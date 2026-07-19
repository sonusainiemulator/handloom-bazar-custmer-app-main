# Active E-Commerce CMS Demo App
*Designed and Developed by Rakebig Service*

A comprehensive multi-vendor e-commerce platform Flutter application with a full admin CMS dashboard.

## Features

### Customer App
- **Authentication**: Email/Password, OTP-based login (with demo fallback), Google Sign-In, Apple Sign-In, Facebook Login
- **Shopping**: Product browsing, search, filtering, wishlists, product comparisons
- **Checkout**: Multi-step checkout process with coupon codes, order summary
- **Order Management**: Order tracking with timeline view, order history
- **User Profile**: Profile management, address book, notification preferences
- **Notifications**: Push notifications for orders, promotions, messages
- **Help & Support**: FAQ section, contact form, support ticket system
- **UI/UX**:
  - Modern Material Design interface
  - Image carousels and galleries
  - OTP verification screens
  - Chat/support messaging interface
  - Flutter widget showcases (`flutter_widget_showcase.dart`)

### Admin CMS Dashboard (Web)
- **User Management**: Approve/reject new user registrations, manage user roles
- **Product Management**: Add/edit/manage products, categories, attributes, stock
- **Order Management**: Process and track orders
- **Support Management**: Handle support tickets and inquiries
- **Promotions**: Manage coupon codes and promotional banners
- **Analytics**: View business insights and reports

## Getting Started

### Prerequisites
- Flutter SDK (version 3.5.0 or higher)
- Firebase project with Android and iOS apps configured

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd Handloom-Bazar-Custmer-App
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Download `google-services.json` for Android and `GoogleService-Info.plist` for iOS from your Firebase project
- Place them in the respective directories:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

4. Configure environment variables
- Create `.env.dev` and `.env.prod` files with API keys and base URLs
- Add environment variables to `lib/configs/env_config.dart`

5. Run the app
```bash
flutter run
```

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
