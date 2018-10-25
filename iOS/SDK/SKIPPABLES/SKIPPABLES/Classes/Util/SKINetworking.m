//
//  SKINetworking.m
//  SKIPPABLES
//
//  Created by Daniel on 10/25/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import "SKINetworking.h"

#import "SKIAsync.h"
#import "SKIConstants.h"

@interface SKINetworkCall<__covariant T: NSURLSessionTask *> ()

@property (strong, nonnull) T sessionTask;
@property (copy, nonnull) SKIAsyncWaterfallTask asyncTask;
@property (assign, nonatomic) NSUInteger retries;
@property (assign, atomic) BOOL tasksCreated;

@end

@implementation SKINetworking

+ (SKINetworkCall<NSURLSessionDataTask *> *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
	
	NSURLSession *session = [NSURLSession sharedSession];
	
	__block SKINetworkCall *call = [[SKINetworkCall alloc] init];
	__weak SKINetworkCall *wCall = call;
	call.asyncTask = ^(id<NSObject> _Nullable result, SKIAsyncWaterfallCallback _Nonnull callback) {
		wCall.sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			if (call.isCanceled == NO && error.domain == NSURLErrorDomain) {
				if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorCancelled) {
					DLog(@"retry n call");
					DLog(@"retry after: %@", error.debugDescription);
					callback(nil, nil);
					
					return;
				}
			}
			
			SKIAsyncOnMain(^{
				completionHandler(data, response, error);
			});
			
			DLog(@"retry n call good");
			callback(nil, [NSError errorWithDomain:@"SKINetworking" code:NSURLErrorCancelled userInfo:nil]);
			
			call = nil;
		}];
		
		[wCall.sessionTask resume];
	};
	
	return call;
}

+ (SKINetworkCall<NSURLSessionDataTask *> *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
	NSURLSession *session = [NSURLSession sharedSession];
	
	__block SKINetworkCall *call = [[SKINetworkCall alloc] init];
	__weak SKINetworkCall *wCall = call;
	call.asyncTask = ^(id<NSObject> _Nullable result, SKIAsyncWaterfallCallback _Nonnull callback) {
		wCall.sessionTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			if (call.isCanceled == NO && error.domain == NSURLErrorDomain) {
				if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorCancelled) {
					DLog(@"retry n call");
					DLog(@"retry after: %@", error.debugDescription);
					callback(nil, nil);
					
					return;
				}
			}
			
			SKIAsyncOnMain(^{
				completionHandler(data, response, error);
			});
			
			DLog(@"retry n call good");
			callback(nil, [NSError errorWithDomain:@"SKINetworking" code:NSURLErrorCancelled userInfo:nil]);
			
			call = nil;
		}];
		
		[wCall.sessionTask resume];
	};
	
	return call;
}

+ (SKINetworkCall<NSURLSessionDownloadTask *> *)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
	NSURLSession *session = [NSURLSession sharedSession];
	
	__block SKINetworkCall *call = [[SKINetworkCall alloc] init];
	__weak SKINetworkCall *wCall = call;
	call.asyncTask = ^(id<NSObject> _Nullable result, SKIAsyncWaterfallCallback _Nonnull callback) {
		wCall.sessionTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			if (call.isCanceled == NO && error.domain == NSURLErrorDomain) {
				if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorCancelled) {
					DLog(@"retry n call");
					DLog(@"retry after: %@", error.debugDescription);
					callback(nil, nil);
					
					return;
				}
			}
			
			SKISyncOnMain(^{
				completionHandler(location, response, error);
			});
			
			DLog(@"retry n call good");
			callback(nil, [NSError errorWithDomain:@"SKINetworking" code:NSURLErrorCancelled userInfo:nil]);
			
			call = nil;
		}];
		
		[wCall.sessionTask resume];
	};
	
	return call;
}

@end

@implementation SKINetworkCall

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.retries = -1;
	}
	return self;
}

- (instancetype)retry:(NSUInteger)times {
	self.retries = MIN(MAX(times, 1), 100);
	
	return self;
}

- (void)resume {
	if(self.tasksCreated == NO) {
		self.tasksCreated = YES;
		NSUInteger count = MAX(1, self.retries);
		NSMutableArray<SKIAsyncWaterfallTask> *tasks = [NSMutableArray arrayWithCapacity:count];
		for (int i = 0; i < count; i++) {
			[tasks addObject:self.asyncTask];
		}
		
		[SKIAsync waterfall:tasks completion:nil];
	}
	
	[self.sessionTask resume];
}

- (void)suspend {
	[self.sessionTask suspend];
}

- (void)cancel {
	[self.sessionTask cancel];
}

- (void)dealloc {
	DLog("dealloc network call");
}

@end
