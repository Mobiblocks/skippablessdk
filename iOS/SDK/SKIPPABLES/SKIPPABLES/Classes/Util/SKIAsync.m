//
//  SKIAsync.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAsync.h"

dispatch_queue_t get_async_dispatch_queue() {
	static dispatch_queue_t _queue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_queue = dispatch_queue_create("com.skippables.async", DISPATCH_QUEUE_CONCURRENT);
	});

	return _queue;
}

@interface SKIAsyncWaterfall : NSObject

+ (instancetype)async;

- (void)waterfall:(NSArray<SKIAsyncWaterfallTask> *)tasks completion:(SKIAsyncWaterfallCompletion)completion;

@property (strong, nonatomic) NSError *taskError;
@property (strong, nonatomic) id taskResult;
@property (strong, nonatomic) NSEnumerator<SKIAsyncWaterfallTask> *taskEnumerator;
@property (copy, nonatomic) SKIAsyncWaterfallCallback callbackBlock;
@property (copy, nonatomic) SKIAsyncWaterfallCompletion completionBlock;

@property (strong, nonatomic) id strongSelf;

@end

@interface SKIAsyncParallel : NSObject

+ (instancetype)async;

- (void)parallel:(NSArray<SKIAsyncParallelTask> *)tasks completion:(SKIAsyncParallelCompletion)completion;

@property (assign, atomic) NSUInteger tasksCount;
@property (assign, atomic) NSUInteger tasksCompleted;
@property (strong, atomic) NSMutableArray *results;

@property (copy, nonatomic) SKIAsyncParallelCompletion completionBlock;

@property (strong, nonatomic) id strongSelf;

@end

@implementation SKIAsync

+ (void)waterfall:(NSArray<SKIAsyncWaterfallTask> *)tasks completion:(SKIAsyncWaterfallCompletion)completion {
	if (tasks.count > 0) {
		[[SKIAsyncWaterfall async] waterfall:tasks completion:completion];
	} else {
		if (completion) {
			completion(nil, nil);
		}
	}
}

+ (void)parallel:(NSArray<SKIAsyncParallelTask> *)tasks completion:(SKIAsyncParallelCompletion)completion {
	if (tasks.count > 0) {
		[[SKIAsyncParallel async] parallel:tasks completion:completion];
	} else {
		if (completion) {
			completion(@[]);
		}
	}
}

@end

@implementation SKIAsyncWaterfall

+ (instancetype)async {
	SKIAsyncWaterfall *async = [[self alloc] init];
	return async;
}

- (void)waterfall:(NSArray<SKIAsyncWaterfallTask> *)tasks completion:(SKIAsyncWaterfallCompletion)completion {
	self.strongSelf = self;

	self.taskEnumerator = tasks.objectEnumerator;
	self.completionBlock = completion;

	__weak typeof(self) wSelf = self;
	self.callbackBlock = ^(NSError *error, id result) {
		wSelf.taskError = error;
		wSelf.taskResult = result;

		if (wSelf.taskError) {
			if (wSelf.completionBlock) {
				wSelf.completionBlock(wSelf.taskError, nil);
			}

			wSelf.strongSelf = nil;
			return;
		}

		[wSelf nextTask:nil result:nil];
	};

	[wSelf nextTask:nil result:nil];
}

- (void)nextTask:(NSError *)error result:(id)result {
	SKIAsyncWaterfallTask task = self.taskEnumerator.nextObject;
	if (!task) {
		if (self.completionBlock) {
			self.completionBlock(self.taskError, self.taskResult);
		}

		self.strongSelf = nil;

		return;
	}

	dispatch_async(get_async_dispatch_queue(), ^{
		@autoreleasepool {
			task(self.taskResult, self.callbackBlock);
		}
	});
}

- (void)dealloc {
}

@end

@implementation SKIAsyncParallel

+ (instancetype)async {
	SKIAsyncParallel *async = [[self alloc] init];

	return async;
}

- (void)parallel:(NSArray<SKIAsyncParallelTask> *)tasks completion:(SKIAsyncParallelCompletion)completion {
	self.strongSelf = self;
	self.results = [NSMutableArray arrayWithCapacity:tasks.count];
	self.tasksCount = tasks.count;
	self.completionBlock = completion;

	NSUInteger index = 0;
	for (SKIAsyncParallelTask task in tasks) {
		[self.results addObject:[NSNull null]];

		NSUInteger taskIndex = index++;

		dispatch_async(get_async_dispatch_queue(), ^{
			task(^(id result) {
				[self finishTask:taskIndex result:result];
			});
		});
	}
}

- (void)finishTask:(NSUInteger)taskIndex result:(id)result {
	@synchronized(self) {
		self.results[taskIndex] = result ?: [NSNull null];
		self.tasksCompleted++;

		if (self.tasksCompleted == self.tasksCount) {
			if (self.completionBlock) {
				self.completionBlock(self.results);
			}

			self.strongSelf = nil;
		}
	}
}

- (void)dealloc {
}

@end
