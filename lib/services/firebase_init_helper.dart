import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../firebase_options.dart';

class FirebaseInitHelper {
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  static bool get isInitialized => _isInitialized;

  /// Initialize Firebase with retry logic
  static Future<bool> ensureInitialized() async {
    // Already initialized
    if (_isInitialized) {
      _log('✅ Firebase already initialized');
      return true;
    }

    // Currently initializing, wait for it
    if (_isInitializing) {
      _log('⏳ Firebase initialization in progress, waiting...');
      int attempts = 0;
      while (_isInitializing && attempts < 30) {
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }
      return _isInitialized;
    }

    _isInitializing = true;

    try {
      // Check if already initialized by Firebase itself
      try {
        Firebase.app();
        _isInitialized = true;
        _isInitializing = false;
        _log('✅ Firebase was already initialized');
        return true;
      } catch (e) {
        // Not initialized, continue with initialization
      }

      // Initialize Firebase
      _log('🔄 Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Verify initialization
      await Future.delayed(Duration(milliseconds: 500));
      Firebase.app();

      _isInitialized = true;
      _isInitializing = false;
      _log('✅ Firebase initialized successfully');
      return true;
    } catch (e) {
      _isInitializing = false;
      _log('❌ Firebase initialization failed: $e');
      return false;
    }
  }

  static void _log(String message) {
    if (kDebugMode) {
      print('[FirebaseInit] $message');
    }
  }
}
