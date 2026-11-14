# Handloom Bazar Customer App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.5%2B-02569B?logo=flutter)](https://flutter.dev)
[![Current Version](https://img.shields.io/badge/version-5.4.0%2B15-brightgreen.svg)](CHANGELOG.md)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)

An e-commerce Flutter mobile application for **Handloom Bazar**—a premier multi-vendor handloom marketplace.

---

## 📱 Features

### Customer App
- **Authentication**: Email/Password, Passwordless OTP Login (Bulk SMS Plans & Firebase), Google Sign-In, Apple Sign-In, and Facebook Login.
- **Shopping Experience**: Category browsing, product search & filtering, customer reviews, wishlist, and cart management.
- **Product Video Player**: Responsive inline embed support for YouTube, Vimeo, Dailymotion, and HTML5 video content with direct external launch fallbacks.
- **Order Management & Tracking**:
  - Live milestone timeline stepper (Order Placed ➔ Confirmed ➔ On The Way ➔ Delivered).
  - Clean two-column metadata breakdown with isolated address formatting.
  - Re-order, downloadable invoice PDF generation, payment retry, and cancellation flows.
- **Checkout**: Seamless checkout flow with Razorpay, Cash on Delivery, wallet payments, coupon discounts, and instant total calculation.
- **Brand Theming**: Modern logo-red brand accent with clean white backgrounds, high-resolution branding, and rounded card styling.

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.5.0 < 4.0.0`
- **Dart SDK**: `^3.5.0`
- **Java**: JDK 17
- **Android SDK**: `compileSdk = 36`, `minSdk = 24`, `targetSdk = 36`

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/TTinfotechs01/Handloom-Bazar-Custmer-App.git
   cd Handloom-Bazar-Custmer-App
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Run the app in debug mode**:
   ```bash
   flutter run
   ```

---

## 📦 Production Builds

### Generate Release APK (for Direct Testing & Sideloading)
```bash
flutter build apk --release
```
*Output: `android/app/build/outputs/apk/release/app-release.apk`*

### Generate Production App Bundle (.AAB for Google Play Store)
```bash
cd android
./gradlew app:bundleRelease
```
*Output: `android/app/build/outputs/bundle/release/app-release.aab`*

---

## 📝 Release History & Changelog

All notable updates and version histories are documented in **[CHANGELOG.md](CHANGELOG.md)**:
- **v5.4.0+15** (2026-11-14): Redesigned Order Details milestone stepper, clean order summary layout, and checkout breakdown dialog.
- **v5.4.0+14** (2026-11-13): Product video rendering with responsive YouTube/Vimeo embeds.
- **v5.4.0+13** (2026-11-13): Logo red theme colors, white splash screen, and V1/V2 APK signing.
- **v5.4.0+12** (2026-11-13): OTP redirect resolution and R8 code shrinking for Google Play compliance.

---

## 🔑 Release Keystore & Signing Configuration

> [!IMPORTANT]
> The production release keystore file (`.jks`) is securely backed up in Google Drive for account **`socialttinfo`** (`socialttinfo@gmail.com`).
> 
> **Keystore Location**: Google Drive (`socialttinfo`) → `Handloom Bazar / Keystore / release.jks` (or configured `.jks` file).
> 
> To configure release signing locally on a new machine:
> 1. Download the release keystore file from the Google Drive account **socialttinfo**.
> 2. Place it in `android/` (or directory specified in `key.properties`).
> 3. Verify `android/key.properties` contains:
>    ```properties
>    storeFile=<path_to_keystore.jks>
>    storePassword=<password>
>    keyAlias=<alias>
>    keyPassword=<password>
>    ```

---

## 📄 License & Organization
Maintained by **TTinfotechs** for **Handloom Bazar**.

## Build Configuration

### Android Build
- **SDK Version**: Target SDK 35, Min SDK 24
- **NDK Version**: 28.0.13004108
- **Desugaring**: Enabled (core library desugaring)
- **MultiDex**: Enabled for compatibility with lower-end devices
- **Shrinking**: Disabled for release builds (see Known Issues)
- **Signing**: Debug signing falls back to debug keystore when production keystore is not found

### iOS Build
- **Frameworks**: Configured for Firebase Core, Auth, and Messaging
- **Info.plist**: Includes necessary Bluetooth and location permissions

## Environment Variables

### Development (`.env.dev`)
```env
API_URL=http://[IP_ADDRESS]/wp-json/custom_api/v2
BASE_URL=http://[IP_ADDRESS]

# Bulk SMS Plans (SendinBlue)
BULK_SMS_USERNAME=your_username
BULK_SMS_PASSWORD=your_password

# Google Sign-In
GOOGLE_CLIENT_ID=your_web_client_id
```

### Production (`.env.prod`)
```env
API_URL=http://[IP_ADDRESS]/wp-json/custom_api/v2
BASE_URL=http://[IP_ADDRESS]

# Bulk SMS Plans (SendinBlue)
BULK_SMS_USERNAME=your_production_username
BULK_SMS_PASSWORD=your_production_password

# Google Sign-In
GOOGLE_CLIENT_ID=your_web_client_id
```

## Common Commands

### Generate Assets
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Update Icons
```bash
flutter pub run flutter_launcher_icons
```

### Run Tests
```bash
flutter test
```

### Format Code
```bash
flutter format .
```

## Known Issues

### 1. App Startup Crash on Real Devices
**Issue**: `NoSuchMethodError` during session restore when `UserByTokenResponse` is passed to `AuthHelper.setUserData()` because it assumes a `user` getter that doesn't exist.
**Status**: [FIXED](#-critical:-app-startup-crash-on-real-devices)

### 2. Release Build Obfuscation (ProGuard/R8)
**Issue**: Release builds may crash on real devices with "class-not-found" errors due to aggressive code stripping by R8/ProGuard. This is particularly noticeable on lower-end Android devices or specific device configurations.
**Status**: `isMinifyEnabled = false` is set in `build.gradle.kts` for release builds to prevent this. This keeps all code available but increases APK size.

### 3. Production Keystore Required for Google Sign-In
**Issue**: Google Sign-In will only work on production builds if the production keystore SHA-1 fingerprint is registered in the Firebase Console for the Android app. On local debug builds, it works because it falls back to debug credentials.
**Fix**: Register the production SHA-1 in Firebase Console → Android App → Add fingerprint.

### 4. Android API Level Compatibility
**Issue**: Some device manufacturers (e.g., Xiaomi, Oppo, Vivo) run heavily customized Android versions that may not fully adhere to Android standards. This can cause the app to crash on startup on those specific devices.
**Status**: Enhanced with `multiDexEnabled` and `android:largeHeap` to handle low-memory devices. `extractNativeLibs="true"` added for better compatibility. However, some manufacturer-specific issues may persist that require device-specific workarounds.
