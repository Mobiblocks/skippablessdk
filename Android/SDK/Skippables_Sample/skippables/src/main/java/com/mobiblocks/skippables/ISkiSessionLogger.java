package com.mobiblocks.skippables;

import android.content.Context;
import android.support.annotation.NonNull;

/**
 * Created by daniel on 11/19/18.
 * <p>
 * Copyright Mobiblocks 2018. All rights reserved.
 */
interface ISkiSessionLogger {

    boolean canLog();
    String getSessionID();
    ISkiSessionLogger setSessionID(String sessionID);

    ISkiSessionLogger collectInfo(@NonNull Context context);
    ISkiSessionLogger build(@NonNull SkiSessionLogger.Builder builder);
    void report();
}
