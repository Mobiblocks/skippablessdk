//
//  SKIAdRequest_Private.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#ifndef SKIAdRequest_Private_h
#define SKIAdRequest_Private_h

#import "SKIAdSize.h"
#import "SKIConstants.h"

extern SKIAdSize const kSKIAdSizeFullscreen;

@class SKIAdRequestResponse;
@class SKIAdRequestError;
@class SKIErrorCollector;
@class SKISDKSessionLogger;

@protocol SKIAdRequestDelegate<NSObject>

- (void)skiAdRequest:(SKIAdRequest *)request didReceiveResponse:(SKIAdRequestResponse *)response;

@end

@interface SKIAdRequest (_Private)

- (void)load;
- (void)cancel;

@property (assign, nonatomic) SKIAdType adType;
@property (assign, nonatomic) SKIAdSize adSize;

@property (weak, nonatomic) id<SKIAdRequestDelegate> delegate;

@property (copy, nonatomic) NSString *adUnitID;
@property (strong, nonatomic) SKIErrorCollector *errorCollector;
@property (strong, nonatomic) SKISDKSessionLogger *sessionLogger;
@property (assign, nonatomic) BOOL logErrors;

@end

#endif /* SKIAdRequest_Private_h */
