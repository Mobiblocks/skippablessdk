//
//  NSArray+Util.m
//  SKIPPABLES
//
//  Created by Daniel on 11/6/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import "NSArray+Util.h"

@implementation NSArray (_SKIUtil)

- (NSArray *)_skiCompactMap:(NSObject *(^)(id))block {
	NSMutableArray *arr = [NSMutableArray array];
	for (NSObject *obj in self) {
		NSObject *map = block(obj);
		if (map) {
			[arr addObject:map];
		}
	}
	
	return arr.copy;
}

@end
