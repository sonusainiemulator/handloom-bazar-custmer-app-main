import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/intl_phone_input.dart';
import 'package:active_ecommerce_cms_demo_app/custom/loading.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:active_ecommerce_cms_demo_app/services/firebase_otp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class FirebaseOtpVerification extends StatefulWidget {
  const FirebaseOtpVerification({Key? key}) : super(key: key);

  @override
  _FirebaseOtpVerificationState createState() =>
      _FirebaseOtpVerificationState();
}

class _FirebaseOtpVerificationState extends State<FirebaseOtpVerification> {
  String initialCountry = 'IN';
  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  String phoneNumberComplete = "";

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _isPhoneNumberValid = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  // Step 1: Send OTP via Firebase
  Future<void> _sendOTP() async {
    if (!_isPhoneNumberValid || phoneNumberComplete.isEmpty) {
      ToastComponent.showDialog("Please enter a valid phone number");
      return;
    }

    Loading.show(context);

    await FirebaseOTPService.sendOTP(
      phoneNumber: phoneNumberComplete,
      onCodeSent: (String verificationId) {
        if (!mounted) return;
        Loading.close();
        setState(() => _isOtpSent = true);
        ToastComponent.showDialog("OTP sent successfully");
      },
      onError: (String error) {
        if (!mounted) return;
        Loading.close();
        ToastComponent.showDialog(error);
      },
      onVerificationCompleted: () {
        // Auto-verification (Android only)
        if (!mounted) return;
        Loading.close();
        setState(() => _isOtpVerified = true);
        ToastComponent.showDialog("Phone verified automatically!");
        _checkExistingUser();
      },
      onVerificationFailed: (String error) {
        if (!mounted) return;
        Loading.close();
        ToastComponent.showDialog(error);
      },
    );
  }

  // Step 2: Verify OTP entered by user
  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      ToastComponent.showDialog("Please enter the 6-digit OTP");
      return;
    }

    Loading.show(context);

    await FirebaseOTPService.verifyOTP(
      otpCode: _otpController.text.trim(),
      onSuccess: () {
        if (!mounted) return;
        Loading.close();
        setState(() => _isOtpVerified = true);
        ToastComponent.showDialog(
            "Phone verified! Please complete registration");
        _checkExistingUser();
      },
      onError: (String error) {
        if (!mounted) return;
        Loading.close();
        String msg = error;
        if (error.contains('invalid-verification-code')) {
          msg = "Invalid OTP. Please check and try again";
        } else if (error.contains('session-expired')) {
          msg = "OTP expired. Please request a new one";
        }
        ToastComponent.showDialog(msg);
      },
    );
  }

  // Check if user already has an account; redirect to login if so
  Future<void> _checkExistingUser() async {
    try {
      final loginResponse = await AuthRepository()
          .getPhoneLoginResponse(phoneNumberComplete, "");
      if (loginResponse.result == true && loginResponse.user != null) {
        ToastComponent.showDialog(
            "Account exists. Please enter your password to login");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Login(phoneNumber: phoneNumberComplete),
          ),
        );
      }
    } catch (_) {
      // User does not exist — continue to registration step
    }
  }

  // Step 3: Complete Registration
  Future<void> _completeRegistration() async {
    if (_nameController.text.trim().isEmpty) {
      ToastComponent.showDialog("Please enter your name");
      return;
    }
    if (_passwordController.text.length < 6) {
      ToastComponent.showDialog("Password must be at least 6 characters");
      return;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      ToastComponent.showDialog("Passwords do not match");
      return;
    }

    Loading.show(context);

    try {
      final signupResponse = await AuthRepository().signupAfterPhoneVerified(
        name: _nameController.text.trim(),
        phoneNumber: phoneNumberComplete,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        tempUserId: temp_user_id.$,
      );

      if (!mounted) return;
      Loading.close();

      if (signupResponse.result == true) {
        ToastComponent.showDialog("Registration successful!");

        if (signupResponse.user != null) {
          is_logged_in.$ = true;
          access_token.$ = signupResponse.access_token;
          user_id.$ = signupResponse.user!.id;
          user_name.$ = signupResponse.user!.name;
          user_email.$ = signupResponse.user!.email ?? "";
          user_phone.$ = signupResponse.user!.phone ?? phoneNumberComplete;
          avatar_original.$ = signupResponse.user!.avatar_original;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Main()),
          (route) => false,
        );
      } else {
        String errorMessage = "Registration failed";
        if (signupResponse.message != null) {
          errorMessage = signupResponse.message is List
              ? (signupResponse.message as List).join(', ')
              : signupResponse.message.toString();
        }
        ToastComponent.showDialog(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      Loading.close();
      ToastComponent.showDialog(
          "Registration failed: ${AuthRepository().getErrorMessage(e)}");
    }
  }

  // Resend OTP
  Future<void> _resendOTP() async {
    _otpController.clear();
    Loading.show(context);

    await FirebaseOTPService.resendOTP(
      phoneNumber: phoneNumberComplete,
      onCodeSent: (String verificationId) {
        if (!mounted) return;
        Loading.close();
        ToastComponent.showDialog("OTP resent successfully");
      },
      onError: (String error) {
        if (!mounted) return;
        Loading.close();
        ToastComponent.showDialog("Failed to resend OTP: $error");
      },
      onVerificationCompleted: () {
        if (!mounted) return;
        Loading.close();
        setState(() => _isOtpVerified = true);
        _checkExistingUser();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                _isOtpVerified
                    ? "Complete Registration"
                    : _isOtpSent
                        ? "Verify OTP"
                        : "Phone Verification",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.accent_color,
                ),
              ),

              const SizedBox(height: 40),

              // ── Step 1: Phone input ──────────────────────────────────────
              if (!_isOtpSent && !_isOtpVerified) ...[
                Text(
                  "Enter your phone number to receive OTP",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 36,
                  child: CustomInternationalPhoneNumberInput(
                    maxLength: 10,
                    onInputChanged: (PhoneNumber number) {
                      String digitsOnly = _phoneNumberController.text.replaceAll(RegExp(r'\D'), '');
                      setState(() {
                        this.number = number;
                        phoneNumberComplete = number.phoneNumber ?? "";
                        _isPhoneNumberValid = digitsOnly.length == 10;
                      });
                    },
                    onInputValidated: (bool value) {
                      String digitsOnly = _phoneNumberController.text.replaceAll(RegExp(r'\D'), '');
                      setState(() => _isPhoneNumberValid = digitsOnly.length == 10);
                    },
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: TextStyle(color: MyTheme.font_grey),
                    initialValue: number,
                    textFieldController: _phoneNumberController,
                    formatInput: true,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    inputDecoration:
                        InputDecorations.buildInputDecoration_phone_number(
                            hint_text: "01XXX XXX XXX"),
                    onSaved: (PhoneNumber number) {
                      phoneNumberComplete = number.phoneNumber ?? "";
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Btn.basic(
                  min_width: MediaQuery.of(context).size.width,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    "Send OTP",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: _sendOTP,
                ),
              ],

              // ── Step 2: OTP entry ────────────────────────────────────────
              if (_isOtpSent && !_isOtpVerified) ...[
                Text(
                  "Enter the 6-digit OTP sent to $phoneNumberComplete",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, letterSpacing: 4),
                    decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "Enter OTP"),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Btn.basic(
                        color: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text(
                          "Resend OTP",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        onPressed: _resendOTP,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Btn.basic(
                        color: MyTheme.accent_color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text(
                          "Verify OTP",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: _verifyOTP,
                      ),
                    ),
                  ],
                ),
              ],

              // ── Step 3: Registration form ────────────────────────────────
              if (_isOtpVerified) ...[
                Text(
                  "Complete your registration",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _nameController,
                    autofocus: false,
                    decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "Full Name"),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _passwordController,
                    autofocus: false,
                    obscureText: true,
                    decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "Password (min 6 characters)"),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _passwordConfirmController,
                    autofocus: false,
                    obscureText: true,
                    decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "Confirm Password"),
                  ),
                ),
                const SizedBox(height: 30),
                Btn.basic(
                  min_width: MediaQuery.of(context).size.width,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    "Complete Registration",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: _completeRegistration,
                ),
              ],

              const SizedBox(height: 30),

              // Back to login
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                  );
                },
                child: Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}