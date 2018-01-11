package com.mobiblocks.skippables.vast;

import android.support.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by daniel on 1/2/18.
 * <p>
 * Copyright Mobiblocks 2018. All rights reserved.
 */

public final class VastError {

    /* No error. */
    public static final int VAST_NO_ERROR_CODE = 0;

    /* XML parsing error. */
    public static final int VAST_XMLPARSE_ERROR_CODE = 100;
    /* VAST schema validation error. */
    public static final int VAST_SCHEMA_VALIDATION_ERROR_CODE = 101;
    /* VAST version of response not supported. */
    public static final int VAST_UNSUPPORTED_VERSION_ERROR_CODE = 102;
    /* Trafficking error. Video player received an Ad type that it was not expecting and/or cannot display. */
    public static final int VAST_TRAFFICKING_ERROR_CODE = 200;

    /* Video player expecting different linearity. */
    public static final int VAST_BAD_VIDEO_LINEARITY_ERROR_CODE = 201;
    /* Video player expecting different duration. */
    public static final int VAST_BAD_VIDEO_DURATION_ERROR_CODE = 202;
    /* Video player expecting different size. */
    public static final int VAST_BAD_VIDEO_SIZE_ERROR_CODE = 203;
    /* Ad category was required but not provided. */
    public static final int VAST_MISSING_AD_CATEGORY_ERROR_CODE = 204;

    /* General Wrapper error. */
    public static final int VAST_GENERAL_WRAPPER_ERROR_CODE = 300;
    /* Timeout of VAST URI provided in Wrapper element, or of VAST URI provided in a subsequent Wrapper element. (URI was either unavailable or reached a timeout as defined by the video player.) */
    public static final int VAST_WRAPPER_TIMEOUT_ERROR_CODE = 301;
    /* Wrapper limit reached, as defined by the video player. Too many Wrapper responses have been received with no InLine response. */
    public static final int VAST_WRAPPER_LIMIT_ERROR_CODE = 302;
    /* No VAST response after one or more Wrappers. */
    public static final int VAST_WRAPPER_NO_VAST_ERROR_CODE = 303;
    /* InLine response returned ad unit that failed to result in ad display within defined time limit. */
    public static final int VAST_FAILED_AD_DISPLAY_TIMEOUT_ERROR_CODE = 304;

    /* General Linear error. Video player is unable to display the Linear Ad. */
    public static final int VAST_GENERAL_LINEAR_ERROR_CODE = 400;
    /* File not found. Unable to find Linear/MediaFile from URI. */
    public static final int VAST_MEDIA_FILE_NOT_FOUND_ERROR_CODE = 401;
    /* Timeout of MediaFile URI. */
    public static final int VAST_MEDIA_FILE_TIMEOUT_ERROR_CODE = 402;
    /* Couldn’t find MediaFile that is supported by this video player, based on the attributes of the MediaFile element. */
    public static final int VAST_MEDIA_FILE_NOT_SUPPORTED_ERROR_CODE = 403;
    /* Problem displaying MediaFile. Video player found a MediaFile with supported type but couldn’t display it. MediaFile may include: unsupported codecs, different MIME type than MediaFile@type, unsupported delivery method, etc. */
    public static final int VAST_MEDIA_FILE_DISPLAY_ERROR_CODE = 405;

    /* Mezzanine was required but not provided. Ad not served. */
    public static final int VAST_MEZZANINE_NOT_PROVIDED_ERROR_CODE = 406;
    /* Mezzanine is in the process of being downloaded for the first time. Download may take several hours. Ad will not be served until mezzanine is downloaded and transcoded. */
    public static final int VAST_MEZZANINE_DOWNLOADING_ERROR_CODE = 407;
    /* Conditional ad rejected. */
    public static final int VAST_CONDITIONAL_AD_REJECTED_ERROR_CODE = 408;
    /* Interactive unit in the InteractiveCreativeFile node was not executed. */
    public static final int VAST_INTERACTIVE_NOT_EXECUTED_ERROR_CODE = 409;
    /* Verification unit in the Verification node was not executed. */
    public static final int VAST_VERIFICATION_NOT_EXECUTED_ERROR_CODE = 410;
    /* Mezzanine was provided as required, but file did not meet required specification. Ad not served. */
    public static final int VAST_MEZZANINE_SPEC_ERROR_CODE = 411;

    /* General NonLinearAds error. */
    public static final int VAST_GENERAL_NON_LINEAR_ERROR_CODE = 500;
    /* Unable to display NonLinear Ad because creative dimensions do not align with creative display area (i.e. creative dimension too large). */
    public static final int VAST_NON_LINEAR_BAD_SIZE_ERROR_CODE = 501;
    /* Unable to fetch NonLinearAds/NonLinear resource. */
    public static final int VAST_NON_LINEAR_FETCH_ERROR_CODE = 502;
    /* Couldn’t find NonLinear resource with supported type. */
    public static final int VAST_NON_LINEAR_UNSUPPORTED_ERROR_CODE = 503;

    /* General CompanionAds error. */
    public static final int VAST_GENERAL_COMPANION_ERROR_CODE = 600;
    /* Unable to display Companion because creative dimensions do not fit within Companion display area (i.e., no available space). */
    public static final int VAST_COMPANION_BAD_SIZE_ERROR_CODE = 601;
    /* Unable to display required Companion. */
    public static final int VAST_COMPANION_DISPLAY_ERROR_CODE = 602;
    /* Unable to fetch CompanionAds/Companion resource. */
    public static final int VAST_COMPANION_FETCH_ERROR_CODE = 603;
    /* Couldn’t find Companion resource with supported type. */
    public static final int VAST_COMPANION_UNSUPPORTED_ERROR_CODE = 604;

    /* Undefined Error. */
    public static final int VAST_UNDEFINED_ERROR_CODE = 900;
    /* General VPAID error. */
    public static final int VAST_GENERAL_VPAIDERROR_CODE = 901;

    @IntDef({VAST_NO_ERROR_CODE,
            VAST_XMLPARSE_ERROR_CODE,
            VAST_SCHEMA_VALIDATION_ERROR_CODE,
            VAST_UNSUPPORTED_VERSION_ERROR_CODE,
            VAST_TRAFFICKING_ERROR_CODE,
            VAST_BAD_VIDEO_LINEARITY_ERROR_CODE,
            VAST_BAD_VIDEO_DURATION_ERROR_CODE,
            VAST_BAD_VIDEO_SIZE_ERROR_CODE,
            VAST_MISSING_AD_CATEGORY_ERROR_CODE,
            VAST_GENERAL_WRAPPER_ERROR_CODE,
            VAST_WRAPPER_TIMEOUT_ERROR_CODE,
            VAST_WRAPPER_LIMIT_ERROR_CODE,
            VAST_WRAPPER_NO_VAST_ERROR_CODE,
            VAST_FAILED_AD_DISPLAY_TIMEOUT_ERROR_CODE,
            VAST_GENERAL_LINEAR_ERROR_CODE,
            VAST_MEDIA_FILE_NOT_FOUND_ERROR_CODE,
            VAST_MEDIA_FILE_TIMEOUT_ERROR_CODE,
            VAST_MEDIA_FILE_NOT_SUPPORTED_ERROR_CODE,
            VAST_MEDIA_FILE_DISPLAY_ERROR_CODE,
            VAST_MEZZANINE_NOT_PROVIDED_ERROR_CODE,
            VAST_MEZZANINE_DOWNLOADING_ERROR_CODE,
            VAST_CONDITIONAL_AD_REJECTED_ERROR_CODE,
            VAST_INTERACTIVE_NOT_EXECUTED_ERROR_CODE,
            VAST_VERIFICATION_NOT_EXECUTED_ERROR_CODE,
            VAST_MEZZANINE_SPEC_ERROR_CODE,
            VAST_GENERAL_NON_LINEAR_ERROR_CODE,
            VAST_NON_LINEAR_BAD_SIZE_ERROR_CODE,
            VAST_NON_LINEAR_FETCH_ERROR_CODE,
            VAST_NON_LINEAR_UNSUPPORTED_ERROR_CODE,
            VAST_GENERAL_COMPANION_ERROR_CODE,
            VAST_COMPANION_BAD_SIZE_ERROR_CODE,
            VAST_COMPANION_DISPLAY_ERROR_CODE,
            VAST_COMPANION_FETCH_ERROR_CODE,
            VAST_COMPANION_UNSUPPORTED_ERROR_CODE,
            VAST_UNDEFINED_ERROR_CODE,
            VAST_GENERAL_VPAIDERROR_CODE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface AdVastError {
    }
}
