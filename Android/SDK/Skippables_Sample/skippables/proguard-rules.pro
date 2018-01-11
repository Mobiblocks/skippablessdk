# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

-keepclassmembers class com.google.android.gms.ads.identifier.AdvertisingIdClient {
    public *;
}
-keep public class com.mobiblocks.skippables.SkiAdInterstitial {
    public *;
}
-keep public class com.mobiblocks.skippables.SkiAdInterstitialActivity {
    public *;
}
-keep public class com.mobiblocks.skippables.SkiAdListener {
    public *;
}
-keep public class com.mobiblocks.skippables.SkiAdRequest {
    public *;
}
-keep public class com.mobiblocks.skippables.SkiAdRequest$Builder {
    public *;
}
-keep public class com.mobiblocks.skippables.SkiAdSize {
    public *;
}
-keep public class com.mobiblocks.skippables.SkiAdView {
    public *;
}
-keep public class com.mobiblocks.skippables.Skippables {
    public *;
}