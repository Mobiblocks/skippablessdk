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

    SkiAdRequestTask(@NonNull SkiAdErrorCollector errorCollector, @NonNull Listener listener) {
        this.errorCollector = errorCollector;
        this.listener = listener;
    }

    @Override
    protected SkiAdRequestResponse doInBackground(SkiAdRequest... skiAdRequests) {
        SkiAdRequest adRequest = skiAdRequests[0];

        JSONObject requestJson = listener.onGetRequestInfo(adRequest);
        if (requestJson == null) {
            errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                @Override
                public void build(SkiAdErrorCollector.Builder err) {
                    err.type = SkiAdErrorCollector.TYPE_OTHER;
                    err.place = "SkiAdRequestTask.doInBackground";
                    err.desc = "Failed to serialise request json";
                }
            });
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_INTERNAL_ERROR);
        }

        final String urlString = SKIConstants.GetAdApiUrl(adRequest.getAdType());
        OutputStreamWriter out = null;
        HttpURLConnection urlConnection = null;
        try {
            // Creating & connection Connection with url and required Header.
            URL url = new URL(urlString);
            urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setConnectTimeout(15 * 1000);
            urlConnection.setReadTimeout(15 * 1000);
            urlConnection.setRequestProperty("Connection", "close");
            urlConnection.setRequestProperty("Content-Type", "application/json");
            urlConnection.setRequestMethod("POST");   //POST or GET
            urlConnection.setDoInput(true);
            urlConnection.setDoOutput(true);

            if (urlConnection instanceof HttpsURLConnection) {
                ((HttpsURLConnection) urlConnection).setSSLSocketFactory(HttpsURLConnection.getDefaultSSLSocketFactory());
            }
            
            urlConnection.connect();

            // Write Request to output stream to server.
            out = new OutputStreamWriter(urlConnection.getOutputStream(),  "UTF-8");
            out.write(requestJson.toString());
            out.close();
            out = null;

            // Check the connection status.
            final int statusCode = urlConnection.getResponseCode();

            // Connection success. Proceed to fetch the response.
            if (statusCode == 200) {
                BufferedReader buff = null;
                SkiVastCompressedInfo vastInfo = null;
                try {
                    InputStream it = new BufferedInputStream(urlConnection.getInputStream());
                    InputStreamReader read = new InputStreamReader(it);
                    buff = new BufferedReader(read);
                    StringBuilder dta = new StringBuilder();
                    String chunks;
                    while ((chunks = buff.readLine()) != null) {
                        dta.append(chunks);
                    }

                    final SkiAdRequestResponse response = processResponseJson(new JSONObject(dta.toString()));
                    vastInfo = response.getVastInfo();
                    if (vastInfo != null) {
                        SkiVastCompressedInfo.MediaFile mediaFile = listener.onGetBestMediaFile(response.getVastInfo());
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
                            return SkiAdRequestResponse.withVastError(VastError.VAST_MEDIA_FILE_NOT_SUPPORTED_ERROR_CODE, vastInfo);
                        }

                        String tempDir = listener.onGetTempDirectory() + "/" + UUID.randomUUID().toString() + ".mp4";
                        response.getVastInfo().setLocalMediaFile(tempDir);
                        URL mediaUrl = mediaFile.getValue();
                        downloadMediaFile(mediaUrl, tempDir);
                    }

                    response.getAdInfo().setAdUnitId(adRequest.getAdUnitId());
                    JSONObject deviceInfo = requestJson.optJSONObject("device");
                    if (deviceInfo != null) {
                        response.getAdInfo().setDeviceInfoJsonString(deviceInfo.toString());
                    }

                    return response;
                } catch (VastException e) {
                    return SkiAdRequestResponse.withVastError(e.getErrorCode(), vastInfo);
                } finally {
                    if (buff != null) {
                        buff.close();
                    }
                }
            } else {
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

    private void downloadMediaFile(URL url, String dest) throws IOException, VastException {
        HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
        urlConnection.setConnectTimeout(15 * 1000);
        urlConnection.setReadTimeout(15 * 1000);
        urlConnection.setRequestProperty("Connection", "close");
        urlConnection.setDoInput(true);
        urlConnection.setRequestMethod("GET");   //POST or GET
        urlConnection.connect();

        // Check the connection status.
        int statusCode = urlConnection.getResponseCode();

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
    }

    private SkiAdRequestResponse processResponseJson(JSONObject response) {
        return SkiAdRequestResponse.create(errorCollector, response);
    }

    @Override
    protected void onPostExecute(SkiAdRequestResponse skiAdRequestResponse) {
        super.onPostExecute(skiAdRequestResponse);

        listener.onResponse(skiAdRequestResponse);
    }

    interface Listener {
        JSONObject onGetRequestInfo(SkiAdRequest request);

        SkiVastCompressedInfo.MediaFile onGetBestMediaFile(SkiVastCompressedInfo vastInfo);

        String onGetTempDirectory() throws IOException;

        void onResponse(SkiAdRequestResponse response);
    }
}
