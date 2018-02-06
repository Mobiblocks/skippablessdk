//
//  SKIVASTUrl.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIVASTUrl.h"

#import "SKIConstants.h"

@implementation SKIVASTUrl

+ (NSURL *)urlFromUrlAfterReplacingMacros:(NSURL *)url builder:(void (^)(SKIVASTUrlMacroValues *))builder {
	NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
	
	if (urlComponents.queryItems.count == 0) {
		return url;
	}
	
	
	SKIVASTUrlMacroValues *values = [[SKIVASTUrlMacroValues alloc] init];
	builder(values);
	
	NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray arrayWithCapacity:urlComponents.queryItems.count];
	for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
		NSString *value = queryItem.value;
		NSString *macro = nil;
		if (value.length > 2) {
			if ([value hasPrefix:@"["] && [value hasSuffix:@"]"]) {
				macro = [value substringWithRange:(NSRange){1, value.length - 2}];
			} else if ([value hasPrefix:@"{"] && [value hasSuffix:@"}"]) {
				macro = [value substringWithRange:(NSRange){1, value.length - 2}];
			}
		} else if (value.length > 4) {
			if ([value hasPrefix:@"%%"] && [value hasSuffix:@"%%"]) {
				macro = [value substringWithRange:(NSRange){2, value.length - 4}];
			}
		}
		
		macro = macro.uppercaseString;
		
		if ([macro isEqualToString:@"ERRORCODE"]) {
			NSString *value = values.errorCode != SKIVASTNoErrorCode ? @"" : [NSString stringWithFormat:@"%i", (int)values.errorCode];
			NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:queryItem.name value:value];
			[queryItems addObject:item];
		} else if ([macro isEqualToString:@"CONTENTPLAYHEAD"]) {
			NSString *value = values.contentPlayhead > -1 ? @"" : SKIFormattedStringFromInterval(values.contentPlayhead);
			NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:queryItem.name value:value];
			[queryItems addObject:item];
		} else if ([macro isEqualToString:@"CACHEBUSTING"] || [macro isEqualToString:@"RANDOM"]) {
			uint32_t rand = arc4random_uniform(89999999) + 10000000;
			NSString *value = [NSString stringWithFormat:@"%u", rand];
			NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:queryItem.name value:value];
			[queryItems addObject:item];
		} else if ([macro isEqualToString:@"ASSETURI"]) {
			NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:queryItem.name value:values.assetUrl ? @"" : values.assetUrl.absoluteString];
			[queryItems addObject:item];
		} else if ([macro isEqualToString:@"TIMESTAMP"]) {
			NSString *value = SKIFormattedTimestampString();
			NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:queryItem.name value:value];
			[queryItems addObject:item];
		} else {
			[queryItems addObject:queryItem];
		}
	}
	
	urlComponents.queryItems = queryItems;
	
	return urlComponents.URL ?: url;
}

@end

@implementation SKIVASTUrlMacroValues

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.errorCode = SKIVASTNoErrorCode;
		self.contentPlayhead = -1;
	}
	return self;
}

@end

