# Changelog

## [5.4.0+14] — 2026-11-13

### Video Player & Product Details Enhancements
- **Enhanced Product Video Renderer**: Replaced raw WebView URL loading in `VideoDescription` with responsive embed container for YouTube, Vimeo, Dailymotion, and HTML5 video files.
- **YouTube Embedding Support**: Parses YouTube standard watch links, share links (`youtu.be`), embed links, and Shorts to embed them using `youtube-nocookie.com` with `allowfullscreen`, `autoplay`, and `playsinline` parameters, bypassing YouTube's `X-Frame-Options: SAMEORIGIN` block.
- **External Video Fallback**: Added a direct button and intent handling to open videos in the native YouTube app or external web browser if embedding fails.
- **Null Safety in Product Video Checks**: Fixed null/empty check in `product_details.dart`, `digital_product_details.dart`, and `auction_products_details.dart`.

## [5.4.0+13] — 2026-11-13

### UI & Branding Enhancements
- **Theme Color Overhaul**: Changed primary accent color across the app to the official Handloom Bazar Logo Red (`#E21221`), replacing the legacy pink theme.
- **Splash Screen Redesign**: Clean pure white background with enlarged high-res logo (`260x260`) and red brand typography.
- **V1 & V2 APK Signing**: Enabled both JAR (v1) and APK Signature Scheme v2 for maximum compatibility across all Android versions.

## [5.4.0+12] — 2026-11-13

### Bug Fixes
- **Backend Redirect Fix (FormatException: <!DOCTYPE html>)**: Fixed base domain path in lib/app_config.dart from handloombazar.co.in to www.handloombazar.co.in to prevent LiteSpeed 301 HTML redirect responses that broke JSON parsing during OTP and authentication requests.
- **Compilation Fixes**: Fixed undefined InputDecorations method and parameter names in lib/screens/auth/firebase_otp_verification.dart.
- **Package Path Cleanup**: Moved MainActivity.kt to the matching com/handloombazar/shop package directory structure and updated network_security_config.xml.

## [5.4.0+9] — 2026-07-28

### Features & Updates
- **OTP Verification Improvements**: Added a backdoor OTP code (`123456`) in `BulkSmsPlansService` for testing and debugging when SMS delivery fails.
- **Improved Logging**: The dynamically generated OTP is now explicitly logged to the debug console to allow testing without the SMS gateway.
- **Build Upgrade**: Upgraded application version to `5.4.0+9` in `pubspec.yaml`.

## [5.4.0+8] — 2026-07-19

### Features & Updates
- **OTP Authentication**: Implemented passwordless login and registration via custom `OtpAuth` (`lib/screens/auth/otp_auth.dart`), integrating with the `BulkSmsPlansService` (`lib/services/bulk_sms_plans_service.dart`) to send OTPs using bulksmsplans.com gateway. Includes fallback demo mode when API keys are not provided.
- **OTP Screen Navigation**: Added "Login / Register with OTP" options to both login and registration screens, routing to the new custom verification flow.
- **Crash Prevention (Zone Guarding)**: Wrapped app initialization in `runZonedGuarded` and registered global error handlers on `FlutterError` and `PlatformDispatcher` to capture unexpected framework/platform crashes gracefully.

### Build & Cleanups
- **Build Upgrade**: Upgraded application version to `5.4.0+8` in `pubspec.yaml` to bump the Android build version code from 7 to 8.
- **Cleanup**: Removed unused dependency `flutter_downloader` and its provider/initialization configs from `pubspec.yaml`, `AndroidManifest.xml`, and `lib/main.dart`.

## [Unreleased] — 2026-04-17

### Bug Fixes
- **Critical: App startup crash on real devices** — Fixed `NoSuchMethodError` thrown during session restore when `UserByTokenResponse` was passed to `AuthHelper.setUserData()`. The method assumed a `response.user` getter which does not exist on the token-response model. Added explicit type branching (`LoginResponse` vs `UserByTokenResponse`) so each path reads the correct fields directly.

### Build & Configuration
- Android `build.gradle.kts`: updated compile/target SDK to 35, NDK to 28.0.13004108, Java 17 compile options, and enabled core library desugaring for broader API compatibility.
- Enabled `multiDexEnabled` and `android:largeHeap` to prevent OOM on low-memory devices.
- Set `isMinifyEnabled = false` and disabled ProGuard/R8 shrinking on release builds to prevent class-not-found crashes caused by aggressive code stripping.
- Updated Firebase BOM to 33.6.0 and Google Play Services Auth to 20.7.0.
- Added `android:extractNativeLibs="true"` to prevent native library load failures on older Android versions.
- Added `provider_paths.xml` resource required by `flutter_downloader` provider declaration.
- Release signing falls back to debug keystore when `key.properties` is absent, keeping local builds installable without exposing production credentials.

### Security
- Added `android/key.properties`, `*.jks`, and `*.keystore` to `.gitignore` to prevent credentials being committed to version control.
- Added `analysis_output.txt` to `.gitignore`.

### Known Issues / Pre-submission Checklist
- Facebook App ID and Client Token placeholders in `android/app/src/main/res/values/strings.xml` must be replaced with production credentials before submission.
- Release keystore SHA-1 must be registered in Firebase Console → Android App → Add fingerprint for Google Sign-In to work on production builds.
