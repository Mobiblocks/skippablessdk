//
//  SKIAdInterstitial_Private.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#ifndef SKIAdInterstitial_Private_h
#define SKIAdInterstitial_Private_h

@class SKIAdRequestResponse;

@interface SKIAdInterstitial (Private) <SKIAdInterstitialViewControllerDelegate>

@property (strong, nonatomic) SKIAdRequestResponse *response;

@end

#endif /* SKIAdInterstitial_Private_h */
