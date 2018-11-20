package com.mobiblocks.skippables.vast;

import android.os.Parcel;
import android.os.Parcelable;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.mobiblocks.skippables.BuildConfig;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;

/**
 * Created by daniel on 12/18/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

public class VastTime implements Parcelable {
    private Long time;
    private Float percents;

    private VastTime(@NonNull Float percents) {
        this.percents = percents;
    }

    private VastTime(long time) {
        this.time = time;
    }

    @SuppressWarnings("WeakerAccess")
    protected VastTime(Parcel in) {
        if (in.readByte() == 0) {
            time = null;
        } else {
            time = in.readLong();
        }
        if (in.readByte() == 0) {
            percents = null;
        } else {
            percents = in.readFloat();
        }
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        if (time == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(time);
        }
        if (percents == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeFloat(percents);
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<VastTime> CREATOR = new Creator<VastTime>() {
        @Override
        public VastTime createFromParcel(Parcel in) {
            return new VastTime(in);
        }

        @Override
        public VastTime[] newArray(int size) {
            return new VastTime[size];
        }
    };

    @Nullable
    public Long getTime() {
        return time;
    }

    protected void setTime(Long time) {
        this.time = time;
    }

    @SuppressWarnings("unused")
    @Nullable
    public Float getPercents() {
        return percents;
    }

    @SuppressWarnings("unused")
    protected void setPercents(Float percents) {
        this.percents = percents;
    }

    public int getOffset(int duration) {
        if (percents != null) {
            return Math.round(duration * (percents / 100.f));
        }

        if (time != null) {
            return Math.round(time / 1000.f);
        }

        return -1;
    }

    public String toJSONValue() {
        if (percents != null) {
            return String.format(Locale.US, "%.02f", percents);
        } else if (time != null) {
            int millis = (int) (time % 1000);
            int seconds = (int) (time / 1000) % 60 ;
            int minutes = (int) ((time / (1000 * 60)) % 60);
            int hours   = (int) (time / (1000 * 60 * 60));
            
            return String.format(Locale.US, "%02d:%02d:%02d.%03d", hours, minutes, seconds, millis);
        }
        
        return null;
    }

    @SuppressWarnings("ConstantConditions")
    public static VastTime parse(@NonNull String string) {
        if (string == null || string.isEmpty()) {
            return null;
        }

        string = string.trim();
        if (string.isEmpty()) {
            return null;
        }

        if (string.endsWith("%")) {
            string = string.substring(0, string.length() - 1);

            try {
                return new VastTime(Float.valueOf(string));
            } catch (NumberFormatException e) {
                return null;
            }
        }

        String[] components = string.split(":");
        if (components.length != 3 && components.length != 4) {
            return null;
        }

        try {
            int hours = Integer.valueOf(components[0]);
            int minutes = Integer.valueOf(components[1]);
            int seconds;
            int milliseconds;
            String secondsString = components[2];
            String[] secondsComponents = secondsString.split("\\.");
            if (secondsComponents.length == 2) {
                seconds = Integer.valueOf(secondsComponents[0]);
                milliseconds = Integer.valueOf(secondsComponents[1]);
            } else {
                seconds = Integer.valueOf(components[2]);
                milliseconds = 0;
            }

            if (BuildConfig.DEBUG) {
                if (minutes > 59) {
                    return null;
                }
                if (seconds > 59) {
                    return null;
                }
                if (milliseconds > 999) {
                    return null;
                }
            }

            long time = ((hours * (60 * 60)) + (minutes * 60) + seconds) * 1000 + milliseconds;
            return new VastTime(time);

        } catch (NumberFormatException em) {
            return null;
        }
    }
}
