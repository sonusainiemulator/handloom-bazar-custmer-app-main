import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:active_ecommerce_cms_demo_app/services/bulk_sms_plans_service.dart';

class RealHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

void main() {
  HttpOverrides.global = RealHttpOverrides();

  test('Live OTP Delivery Test for 9782533298', () async {
    String testNumber = "9782533298";
    String otpCode = BulkSmsPlansService.generateOTP();

    print("==================================================");
    print("[1] Mobile Number: $testNumber");
    print("[2] BulkSMS Target Number: ${BulkSmsPlansService.formatNumberForBulkSms(testNumber)}");
    print("[3] Generated OTP Code: $otpCode");
    print("Sending live OTP request via BulkSMSPlans API...");

    bool success = await BulkSmsPlansService.sendOTP(testNumber, otpCode, name: "Customer");

    expect(success, isTrue);
    print("RESULT: SUCCESS! SMS Submitted to 9782533298.");
    print("==================================================");
  });
}
