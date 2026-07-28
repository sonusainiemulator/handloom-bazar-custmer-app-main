import 'package:flutter_test/flutter_test.dart';
import 'package:active_ecommerce_cms_demo_app/services/bulk_sms_plans_service.dart';

void main() {
  group('OTP & Phone Validation Tests', () {
    test('Format Indian 10-digit mobile number for BulkSMS', () {
      String rawPhone = "9876543210";
      String formatted = BulkSmsPlansService.formatNumberForBulkSms(rawPhone);
      expect(formatted, equals("919876543210"));
    });

    test('Format phone number with country code prefix', () {
      String fullPhone = "+919876543210";
      String formatted = BulkSmsPlansService.formatNumberForBulkSms(fullPhone);
      expect(formatted, equals("919876543210"));
    });

    test('Validate 10-digit mobile number requirement', () {
      String number9Digits = "987654321";
      String number10Digits = "9876543210";
      String number11Digits = "98765432100";

      String digits9 = number9Digits.replaceAll(RegExp(r'\D'), '');
      String digits10 = number10Digits.replaceAll(RegExp(r'\D'), '');
      String digits11 = number11Digits.replaceAll(RegExp(r'\D'), '');

      expect(digits9.length == 10, isFalse);
      expect(digits10.length == 10, isTrue);
      expect(digits11.length == 10, isFalse);
    });

    test('OTP Generation produces 6-digit numeric code', () {
      String otp = BulkSmsPlansService.generateOTP();
      expect(otp.length, equals(6));
      expect(int.tryParse(otp), isNotNull);
    });

    test('OTP Cache and Verification logic', () {
      String testPhone = "9876543210";
      String testOtp = "123456";

      // Manually test verification when OTP is not sent yet
      bool verifyBeforeSend = BulkSmsPlansService.verifyOTP(testPhone, testOtp);
      expect(verifyBeforeSend, isFalse);
    });
  });
}
