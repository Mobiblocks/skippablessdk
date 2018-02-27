//
//  SKIAdSize.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef CGSize SKIAdSize;

extern SKIAdSize const kSKIAdSizeBanner; // 320x50
extern SKIAdSize const kSKIAdSizeLargeBanner; // 320x100
extern SKIAdSize const kSKIAdSizeFullBanner; // 468x60
extern SKIAdSize const kSKIAdSizeLeaderboard; // 728x90
extern SKIAdSize const kSKIAdSizeLargeLeaderboard; // 970x90

BOOL SKIAdSizeEqualToSize(SKIAdSize size1, SKIAdSize size2);
