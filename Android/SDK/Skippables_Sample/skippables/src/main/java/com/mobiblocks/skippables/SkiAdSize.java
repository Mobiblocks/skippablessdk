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
    public static final SkiAdSize LARGE_BANNER = new SkiAdSize(320, 100);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize FULL_BANNER = new SkiAdSize(468, 60);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize MEDIUM_RECTANGLE = new SkiAdSize(300, 250);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize LEADERBOARD = new SkiAdSize(728, 90);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize LARGE_LEADERBOARD = new SkiAdSize(970, 90);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize SKYSCRAPER = new SkiAdSize(120, 600);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize WIDE_SKYSCRAPER = new SkiAdSize(160, 600);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize HALF_PAGE = new SkiAdSize(300, 600);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize PORTRAIT = new SkiAdSize(300, 1050);
    @SuppressWarnings("WeakerAccess")
    public static final SkiAdSize BILLBOARD = new SkiAdSize(970, 250);

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
