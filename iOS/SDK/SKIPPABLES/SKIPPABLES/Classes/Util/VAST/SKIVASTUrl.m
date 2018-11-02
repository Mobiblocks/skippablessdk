//
//  SKIVASTUrl.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIVASTUrl.h"

#import "SKIConstants.h"

@implementation SKIVASTUrl

NSString *valueForMacros(NSString *macro, SKIVASTUrlMacroValues *values) {
	macro = macro.uppercaseString;
	
	if ([macro isEqualToString:@"ERRORCODE"]) {
		NSString *value = values.errorCode == SKIVASTNoErrorCode ? @"" : [NSString stringWithFormat:@"%i", (int)values.errorCode];
		return value;
	} else if ([macro isEqualToString:@"CONTENTPLAYHEAD"]) {
		NSString *value = values.contentPlayhead > -1 ? SKIFormattedStringFromInterval(values.contentPlayhead) : @"";
		return value;
	} else if ([macro isEqualToString:@"CACHEBUSTING"] || [macro isEqualToString:@"RANDOM"]) {
		uint32_t rand = arc4random_uniform(89999999) + 10000000;
		NSString *value = [NSString stringWithFormat:@"%u", rand];
		return value;
	} else if ([macro isEqualToString:@"ASSETURI"]) {
		NSString *value = values.assetUrl.absoluteString ?: @"";
		return value;
	} else if ([macro isEqualToString:@"TIMESTAMP"]) {
		NSString *value = SKIFormattedTimestampString();
		return value;
	} else {
		return macro;
	}
	
	return macro;
}

NSString *macrosFrom(NSString *value) {
	NSString *macro = nil;
	
	if (value.length > 2) {
		if ([value hasPrefix:@"["] && [value hasSuffix:@"]"]) {
			macro = [value substringWithRange:(NSRange){1, value.length - 2}];
		} else if ([value hasPrefix:@"{"] && [value hasSuffix:@"}"]) {
			macro = [value substringWithRange:(NSRange){1, value.length - 2}];
		} else if (value.length > 4) {
			if ([value hasPrefix:@"%%"] && [value hasSuffix:@"%%"]) {
				macro = [value substringWithRange:(NSRange){2, value.length - 4}];
			}
		}
	}
	
	return macro.uppercaseString;
}

+ (NSURL *)urlFromUrlAfterReplacingMacros:(NSURL *)url builder:(void (^)(SKIVASTUrlMacroValues *))builder {
	if (url == nil) {
		return url;
	}
	
	NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
	if (urlComponents == nil) {
		return url;
	}
	
	SKIVASTUrlMacroValues *values = [[SKIVASTUrlMacroValues alloc] init];
	builder(values);
	
	if (urlComponents.path) {
		NSArray *components = url.pathComponents;
		if (components.count > 0) {
			NSMutableArray *pathComponents = [NSMutableArray arrayWithCapacity:components.count];
			for (NSString *pc in components) {
				NSString *macro = macrosFrom(pc);
				if (macro == nil) {
					[pathComponents addObject:pc];
					continue;
				}
				NSString *macroValue = valueForMacros(macro, values);
				if (macroValue == nil) {
					[pathComponents addObject:pc];
					continue;
				}
				
				NSString *encoded = [macroValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
				[pathComponents addObject:encoded];
			}
			
			if ([pathComponents.firstObject isEqualToString:@"/"]) {
				[pathComponents removeObjectAtIndex:0];
			}
			
			NSString *path = [@"/" stringByAppendingString:[pathComponents componentsJoinedByString:@"/"]];
			urlComponents.percentEncodedPath = path;
		}
	}
	
	if (urlComponents.queryItems.count == 0) {
		return urlComponents.URL ?: url;
	}
	
	NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray arrayWithCapacity:urlComponents.queryItems.count];
	for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
		NSString *value = queryItem.value;
		NSString *macro = macrosFrom(value);
		if (macro == nil) {
			[queryItems addObject:queryItem];
			continue;
		}
		
		NSString *macroValue = valueForMacros(macro, values);
		if (macroValue == nil) {
			[queryItems addObject:queryItem];
			continue;
		}
		
		NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:queryItem.name value:macroValue];
		[queryItems addObject:item];
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

