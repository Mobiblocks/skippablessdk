//
//  SKIAdRequestResponse.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKIAdRequestError;
@class SKICompactVast;

@interface SKIAdRequestResponse : NSObject

+ (instancetype)response;

@property (copy, nonatomic) NSString *htmlSnippet;
@property (copy, nonatomic) NSString *videoVast;
@property (strong, nonatomic) SKICompactVast *compactVast;
@property (copy, nonatomic) NSString *clickThroughUrl;
@property (copy, nonatomic) NSString *impressionTrackingUrl;
@property (copy, nonatomic) NSString *clickTrackingUrl;

@property (copy, nonatomic) NSDictionary *rawResponse;

@property (copy, nonatomic) NSDictionary *deviceInfo;

@property (strong, nonatomic) SKIAdRequestError *error;

@end
