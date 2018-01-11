package com.mobiblocks.skippables_sample;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.mobiblocks.skippables.SkiAdInterstitial;
import com.mobiblocks.skippables.SkiAdListener;
import com.mobiblocks.skippables.SkiAdRequest;
import com.mobiblocks.skippables.SkiAdSize;
import com.mobiblocks.skippables.SkiAdView;
import com.mobiblocks.skippables.Skippables;

public class MainActivity extends AppCompatActivity {

    private static final String SKI_AD_UNIT_ID = "your_ad_unit_id";
    private static final String SKI_INTERSTITIAL_AD_UNIT_ID = "your_ad_unit_id";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Skippables.initialize(this);

        final SkiAdRequest adRequest = SkiAdRequest
                .builder()
                .setTest(BuildConfig.DEBUG)
                .build();

        final SkiAdView adView = findViewById(R.id.skiAdView);
        adView.setVisibility(View.GONE);
        adView.setAdUnitId(SKI_AD_UNIT_ID);
        adView.setAdSize(SkiAdSize.BANNER);
        adView.setAdListener(new SkiAdListener() {
            @Override
            public void onAdFailedToLoad(int i) {
                adView.setVisibility(View.GONE);
            }

            @Override
            public void onAdLoaded() {
                adView.setVisibility(View.VISIBLE);
            }
        });
        adView.loadRequest(adRequest);

        final Button button = findViewById(R.id.button);

        final SkiAdInterstitial interstitial = new SkiAdInterstitial(this);
        interstitial.setAdUnitId(SKI_INTERSTITIAL_AD_UNIT_ID);
        interstitial.setAdListener(new SkiAdListener() {
            @Override
            public void onAdFailedToLoad(int errorCode) {
                super.onAdFailedToLoad(errorCode);

                button.setEnabled(true);
                button.setText("Load");
            }

            @Override
            public void onAdLoaded() {
                super.onAdLoaded();

                button.setEnabled(true);
                button.setText("Show");
            }
        });

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (interstitial.isLoaded()) {
                    interstitial.show();
                    
                    button.setText("Load");
                } else if (!interstitial.isLoading() || interstitial.isBeenUsed()) {
                    interstitial.loadRequest(adRequest);

                    button.setEnabled(false);
                    button.setText("Loading");
                }
            }
        });
    }
}
