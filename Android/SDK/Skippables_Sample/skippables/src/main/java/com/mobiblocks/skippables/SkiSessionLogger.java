package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.AsyncTask;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.ref.WeakReference;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;

/**
 * Created by daniel on 11/14/18.
 * <p>
 * Copyright Mobiblocks 2018. All rights reserved.
 */
class SkiSessionLogger {

    private static String sUnique;

    private static class NopLogger implements ISkiSessionLogger {

        @Override
        public boolean canLog() {
            return false;
        }

        @Override
        public String getSessionID() {
            return "";
        }

        @Override
        public ISkiSessionLogger setSessionID(String sessionID) {
            if (sessionID == null) {
                return this;
            }

            synchronized (loggers) {
                loggers.put(sessionID, new WeakReference<ISkiSessionLogger>(this));
            }

            return this;
        }

        @Override
        public ISkiSessionLogger collectInfo(@NonNull Context context) {
            return this;
        }

        @Override
        public ISkiSessionLogger build(@NonNull Builder builder) {
            return this;
        }

        @Override
        public void report() {

        }
    }

    private static class SessionLogger implements ISkiSessionLogger {
        @Nullable
        private String unique;
        @Nullable
        private String ifa;
        @Nullable
        private String session;
        @Nullable
        private String sessionID;
        @NonNull
        private ArrayList<Log> logs = new ArrayList<>();


        private SessionLogger() {
            this.unique = sUnique;
            this.session = Util.getCurrentSession();
        }

        @Override
        public boolean canLog() {
            return true;
        }

        @Override
        public ISkiSessionLogger collectInfo(@NonNull Context context) {
            @SuppressLint("HardwareIds") String androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
            this.unique = androidId;
            this.ifa = null;//Util.getAAID(context);
            this.session = Util.getCurrentSession();

            return this;
        }

        @Override
        public String getSessionID() {
            return sessionID;
        }

        @Override
        public ISkiSessionLogger setSessionID(String sessionID) {
            String old = this.sessionID;
            this.sessionID = sessionID;

            synchronized (loggers) {
                if (old != null) {
                    loggers.remove(old);
                }
                if (sessionID != null) {
                    loggers.put(sessionID, new WeakReference<ISkiSessionLogger>(this));
                }
            }

            return this;
        }

        @Override
        public ISkiSessionLogger build(@NonNull Builder builder) {
            Log log = new Log();
            builder.build(log);

            logs.add(log);

            return this;
        }

        @Override
        public void report() {
            if (logs.size() == 0) {
                return;
            }

            JSONArray array = new JSONArray();
            for (Log log : logs) {
                JSONObject jsonObject = log.toJSONObject();
                if (jsonObject == null || jsonObject.length() == 0) {
                    continue;
                }

                array.put(jsonObject);
            }

            JSONObject jsonObject = new JSONObject();
            jsonPutShhhh(jsonObject, "sessionID", sessionID);
            jsonPutShhhh(jsonObject, "unique", unique != null ? unique : sUnique);
            jsonPutShhhh(jsonObject, "session", session);
            jsonPutShhhh(jsonObject, "ifa", ifa);
            jsonPutShhhh(jsonObject, "sdkVersion", Skippables.version);
            jsonPutShhhh(jsonObject, "logs", array);

            final String jsonString = jsonObject.toString();

            SerialTask.run(new Runnable() {
                @Override
                public void run() {
                    HttpURLConnection urlConnection = null;
                    OutputStreamWriter out = null;
                    try {
                        urlConnection = (HttpURLConnection) SKIConstants.GetEventReportURL().openConnection();
                        urlConnection.setConnectTimeout(15 * 1000);
                        urlConnection.setReadTimeout(15 * 1000);
                        urlConnection.setRequestProperty("Connection", "close");
                        urlConnection.setDoOutput(true);
                        urlConnection.setRequestMethod("POST");
                        urlConnection.setRequestProperty("Content-Type", "application/json");
                        urlConnection.connect();

                        // Write Request to output stream to server.
                        out = new OutputStreamWriter(urlConnection.getOutputStream(), "UTF-8");
                        out.write(jsonString);
                        out.close();
                        out = null;

                        urlConnection.getResponseCode();
                    } catch (Exception ignore1) {
                    } finally {
                        try {
                            if (out != null) {
                                out.close();
                            }
                        } catch (IOException ignore2) {
                        }
                        if (urlConnection != null) {
                            urlConnection.disconnect();
                        }
                    }
                }
            });

            logs.clear();
        }
    }

    @NonNull
    private final static HashMap<String, WeakReference<ISkiSessionLogger>> loggers = new HashMap<>();
    
    private SkiSessionLogger() {}

    @NonNull
    static ISkiSessionLogger getLogger(@Nullable String sessionID) {
        if (sessionID == null || sessionID.length() == 0) {
            return new NopLogger();
        }
        
        ISkiSessionLogger logger = _getLogger(sessionID);
        if (logger == null) {
            return new NopLogger().setSessionID(sessionID);
        }
        
        return logger;
    }
    
    private static ISkiSessionLogger _getLogger(@NonNull String sessionID) {
        synchronized (loggers) {
            WeakReference<ISkiSessionLogger> weakReference = loggers.get(sessionID);
            if (weakReference == null) {
                return null;
            }

            ISkiSessionLogger logger = weakReference.get();
            if (logger == null) {
                loggers.remove(sessionID);
                return null;
            }

            return logger;
        }
    }

    static void initialize(Context context) {
        if (sUnique != null) {
            return;
        }

        @SuppressLint("HardwareIds") String androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        sUnique = androidId;
    }

    static ISkiSessionLogger create() {
        return new SessionLogger();
    }

    static ISkiSessionLogger createNop() {
        return new NopLogger();
    }

    static ISkiSessionLogger createNop(@NonNull String sessionID) {
        if (sessionID == null) {
            return createNop();
        }
        
        return createNop().setSessionID(sessionID);
    }

    interface Builder {
        void build(@NonNull Log log);
    }

    private static void jsonPutShhhh(JSONObject jsonObject, String key, Object object) {
        if (object == null) {
            return;
        }

        try {
            jsonObject.putOpt(key, object);
        } catch (JSONException ignore) {
        }
    }

    static class Log {
        String identifier;
        @NonNull
        Date date = new Date();
        String desc;
        Exception exception;
        JSONObject info;

        static InfoBuild info() {
            return new InfoBuild();
        }

        JSONObject toJSONObject() {
            JSONObject jsonObject = new JSONObject();
            jsonPutShhhh(jsonObject, "identifier", identifier);
            jsonPutShhhh(jsonObject, "timestamp", BigDecimal.valueOf((double) date.getTime() / 1000.0f));
            jsonPutShhhh(jsonObject, "description", desc);
            if (exception != null) {
                JSONObject exObject = new JSONObject();
                jsonPutShhhh(exObject, "message", exception.getMessage());
                jsonPutShhhh(exObject, "localizedMessage", exception.getLocalizedMessage());

                StringWriter sw = new StringWriter();
                PrintWriter pw = new PrintWriter(sw);
                exception.printStackTrace(pw);
                String sStackTrace = sw.toString(); // stack trace as a string

                jsonPutShhhh(exObject, "stackTrace", sStackTrace);

                jsonPutShhhh(jsonObject, "exception", exObject);
            }
            if (info != null && info.length() > 0) {
                jsonPutShhhh(jsonObject, "info", info);
            }

            return jsonObject;
        }

        static class InfoBuild {
            private JSONObject jsonObject = new JSONObject();

            InfoBuild put(String key, Object object) {
                Object wrapped = Util.jsonWrap(object);
                jsonPutShhhh(jsonObject, key, wrapped);
                Object wrapped2 = Util.jsonWrap(object);
                return this;
            }

            JSONObject get() {
                return jsonObject;
            }
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
}
