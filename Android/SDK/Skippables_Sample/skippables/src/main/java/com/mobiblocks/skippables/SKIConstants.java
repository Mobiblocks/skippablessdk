package com.mobiblocks.skippables;

import android.net.Uri;
import android.support.annotation.NonNull;

import java.net.MalformedURLException;
import java.net.URL;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

final class SKIConstants {
    //    private static final String BASE_URL = "http://test.skippables.com";
//    private static final String BASE_URL = "http://10.0.0.35";
    private static final String BASE_URL = "https://www.skippables.com";

    private static final String API_BANNER_URL = BASE_URL + "/x/srv/GetImage";
    private static final String API_VIDEO_URL = BASE_URL + "/x/srv/GetVideo";
    private static final String API_INTERSTITIAL_URL = BASE_URL + "/x/srv/GetInterstitial";
    private static final String INSTALL_URL = BASE_URL + "/x/InstallServer/Track";
    private static final String INFRINGEMENT_REPORT_URL = BASE_URL + "/x/api/Feedback/InfringementReport";

    private static final String ERROR_REPORT_URL = BASE_URL + "/x/error";
    private static final String SDK_ERROR_REPORT_URL = BASE_URL + "/x/error/sdk";
    private static final String SDK_EVENT_REPORT_URL = BASE_URL + "/x/log/sdk/event";

    static String GetAdApiUrl(@SkiAdRequest.AdType int adType) {
        switch (adType) {
            case SkiAdRequest.AD_TYPE_BANNER_IMAGE:
            case SkiAdRequest.AD_TYPE_BANNER_RICH_MEDIA:
            case SkiAdRequest.AD_TYPE_BANNER_TEXT:
                return API_BANNER_URL;
            case SkiAdRequest.AD_TYPE_INTERSTITIAL:
                return API_INTERSTITIAL_URL;
            case SkiAdRequest.AD_TYPE_INTERSTITIAL_VIDEO:
                return API_VIDEO_URL;
            default:
                throw new Error("Not implemented");
        }
    }

    @NonNull static URL GetErrorReportURL(String sessionID) {
        if (sessionID == null) {
            try {
                return new URL(ERROR_REPORT_URL);
            } catch (MalformedURLException e) {
                // impossible
            }
        }

        try {
            Uri uri = Uri.parse(SDK_ERROR_REPORT_URL);
            Uri.Builder builder = uri.buildUpon();
            builder.appendQueryParameter("sessionID", sessionID);

            return new URL(builder.toString());
        } catch (MalformedURLException e) {
            // impossible
        }

        //noinspection ConstantConditions
        return null;
    }

    @NonNull static URL GetEventReportURL() {
        try {
            return new URL(SDK_EVENT_REPORT_URL);
        } catch (MalformedURLException e) {
            // impossible
        }

        //noinspection ConstantConditions
        return null;
    }

    static String GetInstallUrl() {
        return INSTALL_URL;
    }

    static String GetInfringementReportUrl() {
        return INFRINGEMENT_REPORT_URL;
    }
}
