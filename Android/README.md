# SKIPPABLES

##Prerequisites

* Use Android Studio 3 or higher

* Target Android API level 15 or higher

* Recommended: [Create an account](https://www.skippables.com/Account/Register) and [register an app](https://www.skippables.com/Application/New).

##Import the SDK

###Manual
You can also [download](https://www.skippables.com/sdk/android) a copy of the SDK framework directly, unzip the file.

If you are using Android Studio, right click on your project add select **New Module**. Then select **Import .JAR/.AAR Package** option and from the file browser locate *skippables.aar* file. Right click again on your project and in **Module Dependencies** tab choose to add *skippables* module that you recently added, as a dependency.

###OR
Reference the `aar` folder in the app's project-level `build.gradle` file. Open yours and look for an `allprojects` section. We will use *libs* folder:

~~~gradle
allprojects {
    repositories {
        google()
        jcenter()
        flatDir {
            dirs 'libs'
        }
    }
}
~~~

Next, open the app-level `build.gradle` file for your app, and look for a `dependencies` section.

~~~gradle
dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    ...
    compile (name: 'skippables', ext: 'aar')
}
~~~

##Initialize MobileAds
Before loading ads, have your app initialize the SDK by calling `Skippables.initialize()`. Best place is in your `Application` class.

Here's an example of initializing in an Activity:

~~~java
package ...

import ...
import com.mobiblocks.skippables.Skippables;
import com.mobiblocks.skippables.SkiAdView;
import com.mobiblocks.skippables.SkiAdSize;
import com.mobiblocks.skippables.SkiAdRequest;
import com.mobiblocks.skippables.SkiAdListener;

public class MainActivity extends Activity {
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Skippables.initialize(this);
    }
    ...
}
~~~


##Banners
Banner ads are rectangular ads that occupy a spot within a view. They stay on screen while users are interacting with the app.

To display a banner you need to place the `SkiAdView` in the layout of your `Activity` or `Fragment`. The easiest way is to use the corresponding XML layout file. Here's an example that shows `SkiAdView` at the bottom of an `Activity`:

**main_activity.xml**

~~~xml
<?xml version="1.0" encoding="utf-8"?>
<android.support.constraint.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <com.mobiblocks.skippables.SkiAdView
        android:id="@+id/skiAdView"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        app:layout_constraintLeft_toLeftOf="parent"
        app:layout_constraintRight_toRightOf="parent"
        app:layout_constraintBottom_toTopOf="parent" />

</android.support.constraint.ConstraintLayout>

~~~

You can alternatively create the `SkiAdView` programmatically:

~~~java
...
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Skippables.initialize(this);
        
        SkiAdView adView = new SkiAdView(this);
        // TODO: Add adView to your view hierarchy.
    }
...
~~~

###Configure SKIAdBannerView properties
In order to load and display ads, `SkiAdView` requires an ad unit id and an ad size to be set (default ad size is `SkiAdSize.BANNER` 320x50). 

~~~java
...
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        adView.setAdUnitId("your_ad_unit_id");
        adView.setAdSize(SkiAdSize.BANNER);
        ...
    }
...
~~~

###Load an ad
Once the `SkiAdView` configured, it's time to load an ad. This is done by calling `loadRequest()` with a `SkiAdRequest` object:

~~~java
...
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        adView.setAdUnitId("your_ad_unit_id");
        adView.setAdSize(SkiAdSize.BANNER);
        adView.loadRequest(SkiAdRequest.builder().build());
        ...
    }
...
~~~

`SkiAdRequest` objects represent a single ad request, and contain properties for things like targeting information.

###Always test with test ads
When building and testing your apps, make sure you use test ads. Failure to do so can lead to suspension of your account.

That's done with the `setTest(true)` method in `SkiAdRequest` builder class.
Example using `BuildConfig.DEBUG` constant:

~~~java
...
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        adView.setAdUnitId("your_ad_unit_id");
        adView.setAdSize(SkiAdSize.BANNER);
        SkiAdRequest adRequest = SkiAdRequest
                .builder()
                .setTest(BuildConfig.DEBUG)
                .build();
        adView.loadRequest(adRequest);
        ...
    }
...
~~~

###Ad events
You can listen for lifecycle events, such as when an ad is closed or the user leaves the app through the `SkiAdListener`.
Simply call the setAdListener() method:

~~~java
...
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        adView.setAdUnitId(SKI_AD_UNIT_ID);
        adView.setAdSize(SkiAdSize.BANNER);
        adView.setAdListener(new SkiAdListener() {

            @Override
            public void onAdLoaded() {
	            // Called when an ad request loaded an ad.
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
               // Called when an ad request failed.
            }

            @Override
            public void onAdOpened() {
               // Called just before presenting the user a full screen view.
            }

            @Override
            public void onAdLeftApplication() {
               // Called when the user has left the app.
            }

            @Override
            public void onAdClosed() {
               // Called when the user is about to return
               // to the app after tapping on an ad.
            }
            
        });
        ...
    }
...
~~~

##Interstitial Video Ads
Interstitial ads are full-screen ads that cover the interface of an app until closed by the user. They're typically displayed between transition points in the flow of an app, such as between activities or during the pause between levels in a game.

###Create an interstitial ad object

Interstitial ads are requested and shown by `SkiAdInterstitial` objects. Here's how to create a `SkiAdInterstitial` in the `onCreate()` method of an `Activity`:

~~~java
package ...

import ...
import com.mobiblocks.skippables.Skippables;
import com.mobiblocks.skippables.SkiAdInterstitial;
import com.mobiblocks.skippables.SkiAdRequest;
import com.mobiblocks.skippables.SkiAdListener;

public class MainActivity extends Activity {

    private SkiAdInterstitial interstitial;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Skippables.initialize(this);
        
        interstitial = new SkiAdInterstitial(this);
        interstitial.setAdUnitId("your_ad_unit_id");
    }
    ...
}
~~~

`SkiAdInterstitial` is a single-use object that will load and display one interstitial ad. To display multiple interstitial ads, an app needs to create a `SkiAdInterstitial` for each one.

###Load an ad
To load an interstitial ad, call `loadRequest:` with a `SKIAdRequest` object:

~~~java
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        interstitial.setAdUnitId("your_ad_unit_id");
        interstitial.loadRequest(SkiAdRequest.builder().build());
        ...
    }
    ...
~~~

###Always test with test ads
When building and testing your apps, make sure you use test ads. Failure to do so can lead to suspension of your account.

That's done with the `setTest(true)` method in `SkiAdRequest` builder class.
Example using `BuildConfig.DEBUG` constant:

~~~java
...
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        interstitial.setAdUnitId("your_ad_unit_id");
        SkiAdRequest adRequest = SkiAdRequest
                .builder()
                .setTest(BuildConfig.DEBUG)
                .build();
        interstitial.loadRequest(adRequest);
        ...
    }
...
~~~

###Show the ad
Interstitials should be displayed during natural pauses in the flow of an app. To show an interstitial, use the `isLoaded()` method on `SkiAdInterstitial` to verify that it's done loading, then call `show()`.

Here's an example:

~~~java
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        showReportButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (interstitial.isLoaded()) {
                    interstitial.show();
                } else {
                    // ad is not ready
                }
            }
        });
        ...
    }
~~~

###Ad events
You can listen for lifecycle events, such as when an ad is closed or the user leaves the app through the `SkiAdListener`.
Simply call the setAdListener() method:

~~~java
...
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        interstitial.setAdListener(new SkiAdListener() {

            @Override
            public void onAdLoaded() {
	            // Called when an ad request loaded an ad.
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
               // Called when an ad request failed.
            }

            @Override
            public void onAdOpened() {
               // Called just before presenting the user a full screen view.
            }

            @Override
            public void onAdLeftApplication() {
               // Called when the user has left the app.
            }

            @Override
            public void onAdClosed() {
               // Called when the user is about to return
               // to the app after tapping on an ad.
            }
            
        });
        ...
    }
...
~~~

###Using SkiAdListener to reload

Once an interstitial is shown you need to request a new interstitial if you want to show another one.

As an example you can request another interstitial in `onAdClosed()` so that the next interstitial starts loading as soon as the previous one is closed.

~~~java
...
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        interstitial.setAdListener(new SkiAdListener() {

            @Override
            public void onAdClosed() {
               SkiAdRequest adRequest = SkiAdRequest
                       .builder()
                       .setTest(BuildConfig.DEBUG)
                       .build();
               interstitial.loadRequest(adRequest);
            }
            
        });
        ...
    }
...
~~~