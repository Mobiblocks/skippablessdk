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

public class MainActivity extends AppCompatActivity
{
	Button loadButton;
    private SkiAdInterstitial interstitial;
    private SkiAdRequest request;

    @Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
        Skippables.initialize(getApplicationContext());

        loadButton = findViewById(R.id.loadButton);
        loadButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (interstitial.isLoading()) {
                    return;
                }
                
                if (interstitial.isLoaded()) {
                    interstitial.show();
                    
                    loadButton.setText("Load");
                    return;
                }
                
                loadInterstitial();
            }
        });

        final SkiAdView adView = findViewById(R.id.skiAdView);
        adView.setAdUnitId(".Xler.ShareAndroid");
        adView.setAdSize(SkiAdSize.BANNER);
        adView.setAdListener(new SkiAdListener() {
            @Override
            public void onAdLoaded() {
                super.onAdLoaded();
                adView.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAdClosed() {
                super.onAdClosed();
            }

            @Override
            public void onAdLeftApplication() {
                super.onAdLeftApplication();
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                super.onAdFailedToLoad(errorCode);
                adView.setVisibility(View.INVISIBLE);
            }
        });

        final SkiAdView adViewMedium = findViewById(R.id.skiAdViewMedium);
        adViewMedium.setAdUnitId(".Xler.ShareAndroid");
        adViewMedium.setAdSize(SkiAdSize.MEDIUM_RECTANGLE);
        adViewMedium.setAdListener(new SkiAdListener() {
            @Override
            public void onAdLoaded() {
                super.onAdLoaded();
                adViewMedium.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAdClosed() {
                super.onAdClosed();
            }

            @Override
            public void onAdLeftApplication() {
                super.onAdLeftApplication();
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                super.onAdFailedToLoad(errorCode);
                adViewMedium.setVisibility(View.INVISIBLE);
            }
        });

        final SkiAdView adViewHalfPage = findViewById(R.id.skiAdViewHalfPage);
        adViewHalfPage.setAdUnitId(".Xler.ShareAndroid");
        adViewHalfPage.setAdSize(SkiAdSize.HALF_PAGE);
        adViewHalfPage.setAdListener(new SkiAdListener() {
            @Override
            public void onAdLoaded() {
                super.onAdLoaded();
                adViewHalfPage.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAdClosed() {
                super.onAdClosed();
            }

            @Override
            public void onAdLeftApplication() {
                super.onAdLeftApplication();
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                super.onAdFailedToLoad(errorCode);
                adViewHalfPage.setVisibility(View.INVISIBLE);
            }
        });

        request = SkiAdRequest.builder()
                .setTest(true)
                .build();

        interstitial = new SkiAdInterstitial(getApplicationContext());
        interstitial.setAdUnitId(".Xler.ShareAndroid");
        interstitial.setAdListener(new SkiAdListener() {
            @Override
            public void onAdLoaded() {
                super.onAdLoaded();

                loadButton.setEnabled(true);
                loadButton.setText("Show");
            }

            @Override
            public void onAdClosed() {
                super.onAdClosed();
            }

            @Override
            public void onAdLeftApplication() {
                super.onAdLeftApplication();
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                super.onAdFailedToLoad(errorCode);

                loadButton.setText("Load");
                loadButton.setEnabled(true);
            }
        });

        adView.loadRequest(request);

        adViewMedium.loadRequest(request);

        adViewHalfPage.loadRequest(request);
	}
	
	void loadInterstitial() {
        loadButton.setEnabled(false);
        
        interstitial.loadRequest(request);
    }
}
