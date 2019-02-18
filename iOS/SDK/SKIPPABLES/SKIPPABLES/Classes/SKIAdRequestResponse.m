//
//  SKIAdRequestResponse.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdRequestResponse.h"
#import "SKIConstants.h"

@implementation SKIAdRequestResponse

+ (instancetype)response {
	return [[self alloc] init];
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.interstitialType = kSKIAdTypeInterstitialTypeAny;
	}
	return self;
}

@end
