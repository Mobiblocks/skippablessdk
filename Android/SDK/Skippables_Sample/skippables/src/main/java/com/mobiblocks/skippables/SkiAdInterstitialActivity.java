package com.mobiblocks.skippables;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Resources;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageView;
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
    private ImageView mMediaControl;
    private TextView mReportView;
    private Timer myTimer;
    private Runnable mTimerTick = new Runnable() {
        @Override
        public void run() {
            if (mState.isReady() && mVideoView != null) {
                mState.setCurrentPosition(mVideoView.getCurrentPosition());
            }

            updateCloseView(false);
            updateSkipView(false);
            sendTimedEvents();
        }
    };

    private final State mState = new State();

    private boolean mStateSaved;

    private MediaPlayer mMediaPlayer;
    @SuppressWarnings("FieldCanBeLocal")
    private SkiAdReportActivity.SkiAdReportListener mReportListener;

    static Intent getIntent(@SuppressWarnings("NullableProblems") @NonNull Context context, @NonNull String uid, @NonNull SkiAdInfo adInfo, @NonNull SkiVastCompressedInfo vastInfo) {
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

    @SuppressLint("ClickableViewAccessibility")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mVastInfo = getVastInfo(getIntent());
        if (mVastInfo == null) {
            finishInterstitial(false);
            return;
        }

        if (mVastInfo.isMaybeShownInLandscape()) {
            int orientation = Util.getScreenOrientation(this);
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
            int orientation = Util.getScreenOrientation(this);
            switch (orientation) {
                case ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE:
                case ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE: {
                    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                    break;
                }
                default: {
                    setRequestedOrientation(orientation);
                }
            }
        }

        mRelativeLayout = new RelativeLayout(this);
        mRelativeLayout.setLayoutParams(new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));

        RelativeLayout.LayoutParams videoViewLayoutParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        videoViewLayoutParams.addRule(RelativeLayout.CENTER_IN_PARENT);
//        videoViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
//        videoViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
//        videoViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
//        videoViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);

        mVideoView = new InterstitialVideoView(this);
//        mVideoView.setClickable(true);
        mVideoView.setLayoutParams(videoViewLayoutParams);
        mVideoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                mMediaPlayer = mp;

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                    mMediaPlayer.setVideoScalingMode(MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT);
                }

                mState.setReady(true);

                updateMediaControl();

                float volume = State.isMuted() ? 0.f : 1.f;
                mp.setVolume(volume, volume);

                restoreSavedPosition(null);

                mVideoView.requestLayout();
                sendInitialEvents();
                maybeScheduleTicker();
            }
        });
        mVideoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                maybeUnscheduleTicker();

                mState.setReady(false);
                mState.setCompleted(true);

                updateCloseView(true);
                updateSkipView(true);
                updateMediaControl();

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
        mVideoView.setOnTouchListener(new View.OnTouchListener() {
            float startX = 0;
            float startY = 0;

            private boolean isAClick(float startX, float endX, float startY, float endY) {
                float differenceX = Math.abs(startX - endX);
                float differenceY = Math.abs(startY - endY);
                return !(differenceX > 50 || differenceY > 50);
            }

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        startX = event.getX();
                        startY = event.getY();
                        return true;
                    case MotionEvent.ACTION_UP:
                        float endX = event.getX();
                        float endY = event.getY();
                        if (isAClick(startX, endX, startY, endY)) {
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
        mSkipView.setText(R.string.skippables_interstitial_skip);
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
        mCloseView.setId(Util.generateViewId());
        mCloseView.setMinWidth(px(70));
        mCloseView.setHeight(px(32));
        mCloseView.setLayoutParams(closeViewLayoutParams);
        mCloseView.setPadding(px(5), px(5), px(5), px(5));
        mCloseView.setBackgroundColor(Color.argb(178, 51, 51, 51));
        mCloseView.setTextColor(Color.WHITE);
        mCloseView.setText(R.string.skippables_interstitial_close);
        mCloseView.setGravity(Gravity.CENTER);
        mCloseView.setEnabled(false);

        mCloseView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finishInterstitial(false);
            }
        });

        mRelativeLayout.addView(mCloseView);


        if (!mState.isCompleted()) {
            mMediaControl = new ImageView(this);
            mMediaControl.setImageResource(mState.isPaused() ? R.drawable.skippables_interstitial_video_play : R.drawable.skippables_interstitial_video_pause);

            mMediaControl.setPadding(px(5), px(5), px(5), px(5));
            mMediaControl.setBackgroundColor(Color.argb(178, 51, 51, 51));
            mMediaControl.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mState.isCompleted() || mMediaPlayer == null || !mState.isReady()) {
                        return;
                    }

                    if (mMediaPlayer.isPlaying()) {
                        mMediaPlayer.pause();
                        mState.setPaused(true);
                    } else {
                        mMediaPlayer.start();
                        mState.setPaused(false);
                    }

                    updateMediaControl();
                }
            });

            updateMediaControl();

            RelativeLayout.LayoutParams mediaControlLayoutParams = new RelativeLayout.LayoutParams(px(32), px(32));

            mediaControlLayoutParams.addRule(RelativeLayout.RIGHT_OF, mCloseView.getId());
            mediaControlLayoutParams.addRule(RelativeLayout.ALIGN_BOTTOM, mCloseView.getId());
            mediaControlLayoutParams.setMargins(0, 0, 0, 0);

            mRelativeLayout.addView(mMediaControl, mediaControlLayoutParams);
        }

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
                    SkiAdReportActivity.show(SkiAdInterstitialActivity.this, createReportListener(adInfo));
                }
            });

            RelativeLayout.LayoutParams reportViewLayoutParams = new RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);

            reportViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            reportViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
            reportViewLayoutParams.setMargins(0, 0, 0, 0);

            mRelativeLayout.addView(mReportView, reportViewLayoutParams);
        }

        final ImageView soundToggleVideo = new ImageView(this);
        soundToggleVideo.setImageResource(State.isMuted() ? R.drawable.skippables_interstitial_video_muted : R.drawable.skippables_interstitial_video_volume);
        soundToggleVideo.setPadding(px(5), px(5), px(5), px(5));
        soundToggleVideo.setBackgroundColor(Color.argb(178, 51, 51, 51));
        soundToggleVideo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mMediaPlayer != null) {
                    boolean muted = State.toggleMute();
                    float volume = muted ? 0.f : 1.f;
                    mMediaPlayer.setVolume(volume, volume);
                    soundToggleVideo.setImageResource(muted ? R.drawable.skippables_interstitial_video_muted : R.drawable.skippables_interstitial_video_volume);
                }
            }
        });

        RelativeLayout.LayoutParams soundToggleVideoLayoutParams = new RelativeLayout.LayoutParams(px(32), px(32));

        soundToggleVideoLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        soundToggleVideoLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        soundToggleVideoLayoutParams.setMargins(0, 0, 0, 0);

        mRelativeLayout.addView(soundToggleVideo, soundToggleVideoLayoutParams);

        updateCloseView(mState.isCompleted());
        updateSkipView(mState.isCompleted());

        hideEverything();

        setContentView(mRelativeLayout);

        mVideoView.requestFocus();
    }

    private SkiAdReportActivity.SkiAdReportListener createReportListener(final SkiAdInfo adInfo) {
        mReportListener = new SkiAdReportActivity.SkiAdReportListener() {
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
        };

        return mReportListener;
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

        saveCurrentPosition(outState);

        mStateSaved = true;
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);

        restoreSavedPosition(savedInstanceState);

        mStateSaved = false;
    }

    @Override
    protected void onResume() {
        super.onResume();

        hideEverything();
        if (!mState.isCompleted()) {
            maybeScheduleTicker();
            if (!mVideoView.isPlaying() && !mState.isPaused()) {
                mVideoView.start();
            }

            mState.setShownOnce(true);
            sendInitialEvents();
        }
    }

    @Override
    protected void onRestart() {
        super.onRestart();

        mState.setReady(false);
    }

    @Override
    protected void onPause() {
        super.onPause();

        if (!mState.isCompleted()) {
            maybeUnscheduleTicker();
            if (mVideoView.isPlaying()) {
                mVideoView.pause();
                mState.setPaused(true);
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
        if (mState.isCompleted()) {
            super.onBackPressed();
        }
    }

    private void saveCurrentPosition(Bundle bundle) {
        if (mVideoView == null || !mState.isReady()) {
            return;
        }

        mState.setCurrentPosition(mVideoView.getCurrentPosition());
        if (bundle != null) {
            bundle.putParcelable("__savedState", mState);
        }
    }

    private void restoreSavedPosition(Bundle bundle) {
        if (bundle != null) {
            State savedState = bundle.getParcelable("__savedState");
            if (savedState != null) {
                mState.restore(savedState);
            }
        }

        if (!mState.isCompleted() && mState.isReady() && mState.getCurrentPosition() > 0 && mVideoView != null) {
            if (mState.getCurrentPosition() == mVideoView.getCurrentPosition()) {
                return;
            }

            if (BuildConfig.DEBUG) {
                Log.d("skippables-state", mState.getCurrentPosition() + ":" + mVideoView.getCurrentPosition());
            }
            
            if (mMediaPlayer != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                mMediaPlayer.seekTo(mState.getCurrentPosition(), MediaPlayer.SEEK_CLOSEST);
            } else {
                mVideoView.seekTo(mState.getCurrentPosition());
            }
        }
    }

    private int px(float dp) {
        Resources r = getResources();
        return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, r.getDisplayMetrics()));
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
        if (mState.isCompleted() || !mState.isReady() || myTimer != null) {
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
        if (mState.isReady()) {
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

    private void updateMediaControl() {
        if (mMediaControl == null) {
            return;
        }

        if (mState.isCompleted() || !mState.isReady()) {
            mMediaControl.setVisibility(View.INVISIBLE);
        } else {
            mMediaControl.setVisibility(View.VISIBLE);
        }

        mMediaControl.setImageResource(mState.isPaused() ? R.drawable.skippables_interstitial_video_play : R.drawable.skippables_interstitial_video_pause);
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

    private void sendInitialEvents() {
        if (mState.isShownOnce() && mState.isReady()) {
            ArrayList<URL> removeImpression = new ArrayList<>();
            //noinspection ConstantConditions
            URL assetURL = mVastInfo.findBestMediaFile(this).getValue();
            Util.VastUrlMacros builder = Util.VastUrlMacros.builder()
                    .setAssetUrl(assetURL)
                    .setContentPlayAhead(0);
            ArrayList<URL> impressions = mVastInfo.getImpressionUrls();
            for (URL url : impressions) {
                removeImpression.add(url);
                URL macrosed = builder.build(url);
                SkiEventTracker.getInstance(this).trackEventRequest(macrosed);
            }

            mVastInfo.getImpressionUrls().removeAll(removeImpression);

            ArrayList<SkiVastCompressedInfo.MediaFile.Tracking> removeTracking = new ArrayList<>();
            for (SkiVastCompressedInfo.MediaFile.Tracking tracking :
                    mVastInfo.getTrackings()) {
                removeTracking.add(tracking);
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

            mVastInfo.getTrackings().removeAll(removeTracking);
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

    @SuppressLint("ClickableViewAccessibility")
    private void handleVideoClick() {
        mVideoView.setOnTouchListener(null);
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

    private class InterstitialVideoView extends VideoView {

        private int mVideoWidth;
        private int mVideoHeight;

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

        @Override
        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            if (mMediaPlayer == null || !mState.isReady()) {
                super.onMeasure(widthMeasureSpec, heightMeasureSpec);
                return;
            }

            try {
                mVideoWidth = mMediaPlayer.getVideoWidth();
                mVideoHeight = mMediaPlayer.getVideoHeight();
            } catch (IllegalStateException ignore) {
                //TODO: this is a workaround, only god himself knows when an activity is restored restarted destroyed view requested view valid is prepared is in the middle of destroying the sun
                return;
            }

            int width = getDefaultSize(mVideoWidth, widthMeasureSpec);
            int height = getDefaultSize(mVideoHeight, heightMeasureSpec);
            if (mVideoWidth > 0 && mVideoHeight > 0) {
                if (mVideoWidth * height > width * mVideoHeight) {
                    //Log.i("@@@", "image too tall, correcting");
                    height = width * mVideoHeight / mVideoWidth;
                } else if (mVideoWidth * height < width * mVideoHeight) {
                    //Log.i("@@@", "image too wide, correcting");
                    width = height * mVideoWidth / mVideoHeight;
                }
            }
            setMeasuredDimension(width, height);
        }
    }

    private static class State implements Parcelable {
        private static boolean sMuted = false;

        private boolean isReady;
        private boolean isPaused;
        private boolean completed;

        private boolean shownOnce;
        private int currentPosition;

        State() {

        }

        @SuppressWarnings("WeakerAccess")
        protected State(Parcel in) {
            isReady = in.readByte() != 0;
            isPaused = in.readByte() != 0;
            completed = in.readByte() != 0;
            shownOnce = in.readByte() != 0;
            currentPosition = in.readInt();
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeByte((byte) (isReady ? 1 : 0));
            dest.writeByte((byte) (isPaused ? 1 : 0));
            dest.writeByte((byte) (completed ? 1 : 0));
            dest.writeByte((byte) (shownOnce ? 1 : 0));
            dest.writeInt(currentPosition);
        }

        @Override
        public int describeContents() {
            return 0;
        }

        public static final Creator<State> CREATOR = new Creator<State>() {
            @Override
            public State createFromParcel(Parcel in) {
                return new State(in);
            }

            @Override
            public State[] newArray(int size) {
                return new State[size];
            }
        };

        static boolean isMuted() {
            return sMuted;
        }

        static void setMuted(boolean muted) {
            sMuted = muted;
        }

        static boolean toggleMute() {
            sMuted = !sMuted;

            return sMuted;
        }

        boolean isReady() {
            return isReady;
        }

        void setReady(boolean ready) {
            printState("current", this);
            isReady = ready;
        }

        public boolean isPaused() {
            return isPaused;
        }

        public void setPaused(boolean paused) {
            isPaused = paused;
        }

        boolean isCompleted() {
            return completed;
        }

        void setCompleted(boolean completed) {
            printState("current", this);
            this.completed = completed;
        }

        boolean isShownOnce() {
            return shownOnce;
        }

        void setShownOnce(boolean shownOnce) {
            printState("current", this);
            this.shownOnce = shownOnce;
        }

        int getCurrentPosition() {
            return currentPosition;
        }

        void setCurrentPosition(int currentPosition) {
            printState("current", this);
            this.currentPosition = currentPosition;
        }

        void restore(State savedState) {
            printState("current", this);
            printState("saved", savedState);
            this.isReady = savedState.isReady;
            this.completed = savedState.completed;
            this.shownOnce = savedState.shownOnce;
            this.currentPosition = savedState.currentPosition;
        }

        @Override
        public String toString() {
            return "State{" +
                    ", muted=" + sMuted +
                    ", isReady=" + isReady +
                    ", completed=" + completed +
                    ", shownOnce=" + shownOnce +
                    ", currentPosition=" + currentPosition +
                    '}';
        }

        private static void printState(String name, State state) {
            if (BuildConfig.DEBUG) {
                Log.d("skippables-state", name + ": " + state.toString());
            }
        }
    }
}
