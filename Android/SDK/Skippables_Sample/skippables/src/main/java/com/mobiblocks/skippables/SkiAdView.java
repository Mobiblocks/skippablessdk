package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

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
    private TextView mReportView;
    private boolean mLoading;
    @SuppressWarnings("FieldCanBeLocal")
    private SkiAdReportActivity.SkiAdReportListener mReportListener;

    public SkiAdView(Context context) {
        super(context);
        setClipChildren(true);
    }

    public SkiAdView(Context context, AttributeSet attrs) {
        super(context, attrs);
        setClipChildren(true);
    }

    public SkiAdView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setClipChildren(true);
    }

    @SuppressWarnings("unused")
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public SkiAdView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        setClipChildren(true);
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
        int aw = mAdSize.getWidthInPixels(getContext());
        int ah = mAdSize.getHeightInPixels(getContext());
        int wl = (getMeasuredWidth() - aw) / 2;
        int wt = (getMeasuredHeight() - ah) / 2;
        if (mWebView != null) {
            int wr = wl + aw;
            int wb = wt + ah;
            mWebView.layout(wl, wt, wr, wb);
        }
        
        if (mReportView != null) {
            int rl = wl;
            int rt = wt;
            int rw = mReportView.getMeasuredWidth();
            int rh = mReportView.getMeasuredHeight();
            mReportView.layout(rl, rt, rl + rw, rt + rh);
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int measuredWidth = 0;
        int measuredHeight = 0;
        if (mWebView != null && mWebView.getVisibility() != View.GONE) {
            this.measureChild(mWebView, widthMeasureSpec, heightMeasureSpec);
            measuredWidth = mWebView.getMeasuredWidth();
            measuredHeight = mWebView.getMeasuredHeight();
        } else {
            if (mAdSize != null) {
                Context context = this.getContext();
                measuredWidth = mAdSize.getWidthInPixels(context);
                measuredHeight = mAdSize.getHeightInPixels(context);
            }
        }

        measuredWidth = Math.max(measuredWidth, this.getSuggestedMinimumWidth());
        measuredHeight = Math.max(measuredHeight, this.getSuggestedMinimumHeight());
        this.setMeasuredDimension(View.resolveSize(measuredWidth, widthMeasureSpec), View.resolveSize(measuredHeight, heightMeasureSpec));

        if (mReportView != null) {
            int childWidthMeasureSpec = MeasureSpec.makeMeasureSpec(measuredWidth, MeasureSpec.AT_MOST);
            int childHeightMeasureSpec = MeasureSpec.makeMeasureSpec(measuredHeight, MeasureSpec.AT_MOST);
            mReportView.measure(childWidthMeasureSpec, childHeightMeasureSpec);
        }
    }

    @SuppressWarnings("unused")
    public void load(SkiAdRequest request) {
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

            @SuppressLint("ClickableViewAccessibility")
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
                    private long touchStamp = 0;
                    private boolean hitTypeIsLink(int hitType) {
                        return hitType == WebView.HitTestResult.ANCHOR_TYPE
                                || hitType == WebView.HitTestResult.IMAGE_ANCHOR_TYPE
                                || hitType == WebView.HitTestResult.SRC_ANCHOR_TYPE
                                || hitType == WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE;
                    }

                    private void tryOpenAnyBrowser(Uri uri) {
                        if (System.currentTimeMillis() - touchStamp < 2000) {
                            return;
                        }
                        touchStamp = System.currentTimeMillis();
                        
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
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                            view.evaluateJavascript("document.body.style.margin='0';document.body.style.padding='0';", null);
                        } else {
                            view.loadUrl("javascript:(function() {document.body.style.margin='0';document.body.style.padding='0';})();");
                        }
                        view.getSettings().setJavaScriptEnabled(false);
                        view.setVisibility(VISIBLE);
                        if (mReportView != null) {
                            mReportView.setVisibility(VISIBLE);
                        }
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
                            tryOpenAnyBrowser(Uri.parse(url));
                            return true;
                        } else {
                            if (hitType == WebView.HitTestResult.EMAIL_TYPE ||
                                    hitType == WebView.HitTestResult.GEO_TYPE ||
                                    hitType == WebView.HitTestResult.PHONE_TYPE) {
                                tryOpenAnyBrowser(Uri.parse(url));
                                return true;
                            }
                        }

                        return true;//super.shouldOverrideUrlLoading(view, url);
                    }

//                    @Override
//                    public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
//                        
//                    }
                });
                mWebView.loadData(htmlData, "text/html", "utf8");
                mWebView.setVisibility(INVISIBLE);
                SkiAdView.this.addView(mWebView, new ViewGroup.LayoutParams(mAdSize.getWidthInPixels(getContext()), mAdSize.getHeightInPixels(getContext())));

                if (response.getAdInfo() != null) {
                    mReportView = new TextView(getContext());
                    mReportView.setVisibility(INVISIBLE);
                    mReportView.setText(R.string.skippables_ad_report);
                    mReportView.setTextSize(11);
                    mReportView.setTextColor(Color.rgb(70, 130, 180));
                    mReportView.setBackgroundColor(Color.argb(178, 51, 51, 51));
                    int plr = px(0);
                    int ptb = px(0);
                    mReportView.setPadding(plr, ptb, plr, ptb);
                    mReportView.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            SkiAdReportActivity.show(getContext(), createReportListener(response));
                        }
                    });

                    SkiAdView.this.addView(mReportView, new ViewGroup.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
                }

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

    private SkiAdReportActivity.SkiAdReportListener createReportListener(final SkiAdRequestResponse response) {
        mReportListener = new SkiAdReportActivity.SkiAdReportListener() {
            @Override
            public void onResult(boolean canceled, Intent data) {
                if (canceled) {
                    return;
                }

                String email = SkiAdReportActivity.getEmail(data);
                String feedback = SkiAdReportActivity.getFeedback(data);

                SkiEventTracker.getInstance(getContext())
                        .trackInfringementReport(
                                SkiEventTracker.infringementReport(response)
                                        .setEmail(email)
                                        .setMessage(feedback));

                post(new Runnable() {
                    @Override
                    public void run() {
                        if (mAdListener != null) {
                            mAdListener.onAdFailedToLoad(SkiAdRequest.ERROR_NO_FILL);
                        }

                        mWebView = null;
                        mReportView = null;
                        removeAllViews();
                    }
                });
            }
        };
        
        return mReportListener;
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

    private int px(float dp) {
        Resources r = getResources();
        return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, r.getDisplayMetrics()));
    }

    public boolean isLoading() {
        return mLoading;
    }
}
