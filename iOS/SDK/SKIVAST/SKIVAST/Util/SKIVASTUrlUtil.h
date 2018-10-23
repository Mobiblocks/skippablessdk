//
//  SKIVASTUrlUtil.h
//  SKIVAST
//
//  Created by Daniel on 10/22/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKIVASTUrlUtil : NSObject

+ (nullable NSURL *)URLWithCString:(const char *)cString errorFixed:(nullable BOOL *)errorFixed;

@end

NS_ASSUME_NONNULL_END
