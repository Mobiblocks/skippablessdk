package com.mobiblocks.skippables;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.mobiblocks.skippables.vast.ImpressionType;
import com.mobiblocks.skippables.vast.InlineType;
import com.mobiblocks.skippables.vast.LinearInlineChildType;
import com.mobiblocks.skippables.vast.LinearWrapperChildType;
import com.mobiblocks.skippables.vast.SaxParser;
import com.mobiblocks.skippables.vast.TrackingEventsType;
import com.mobiblocks.skippables.vast.VAST;
import com.mobiblocks.skippables.vast.VastError;
import com.mobiblocks.skippables.vast.VastTime;
import com.mobiblocks.skippables.vast.VideoClicksBaseType;
import com.mobiblocks.skippables.vast.VideoClicksInlineChildType;
import com.mobiblocks.skippables.vast.WrapperType;

import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class SkiAdRequestResponse {
    @SuppressWarnings("UnusedAssignment")
    @SkiAdRequest.AdError
    private int errorCode = SkiAdRequest.ERROR_NO_ERROR;
    @VastError.AdVastError
    private int vastErrorCode = VastError.VAST_NO_ERROR_CODE;
    private boolean logErrors = true;

    private String htmlSnippet;
    private SkiCompactVast vast;

    @NonNull private final SkiAdInfo adInfo = new SkiAdInfo();

    @SuppressWarnings("WeakerAccess")
    static SkiAdRequestResponse response() {
        return new SkiAdRequestResponse();
    }

    static SkiAdRequestResponse withError(@SkiAdRequest.AdError int errorCode) {
        return new SkiAdRequestResponse(errorCode);
    }

//    @SuppressWarnings({"SameParameterValue", "WeakerAccess"})
//    static SkiAdRequestResponse withVastError(@VastError.AdVastError int vastErrorCode) {
//        return new SkiAdRequestResponse(SkiAdRequest.ERROR_RECEIVED_INVALID_RESPONSE, vastErrorCode);
//    }
//
//    static SkiAdRequestResponse withVastError(@VastError.AdVastError int vastErrorCode, SkiCompactVast vast) {
//        SkiAdRequestResponse response = new SkiAdRequestResponse(SkiAdRequest.ERROR_RECEIVED_INVALID_RESPONSE, vastErrorCode);
//        response.setVastInfo(vast);
//        return response;
//    }

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

    public void setErrorCode(@SkiAdRequest.AdError int errorCode) {
        this.errorCode = errorCode;
    }

    @VastError.AdVastError
    int getVastErrorCode() {
        return vastErrorCode;
    }

    public void setVastErrorCode(@VastError.AdVastError int vastErrorCode) {
        this.vastErrorCode = vastErrorCode;
        if (!hasError()) {
            if (vastErrorCode == VastError.VAST_NO_ERROR_CODE) {
                this.errorCode = SkiAdRequest.ERROR_NO_FILL;
            } else {
                this.errorCode = SkiAdRequest.ERROR_RECEIVED_INVALID_RESPONSE;
            }
        }
    }

    @SuppressWarnings("unused")
    boolean isLogErrors() {
        return logErrors;
    }

    String getHtmlSnippet() {
        return htmlSnippet;
    }

    private void setHtmlSnippet(String htmlSnippet) {
        this.htmlSnippet = htmlSnippet;
    }

    SkiCompactVast getVastInfo() {
        return vast;
    }

    private void setVastInfo(SkiCompactVast vast) {
        this.vast = vast;
    }

    @NonNull SkiAdInfo getAdInfo() {
        return adInfo;
    }

    static SkiAdRequestResponse create(ISkiSessionLogger sessionLogger, SkiAdErrorCollector errorCollector, JSONObject object) {
        String sessionID = object.optString("SessionID");
        errorCollector.setSessionID(sessionID);

        SkiAdRequestResponse response = SkiAdRequestResponse.response();
        response.adInfo.setSessionID(sessionID);
        
        boolean sessionLog = object.optBoolean("SessionLog", false);
        if (!sessionLog) {
            sessionLogger = SkiSessionLogger.createNop(sessionID);
        } else {
            sessionLogger.setSessionID(sessionID);
        }
        
        if (!object.isNull("data") || !object.isNull("Data")) {
            response.adInfo.setAdId(object.optString("AdId"));
            
            String data = object.optString("data", null);
            if (data == null) {
                data = object.optString("Data", null);
            }
            if (data != null) {
                if (data.isEmpty()) {
                    response.setErrorCode(SkiAdRequest.ERROR_NO_FILL);
                }
                
                response.setHtmlSnippet(data);

                return response;
            }
        }

        if (!object.isNull("content") || !object.isNull("Content")) {
            String content = object.optString("content", null);
            if (content == null) {
                content = object.optString("Content", null);
            }
            
            if (content == null || content.isEmpty()) {
                response.setErrorCode(SkiAdRequest.ERROR_NO_FILL);
                return response;
            }

            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.parseVast";
                }
            });

            //content = "<VAST version=\"4.0\" xmlns=\"http://www.iab.com/VAST\">    <Ad id=\"20011\" sequence=\"1\" conditionalAd=\"false\">        <Wrapper followAdditionalWrappers=\"0\" allowMultipleAds=\"1\" fallbackOnNoAd=\"0\">            <AdSystem version=\"4.0\">iabtechlab</AdSystem>            <Error>http://example.com/error</Error>            <Impression id=\"Impression-ID\">http://example.com/track/impression</Impression>            <Creatives>                <Creative id=\"5480\" sequence=\"1\" adId=\"2447226\">                  <CompanionAds>                      <Companion id=\"1232\" width=\"100\" height=\"150\" assetWidth=\"250\" assetHeight=\"200\" expandedWidth=\"350\" expandedHeight=\"250\"  \t\t\t\t\tapiFramework=\"VPAID\" adSlotID=\"3214\" pxratio=\"1400\" >                              <StaticResource creativeType=\"image/png\">                                  <![CDATA[https://www.iab.com/wp-content/uploads/2014/09/iab-tech-lab-6-644x290.png]]>                              </StaticResource>                              <CompanionClickThrough>                                  <![CDATA[https://iabtechlab.com]]>                              </CompanionClickThrough>                      </Companion>                  </CompanionAds>                </Creative>            </Creatives>            <VASTAdTagURI><![CDATA[http://10.0.0.6:8085/wrapper2.xml]]></VASTAdTagURI>        </Wrapper>    </Ad></VAST>";
            VAST vast = parseVast(errorCollector, sessionLogger, content);
            if (vast == null) {
                response.setErrorCode(SkiAdRequest.ERROR_RECEIVED_INVALID_RESPONSE);
                return response;
            }

            VAST.Ad ad = vast.getFirstAd();
            if (ad == null) {
                errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                    @Override
                    public void build(SkiAdErrorCollector.Builder err) {
                        err.type = SkiAdErrorCollector.TYPE_VAST;
                        err.place = "SkiAdRequestResponse.create";
                        err.desc = "VAST does not contain ad.";
                    }
                });
                
                response.setVastErrorCode(VastError.VAST_NO_ERROR_CODE);
                return response;
            }

            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.compactVast";
                }
            });

            Result<SkiCompactVast> compactVastResult = extractInfo(vast);
            response.setVastInfo(compactVastResult.getResult());
            
            if (compactVastResult.getError() != null) {
                final Error error = compactVastResult.getError();

                final SkiCompactVast compactVast = compactVastResult.getResult();
                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adRequest.compactVast.error";
                        if (compactVast != null) {
                            log.info = SkiSessionLogger.Log.info()
                                    .put("error", SkiSessionLogger.Log.info()
                                            .put("domain", error.domain)
                                            .put("code", error.code)
                                            .get())
                                    .get();
                        }
                    }
                });
                
                if (error.domain == 2) {
                    response.setVastErrorCode(error.code);
                    return response;
                } else {

                    response.setVastErrorCode(VastError.VAST_UNDEFINED_ERROR_CODE);
                    return response;
                }
            }
            
            final SkiCompactVast compactVast = compactVastResult.getResult();

            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.compactVast.value";
                    if (compactVast != null) {
                        log.info = compactVast.toJSONObject();
                    }
                }
            });

            response.adInfo.setSessionID(object.optString("SessionID"));
            response.adInfo.setAdId(ad.getId());

            return response;
        }

        response.setErrorCode(SkiAdRequest.ERROR_NO_FILL);

        return response;
    }

    @Nullable
    private static VAST parseVast(SkiAdErrorCollector errorCollector, ISkiSessionLogger sessionLogger, String vastXml) {
        VAST vast;
        try {
            vast = SaxParser.getInstance().parseFromString(vastXml);
        } catch (final Exception e) {
            errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                @Override
                public void build(SkiAdErrorCollector.Builder err) {
                    err.type = SkiAdErrorCollector.TYPE_VAST;
                    err.place = "SkiAdRequestResponse.create";
                    err.underlyingException = e;
                }
            });
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.parseVast.error";
                    log.exception = e;
                }
            });
            
            return null;
        }

        VAST.Ad ad = vast.getFirstAd();
        if (ad == null) {
            return vast;
        }

        if (ad.getWrapper() != null) {
            URL wrapperUrl = ad.getWrapper().getVASTAdTagURI();
            if (wrapperUrl == null) {
                return vast;
            }
            
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adRequest.loadWrapper";
                }
            });

            String wrapperXml = null;
            try {
                wrapperXml = getUrlContent(sessionLogger, wrapperUrl);
            } catch (final IOException e) {
                errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                    @Override
                    public void build(SkiAdErrorCollector.Builder err) {
                        err.type = SkiAdErrorCollector.TYPE_OTHER;
                        err.place = "SkiAdRequestResponse.parseVast";
                        err.underlyingException = e;
                    }
                });
                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adRequest.loadWrapper.error";
                        log.exception = e;
                    }
                });
            }
            if (wrapperXml == null || wrapperXml.isEmpty()) {
                return vast;
            }

            try {
                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adRequest.parseWrapper";
                    }
                });
                VAST wrapperVast = parseVast(errorCollector, sessionLogger, wrapperXml);
                ad.getWrapper().setWrappedVast(wrapperVast); 
            } catch (final Exception e) {
                errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                    @Override
                    public void build(SkiAdErrorCollector.Builder err) {
                        err.type = SkiAdErrorCollector.TYPE_VAST;
                        err.place = "SkiAdRequestResponse.parseVast";
                        err.underlyingException = e;
                    }
                });
                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adRequest.parseWrapper.error";
                        log.exception = e;
                    }
                });
                
                return vast;
            }
        }

        return vast;
    }
    
    static class Result<T> {
        private final T result;
        private final Error error;
        private final boolean failed;

        private Result(T result, Error error, boolean failed) {
            this.result = result;
            this.error = error;
            this.failed = failed;
        }
        
        boolean isFailed() {
            return failed;
        }

        public T getResult() {
            return result;
        }

        public Error getError() {
            return error;
        }

        static <T> Result<T> ok(T result) {
            return new Result<>(result, null, false);
        }

        static <T> Result<T> fail() {
            return new Result<>(null, null, true);
        }

        static <T> Result<T> fail(@NonNull Error error) {
            return new Result<>(null, error, true);
        }

        static <T> Result<T> fail(T result, @NonNull Error error) {
            return new Result<>(result, error, true);
        }
    }
    
    static class Error {
        private final int domain;
        private final int code;

        Error(int domain, int code) {
            this.domain = domain;
            this.code = code;
        }
    }

    private static Result<SkiCompactVast> extractInfo(VAST vast) {
        SkiCompactVast compactVast = new SkiCompactVast();
        if (vast == null) {
            return Result.fail(compactVast, new Error(1, -1000));
        }

        if (vast.getError() != null) {
            compactVast.getErrors().add(vast.getError());
        }

        VAST.Ad ad = vast.getFirstAd();
        if (ad == null) {
            return Result.fail(new Error(2, VastError.VAST_NO_ERROR_CODE));
        }
        
        return extractInfo(vast, compactVast);
    }

    private static Result<SkiCompactVast> extractInfo(VAST vast, SkiCompactVast compactVast) {
        if (vast == null) {
            return Result.fail(new Error(2, VastError.VAST_GENERAL_WRAPPER_ERROR_CODE));
        }
        
        if (vast.getError() != null) {
            compactVast.getErrors().add(vast.getError());
        }
        
        VAST.Ad ad = vast.getFirstAd();
        if (ad == null) {
            return Result.fail(new Error(2, VastError.VAST_GENERAL_WRAPPER_ERROR_CODE));
        }

        WrapperType wrapper = ad.getWrapper();
        if (wrapper != null) {
            return extractInfoWrapper(wrapper, compactVast);
        }

        InlineType inline = ad.getInLine();
        if (inline != null) {
            return extractInfoInline(inline, compactVast);
        }
        
        return Result.fail(compactVast, new Error(2, VastError.VAST_GENERAL_WRAPPER_ERROR_CODE));
    }

    private static Result<SkiCompactVast> extractInfoWrapper(WrapperType wrapper, SkiCompactVast compactVast) {
        compactVast.setWrapper(true);
        URL error = wrapper.getError();
        if (error != null) {
            compactVast.getInlineErrors().add(error);
        }

        List<ImpressionType> impressions = wrapper.getImpression();
        for (ImpressionType impression : impressions) {
            URL url = impression.getValue();
            if (url != null) {
                compactVast.getImpressions().add(url);
            }
        }

        LinearWrapperChildType linear = wrapper.getFirstLinearCreative();
        if (linear != null) {
            TrackingEventsType trackingEvents = linear.getTrackingEvents();
            if (trackingEvents != null) {
                List<TrackingEventsType.Tracking> trackingList = trackingEvents.getTracking();
                if (trackingList != null) {
                    List<SkiCompactVast.TrackingEvent> events = toTrackingEvents(trackingList);
                    compactVast.getAd().getTrackingEvents().addAll(events);
                }
            }

            VideoClicksBaseType videoClicks = linear.getVideoClicks();
            if (videoClicks != null) {
                List<VideoClicksBaseType.ClickTracking> clickTrackings = videoClicks.getClickTracking();
                if (clickTrackings != null) {
                    for (VideoClicksBaseType.ClickTracking track : clickTrackings) {
                        URL url = track.getValue();
                        if (url != null) {
                            compactVast.getAd().getVideoClicks().add(url);
                        }
                    }
                }
            }
        }

        VAST wrappedVast = wrapper.getWrappedVast();
        if (wrappedVast != null) {
            return extractInfo(wrappedVast, compactVast);
        }
        
        return Result.ok(compactVast);
    }

    private static Result<SkiCompactVast> extractInfoInline(InlineType inline, SkiCompactVast compactVast) {
        URL error = inline.getError();
        if (error != null) {
            compactVast.getInlineErrors().add(error);
        }

        List<ImpressionType> impressions = inline.getImpression();
        for (ImpressionType impression : impressions) {
            URL url = impression.getValue();
            if (url != null) {
                compactVast.getImpressions().add(url);
            }
        }

        LinearInlineChildType linear = inline.getFirstLinearCreative();
        if (linear != null) {
            TrackingEventsType trackingEvents = linear.getTrackingEvents();
            if (trackingEvents != null) {
                List<TrackingEventsType.Tracking> trackingList = trackingEvents.getTracking();
                if (trackingList != null) {
                    List<SkiCompactVast.TrackingEvent> events = toTrackingEvents(trackingList);
                    compactVast.getAd().getTrackingEvents().addAll(events);
                }
            }

            VideoClicksInlineChildType videoClicks = linear.getVideoClicks();
            if (videoClicks != null) {
                List<VideoClicksBaseType.ClickTracking> clickTrackings = videoClicks.getClickTracking();
                if (clickTrackings != null) {
                    for (VideoClicksBaseType.ClickTracking track : clickTrackings) {
                        URL url = track.getValue();
                        if (url != null) {
                            compactVast.getAd().getVideoClicks().add(url);
                        }
                    }
                }

                VideoClicksInlineChildType.ClickThrough clickThrough = videoClicks.getClickThrough();
                if (clickThrough != null) {
                    compactVast.getAd().setClickThrough(clickThrough.getValue());
                }
            }
            
            compactVast.getAd().setDuration(VastTime.parse(linear.getDuration()));
            compactVast.getAd().setSkipoffset(VastTime.parse(linear.getSkipoffset()));
            for (LinearInlineChildType.MediaFiles.MediaFile media : linear.getMediaFiles().getMediaFile()) {
                SkiCompactVast.MediaFile compactFile = toMediaFile(media);
                if (compactFile == null) {
                    continue;
                }
                compactVast.getAd().getMediaFiles().add(compactFile);
            }
        }
        
        return Result.ok(compactVast);
    }
    
    private static SkiCompactVast.MediaFile toMediaFile(LinearInlineChildType.MediaFiles.MediaFile media) {
        URL url = media.getValue();
        if (url == null) {
            return null;
        }
        String type = media.getType();
        if (type == null || type.length() == 0) {
            return null;
        }
        
        SkiCompactVast.MediaFile mediaFile = new SkiCompactVast.MediaFile();
        mediaFile.setUrl(url);
        mediaFile.setIdentifier(media.getId());
        mediaFile.setDelivery(media.getDelivery());
        mediaFile.setType(media.getType());
        mediaFile.setWidth(media.getWidth());
        mediaFile.setHeight(media.getHeight());

        return mediaFile;
    }

    private static SkiCompactVast.TrackingEvent toTrackingEvent(TrackingEventsType.Tracking tracking) {
        URL url = tracking.getValue();
        if (url == null) {
            return null;
        }
        VastTime offset = VastTime.parse(tracking.getOffset());

        return new SkiCompactVast.TrackingEvent(tracking.getEvent(), offset, url);
    }

    private static List<SkiCompactVast.TrackingEvent> toTrackingEvents(List<TrackingEventsType.Tracking> trackings) {
        ArrayList<SkiCompactVast.TrackingEvent> events = new ArrayList<>();
        for (TrackingEventsType.Tracking tracking: trackings) {
            SkiCompactVast.TrackingEvent event = toTrackingEvent(tracking);
            if (event == null) {
                continue;
            }
            
            events.add(event);
        }
        
        return events;
    }
    
    private static String tryGetUrlContent(ISkiSessionLogger sessionLogger, final URL url) {
        try {
            return getUrlContent(sessionLogger, url);
        } catch (IOException e) {
            return null;
        }
    }

    private static String getUrlContent(ISkiSessionLogger sessionLogger, final URL url) throws IOException {

        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adRequest.loadWrapper";
                log.info = SkiSessionLogger.Log.info()
                        .put("url", url.toString())
                        .put("method", "GET")
                        .get();
            }
        });
        
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
            final int statusCode = urlConnection.getResponseCode();

            // Connection success. Proceed to fetch the response.
            if (statusCode == 200) {
                BufferedReader buff = null;
                try {
                    InputStream it = new BufferedInputStream(urlConnection.getInputStream());
                    InputStreamReader read = new InputStreamReader(it);
                    buff = new BufferedReader(read);
                    final StringBuilder dta = new StringBuilder();
                    String chunks;
                    while ((chunks = buff.readLine()) != null) {
                        dta.append(chunks);
                    }

                    final HttpURLConnection finalUrlConnection = urlConnection;
                    sessionLogger.build(new SkiSessionLogger.Builder() {
                        @Override
                        public void build(@NonNull SkiSessionLogger.Log log) {
                            log.identifier = "adRequest.loadWrapper.response";
                            log.info = SkiSessionLogger.Log.info()
                                    .put("url", url.toString())
                                    .put("statusCode", statusCode)
                                    .put("data", dta.toString())
                                    .put("headers", finalUrlConnection.getHeaderFields())
                                    .get();
                        }
                    });

                    return dta.toString();
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
                            log.identifier = "adRequest.loadWrapper.response";
                            log.info = SkiSessionLogger.Log.info()
                                    .put("url", url.toString())
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
                
                return null;
            }
        } finally {
            if (urlConnection != null) {
                urlConnection.disconnect();
            }
        }
    }
}
