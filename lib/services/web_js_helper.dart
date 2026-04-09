// Web-specific JavaScript helper
// This file should only be imported on web platform

import 'dart:js' as js;

class WebJSHelper {
  static void clearRecaptcha() {
    try {
      js.context.callMethod('eval', ['window.hideRecaptchaModal && window.hideRecaptchaModal()']);
      js.context.callMethod('eval', ['window.refreshRecaptcha && window.refreshRecaptcha()']);
      print('🧹 Cleared web reCAPTCHA via JavaScript');
    } catch (e) {
      print('⚠️ Could not clear reCAPTCHA: $e');
    }
  }

  static Future<Map<String, dynamic>?> fetchGooglePlacesReviews(String placeId, String apiKey) async {
    try {
      final result = await js.context.callMethod('fetchGooglePlacesReviews', [placeId, apiKey]);
      
      if (result != null) {
        final data = js.context['JSON'].callMethod('parse', [js.context['JSON'].callMethod('stringify', [result])]);
        return Map<String, dynamic>.from(data);
      }
    } catch (e) {
      print('Error calling JavaScript function: $e');
    }
    return null;
  }
}
