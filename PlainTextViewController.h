//
//  PlainTextViewController.h
//  CommonViewControllers
//
//  Created by Lessica <82flex@gmail.com> on 2019/3/12.
//  Copyright © 2019 Zheng Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlainTextViewController : UIViewController

- (instancetype)initWithPath:(NSString *)path;
@property (nonatomic, copy, readonly) NSString *entryPath;

@property (nonatomic, assign) BOOL allowTrash;
@property (nonatomic, assign) BOOL pullToReload;
@property (nonatomic, assign) BOOL allowSearch;

@end

NS_ASSUME_NONNULL_END
