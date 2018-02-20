//
//  SKIAdReportViewController.h
//  SKIPPABLES
//
//  Created by Daniel on 2/16/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKIAdReportViewController : UITableViewController

+ (nonnull UINavigationController *)navigatingViewControllerWidthCallback:(void (^_Nonnull)(BOOL canceled, NSString *_Nullable email, NSString *_Nullable message))callback;
+ (void)showFromViewController:(nonnull UIViewController *)viewController callback:(void (^_Nonnull)(BOOL canceled, NSString *_Nullable email, NSString *_Nullable message))callback;

@end
