package com.mobiblocks.skippables;

import com.mobiblocks.skippables.vast.ImpressionType;
import com.mobiblocks.skippables.vast.InlineType;
import com.mobiblocks.skippables.vast.LinearInlineChildType;
import com.mobiblocks.skippables.vast.LinearWrapperChildType;
import com.mobiblocks.skippables.vast.SaxParser;
import com.mobiblocks.skippables.vast.TrackingEventsType;
import com.mobiblocks.skippables.vast.VAST;
import com.mobiblocks.skippables.vast.VastError;
import com.mobiblocks.skippables.vast.VastException;
import com.mobiblocks.skippables.vast.VideoClicksBaseType;
import com.mobiblocks.skippables.vast.VideoClicksInlineChildType;
import com.mobiblocks.skippables.vast.WrapperType;

import org.json.JSONObject;
import org.xml.sax.SAXException;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class SkiAdRequestResponse {
    @SkiAdRequest.AdError
    private int errorCode = SkiAdRequest.ERROR_NO_ERROR;
    @VastError.AdVastError
    private int vastErrorCode = VastError.VAST_NO_ERROR_CODE;
    private String htmlSnippet;
    private SkiVastCompressedInfo vast;

    @SuppressWarnings("WeakerAccess")
    static SkiAdRequestResponse response() {
        return new SkiAdRequestResponse();
    }

    static SkiAdRequestResponse withError(@SkiAdRequest.AdError int errorCode) {
        return new SkiAdRequestResponse(SkiAdRequest.ERROR_RECEIVED_INVALID_RESPONSE, errorCode);
    }

    static SkiAdRequestResponse withVastError(@VastError.AdVastError int vastErrorCode) {
        return new SkiAdRequestResponse(vastErrorCode);
    }

    private SkiAdRequestResponse() {
        this.errorCode = 0;
    }

    private SkiAdRequestResponse(@SkiAdRequest.AdError int errorCode) {
        this.errorCode = errorCode;
    }

    private SkiAdRequestResponse(@SkiAdRequest.AdError int errorCode, @VastError.AdVastError int vastErrorCode) {
        this.errorCode = errorCode;
        this.vastErrorCode = vastErrorCode;
    }

    boolean hasError() {
        return errorCode != SkiAdRequest.ERROR_NO_ERROR;
    }

    boolean hasVastError() {
        return vastErrorCode != VastError.VAST_NO_ERROR_CODE;
    }

    @SuppressWarnings("unused")
    boolean hasAnyError() {
        return hasError() || hasVastError();
    }

    @SkiAdRequest.AdError
    int getErrorCode() {
        return errorCode;
    }
    
    @VastError.AdVastError
    public int getVastErrorCode() {
        return vastErrorCode;
    }

    String getHtmlSnippet() {
        return htmlSnippet;
    }

    private void setHtmlSnippet(String htmlSnippet) {
        this.htmlSnippet = htmlSnippet;
    }

    SkiVastCompressedInfo getVastInfo() {
        return vast;
    }

    private void setVastInfo(SkiVastCompressedInfo vast) {
        this.vast = vast;
    }

    static SkiAdRequestResponse create(JSONObject object) {
        if (!object.isNull("data") || !object.isNull("Data")) {
            String data = object.optString("data", null);
            if (data == null) {
                data = object.optString("Data", null);
            }
            if (data != null) {
                if (data.isEmpty()) {
                    return new SkiAdRequestResponse(SkiAdRequest.ERROR_NO_FILL);
                }

                SkiAdRequestResponse response = SkiAdRequestResponse.response();
                response.setHtmlSnippet(data);

                return response;
            }
        }

        if (!object.isNull("content") || !object.isNull("Content")) {
            String content = object.optString("content", null);
            if (content == null) {
                content = object.optString("Content", null);
            }
            if (content != null) {
                if (content.isEmpty()) {
                    return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_NO_FILL);
                }

                try {
                    VAST vast = parseVast(content);
                    VAST.Ad ad = vast.getFirstAd();
                    if (ad == null) {
                        return SkiAdRequestResponse.withVastError(VastError.VAST_UNDEFINED_ERROR_CODE);
                    }

                    SkiVastCompressedInfo compressedInfo = extractInfo(vast);

                    SkiAdRequestResponse response = new SkiAdRequestResponse();
                    response.setVastInfo(compressedInfo);

                    return response;
                } catch (VastException e) {
                    return SkiAdRequestResponse.withVastError(e.getErrorCode());
                } catch (ParserConfigurationException e) {
                    return SkiAdRequestResponse.withVastError(VastError.VAST_XMLPARSE_ERROR_CODE);
                } catch (SAXException e) {
                    return SkiAdRequestResponse.withVastError(VastError.VAST_XMLPARSE_ERROR_CODE);
                } catch (IOException e) {
                    return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_INTERNAL_ERROR);
                }
            }
        }

        return SkiAdRequestResponse.withError(SkiAdRequest.ERROR_NO_FILL);
    }

    private static VAST parseVast(String vastXml) throws ParserConfigurationException, SAXException, VastException, IOException {
        VAST vast = SaxParser.getInstance().parseFromString(vastXml);
        VAST.Ad ad = vast.getFirstAd();
        if (ad == null) {
            return vast;
        }

        if (ad.getWrapper() != null) {
            URL wrapperUrl = ad.getWrapper().getVASTAdTagURI();
            if (wrapperUrl == null) {
                throw new VastException(VastError.VAST_GENERAL_WRAPPER_ERROR_CODE);
            }

            String wrapperXml = getUrlContent(wrapperUrl);
            if (wrapperXml == null || wrapperXml.isEmpty()) {
                throw new VastException(VastError.VAST_WRAPPER_NO_VAST_ERROR_CODE);
            }

            ad.getWrapper().setWrappedVast(parseVast(wrapperXml));
        }

        return vast;
    }

    private static SkiVastCompressedInfo extractInfo(VAST vast) throws VastException {
        VAST.Ad ad = vast.getFirstAd();
        if (ad == null) {
            return null;
        }

        SkiVastCompressedInfo compressedInfo = new SkiVastCompressedInfo();

        WrapperType wrapper = ad.getWrapper();
        if (wrapper != null) {
            extractInfoWrapper(wrapper, compressedInfo);
        }

        InlineType inline = ad.getInLine();
        if (inline != null) {
            extractInfoInline(inline, compressedInfo);
        }

        return compressedInfo;
    }

    private static void extractInfo(VAST vast, SkiVastCompressedInfo compressedInfo) throws VastException {
        VAST.Ad ad = vast.getFirstAd();
        if (ad == null) {
            return;
        }

        WrapperType wrapper = ad.getWrapper();
        if (wrapper != null) {
            extractInfoWrapper(wrapper, compressedInfo);
        }

        InlineType inline = ad.getInLine();
        if (inline != null) {
            extractInfoInline(inline, compressedInfo);
        }
    }

    private static void extractInfoWrapper(WrapperType wrapper, SkiVastCompressedInfo compressedInfo) throws VastException {
        URL error = wrapper.getError();
        if (error != null) {
            compressedInfo.getErrorTrackings().add(error);
        }

        List<ImpressionType> impressions = wrapper.getImpression();
        for (ImpressionType impression : impressions) {
            URL url = impression.getValue();
            if (url != null) {
                compressedInfo.getImpressionUrls().add(url);
            }
        }

        LinearWrapperChildType linear = wrapper.getFirstLinearCreative();
        if (linear != null) {
            TrackingEventsType trackingEvents = linear.getTrackingEvents();
            if (trackingEvents != null) {
                List<TrackingEventsType.Tracking> trackingList = trackingEvents.getTracking();
                if (trackingList != null) {
                    compressedInfo.addTrackings(trackingList);
                }
            }

            VideoClicksBaseType videoClicks = linear.getVideoClicks();
            if (videoClicks != null) {
                List<VideoClicksBaseType.ClickTracking> clickTrackings = videoClicks.getClickTracking();
                if (clickTrackings != null) {
                    for (VideoClicksBaseType.ClickTracking track : clickTrackings) {
                        URL url = track.getValue();
                        if (url != null) {
                            compressedInfo.getClickTrackings().add(url);
                        }
                    }
                }
            }
        }

        VAST wrappedVast = wrapper.getWrappedVast();
        if (wrappedVast != null) {
            extractInfo(wrappedVast, compressedInfo);
        }
    }

    private static void extractInfoInline(InlineType inline, SkiVastCompressedInfo compressedInfo) throws VastException {
        URL error = inline.getError();
        if (error != null) {
            compressedInfo.getErrorTrackings().add(error);
        }

        List<ImpressionType> impressions = inline.getImpression();
        for (ImpressionType impression : impressions) {
            URL url = impression.getValue();
            if (url != null) {
                compressedInfo.getImpressionUrls().add(url);
            }
        }

        LinearInlineChildType linear = inline.getFirstLinearCreative();
        if (linear != null) {
            TrackingEventsType trackingEvents = linear.getTrackingEvents();
            if (trackingEvents != null) {
                List<TrackingEventsType.Tracking> trackingList = trackingEvents.getTracking();
                if (trackingList != null) {
                    compressedInfo.addTrackings(trackingList);
                }
            }

            VideoClicksInlineChildType videoClicks = linear.getVideoClicks();
            if (videoClicks != null) {
                List<VideoClicksBaseType.ClickTracking> clickTrackings = videoClicks.getClickTracking();
                if (clickTrackings != null) {
                    for (VideoClicksBaseType.ClickTracking track : clickTrackings) {
                        URL url = track.getValue();
                        if (url != null) {
                            compressedInfo.getClickTrackings().add(url);
                        }
                    }
                }

                VideoClicksInlineChildType.ClickThrough clickThrough = videoClicks.getClickThrough();
                if (clickThrough != null) {
                    compressedInfo.setClickThrough(clickThrough.getValue());
                }
            }

            compressedInfo.setCreative(linear);
        }
    }

    private static String getUrlContent(URL url) throws IOException {
        HttpURLConnection urlConnection = null;
        try {
            urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setConnectTimeout(15 * 1000);
            urlConnection.setReadTimeout(15 * 1000);
            urlConnection.setRequestProperty("Connection", "close");
            urlConnection.setDoInput(true);
            urlConnection.setRequestProperty("Content-Type", "application/json");
            urlConnection.setRequestMethod("GET");   //POST or GET
            urlConnection.connect();

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

                    return dta.toString();
                } finally {
                    if (buff != null) {
                        buff.close();
                    }
                }
            } else {
                return null;
            }
        } finally {
            if (urlConnection != null) {
                urlConnection.disconnect();
            }
        }
    }
}
