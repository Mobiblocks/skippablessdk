//
//  SKIAdInterstitialDelegate.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKIAdInterstitial;
@class SKIAdRequestError;

@protocol SKIAdInterstitialDelegate <NSObject>

@optional

#pragma mark Ad Request Lifecycle Notifications
/// Called when an ad request loaded an ad. This is a good opportunity to add this view to the
/// hierarchy if it has not been added yet. If the ad was received as a part of the server-side auto
/// refreshing, you can examine the hasAutoRefreshed property of the view.
- (void)skiInterstitialDidReceiveAd:(SKIAdInterstitial *)interstitial;

#pragma mark Optional Ad Request Lifecycle Notifications
/// Called when an ad request failed. Normally this is because no network connection was available
/// or no ads were available (i.e. no fill). If the error was received as a part of the server-side
/// auto refreshing, you can examine the hasAutoRefreshed property of the view.
- (void)skiInterstitial:(SKIAdInterstitial *)interstitial didFailToReceiveAdWithError:(SKIAdRequestError *)error;

#pragma mark Optional Display-Time Lifecycle Notifications

/// Called just before presenting an interstitial. After this method finishes the interstitial will
/// animate onto the screen. Use this opportunity to stop animations and save the state of your
/// application in case the user leaves while the interstitial is on screen (e.g. to visit the App
/// Store from a link on the interstitial).
- (void)skiInterstitialWillPresent:(SKIAdInterstitial *)ad;

/// Called before the interstitial is to be animated off the screen.
- (void)skiInterstitialWillDismiss:(SKIAdInterstitial *)ad;

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)skiInterstitialDidDismiss:(SKIAdInterstitial *)ad;

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store). The normal
/// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
/// before this.
- (void)skiInterstitialWillLeaveApplication:(SKIAdInterstitial *)ad;

@end
