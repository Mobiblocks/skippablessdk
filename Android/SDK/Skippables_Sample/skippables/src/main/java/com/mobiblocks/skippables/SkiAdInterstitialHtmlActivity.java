package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.RenderProcessGoneDetail;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.net.URL;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import static android.view.View.VISIBLE;

public class SkiAdInterstitialHtmlActivity extends Activity {

    private static final String EXTRA_UID = "EXTRA_UID";
    private static final String EXTRA_AD_INFO = "EXTRA_AD_INFO";

    static Intent getIntent(@SuppressWarnings("NullableProblems") @NonNull Context context, @NonNull String uid, @NonNull SkiAdInfo adInfo) {
        Intent intent = new Intent(context, SkiAdInterstitialHtmlActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(SkiAdInterstitialHtmlActivity.EXTRA_UID, uid);
        intent.putExtra(SkiAdInterstitialHtmlActivity.EXTRA_AD_INFO, adInfo);

        return intent;
    }

    static String getUid(Intent intent) {
        return intent.getStringExtra(EXTRA_UID);
    }
    
    static SkiAdInfo getAdInfo(Intent intent) {
        return intent.getParcelableExtra(EXTRA_AD_INFO);
    }


    @NonNull
    private SkiAdErrorCollector errorCollector = new SkiAdErrorCollector();
    @NonNull
    private ISkiSessionLogger sessionLogger = SkiSessionLogger.createNop();
    
    private TextView mSkipView;
    private TextView mReportView;
    private WebView mWebView;
    private boolean mIsLoaded;
    @SuppressWarnings("FieldCanBeLocal")
    private SkiAdReportActivity.SkiAdReportListener mReportListener;
    
    private boolean impressionSent = false;
    private int mSkipSeconds = 5;
    private Timer myTimer;
    private Runnable mTimerTick = new Runnable() {
        @Override
        public void run() {
            mSkipSeconds -= 1;
            if (mSkipSeconds <= 0) {
                maybeUnscheduleTicker();
            }
            
            updateSkipView(false);
        }
    };
    
    private void maybeScheduleTicker() {
        if (mSkipSeconds <= 0 || myTimer != null) {
            return;
        }

        myTimer = new Timer();
        myTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                runOnUiThread(mTimerTick);
            }

        }, 0, 1000);
    }

    private void maybeUnscheduleTicker() {
        if (myTimer == null) {
            return;
        }

        myTimer.cancel();
        myTimer.purge();
        myTimer = null;
    }

    private void updateSkipView(boolean b) {
        if (mSkipSeconds <= 0) {
            mReportView.setVisibility(View.VISIBLE);
            mSkipView.setVisibility(View.VISIBLE);
            mSkipView.setText(R.string.skippables_interstitial_skip);
            mSkipView.setTextColor(Color.WHITE);
            mSkipView.setEnabled(true);
        } else {
            mSkipView.setVisibility(View.VISIBLE);
            mSkipView.setTextColor(Color.rgb(153, 153, 153));
            mSkipView.setEnabled(false);
            int remaining = mSkipSeconds;
            if (remaining < 60.) {
                mSkipView.setText(String.format(getString(R.string.skippables_interstitial_skip_in_short), remaining % 60));
            } else {
                mSkipView.setText(String.format(getString(R.string.skippables_interstitial_skip_in_long), (remaining / 60) % 60, remaining % 60));
            }
        }
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String sessionID = null;
        final SkiAdInfo adInfo = getAdInfo(getIntent());
        if (adInfo != null) {
            sessionID = adInfo.getSessionID();
            errorCollector.setSessionID(sessionID);
            if (sessionID != null) {
                sessionLogger = SkiSessionLogger.getLogger(sessionID);
            }
        }

        //noinspection ConstantConditions
        if (sessionLogger == null) {
            sessionLogger = SkiSessionLogger.getLogger(sessionID).collectInfo(this);
        }

        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adInterstitialHtmlView.onCreate";
                log.info = SkiSessionLogger.Log.info()
                        .put("adInfoIsSet", adInfo != null)
                        .get();
            }
        });
        if (adInfo == null) {
            errorCollector.collect(new SkiAdErrorCollector.ErrorCollector() {
                @Override
                public void build(SkiAdErrorCollector.Builder err) {
                    err.type = SkiAdErrorCollector.TYPE_PLAYER;
                    err.place = "SkiAdInterstitialHtmlActivity.onCreate";
                    err.desc = "Activity created with invalid ad info.";
                }
            });
            finishInterstitial(false);
            return;
        }

        LinearLayout ll = new LinearLayout(this);
        ll.setOrientation(LinearLayout.VERTICAL);

        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adInterstitialHtmlView.prepareWebView";
            }
        });

        mWebView = new WebView(this);
        mWebView.getSettings().setJavaScriptEnabled(true);
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

                final Uri finalUri = uri;
                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adInterstitialHtmlView.openClick";
                        log.info = SkiSessionLogger.Log.info()
                                .put("url", finalUri.toString())
                                .put("clickUrl", adInfo.getClickUrl())
                                .get();
                                
                    }
                });
                
                if (adInfo.getClickUrl() != null) {
                    Uri override = Uri.parse(adInfo.getClickUrl());
                    if (override != null) {
                        uri = override;
                    }
                }

                touchStamp = System.currentTimeMillis();

                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(uri);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.setPackage("com.android.chrome");
                try {
                    SkiAdInterstitialHtmlActivity.this.startActivity(intent);
                } catch (ActivityNotFoundException ignore) {
                    intent.setPackage("com.amazon.cloud9");
                    try {
                        SkiAdInterstitialHtmlActivity.this.startActivity(intent);
                    } catch (ActivityNotFoundException ignored) {
                        intent.setPackage(null);
                        try {
                            SkiAdInterstitialHtmlActivity.this.startActivity(intent);
                        } catch (ActivityNotFoundException ignored1) {
                            return;
                        }
                    }
                }

                SkiAdInterstitialHtmlActivity.this.finishInterstitial(true);
            }

            @SuppressLint("SetJavaScriptEnabled")
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
//                view.getSettings().setJavaScriptEnabled(true);
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
//                    view.evaluateJavascript("document.body.style.margin='0';document.body.style.padding='0';", null);
//                } else {
//                    view.loadUrl("javascript:(function() {document.body.style.margin='0';document.body.style.padding='0';})();");
//                }
//                view.getSettings().setJavaScriptEnabled(false);
                view.setVisibility(VISIBLE);
//                if (mReportView != null) {
//                    mReportView.setVisibility(VISIBLE);
//                }

                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adInterstitialHtmlView.prepareWebView.onPageFinished";
                    }
                });

                if (impressionSent == false && adInfo.getImpressionUrl() != null) {
                    impressionSent = true;
                    
                    try {
                        final URL impUrl = new URL(adInfo.getImpressionUrl());
                        final String identifier = UUID.randomUUID().toString();
                        SkiEventTracker.getInstance(SkiAdInterstitialHtmlActivity.this).trackEvent(new SkiEventTracker.EventBuilder() {
                            @Override
                            public void build(SkiEventTracker.Builder ev) {
                                ev.url = impUrl;
                                ev.identifier = identifier;
                                ev.sessionID = errorCollector.getSessionID();
                                ev.logError = true;
                                ev.logSession = sessionLogger.canLog();
                            }
                        });
                    } catch (final Exception ex) {
                        sessionLogger.build(new SkiSessionLogger.Builder() {
                            @Override
                            public void build(@NonNull SkiSessionLogger.Log log) {
                                log.identifier = "adInterstitialHtmlView.impression.error";
                                log.exception = ex;
                                log.info = SkiSessionLogger.Log.info()
                                        .put("impressionUr", adInfo.getImpressionUrl())
                                        .get();
                            }
                        });
                    }
                }

                mIsLoaded = true;
                maybeScheduleTicker();
            }

            @Override
            public void onReceivedError(WebView view, final int errorCode, final String description, final String failingUrl) {
                super.onReceivedError(view, errorCode, description, failingUrl);
                mWebView = null;
                mReportView = null;

                SkiAdInterstitialHtmlActivity.this.finishInterstitial(false);

                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adInterstitialHtmlView.prepareWebView.onReceivedError";
                        log.info = SkiSessionLogger.Log.info()
                                .put("code", errorCode)
                                .put("failingUrl", failingUrl )
                                .put("description", description )
                                .get();
                    }
                });
                maybeScheduleTicker();
            }

            @TargetApi(Build.VERSION_CODES.M)
            @Override
            public void onReceivedError(WebView view, final WebResourceRequest request, final WebResourceError error) {
                super.onReceivedError(view, request, error);

                mWebView = null;
                mReportView = null;

                SkiAdInterstitialHtmlActivity.this.finishInterstitial(false);

                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adInterstitialHtmlView.prepareWebView.onReceivedError";
                        log.info = SkiSessionLogger.Log.info()
                                .put("code", error.getErrorCode())
                                .put("failingUrl", request.getUrl().toString() )
                                .put("description", error.getDescription() )
                                .get();
                    }
                });
            }

            @Override
            public boolean onRenderProcessGone(WebView view, RenderProcessGoneDetail detail) {
                mWebView = null;
                mReportView = null;

                SkiAdInterstitialHtmlActivity.this.finishInterstitial(false);

                sessionLogger.build(new SkiSessionLogger.Builder() {
                    @Override
                    public void build(@NonNull SkiSessionLogger.Log log) {
                        log.identifier = "adInterstitialHtmlView.prepareWebView.onRenderProcessGone";
                    }
                });

                return true;
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

                return false;
            }

            @TargetApi(Build.VERSION_CODES.LOLLIPOP)
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                String url = request.getUrl().toString();
                
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

                return false;
            }
        });

        LinearLayout.LayoutParams lpw = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        lpw.weight = 1;
        ll.addView(mWebView, lpw);

        RelativeLayout rl = new RelativeLayout(this);
        rl.setMinimumHeight(px(24));

        RelativeLayout.LayoutParams reportViewViewLayoutParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        reportViewViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        reportViewViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);

        mReportView = new TextView(this);
        mReportView.setVisibility(View.INVISIBLE);
        mReportView.setLayoutParams(reportViewViewLayoutParams);
        mReportView.setText(R.string.skippables_interstitial_report);
        mReportView.setTextSize(13);
        mReportView.setTextColor(Color.rgb(70, 130, 180));
        mReportView.setBackgroundColor(Color.argb(178, 51, 51, 51));
        int plr = px(5);
        int ptb = px(2);
        mReportView.setPadding(plr, ptb, plr, ptb);
        mReportView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SkiAdReportActivity.show(SkiAdInterstitialHtmlActivity.this, createReportListener(adInfo));
            }
        });
        
        rl.addView(mReportView);

        RelativeLayout.LayoutParams skipoffsetViewLayoutParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        skipoffsetViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
//        reportViewViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);

        mSkipView = new TextView(this);
        mSkipView.setMinWidth(px(70));
        mSkipView.setLayoutParams(skipoffsetViewLayoutParams);
        mSkipView.setPadding(px(5), px(5), px(5), px(5));
        mSkipView.setBackgroundColor(Color.argb(178, 51, 51, 51));
        mSkipView.setTextColor(Color.WHITE);
        mSkipView.setText(R.string.skippables_interstitial_skip);
        mSkipView.setEnabled(false);
//        mSkipView.setVisibility(View.GONE);

        mSkipView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                sendSkipEvents();
                finishInterstitial(false);
            }
        });

        rl.addView(mSkipView);

        LinearLayout.LayoutParams lpr = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        rl.setLayoutParams(lpr);
        
        ll.addView(rl);

        if (adInfo.getHtmlSnippetBaseUrl() != null) {
            mWebView.loadDataWithBaseURL(adInfo.getHtmlSnippetBaseUrl(), adInfo.getHtmlSnippet(), "text/html", "utf8", null);
        } else {
            mWebView.loadData(adInfo.getHtmlSnippet(), "text/html", "utf8");
        }

        setContentView(ll, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    }

    private SkiAdReportActivity.SkiAdReportListener createReportListener(final SkiAdInfo adInfo) {
        mReportListener = new SkiAdReportActivity.SkiAdReportListener() {
            @Override
            public void onResult(boolean canceled, Intent data) {
                if (!canceled) {
                    String email = SkiAdReportActivity.getEmail(data);
                    String feedback = SkiAdReportActivity.getFeedback(data);

                    SkiEventTracker.getInstance(SkiAdInterstitialHtmlActivity.this)
                            .trackInfringementReport(
                                    SkiEventTracker.infringementReport(adInfo)
                                            .setEmail(email)
                                            .setMessage(feedback));

                    finishInterstitial(true);
                }
            }
        };

        return mReportListener;
    }

    private void finishInterstitial(boolean left) {
        this.finish();

        final boolean reported = SkiAdInterstitial.closed(getUid(getIntent()));
        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adInterstitialHtmlView.close";
                log.desc = "Report to user.";
                log.info = SkiSessionLogger.Log.info()
                        .put("method", "SkiAdListener.onAdClosed()")
                        .put("listenerIsSet", reported)
                        .get();
            }
        });

        if (left) {
            final boolean reported2 = SkiAdInterstitial.left(getUid(getIntent()));
            sessionLogger.build(new SkiSessionLogger.Builder() {
                @Override
                public void build(@NonNull SkiSessionLogger.Log log) {
                    log.identifier = "adInterstitialHtmlView.left";
                    log.desc = "Report to user.";
                    log.info = SkiSessionLogger.Log.info()
                            .put("method", "SkiAdListener.onAdLeftApplication()")
                            .put("listenerIsSet", reported2)
                            .get();
                }
            });
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        
        if (mIsLoaded) {
            maybeScheduleTicker();
        }

        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adInterstitialHtmlView.onResume";
            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();
        
        maybeUnscheduleTicker();

        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adInterstitialHtmlView.onPause";
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        
        maybeUnscheduleTicker();

        sessionLogger.build(new SkiSessionLogger.Builder() {
            @Override
            public void build(@NonNull SkiSessionLogger.Log log) {
                log.identifier = "adInterstitialHtmlView.onDestroy";
            }
        });
    }

    @Override
    public void onBackPressed() {
        if (mSkipSeconds <= 0) {
            super.onBackPressed();
        }
    }

    private int px(float dp) {
        Resources r = getResources();
        return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, r.getDisplayMetrics()));
    }
}
