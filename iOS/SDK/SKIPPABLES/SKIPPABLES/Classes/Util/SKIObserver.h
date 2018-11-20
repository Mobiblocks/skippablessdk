//
//  SKIObserver.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKIObserver;

typedef void(^SKIObserverCallback)(SKIObserver *observer, NSDictionary<NSKeyValueChangeKey,id> *change);
typedef void(^SKIObserverTimeoutCallback)(SKIObserver *observer);

@interface SKIObserver : NSObject

+ (instancetype)observeObject:(NSObject *)object
				   forKeyPath:(NSString *)keyPath
					 callback:(SKIObserverCallback)callback
					  timeout:(SKIObserverTimeoutCallback)timeout;
+ (instancetype)observeObject:(NSObject *)object
                   forKeyPath:(NSString *)keyPath
                      timeout:(NSTimeInterval)timeout
					 callback:(SKIObserverCallback)callback
					  timeout:(SKIObserverTimeoutCallback)timeout;

- (void)remove;

@property (strong, nonatomic, readonly) NSObject *object;
@property (copy, nonatomic, readonly) NSString *keyPath;

@end
