//
//  ViewController.m
//  PlainTextViewControllerExample
//
//  Created by Lessica on 2024/1/14.
//

#import "ViewController.h"
#import "PlainTextViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)showButtonTapped:(id)sender {
    PlainTextViewController *ctrl = [[PlainTextViewController alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"passwd" ofType:@""]];
    ctrl.pullToReload = YES;
    ctrl.allowSearch = YES;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
