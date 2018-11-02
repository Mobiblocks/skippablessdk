package com.mobiblocks.skippables;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.lang.ref.WeakReference;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import static com.mobiblocks.skippables.SkiAdRequest.ERROR_INVALID_ARGUMENT;

/**
 * Created by daniel on 12/19/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

@SuppressWarnings({"unused", "WeakerAccess"})
public class SkiAdInterstitial {
    private final Context mContext;
    private final Handler mHandler;
    private String mAdUnitId;
    private SkiAdListener mAdListener;

    private boolean mLoading;
    private boolean mLoaded;
    private boolean mHasBeenUsed;
    private SkiAdInfo mAdInfo;
    private SkiVastCompressedInfo mVastInfo;
    private SkiAdRequest mRequest;

    private static final HashMap<String, WeakReference<SkiAdListener>> sListeners = new HashMap<>();

    public SkiAdInterstitial(Context context) {
        mContext = context;
        mHandler = new Handler(Looper.getMainLooper());
    }

    public void load(SkiAdRequest request) {
        if (isLoading()) {
            return;
        }

        if (!request.isTest() && (mAdUnitId == null || mAdUnitId.isEmpty())) {
            if (mAdListener != null) {
                final SkiAdListener listener = mAdListener;
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        Log.d("SKIPPABLES", "Ad unit id is empty");
                        listener.onAdFailedToLoad(ERROR_INVALID_ARGUMENT);
                    }
                });
            }

            return;
        }

        mLoading = true;
        mLoaded = false;
        mHasBeenUsed = false;

        mRequest = new SkiAdRequest(request);
        mRequest.setAdType(SkiAdRequest.AD_TYPE_INTERSTITIAL_VIDEO);
        mRequest.setAdUnitId(mAdUnitId);
        mRequest.load(mContext, new SkiAdRequestListener() {
            @Override
            public void onResponse(SkiAdRequestResponse response) {
                mLoading = false;
                if (response.hasAnyError()) {
                    if (mAdListener != null) {
                        final SkiAdListener listener = mAdListener;
                        final int errorCode = response.getErrorCode();
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                listener.onAdFailedToLoad(errorCode);
                            }
                        });
                    }

                    if (response.hasVastError()) {
                        SkiVastCompressedInfo info = response.getVastInfo();
                        if (info != null) {
                            Util.VastUrlMacros builder = Util.VastUrlMacros.builder()
                                    .setErrorCode(response.getVastErrorCode());
                            ArrayList<URL> errorTrackings = info.getErrorTrackings();
                            for (URL url : errorTrackings) {
                                final URL macrosed = builder.build(url);
                                if (macrosed != null) {
                                    SkiEventTracker.getInstance(mContext).trackEvent(new SkiEventTracker.EventBuilder() {
                                        @Override
                                        public void build(SkiEventTracker.Builder ev) {
                                            ev.url = macrosed;
                                        }
                                    });
                                }
                            }
                        }
                    }
                    return;
                }

                mLoaded = true;

                mAdInfo = response.getAdInfo();
                mVastInfo = response.getVastInfo();

                if (mAdListener != null) {
                    final SkiAdListener listener = mAdListener;
                    mHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            listener.onAdLoaded();
                        }
                    });
                }
            }
        });
    }

    public String getAdUnitId() {
        return mAdUnitId;
    }

    public void setAdUnitId(String mAdUnitId) {
        this.mAdUnitId = mAdUnitId;
    }

    public void setAdListener(SkiAdListener mAdListener) {
        this.mAdListener = mAdListener;
    }

    public boolean isLoading() {
        return mLoading;
    }

    public boolean isLoaded() {
        return mLoaded;
    }

    public boolean isBeenUsed() {
        return mHasBeenUsed;
    }

    public void show() {
        if (!isLoaded() || isBeenUsed()) {
            return;
        }

        mHasBeenUsed = true;
        mLoaded = false;

        mContext.startActivity(SkiAdInterstitialActivity.getIntent(mContext, mRequest.uid, mAdInfo, mVastInfo));

        if (mAdListener != null) {
            synchronized (sListeners) {
                sListeners.put(mRequest.uid, new WeakReference<>(mAdListener));
            }
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mAdListener.onAdOpened();
                }
            });
        }
    }

    private static void compat() {
        synchronized (sListeners) {
            Set<String> keySet = new HashSet<>(sListeners.keySet());
            for (String key :
                    keySet) {
                WeakReference<SkiAdListener> weak = sListeners.get(key);
                if (weak != null) {
                    final SkiAdListener listener = weak.get();
                    if (listener == null) {
                        sListeners.remove(key);
                    }
                }
            }
        }
    }

    static void closed(String uid) {
        synchronized (sListeners) {
            WeakReference<SkiAdListener> weak = sListeners.get(uid);
            if (weak != null) {
                final SkiAdListener listener = weak.get();
                if (listener != null) {
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            listener.onAdClosed();
                        }
                    });
                } else {
                    sListeners.remove(uid);
                }
            }
        }

        compat();
    }

    static void left(String uid) {
        synchronized (sListeners) {
            WeakReference<SkiAdListener> weak = sListeners.get(uid);
            if (weak != null) {
                final SkiAdListener listener = weak.get();
                if (listener != null) {
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            listener.onAdLeftApplication();
                        }
                    });
                } else {
                    sListeners.remove(uid);
                }
            }
        }

        compat();
    }
}
