//
//  SKIAsync.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SKIAsyncWaterfallCallback)(NSError *_Nullable error, id _Nullable result);
typedef void (^SKIAsyncWaterfallCompletion)(NSError *_Nullable error, id _Nullable result);
typedef void (^SKIAsyncWaterfallTask)(id<NSObject> _Nullable result, SKIAsyncWaterfallCallback callback);

typedef void (^SKIAsyncParallelCallback)(id<NSObject> _Nullable result);
typedef void (^SKIAsyncParallelTask)(SKIAsyncParallelCallback callback);
typedef void (^SKIAsyncParallelCompletion)(NSArray *results);

@interface SKIAsync : NSObject

+ (void)waterfall:(NSArray<SKIAsyncWaterfallTask> *)tasks completion:(nullable SKIAsyncWaterfallCompletion)completion;
+ (void)parallel:(NSArray<SKIAsyncParallelTask> *)tasks completion:(nullable SKIAsyncParallelCompletion)completion;

@end

NS_ASSUME_NONNULL_END
