package com.mobiblocks.skippables;

import android.support.annotation.IntDef;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.net.URL;
import java.util.HashMap;

/**
 * Created by daniel on 10/24/18.
 * <p>
 * Copyright Mobiblocks 2018. All rights reserved.
 */
class SkiAdErrorCollector {
    static final int TYPE_HTTP = 0;
    static final int TYPE_VAST = 1;
    static final int TYPE_PLAYER = 2;
    static final int TYPE_OTHER = 3;
    @SuppressWarnings("WeakerAccess")
    @IntDef({TYPE_HTTP,
            TYPE_VAST,
            TYPE_PLAYER,
            TYPE_OTHER})
    @Retention(RetentionPolicy.SOURCE)
    public @interface ErrorType { }
    
    static class Builder {
        @ErrorType int type;
        String place;
        String desc;
        Exception underlyingException;
        HashMap<String, Object> otherInfo;

        JSONObject toJSONObject() {
            JSONObject object = new JSONObject();
            try {
                object.put("type", type);
                if (place != null) {
                    object.put("place", place);
                }
                if (desc != null) {
                    object.put("description", desc);
                }
                if (underlyingException != null) {
                    JSONObject exObject = new JSONObject();
                    exObject.put("message", underlyingException.getMessage());
                    exObject.put("localizedMessage", underlyingException.getLocalizedMessage());

                    StringWriter sw = new StringWriter();
                    PrintWriter pw = new PrintWriter(sw);
                    underlyingException.printStackTrace(pw);
                    String sStackTrace = sw.toString(); // stack trace as a string
                    
                    exObject.put("stackTrace", sStackTrace);
                    
                    object.put("underlyingError", exObject);
                }
                if (otherInfo != null && otherInfo.size() > 0) {
                    object.put("info", new JSONObject(otherInfo));
                }
                
                return object;
            } catch (JSONException ignore) {
            }
            
            return null;
        }
        
        static JSONObject buildJSONObject(ErrorCollector collector) {
            Builder builder = new Builder();
            collector.build(builder);
            
            return builder.toJSONObject();
        }
    }
    
    interface ErrorCollector {
        void build(Builder err);
    }
    
    private String mSessionID;

    @SuppressWarnings("unused")
    String getSessionID() {
        return mSessionID;
    }
    
    private URL reportURL;

    SkiAdErrorCollector() {
        reportURL = SKIConstants.GetErrorReportURL(null);
    }

    void setSessionID(String mSessionID) {
        this.mSessionID = mSessionID;
        reportURL = SKIConstants.GetErrorReportURL(mSessionID);
    }
    
    void collect(ErrorCollector collector) {
        if (reportURL == null) {
            return;
        }
        
        Builder builder = new Builder();
        collector.build(builder);

        final JSONObject object = builder.toJSONObject();
        if (object != null) {
            SkiEventTracker.getInstance().trackEvent(new SkiEventTracker.EventBuilder() {
                @Override
                public void build(SkiEventTracker.Builder ev) {
                    ev.url = reportURL;
                    ev.data = object;
                    ev.sessionID = mSessionID;
                }
            });
        }
    }
}
