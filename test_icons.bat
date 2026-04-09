@echo off
echo Building Flutter app with new icons...
echo.

echo Step 1: Clean build cache
flutter clean

echo.
echo Step 2: Get dependencies
flutter pub get

echo.
echo Step 3: Build APK for testing
flutter build apk --debug

echo.
echo ========================================
echo App icon fix completed!
echo ========================================
echo.
echo The following changes were made:
echo 1. Updated pubspec.yaml to use play_store_512.png (Icon Kitchen design)
echo 2. Removed adaptive icon configuration completely
echo 3. Using direct icon implementation to preserve exact design
echo 4. Generated new launcher icons without scaling issues
echo.
echo To test the new icon:
echo 1. Install the debug APK on your device
echo 2. Look for "Priya Fashion" app on your home screen
echo 3. The icon should now show full fit without being small/compact
echo.
echo APK location: build\app\outputs\flutter-apk\app-debug.apk
echo ========================================
pause