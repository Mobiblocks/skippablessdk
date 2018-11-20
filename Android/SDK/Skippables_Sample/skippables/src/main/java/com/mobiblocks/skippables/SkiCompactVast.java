package com.mobiblocks.skippables;

import android.content.Context;
import android.graphics.Point;
import android.os.Build;
import android.os.Parcel;
import android.os.Parcelable;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.DisplayMetrics;
import android.util.SparseArray;
import android.view.Display;
import android.view.WindowManager;

import com.mobiblocks.skippables.vast.VastTime;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

/**
 * Created by daniel on 11/13/18.
 * <p>
 * Copyright Mobiblocks 2018. All rights reserved.
 */
class SkiCompactVast implements Parcelable {
    private ArrayList<URL> errors = new ArrayList<>();
    private ArrayList<URL> inlineErrors = new ArrayList<>();
    private ArrayList<URL> impressions = new ArrayList<>();
    private boolean isWrapper = false;
    private Ad ad = new Ad();
    
    SkiCompactVast() {}

    SkiCompactVast(Parcel in) {
        errors = toURLArray(in.createStringArrayList());
        inlineErrors = toURLArray(in.createStringArrayList());
        impressions = toURLArray(in.createStringArrayList());
        
        isWrapper = in.readByte() != 0;
        ad = in.readParcelable(Ad.class.getClassLoader());
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeStringList(toStringArray(errors));
        dest.writeStringList(toStringArray(inlineErrors));
        dest.writeStringList(toStringArray(impressions));
        
        dest.writeByte((byte) (isWrapper ? 1 : 0));
        dest.writeParcelable(ad, flags);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<SkiCompactVast> CREATOR = new Creator<SkiCompactVast>() {
        @Override
        public SkiCompactVast createFromParcel(Parcel in) {
            return new SkiCompactVast(in);
        }

        @Override
        public SkiCompactVast[] newArray(int size) {
            return new SkiCompactVast[size];
        }
    };

    @NonNull ArrayList<URL> getErrors() {
        return errors;
    }

    @NonNull ArrayList<URL> getInlineErrors() {
        return inlineErrors;
    }

    @NonNull ArrayList<URL> getImpressions() {
        return impressions;
    }

    boolean isWrapper() {
        return isWrapper;
    }

    public void setWrapper(boolean wrapper) {
        isWrapper = wrapper;
    }

    Ad getAd() {
        return ad;
    }

    JSONObject toJSONObject() {
        JSONObject jsonObject = new JSONObject();
        if (errors != null && errors.size() > 0) {
            try {
                jsonObject.put("errors", Util.jsonWrap(toStringArray(errors)));
            } catch (JSONException ignore) { }
        }
        if (inlineErrors != null && inlineErrors.size() > 0) {
            try {
                jsonObject.put("inlineErrors", Util.jsonWrap(toStringArray(inlineErrors)));
            } catch (JSONException ignore) { }
        }
        if (impressions != null && impressions.size() > 0) {
            try {
                jsonObject.put("impressions", Util.jsonWrap(toStringArray(impressions)));
            } catch (JSONException ignore) { }
        }
        try {
            jsonObject.put("isWrapper", isWrapper);
        } catch (JSONException ignore) { }
        if (this.ad != null) {
            try {
                jsonObject.putOpt("ad", this.ad.toJSONObject());
            } catch (JSONException ignore) { }
        }
        return jsonObject;
    }

    static class Ad implements Parcelable {
        private String identifier;
        private VastTime duration;
        private VastTime skipoffset;
        private URL clickThrough;
        private ArrayList<URL> videoClicks = new ArrayList<>();
        private ArrayList<MediaFile> mediaFiles = new ArrayList<>();
        private ArrayList<TrackingEvent> trackingEvents = new ArrayList<>();
        private MediaFile mediaFile;

        Ad() {}

        Ad(Parcel in) throws MalformedURLException {
            identifier = in.readString();
            duration = in.readParcelable(VastTime.class.getClassLoader());
            skipoffset = in.readParcelable(VastTime.class.getClassLoader());
            String clickThroughString = in.readString();
            if (clickThroughString != null && !clickThroughString.isEmpty()) {
                clickThrough = new URL(clickThroughString);
            }
            
            videoClicks = toURLArray(in.createStringArrayList());
            mediaFiles = in.createTypedArrayList(MediaFile.CREATOR);
            trackingEvents = in.createTypedArrayList(TrackingEvent.CREATOR);
            mediaFile = in.readParcelable(MediaFile.class.getClassLoader());
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(identifier);
            dest.writeParcelable(duration, flags);
            dest.writeParcelable(skipoffset, flags);
            dest.writeString(clickThrough == null ? null : clickThrough.toString());
            
            dest.writeStringList(toStringArray(videoClicks));
            dest.writeTypedList(mediaFiles);
            dest.writeTypedList(trackingEvents);
            dest.writeParcelable(mediaFile, flags);
        }

        @Override
        public int describeContents() {
            return 0;
        }

        public static final Creator<Ad> CREATOR = new Creator<Ad>() {
            @Override
            public Ad createFromParcel(Parcel in) {
                try {
                    return new Ad(in);
                } catch (MalformedURLException e) {
                    return null;
                }
            }

            @Override
            public Ad[] newArray(int size) {
                return new Ad[size];
            }
        };

        boolean maybeShownInLandscape() {
            //noinspection SimplifiableIfStatement
            if (mediaFile == null) {
                return false;
            }

            return mediaFile.width > mediaFile.height;
        }

        String getIdentifier() {
            return identifier;
        }

        VastTime getDuration() {
            return duration;
        }

        void setDuration(VastTime duration) {
            this.duration = duration;
        }

        VastTime getSkipoffset() {
            return skipoffset;
        }

        void setSkipoffset(VastTime skipoffset) {
            this.skipoffset = skipoffset;
        }

        URL getClickThrough() {
            return clickThrough;
        }

        void setClickThrough(URL clickThrough) {
            this.clickThrough = clickThrough;
        }

        @NonNull ArrayList<URL> getVideoClicks() {
            return videoClicks;
        }

        @NonNull ArrayList<MediaFile> getMediaFiles() {
            return mediaFiles;
        }

        @NonNull ArrayList<TrackingEvent> getTrackingEvents() {
            return trackingEvents;
        }

        @Nullable MediaFile findBestMediaFile(Context context) {
            if (mediaFile == null) {
                int screenWidth = -1;
                int screenHeight = -1;

                WindowManager windowManager =
                        (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
                if (windowManager != null) {
                    Display display = windowManager.getDefaultDisplay();
                    Point size = new Point();
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                        display.getRealSize(size);

                        screenWidth = size.x;
                        screenHeight = size.y;
                    }
                }

                if (screenWidth == -1 || screenHeight == -1) {
                    DisplayMetrics metrics = context.getResources().getDisplayMetrics();
                    screenWidth = metrics.widthPixels;
                    screenHeight = metrics.heightPixels;
                }

                float screenRatio = (float)Math.max(screenWidth, screenHeight) / (float)Math.min(screenWidth, screenHeight);
                int screenPixels = screenWidth - screenHeight;

                float widthWeight = 1;
                float heightWeight = 1;
                if (screenWidth > screenHeight) {
                    heightWeight = 1.5f;
                } else if (screenWidth < screenHeight) {
                    widthWeight = 1.5f;
                }

                ArrayList<MediaFile> usable = usableMediaFilesSortedByResolution(mediaFiles);

                SparseArray<MediaFile> pointedMediaFiles = new SparseArray<>();

                for (MediaFile media : usable) {
                    int currentWidth = media.width;
                    int currentHeight = media.height;

                    float currentRatio = (float)Math.max(currentWidth, currentHeight) / (float)Math.min(currentWidth, currentHeight);
                    int currentPixels = currentWidth - currentHeight;

                    float ratioDiff = Math.abs(screenRatio - currentRatio);
                    int widthDiff = Math.abs(screenWidth - currentWidth);
                    int heightDiff = Math.abs(screenHeight - currentHeight);
                    int pixelsDiff = Math.abs(screenPixels - currentPixels);

                    int pointRatio = Math.round(ratioDiff * 100.f);
                    int pointWidth = Math.round(widthDiff / 100.f * widthWeight);
                    int pointHeight = Math.round(heightDiff / 100.f * heightWeight);
                    int pointPixels = Math.round(pixelsDiff / 100.f * 1);

                    int points = pointRatio + pointWidth + pointHeight + pointPixels;
                    pointedMediaFiles.put(points, media);
                }

                if (pointedMediaFiles.size() == 0) {
                    return null;
                }

                int bestKey = Integer.MAX_VALUE;
                for (int i = 0; i < pointedMediaFiles.size(); i++) {
                    int key = pointedMediaFiles.keyAt(i);

                    if (bestKey > key) {
                        bestKey = key;
                    }
                }

                mediaFile = pointedMediaFiles.get(bestKey);
            }

            return mediaFile;
        }

        private static ArrayList<MediaFile> usableMediaFilesSortedByResolution(ArrayList<MediaFile> mediaFiles) {
            ArrayList<MediaFile> usable = new ArrayList<>();
            if (mediaFiles == null || mediaFiles.size() == 0) {
                return usable;
            }

            for (MediaFile media : mediaFiles) {
                if ("video/mp4".equalsIgnoreCase(media.type) || "video/3gpp".equalsIgnoreCase(media.type)) {
                    usable.add(media);
                }
            }

            Collections.sort(usable, new Comparator<MediaFile>() {
                @Override
                public int compare(MediaFile o1, MediaFile o2) {
                    int m1 = o1.width * o1.height;
                    int m2 = o2.width * o2.height;

                    if (m1 == m2) {
                        return 0;
                    } else if (m1 > m2) {
                        return 1;
                    } else if (m1 < m2) {
                        return -1;
                    } else {
                        return 0; // LOL))
                    }
                }
            });

            return usable;
        }

        JSONObject toJSONObject() {
            JSONObject jsonObject = new JSONObject();
            if (duration != null) {
                try {
                    jsonObject.putOpt("duration", duration.toJSONValue());
                } catch (JSONException ignore) { }
            }
            if (skipoffset != null) {
                try {
                    jsonObject.putOpt("skipoffset", skipoffset.toJSONValue());
                } catch (JSONException ignore) { }
            }
            if (clickThrough != null) {
                try {
                    jsonObject.putOpt("clickThrough", clickThrough.toString());
                } catch (JSONException ignore) { }
            }
            if (videoClicks != null && videoClicks.size() > 0) {
                try {
                    jsonObject.putOpt("videoClicks", Util.jsonWrap(toStringArray(videoClicks)));
                } catch (JSONException ignore) { }
            }
            if (mediaFiles != null && mediaFiles.size() > 0) {
                JSONArray mediaList = new JSONArray();
                for (MediaFile mediaFile : mediaFiles) {
                    JSONObject jo = mediaFile.toJSONObject();
                    if (jo == null) {
                        continue;
                    }
                    mediaList.put(jo);
                }
                try {
                    jsonObject.putOpt("mediaFiles", mediaList);
                } catch (JSONException ignore) { }
            }
            if (trackingEvents != null && trackingEvents.size() > 0) {
                JSONArray trackingList = new JSONArray();
                for (TrackingEvent event : trackingEvents) {
                    JSONObject jo = event.toJSONObject();
                    if (jo == null) {
                        continue;
                    }
                    trackingList.put(jo);
                }
                try {
                    jsonObject.putOpt("trackingEvents", trackingList);
                } catch (JSONException ignore) { }
            }
            return jsonObject;
        }
    }
    
    static class MediaFile implements Parcelable {
        private String identifier;
        private String type;
        private String delivery;
        private int width;
        private int height;
        private URL url;

        private String localMediaFile;
        
        MediaFile() {}

        MediaFile(Parcel in) throws MalformedURLException {
            identifier = in.readString();
            type = in.readString();
            delivery = in.readString();
            width = in.readInt();
            height = in.readInt();
            String urlString = in.readString();
            if (urlString != null && !urlString.isEmpty()) {
                url = new URL(urlString);
            }
            localMediaFile = in.readString();
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(identifier);
            dest.writeString(type);
            dest.writeString(delivery);
            dest.writeInt(width);
            dest.writeInt(height);
            dest.writeString(url == null ? null : url.toString());
            dest.writeString(localMediaFile);
        }

        @Override
        public int describeContents() {
            return 0;
        }

        public static final Creator<MediaFile> CREATOR = new Creator<MediaFile>() {
            @Override
            public MediaFile createFromParcel(Parcel in) {
                try {
                    return new MediaFile(in);
                } catch (MalformedURLException e) {
                    return null;
                }
            }

            @Override
            public MediaFile[] newArray(int size) {
                return new MediaFile[size];
            }
        };

        String getLocalMediaFile() {
            return localMediaFile;
        }

        void setLocalMediaFile(String localMediaFile) {
            this.localMediaFile = localMediaFile;
        }

         String getIdentifier() {
            return identifier;
        }

         void setIdentifier(String identifier) {
            this.identifier = identifier;
        }

         String getType() {
            return type;
        }

         void setType(String type) {
            this.type = type;
        }

         String getDelivery() {
            return delivery;
        }

         void setDelivery(String delivery) {
            this.delivery = delivery;
        }

         int getWidth() {
            return width;
        }

         void setWidth(int width) {
            this.width = width;
        }

         int getHeight() {
            return height;
        }

         void setHeight(int height) {
            this.height = height;
        }

         URL getUrl() {
            return url;
        }

         void setUrl(URL url) {
            this.url = url;
        }

        JSONObject toJSONObject() {
            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.putOpt("identifier", identifier);
            } catch (JSONException ignore) { }
            try {
                jsonObject.putOpt("type", type);
            } catch (JSONException ignore) { }
            try {
                jsonObject.putOpt("delivery", delivery);
            } catch (JSONException ignore) { }
            try {
                jsonObject.putOpt("width", width);
            } catch (JSONException ignore) { }
            try {
                jsonObject.putOpt("height", height);
            } catch (JSONException ignore) { }
            if (url != null) {
                try {
                    jsonObject.putOpt("url", url.toString());
                } catch (JSONException ignore) { }
            }
            return jsonObject;
        }
    }
    
    static class TrackingEvent implements Parcelable {
        private String event;
        private VastTime offset;
        private URL url;
        
        TrackingEvent() {}

        TrackingEvent(String event, VastTime offset, URL url) {
            this.event = event;
            this.offset = offset;
            this.url = url;
        }

        TrackingEvent(Parcel in) throws MalformedURLException {
            event = in.readString();
            offset = in.readParcelable(VastTime.class.getClassLoader());
            String urlString = in.readString();
            if (urlString != null && !urlString.isEmpty()) {
                url = new URL(urlString);
            }
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(event);
            dest.writeParcelable(offset, flags);
            dest.writeString(url == null ? null : url.toString());
        }

        @Override
        public int describeContents() {
            return 0;
        }

        public static final Creator<TrackingEvent> CREATOR = new Creator<TrackingEvent>() {
            @Override
            public TrackingEvent createFromParcel(Parcel in) {
                try {
                    return new TrackingEvent(in);
                } catch (MalformedURLException e) {
                    return null;
                }
            }

            @Override
            public TrackingEvent[] newArray(int size) {
                return new TrackingEvent[size];
            }
        };

        String getEvent() {
            return event;
        }

        VastTime getOffset() {
            return offset;
        }

        URL getUrl() {
            return url;
        }

        JSONObject toJSONObject() {
            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.putOpt("event", event);
            } catch (JSONException ignore) { }
            if (offset != null) {
                try {
                    jsonObject.putOpt("offset", offset.toJSONValue());
                } catch (JSONException ignore) { }
            }
            if (url != null) {
                try {
                    jsonObject.putOpt("url", url.toString());
                } catch (JSONException ignore) { }
            }
            return jsonObject;
        }
    }


    private static ArrayList<String> toStringArray(ArrayList<URL> urls) {
        if (urls == null) {
            return null;
        }

        ArrayList<String> strings = new ArrayList<>();
        for (URL url : urls) {
            strings.add(url.toString());
        }

        return strings;
    }

    private static ArrayList<URL> toURLArray(ArrayList<String> urls) {
        if (urls == null) {
            return null;
        }

        ArrayList<URL> strings = new ArrayList<>();
        for (String url : urls) {
            try {
                strings.add(new URL(url));
            } catch (MalformedURLException ignored) {
            }
        }

        return strings;
    }
}
