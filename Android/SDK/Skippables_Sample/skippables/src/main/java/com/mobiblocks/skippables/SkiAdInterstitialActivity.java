package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.VideoView;

import com.mobiblocks.skippables.vast.VastError;
import com.mobiblocks.skippables.vast.VastTime;

import java.io.File;
import java.net.URL;
import java.util.ArrayList;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

public class SkiAdInterstitialActivity extends Activity {

    private static final String EXTRA_UID = "EXTRA_UID";
    private static final String EXTRA_AD_INFO = "EXTRA_AD_INFO";
    private static final String EXTRA_VAST_INFO = "EXTRA_VAST_INFO";

    private SkiVastCompressedInfo mVastInfo;
    private TextView mSkipView;
    private TextView mCloseView;
    private TextView mReportView;
    private Timer myTimer;
    private Runnable mTimerTick = new Runnable() {
        @Override
        public void run() {
            updateCloseView(false);
            updateSkipView(false);
            sendTimedEvents();
        }
    };

    private boolean mIsReady;
    private boolean mCompleted;

    private boolean mShownOnce;

    private boolean mStateSaved;

    static Intent getIntent(@NonNull Context context, @NonNull String uid, @NonNull SkiAdInfo adInfo, @NonNull SkiVastCompressedInfo vastInfo) {
        Intent intent = new Intent(context, SkiAdInterstitialActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(SkiAdInterstitialActivity.EXTRA_UID, uid);
        intent.putExtra(SkiAdInterstitialActivity.EXTRA_AD_INFO, adInfo);
        intent.putExtra(SkiAdInterstitialActivity.EXTRA_VAST_INFO, vastInfo);

        return intent;
    }

    static SkiVastCompressedInfo getVastInfo(Intent intent) {
        return intent.getParcelableExtra(EXTRA_VAST_INFO);
    }

    static SkiAdInfo getAdInfo(Intent intent) {
        return intent.getParcelableExtra(EXTRA_AD_INFO);
    }

    static String getUid(Intent intent) {
        return intent.getStringExtra(EXTRA_UID);
    }

    private RelativeLayout mRelativeLayout;
    private InterstitialVideoView mVideoView;

    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mVastInfo = getVastInfo(getIntent());
        if (mVastInfo == null) {
            finishInterstitial(false);
            return;
        }

        if (mVastInfo.isMaybeShownInLandscape()) {
            int orientation = getScreenOrientation(this);
            switch (orientation) {
                case ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE:
                case ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE: {
                    setRequestedOrientation(orientation);
                    break;
                }
                default: {
                    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                }
            }
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }

        mRelativeLayout = new RelativeLayout(this);
        mRelativeLayout.setLayoutParams(new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));

        RelativeLayout.LayoutParams videoViewLayoutParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        videoViewLayoutParams.addRule(RelativeLayout.CENTER_IN_PARENT);
        videoViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
//        videoViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        videoViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
//        videoViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);

        mVideoView = new InterstitialVideoView(this);
//        mVideoView.setClickable(true);
        mVideoView.setLayoutParams(videoViewLayoutParams);
        mVideoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                mIsReady = true;
                maybeScheduleTicker();
            }
        });
        mVideoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                maybeUnscheduleTicker();
                updateCloseView(true);
                updateSkipView(true);
                mIsReady = false;
                mCompleted = true;
                sendCompleteEvents();
            }
        });
        mVideoView.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
                sendErrorEvents();
                finishInterstitial(false);
                return true;
            }
        });

        String local = mVastInfo.getLocalMediaFile();
        if (local != null) {
            mVideoView.setVideoPath(local);
        } else {
            SkiVastCompressedInfo.MediaFile mediaFile = mVastInfo.findBestMediaFile(this);
            if (mediaFile != null) {
                mVideoView.setVideoURI(Uri.parse(mediaFile.getValue().toString()));
            }
        }
        final float point[] = new float[]{0, 0};
        mVideoView.setOnTouchListener(new View.OnTouchListener() {
            private boolean isAClick(float startX, float endX, float startY, float endY) {
                float differenceX = Math.abs(startX - endX);
                float differenceY = Math.abs(startY - endY);
                return !(differenceX > 50 || differenceY > 50);
            }
            
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        point[0] = event.getX();
                        point[1] = event.getY();
                        return true;
                    case MotionEvent.ACTION_UP:
                        float endX = event.getX();
                        float endY = event.getY();
                        if (isAClick(point[0], endX, point[1], endY)) {
                            handleVideoClick();
                        }
                        return true;
                }
                return false;
            }
        });
//        mVideoView.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                handleVideoClick();
//            }
//        });
        mRelativeLayout.addView(mVideoView);

        DisplayMetrics displayMetrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        int height = displayMetrics.heightPixels;

        RelativeLayout.LayoutParams skipoffsetViewLayoutParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        skipoffsetViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        skipoffsetViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        skipoffsetViewLayoutParams.setMargins(0, 0, 0, (int) (height * .25f));

        mSkipView = new TextView(this);
        mSkipView.setMinWidth(px(70));
        mSkipView.setLayoutParams(skipoffsetViewLayoutParams);
        mSkipView.setPadding(px(5), px(5), px(5), px(5));
        mSkipView.setBackgroundColor(Color.argb(178, 51, 51, 51));
        mSkipView.setTextColor(Color.WHITE);
        mSkipView.setText("Skip");
        mSkipView.setEnabled(false);
        mSkipView.setVisibility(View.GONE);

        mSkipView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sendSkipEvents();
                finishInterstitial(false);
            }
        });

        mRelativeLayout.addView(mSkipView);

        RelativeLayout.LayoutParams closeViewLayoutParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        closeViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        closeViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        closeViewLayoutParams.setMargins(0, 0, 0, 0);

        mCloseView = new TextView(this);
        mCloseView.setMinWidth(px(70));
        mCloseView.setLayoutParams(closeViewLayoutParams);
        mCloseView.setPadding(px(5), px(5), px(5), px(5));
        mCloseView.setBackgroundColor(Color.argb(178, 51, 51, 51));
        mCloseView.setTextColor(Color.WHITE);
        mCloseView.setText("Close");
        mCloseView.setGravity(Gravity.CENTER);
        mCloseView.setEnabled(false);

        mCloseView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finishInterstitial(false);
            }
        });

        mRelativeLayout.addView(mCloseView);

        final SkiAdInfo adInfo = getAdInfo(getIntent());
        if (adInfo != null) {
            mReportView = new TextView(this);
            mReportView.setVisibility(View.GONE);
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
                    SkiAdReportActivity.show(SkiAdInterstitialActivity.this, new SkiAdReportActivity.SkiAdReportListener() {
                        @Override
                        public void onResult(boolean canceled, Intent data) {
                            if (!canceled) {
                                String email = SkiAdReportActivity.getEmail(data);
                                String feedback = SkiAdReportActivity.getFeedback(data);

                                SkiEventTracker.getInstance(SkiAdInterstitialActivity.this)
                                        .trackInfringementReport(
                                                SkiEventTracker.infringementReport(adInfo)
                                                        .setEmail(email)
                                                        .setMessage(feedback));

                                finishInterstitial(true);
                            }
                        }
                    });
                }
            });

            RelativeLayout.LayoutParams reportViewLayoutParams = new RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);

            reportViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            reportViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
            reportViewLayoutParams.setMargins(0, 0, 0, 0);

            mRelativeLayout.addView(mReportView, reportViewLayoutParams);
        }

        updateCloseView(false);
        updateSkipView(false);

        hideEverything();

        setContentView(mRelativeLayout);

        mVideoView.requestFocus();
    }

    private void finishInterstitial(boolean left) {
        this.finish();

        SkiAdInterstitial.closed(getUid(getIntent()));
        if (left) {
            SkiAdInterstitial.left(getUid(getIntent()));
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);

        outState.putInt("__savedPosition", mVideoView.getCurrentPosition());

        mStateSaved = true;
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);

        int restoredPosition = savedInstanceState.getInt("__savedPosition", 0);
        if (restoredPosition > 0 && mVideoView != null) {
            mVideoView.seekTo(restoredPosition);
        }
        mStateSaved = false;
    }

    @Override
    protected void onResume() {
        super.onResume();

        hideEverything();
        if (!mCompleted) {
            maybeScheduleTicker();
            if (!mVideoView.isPlaying()) {
                mVideoView.start();
            }

            if (!mShownOnce) {
                mShownOnce = true;

                //noinspection ConstantConditions
                URL assetURL = mVastInfo.findBestMediaFile(this).getValue();
                Util.VastUrlMacros builder = Util.VastUrlMacros.builder()
                        .setAssetUrl(assetURL)
                        .setContentPlayAhead(0);
                ArrayList<URL> impressions = mVastInfo.getImpressionUrls();
                for (URL url : impressions) {
                    URL macrosed = builder.build(url);
                    SkiEventTracker.getInstance(this).trackEventRequest(macrosed);
                }

                for (SkiVastCompressedInfo.MediaFile.Tracking tracking :
                        mVastInfo.getTrackings()) {
                    //noinspection ConstantConditions
                    if (tracking.getValue() == null) {
                        continue;
                    }
                    String event = tracking.getEvent();
                    if ("start".equalsIgnoreCase(event)) {
                        URL macrosed = builder.build(tracking.getValue());
                        SkiEventTracker.getInstance(this).trackEventRequest(macrosed);
                    }
                }
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();

        if (!mCompleted) {
            maybeUnscheduleTicker();
            if (mVideoView.isPlaying()) {
                mVideoView.pause();
            }
        }
    }

    @Override
    protected void onDestroy() {
        if (!mStateSaved) {
            String local = mVastInfo.getLocalMediaFile();
            if (local != null) {
                //noinspection ResultOfMethodCallIgnored
                new File(local).delete();
            }
        }
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        if (mCompleted) {
            super.onBackPressed();
        }
    }

    private int px(float dp) {
        Resources r = getResources();
        return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, r.getDisplayMetrics()));
    }

    public static int getScreenOrientation(Activity activity) {
        int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
        int orientation = activity.getResources().getConfiguration().orientation;
        if (orientation == Configuration.ORIENTATION_PORTRAIT) {
            if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_270) {
                return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
            } else {
                return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
            }
        }
        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
                return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
            } else {
                return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
            }
        }

        return ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED;
    }


    @SuppressLint("InlinedApi")
    private void hideEverything() {
        mRelativeLayout.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE
                | View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION);
    }

    private void maybeScheduleTicker() {
        if (!mIsReady || myTimer != null) {
            return;
        }

        myTimer = new Timer();
        myTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                runOnUiThread(mTimerTick);
            }

        }, 0, 500);
    }

    private void maybeUnscheduleTicker() {
        if (myTimer == null) {
            return;
        }

        myTimer.cancel();
        myTimer.purge();
        myTimer = null;
    }

    private int getAnyDuration() {
        if (mIsReady) {
            return mVideoView.getDuration() / 1000;
        } else {
            VastTime vastTime = mVastInfo.getDuration();
            if (vastTime != null) {
                Long time = vastTime.getTime();
                if (time != null) {
                    return (int) (time / 1000);
                }
            }
        }

        return 0;
    }

    private void updateCloseView(boolean completed) {
        if (completed) {
            mCloseView.setEnabled(true);
            mCloseView.setText(R.string.skippables_interstitial_close);
            mReportView.setVisibility(View.VISIBLE);
            return;
        }
        mReportView.setVisibility(View.GONE);

        int duration = getAnyDuration();
        int currentPosition = mVideoView.getCurrentPosition() / 1000;

        int remaining = duration - currentPosition;
        if (remaining <= 0) {
            mCloseView.setEnabled(true);
            mCloseView.setText(R.string.skippables_interstitial_close);
        } else {
            mCloseView.setText(String.format(Locale.US, "%02d:%02d", (remaining / 60) % 60, remaining % 60));
            mCloseView.setEnabled(false);
        }
    }

    private void updateSkipView(boolean completed) {
        if (completed) {
            mReportView.setVisibility(View.VISIBLE);
//            mSkipView.setVisibility(View.GONE);
            return;
        }

        VastTime vastTime = mVastInfo.getSkipOffset();
        if (vastTime == null) {
            mReportView.setVisibility(View.VISIBLE);
//            mSkipView.setVisibility(View.GONE);
            return;
        }

        int duration = getAnyDuration();
        int skippOffset = vastTime.getOffset(duration);
        if (skippOffset < 0 || skippOffset >= duration) {
//            mReportView.setVisibility(View.VISIBLE);
//            mSkipView.setVisibility(View.GONE);
            return;
        }

        int currentPosition = mVideoView.getCurrentPosition() / 1000;
        if (currentPosition >= duration) {
//            mSkipView.setVisibility(View.GONE);
            mReportView.setVisibility(View.VISIBLE);
            mSkipView.setEnabled(true);
        } else if (currentPosition >= skippOffset) {
            mReportView.setVisibility(View.VISIBLE);
            mSkipView.setVisibility(View.VISIBLE);
            mSkipView.setText(R.string.skippables_interstitial_skip);
            mSkipView.setTextColor(Color.WHITE);
            mSkipView.setEnabled(true);
        } else {
            mSkipView.setVisibility(View.VISIBLE);
            mSkipView.setTextColor(Color.rgb(153, 153, 153));
            mSkipView.setEnabled(false);
            int remaining = Math.round(skippOffset - currentPosition);
            if (remaining < 60.) {
                mSkipView.setText(String.format(getString(R.string.skippables_interstitial_skip_in_short), remaining % 60));
            } else {
                mSkipView.setText(String.format(getString(R.string.skippables_interstitial_skip_in_long), (remaining / 60) % 60, remaining % 60));
            }
        }
    }

    private void sendTimedEvents() {
        int duration = getAnyDuration();
        int currentPosition = mVideoView.getCurrentPosition() / 1000;
        //noinspection ConstantConditions
        URL assetURL = mVastInfo.findBestMediaFile(this).getValue();
        Util.VastUrlMacros builder = Util.VastUrlMacros.builder()
                .setAssetUrl(assetURL)
                .setContentPlayAhead(currentPosition);

        ArrayList<SkiVastCompressedInfo.MediaFile.Tracking> remove = new ArrayList<>();
        for (SkiVastCompressedInfo.MediaFile.Tracking tracking :
                mVastInfo.getTrackings()) {
            //noinspection ConstantConditions
            if (tracking.getValue() == null) {
                continue;
            }
            String event = tracking.getEvent();
            if ("firstQuartile".equalsIgnoreCase(event)) {
                int quartile = (int) (duration * .25);
                if (currentPosition >= quartile) {
                    URL macrosed = builder.build(tracking.getValue());
                    SkiEventTracker.getInstance(this).trackEventRequest(macrosed);

                    remove.add(tracking);
                }
            } else if ("midpoint".equalsIgnoreCase(event)) {
                int quartile = (int) (duration * .50);
                if (currentPosition >= quartile) {
                    URL macrosed = builder.build(tracking.getValue());
                    SkiEventTracker.getInstance(this).trackEventRequest(macrosed);

                    remove.add(tracking);
                }
            } else if ("thirdQuartile".equalsIgnoreCase(event)) {
                int quartile = (int) (duration * .75);
                if (currentPosition >= quartile) {
                    URL macrosed = builder.build(tracking.getValue());
                    SkiEventTracker.getInstance(this).trackEventRequest(macrosed);

                    remove.add(tracking);
                }
            } else if ("progress".equalsIgnoreCase(event)) {
                if (tracking.getOffset() == null) {
                    remove.add(tracking);
                } else {
                    int offset = tracking.offset.getOffset(duration);
                    if (currentPosition >= offset) {
                        URL macrosed = builder.build(tracking.getValue());
                        SkiEventTracker.getInstance(this).trackEventRequest(macrosed);

                        remove.add(tracking);
                    }
                }
            }
        }

        mVastInfo.getTrackings().removeAll(remove);
    }

    private void sendCompleteEvents() {
        int currentPosition = mVideoView.getCurrentPosition() / 1000;
        //noinspection ConstantConditions
        URL assetURL = mVastInfo.findBestMediaFile(this).getValue();
        Util.VastUrlMacros builder = Util.VastUrlMacros.builder()
                .setAssetUrl(assetURL)
                .setContentPlayAhead(currentPosition);

        ArrayList<SkiVastCompressedInfo.MediaFile.Tracking> remove = new ArrayList<>();
        for (SkiVastCompressedInfo.MediaFile.Tracking tracking :
                mVastInfo.getTrackings()) {
            //noinspection ConstantConditions
            if (tracking.getValue() == null) {
                continue;
            }
            String event = tracking.getEvent();
            if ("complete".equalsIgnoreCase(event)) {
                URL macrosed = builder.build(tracking.getValue());
                SkiEventTracker.getInstance(this).trackEventRequest(macrosed);

                remove.add(tracking);
            }
        }

        mVastInfo.getTrackings().removeAll(remove);
    }

    private void sendSkipEvents() {
        int currentPosition = mVideoView.getCurrentPosition() / 1000;
        //noinspection ConstantConditions
        URL assetURL = mVastInfo.findBestMediaFile(this).getValue();
        Util.VastUrlMacros builder = Util.VastUrlMacros.builder()
                .setAssetUrl(assetURL)
                .setContentPlayAhead(currentPosition);

        ArrayList<SkiVastCompressedInfo.MediaFile.Tracking> remove = new ArrayList<>();
        for (SkiVastCompressedInfo.MediaFile.Tracking tracking :
                mVastInfo.getTrackings()) {
            //noinspection ConstantConditions
            if (tracking.getValue() == null) {
                continue;
            }
            String event = tracking.getEvent();
            if ("skip".equalsIgnoreCase(event)) {
                URL macrosed = builder.build(tracking.getValue());
                SkiEventTracker.getInstance(this).trackEventRequest(macrosed);

                remove.add(tracking);
            }
        }

        mVastInfo.getTrackings().removeAll(remove);
    }

    private void sendClickEvents() {
        int currentPosition = mVideoView.getCurrentPosition() / 1000;
        //noinspection ConstantConditions
        URL assetURL = mVastInfo.findBestMediaFile(this).getValue();
        Util.VastUrlMacros builder = Util.VastUrlMacros.builder()
                .setAssetUrl(assetURL)
                .setContentPlayAhead(currentPosition);

        for (URL url :
                mVastInfo.getClickTrackings()) {
            URL macrosed = builder.build(url);
            SkiEventTracker.getInstance(this).trackEventRequest(macrosed);
        }
    }

    private void sendErrorEvents() {
        int currentPosition = mVideoView.getCurrentPosition() / 1000;
        //noinspection ConstantConditions
        URL assetURL = mVastInfo.findBestMediaFile(this).getValue();
        Util.VastUrlMacros builder = Util.VastUrlMacros.builder()
                .setAssetUrl(assetURL)
                .setContentPlayAhead(currentPosition)
                .setErrorCode(VastError.VAST_MEDIA_FILE_NOT_SUPPORTED_ERROR_CODE);
        ArrayList<URL> errorTrackings = mVastInfo.getErrorTrackings();
        for (URL url :
                errorTrackings) {
            SkiEventTracker.getInstance(this).trackEventRequest(builder.build(url));
        }
    }

    private void handleVideoClick() {
        sendClickEvents();

        boolean left = true;
        URL clickUrl = mVastInfo.getClickThrough();
        if (clickUrl != null) {
            if (clickUrl.getProtocol().equalsIgnoreCase("http") ||
                    clickUrl.getProtocol().equalsIgnoreCase("https")) {
                left = tryOpenAnyBrowser(Uri.parse(clickUrl.toString()));
            } else {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(clickUrl.toString()));
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                try {
                    startActivity(intent);
                } catch (ActivityNotFoundException ignore) {
                    left = false;
                }
            }

            finishInterstitial(left);
        }
    }

    private boolean tryOpenAnyBrowser(Uri uri) {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(uri);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.setPackage("com.android.chrome");
        try {
            startActivity(intent);
        } catch (ActivityNotFoundException ignore) {
            intent.setPackage("com.amazon.cloud9");
            try {
                startActivity(intent);
            } catch (ActivityNotFoundException ignored) {
                intent.setPackage(null);
                try {
                    startActivity(intent);
                } catch (ActivityNotFoundException ignored1) {
                    return false;
                }
            }
        }

        return true;
    }

    private static class InterstitialVideoView extends VideoView {

//        private int mVideoWidth;
//        private int mVideoHeight;

        public InterstitialVideoView(Context context) {
            super(context);

//            setOnPreparedListener(this);
        }

        public InterstitialVideoView(Context context, AttributeSet attrs) {
            super(context, attrs);
        }

        public InterstitialVideoView(Context context, AttributeSet attrs, int defStyleAttr) {
            super(context, attrs, defStyleAttr);
        }

        @SuppressWarnings("unused")
        @TargetApi(Build.VERSION_CODES.LOLLIPOP)
        public InterstitialVideoView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
            super(context, attrs, defStyleAttr, defStyleRes);
        }

//        @Override
//        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
//            //Log.i("@@@@", "onMeasure");
//            int width = getDefaultSize(mVideoWidth, widthMeasureSpec);
//            int height = getDefaultSize(mVideoHeight, heightMeasureSpec);
//            if (mVideoWidth > 0 && mVideoHeight > 0) {
//                if ( mVideoWidth * height  > width * mVideoHeight ) {
//                    //Log.i("@@@", "image too tall, correcting");
//                    height = width * mVideoHeight / mVideoWidth;
//                } else if ( mVideoWidth * height  < width * mVideoHeight ) {
//                    //Log.i("@@@", "image too wide, correcting");
//                    width = height * mVideoWidth / mVideoHeight;
//                } else {
//                    //Log.i("@@@", "aspect ratio is correct: " +
//                    //width+"/"+height+"="+
//                    //mVideoWidth+"/"+mVideoHeight);
//                }
//            }
//            //Log.i("@@@@@@@@@@", "setting size: " + width + 'x' + height);
//            setMeasuredDimension(width, height);
//        }
//
//        @Override
//        public void onPrepared(MediaPlayer mp) {
////            mp.setVideoScalingMode(MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT);
//            
//            mVideoWidth = mp.getVideoWidth();
//            mVideoHeight = mp.getVideoHeight();
//        }
    }
}
