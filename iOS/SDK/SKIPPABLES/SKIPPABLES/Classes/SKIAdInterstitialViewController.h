//
//  SKIAdInterstitialViewController.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SKIViewController.h"

@class SKIAdRequestError;
@class SKIAdInterstitialViewController;

@protocol SKIAdInterstitialViewControllerDelegate<NSObject>

- (void)interstitialViewControllerDidFinishLoading:(SKIAdInterstitialViewController *)controller;
- (void)interstitialViewController:(SKIAdInterstitialViewController *)controller didFailToLoadWithErr:(SKIAdRequestError *)error;

@end

@class SKIAdInterstitial;

@interface SKIAdInterstitialViewController : SKIViewController

+ (instancetype)viewController;

- (void)preloadWithAd:(SKIAdInterstitial *)ad;

@end
