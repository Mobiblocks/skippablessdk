package com.mobiblocks.skippables;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.os.AsyncTask;
import android.support.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStreamWriter;
import java.io.Serializable;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
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

    private HashMap<UUID, EventDatePair> events = new HashMap<>();

    private URL installUrl;

    private SkiEventTracker(final Context applicationContext) {
        try {
            installUrl = new URL(SKIConstants.GetInstallUrl());
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
                ArrayList<EventDatePair> eventPairs = (ArrayList<EventDatePair>) objectInputStream.readObject();
                for (EventDatePair pair :
                        eventPairs) {
                    Date eventDate = pair.date;
                    if (eventDate.before(date)) {
                        continue;
                    }

                    events.put(UUID.randomUUID(), pair);
                }
            } catch (IOException | ClassNotFoundException ignored) {
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
            data.put("aid", applicationContext.getPackageName());
            data.put("idfa", Util.getAAID(applicationContext));

            //noinspection ResultOfMethodCallIgnored
            installFile.createNewFile();
            
            trackEventRequest(installUrl, NO_EXPIRE, data);
        } catch (JSONException | IOException ignored) {
        }
    }

    private void maybeResendEvents() {
        Date current = new Date();
        for (Map.Entry<UUID, EventDatePair> entry :
                events.entrySet()) {
            UUID uuid = entry.getKey();
            EventDatePair pair = entry.getValue();
            Date eventDate = pair.date;
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

    private void trackEventRequest(final URL url, final Date expires, final JSONObject data) {
        final UUID uuid = UUID.randomUUID();

        SerialTask.run(new Runnable() {
            @Override
            public void run() {
                events.put(uuid, EventDatePair.pair(url, expires, data));
                savedEvents();
            }
        }, new Runnable() {
            @Override
            public void run() {
                makeRequestEvent(uuid);
            }
        });
    }

    private void makeRequestEvent(final UUID uuid) {
        EventDatePair pair = events.get(uuid);
        if (pair == null) {
            return;
        }

        HttpURLConnection urlConnection = null;
        OutputStreamWriter out = null;
        try {
            JSONObject data = pair.getData();
            
            urlConnection = (HttpURLConnection) pair.url.openConnection();
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
        } catch (IOException ignored) {

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

    private static class EventDatePair implements Serializable {
        private static final long serialVersionUID = 1352111171012111124L;

        private final URL url;
        private final Date date;
        private final String data;

        private EventDatePair(URL url, Date date, JSONObject data) {
            this.date = date;
            this.url = url;
            this.data = data == null ? null : data.toString();
        }

        static EventDatePair pair(URL url, Date expires, JSONObject data) {
            return new EventDatePair(url, expires, data);
        }

        public JSONObject getData() {
            if (data == null) {
                return null;
            }
            
            try {
                return new JSONObject(data);
            } catch (JSONException e) {
                return null;
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
