//
//  SKIVAST.h
//  SKIVAST
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for SKIVAST.
FOUNDATION_EXPORT double SKIVASTVersionNumber;

//! Project version string for SKIVAST.
FOUNDATION_EXPORT const unsigned char SKIVASTVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SKIVAST/PublicHeader.h>

typedef NS_OPTIONS(NSInteger, SKIVASTErrorCode) {
	SKIVASTNoErrorCode = 0, /* No error. */
	
	SKIVASTXMLParseErrorCode = 100, /* XML parsing error. */
	SKIVASTSchemaValidationErrorCode = 101, /* VAST schema validation error. */
	SKIVASTUnsupportedVersionErrorCode = 102, /* VAST version of response not supported. */
	SKIVASTTraffickingErrorCode = 200, /* Trafficking error. Video player received an Ad type that it was not expecting and/or cannot display. */
	
	SKIVASTBadVideoLinearityErrorCode = 201, /* Video player expecting different linearity. */
	SKIVASTBadVideoDurationErrorCode = 202, /* Video player expecting different duration. */
	SKIVASTBadVideoSizeErrorCode = 203, /* Video player expecting different size. */
	SKIVASTMissingAdCategoryErrorCode = 204, /* Ad category was required but not provided. */
	
	SKIVASTGeneralWrapperErrorCode = 300, /* General Wrapper error. */
	SKIVASTWrapperTimeoutErrorCode = 301, /* Timeout of VAST URI provided in Wrapper element, or of VAST URI provided in a subsequent Wrapper element. (URI was either unavailable or reached a timeout as defined by the video player.) */
	SKIVASTWrapperLimitErrorCode = 302, /* Wrapper limit reached, as defined by the video player. Too many Wrapper responses have been received with no InLine response. */
	SKIVASTWrapperNoVastErrorCode = 303, /* No VAST response after one or more Wrappers. */
	SKIVASTFailedAdDisplayTimeoutErrorCode = 304, /* InLine response returned ad unit that failed to result in ad display within defined time limit. */
	
	SKIVASTGeneralLinearErrorCode = 400, /* General Linear error. Video player is unable to display the Linear Ad. */
	SKIVASTMediaFileNotFoundErrorCode = 401, /* File not found. Unable to find Linear/MediaFile from URI. */
	SKIVASTMediaFileTimeoutErrorCode = 402, /* Timeout of MediaFile URI. */
	SKIVASTMediaFileNotSupportedErrorCode = 403, /* Couldn’t find MediaFile that is supported by this video player, based on the attributes of the MediaFile element. */
	SKIVASTMediaFileDisplayErrorCode = 405, /* Problem displaying MediaFile. Video player found a MediaFile with supported type but couldn’t display it. MediaFile may include: unsupported codecs, different MIME type than MediaFile@type, unsupported delivery method, etc. */
	
	SKIVASTMezzanineNotProvidedErrorCode = 406, /* Mezzanine was required but not provided. Ad not served. */
	SKIVASTMezzanineDownloadingErrorCode = 407, /* Mezzanine is in the process of being downloaded for the first time. Download may take several hours. Ad will not be served until mezzanine is downloaded and transcoded. */
	SKIVASTConditionalAdRejectedErrorCode = 408, /* Conditional ad rejected. */
	SKIVASTInteractiveNotExecutedErrorCode = 409, /* Interactive unit in the InteractiveCreativeFile node was not executed. */
	SKIVASTVerificationNotExecutedErrorCode = 410, /* Verification unit in the Verification node was not executed. */
	SKIVASTMezzanineSpecErrorCode = 411, /* Mezzanine was provided as required, but file did not meet required specification. Ad not served. */
	
	SKIVASTGeneralNonLinearErrorCode = 500, /* General NonLinearAds error. */
	SKIVASTNonLinearBadSizeErrorCode = 501, /* Unable to display NonLinear Ad because creative dimensions do not align with creative display area (i.e. creative dimension too large). */
	SKIVASTNonLinearFetchErrorCode = 502, /* Unable to fetch NonLinearAds/NonLinear resource. */
	SKIVASTNonLinearUnsupportedErrorCode = 503, /* Couldn’t find NonLinear resource with supported type. */
	
	SKIVASTGeneralCompanionErrorCode = 600, /* General CompanionAds error. */
	SKIVASTCompanionBadSizeErrorCode = 601, /* Unable to display Companion because creative dimensions do not fit within Companion display area (i.e., no available space). */
	SKIVASTCompanionDisplayErrorCode = 602, /* Unable to display required Companion. */
	SKIVASTCompanionFetchErrorCode = 603, /* Unable to fetch CompanionAds/Companion resource. */
	SKIVASTCompanionUnsupportedErrorCode = 604, /* Couldn’t find Companion resource with supported type. */
	
	SKIVASTUndefinedErrorCode = 900, /* Undefined Error. */
	SKIVASTGeneralVPAIDErrorCode = 901, /* General VPAID error. */
};

#import "SKIVASTAd.h"
#import "SKIVASTAdDefinitionBase.h"
#import "SKIVASTAdParameters.h"
#import "SKIVASTAdSystem.h"
#import "SKIVASTAdVerificationsInline.h"
#import "SKIVASTAdVerificationsWrapper.h"
#import "SKIVASTCategory.h"
#import "SKIVASTClickThrough.h"
#import "SKIVASTClickTracking.h"
#import "SKIVASTCompanionAd.h"
#import "SKIVASTCompanionAdsCollection.h"
#import "SKIVASTCompanionClickTracking.h"
#import "SKIVASTCreativeBase.h"
#import "SKIVASTCreativeExtension.h"
#import "SKIVASTCreativeExtensions.h"
#import "SKIVASTCreativeInlineChild.h"
#import "SKIVASTCreativeResourceNonVideo.h"
#import "SKIVASTCreatives.h"
#import "SKIVASTCreativeWrapperChild.h"
#import "SKIVASTCustomClick.h"
#import "SKIVASTExtension.h"
#import "SKIVASTExtensions.h"
#import "SKIVASTFlashResource.h"
#import "SKIVASTHTMLResource.h"
#import "SKIVASTIcon.h"
#import "SKIVASTIconClicks.h"
#import "SKIVASTIcons.h"
#import "SKIVASTIconTrackingUri.h"
#import "SKIVASTImpression.h"
#import "SKIVASTInline.h"
#import "SKIVASTInteractiveCreativeFile.h"
#import "SKIVASTJavaScriptResource.h"
#import "SKIVASTLinearBase.h"
#import "SKIVASTLinearInlineChild.h"
#import "SKIVASTLinearWrapperChild.h"
#import "SKIVASTMediaFile.h"
#import "SKIVASTMediaFiles.h"
#import "SKIVASTNonLinearAdBase.h"
#import "SKIVASTNonLinearAdInlineChild.h"
#import "SKIVASTNonLinearAds.h"
#import "SKIVASTNonLinearClickTracking.h"
#import "SKIVASTPricing.h"
#import "SKIVASTStaticResource.h"
#import "SKIVASTSurvey.h"
#import "SKIVASTTracking.h"
#import "SKIVASTTrackingEvents.h"
#import "SKIVASTUniversalAdId.h"
#import "SKIVASTVAST+File.h"
#import "SKIVASTVAST.h"
#import "SKIVASTVerificationInline.h"
#import "SKIVASTVerificationWrapper.h"
#import "SKIVASTVideoClicksBase.h"
#import "SKIVASTVideoClicksInlineChild.h"
#import "SKIVASTViewableImpression.h"
#import "SKIVASTWrapper.h"
#import "SKIVASTWrapper+Vast.h"
