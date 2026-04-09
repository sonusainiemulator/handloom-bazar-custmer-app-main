############################################################
# Flutter
############################################################
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }

############################################################
# Firebase - Enhanced for Release Mode
############################################################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**
-keep class com.google.firebase.auth.** { *; }
-dontwarn com.google.firebase.auth.**
-keep class com.google.firebase.auth.internal.** { *; }
-keep class com.google.firebase.auth.api.** { *; }
-keep class com.google.firebase.iid.** { *; }
-keep class com.google.firebase.installations.** { *; }
-keep class com.google.firebase.components.** { *; }
-keep class com.google.firebase.datatransport.** { *; }
-keep class com.google.firebase.encoders.** { *; }
-keep class com.google.firebase.heartbeatinfo.** { *; }
-keep class com.google.firebase.platforminfo.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

############################################################
# Google Play Services - Enhanced
############################################################
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-dontwarn com.google.android.play.core.**
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.internal.** { *; }

############################################################
# Kotlin / Coroutines
############################################################
-keepclassmembers class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

############################################################
# Gson / JSON (Firestore / Retrofit / APIs)
############################################################
-keep class com.google.gson.** { *; }
-keep class com.google.gson.annotations.** { *; }
-dontwarn com.google.gson.**

-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <methods>;
}

############################################################
# Play Integrity API
############################################################
-keep class com.google.android.gms.integrity.** { *; }
-dontwarn com.google.android.gms.integrity.**

############################################################
# reCAPTCHA
############################################################
-keep class com.google.android.gms.recaptcha.** { *; }
-dontwarn com.google.android.gms.recaptcha.**

############################################################
# SafetyNet
############################################################
-keep class com.google.android.gms.safetynet.** { *; }
-dontwarn com.google.android.gms.safetynet.**

############################################################
# Android - Enhanced
############################################################
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

############################################################
# Additional Release Mode Fixes
############################################################
# Keep all model classes and data classes
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep R class
-keep class **.R$* { *; }

# Keep BuildConfig
-keep class **.BuildConfig { *; }

# Prevent obfuscation of classes with custom constructors
-keepclassmembers class * {
    public <init>(...);
}

# Keep classes that are referenced in AndroidManifest.xml
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

############################################################
# OkHttp and Networking
############################################################
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

############################################################
# Retrofit and JSON
############################################################
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Exceptions

############################################################
# Multidex
############################################################
-keep class androidx.multidex.** { *; }
-dontwarn androidx.multidex.**
