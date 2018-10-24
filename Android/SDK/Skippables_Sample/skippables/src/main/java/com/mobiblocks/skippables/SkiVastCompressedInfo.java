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

import com.mobiblocks.skippables.vast.LinearInlineChildType;
import com.mobiblocks.skippables.vast.TrackingEventsType;
import com.mobiblocks.skippables.vast.VastException;
import com.mobiblocks.skippables.vast.VastTime;

import java.math.BigInteger;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by daniel on 12/19/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class SkiVastCompressedInfo implements Parcelable {
    private MediaFile mediaFile;
    private ArrayList<MediaFile> mediaFiles;
    private String localMediaFile;
    private VastTime duration;
    private VastTime skipoffset;

    @NonNull
    private ArrayList<URL> errorTrackings = new ArrayList<>();

    @NonNull
    private ArrayList<URL> impressionUrls = new ArrayList<>();

    @NonNull
    private ArrayList<MediaFile.Tracking> trackings = new ArrayList<>();

    private URL clickThrough;

    @NonNull
    private ArrayList<URL> clickTrackings = new ArrayList<>();

    SkiVastCompressedInfo() {
    }

    private SkiVastCompressedInfo(Parcel in) throws MalformedURLException {
        mediaFile = in.readParcelable(MediaFile.class.getClassLoader());
        mediaFiles = in.createTypedArrayList(MediaFile.CREATOR);
        localMediaFile = in.readString();
        duration = in.readParcelable(VastTime.class.getClassLoader());
        skipoffset = in.readParcelable(VastTime.class.getClassLoader());

        errorTrackings = toURLArray(in.createStringArrayList());
        impressionUrls = toURLArray(in.createStringArrayList());

        trackings = in.createTypedArrayList(MediaFile.Tracking.CREATOR);

        String clickThroughString = in.readString();
        if (clickThroughString != null && !clickThroughString.isEmpty()) {
            clickThrough = new URL(clickThroughString);
        }

        clickTrackings = toURLArray(in.createStringArrayList());
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(mediaFile, flags);
        dest.writeTypedList(mediaFiles);
        dest.writeString(localMediaFile);
        dest.writeParcelable(duration, flags);
        dest.writeParcelable(skipoffset, flags);

        dest.writeStringList(toStringArray(errorTrackings));
        dest.writeStringList(toStringArray(impressionUrls));

        dest.writeTypedList(trackings);

        dest.writeString(clickThrough == null ? null : clickThrough.toString());

        dest.writeStringList(toStringArray(clickTrackings));
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<SkiVastCompressedInfo> CREATOR = new Creator<SkiVastCompressedInfo>() {
        @Override
        public SkiVastCompressedInfo createFromParcel(Parcel in) {
            try {
                return new SkiVastCompressedInfo(in);
            } catch (MalformedURLException e) {
                return null;
            }
        }

        @Override
        public SkiVastCompressedInfo[] newArray(int size) {
            return new SkiVastCompressedInfo[size];
        }
    };

    boolean isMaybeShownInLandscape() {
        //noinspection SimplifiableIfStatement
        if (mediaFile == null) {
            return false;
        }

        return mediaFile.width > mediaFile.height;
    }

    void setCreative(LinearInlineChildType creative) throws VastException {
        if (creative != null) {
            mediaFiles = new ArrayList<>();
            for (LinearInlineChildType.MediaFiles.MediaFile media : creative.getMediaFiles().getMediaFile()) {
                mediaFiles.add(MediaFile.create(media));
            }

            duration = VastTime.parse(creative.getDuration());
            skipoffset = VastTime.parse(creative.getSkipoffset());
        }
    }

    @SuppressWarnings("PointlessArithmeticExpression")
    @Nullable
    MediaFile findBestMediaFile(Context context) {
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
            
            ArrayList<MediaFile> usable = usableMediaFilesSortedByResolution();

            SparseArray<MediaFile> pointedMediaFiles = new SparseArray<>();

            for (MediaFile media :
                    usable) {
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

    private ArrayList<MediaFile> usableMediaFilesSortedByResolution() {
        ArrayList<MediaFile> usable = new ArrayList<>();
        if (mediaFiles == null) {
            return usable;
        }
        
        for (MediaFile media :
                mediaFiles) {
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

    String getLocalMediaFile() {
        return localMediaFile;
    }

    void setLocalMediaFile(String localMediaFile) {
        this.localMediaFile = localMediaFile;
    }

    @Nullable
    VastTime getDuration() {
        return duration;
    }

    @Nullable
    VastTime getSkipOffset() {
        return skipoffset;
    }

    @NonNull
    ArrayList<URL> getErrorTrackings() {
        return errorTrackings;
    }

    @NonNull
    ArrayList<URL> getImpressionUrls() {
        return impressionUrls;
    }

    void addTrackings(List<TrackingEventsType.Tracking> trackings) {
        if (trackings == null) {
            return;
        }

        for (TrackingEventsType.Tracking tracking :
                trackings) {
            this.trackings.add(MediaFile.Tracking.create(tracking));
        }
    }

    @NonNull
    ArrayList<MediaFile.Tracking> getTrackings() {
        return trackings;
    }

    URL getClickThrough() {
        return clickThrough;
    }

    void setClickThrough(URL clickThrough) {
        this.clickThrough = clickThrough;
    }

    @NonNull
    ArrayList<URL> getClickTrackings() {
        return clickTrackings;
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

    @SuppressWarnings({"unused", "NullableProblems"})
    static class MediaFile implements Parcelable {
        @NonNull
        URL value;
        String id;
        @NonNull
        String delivery;
        @NonNull
        String type;
        int width;
        int height;
        String codec;
        int bitrate;
        int minBitrate;
        int maxBitrate;
        Boolean scalable;
        Boolean maintainAspectRatio;
        String apiFramework;

        MediaFile() {
        }

        MediaFile(Parcel in) throws MalformedURLException {
            String urlString = in.readString();
            value = new URL(urlString);
            id = in.readString();
            delivery = in.readString();
            type = in.readString();
            width = in.readInt();
            height = in.readInt();
            codec = in.readString();
            bitrate = in.readInt();
            minBitrate = in.readInt();
            maxBitrate = in.readInt();
            byte tmpScalable = in.readByte();
            scalable = tmpScalable == 0 ? null : tmpScalable == 1;
            byte tmpMaintainAspectRatio = in.readByte();
            maintainAspectRatio = tmpMaintainAspectRatio == 0 ? null : tmpMaintainAspectRatio == 1;
            apiFramework = in.readString();
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(value.toString());
            dest.writeString(id);
            dest.writeString(delivery);
            dest.writeString(type);
            dest.writeInt(width);
            dest.writeInt(height);
            dest.writeString(codec);
            dest.writeInt(bitrate);
            dest.writeInt(minBitrate);
            dest.writeInt(maxBitrate);
            dest.writeByte((byte) (scalable == null ? 0 : scalable ? 1 : 2));
            dest.writeByte((byte) (maintainAspectRatio == null ? 0 : maintainAspectRatio ? 1 : 2));
            dest.writeString(apiFramework);
        }

        @Override
        public int describeContents() {
            return 0;
        }

        @SuppressWarnings("WeakerAccess")
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

        /**
         * Gets the value of the value property.
         *
         * @return possible object is
         * {@link URL }
         */
        @NonNull
        public URL getValue() {
            return value;
        }

        /**
         * Gets the value of the id property.
         *
         * @return possible object is
         * {@link String }
         */
        public String getId() {
            return id;
        }

        /**
         * Gets the value of the delivery property.
         *
         * @return possible object is
         * {@link String }
         */
        @NonNull
        public String getDelivery() {
            return delivery;
        }

        /**
         * Gets the value of the type property.
         *
         * @return possible object is
         * {@link String }
         */
        @NonNull
        public String getType() {
            return type;
        }

        /**
         * Gets the value of the width property.
         *
         * @return possible object is
         * {@link BigInteger }
         */
        public int getWidth() {
            return width;
        }

        /**
         * Gets the value of the height property.
         *
         * @return possible object is
         * {@link BigInteger }
         */
        public int getHeight() {
            return height;
        }

        /**
         * Gets the value of the codec property.
         *
         * @return possible object is
         * {@link String }
         */
        public String getCodec() {
            return codec;
        }

        /**
         * Gets the value of the bitrate property.
         *
         * @return possible object is
         * {@link BigInteger }
         */
        public int getBitrate() {
            return bitrate;
        }

        /**
         * Gets the value of the minBitrate property.
         *
         * @return possible object is
         * {@link BigInteger }
         */
        public int getMinBitrate() {
            return minBitrate;
        }

        /**
         * Gets the value of the maxBitrate property.
         *
         * @return possible object is
         * {@link BigInteger }
         */
        public int getMaxBitrate() {
            return maxBitrate;
        }

        /**
         * Gets the value of the scalable property.
         *
         * @return possible object is
         * {@link Boolean }
         */
        public Boolean isScalable() {
            return scalable;
        }

        /**
         * Gets the value of the maintainAspectRatio property.
         *
         * @return possible object is
         * {@link Boolean }
         */
        public Boolean isMaintainAspectRatio() {
            return maintainAspectRatio;
        }

        /**
         * Gets the value of the apiFramework property.
         *
         * @return possible object is
         * {@link String }
         */
        public String getApiFramework() {
            return apiFramework;
        }

        static MediaFile create(LinearInlineChildType.MediaFiles.MediaFile media) {
            MediaFile mediaFile = new MediaFile();
            mediaFile.value = media.getValue();
            mediaFile.id = media.getId();
            mediaFile.delivery = media.getDelivery();
            mediaFile.type = media.getType();
            mediaFile.width = media.getWidth();
            mediaFile.height = media.getHeight();
            mediaFile.codec = media.getCodec();
            mediaFile.bitrate = media.getBitrate();
            mediaFile.minBitrate = media.getMinBitrate();
            mediaFile.maxBitrate = media.getMaxBitrate();
            mediaFile.scalable = media.isScalable();
            mediaFile.maintainAspectRatio = media.isMaintainAspectRatio();
            mediaFile.apiFramework = media.getApiFramework();

            return mediaFile;
        }

        public static class Tracking implements Parcelable {
            URL value;
            String event;
            VastTime offset;

            Tracking() {
            }

            Tracking(Parcel in) throws MalformedURLException {
                String urlString = in.readString();
                if (urlString != null && !urlString.isEmpty()) {
                    value = new URL(urlString);
                }
                event = in.readString();
                offset = in.readParcelable(VastTime.class.getClassLoader());
            }

            @Override
            public void writeToParcel(Parcel dest, int flags) {
                dest.writeString(value == null ? null : value.toString());
                dest.writeString(event);
                dest.writeParcelable(offset, flags);
            }

            @Override
            public int describeContents() {
                return 0;
            }

            @SuppressWarnings("WeakerAccess")
            public static final Creator<Tracking> CREATOR = new Creator<Tracking>() {
                @Override
                public Tracking createFromParcel(Parcel in) {
                    try {
                        return new Tracking(in);
                    } catch (MalformedURLException e) {
                        return null;
                    }
                }

                @Override
                public Tracking[] newArray(int size) {
                    return new Tracking[size];
                }
            };

            /**
             * Gets the value of the value property.
             *
             * @return possible object is
             * {@link URL }
             */
            @NonNull
            URL getValue() {
                return value;
            }

            /**
             * Gets the value of the event property.
             *
             * @return possible object is
             * {@link String }
             */
            @NonNull
            String getEvent() {
                return event;
            }

            /**
             * Gets the value of the offset property.
             *
             * @return possible object is
             * {@link String }
             */
            VastTime getOffset() {
                return offset;
            }

            static Tracking create(TrackingEventsType.Tracking from) {
                Tracking tracking = new Tracking();
                tracking.value = from.getValue();
                tracking.event = from.getEvent();
                try {
                    tracking.offset = VastTime.parse(from.getOffset());
                } catch (VastException ignored) {
                }
                return tracking;
            }
        }
    }
}
