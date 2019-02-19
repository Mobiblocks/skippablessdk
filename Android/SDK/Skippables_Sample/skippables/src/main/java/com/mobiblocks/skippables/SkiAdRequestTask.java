package com.mobiblocks.skippables;

import android.os.AsyncTask;
import android.support.annotation.NonNull;

import com.mobiblocks.skippables.vast.VastError;
import com.mobiblocks.skippables.vast.VastException;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.util.UUID;

import javax.net.ssl.HttpsURLConnection;

import static com.mobiblocks.skippables.vast.VastError.VAST_MEDIA_FILE_NOT_FOUND_ERROR_CODE;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class SkiAdRequestTask extends AsyncTask<SkiAdRequest, Void, SkiAdRequestResponse> {

    private final Listener listener;
    private final SkiAdErrorCollector errorCollector;
    private final ISkiSessionLogger sessionLogger;

    SkiAdRequestTask(@NonNull ISkiSessionLogger sessionLogger, @NonNull SkiAdErrorCollector errorCollector, @NonNull Listener listener) {
        this.sessionLogger = sessionLogger;
        this.errorCollector = errorCollector;
        this.listener = listener;
    }

    @Override
    protected SkiAdRequestResponse doInBackground(SkiAdRequest... skiAdRequests) {
        SkiAdRequest adRequest = skiAdRequests[0];

        final JSONObject requestJson = listener.onGetRequestInfo(adRequest);
        if (requestJson == null) {
            errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                @Override
                public void build(SkiAdErrorCollector.Builder err) {
                    err.type = SkiAdErrorCollector.TYPE_OTHER;
                    err.place = "SkiAdRequestTask.doInBackground";
                    err.desc = "Failed to serialise request json";
                }
            });
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.requestData.error";
                    log.desc = "Failed to collect device data";
                }
            });
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_INTERNAL_ERROR);
        }

        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adRequest.requestData";
                log.info = requestJson;
            }
        });

        final String urlString = SKIConstants.GetAdApiUrl(adRequest.getAdType());
        final String httpMethod = "POST";
        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adRequest.sendRequestData";
                log.info = SkiSessionLogger.Log.info()
                        .put("url", urlString)
                        .put("method", httpMethod)
                        .get();
            }
        });

        OutputStreamWriter out = null;
        HttpURLConnection urlConnection = null;
        try {
            URL url = new URL(urlString);
            urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setConnectTimeout(15 * 1000);
            urlConnection.setReadTimeout(15 * 1000);
            urlConnection.setRequestProperty("Connection", "close");
            urlConnection.setRequestProperty("Content-Type", "application/json");
            urlConnection.setRequestMethod(httpMethod);   //POST or GET
            urlConnection.setDoInput(true);
            urlConnection.setDoOutput(true);

            if (urlConnection instanceof HttpsURLConnection) {
                ((HttpsURLConnection) urlConnection).setSSLSocketFactory(HttpsURLConnection.getDefaultSSLSocketFactory());
            }

            urlConnection.connect();

            // Write Request to output stream to server.
            out = new OutputStreamWriter(urlConnection.getOutputStream(), "UTF-8");
            out.write(requestJson.toString());
            out.close();
            out = null;

            // Check the connection status.
            final int statusCode = urlConnection.getResponseCode();

            // Connection success. Proceed to fetch the response.
            if (statusCode == 200) {
                SkiCompactVast compactVast = null;
                BufferedReader buff = null;
                try {
                    final StringBuilder dta = new StringBuilder();
                    InputStream it = new BufferedInputStream(urlConnection.getInputStream());
                    InputStreamReader read = new InputStreamReader(it);
                    buff = new BufferedReader(read);
                    String chunks;
                    while ((chunks = buff.readLine()) != null) {
                        dta.append(chunks);
                    }

                    final HttpURLConnection finalUrlConnection = urlConnection;
                    sessionLogger.build(new SkiSessionLogger.Builder() {
                        @Override
                        public void build(@NonNull SkiSessionLogger.Log log) {
                            log.identifier = "adRequest.sendRequestData.response";
                            log.info = SkiSessionLogger.Log.info()
                                    .put("url", urlString)
                                    .put("statusCode", statusCode)
                                    .put("data", dta.toString())
                                    .put("headers", finalUrlConnection.getHeaderFields())
                                    .get();
                        }
                    });
                    
                    sessionLogger.build(new SkiSessionLogger.Builder() {
                        @Override
                        public void build(@NonNull SkiSessionLogger.Log log) {
                            log.identifier = "adRequest.processResponseData";
                        }
                    });
                    
                    final SkiAdRequestResponse response = processResponseJson(adRequest.getAdType(), new JSONObject(dta.toString()));
                    response.getAdInfo().setAdUnitId(adRequest.getAdUnitId());
                    JSONObject deviceInfo = requestJson.optJSONObject("device");
                    if (deviceInfo != null) {
                        response.getAdInfo().setDeviceInfoJsonString(deviceInfo.toString());
                    }
                    
                    compactVast = response.getVastInfo();
                    if (compactVast != null) {
                        final SkiCompactVast.MediaFile mediaFile = listener.onGetBestMediaFile(compactVast);
                        if (mediaFile == null) {
                            errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                                @Override
                                public void build(SkiAdErrorCollector.Builder err) {
                                    err.type = SkiAdErrorCollector.TYPE_VAST;
                                    err.place = "SkiAdRequestTask.doInBackground";
                                    err.desc = "VAST does not contain playable media.";
                                    err.otherInfo = Util.<String, Object>hm(
                                            "identifier",
                                            response.getAdInfo().getAdId()
                                    );
                                }
                            });
                            response.setVastErrorCode(VastError.VAST_MEDIA_FILE_NOT_SUPPORTED_ERROR_CODE);
                            return response;
                        }

                        sessionLogger.build(new SkiSessionLogger.Builder() {
                            @Override
                            public void build(@NonNull SkiSessionLogger.Log log) {
                                log.identifier = "adRequest.compactVast.selectedMedia";
                                log.info = mediaFile.toJSONObject();
                            }
                        });

                        sessionLogger.build(new SkiSessionLogger.Builder() {
                            @Override
                            public void build(@NonNull SkiSessionLogger.Log log) {
                                log.identifier = "adRequest.downloadMedia";
                            }
                        });
                        

                        String tempDir = listener.onGetTempDirectory() + "/" + UUID.randomUUID().toString() + ".mp4";
                        URL mediaUrl = mediaFile.getUrl();
                        try {
                            downloadMediaFile(sessionLogger, mediaUrl, tempDir);
                        } catch (final VastException e) {
                            sessionLogger.build(new SkiSessionLogger.Builder() {
                                @Override
                                public void build(@NonNull SkiSessionLogger.Log log) {
                                    log.identifier = "adRequest.processResponseData.error";
                                    log.exception = e;
                                }
                            });
                            
                            response.setVastErrorCode(e.getErrorCode());
                            return response;
                        }
                        
                        mediaFile.setLocalMediaFile(tempDir);
                    }

                    return response;
                } finally {
                    if (buff != null) {
                        buff.close();
                    }
                }
            } else {
                BufferedReader buff = null;
                try {
                    final StringBuilder dta = new StringBuilder();
                    InputStream it = new BufferedInputStream(urlConnection.getErrorStream());
                    InputStreamReader read = new InputStreamReader(it);
                    buff = new BufferedReader(read);
                    String chunks;
                    while ((chunks = buff.readLine()) != null) {
                        dta.append(chunks);
                    }

                    final HttpURLConnection finalUrlConnection = urlConnection;
                    sessionLogger.build(new SkiSessionLogger.Builder() {
                        @Override
                        public void build(@NonNull SkiSessionLogger.Log log) {
                            log.identifier = "adRequest.sendRequestData.response";
                            log.info = SkiSessionLogger.Log.info()
                                    .put("url", urlString)
                                    .put("statusCode", statusCode)
                                    .put("data", dta.toString())
                                    .put("headers", finalUrlConnection.getHeaderFields())
                                    .get();
                        }
                    });
                } catch (Exception ignore) {
                } finally {
                    if (buff != null) {
                        buff.close();
                    }
                }

                errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                    @Override
                    public void build(SkiAdErrorCollector.Builder err) {
                        err.type = SkiAdErrorCollector.TYPE_HTTP;
                        err.place = "SkiAdRequestTask.doInBackground";
                        err.otherInfo = Util.<String, Object>hm(
                                "url", urlString,
                                "statusCode", "" + statusCode
                        );
                    }
                });
                return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_SERVER_ERROR);
            }
        } catch (final ProtocolException e) {
            errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                @Override
                public void build(SkiAdErrorCollector.Builder err) {
                    err.type = SkiAdErrorCollector.TYPE_HTTP;
                    err.place = "SkiAdRequestTask.doInBackground";
                    err.otherInfo = Util.<String, Object>hm(
                            "url", urlString
                    );
                    err.underlyingException = e;
                }
            });
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.sendRequestData.error";
                    log.exception = e;
                }
            });
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_NETWORK_ERROR);
        } catch (final MalformedURLException e) {
            errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                @Override
                public void build(SkiAdErrorCollector.Builder err) {
                    err.type = SkiAdErrorCollector.TYPE_HTTP;
                    err.place = "SkiAdRequestTask.doInBackground";
                    err.otherInfo = Util.<String, Object>hm(
                            "url", urlString
                    );
                    err.underlyingException = e;
                }
            });
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.sendRequestData.error";
                    log.exception = e;
                }
            });
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_INTERNAL_ERROR);
        } catch (final IOException e) {
            errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                @Override
                public void build(SkiAdErrorCollector.Builder err) {
                    err.type = SkiAdErrorCollector.TYPE_HTTP;
                    err.place = "SkiAdRequestTask.doInBackground";
                    err.otherInfo = Util.<String, Object>hm(
                            "url", urlString
                    );
                    err.underlyingException = e;
                }
            });
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.sendRequestData.error";
                    log.exception = e;
                }
            });
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_NETWORK_ERROR);
        } catch (final JSONException e) {
            errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                @Override
                public void build(SkiAdErrorCollector.Builder err) {
                    err.type = SkiAdErrorCollector.TYPE_HTTP;
                    err.place = "SkiAdRequestTask.doInBackground";
                    err.otherInfo = Util.<String, Object>hm(
                            "url", urlString
                    );
                    err.underlyingException = e;
                }
            });
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.sendRequestData.error";
                    log.exception = e;
                }
            });
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_RECEIVED_INVALID_RESPONSE);
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

    private static void downloadMediaFile(ISkiSessionLogger sessionLogger, final URL url, String dest) throws IOException, VastException {
        try {
            final HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setConnectTimeout(15 * 1000);
            urlConnection.setReadTimeout(15 * 1000);
            urlConnection.setRequestProperty("Connection", "close");
            urlConnection.setDoInput(true);
            urlConnection.setRequestMethod("GET");   //POST or GET
            urlConnection.connect();

            // Check the connection status.
            final int statusCode = urlConnection.getResponseCode();

            // Connection success. Proceed to fetch the response.
            if (statusCode == 200) {
                File destFile = new File(dest);

                InputStream it = new BufferedInputStream(urlConnection.getInputStream());

                FileOutputStream fileOutputStream = new FileOutputStream(destFile);

                byte[] chunks = new byte[4096];
                int count;
                while ((count = it.read(chunks)) != -1) {
                    fileOutputStream.write(chunks, 0, count);
                }

                fileOutputStream.close();
            } else {
                throw new VastException(VAST_MEDIA_FILE_NOT_FOUND_ERROR_CODE);
            }

            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.downloadMedia.response";
                    log.info = SkiSessionLogger.Log.info()
                            .put("url", url.toString())
                            .put("statusCode", statusCode)
                            .put("headers", urlConnection.getHeaderFields())
                            .get();
                }
            });
        } catch (final Exception e) {
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.downloadMedia.error";
                    log.exception = e;
                }
            });
            
            throw e;
        }
    }

    private SkiAdRequestResponse processResponseJson(@SkiAdRequest.AdType int adType, JSONObject response) {
        return SkiAdRequestResponse.create(sessionLogger, errorCollector, adType, response);
    }

    @Override
    protected void onPostExecute(SkiAdRequestResponse skiAdRequestResponse) {
        super.onPostExecute(skiAdRequestResponse);

        listener.onResponse(skiAdRequestResponse);
    }

    interface Listener {
        JSONObject onGetRequestInfo(SkiAdRequest request);

        SkiCompactVast.MediaFile onGetBestMediaFile(SkiCompactVast compactVast);

        String onGetTempDirectory() throws IOException;

        void onResponse(SkiAdRequestResponse response);
    }
}
