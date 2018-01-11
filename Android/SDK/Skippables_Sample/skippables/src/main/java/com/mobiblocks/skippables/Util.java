package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.Uri;
import android.provider.Settings;

import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.mobiblocks.skippables.vast.VastError;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Random;
import java.util.Set;

import static com.mobiblocks.skippables.vast.VastError.VAST_NO_ERROR_CODE;

/**
 * Created by daniel on 12/21/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class Util {
    static class VastUrlMacros {
        private static class NVP {
            private final String name;
            private final String value;

            NVP(String name, String value) {
                this.name = name;
                this.value = value;
            }

            static NVP p(String name, String value) {
                return new NVP(name, value);
            }

        }

        private VastUrlMacros() {
        }

        @VastError.AdVastError
        private int errorCode = VAST_NO_ERROR_CODE;
        private int contentPlayAhead = -1;
        private URL assetUrl;

        static VastUrlMacros builder() {
            return new VastUrlMacros();
        }

        VastUrlMacros setErrorCode(@VastError.AdVastError int errorCode) {
            this.errorCode = errorCode;

            return this;
        }

        VastUrlMacros setContentPlayAhead(int contentPlayAhead) {
            this.contentPlayAhead = contentPlayAhead;

            return this;
        }

        VastUrlMacros setAssetUrl(URL assetUrl) {
            this.assetUrl = assetUrl;

            return this;
        }

        private static SimpleDateFormat timestampFormatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);

        private static String formattedTimeStamp() {
            return timestampFormatter.format(new Date());
        }

        URL build(URL url) {
            Uri uri = Uri.parse(url.toString());
            Set<String> queryParameterNames = uri.getQueryParameterNames();

            ArrayList<NVP> nvps = new ArrayList<>();

            for (String qName :
                    queryParameterNames) {
                List<String> qValues = uri.getQueryParameters(qName);
                for (String val :
                        qValues) {
                    String macros = null;
                    if (val.length() > 2) {
                        if (val.startsWith("[") && val.endsWith("]")) {
                            macros = val.substring(1, val.length() - 1);
                        } else if (val.startsWith("{") && val.endsWith("}")) {
                            macros = val.substring(1, val.length() - 1);
                        }
                    } else if (val.length() > 4) {
                        if (val.startsWith("%%") && val.endsWith("%%")) {
                            macros = val.substring(2, val.length() - 3);
                        }
                    }

                    if (macros == null) {
                        nvps.add(NVP.p(qName, val));
                    } else {
                        if (macros.equalsIgnoreCase("ERRORCODE")) {
                            nvps.add(NVP.p(qName, errorCode == VAST_NO_ERROR_CODE ? String.valueOf(errorCode) : ""));
                        } else if (macros.equalsIgnoreCase("CONTENTPLAYHEAD")) {
                            if (contentPlayAhead > -1) {
                                int hours = contentPlayAhead / 3600;
                                int minutes = (contentPlayAhead % 3600) / 60;
                                int seconds = contentPlayAhead % 60;
                                String formatted = String.format(Locale.US, "%02d:%02d:%02d",
                                        hours,
                                        minutes,
                                        seconds);
                                nvps.add(NVP.p(qName, formatted));
                            } else {
                                nvps.add(NVP.p(qName, ""));
                            }
                        } else if (macros.equalsIgnoreCase("CACHEBUSTING") || macros.equalsIgnoreCase("RANDOM")) {
                            Random r = new Random();
                            int random = r.nextInt(89999999 - 10000000) + 10000000;
                            nvps.add(NVP.p(qName, String.valueOf(random)));
                        } else if (macros.equalsIgnoreCase("ASSETURI")) {
                            nvps.add(NVP.p(qName, assetUrl == null ? "" : assetUrl.toString()));
                        } else if (macros.equalsIgnoreCase("TIMESTAMP")) {
                            nvps.add(NVP.p(qName, formattedTimeStamp()));
                        } else {
                            nvps.add(NVP.p(qName, val));
                        }
                    }
                }
            }

            Uri.Builder builder = uri.buildUpon();
            builder.clearQuery();
            for (NVP nvp :
                    nvps) {
                builder.appendQueryParameter(nvp.name, nvp.value);
            }
            try {
                return new URL(builder.toString());
            } catch (MalformedURLException ignore) {
                return url;
            }
        }
    }

    private static File getDocumentsFileDir(Context context) {
        return context.getDir("skipp", Context.MODE_PRIVATE);
    }

    static File getInstallFilePath(Context context) {
        return new File(getDocumentsFileDir(context), "install");
    }

    static File getEventsFilePath(Context context) {
        return new File(getDocumentsFileDir(context), "skie");
    }

    static String getAAID(Context context) {
        try {
            AdvertisingIdClient.Info adInfo = AdvertisingIdClient.getAdvertisingIdInfo(context);
            if (adInfo != null) {
                return adInfo.getId();
            }
        } catch (IOException | GooglePlayServicesRepairableException | GooglePlayServicesNotAvailableException | NoClassDefFoundError ignore) {
            // Error handling if needed
        }

        @SuppressLint("HardwareIds") String androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        if (androidId != null) {
            return androidId;
        }

        return "00000000-0000-0000-0000-000000000000";
    }
}
