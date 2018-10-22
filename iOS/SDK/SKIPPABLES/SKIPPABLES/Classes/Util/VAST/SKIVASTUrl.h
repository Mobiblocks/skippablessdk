//
//  SKIVASTUrl.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKIVAST.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKIVASTUrlMacroValues : NSObject

@property (assign, nonatomic) SKIVASTErrorCode errorCode;
@property (copy, nonatomic) NSString *skiErrorDescription;
@property (assign, nonatomic) NSTimeInterval contentPlayhead;
@property (strong, nonatomic, nullable) NSURL *assetUrl;

@end

@interface SKIVASTUrl : NSObject

+ (NSURL *)urlFromUrlAfterReplacingMacros:(NSURL *)url builder:(void (^)(SKIVASTUrlMacroValues *macroValues))builder;

@end

NS_ASSUME_NONNULL_END
