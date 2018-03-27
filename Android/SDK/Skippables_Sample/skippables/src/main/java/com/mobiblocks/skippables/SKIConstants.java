package com.mobiblocks.skippables;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

final class SKIConstants {
    static final String UNIT_ID_KEY = SkiConf.UNIT_ID_KEY;
//    private static final String BASE_URL = "http://test.skippables.com";
//    private static final String BASE_URL = "http://10.0.0.35";
    private static final String BASE_URL = "https://www.skippables.com";
    
    private static final String API_BANNER_URL = BASE_URL + "/x/srv/GetImage";
    private static final String API_VIDEO_URL = BASE_URL + "/x/srv/GetVideo";
    private static final String INSTALL_URL = BASE_URL + "/x/InstallServer/Track";
    private static final String INFRINGEMENT_REPORT_URL = BASE_URL + "/x/api/Feedback/InfringementReport";

    static String GetAdApiUrl(@SkiAdRequest.AdType int adType) {
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

    static String GetInfringementReportUrl() {
        return INFRINGEMENT_REPORT_URL;
    }
}
