package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.support.annotation.UiThread;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.view.Surface;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.mobiblocks.skippables.vast.VastError;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.Closeable;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Constructor;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

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
                for (String val : qValues) {
                    String macros = null;
                    if (val.length() > 2) {
                        if (val.startsWith("[") && val.endsWith("]")) {
                            macros = val.substring(1, val.length() - 1);
                        } else if (val.startsWith("{") && val.endsWith("}")) {
                            macros = val.substring(1, val.length() - 1);
                        } else if (val.length() > 4) {
                            if (val.startsWith("%%") && val.endsWith("%%")) {
                                macros = val.substring(2, val.length() - 3);
                            }
                        }
                    }

                    if (macros == null) {
                        nvps.add(NVP.p(qName, val));
                    } else {
                        if (macros.equalsIgnoreCase("ERRORCODE")) {
                            nvps.add(NVP.p(qName, errorCode == VAST_NO_ERROR_CODE ? "" : String.valueOf(errorCode)));
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
            for (NVP nvp : nvps) {
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

    static String uuid = UUID.randomUUID().toString();
    static String session = null;
    static String getCurrentSession() {
        if (session == null) {
            session = MAYBE_MD5(uuid);
        }
        
        return session;
    }
    
    private static String MAYBE_MD5(String md5) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            byte[] array = md.digest(md5.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte anArray : array) {
                sb.append(Integer.toHexString((anArray & 0xFF) | 0x100).substring(1, 3));
            }
            return sb.toString();
        } catch (java.security.NoSuchAlgorithmException ignored) {
        } catch (java.io.UnsupportedEncodingException ignored) {

        }
        return md5;
    }

    static String getAAID(Context context) {
        try {
            AdvertisingIdClient.Info adInfo = AdvertisingIdClient.getAdvertisingIdInfo(context);
            if (adInfo != null) {
                return adInfo.getId();
            }
        } catch (IOException | GooglePlayServicesRepairableException | GooglePlayServicesNotAvailableException | NoClassDefFoundError ignore) {
            // Error handling if needed
            if (ignore != null) {

            }
        }

        return "00000000-0000-0000-0000-000000000000";
    }

    public static int getScreenOrientation(Activity activity) {
        int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
        int orientation = activity.getResources().getConfiguration().orientation;
        if (orientation == Configuration.ORIENTATION_PORTRAIT) {
            if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_270) {
                return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
            } else {
                return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
            }
        }
        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
                return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
            } else {
                return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
            }
        }

        return ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED;
    }

    private static final AtomicInteger sNextGeneratedId = new AtomicInteger(1);

    /**
     * Generate a value suitable for use in {@link #View.setId(int)}.
     * This value will not collide with ID values generated at build time by aapt for R.id.
     *
     * @return a generated ID value
     */
    private static int _generateViewId() {
        for (; ; ) {
            final int result = sNextGeneratedId.get();
            // aapt-generated IDs have the high byte nonzero; clamp to the range under that.
            int newValue = result + 1;
            if (newValue > 0x00FFFFFF) newValue = 1; // Roll over to 1, not 0.
            if (sNextGeneratedId.compareAndSet(result, newValue)) {
                return result;
            }
        }
    }

    public static int generateViewId() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            return View.generateViewId();
        } else {
            return _generateViewId();
        }
    }

    @UiThread
    public static String getDefaultUserAgentString(final Context context) {
        if (Build.VERSION.SDK_INT >= 17) {
            return NewApiWrapper.getDefaultUserAgent(context);
        }

        try {
            Constructor<WebSettings> constructor = WebSettings.class.getDeclaredConstructor(Context.class, WebView.class);
            constructor.setAccessible(true);
            try {
                WebSettings settings = constructor.newInstance(context, null);
                return settings.getUserAgentString();
            } finally {
                constructor.setAccessible(false);
            }
        } catch (Exception e) {
            if (Looper.myLooper() == Looper.getMainLooper()) {
                return new WebView(context).getSettings().getUserAgentString();
            } else {
                final StringBuilder uadBuilder = new StringBuilder();
                final Handler handler = new Handler(Looper.getMainLooper());
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        synchronized (handler) {
                            uadBuilder.append(new WebView(context).getSettings().getUserAgentString());
                            handler.notifyAll();
                        }
                    }
                });
                try {
                    synchronized (handler) {
                        handler.wait(2000);
                    }

                    String ua = uadBuilder.toString();
                    return ua.length() > 0 ? ua : null;
                } catch (InterruptedException e1) {
                    return null;
                }
            }
        }
    }

    @TargetApi(17)
    private static class NewApiWrapper {
        static String getDefaultUserAgent(Context context) {
            return WebSettings.getDefaultUserAgent(context);
        }
    }

    private static int rtbDeviceType = -1;

    public static int getRTBDeviceType(Context context) {
        if (rtbDeviceType == -1) {
            TelephonyManager manager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
            if (manager != null) {
                if (manager.getPhoneType() == TelephonyManager.PHONE_TYPE_NONE) {
                    rtbDeviceType = 5;
                } else {
                    DisplayMetrics metrics = context.getResources().getDisplayMetrics();

                    float yInches = metrics.heightPixels / metrics.ydpi;
                    float xInches = metrics.widthPixels / metrics.xdpi;
                    double diagonalInches = Math.sqrt(xInches * xInches + yInches * yInches);
                    if (diagonalInches >= 6.5) {
                        rtbDeviceType = 1;
                    } else {
                        rtbDeviceType = 4;
                    }
                }
            }

            rtbDeviceType = 6;
        }

        return rtbDeviceType;
    }

    private static SkiSize screenSize;
    public static SkiSize getScreenSize(Context context) {
        if (screenSize == null) {
            DisplayMetrics metrics = context.getResources().getDisplayMetrics();
            int orientation = context.getResources().getConfiguration().orientation;
            if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
                //noinspection SuspiciousNameCombination
                screenSize = new SkiSize(metrics.heightPixels, metrics.widthPixels);
            } else {
                screenSize = new SkiSize(metrics.widthPixels, metrics.heightPixels);
            }

        }
        return screenSize;
    }

    static <K, V> HashMap<K, V> hm(K k, V v) {
        HashMap<K, V> hm = new HashMap<>();
        hm.put(k, v);
        return hm;
    }

    static <K, V> HashMap<K, V> hm(K k1, V v1, K k2, V v2) {
        HashMap<K, V> hm = new HashMap<>();
        hm.put(k1, v1);
        hm.put(k2, v2);
        return hm;
    }

    static <K, V> HashMap<K, V> hm(K k1, V v1, K k2, V v2, K k3, V v3) {
        HashMap<K, V> hm = new HashMap<>();
        hm.put(k1, v1);
        hm.put(k2, v2);
        hm.put(k3, v3);
        return hm;
    }

    static <K, V> HashMap<K, V> hm(K k1, V v1, K k2, V v2, K k3, V v3, K k4, V v4) {
        HashMap<K, V> hm = new HashMap<>();
        hm.put(k1, v1);
        hm.put(k2, v2);
        hm.put(k3, v3);
        hm.put(k4, v4);
        return hm;
    }

    static <K, V> HashMap<K, V> hm(K k1, V v1, K k2, V v2, K k3, V v3, K k4, V v4, K k5, V v5) {
        HashMap<K, V> hm = new HashMap<>();
        hm.put(k1, v1);
        hm.put(k2, v2);
        hm.put(k3, v3);
        hm.put(k4, v4);
        hm.put(k5, v5);
        return hm;
    }
    
    static JSONObject jsonObjectWrap(Map map) {
        JSONObject jsonObject = new JSONObject();
        try {
            for (Map.Entry<?, ?> entry : ((Map<?, ?>) map).entrySet()) {
                if (entry.getKey() == null || !(entry.getKey() instanceof String)) {
                    continue;
                }

                jsonObject.putOpt((String) entry.getKey(), jsonWrap(entry.getValue()));
            }
        } catch (Exception ignore) {}
        return jsonObject;
    }

    static Object jsonWrap(Object o) {
        if (o == null) {
            return null;
        }
        if (o instanceof JSONArray || o instanceof JSONObject) {
            return o;
        }
        try {
            if (o instanceof Collection) {
                JSONArray array = new JSONArray();
                for (Object o1 : ((Collection) o)) {
                    array.put(jsonWrap(o1));
                }
                return array;
            }
            if (o instanceof Map) {
                JSONObject jsonObject = new JSONObject();
                for (Map.Entry<?, ?> entry: ((Map<?, ?>) o).entrySet()) {
                    if (entry.getKey() == null || !(entry.getKey() instanceof String)) {
                        continue;
                    }

                    jsonObject.putOpt((String) entry.getKey(), jsonWrap(entry.getValue()));
                }
                return jsonObject;
            }
            if (o instanceof Boolean ||
                    o instanceof Byte ||
                    o instanceof Character ||
                    o instanceof Double ||
                    o instanceof Float ||
                    o instanceof Integer ||
                    o instanceof Long ||
                    o instanceof Short ||
                    o instanceof String) {
                return o;
            }
            if (o.getClass().getPackage().getName().startsWith("java.")) {
                return o.toString();
            }
        } catch (Exception ignored) {
            android.util.Log.d("sdf", "sdf");
        }
        return null;
    }

    static String readAnyResponse(HttpURLConnection uc) throws IOException {
        final int statusCode = uc.getResponseCode();
        BufferedReader buff = null;
        try {
            InputStream inStream = statusCode == 200 ? uc.getInputStream() : uc.getErrorStream();
            InputStream it = new BufferedInputStream(inStream);
            InputStreamReader read = new InputStreamReader(it);
            buff = new BufferedReader(read);
            StringBuilder dta = new StringBuilder();
            String chunks;
            while ((chunks = buff.readLine()) != null) {
                dta.append(chunks);
            }
            return dta.toString();
        } finally {
            close(buff);
        }
    }

    static String tryReadAnyResponse(HttpURLConnection uc) {
        try {
            return readAnyResponse(uc);
        } catch (Exception ignored) { }
        
        return null;
    }
    
    static void close(Closeable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (IOException ignore) { }
        }
    }
}
