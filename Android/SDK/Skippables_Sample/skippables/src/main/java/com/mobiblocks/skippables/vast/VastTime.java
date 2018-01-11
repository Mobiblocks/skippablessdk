package com.mobiblocks.skippables.vast;

import android.os.Parcel;
import android.os.Parcelable;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.mobiblocks.skippables.BuildConfig;

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

    @SuppressWarnings("ConstantConditions")
    public static VastTime parse(@NonNull String string) throws VastException {
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
                throw new VastException(VastError.VAST_UNDEFINED_ERROR_CODE);
            }
        }

        String[] components = string.split(":");
        if (components.length != 3 && components.length != 4) {
            throw new VastException(VastError.VAST_UNDEFINED_ERROR_CODE);
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
                    throw new VastException(VastError.VAST_UNDEFINED_ERROR_CODE);
                }
                if (seconds > 59) {
                    throw new VastException(VastError.VAST_UNDEFINED_ERROR_CODE);
                }
                if (milliseconds > 999) {
                    throw new VastException(VastError.VAST_UNDEFINED_ERROR_CODE);
                }
            }

            long time = ((hours * (60 * 60)) + (minutes * 60) + seconds) * 1000 + milliseconds;
            return new VastTime(time);

        } catch (NumberFormatException em) {
            throw new VastException(VastError.VAST_UNDEFINED_ERROR_CODE, em);
        }
    }
}
