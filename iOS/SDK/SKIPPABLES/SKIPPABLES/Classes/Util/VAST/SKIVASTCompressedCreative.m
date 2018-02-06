//
//  SKIVASTCompressedCreative.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIVASTCompressedCreative.h"

#import "SKIConstants.h"

@implementation SKIVASTCompressedCreative

+ (instancetype)compressed {
	return [[self alloc] init];
}

- (BOOL)maybeShownInLandscape {
	if (!SKIMaybeSupportsLanscapeOrientation()) {
		return NO;
	}
	
	CGFloat mediaWidth = self.mediaFile.width.floatValue;
	CGFloat mediaHeight = self.mediaFile.height.floatValue;
	
	if (mediaWidth > mediaHeight) {
		CGFloat ratio = mediaWidth / mediaHeight;
		if (ratio > 1.50) {
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)hasLandscapeOrientation:(NSArray<NSString *> *)orientations {
	for (NSString *orientationString in orientations) {
		if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
			return YES;
		} else if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
			return YES;
		}
	}
	
	return NO;
}

- (NSDate *)duration {
	if (self.nonLinear) {
		return nil;
	}
	
	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
	
	return creativeInline.linear.duration;
}

- (NSString *)skipoffset {
	if (self.nonLinear) {
		return nil;
	}
	
	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
	
	return creativeInline.linear.skipoffset;
}

- (NSArray<SKIVASTTracking *> *)trackings {
	if (self.nonLinear) {
		return nil;
	}
	
	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
	
	return creativeInline.linear.trackingEvents.trackings;
}

- (SKIVASTClickThrough *)clickThrough {
	if (self.nonLinear) {
		return nil;
	}
	
	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
	
	return creativeInline.linear.videoClicks.clickThrough;
}

- (NSArray<SKIVASTClickTracking *> *)clickTrackings {
	if (self.nonLinear) {
		return nil;
	}
	
	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
	
	return creativeInline.linear.videoClicks.clickTrackings;
}

@end
