package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.telephony.TelephonyManager;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;
import java.util.UUID;

/**
 * Created by daniel on 12/21/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class SkiEventTracker {
    @SuppressWarnings("unused")
    private static final Date NO_EXPIRE = new Date(Long.MAX_VALUE);
    private static SkiEventTracker instance = null;
    private final File eventFile;
    private final File installFile;
    private boolean isConnected;

    private HashMap<UUID, P> events = new HashMap<>();

    private URL installUrl;
    private URL infringementUrl;

    private SkiEventTracker(final Context applicationContext) {
        try {
            installUrl = new URL(SKIConstants.GetInstallUrl());
        } catch (MalformedURLException ignore) {
            //impossible
        }
        try {
            infringementUrl = new URL(SKIConstants.GetInfringementReportUrl());
        } catch (MalformedURLException ignore) {
            //impossible
        }

        installFile = Util.getInstallFilePath(applicationContext);
        eventFile = Util.getEventsFilePath(applicationContext);
        SerialTask.run(new Runnable() {
            @Override
            public void run() {
                loadSavedEvents();
                maybeResendEvents();
            }
        }, new Runnable() {
            @Override
            public void run() {
                maybeRegisterInstall(applicationContext);
            }
        });

        isConnected = isDataConnected(applicationContext);
        applicationContext.registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                boolean currentIsConnected = isDataConnected(context);
                if (!isConnected && currentIsConnected) {
                    SerialTask.run(new Runnable() {
                        @Override
                        public void run() {
                            maybeResendEvents();
                        }
                    });
                }

                isConnected = currentIsConnected;
            }
        }, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
    }

    private boolean isDataConnected(Context context) {
        try {
            ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
            if (cm != null) {
                return cm.getActiveNetworkInfo().isConnected();
            }
        } catch (Exception e) {
            return false;
        }

        return false;
    }

    private void loadSavedEvents() {
        if (eventFile.exists()) {
            FileInputStream fileInputStream = null;
            ObjectInputStream objectInputStream = null;
            try {
                fileInputStream = new FileInputStream(eventFile);
                objectInputStream = new ObjectInputStream(fileInputStream);

                Date date = new Date();
                //noinspection unchecked
                ArrayList<P> eventPairs = (ArrayList<P>) objectInputStream.readObject();
                for (P pair :
                        eventPairs) {
                    Date eventDate = pair.e;
                    if (eventDate.before(date)) {
                        continue;
                    }

                    events.put(UUID.randomUUID(), pair);
                }
            } catch (IOException | ClassNotFoundException ignored) {
                Dl("read: " + ignored);
            } finally {
                if (fileInputStream != null) {
                    try {
                        fileInputStream.close();
                    } catch (IOException ignored) {
                    }
                }
                if (objectInputStream != null) {
                    try {
                        objectInputStream.close();
                    } catch (IOException ignored) {
                    }
                }
            }
        }
    }

    private void savedEvents() {
        FileOutputStream fileOutputStream = null;
        ObjectOutputStream objectOutputStream = null;
        try {
            fileOutputStream = new FileOutputStream(eventFile);
            objectOutputStream = new ObjectOutputStream(fileOutputStream);

            objectOutputStream.writeObject(new ArrayList<>(events.values()));
        } catch (IOException ignored) {
        } finally {
            if (fileOutputStream != null) {
                try {
                    fileOutputStream.close();
                } catch (IOException ignored) {
                }
            }
            if (objectOutputStream != null) {
                try {
                    objectOutputStream.close();
                } catch (IOException ignored) {
                }
            }
        }
    }

    private void removeEvent(UUID uuid) {
        events.remove(uuid);
    }

    private void maybeRegisterInstall(Context applicationContext) {
        if (installFile.exists()) {
            return;
        }

        JSONObject data = new JSONObject();
        try {
            data.put("event_unix", (int)(System.currentTimeMillis() / 1000L));
            
            data.put("aid", applicationContext.getPackageName());
            data.put("ifa", Util.getAAID(applicationContext));
            @SuppressLint("HardwareIds") String androidId = Settings.Secure.getString(applicationContext.getContentResolver(), Settings.Secure.ANDROID_ID);
            if (androidId != null) {
                data.put("ssaid", androidId);
            }
            
            String ua = Util.getDefaultUserAgentString(applicationContext);
            if (ua != null) {
                data.put("ua", ua);
            }
            
            String model = Build.MODEL;
            if (model != null) {
                data.put("model", model);
            }

            String product = Build.PRODUCT;
            if (product != null) {
                data.put("hwv", product);
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                data.put("os", Build.VERSION.BASE_OS == null || Build.VERSION.BASE_OS.isEmpty() ? "Android" : Build.VERSION.BASE_OS);
            } else {
                data.put("os", "Android");
            }
            data.put("osv", Build.VERSION.RELEASE);
            data.put("devicetype", Util.getRTBDeviceType(applicationContext));

            SkiSize screenSize = Util.getScreenSize(applicationContext);
            JSONObject screen = new JSONObject();
            screen.put("w", screenSize.getWidth());
            screen.put("h", screenSize.getHeight());
            screen.put("s", applicationContext.getResources().getDisplayMetrics().density);
            
            data.put("screen", screen);

            TelephonyManager telephonyManager = ((TelephonyManager) applicationContext.getSystemService(Context.TELEPHONY_SERVICE));
            if (telephonyManager != null) {
                String operatorName = telephonyManager.getNetworkOperatorName();
                if (operatorName != null && !operatorName.isEmpty()) {
                    data.put("carrier", operatorName);
                }
                String operatorCode = telephonyManager.getNetworkOperator();
                if (operatorCode != null && !operatorCode.isEmpty()) {
                    data.put("carriercode", operatorCode);
                }
            }

            TimeZone tz = TimeZone.getDefault();
            int offsetFromUtc = tz.getOffset(System.currentTimeMillis()) / 1000 / 60;
            data.put("utcoffset", offsetFromUtc);

            //noinspection ResultOfMethodCallIgnored
            installFile.createNewFile();

            trackEventRequest(installUrl, NO_EXPIRE, data);
        } catch (JSONException | IOException ignored) {
        }
    }

    private void maybeResendEvents() {
        Date current = new Date();
        for (Map.Entry<UUID, P> entry :
                events.entrySet()) {
            UUID uuid = entry.getKey();
            P pair = entry.getValue();
            Date eventDate = pair.e;
            if (eventDate.before(current)) {
                events.remove(uuid);
                continue;
            }

            makeRequestEvent(uuid);
        }
    }

    void trackEventRequest(URL url) {
        trackEventRequest(url, new Date(System.currentTimeMillis() + 86400 * 1000), null);
    }

    @SuppressWarnings("WeakerAccess")
    void trackEventRequest(final URL url, final JSONObject data) {
        trackEventRequest(url, new Date(System.currentTimeMillis() + 86400 * 1000), data);
    }

    private void trackEventRequest(final URL url, final Date expires, final JSONObject data) {
        final UUID uuid = UUID.randomUUID();
        Dl("trackEventRequest: " + url);
        SerialTask.run(new Runnable() {
            @Override
            public void run() {
                events.put(uuid, P.pair(url, expires, data));
                savedEvents();
            }
        }, new Runnable() {
            @Override
            public void run() {
                makeRequestEvent(uuid);
            }
        });
    }

    void trackInfringementReport(InfringementReport report) {
        try {
            trackEventRequest(infringementUrl, report.buildJSON());
        } catch (JSONException e) {
            Dl("report: " + e);
        }
    }

    private void makeRequestEvent(final UUID uuid) {
        P pair = events.get(uuid);
        if (pair == null) {
            return;
        }

        Dl("makeRequestEvent: " + pair.u);
        HttpURLConnection urlConnection = null;
        OutputStreamWriter out = null;
        try {
            JSONObject data = pair.getD();

            urlConnection = (HttpURLConnection) pair.u.openConnection();
            urlConnection.setConnectTimeout(15 * 1000);
            urlConnection.setReadTimeout(15 * 1000);
            urlConnection.setRequestProperty("Connection", "close");
            urlConnection.setDoOutput(true);
            if (data == null) {
                urlConnection.setRequestMethod("GET");
            } else {
                urlConnection.setRequestMethod("POST");
                urlConnection.setRequestProperty("Content-Type", "application/json");
            }
            urlConnection.connect();

            if (data != null) {
                // Write Request to output stream to server.
                out = new OutputStreamWriter(urlConnection.getOutputStream(), "UTF-8");
                out.write(data.toString());
                out.close();
                out = null;
            }

            int statusCode = urlConnection.getResponseCode();
            if (statusCode == 200 || statusCode == 404) {
                SerialTask.run(new Runnable() {
                    @Override
                    public void run() {
                        removeEvent(uuid);
                        savedEvents();
                    }
                });
            }

            Dl("makeRequestEvent: " + statusCode + ":" + pair.u);
        } catch (IOException ignored) {
            Dl("makeRequestEvent: " + pair.u + ":" + ignored);
        } finally {
            if (out != null) {
                try {
                    out.close();
                } catch (IOException ignored) {
                }
            }
            if (urlConnection != null) {
                urlConnection.disconnect();
            }
        }
    }

    @SuppressWarnings("unused")
    static SkiEventTracker getInstance() {
        if (instance == null) {
            throw new IllegalStateException("Skippables sdk not initialized");
        }

        return instance;
    }

    static SkiEventTracker getInstance(@NonNull Context context) {
        if (instance == null) {
            initialize(context.getApplicationContext());
        }

        return instance;
    }

    static void initialize(Context applicationContext) {
        if (instance == null) {
            instance = new SkiEventTracker(applicationContext.getApplicationContext());
        }
    }

    private static void Dl(String l) {
        if (BuildConfig.DEBUG) {
            Log.d("skippables", l);
        }
    }

    private static class SerialTask extends AsyncTask<Runnable, Void, Void> {

        @Override
        protected Void doInBackground(Runnable... runnables) {
            for (Runnable runnable :
                    runnables) {
                runnable.run();
            }

            return null;
        }

        static void run(Runnable... runnables) {
            new SerialTask().executeOnExecutor(AsyncTask.SERIAL_EXECUTOR, runnables);
        }
    }

    static InfringementReport infringementReport() {
        return new InfringementReport();
    }

    static InfringementReport infringementReport(SkiAdInfo adInfo) {
        return new InfringementReport(adInfo);
    }

    static InfringementReport infringementReport(SkiAdRequestResponse response) {
        return new InfringementReport(response.getAdInfo());
    }

    static class InfringementReport {
        private String adId;
        private String adUnitId;
        private String deviceInfoJsonString;


        private String email;
        private String message;

        InfringementReport() {
        }

        InfringementReport(SkiAdInfo adInfo) {
            adId = adInfo.getAdId();
            adUnitId = adInfo.getAdUnitId();
            deviceInfoJsonString = adInfo.getDeviceInfoJsonString();
        }

        InfringementReport setAdId(String adId) {
            this.adId = adId;

            return this;
        }

        InfringementReport setAdUnitId(String adUnitId) {
            this.adUnitId = adUnitId;

            return this;
        }

        InfringementReport setDeviceInfoJsonString(String deviceInfoJsonString) {
            this.deviceInfoJsonString = deviceInfoJsonString;

            return this;
        }

        InfringementReport setEmail(String email) {
            this.email = email;

            return this;
        }

        InfringementReport setMessage(String message) {
            this.message = message;

            return this;
        }

        private JSONObject buildJSON() throws JSONException {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("adid", adId);
            jsonObject.put("adunitid", adUnitId);
            jsonObject.put("email", email);
            jsonObject.put("message", message);
            jsonObject.put("deviceinfo", deviceInfoJsonString);

            return jsonObject;
        }
    }
}
