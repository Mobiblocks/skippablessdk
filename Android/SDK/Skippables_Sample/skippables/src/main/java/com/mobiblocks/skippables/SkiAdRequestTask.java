package com.mobiblocks.skippables;

import android.os.AsyncTask;
import android.support.annotation.NonNull;

import com.mobiblocks.skippables.vast.VastError;

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

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class SkiAdRequestTask extends AsyncTask<SkiAdRequest, Void, SkiAdRequestResponse> {

    private final Listener listener;

    SkiAdRequestTask(@NonNull Listener listener) {
        this.listener = listener;
    }

    @Override
    protected SkiAdRequestResponse doInBackground(SkiAdRequest... skiAdRequests) {
        SkiAdRequest adRequest = skiAdRequests[0];

        JSONObject requestJson = listener.onGetRequestInfo(adRequest);
        if (requestJson == null) {
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_INTERNAL_ERROR);
        }

        String urlString = SKIConstants.GetAdApiUrl(adRequest.getAdType());
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
            int statusCode = urlConnection.getResponseCode();

            // Connection success. Proceed to fetch the response.
            if (statusCode == 200) {
                BufferedReader buff = null;
                try {
                    InputStream it = new BufferedInputStream(urlConnection.getInputStream());
                    InputStreamReader read = new InputStreamReader(it);
                    buff = new BufferedReader(read);
                    StringBuilder dta = new StringBuilder();
                    String chunks;
                    while ((chunks = buff.readLine()) != null) {
                        dta.append(chunks);
                    }

                    SkiAdRequestResponse response = processResponseJson(new JSONObject(dta.toString()));
                    if (response.getVastInfo() != null) {
                        SkiVastCompressedInfo.MediaFile mediaFile = listener.onGetBestMediaFile(response.getVastInfo());
                        if (mediaFile == null) {
                            return SkiAdRequestResponse.withVastError(VastError.VAST_MEDIA_FILE_NOT_SUPPORTED_ERROR_CODE);
                        }

                        String tempDir = listener.onGetTempDirectory() + "/" + UUID.randomUUID().toString() + ".mp4";
                        response.getVastInfo().setLocalMediaFile(tempDir);
                        downloadMediaFile(mediaFile.getValue(), tempDir);
                    }
                    
                    response.getAdInfo().setAdUnitId(adRequest.getAdUnitId());
                    JSONObject deviceInfo = requestJson.optJSONObject("device");
                    if (deviceInfo != null) {
                        response.getAdInfo().setDeviceInfoJsonString(deviceInfo.toString());
                    }

                    return response;
                } finally {
                    if (buff != null) {
                        buff.close();
                    }
                }
            } else {
                return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_SERVER_ERROR);
            }
        } catch (ProtocolException e) {
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_NETWORK_ERROR);
        } catch (MalformedURLException e) {
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_INTERNAL_ERROR);
        } catch (IOException e) {
            return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_NETWORK_ERROR);
        } catch (JSONException e) {
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

    private void downloadMediaFile(URL url, String dest) throws IOException {
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
        }
    }

    private SkiAdRequestResponse processResponseJson(JSONObject response) {
        return SkiAdRequestResponse.create(response);
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
