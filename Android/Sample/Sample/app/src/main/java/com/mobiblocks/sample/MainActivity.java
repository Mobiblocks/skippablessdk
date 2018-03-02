package com.mobiblocks.sample;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.mobiblocks.skippables.SkiAdInterstitial;
import com.mobiblocks.skippables.SkiAdListener;
import com.mobiblocks.skippables.SkiAdRequest;
import com.mobiblocks.skippables.SkiAdView;
import com.mobiblocks.skippables.Skippables;

public class MainActivity extends Activity {

    private static final String BANNER_AD_UNIT_ID_1 = "";
    private static final String INTERSTITIAL_AD_UNIT_ID_1 = "";
    private static final String INTERSTITIAL_AD_UNIT_ID_2 = "";
    private static final String INTERSTITIAL_AD_UNIT_ID_3 = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Skippables.initialize(this);


        final SkiAdRequest request = SkiAdRequest
                .builder()
                .setTest(BuildConfig.DEBUG)
                .build();

        SkiAdView banner = findViewById(R.id.banner);
        banner.setAdUnitId(BANNER_AD_UNIT_ID_1);
        banner.setAdListener(new SkiAdListener() {
            @Override
            public void onAdClosed() {
                super.onAdClosed();
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                super.onAdFailedToLoad(errorCode);
            }
        });
        banner.loadRequest(request);

        final SkiAdInterstitial interstitial1 = new SkiAdInterstitial(this);
        interstitial1.setAdUnitId(INTERSTITIAL_AD_UNIT_ID_1);
        interstitial1.setAdListener(new SkiAdListener() {
            @Override
            public void onAdClosed() {
                interstitial1.loadRequest(request);
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
            }
        });
        interstitial1.loadRequest(request);

        Button button1 = findViewById(R.id.button1);
        button1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, Example1Activity.class);
                MainActivity.this.startActivity(intent);
                
                if (interstitial1.isLoaded()) {
                    interstitial1.show();
                } else if (!interstitial1.isLoading() || !interstitial1.isBeenUsed()) {
                    interstitial1.loadRequest(request);
                }
            }
        });

        final SkiAdInterstitial interstitial2 = new SkiAdInterstitial(this);
        interstitial2.setAdUnitId(INTERSTITIAL_AD_UNIT_ID_2);
        interstitial2.setAdListener(new SkiAdListener() {
            @Override
            public void onAdClosed() {
                interstitial1.loadRequest(request);
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
            }
        });
        interstitial2.loadRequest(request);

        Button button2 = findViewById(R.id.button2);
        button2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, Example2Activity.class);
                MainActivity.this.startActivity(intent);
                
                if (interstitial2.isLoaded()) {
                    interstitial2.show();
                } else if (!interstitial2.isLoading() || !interstitial2.isBeenUsed()) {
                    interstitial2.loadRequest(request);
                }
            }
        });

        final SkiAdInterstitial interstitial3 = new SkiAdInterstitial(this);
        interstitial3.setAdUnitId(INTERSTITIAL_AD_UNIT_ID_3);
        interstitial3.setAdListener(new SkiAdListener() {
            @Override
            public void onAdClosed() {
                interstitial1.loadRequest(request);
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
            }
        });
        interstitial3.loadRequest(request);

        Button button3 = findViewById(R.id.button3);
        button3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, Example3Activity.class);
                MainActivity.this.startActivity(intent);
                
                if (interstitial3.isLoaded()) {
                    interstitial3.show();
                } else if (!interstitial3.isLoading() || !interstitial3.isBeenUsed()) {
                    interstitial3.loadRequest(request);
                }
            }
        });
    }
}
