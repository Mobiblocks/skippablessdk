package com.mobiblocks.skippables;

import android.content.Context;

/**
 * Created by daniel on 12/21/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

@SuppressWarnings("unused")
public class Skippables {
    public static final String version = "1.0.7";
    
    public static void initialize(Context applicationContext) {
        SkiEventTracker.initialize(applicationContext);
    }
}
