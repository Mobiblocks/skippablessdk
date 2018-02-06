//
//  SKIAdEventTracker.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKIAdEventTracker : NSObject

+ (instancetype)defaultTracker;

- (void)trackEventRequestWithUrl:(NSURL *)url;
- (void)trackErrorRequestWithUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
