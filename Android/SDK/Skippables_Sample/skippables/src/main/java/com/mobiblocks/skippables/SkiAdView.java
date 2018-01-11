package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import static com.mobiblocks.skippables.SkiAdRequest.ERROR_INVALID_ARGUMENT;

/**
 * Created by daniel on 12/13/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

public class SkiAdView extends ViewGroup {
    private String mAdUnitId;
    private SkiAdSize mAdSize = SkiAdSize.BANNER;
    private SkiAdListener mAdListener;
    private WebView mWebView;
    private boolean mLoading;

    public SkiAdView(Context context) {
        super(context);
    }

    public SkiAdView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public SkiAdView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @SuppressWarnings("unused")
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public SkiAdView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    @Override
    public void setLayoutParams(LayoutParams params) {
//        if (params != null) {
//            if (params.width == LayoutParams.WRAP_CONTENT) {
//                params.width = mAdSize.getWidthInPixels(getContext());
//            }
//
//            if (params.height == LayoutParams.WRAP_CONTENT) {
//                params.height = mAdSize.getHeightInPixels(getContext());
//            }
//        }
//        
        super.setLayoutParams(params);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        if (mWebView != null) {
            int aw = mAdSize.getWidthInPixels(getContext());
            int ah = mAdSize.getHeightInPixels(getContext());
            int wl = (getMeasuredWidth() - aw) / 2;
            int wt = (getMeasuredHeight() - ah) / 2;
            int wr = wl + aw;
            int wb = wt + ah;
            mWebView.layout(wl, wt, wr, wb);
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int measuredWidth = 0;
        int measuredHeight = 0;
        if(mWebView != null && mWebView.getVisibility() != View.GONE) {
            this.measureChild(mWebView, widthMeasureSpec, heightMeasureSpec);
            measuredWidth = mWebView.getMeasuredWidth();
            measuredHeight = mWebView.getMeasuredHeight();
        } else {
            if(mAdSize != null) {
                Context var7 = this.getContext();
                measuredWidth = mAdSize.getWidthInPixels(var7);
                measuredHeight = mAdSize.getHeightInPixels(var7);
            }
        }

        measuredWidth = Math.max(measuredWidth, this.getSuggestedMinimumWidth());
        measuredHeight = Math.max(measuredHeight, this.getSuggestedMinimumHeight());
        this.setMeasuredDimension(View.resolveSize(measuredWidth, widthMeasureSpec), View.resolveSize(measuredHeight, heightMeasureSpec));
    }

    @SuppressWarnings("unused")
    public void loadRequest(SkiAdRequest request) {
        if (isLoading()) {
            return;
        }
        
        if (mAdUnitId == null || mAdUnitId.isEmpty()) {
            throw new IllegalArgumentException("AdUnitId is empty");
        }

        mLoading = true;

        SkiAdRequest mRequest = new SkiAdRequest(request);
        mRequest.setAdSize(mAdSize);
        mRequest.setAdType(SkiAdRequest.AD_TYPE_BANNER_IMAGE);
        mRequest.setAdUnitId(mAdUnitId);
        mRequest.load(getContext(), new SkiAdRequestListener() {

            @Override
            public void onResponse(final SkiAdRequestResponse response) {
                mLoading = false;
                if (response.hasError()) {
                    if (mAdListener != null) {
                        final int errorCode = response.getErrorCode();
                        post(new Runnable() {
                            @Override
                            public void run() {
                                mAdListener.onAdFailedToLoad(errorCode);
                            }
                        });
                    }
                    return;
                }
                
                String htmlData = response.getHtmlSnippet();
                mWebView = new WebView(getContext());
                mWebView.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
                mWebView.setVerticalScrollBarEnabled(false);
                mWebView.setHorizontalScrollBarEnabled(false);
                mWebView.setOnTouchListener(new View.OnTouchListener() {
                    public boolean onTouch(View v, MotionEvent event) {
                        return (event.getAction() == MotionEvent.ACTION_MOVE);
                    }
                });
                mWebView.setWebViewClient(new WebViewClient() {
                    private boolean hitTypeIsLink(int hitType)
                    {
                        return hitType == WebView.HitTestResult.ANCHOR_TYPE
                                || hitType == WebView.HitTestResult.IMAGE_ANCHOR_TYPE
                                || hitType == WebView.HitTestResult.SRC_ANCHOR_TYPE
                                || hitType == WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE;
                    }

                    private void TryOpenAnyBrowser(Uri uri) {
                        Intent intent = new Intent(Intent.ACTION_VIEW);
                        intent.setData(uri);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        intent.setPackage("com.android.chrome");
                        try {
                            SkiAdView.this.getContext().startActivity(intent);
                        } catch (ActivityNotFoundException ignore) {
                            intent.setPackage("com.amazon.cloud9");
                            try {
                                SkiAdView.this.getContext().startActivity(intent);
                            } catch (ActivityNotFoundException ignored) {
                                intent.setPackage(null);
                                try {
                                    SkiAdView.this.getContext().startActivity(intent);
                                } catch (ActivityNotFoundException ignored1) {
                                    return;
                                }
                            }
                        }
                        
                        if (mAdListener != null) {
                            final int errorCode = response.getErrorCode();
                            post(new Runnable() {
                                @Override
                                public void run() {
                                    mAdListener.onAdLeftApplication();
                                }
                            });
                        }
                    }
                    @SuppressLint("SetJavaScriptEnabled")
                    @Override
                    public void onPageFinished(WebView view, String url) {
                        super.onPageFinished(view, url);
                        view.getSettings().setJavaScriptEnabled(true);
//                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
//                            view.evaluateJavascript("document.body.style.margin='0';document.body.style.padding='0';", null);
//                        } else {
                            view.loadUrl("javascript:(function() {document.body.style.margin='0';document.body.style.padding='0';})();");
//                        }
                        view.getSettings().setJavaScriptEnabled(false);
                        view.setVisibility(VISIBLE);
                    }

                    @Override
                    public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                        super.onReceivedError(view, request, error);
                        post(new Runnable() {
                            @Override
                            public void run() {
                                mAdListener.onAdFailedToLoad(ERROR_INVALID_ARGUMENT);
                            }
                        });
                    }

                    @Override
                    public boolean shouldOverrideUrlLoading(WebView view, String url) {
                        WebView.HitTestResult hr = view.getHitTestResult();
                        int hitType = hr != null ? hr.getType() : WebView.HitTestResult.UNKNOWN_TYPE;
                        if (hitTypeIsLink(hitType)) {
                            TryOpenAnyBrowser(Uri.parse(url));
                            return true;
                        } else {
                            if (hitType == WebView.HitTestResult.EMAIL_TYPE ||
                                    hitType == WebView.HitTestResult.GEO_TYPE ||
                                    hitType == WebView.HitTestResult.PHONE_TYPE) {
                                TryOpenAnyBrowser(Uri.parse(url));
                                return true;
                            }
                        }
                        
                        return super.shouldOverrideUrlLoading(view, url);
                    }

//                    @Override
//                    public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
//                        
//                    }
                });
                mWebView.loadData(htmlData, "text/html", "utf8");
                mWebView.setVisibility(INVISIBLE);
                SkiAdView.this.addView(mWebView, new ViewGroup.LayoutParams(mAdSize.getWidthInPixels(getContext()), mAdSize.getHeightInPixels(getContext())));

                if (mAdListener != null) {
                    post(new Runnable() {
                        @Override
                        public void run() {
                            mAdListener.onAdLoaded();
                        }
                    });
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public String getAdUnitId() {
        return mAdUnitId;
    }

    @SuppressWarnings("unused")
    public void setAdUnitId(String adUnitId) {
        mAdUnitId = adUnitId;
    }

    @SuppressWarnings("unused")
    public void setAdListener(SkiAdListener adListener) {
        this.mAdListener = adListener;
    }

    @SuppressWarnings("unused")
    public SkiAdSize getAdSize() {
        return mAdSize;
    }

    @SuppressWarnings("unused")
    public void setAdSize(SkiAdSize mAdSize) {
        this.mAdSize = mAdSize;
        if (mAdSize != null) {
            setMinimumWidth(mAdSize.getWidthInPixels(getContext()));
            setMinimumHeight(mAdSize.getHeightInPixels(getContext()));
        } else {
            setMinimumWidth(0);
            setMinimumHeight(0);
        }
        
        requestLayout();
//        LayoutParams params = getLayoutParams();
//        if (params != null) {
//            if (params.width == LayoutParams.WRAP_CONTENT) {
//                params.width = mAdSize.getWidthInPixels(getContext());
//            }
//
//            if (params.height == LayoutParams.WRAP_CONTENT) {
//                params.height = mAdSize.getHeightInPixels(getContext());
//            }
//
//            super.setLayoutParams(params);
//        }
    }

    public boolean isLoading() {
        return mLoading;
    }
}
