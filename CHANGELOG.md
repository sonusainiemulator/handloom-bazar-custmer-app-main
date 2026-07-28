# 📋 CHANGELOG

## 🚀 Version 5.4.0+9 — (2026-07-28)
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
