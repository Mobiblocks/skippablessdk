package com.mobiblocks.skippables;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

public abstract class SkiAdListener {
    public SkiAdListener() {
    }

    public void onAdClosed() {
    }

    public void onAdFailedToLoad(@SkiAdRequest.AdError int errorCode) {
    }

    public void onAdLeftApplication() {
    }

    public void onAdOpened() {
    }

    public void onAdLoaded() {
    }
}
