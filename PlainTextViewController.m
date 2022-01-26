//
//  PlainTextViewController.m
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2019/3/12.
//  Copyright © 2019 Zheng Wu. All rights reserved.
//

#import "PlainTextViewController.h"
#import "ICTextView.h"

@interface PlainTextViewController () <UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) ICTextView *contentTextView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIBarButtonItem *trashItem;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation PlainTextViewController {
    BOOL _shouldEndEditing;
}
@synthesize entryPath = _entryPath;

+ (NSString *)viewerName {
    return NSLocalizedString(@"Text Viewer", @"PlainTextViewController");
}

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        _entryPath = path;
        _shouldEndEditing = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.title.length == 0) {
        if (self.entryPath) {
            NSString *entryName = [self.entryPath lastPathComponent];
            self.title = entryName;
        } else {
            self.title = [[self class] viewerName];
        }
    }
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    self.searchController = ({
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        searchController.searchResultsUpdater = self;
        searchController.obscuresBackgroundDuringPresentation = NO;
        searchController.hidesNavigationBarDuringPresentation = YES;
        searchController.searchBar.returnKeyType = UIReturnKeyNext;
        searchController.searchBar.delegate = self;
        searchController;
    });
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    if (self.allowTrash) {
        self.navigationItem.rightBarButtonItem = self.trashItem;
    }
    
    if (self.allowSearch) {
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
        self.navigationItem.searchController = self.searchController;
    }

    if (self.pullToReload) {
        [self.contentTextView setRefreshControl:self.refreshControl];
    }
    
    [self.view addSubview:self.contentTextView];
    [self loadTextDataFromEntry];
    [self registerKeyboardNotifications];
}

- (void)reloadTextDataFromEntry:(UIRefreshControl *)sender {
    [self loadTextDataFromEntry];
    if ([sender isRefreshing]) {
        [sender endRefreshing];
    }
}

- (void)loadTextDataFromEntry {
    NSString *entryPath = self.entryPath;
    if (!entryPath) {
        return;
    }
    if (0 != access(entryPath.fileSystemRepresentation, W_OK)) {
        [[NSData data] writeToFile:entryPath atomically:YES];
    }
    NSURL *fileURL = [NSURL fileURLWithPath:entryPath];
    NSError *readError = nil;
    NSFileHandle *textHandler = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&readError];
    if (readError) {
        [self.contentTextView setText:readError.localizedDescription];
        return;
    }
    if (!textHandler) {
        return;
    }
    NSData *dataPart = [textHandler readDataOfLength:1024 * 1024];
    [textHandler closeFile];
    if (!dataPart) {
        return;
    }
    NSString *stringPart = [[NSString alloc] initWithData:dataPart encoding:NSUTF8StringEncoding];
    if (!stringPart) {
        [self.contentTextView setText:[NSString stringWithFormat:NSLocalizedString(@"Cannot parse text with UTF-8 encoding: \"%@\".", nil), [entryPath lastPathComponent]]];
        return;
    }
    if (stringPart.length == 0) {
        [self.contentTextView setText:[NSString stringWithFormat:NSLocalizedString(@"The content of text file \"%@\" is empty.", nil), [entryPath lastPathComponent]]];
    } else {
        [self.contentTextView setText:stringPart];
    }

    [self.contentTextView setSelectedRange:NSMakeRange(0, 0)];
}

- (void)trashItemTapped:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm", @"PlainTextViewController") message:[NSString stringWithFormat:NSLocalizedString(@"Do you want to clear this log file \"%@\"?", @"PlainTextViewController"), [self.entryPath lastPathComponent]] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"PlainTextViewController") style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {

                      }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"PlainTextViewController") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                          [[NSData data] writeToFile:self.entryPath atomically:YES];
                          [self loadTextDataFromEntry];
                      }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIView Getters

- (UITextView *)contentTextView {
    if (!_contentTextView) {
        ICTextView *logTextView = [[ICTextView alloc] initWithFrame:self.view.bounds];
        logTextView.selectable = YES;
        logTextView.scrollsToTop = YES;
        logTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        logTextView.editable = NO;
        logTextView.returnKeyType = UIReturnKeyDefault;
        logTextView.dataDetectorTypes = UIDataDetectorTypeNone;
        logTextView.textAlignment = NSTextAlignmentLeft;
        logTextView.allowsEditingTextAttributes = NO;
        logTextView.alwaysBounceVertical = YES;
        logTextView.font = [UIFont monospacedSystemFontOfSize:14.0 weight:UIFontWeightRegular];
        logTextView.smartDashesType = UITextSmartDashesTypeNo;
        logTextView.smartQuotesType = UITextSmartQuotesTypeNo;
        logTextView.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
        logTextView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        logTextView.searchOptions = NSRegularExpressionCaseInsensitive;
        logTextView.circularSearch = YES;
        logTextView.scrollPosition = ICTextViewScrollPositionMiddle;
        _contentTextView = logTextView;
    }
    return _contentTextView;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(reloadTextDataFromEntry:) forControlEvents:UIControlEventValueChanged];
        _refreshControl = refreshControl;
    }
    return _refreshControl;
}

- (UIBarButtonItem *)trashItem {
    if (!_trashItem) {
        _trashItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashItemTapped:)];
    }
    return _trashItem;
}

- (void)registerKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTextViewInsetsWithKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTextViewInsetsWithKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)updateTextViewInsetsWithKeyboardNotification:(NSNotification *)notification
{
    UIEdgeInsets newInsets = UIEdgeInsetsZero;
    if (notification)
    {
        CGRect keyboardFrame;
        [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
        newInsets.bottom = [self.view bounds].size.height - keyboardFrame.origin.y - self.view.safeAreaInsets.bottom;
    }
    UITextView *textView = self.contentTextView;
    textView.contentInset = newInsets;
    textView.scrollIndicatorInsets = newInsets;
}

#pragma mark - UISearchResultsUpdating

- (void)doNextSearch {
    [self.contentTextView scrollToString:self.searchController.searchBar.text searchDirection:ICTextViewSearchDirectionForward];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self doNextSearch];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return _shouldEndEditing;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _shouldEndEditing = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _shouldEndEditing = NO;
    [self doNextSearch];
}

#pragma mark -

- (void)dealloc {
#if DEBUG
    NSLog(@"-[%@ dealloc]", [self class]);
#endif
}

@end
