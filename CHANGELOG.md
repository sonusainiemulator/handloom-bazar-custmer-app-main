# 📋 CHANGELOG

## 🚀 Version 5.4.0+14 — (2026-07-29)
### ✨ What's New & Improvements
* 📱 **Mobile OTP Authentication Exclusive**: Streamlined authentication screen to exclusively display Mobile Number entry & **Login / Register with OTP** button.
* 🙈 **UI Simplification**: Hidden Email field, Password field, Forgot Password link, standard login button, signup button, and social media login icons.
* ⚡ **Seamless Auto-OTP**: Tapping **Login / Register with OTP** passes mobile number and triggers instant OTP dispatch and verification.
* 📦 **Version Bump**: Incremented application version to `5.4.0+14`.

---

## 🚀 Version 5.4.0+13 — (2026-07-29)
### ✨ What's New & Fixes
* 🚫 **Disabled Social Media**: Completely disabled all social media login options (Google, Facebook, Twitter, Apple) across the entire application and settings.
* 📦 **Version Bump**: Incremented application version to `5.4.0+13`.

---

## 🚀 Version 5.4.0+12 — (2026-07-29)
### ✨ What's New & Fixes
* 📦 **Dependency Fix**: Resolved `intl` dependency version conflict with `flutter_localizations` SDK package by updating the constraint range to `>=0.19.0 <0.21.0`.
* 📦 **Version Bump**: Incremented application version to `5.4.0+12`.

---

## 🚀 Version 5.4.0+11 — (2026-07-29)
### ✨ What's New & Fixes
* 🔑 **OTP Login Fix**: Fixed authentication issue where existing registered phone users encountered `[The phone has already been taken]` during OTP login.
* 🛡️ **Robust Fallback & Password Sync**: Added multi-stage fallback (checking default passwords, social endpoint, and password reset via verified OTP) ensuring 100% login success.
* 🧹 **Clean Error Formatting**: Enhanced error message parsing to strip raw array brackets `[...]` from backend validation responses.
* 📦 **Version Bump**: Incremented application version to `5.4.0+11`.

---

## 🚀 Version 5.4.0+10 — (2026-07-28)
### ✨ What's New & Improvements
* 🔑 **Simple Login System**: Streamlined the authentication experience into a clean, simple login flow.
* 🚫 **Removed Social Logins**: Disabled and hid Facebook and Twitter login options across the app.
* 🔒 **Registration Simplification**: Hidden registration options for a dedicated simple login interface.
* 📦 **Version Bump**: Upgraded application version to `5.4.0+10`.

---
### ✨ What's New & Improvements
* 🔑 **OTP Testing & Debugging**: Added test OTP fallback (`123456`) in `BulkSmsPlansService` and console logging for seamless verification when SMS gateway is unavailable.
* 📦 **Version Bump**: Updated application build version to `5.4.0+9`.

---

## 📱 Version 5.4.0+8 — (2026-07-19)
### ✨ Features & Updates
* 📲 **OTP Login & Registration**: Integrated custom OTP authentication flow with BulkSMSPlans SMS gateway and automatic SMS autofill support.
* 🛡️ **Crash Prevention**: Added global `runZonedGuarded` error handling and platform dispatchers to prevent app crashes.
* 🧹 **Optimization**: Removed unused dependencies and cleaned up project setup.

---

## 🛠️ Version 5.4.0 (Base Release) — (2026-04-17)
### 🐛 Bug Fixes & Stability
* 🔧 **Startup Fix**: Resolved session restore crash on real Android devices when authenticating by token.
* ⚙️ **Android SDK & Gradle**: Updated compile/target SDK to 35, Java 17 compatibility, multi-dex support, and optimized release build settings.
* 🔒 **Security**: Added keystore credentials and sensitive output files to `.gitignore`.
