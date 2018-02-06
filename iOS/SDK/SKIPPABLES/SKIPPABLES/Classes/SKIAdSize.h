//
//  SKIAdSize.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef CGSize SKIAdSize;

/// iPhone and iPod Touch ad size. Typically 320x50.
extern SKIAdSize const kSKIAdSizeBanner;

/// Medium Rectangle size for the iPad (especially in a UISplitView's left pane). Typically 320x100.
extern SKIAdSize const kSKIAdSizeMediumRectangle;

/// Skyscraper size for the iPad. Typically 320x480.
extern SKIAdSize const kSKIAdSizeHalfPage;

BOOL SKIAdSizeEqualToSize(SKIAdSize size1, SKIAdSize size2);
