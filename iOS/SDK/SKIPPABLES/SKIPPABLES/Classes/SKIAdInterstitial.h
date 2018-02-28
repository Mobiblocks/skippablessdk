//
//  SKIAdInterstitial.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SKIAdRequest.h"
#import "SKIAdInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKIAdInterstitial : NSObject

@property (copy, nonatomic) NSString *adUnitID;

@property (weak, nonatomic) id<SKIAdInterstitialDelegate> delegate;

+ (instancetype)interstitial;

/// Makes an interstitial ad request. Only one interstitial request is allowed at a time.
///
/// This is best to do several seconds before the interstitial is needed to preload its content.
/// Then when transitioning between view controllers show the interstital with
/// presentFromViewController.
- (void)loadRequest:(SKIAdRequest *)request;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;

/// Returns YES if the interstitial is currently loading.
@property(assign, nonatomic, readonly) BOOL isLoading;

/// Returns YES if the interstitial is ready to be displayed. The delegate's
/// skiInterstitialDidReceiveAd: will be called after this property switches from NO to YES.
@property(assign, nonatomic, readonly) BOOL isReady;

/// Returns YES if this object has already been presented. Interstitial objects can only be used
/// once even with different requests.
@property(assign, nonatomic, readonly) BOOL hasBeenUsed;

@end

NS_ASSUME_NONNULL_END
