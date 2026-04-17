# Changelog

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
