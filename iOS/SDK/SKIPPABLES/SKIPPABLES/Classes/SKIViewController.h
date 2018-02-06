//
//  SKIViewController.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKIViewController : UIViewController

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)applicationWillResignActiveNotification:(NSNotification *)notification NS_REQUIRES_SUPER;

- (void)applicationDidBecomeActive:(BOOL)previouslyVisible NS_REQUIRES_SUPER;
- (void)applicationWillResignActive:(BOOL)previouslyVisible NS_REQUIRES_SUPER;

@end
