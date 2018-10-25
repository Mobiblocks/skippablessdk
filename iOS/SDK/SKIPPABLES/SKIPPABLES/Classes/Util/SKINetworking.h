//
//  SKINetworking.h
//  SKIPPABLES
//
//  Created by Daniel on 10/25/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKINetworkCall<__covariant T: NSURLSessionTask *> : NSObject

- (instancetype)retry:(NSUInteger)times;

- (void)resume;
- (void)suspend;
- (void)cancel;

@property (strong, nonnull, readonly) T sessionTask;
@property (assign, readonly, atomic) BOOL isCanceled;

@end

@interface SKINetworking : NSObject

+ (SKINetworkCall<NSURLSessionDataTask *> *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
+ (SKINetworkCall<NSURLSessionDataTask *> *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

//+ (SKINetworkCall<NSURLSessionUploadTask *> *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
//+ (SKINetworkCall<NSURLSessionUploadTask *> *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

//+ (SKINetworkCall<NSURLSessionDownloadTask *> *)downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
+ (SKINetworkCall<NSURLSessionDownloadTask *> *)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
//+ (SKINetworkCall<NSURLSessionDownloadTask *> *)downloadTaskWithResumeData:(NSData *)resumeData completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
