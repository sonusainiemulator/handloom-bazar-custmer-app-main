import 'dart:math';
import 'package:http/http.dart' as http;
import '../other_config.dart';
import '../custom/toast_component.dart';

class BulkSmsPlansService {
  // In-memory cache for OTP codes: {phoneNumber: {otp: code, expiry: time}}
  static final Map<String, _OtpData> _otpCache = {};

  /// Generates a random 6-digit OTP code as a String.
  static String generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Sends the OTP to the specified phone number via bulksmsplans.com.
  /// If API credentials are not configured, it runs in Demo/Mock Mode.
  static Future<bool> sendOTP(String phoneNumber, String otpCode) async {
    try {
      // Normalize number format (e.g., 91XXXXXXXXXX)
      String formattedNumber = formatNumberForBulkSms(phoneNumber);
      
      // Store the OTP and its expiration time (5 minutes from now)
      _otpCache[phoneNumber] = _OtpData(
        code: otpCode,
        expiryTime: DateTime.now().add(const Duration(minutes: 5)),
      );

      final String message = "Your Handloom Bazar verification OTP is: $otpCode. Valid for 5 minutes.";
      
      // Retrieve API config credentials
      final String apiId = OtherConfig.BULK_SMS_PLANS_API_ID.trim();
      final String apiPassword = OtherConfig.BULK_SMS_PLANS_API_PASSWORD.trim();
      final String senderId = OtherConfig.BULK_SMS_PLANS_SENDER_ID.trim();
      final String smsType = OtherConfig.BULK_SMS_PLANS_SMS_TYPE.trim();

      // Check if credentials are missing or default
      if (apiId.isEmpty || apiPassword.isEmpty || apiId == "YOUR_API_ID") {
        // Run in Demo / Mock Mode
        print("\n=== [BulkSMSPlans Demo Mode] ===");
        print("Phone Number: $phoneNumber (Formatted: $formattedNumber)");
        print("OTP Code: $otpCode");
        print("Message: $message");
        print("=================================\n");
        
        ToastComponent.showDialog("[Demo Mode] OTP code is $otpCode (printed to console)");
        return true;
      }

      // Construct HTTP GET url for BulkSMSPlans
      final String url = "https://www.bulksmsplans.com/api/send_sms"
          "?api_id=${Uri.encodeComponent(apiId)}"
          "&api_password=${Uri.encodeComponent(apiPassword)}"
          "&sms_type=${Uri.encodeComponent(smsType)}"
          "&sms_encoding=text"
          "&sender=${Uri.encodeComponent(senderId)}"
          "&number=${Uri.encodeComponent(formattedNumber)}"
          "&message=${Uri.encodeComponent(message)}";

      print("[BulkSMSPlans] Requesting URL: $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print("[BulkSMSPlans] API response: ${response.body}");
        return true;
      } else {
        print("[BulkSMSPlans] API error: ${response.statusCode} - ${response.body}");
        ToastComponent.showDialog("Failed to send OTP via SMS gateway.");
        return false;
      }
    } catch (e) {
      print("[BulkSMSPlans] Exception occurred: $e");
      ToastComponent.showDialog("Error: ${e.toString()}");
      return false;
    }
  }

  /// Verifies if the entered OTP is correct and has not expired.
  static bool verifyOTP(String phoneNumber, String enteredOtp) {
    if (!_otpCache.containsKey(phoneNumber)) {
      return false;
    }
    
    final _OtpData otpData = _otpCache[phoneNumber]!;
    
    // Check expiration
    if (DateTime.now().isAfter(otpData.expiryTime)) {
      _otpCache.remove(phoneNumber); // Expired, clear it
      return false;
    }
    
    // Check match
    if (otpData.code == enteredOtp.trim()) {
      _otpCache.remove(phoneNumber); // Success, clear/consume the OTP
      return true;
    }
    
    return false;
  }

  /// Helper method to normalize a phone number into BulkSMSPlans format.
  /// Typically expects India country prefix without plus sign (e.g. 919876543210).
  static String formatNumberForBulkSms(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    
    // If it is 10 digits, prepend 91 (default Indian country code)
    if (digits.length == 10) {
      return "91$digits";
    }
    
    // If it starts with 91 and has 12 digits, return as-is
    if (digits.startsWith("91") && digits.length == 12) {
      return digits;
    }
    
    return digits;
  }
}

class _OtpData {
  final String code;
  final DateTime expiryTime;

  _OtpData({required this.code, required this.expiryTime});
}
