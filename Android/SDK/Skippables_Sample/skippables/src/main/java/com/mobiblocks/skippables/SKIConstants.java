package com.mobiblocks.skippables;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

final class SKIConstants {
    static final String UNIT_ID_KEY = SkiConf.UNIT_ID_KEY;
//    private static final String API_BANNER_URL = "http://10.0.0.50/tek/banner";
//    private static final String API_VIDEO_URL = "http://10.0.0.50/tek/video";
//    private static final String INSTALL_URL = "http://10.0.0.50/tek/install";
    private static final String API_BANNER_URL = "https://www.skippables.com/ad/AdServer/GetBanner";
    private static final String API_VIDEO_URL = "https://www.skippables.com/ad/AdServer/GetVideo";
    private static final String INSTALL_URL = "https://www.skippables.com/ad/InstallServer/Track";

    static String GetApiUrl(@SkiAdRequest.AdType int adType) {
        switch (adType) {
            case SkiAdRequest.AD_TYPE_BANNER_IMAGE:
            case SkiAdRequest.AD_TYPE_BANNER_RICH_MEDIA:
            case SkiAdRequest.AD_TYPE_BANNER_TEXT:
                return API_BANNER_URL;
            case SkiAdRequest.AD_TYPE_INTERSTITIAL_VIDEO:
                return API_VIDEO_URL;
            case SkiAdRequest.AD_TYPE_INTERSTITIAL:
            default:
                throw new Error("Not implemented");
        }
    }

    static String GetInstallUrl() {
        return INSTALL_URL;
    }
}
