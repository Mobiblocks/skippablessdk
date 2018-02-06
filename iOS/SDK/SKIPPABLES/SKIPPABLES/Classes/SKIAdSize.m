//
//  SKIAdSize.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdSize.h"

SKIAdSize const kSKIAdSizeBanner = {320.f, 50.f};

SKIAdSize const kSKIAdSizeMediumRectangle = {320.f, 100.f};

SKIAdSize const kSKIAdSizeHalfPage = {320.f, 480.f};

BOOL SKIAdSizeEqualToSize(SKIAdSize size1, SKIAdSize size2) {
	return CGSizeEqualToSize((CGSize)size1, (CGSize)size2);
}
