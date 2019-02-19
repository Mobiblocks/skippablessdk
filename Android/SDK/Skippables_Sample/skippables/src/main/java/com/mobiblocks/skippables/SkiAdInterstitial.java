package com.mobiblocks.skippables;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
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
    private SkiCompactVast mVastInfo;
    private SkiAdRequest mRequest;
    private ISkiSessionLogger sessionLogger;

    private static final HashMap<String, WeakReference<SkiAdListener>> sListeners = new HashMap<>();
    private @SkiAdRequestResponse.InterstitialType int mInterstitialType;

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
        
        if (sessionLogger != null) {
            sessionLogger.report();
            sessionLogger = null;
        }

        mLoading = true;
        mLoaded = false;
        mHasBeenUsed = false;

        mRequest = new SkiAdRequest(request);
        mRequest.setAdType(SkiAdRequest.AD_TYPE_INTERSTITIAL);
        mRequest.setAdUnitId(mAdUnitId);
        mRequest.load(mContext, new SkiAdRequestListener() {
            @Override
            public void onResponse(SkiAdRequestResponse response) {
                sessionLogger = SkiSessionLogger.getLogger(response.getAdInfo().getSessionID());
                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adInterstitial.response";
                    }
                });
                
                mLoading = false;
                if (response.hasAnyError()) {
                    sessionLogger.build(new SkiSessionLogger.Builder() {
                        @Override
                        public void build(@NonNull SkiSessionLogger.Log log) {
                            log.identifier = "adInterstitial.response.error";
                            log.desc = "Report to user.";
                            log.info = SkiSessionLogger.Log.info()
                                    .put("method", "SkiAdListener.onAdFailedToLoad(int)")
                                    .put("listenerIsSet", mAdListener != null)
                                    .get();
                        }
                    });
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
                        SkiCompactVast compactVast = response.getVastInfo();
                        if (compactVast != null) {
                            Util.VastUrlMacros builder = Util.VastUrlMacros.builder()
                                    .setErrorCode(response.getVastErrorCode());
                            ArrayList<URL> errorTrackings = compactVast.getErrors();
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
                    sessionLogger.report();
                    return;
                }

                mLoaded = true;

                mAdInfo = response.getAdInfo();
                mVastInfo = response.getVastInfo();
                mInterstitialType = response.interstitialType;
                
                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adInterstitial.response.success";
                        log.desc = "Report to user.";
                        log.info = SkiSessionLogger.Log.info()
                                .put("method", "SkiAdListener.onAdLoaded()")
                                .put("listenerIsSet", mAdListener != null)
                                .get();
                    }
                });

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
        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adInterstitial.present";
            }
        });
        
        if (!isLoaded() || isBeenUsed()) {
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adInterstitial.present.error";
                    log.info = SkiSessionLogger.Log.info()
                            .put("isReady", isLoaded())
                            .put("isLoading", isLoading())
                            .put("hasBeenUsed", isBeenUsed())
                            .get();
                }
            });
            return;
        }

        mHasBeenUsed = true;
        mLoaded = false;
        
        if (mInterstitialType == SkiAdRequestResponse.AD_INTERSTITIAL_TYPE_HTML) {
            mContext.startActivity(SkiAdInterstitialHtmlActivity.getIntent(mContext, mRequest.uid, mAdInfo));
        } else {
            mContext.startActivity(SkiAdInterstitialVideoActivity.getIntent(mContext, mRequest.uid, mAdInfo, mVastInfo));
        }
        
        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adInterstitial.present.success";
                log.desc = "Report to user.";
                log.info = SkiSessionLogger.Log.info()
                        .put("method", "SkiAdListener.onAdOpened()")
                        .put("listenerIsSet", mAdListener != null)
                        .get();
            }
        });

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

    static boolean closed(String uid) {
        if (uid == null) {
            Log.d("tag", "message");
            return false;
        }
        
        boolean ret = false;
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
                    ret = true;
                } else {
                    sListeners.remove(uid);
                }
            }
        }

        compat();
        
        return ret;
    }

    static boolean left(String uid) {
        if (uid == null) {
            Log.d("tag", "message");
            return false;
        }
        
        boolean ret = false;
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
                    ret = true;
                } else {
                    sListeners.remove(uid);
                }
            }
        }

        compat();
        
        return ret;
    }
}
