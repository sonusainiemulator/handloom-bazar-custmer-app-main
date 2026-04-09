// Mobile-specific helper (stub implementation)
// This file provides empty implementations for mobile platforms

class WebJSHelper {
  static void clearRecaptcha() {
    // No-op on mobile platforms
    print('🧹 reCAPTCHA clearing not needed on mobile');
  }

  static Future<Map<String, dynamic>?> fetchGooglePlacesReviews(String placeId, String apiKey) async {
    // No-op on mobile platforms - would use HTTP API instead
    print('📱 Google Places reviews not available via JavaScript on mobile');
    return null;
  }
}
