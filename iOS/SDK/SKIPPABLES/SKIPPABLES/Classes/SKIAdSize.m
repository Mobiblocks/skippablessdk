//
//  SKIAdSize.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdSize.h"

SKIAdSize const kSKIAdSizeBanner = {320, 50};
SKIAdSize const kSKIAdSizeLargeBanner = {320, 100};
SKIAdSize const kSKIAdSizeFullBanner = {468, 60};
SKIAdSize const kSKIAdSizeMediumRectangle = {300, 250};
SKIAdSize const kSKIAdSizeLeaderboard = {728, 90};
SKIAdSize const kSKIAdSizeLargeLeaderboard = {970, 90};
SKIAdSize const kSKIAdSizeSkyscraper = {120, 600};
SKIAdSize const kSKIAdSizeWideSkyscraper = {160, 600};
SKIAdSize const kSKIAdSizeHalfPage = {300, 600};
SKIAdSize const kSKIAdSizePortrait = {300, 1050};
SKIAdSize const kSKIAdSizeBillboard = {970, 250};

BOOL SKIAdSizeEqualToSize(SKIAdSize size1, SKIAdSize size2) {
	return CGSizeEqualToSize((CGSize)size1, (CGSize)size2);
}
