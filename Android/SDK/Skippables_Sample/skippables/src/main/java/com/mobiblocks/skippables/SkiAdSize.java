package com.mobiblocks.skippables;

import android.content.Context;
import android.util.TypedValue;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

@SuppressWarnings("unused")
public final class SkiAdSize extends SkiSize {
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize BANNER = new SkiAdSize(320, 50);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize MEDIUM_RECTANGLE = new SkiAdSize(320, 100);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize HALF_PAGE = new SkiAdSize(320, 480);

    private SkiAdSize(int width, int height) {
        super(width, height);
    }

    @SuppressWarnings("WeakerAccess")
    public int getWidthInPixels(Context context) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, mWidth, context.getResources().getDisplayMetrics());
    }

    @SuppressWarnings("WeakerAccess")
    public int getHeightInPixels(Context context) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, mHeight, context.getResources().getDisplayMetrics());
    }
}
