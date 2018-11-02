package com.mobiblocks.skippables;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by daniel on 2/8/18.
 * <p>
 * Copyright Mobiblocks 2018. All rights reserved.
 */

class SkiAdInfo implements Parcelable {
    private String adId;
    private String adUnitId;
    private String deviceInfoJsonString;
    private String sessionID;
    
    SkiAdInfo() {
        
    }

    @SuppressWarnings("WeakerAccess")
    protected SkiAdInfo(Parcel in) {
        adId = in.readString();
        adUnitId = in.readString();
        deviceInfoJsonString = in.readString();
        sessionID = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(adId);
        dest.writeString(adUnitId);
        dest.writeString(deviceInfoJsonString);
        dest.writeString(sessionID);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<SkiAdInfo> CREATOR = new Creator<SkiAdInfo>() {
        @Override
        public SkiAdInfo createFromParcel(Parcel in) {
            return new SkiAdInfo(in);
        }

        @Override
        public SkiAdInfo[] newArray(int size) {
            return new SkiAdInfo[size];
        }
    };

    String getAdId() {
        return adId;
    }

    SkiAdInfo setAdId(String adId) {
        this.adId = adId;
        
        return this;
    }

    String getAdUnitId() {
        return adUnitId;
    }

    SkiAdInfo setAdUnitId(String adUnitId) {
        this.adUnitId = adUnitId;

        return this;
    }

    String getDeviceInfoJsonString() {
        return deviceInfoJsonString;
    }

    SkiAdInfo setDeviceInfoJsonString(String deviceInfoJsonString) {
        this.deviceInfoJsonString = deviceInfoJsonString;

        return this;
    }

    String getSessionID() {
        return sessionID;
    }

    void setSessionID(String sessionID) {
        this.sessionID = sessionID;
    }
}
