package com.mobiblocks.skippables;

/**
 * Created by daniel on 12/21/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class SkiSize {
    final int mWidth;
    final int mHeight;

    SkiSize(int width, int height) {
        mWidth = width;
        mHeight = height;
    }

    @SuppressWarnings("WeakerAccess")
    public int getWidth() {
        return mWidth;
    }

    @SuppressWarnings("WeakerAccess")
    public int getHeight() {
        return mHeight;
    }
}
