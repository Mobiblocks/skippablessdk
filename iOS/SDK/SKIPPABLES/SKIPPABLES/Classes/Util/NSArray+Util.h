//
//  NSArray+Util.h
//  SKIPPABLES
//
//  Created by Daniel on 11/6/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (_SKIUtil)
- (NSArray *)_skiCompactMap:(NSObject * (^__nonnull)(ObjectType obj))block;
@end

NS_ASSUME_NONNULL_END
