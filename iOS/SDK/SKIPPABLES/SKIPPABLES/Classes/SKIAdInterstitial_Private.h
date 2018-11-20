//
//  SKIAdInterstitial_Private.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#ifndef SKIAdInterstitial_Private_h
#define SKIAdInterstitial_Private_h

@class SKIAdRequestResponse;
@class SKIErrorCollector;
@class SKISDKSessionLogger;

@interface SKIAdInterstitial (Private) <SKIAdInterstitialViewControllerDelegate>

@property (strong, nonatomic) SKIAdRequestResponse *response;
@property (assign, nonatomic) BOOL logErrors;
@property (strong, nonatomic) SKIErrorCollector *errorCollector;
@property (strong, nonatomic, readonly) SKISDKSessionLogger *sessionLogger;

@end

#endif /* SKIAdInterstitial_Private_h */
