import 'package:active_ecommerce_cms_demo_app/services/bulk_sms_plans_service.dart';

void main() async {
  print("=======================================");
  print("   Testing OTP & Mobile Validation CLI ");
  print("=======================================");

  // Test 1: Number Validation
  String sampleInput9 = "987654321";
  String sampleInput10 = "9876543210";

  print("\n[Test 1] Mobile Number Length Checks:");
  print(" - Input: '$sampleInput9' (9 digits) -> Valid: ${sampleInput9.replaceAll(RegExp(r'\D'), '').length == 10}");
  print(" - Input: '$sampleInput10' (10 digits) -> Valid: ${sampleInput10.replaceAll(RegExp(r'\D'), '').length == 10}");

  // Test 2: Formatting
  print("\n[Test 2] BulkSMS Formatting:");
  print(" - Formatted output for '$sampleInput10': ${BulkSmsPlansService.formatNumberForBulkSms(sampleInput10)}");

  // Test 3: OTP Generation
  String generatedOtp = BulkSmsPlansService.generateOTP();
  print("\n[Test 3] Generated OTP:");
  print(" - Code: $generatedOtp (Length: ${generatedOtp.length})");

  // Test 4: Local verification test
  print("\n[Test 4] OTP Verification (Pre-Verification Check):");
  bool checkEmpty = BulkSmsPlansService.verifyOTP(sampleInput10, "000000");
  print(" - Invalid OTP verified? $checkEmpty (Expected: false)");

  print("\n=======================================");
  print("   All CLI Tests Executed Successfully!");
  print("=======================================");
}
