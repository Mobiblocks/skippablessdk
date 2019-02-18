//
//  SKIAdInterstitialViewController.h
//  SKIPPABLES
//
//  Created by Daniel on 2/18/19.
//  Copyright © 2019 Mobiblocks. All rights reserved.
//

#import "SKIViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SKIAdRequestError;
@class SKIAdInterstitial;
@class SKIAdInterstitialViewController;

@protocol SKIAdInterstitialViewControllerDelegate<NSObject>

- (void)interstitialViewControllerDidFinishLoading:(SKIAdInterstitialViewController *)controller;
- (void)interstitialViewController:(SKIAdInterstitialViewController *)controller didFailToLoadWithErr:(SKIAdRequestError *)error;

@end

@interface SKIAdInterstitialViewController : SKIViewController

+ (instancetype)viewController;

@property (strong, nonatomic) SKIAdInterstitial *ad;
@property (weak, nonatomic) id<SKIAdInterstitialViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
