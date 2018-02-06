//
//  SKIAdRequest_Private.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#ifndef SKIAdRequest_Private_h
#define SKIAdRequest_Private_h

#import "SKIAdSize.h"

typedef NS_ENUM(NSInteger, SKIAdType) {
	kSKIAdTypeBannerText        = 0,
	kSKIAdTypeBannerImage       = 1,
	kSKIAdTypeBannerRichmedia   = 2,
	kSKIAdTypeInterstitial      = 3,
	kSKIAdTypeInterstitialVideo = 4,
};

extern SKIAdSize const kSKIAdSizeFullscreen;

@class SKIAdRequestResponse;
@class SKIAdRequestError;

@protocol SKIAdRequestDelegate<NSObject>

- (void)skiAdRequest:(SKIAdRequest *)request didReceiveResponse:(SKIAdRequestResponse *)response;
- (void)skiAdRequest:(SKIAdRequest *)request didFailWithError:(SKIAdRequestError *)error;

@end

@interface SKIAdRequest (_Private)

- (void)load;
- (void)cancel;

@property (assign, nonatomic) SKIAdType adType;
@property (assign, nonatomic) SKIAdSize adSize;

@property (weak, nonatomic) id<SKIAdRequestDelegate> delegate;

@property (copy, nonatomic) NSString *adUnitID;

@end

#endif /* SKIAdRequest_Private_h */
