@echo off
echo Getting SHA-256 fingerprint for release keystore...
echo.

REM Check if keystore exists
if not exist "android\app\key.jks" (
    echo ERROR: Keystore file not found at android\app\key.jks
    echo Please ensure your keystore file is in the correct location.
    pause
    exit /b 1
)

REM Check if key.properties exists
if not exist "android\key.properties" (
    echo ERROR: key.properties file not found at android\key.properties
    echo Please ensure your key.properties file exists with keystore credentials.
    pause
    exit /b 1
)

echo Found keystore file: android\app\key.jks
echo.

REM Read keystore properties
for /f "tokens=2 delims==" %%a in ('findstr "keyAlias" android\key.properties') do set KEY_ALIAS=%%a
for /f "tokens=2 delims==" %%a in ('findstr "storePassword" android\key.properties') do set STORE_PASSWORD=%%a
for /f "tokens=2 delims==" %%a in ('findstr "keyPassword" android\key.properties') do set KEY_PASSWORD=%%a

echo Using alias: %KEY_ALIAS%
echo.

echo Running keytool command...
echo.

keytool -list -v -keystore android\app\key.jks -alias %KEY_ALIAS% -storepass %STORE_PASSWORD% -keypass %KEY_PASSWORD%

echo.
echo ========================================
echo IMPORTANT: Copy the SHA-256 fingerprint from above
echo and add it to your Firebase Console:
echo.
echo 1. Go to Firebase Console
echo 2. Project Settings
echo 3. Your Android App
echo 4. Add Fingerprint
echo 5. Paste the SHA-256 value
echo ========================================
echo.
pause
