import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:active_ecommerce_cms_demo_app/other_config.dart';
import 'package:active_ecommerce_cms_demo_app/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

// Conditional import for platform-specific JavaScript helpers
import 'mobile_js_helper.dart' if (dart.library.js) 'web_js_helper.dart';

class FirebaseOTPService {
  static FirebaseAuth? _authInstance;
  static ConfirmationResult? _webConfirmationResult;
  static String? _verificationId;
  
  // Get or initialize Firebase Auth with retry logic
  static Future<FirebaseAuth> _getAuth() async {
    // If already have instance, return it
    if (_authInstance != null) {
      _debugLog('✅ Using cached Firebase Auth instance');
      return _authInstance!;
    }
    
    Object? lastError;
    
    // Try up to 3 times
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        _debugLog('🔄 Attempt $attempt to get Firebase Auth...');
        
        // Check if Firebase is already initialized
        try {
          Firebase.app();
          _authInstance = FirebaseAuth.instance;
          _debugLog('✅ Firebase Auth obtained from existing app');
          return _authInstance!;
        } catch (e) {
          // Firebase not initialized, try to initialize it
          _debugLog('⚠️ Firebase not initialized, attempting to initialize...');
          
          try {
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            );
            
            // Wait longer for Firebase to be ready
            await Future.delayed(Duration(milliseconds: 1000));
            
            // Verify it's initialized
            Firebase.app();
            
            _authInstance = FirebaseAuth.instance;
            _debugLog('✅ Firebase initialized successfully and Auth obtained');
            return _authInstance!;
          } on FirebaseException catch (initError) {
            lastError = initError;
            if (initError.code == 'duplicate-app') {
              // App already exists, just get the instance
              _debugLog('⚠️ Duplicate app error, getting existing instance');
              try {
                Firebase.app();
                _authInstance = FirebaseAuth.instance;
                _debugLog('✅ Got Auth instance after duplicate-app error');
                return _authInstance!;
              } catch (e) {
                lastError = e;
                _debugLog('❌ Could not get instance after duplicate-app: $e');
              }
            } else {
              _debugLog('❌ Firebase init error: ${initError.code} - ${initError.message}');
              
              // Fallback: Try initializing without options (uses google-services.json)
              if (!kIsWeb) {
                try {
                  _debugLog('🔄 Attempting fallback initialization (native config)...');
                  await Firebase.initializeApp();
                  
                  // Wait for Firebase to be ready
                  await Future.delayed(Duration(milliseconds: 500));
                  Firebase.app();
                  
                  _authInstance = FirebaseAuth.instance;
                  _debugLog('✅ Firebase initialized successfully with native config');
                  return _authInstance!;
                } catch (e2) {
                  _debugLog('❌ Fallback initialization failed: $e2');
                }
              }
            }
          } catch (e) {
            lastError = e;
          }
        }
      } catch (e) {
        lastError = e;
        _debugLog('❌ Attempt $attempt failed: $e');
      }
      
      // Wait before retry (except on last attempt)
      if (attempt < 3) {
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
    
    // Last resort: try to get FirebaseAuth.instance directly
    try {
      _debugLog('🔄 Last resort: trying to get FirebaseAuth.instance directly...');
      _authInstance = FirebaseAuth.instance;
      _debugLog('✅ Got Auth instance as last resort');
      return _authInstance!;
    } catch (e) {
      lastError = e;
      _debugLog('❌ All attempts failed. Firebase could not be initialized: $e');
      throw lastError ?? Exception("Failed to initialize Firebase Auth");
    }
  }

  // Debug logging helper
  static void _debugLog(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  /// Send OTP
  static Future<bool> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function() onVerificationCompleted,
    Function(String)? onVerificationFailed,
  }) async {
    try {
      _debugLog('🔥 Sending OTP to: $phoneNumber');
      
      // Get Firebase Auth instance (will initialize if needed)
      FirebaseAuth auth;
      try {
        auth = await _getAuth();
      } catch (e) {
        _debugLog('❌ Failed to get Firebase Auth: $e');
        onError('Firebase Initialization Failed:\n$e\n\nPlease restart the app.');
        return false;
      }
      
      _debugLog('✅ Firebase Auth ready for OTP');

      if (kIsWeb) {
        _debugLog('🌐 Web platform detected - using signInWithPhoneNumber');

        // Clear any previous verification data
        _webConfirmationResult = null;

        try {
          // Clear any existing reCAPTCHA
          _clearWebRecaptcha();

          // Wait a moment for cleanup
          await Future.delayed(Duration(milliseconds: 500));

          _debugLog('🔄 Attempting to send OTP with fresh reCAPTCHA...');

          // Web OTP using ConfirmationResult and reCAPTCHA handled internally
          _webConfirmationResult = await auth.signInWithPhoneNumber(
            phoneNumber,
          );

          if (_webConfirmationResult != null) {
            _debugLog('✅ Web OTP sent successfully');
            onCodeSent('code-sent-web');
            return true;
          } else {
            _debugLog('❌ Failed to get confirmation result');
            onError('Failed to send OTP. Please try again.');
            return false;
          }
        } on FirebaseAuthException catch (e) {
          _debugLog('❌ Firebase Auth Error: ${e.code} - ${e.message}');

          if (e.code == 'invalid-app-credential' ||
              e.code == 'captcha-check-failed') {
            _debugLog(
              '❌ reCAPTCHA verification failed. This is a known issue with Firebase Web.',
            );
            _debugLog(
              '💡 Suggesting user to refresh the page or try mobile app.',
            );

            onError(
              'Phone verification is having issues on web browser.\n\nPlease try:\n1. Refresh this page (F5)\n2. Clear browser cache\n3. Try in incognito mode\n4. Use mobile app if available',
            );
            return false;
          } else {
            rethrow;
          }
        }
      } else {
        // Mobile OTP using verifyPhoneNumber
        _debugLog('📱 Mobile platform - using verifyPhoneNumber');
        await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            _debugLog('✅ Auto-verification completed');
            await auth.signInWithCredential(credential);
            onVerificationCompleted();
          },
          verificationFailed: (FirebaseAuthException e) {
            final error = e.message ?? "Verification failed";
            if (onVerificationFailed != null) {
              onVerificationFailed(error);
            } else {
              onError(error);
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _debugLog('❌ Firebase Auth Error: ${e.code} - ${e.message}');

      // Enhanced error handling for release mode
      String errorMessage = _getFirebaseErrorMessage(e);
      onError(errorMessage);
      return false;
    } catch (e) {
      _debugLog('❌ Unexpected error: $e');
      onError('Network error. Please check your connection and try again.');
      return false;
    }
  }

  /// Verify OTP
  static Future<bool> verifyOTP({
    required String otpCode,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      FirebaseAuth auth;
      try {
        auth = await _getAuth();
      } catch (e) {
        onError("Firebase Init Error: $e");
        return false;
      }
      
      if (kIsWeb) {
        if (_webConfirmationResult == null) {
          onError("Session expired. Please request OTP again.");
          return false;
        }
        final userCredential = await _webConfirmationResult!.confirm(
          otpCode.trim(),
        );
        if (userCredential.user != null) {
          onSuccess();
          return true;
        } else {
          onError("Verification failed. Please try again.");
          return false;
        }
      } else {
        if (_verificationId == null) {
          onError("Verification ID not found. Please request OTP again.");
          return false;
        }
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otpCode.trim(),
        );
        final userCredential = await auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          onSuccess();
          return true;
        } else {
          onError("Verification failed. Please try again.");
          return false;
        }
      }
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }

  /// Format phone number for Firebase
  static String formatPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!cleaned.startsWith('+')) {
      cleaned = '${OtherConfig.defaultPhoneCountryCode}$cleaned';
    }
    return cleaned;
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    RegExp phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(cleaned);
  }

  /// Resend OTP
  static Future<bool> resendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function() onVerificationCompleted,
  }) async {
    // Clear previous verification data
    _verificationId = null;
    _webConfirmationResult = null;

    return await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onVerificationCompleted: onVerificationCompleted,
    );
  }

  /// Utility methods
  static String? getVerificationId() => _verificationId;

  static void clearVerificationData() {
    _verificationId = null;
    _webConfirmationResult = null;
  }

  static Future<User?> getCurrentUser() async {
    try {
      final auth = await _getAuth();
      return auth.currentUser;
    } catch (e) {
      return null;
    }
  }
  
  static Future<bool> isUserSignedIn() async {
    try {
      final auth = await _getAuth();
      return auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  static Future<void> signOut() async {
    try {
      final auth = await _getAuth();
      await auth.signOut();
    } catch (e) {
      _debugLog('Error signing out: $e');
    }
    clearVerificationData();
  }

  /// Clear web reCAPTCHA to prevent token conflicts
  static void _clearWebRecaptcha() {
    if (kIsWeb) {
      try {
        WebJSHelper.clearRecaptcha();
      } catch (e) {
        _debugLog('⚠️ Could not clear reCAPTCHA: $e');
      }
    }
  }

  /// Get user-friendly error messages for Firebase Auth errors
  static String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid phone number with country code';
      case 'too-many-requests':
        return 'Too many attempts. Please wait 5 minutes and try again';
      case 'quota-exceeded':
        return 'SMS limit reached. Please try again later';
      case 'invalid-verification-code':
        return 'Wrong OTP code. Please check and try again';
      case 'invalid-verification-id':
      case 'session-expired':
        return 'OTP expired. Please request a new code';
      case 'invalid-app-credential':
        return 'App verification failed. This is a release mode issue.\n\nPlease ensure:\n1. App is signed with correct certificate\n2. SHA-256 fingerprint is added to Firebase\n3. Google Play Integrity is properly configured';
      case 'captcha-check-failed':
        return 'Security verification failed. This may be due to Play Integrity checks.\n\nPlease try:\n1. Restart the app\n2. Check internet connection\n3. Contact support if issue persists';
      case 'recaptcha-not-enabled':
        return 'Phone verification temporarily unavailable';
      case 'network-request-failed':
        return 'No internet connection. Please check and try again';
      case 'app-not-authorized':
        return 'App not authorized for Firebase. Please contact support';
      case 'missing-phone-number':
        return 'Please enter your phone number';
      case 'operation-not-allowed':
        return 'Phone verification not enabled. Contact support';
      case 'credential-already-in-use':
        return 'This phone number is already registered';
      case 'user-disabled':
        return 'Account disabled. Please contact support';
      default:
        // Enhanced error handling for Play Integrity issues
        String message = e.message ?? 'Something went wrong. Please try again';

        // Check for Play Integrity specific errors
        if (message.contains('Play Integrity') ||
            message.contains('app identifier') ||
            message.contains('reCAPTCHA checks were unsuccessful')) {
          return 'App verification failed. This is a known issue in release mode.\n\nSolutions:\n1. Ensure app is properly signed\n2. Add SHA-256 certificate to Firebase Console\n3. Enable Play Integrity API\n4. Try using debug version if available';
        }

        if (message.contains('Firebase') || message.contains('auth/')) {
          return 'Verification failed. Please try again';
        }
        return message;
    }
  }
}
