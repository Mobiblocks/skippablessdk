//
//  SKIAdRequestResponse.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKIAdRequestError;

@interface SKIAdRequestResponse : NSObject

+ (instancetype)response;

@property (copy, nonatomic) NSString *htmlSnippet;
@property (copy, nonatomic) NSString *videoVast;
@property (copy, nonatomic) NSString *clickThroughUrl;
@property (copy, nonatomic) NSString *impressionTrackingUrl;
@property (copy, nonatomic) NSString *clickTrackingUrl;

@property (copy, nonatomic) NSDictionary *rawResponse;

@property (strong, nonatomic) SKIAdRequestError *error;

@end
