//
//  SKIAdBannerView.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SKIAdSize.h"
#import "SKIAdRequest.h"
#import "SKIAdBannerViewDelegate.h"

@interface SKIAdBannerView : UIView

@property (copy, nonatomic, nonnull) IBInspectable NSString *adUnitID;

@property (assign, nonatomic) SKIAdSize adSize;

@property (assign, nonatomic) BOOL scaleToFillWidth;

@property (weak, nonatomic, nullable) IBOutlet id<SKIAdBannerViewDelegate> delegate;

@property (weak, nonatomic, nullable) IBOutlet UIViewController *rootViewController;

+ (nonnull instancetype)bannerView;

/// Makes an ad request. The request object supplies targeting information.
- (void)loadRequest:(nonnull SKIAdRequest *)request;

@end
