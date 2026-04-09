import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../firebase_options.dart';

/// Enhanced Firebase service with improved initialization and error handling
/// This service provides better Firebase integration with retry logic and user-friendly errors
class EnhancedFirebaseService {
  static bool _isInitialized = false;
  static FirebaseAuth? _authInstance;
  
  /// Get Firebase Auth instance with automatic initialization
  /// Includes retry logic and proper error handling
  static Future<FirebaseAuth> getAuth() async {
    if (_isInitialized && _authInstance != null) {
      return _authInstance!;
    }
    
    await _initializeFirebase();
    return _authInstance!;
  }
  
  /// Initialize Firebase with enhanced error handling
  static Future<void> _initializeFirebase() async {
    try {
      print('🔄 Enhanced Firebase initialization starting...');
      
      // Multiple initialization strategies
      await _initializeWithFallbacks();
      
      // Additional initialization delay for stability
      await Future.delayed(Duration(milliseconds: 1500));
      
      // Verify Firebase app is ready
      Firebase.app();
      
      _authInstance = FirebaseAuth.instance;
      _isInitialized = true;
      
      print('✅ Enhanced Firebase initialization successful');
    } catch (e) {
      print('❌ Enhanced Firebase initialization failed: $e');
      throw FirebaseException(
        plugin: 'firebase_core',
        code: 'initialization-error',
        message: 'Failed to initialize Firebase: $e',
      );
    }
  }
  
  /// Initialize Firebase with multiple fallback strategies
  static Future<void> _initializeWithFallbacks() async {
    try {
      // Primary initialization with options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print('⚠️ Primary initialization failed, trying fallback...');
      
      // Fallback 1: Try without options for native platforms
      if (!kIsWeb) {
        try {
          await Firebase.initializeApp();
          print('✅ Firebase initialized with native config');
          return;
        } catch (e2) {
          print('❌ Native config fallback failed: $e2');
        }
      }
      
      // Fallback 2: Check if app is already initialized
      try {
        Firebase.app();
        print('✅ Firebase already initialized');
        return;
      } catch (e3) {
        print('❌ Firebase not available: $e3');
      }
      
      rethrow;
    }
  }
  
  /// Enhanced phone verification with comprehensive retry logic
  static Future<bool> verifyPhoneWithRetry(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String) onError,
    required Function() onVerificationCompleted,
    Function(String)? onVerificationFailed,
    int maxRetries = 3,
  }) async {
    
    // Enhanced phone number validation and formatting
    String? formattedPhone = _formatAndValidatePhone(phoneNumber);
    if (formattedPhone == null) {
      onError('Invalid phone number format. Please include country code (e.g., +1234567890).');
      return false;
    }
    
    // Check Firebase app status first
    try {
      Firebase.app();
    } catch (e) {
      onError('Firebase not initialized. Please restart the app and try again.');
      return false;
    }
    
    // Retry logic with exponential backoff
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔄 Phone verification attempt $attempt of $maxRetries');
        
        final auth = await getAuth();
        
        await auth.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            print('✅ Auto-verification completed');
            await auth.signInWithCredential(credential);
            onVerificationCompleted();
          },
          verificationFailed: (FirebaseAuthException e) {
            final errorMessage = _getUserFriendlyError(e);
            if (onVerificationFailed != null) {
              onVerificationFailed(errorMessage);
            } else {
              onError(errorMessage);
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            print('✅ Code sent successfully');
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print('⚠️ Auto-retrieval timeout');
          },
          timeout: Duration(seconds: 60),
        );
        
        return true;
      } catch (e) {
        print('❌ Phone verification attempt $attempt failed: $e');
        
        if (attempt == maxRetries) {
          onError('Phone verification failed after $maxRetries attempts. Please check your connection and try again.');
          return false;
        }
        
        // Exponential backoff delay
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    return false;
  }
  
  /// Enhanced OTP verification with better error handling
  static Future<bool> verifyOTPWithRetry({
    required String otpCode,
    required String verificationId,
    required Function() onSuccess,
    required Function(String) onError,
    int maxRetries = 2,
  }) async {
    
    // Input validation
    if (otpCode.trim().isEmpty) {
      onError('Please enter the OTP code.');
      return false;
    }
    
    if (otpCode.length != 6) {
      onError('OTP code must be 6 digits.');
      return false;
    }
    
    // Retry logic for network issues
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final auth = await getAuth();
        
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otpCode.trim(),
        );
        
        final userCredential = await auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          onSuccess();
          return true;
        } else {
          if (attempt == maxRetries) {
            onError('Invalid OTP code. Please check and try again.');
            return false;
          }
        }
      } catch (e) {
        if (attempt == maxRetries) {
          onError('OTP verification failed. Please check the code and try again.');
          return false;
        }
        
        await Future.delayed(Duration(seconds: 1));
      }
    }
    
    return false;
  }
  
  /// Format and validate phone number with country code
  static String? _formatAndValidatePhone(String phoneNumber) {
    if (phoneNumber.isEmpty) return null;
    
    // Remove common formatting characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    
    // Ensure it starts with country code
    if (!cleaned.startsWith('+')) {
      // Add default country code (US/Canada) if not specified
      // You might want to make this configurable
      cleaned = '+1$cleaned';
    }
    
    // Enhanced validation
    RegExp phoneRegex = RegExp(r'^\+[1-9]\d{6,14}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return null;
    }
    
    return cleaned;
  }
  
  /// Get user-friendly error messages for Firebase Auth errors
  static String _getUserFriendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format. Please include country code (e.g., +1234567890).';
      
      case 'too-many-requests':
        return 'Too many verification attempts. Please wait 5 minutes and try again.';
      
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later or contact support.';
      
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check the 6-digit code sent to your phone.';
      
      case 'invalid-verification-id':
      case 'session-expired':
        return 'Verification session expired. Please request a new OTP code.';
      
      case 'invalid-app-credential':
        return 'App verification failed. This is a release mode issue.\n\nPlease:\n1. Restart the app\n2. Ensure you have a stable internet connection\n3. Contact support if the issue persists';
      
      case 'captcha-check-failed':
        return 'Security verification failed. Please restart the app and try again.';
      
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      
      case 'app-not-authorized':
        return 'App not authorized for Firebase services. Please contact support.';
      
      case 'missing-phone-number':
        return 'Phone number is required for verification.';
      
      case 'operation-not-allowed':
        return 'Phone verification is not enabled for this app.';
      
      case 'credential-already-in-use':
        return 'This phone number is already registered with another account.';
      
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      
      case 'invalid-email':
        return 'Invalid email address format.';
      
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      
      case 'user-not-found':
        return 'No account found with this email/phone number.';
      
      default:
        // Enhanced error handling for unknown errors
        String message = e.message ?? 'An unknown error occurred';
        
        // Check for common patterns
        if (message.contains('Play Integrity') ||
            message.contains('app identifier') ||
            message.contains('reCAPTCHA checks were unsuccessful')) {
          return 'App verification failed. This is a security check issue.\n\nPlease try:\n1. Restart the app\n2. Check internet connection\n3. Contact support if issue persists';
        }
        
        if (message.contains('Firebase') || message.contains('auth/')) {
          return 'Authentication service error. Please try again.';
        }
        
        return message;
    }
  }
  
  /// Check current user status
  static Future<User?> getCurrentUser() async {
    try {
      final auth = await getAuth();
      return auth.currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  /// Check if user is signed in
  static Future<bool> isUserSignedIn() async {
    try {
      final auth = await getAuth();
      return auth.currentUser != null;
    } catch (e) {
      print('Error checking user sign-in status: $e');
      return false;
    }
  }
  
  /// Sign out current user
  static Future<void> signOut() async {
    try {
      final auth = await getAuth();
      await auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }
  
  /// Clear all Firebase data and reinitialize
  static Future<void> resetFirebase() async {
    try {
      _isInitialized = false;
      _authInstance = null;
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await getAuth();
      print('✅ Firebase reset and reinitialized');
    } catch (e) {
      print('❌ Firebase reset failed: $e');
    }
  }
  
  /// Get Firebase app status for debugging
  static String getFirebaseStatus() {
    try {
      Firebase.app();
      return 'Firebase App: ✅ Initialized\nFirebase Auth: ${_authInstance != null ? '✅ Ready' : '❌ Not Ready'}';
    } catch (e) {
      return 'Firebase App: ❌ Not Available\nError: $e';
    }
  }
}
