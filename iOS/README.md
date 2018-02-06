# SKIPPABLES

##Prerequisites

* Use Xcode 9.1 or higher

* Target iOS 9.0 or higher

* Recommended: [Create an account](https://www.skippables.com/Account/Register) and [register an app](https://www.skippables.com/Application/New).

##Import the SDK
###CocoaPods (preferred)
The simplest way to import the SDK is with [CocoaPods](https://guides.cocoapods.org/using/getting-started). Open your project's Podfile and add this line to your app's target:

	   pod 'Skippables'
	   
Then from the command line run:

		pod install
		
If you're new to CocoaPods, see their [official documentation](https://guides.cocoapods.org/using/using-cocoapods) for info on how to create and use Podfiles.

###Manual download
You can also [download](https://www.skippables.com/sdk/ios) a copy of the SDK framework directly, unzip the file.

1. Drag and drop *SKIPPABLES.framework* inside a file group of your XCode project (usually, 'Frameworks').
2. Be sure to check the box for 'Copy items into destination group's folder if needed' on the following window.
3. Don't forget to embed the framework in your application:
	1. Go to the app target’s General configuration page
	2. Add the framework target to the Embedded Binaries section by clicking the Add icon (do not drag in the framework from Finder)
	3. Select *SKIPPABLES.framework* from the list of binaries that can be embedded.
4. Include the following frameworks that are not included by default:
    * *AdSupport.framework*

##Banners
Banner ads are rectangular ads that occupy a spot within a view. They stay on screen while users are interacting with the app.

###Interface Builder

A `SKIAdBannerView` can be added through Interface Builder like any view. Be sure to add width and height constraints to match the ad size you'd like to display.

###Programmatically
A `SKIAdBannerView` can also be instantiated directly. Here's an example on how to create a `SKIAdBannerView`, aligned to the bottom of the safe area of the screen, with the standard banner size of 320x50:

~~~objc
#import <SKIPPABLES/SKIPPABLES.h>

@interface ViewController ()

@property(strong, nonatomic) SKIAdBannerView *bannerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.bannerView = [SKIAdBannerView bannerView];
	self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self.view addSubview:self.bannerView];
	[self.view addConstraints:@[
		[NSLayoutConstraint constraintWithItem:self.bannerView
		                             attribute:NSLayoutAttributeHeight
		                             relatedBy:NSLayoutRelationEqual
		                                toItem:nil
		                             attribute:NSLayoutAttributeNotAnAttribute
		                            multiplier:1.0
		                              constant:50.f],
		[NSLayoutConstraint constraintWithItem:self.bannerView
		                             attribute:NSLayoutAttributeBottom
		                             relatedBy:NSLayoutRelationEqual
		                                toItem:self.bottomLayoutGuide
		                             attribute:NSLayoutAttributeTop
		                            multiplier:1
		                              constant:0],
		[NSLayoutConstraint constraintWithItem:self.bannerView
		                             attribute:NSLayoutAttributeLeft
		                             relatedBy:NSLayoutRelationEqual
		                                toItem:self.view
		                             attribute:NSLayoutAttributeLeft
		                            multiplier:1
		                              constant:0],
		[NSLayoutConstraint constraintWithItem:self.bannerView
		                             attribute:NSLayoutAttributeRight
		                             relatedBy:NSLayoutRelationEqual
		                                toItem:self.view
		                             attribute:NSLayoutAttributeRight
		                            multiplier:1
		                              constant:0]
	]];
}

@end
~~~

###Configure SKIAdBannerView properties
In order to load and display ads, `SKIAdBannerView` requires an ad unit id and an ad size to be set (default ad size is `kSKIAdSizeBanner` 320x50).

Here's a code example showing how to set the two required properties in the `viewDidLoad` method of a `UIViewController`:

~~~objc
- (void)viewDidLoad {
  [super viewDidLoad];
  ...
  self.bannerView.adSize = kSKIAdSizeBanner;
  self.bannerView.adUnitID = @"your_ad_unit_id";
  ...
}
~~~

###Load an ad
Once the `SKIAdBannerView` configured, it's time to load an ad. This is done by calling `loadRequest:` with a `SKIAdRequest` object:

~~~objc
- (void)viewDidLoad {
  [super viewDidLoad];
  ...
  self.bannerView.adUnitID = @"your_ad_unit_id";
  [self.bannerView loadRequest:[SKIAdRequest request]];
  ...
}
~~~

`SKIAdRequest` objects represent a single ad request, and contain properties for things like targeting information.

###Always test with test ads
When building and testing your apps, make sure you use test ads. Failure to do so can lead to suspension of your account.

To enable test ads on an ad request set `SKIAdRequest` `test` property to `YES`.
Example using `DEBUG` macros:

~~~objc
...
  SKIAdRequest *adRequest = [SKIAdRequest request];
#ifdef DEBUG
  adRequest.test = YES;
#endif
  [self.bannerView loadRequest:adRequest];
...
~~~

###Ad events
You can listen for lifecycle events, such as when an ad is closed or the user leaves the app by implementing `SKIAdBannerViewDelegate` protocol.

#####Registering for banner events

To register for banner ad events, set the delegate property on `SKIAdBannerView` to an object that implements the `SKIAdBannerViewDelegate` protocol.

~~~objc
#import <SKIPPABLES/SKIPPABLES.h>

@interface ViewController ()

@property(strong, nonatomic) SKIAdBannerView *bannerView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  ...
  self.bannerView.adUnitID = @"your_ad_unit_id";
  self.bannerView.delegate = self;
  ...
}
~~~

#####Implementing banner events

Each of the methods in `SKIAdBannerViewDelegate` are optional, so you only need to implement the methods you want. This example implements each method and logs a message to the console:

~~~objc
/// Called when an ad request loaded an ad.
- (void)skiAdViewDidReceiveAd:(SKIAdBannerView *)view {
	NSLog(@"skiAdViewDidReceiveAd");
	
	// e.g. animate ad appearance
}

/// Called when an ad request failed.
- (void)skiAdView:(SKIAdBannerView *)view didFailToReceiveAdWithError:(SKIAdRequestError *)error {
	NSLog(@"skiAdView:didFailToReceiveAdWithError: %@", error);
	
	// e.g. removing the ad from view
}

/// Called just before presenting the user a full screen view.
- (void)skiAdViewWillPresentScreen:(SKIAdBannerView *)adView {
	NSLog(@"skiAdViewWillPresentScreen");
}

/// Called just before dismissing a full screen view.
- (void)skiAdViewWillDismissScreen:(SKIAdBannerView *)adView {
	NSLog(@"skiAdViewWillDismissScreen");
}

/// Called just after dismissing a full screen view.
- (void)skiAdViewDidDismissScreen:(SKIAdBannerView *)adView {
	NSLog(@"skiAdViewDidDismissScreen");
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store).
- (void)skiAdViewWillLeaveApplication:(SKIAdBannerView *)adView {
	NSLog(@"skiAdViewWillLeaveApplication");
}
~~~

##Interstitial Video Ads
Interstitial ads are full-screen ads that cover the interface of an app until closed by the user. They're typically displayed between transition points in the flow of an app, such as between activities or during the pause between levels in a game.

###Create an interstitial ad object

Interstitial ads are requested and shown by `SKIAdInterstitial` objects. Here's how to create a `SKIAdInterstitial` in the `viewDidLoad` method of a `UIViewController`:

~~~objc
#import <SKIPPABLES/SKIPPABLES.h>

@interface ViewController ()

@property(strong, nonatomic) SKIAdInterstitial *interstitial;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.interstitial = [SKIAdInterstitial interstitial];
	self.interstitial.adUnitID = @"your_ad_unit_id";
  ...
}
~~~

`SKIAdInterstitial` is a single-use object that will load and display one interstitial ad. To display multiple interstitial ads, an app needs to create a `SKIAdInterstitial` for each one.

###Load an ad
To load an interstitial ad, call `loadRequest:` with a `SKIAdRequest` object:

~~~objc
- (void)viewDidLoad {
  [super viewDidLoad];
  ...
  self.interstitial.adUnitID = @"your_ad_unit_id";
  
  [self.interstitial loadRequest:[SKIAdRequest request]];
  ...
}
~~~

###Always test with test ads
When building and testing your apps, make sure you use test ads. Failure to do so can lead to suspension of your account.

To enable test ads on an ad request set `SKIAdRequest` `test` property to `YES`.
Example using `DEBUG` macros:

~~~objc
...
  SKIAdRequest *adRequest = [SKIAdRequest request];
#ifdef DEBUG
  adRequest.test = YES;
#endif
  [self.interstitial loadRequest:adRequest];
...
~~~

###Show the ad
Interstitials should be displayed during natural pauses in the flow of an app. To show an interstitial, check the `isReady` property on `SKIAdInterstitial` to verify that it's done loading, then call `presentFromRootViewController:`.

Here's an example:

~~~objc
- (IBAction)showReport:(id)sender {
  ...
  if (self.interstitial.isReady) {
    [self.interstitial presentFromRootViewController:self];
  } else {
    NSLog(@"Ad is not ready");
  }
}
~~~

###Ad events
You can listen for lifecycle events, such as when an ad is closed or the user leaves the app by implementing `SKIAdInterstitialDelegate` protocol.

#####Registering for interstitial events
To register for interstitial ad events, set the delegate property on `SKIAdInterstitial` to an object that implements the `SKIAdInterstitialDelegate` protocol.

~~~objc
#import <SKIPPABLES/SKIPPABLES.h>

@interface ViewController () <SKIAdInterstitialDelegate>

@property(strong, nonatomic) SKIAdInterstitial *interstitial;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  ...
  self.interstitial = [SKIAdInterstitial interstitial];
  self.interstitial.adUnitID = @"your_ad_unit_id";
  self.interstitial.delegate = self;
  ...
}
~~~

#####Implementing interstitial events
Each of the methods in `SKIAdInterstitialDelegate` are optional, so you only need to implement the methods you want. This example implements each method and logs a message to the console:


~~~objc
/// Called when an ad request loaded an ad.
- (void)skiInterstitialDidReceiveAd:(SKIAdInterstitial *)interstitial {
	NSLog(@"skiInterstitialDidReceiveAd");
}
/// Called when an ad request failed.
- (void)skiInterstitial:(SKIAdInterstitial *)interstitial didFailToReceiveAdWithError:(SKIAdRequestError *)error {
	NSLog(@"skiInterstitial:didFailToReceiveAdWithError: %@", error);
}

/// Called just before presenting an interstitial.
- (void)skiInterstitialWillPresent:(SKIAdInterstitial *)ad {
	NSLog(@"skiInterstitialWillPresent");
}

/// Called before the interstitial is to be animated off the screen.
- (void)skiInterstitialWillDismiss:(SKIAdInterstitial *)ad {
	NSLog(@"skiInterstitialWillDismiss");
}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)skiInterstitialDidDismiss:(SKIAdInterstitial *)ad {
	NSLog(@"skiInterstitialDidDismiss");
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store).
- (void)skiInterstitialWillLeaveApplication:(SKIAdInterstitial *)ad {
	NSLog(@"skiInterstitialWillLeaveApplication");
}
~~~

###Using SKIAdInterstitialDelegate to reload
`SKIAdInterstitial` is a one-time-use object. This means once an interstitial is shown, `hasBeenUsed` returns `YES` and the interstitial can't be reused.
As an example you can allocate another interstitial in the `skiInterstitialWillDismiss:` method on `SKIAdInterstitialDelegate` protocol so that the next interstitial starts loading as soon as the previous one is dismissed.

~~~objc
- (SKIAdInterstitial *)createAndLoadInterstitial {
	SKIAdInterstitial *interstitial = [SKIAdInterstitial interstitial];
	interstitial.delegate = self;
	SKIAdRequest *adRequest = [SKIAdRequest request];
#ifdef DEBUG
	adRequest.test = YES;
#endif
	[self.interstitial loadRequest:adRequest];
	
	return interstitial;
}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)skiInterstitialDidDismiss:(SKIAdInterstitial *)ad {
	self.interstitial = [self createAndLoadInterstitial];
}
~~~