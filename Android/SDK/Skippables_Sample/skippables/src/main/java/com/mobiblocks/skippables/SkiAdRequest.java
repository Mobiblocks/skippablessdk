package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.Settings;
import android.support.annotation.IntDef;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.telephony.TelephonyManager;

import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.ArrayList;
import java.util.TimeZone;
import java.util.UUID;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

public class SkiAdRequest {
    static final int AD_TYPE_BANNER_TEXT = 0;
    static final int AD_TYPE_BANNER_IMAGE = 1;
    static final int AD_TYPE_BANNER_RICH_MEDIA = 2;
    static final int AD_TYPE_INTERSTITIAL = 3;
    static final int AD_TYPE_INTERSTITIAL_VIDEO = 4;

    @SuppressWarnings("WeakerAccess")
    public static final int GENDER_UNKNOWN = 0;
    @SuppressWarnings("WeakerAccess")
    public static final int GENDER_MALE = 1;
    @SuppressWarnings("WeakerAccess")
    public static final int GENDER_FEMALE = 2;
    @SuppressWarnings("WeakerAccess")
    public static final int GENDER_OTHER = 3;

    @SuppressWarnings("WeakerAccess")
    public static final int ERROR_NO_ERROR = 0;
    /// The ad request is invalid. Typically this is because the ad did not have the ad unit ID or root view
    /// controller set.
    @SuppressWarnings("WeakerAccess")
    public static final int ERROR_INVALID_REQUEST = 1;

    /// The ad request was successful, but no ad was returned.
    @SuppressWarnings("WeakerAccess")
    public static final int ERROR_NO_FILL = 2;

    /// There was an ERROR loading data from the network.
    @SuppressWarnings("WeakerAccess")
    public static final int ERROR_NETWORK_ERROR = 3;

    /// The ad server experienced a failure processing the request.
    @SuppressWarnings("WeakerAccess")
    public static final int ERROR_SERVER_ERROR = 4;

    /// The request was unable to be loaded before being timed out.
    @SuppressWarnings("WeakerAccess")
    public static final int ERROR_TIMEOUT = 6;

    /// Internal ERROR.
    @SuppressWarnings("WeakerAccess")
    public static final int ERROR_INTERNAL_ERROR = 7;

    /// Invalid argument ERROR.
    @SuppressWarnings("WeakerAccess")
    public static final int ERROR_INVALID_ARGUMENT = 8;

    /// Received invalid response.
    @SuppressWarnings("WeakerAccess")
    public static final int ERROR_RECEIVED_INVALID_RESPONSE = 9;
    @NonNull final String uid = UUID.randomUUID().toString();

    private boolean test;
    @Gender
    private int gender = GENDER_UNKNOWN;
    private int yearOfBirth = -1;
    private boolean childDirectedTreatment;
    private Location location;
    @Nullable
    private ArrayList<String> keywordList;

    private SkiAdRequestListener listener;

    private boolean adTypeIsSet;
    @AdType
    private int adType = AD_TYPE_BANNER_TEXT;
    private boolean adSizeIsSet;
    private SkiAdSize adSize = SkiAdSize.BANNER;
    private String adUnitId;

    private SkiAdErrorCollector errorCollector = new SkiAdErrorCollector();
    @NonNull private final ISkiSessionLogger sessionLogger;

    SkiAdRequest(Builder builder) {
        test = builder.mTest;
        gender = builder.mGender;
        yearOfBirth = builder.mYearOfBirth;
        childDirectedTreatment = builder.mChildDirectedTreatment;
        location = builder.mLocation;
        keywordList = builder.mKeywordList;
        sessionLogger = SkiSessionLogger.create().build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "session.start";
            }
        });
    }

    SkiAdRequest(SkiAdRequest request) {
        test = request.test;
        gender = request.gender;
        yearOfBirth = request.yearOfBirth;
        childDirectedTreatment = request.childDirectedTreatment;
        location = request.location;
        keywordList = request.keywordList;
        sessionLogger = SkiSessionLogger.create().build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "session.start";    
            }
        });
    }

    void load(@NonNull final Context context, @NonNull final SkiAdRequestListener listener) {
        this.listener = listener;
        sessionLogger.collectInfo(context).build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adRequest.load";
            }
        });
        new SkiAdRequestTask(this.sessionLogger, this.errorCollector, new SkiAdRequestTask.Listener() {
            @Override
            public JSONObject onGetRequestInfo(SkiAdRequest adRequest) {
                SkiSize screenSize = Util.getScreenSize(context);

                JSONObject requestObject = new JSONObject();
                try {
                    requestObject.put("test", adRequest.test);
                    requestObject.put("adUnitId", adRequest.getAdUnitId());

                    SkiAdSize adSize = adRequest.getAdSize();
                    switch (adRequest.adType) {
                        case SkiAdRequest.AD_TYPE_BANNER_IMAGE: {
                            JSONObject adTypeObject = new JSONObject();
                            adTypeObject.put("type", "img");
                            adTypeObject.put("w", adSize.getWidth());
                            adTypeObject.put("h", adSize.getHeight());
                            requestObject.put("banner", adTypeObject);
                            break;
                        }
                        case SkiAdRequest.AD_TYPE_BANNER_RICH_MEDIA: {
//                            adTypeObject.put("type", "txt");
//                            adTypeObject.put("w", adSize.getWidth());
//                            adTypeObject.put("h", adSize.getHeight());

                            throw new Exception("Invalid ad type.");
//                            break;
                        }
                        case SkiAdRequest.AD_TYPE_BANNER_TEXT: {
//                            adTypeObject.put("type", "richmedia");
//                            adTypeObject.put("w", adSize.getWidth());
//                            adTypeObject.put("h", adSize.getHeight());

                            throw new Exception("Invalid ad type.");
//                            break;
                        }
                        case SkiAdRequest.AD_TYPE_INTERSTITIAL_VIDEO: {
                            JSONObject adTypeObject = new JSONObject();
                            adTypeObject.put("w", screenSize.getWidth());
                            adTypeObject.put("h", screenSize.getHeight());
                            adTypeObject.put("mimes", getMimesArray());
                            adTypeObject.put("protocols", getProtocolsArray());
                            adTypeObject.put("linearity", 1);
                            adTypeObject.put("skip", 1);

                            requestObject.put("video", adTypeObject);
                            break;
                        }
                        case SkiAdRequest.AD_TYPE_INTERSTITIAL: {
                            throw new Exception("Invalid ad type.");
//                            break;
                        }
                    }

                    JSONObject appObject = new JSONObject();

                    PackageManager packageManager = context.getPackageManager();
                    ApplicationInfo applicationInfo = context.getApplicationInfo();
                    CharSequence appName = applicationInfo.loadLabel(packageManager);
                    if (appName != null) {
                        appObject.put("name", appName.toString());
                    }

                    appObject.put("bundle", context.getPackageName());
                    PackageInfo info = packageManager.getPackageInfo(context.getPackageName(), 0);
                    appObject.put("ver", info.versionName);
                    
                    appObject.put("requireSecure", false);
                    
                    requestObject.put("app", appObject);

                    JSONObject deviceObject = new JSONObject();

                    String ua = Util.getDefaultUserAgentString(context);
                    if (ua != null) {
                        deviceObject.put("ua", ua);
                    }

                    deviceObject.put("lmt", isLimitAdTrackingEnabled(context) ? 1 : 0);

                    String manufacturer = Build.MANUFACTURER;
                    if (manufacturer != null) {
                        deviceObject.put("make", manufacturer);
                    }

                    String model = Build.MODEL;
                    if (model != null) {
                        deviceObject.put("model", model);
                    }

                    String product = Build.PRODUCT;
                    if (product != null) {
                        deviceObject.put("hwv", product);
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        deviceObject.put("os", Build.VERSION.BASE_OS == null || Build.VERSION.BASE_OS.isEmpty() ? "Android" : Build.VERSION.BASE_OS);
                    } else {
                        deviceObject.put("os", "Android");
                    }
                    deviceObject.put("osv", Build.VERSION.RELEASE);
                    deviceObject.put("devicetype", Util.getRTBDeviceType(context));
                    deviceObject.put("w", screenSize.getWidth());
                    deviceObject.put("h", screenSize.getHeight());
                    deviceObject.put("pxratio", context.getResources().getDisplayMetrics().density);

                    TelephonyManager telephonyManager = ((TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE));
                    if (telephonyManager != null) {
                        String operatorName = telephonyManager.getNetworkOperatorName();
                        if (operatorName != null && !operatorName.isEmpty()) {
                            deviceObject.put("carrier", operatorName);
                        }
                        String operatorCode = telephonyManager.getNetworkOperator();
                        if (operatorCode != null && !operatorCode.isEmpty()) {
                            deviceObject.put("carriercode", operatorCode);
                        }
                    }

                    int networkType = getNetworkType(context);
                    if (networkType != 0) {
                        deviceObject.put("connectiontype", networkType);
                    }

                    deviceObject.put("session", Util.getCurrentSession());
                    deviceObject.put("ifa", Util.getAAID(context));

                    @SuppressLint("HardwareIds") String androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
                    if (androidId != null) {
                        deviceObject.put("ssaid", androidId);
                    }

                    requestObject.put("device", deviceObject);

                    JSONObject regs = new JSONObject();
                    regs.put("coppa", adRequest.childDirectedTreatment ? 1 : 0);

                    requestObject.put("regs", regs);

                    JSONObject user = new JSONObject();
                    switch (adRequest.gender) {

                        case SkiAdRequest.GENDER_FEMALE:
                            user.put("gender", "F");
                            break;
                        case SkiAdRequest.GENDER_MALE:
                            user.put("gender", "M");
                            break;
                        case SkiAdRequest.GENDER_OTHER:
                            user.put("gender", "O");
                            break;
                        case SkiAdRequest.GENDER_UNKNOWN:
                            break;
                    }

                    if (adRequest.yearOfBirth > 1800) {
                        user.put("yob", adRequest.yearOfBirth);
                    }

                    if (adRequest.keywordList != null && adRequest.keywordList.size() > 0) {
                        StringBuilder sb = new StringBuilder();
                        for (String s : adRequest.keywordList) {
                            sb.append(s);
                            sb.append(",");
                        }
                        user.put("keywords", sb.toString());
                    }

                    if (user.length() > 0) {
                        requestObject.put("user", user);
                    }

                    JSONObject geo = new JSONObject();
                    TimeZone tz = TimeZone.getDefault();
                    int offsetFromUtc = tz.getOffset(System.currentTimeMillis()) / 1000 / 60;
                    geo.put("utcoffset", offsetFromUtc);

                    if (location != null) {
                        String provider = location.getProvider();
                        if (LocationManager.GPS_PROVIDER.equalsIgnoreCase(provider) || 
                            LocationManager.NETWORK_PROVIDER.equalsIgnoreCase(provider) ||
                            LocationManager.PASSIVE_PROVIDER.equalsIgnoreCase(provider) ||
                            "fused".equalsIgnoreCase(provider)) {
                            geo.put("type", 1); //GPS/Location Services
                        } else {
                            geo.put("type", 3); //User provided
                        }
                        geo.put("lat", location.getLatitude());
                        geo.put("lon", location.getLongitude());
                        geo.put("accuracy", location.getAccuracy());
                    }
                    
                    requestObject.put("geo", geo);

                } catch (JSONException e) {
                    return null;
                } catch (Exception e) {
                    return null;
                }

                return requestObject;
            }

            @Override
            public SkiCompactVast.MediaFile onGetBestMediaFile(SkiCompactVast compactVast) {
                return compactVast.getAd().findBestMediaFile(context);
            }

            @Override
            public String onGetTempDirectory() throws IOException {
                File cache = context.getCacheDir();
                File oCache = new File(cache, "skipp");
                if (!oCache.exists() && !oCache.mkdirs()) {
                    throw new IOException("Failed to create cache dir");
                }

                return oCache.getAbsolutePath();
            }

            @Override
            public void onResponse(SkiAdRequestResponse response) {
                SkiAdRequest.this.listener.onResponse(response);
            }
        }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, this);
    }

    private static int getNetworkType(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (cm != null) {
            NetworkInfo networkInfo = cm.getActiveNetworkInfo();
            if (networkInfo != null) {
                int netType = networkInfo.getType();
                if (netType == ConnectivityManager.TYPE_ETHERNET) {
                    return 1;
                } else if (netType == ConnectivityManager.TYPE_WIFI) {
                    return 2;
                } else if (netType == ConnectivityManager.TYPE_MOBILE) {
                    int netSubtype = networkInfo.getSubtype();
                    return getRTBMobileNetworkClass(netSubtype);
                } else {
                    return 0;
                }
            }
        }

        return 0;
    }


    private static int getRTBMobileNetworkClass(int networkType) {
        switch (networkType) {
            case TelephonyManager.NETWORK_TYPE_GPRS:
            case TelephonyManager.NETWORK_TYPE_GSM:
            case TelephonyManager.NETWORK_TYPE_EDGE:
            case TelephonyManager.NETWORK_TYPE_CDMA:
            case TelephonyManager.NETWORK_TYPE_1xRTT:
            case TelephonyManager.NETWORK_TYPE_IDEN:
                return 4;
            case TelephonyManager.NETWORK_TYPE_UMTS:
            case TelephonyManager.NETWORK_TYPE_EVDO_0:
            case TelephonyManager.NETWORK_TYPE_EVDO_A:
            case TelephonyManager.NETWORK_TYPE_HSDPA:
            case TelephonyManager.NETWORK_TYPE_HSUPA:
            case TelephonyManager.NETWORK_TYPE_HSPA:
            case TelephonyManager.NETWORK_TYPE_EVDO_B:
            case TelephonyManager.NETWORK_TYPE_EHRPD:
            case TelephonyManager.NETWORK_TYPE_HSPAP:
            case TelephonyManager.NETWORK_TYPE_TD_SCDMA:
                return 5;
            case TelephonyManager.NETWORK_TYPE_LTE:
            case TelephonyManager.NETWORK_TYPE_IWLAN:
            case 19://TelephonyManager.NETWORK_TYPE_LTE_CA:
                return 6;
            default:
                return 3;
        }
    }

    private static JSONArray protocolsArray;

    private static JSONArray getProtocolsArray() {
        if (protocolsArray == null) {
            protocolsArray = new JSONArray();
            protocolsArray.put(3);
            protocolsArray.put(6);
            protocolsArray.put(7);
        }

        return protocolsArray;
    }

    private static JSONArray mimesArray;

    private static JSONArray getMimesArray() {
        if (mimesArray == null) {
            mimesArray = new JSONArray();
            mimesArray.put("video/mp4");
            mimesArray.put("video/3gpp");
        }

        return mimesArray;
    }

    private static boolean isLimitAdTrackingEnabled(Context context) {
        try {
            AdvertisingIdClient.Info adInfo = AdvertisingIdClient.getAdvertisingIdInfo(context);
            return adInfo != null && adInfo.isLimitAdTrackingEnabled();
        } catch (IOException | GooglePlayServicesRepairableException | GooglePlayServicesNotAvailableException | NoClassDefFoundError ignore) {
            // Error handling if needed
        }
        return false;
    }

    @AdType
    int getAdType() {
        return adType;
    }

    void setAdType(@AdType int adType) {
        if (adTypeIsSet) {
            throw new IllegalArgumentException("You can not reset ad type.");
        }

        adTypeIsSet = true;
        this.adType = adType;
    }

    private SkiAdSize getAdSize() {
        return adSize;
    }

    void setAdSize(SkiAdSize adSize) {
        if (adSizeIsSet) {
            throw new IllegalArgumentException("You can not reset ad size.");
        }

        adSizeIsSet = true;
        this.adSize = adSize;
    }

    boolean isTest() {
        return test;
    }

    @SuppressWarnings("unused")
    public static Builder builder() {
        return new Builder();
    }

     String getAdUnitId() {
        return adUnitId;
    }

    void setAdUnitId(String adUnitId) {
        this.adUnitId = adUnitId;
    }

    @SuppressWarnings("WeakerAccess")
    @IntDef({GENDER_UNKNOWN,
            GENDER_MALE,
            GENDER_FEMALE,
            GENDER_OTHER})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Gender {
    }

    @SuppressWarnings("WeakerAccess")
    @IntDef({AD_TYPE_BANNER_TEXT,
            AD_TYPE_BANNER_IMAGE,
            AD_TYPE_BANNER_RICH_MEDIA,
            AD_TYPE_INTERSTITIAL,
            AD_TYPE_INTERSTITIAL_VIDEO})
    @Retention(RetentionPolicy.SOURCE)
    public @interface AdType {
    }

    @SuppressWarnings("WeakerAccess")
    @IntDef({ERROR_NO_ERROR,
            ERROR_INVALID_REQUEST,
            ERROR_NO_FILL,
            ERROR_NETWORK_ERROR,
            ERROR_SERVER_ERROR,
            ERROR_TIMEOUT,
            ERROR_INTERNAL_ERROR,
            ERROR_INVALID_ARGUMENT,
            ERROR_RECEIVED_INVALID_RESPONSE,})
    @Retention(RetentionPolicy.SOURCE)
    public @interface AdError {
    }

    @SuppressWarnings("unused")
    public static final class Builder {
        private boolean mTest;
        @Gender
        private int mGender = GENDER_UNKNOWN;
        private int mYearOfBirth = -1;
        private boolean mChildDirectedTreatment;
        private Location mLocation;
        private ArrayList<String> mKeywordList;

        public Builder setTest(boolean test) {
            this.mTest = test;

            return this;
        }

        public Builder setGender(@Gender int gender) {
            this.mGender = gender;

            return this;
        }

        public Builder setYearOfBirth(int yearOfBirth) {
            this.mYearOfBirth = yearOfBirth;

            return this;
        }

        public Builder setChildDirectedTreatment(boolean childDirectedTreatment) {
            this.mChildDirectedTreatment = childDirectedTreatment;

            return this;
        }

        public Builder setLocation(Location location) {
            this.mLocation = location;

            return this;
        }

        public void addKeyword(@NonNull String keyword) {
            //noinspection ConstantConditions
            if (keyword == null || keyword.isEmpty()) {
                return;
            }

            if (mKeywordList == null) {
                mKeywordList = new ArrayList<>();
            }

            mKeywordList.add(keyword);
        }

        public SkiAdRequest build() {
            return new SkiAdRequest(this);
        }
    }
}
