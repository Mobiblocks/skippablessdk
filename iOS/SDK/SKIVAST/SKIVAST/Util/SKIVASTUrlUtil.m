//
//  SKIVASTUrlUtil.m
//  SKIVAST
//
//  Created by Daniel on 10/22/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import "SKIVASTUrlUtil.h"

@implementation SKIVASTUrlUtil

+ (NSURL *)URLWithCString:(const char *)cString errorFixed:(BOOL *)errorFixed {
	*errorFixed = NO;
	
	NSString *value = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSURL *url = [NSURL URLWithString:value];
	if (url == nil) {
		value = [value stringByRemovingPercentEncoding];
		value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		url = [NSURL URLWithString:value];
		
		*errorFixed = url != nil;
	}
	
	return url;
}

@end
