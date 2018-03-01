package com.mobiblocks.skippables_sample;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.mobiblocks.skippables.SkiAdInterstitial;
import com.mobiblocks.skippables.SkiAdListener;
import com.mobiblocks.skippables.SkiAdRequest;
import com.mobiblocks.skippables.SkiAdSize;
import com.mobiblocks.skippables.SkiAdView;
import com.mobiblocks.skippables.Skippables;

public class MainActivity extends Activity
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

        loadButton = (Button) findViewById(R.id.loadButton);
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

        final SkiAdView adView = (SkiAdView) findViewById(R.id.skiAdView);
        adView.setAdUnitId("9aac45fd-08c8-4394-a3a4-076198782d6c");
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

        final SkiAdView adViewMedium = (SkiAdView) findViewById(R.id.skiAdViewMedium);
        adViewMedium.setAdUnitId("73f87173-6181-48ae-b149-0e7a29019415");
        adViewMedium.setAdSize(SkiAdSize.FULL_BANNER);
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

        final SkiAdView adViewHalfPage = (SkiAdView) findViewById(R.id.skiAdViewHalfPage);
        adViewHalfPage.setAdUnitId("73f87173-6181-48ae-b149-0e7a29019415");
        adViewHalfPage.setAdSize(SkiAdSize.LARGE_BANNER);
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
//                .setTest(true)
                .build();

        interstitial = new SkiAdInterstitial(getApplicationContext());
        interstitial.setAdUnitId("073383e2-0f01-46d6-80f4-93c8024904c4");
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
