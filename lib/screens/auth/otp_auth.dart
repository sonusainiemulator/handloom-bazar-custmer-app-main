import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/intl_phone_input.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/custom/loading.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/common_response.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class OtpAuth extends StatefulWidget {
  final bool initialIsRegister;

  const OtpAuth({super.key, this.initialIsRegister = false});

  @override
  _OtpAuthState createState() => _OtpAuthState();
}

class _OtpAuthState extends State<OtpAuth> {
  // Toggle between Login & Register tabs
  late bool _isRegisterMode;

  // Verification stage
  bool _otpSent = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  
  // Individual controllers & focus nodes for 6-digit OTP fields
  final List<TextEditingController> _otpDigitControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpDigitFocusNodes = List.generate(6, (_) => FocusNode());

  // Phone number (full format with country code, e.g. +919876543210)
  String? _phoneComplete = "";

  // Countdown timer for Resending OTP
  Timer? _timer;
  int _timerCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    super.initState();
    _isRegisterMode = widget.initialIsRegister;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    for (var controller in _otpDigitControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpDigitFocusNodes) {
      focusNode.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  // Start the countdown timer
  void _startTimer() {
    setState(() {
      _timerCountdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timerCountdown > 0) {
            _timerCountdown--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  // Send OTP via Backend (secure — no credentials stored in app)
  Future<void> _sendOtpRequest() async {
    FocusScope.of(context).unfocus();

    if (_phoneComplete == null || _phoneComplete!.isEmpty) {
      ToastComponent.showDialog("Please enter a valid phone number");
      return;
    }

    if (_isRegisterMode) {
      if (_nameController.text.trim().isEmpty) {
        ToastComponent.showDialog("Please enter your name");
        return;
      }
      if (_passwordController.text.isEmpty) {
        ToastComponent.showDialog("Please enter password");
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
    }

    Loading.show(context);
    try {
      CommonResponse otpResponse;
      if (_isRegisterMode) {
        otpResponse = await AuthRepository().getOtpRegistrationResponse(
          _phoneComplete!,
          name: _nameController.text.trim(),
        );
      } else {
        otpResponse = await AuthRepository().getOtpLoginResponse(_phoneComplete!);
      }
      Loading.close();

      if (otpResponse.result == true) {
        setState(() { _otpSent = true; });
        _startTimer();
        ToastComponent.showDialog("OTP sent successfully!");
      } else {
        String errMsg = "Failed to send OTP. Please try again.";
        if (otpResponse.message != null) {
          errMsg = otpResponse.message.toString();
        }
        ToastComponent.showDialog(errMsg);
      }
    } catch (e) {
      Loading.close();
      print("[OtpAuth] sendOtp error: $e");
      ToastComponent.showDialog("Error sending OTP: ${e.toString()}");
    }
  }

  // Verify OTP with backend, then register/login
  Future<void> _verifyAndSubmit() async {
    FocusScope.of(context).unfocus();

    String enteredOtp = _otpDigitControllers.map((c) => c.text).join();
    if (enteredOtp.length != 6) {
      ToastComponent.showDialog("Please enter the complete 6-digit OTP code");
      return;
    }

    Loading.show(context);
    try {
      // Step 1: Verify OTP with backend
      var verifyResponse = await AuthRepository().getVerifyOtpResponse(_phoneComplete!, enteredOtp);

      if (verifyResponse.result != true) {
        Loading.close();
        String errMsg = "Invalid or expired OTP code";
        if (verifyResponse.message != null) {
          errMsg = verifyResponse.message.toString();
        }
        ToastComponent.showDialog(errMsg);
        return;
      }

      // Step 2: OTP is valid — proceed to register or login
      if (_isRegisterMode) {
        var signupResponse = await AuthRepository().getSignupResponse(
          _nameController.text.trim(),
          _phoneComplete!,
          _passwordController.text,
          _passwordConfirmController.text,
          "phone",
          tempUserId: temp_user_id.$,
        );
        Loading.close();

        if (signupResponse.result != true) {
          String errMsg = "Registration failed";
          if (signupResponse.message != null) {
            if (signupResponse.message is List) {
              errMsg = signupResponse.message.join("\n");
            } else {
              errMsg = signupResponse.message.toString();
            }
          }
          ToastComponent.showDialog(errMsg);
        } else {
          ToastComponent.showDialog(signupResponse.message?.toString() ?? "Registered successfully!");
          AuthHelper().setUserData(signupResponse);
          if (mounted) context.go("/");
        }
      } else {
        // Login: OTP verified — now authenticate with backend login-with-otp
        var loginResponse = await AuthRepository().loginWithOtp(_phoneComplete!, enteredOtp);
        Loading.close();

        if (loginResponse.result != true) {
          String errMsg = "Login failed. Please try again.";
          if (loginResponse.message != null) {
            errMsg = loginResponse.message.toString();
          }
          ToastComponent.showDialog(errMsg);
        } else if (loginResponse.access_token == null || loginResponse.access_token!.isEmpty) {
          ToastComponent.showDialog("Login failed: server did not return an access token.");
        } else {
          AuthHelper().setUserData(loginResponse);
          ToastComponent.showDialog("Login successful!");
          if (mounted) context.go("/");
        }
      }
    } catch (e) {
      Loading.close();
      print("[OtpAuth] verifyAndSubmit error: $e");
      ToastComponent.showDialog("Error: ${e.toString()}");
    }
  }

  // Clear OTP input fields
  void _clearOtpInput() {
    for (var controller in _otpDigitControllers) {
      controller.clear();
    }
    _otpDigitFocusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return AuthScreen.buildScreen(
      context,
      _otpSent 
          ? "OTP Verification" 
          : (_isRegisterMode ? "Register with OTP" : "Login with OTP"),
      _otpSent 
          ? buildOtpVerificationBody(screenWidth) 
          : buildRequestFormBody(screenWidth),
    );
  }

  // Section 1: Phone Request & Form
  Widget buildRequestFormBody(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tab Selector for Login/Registration Mode
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            width: screenWidth * 0.7,
            height: 40,
            decoration: BoxDecoration(
              color: MyTheme.light_grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isRegisterMode = false;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !_isRegisterMode ? MyTheme.accent_color : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "OTP Login",
                        style: TextStyle(
                          color: !_isRegisterMode ? Colors.white : MyTheme.font_grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isRegisterMode = true;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _isRegisterMode ? MyTheme.accent_color : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "OTP Register",
                        style: TextStyle(
                          color: _isRegisterMode ? Colors.white : MyTheme.font_grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Form Fields Container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Register Fields
              if (_isRegisterMode) ...[
                Text(
                  "Name",
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: "John Doe",
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Phone Field
              Text(
                "Phone Number",
                style: TextStyle(
                  color: MyTheme.accent_color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 38,
                child: CustomInternationalPhoneNumberInput(
                  countries: const ['IN'],
                  initialValue: PhoneNumber(isoCode: 'IN', dialCode: '+91'),
                  onInputChanged: (PhoneNumber number) {
                    setState(() {
                      _phoneComplete = number.phoneNumber;
                    });
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: const TextStyle(color: MyTheme.font_grey),
                  textStyle: const TextStyle(color: MyTheme.font_grey),
                  textFieldController: _phoneNumberController,
                  formatInput: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  inputDecoration: InputDecorations.buildInputDecoration_phone(
                    hint_text: "98765 43210",
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Register Password Fields
              if (_isRegisterMode) ...[
                Text(
                  "Password",
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: "••••••",
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Confirm Password",
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _passwordConfirmController,
                    obscureText: true,
                    decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: "••••••",
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                height: 45,
                width: double.infinity,
                child: Btn.basic(
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Text(
                    "Send OTP Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    _sendOtpRequest();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Section 2: OTP Entry & Verification
  Widget buildOtpVerificationBody(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.phonelink_ring,
            color: MyTheme.accent_color,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "We have sent a 6-digit OTP verification code to",
            style: TextStyle(color: MyTheme.font_grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _phoneComplete ?? "",
            style: TextStyle(
              color: MyTheme.accent_color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // 6 digit input boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 40,
                height: 45,
                child: TextField(
                  controller: _otpDigitControllers[index],
                  focusNode: _otpDigitFocusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.dark_font_grey,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: MyTheme.textfield_grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: MyTheme.accent_color, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      if (index < 5) {
                        _otpDigitFocusNodes[index + 1].requestFocus();
                      } else {
                        _otpDigitFocusNodes[index].unfocus();
                      }
                    } else {
                      if (index > 0) {
                        _otpDigitFocusNodes[index - 1].requestFocus();
                      }
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 30),

          // Submit Code Button
          SizedBox(
            height: 45,
            width: double.infinity,
            child: Btn.basic(
              color: MyTheme.accent_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                _isRegisterMode ? "Verify & Register" : "Verify & Login",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                _verifyAndSubmit();
              },
            ),
          ),
          const SizedBox(height: 20),

          // Countdown Timer / Resend Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the code? ",
                style: TextStyle(color: MyTheme.font_grey, fontSize: 13),
              ),
              _canResend
                  ? InkWell(
                      onTap: () {
                        _sendOtpRequest();
                      },
                      child: Text(
                        "Resend Code",
                        style: TextStyle(
                          color: MyTheme.accent_color,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : Text(
                      "Resend in ${_timerCountdown}s",
                      style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 12),

          // Go Back button
          InkWell(
            onTap: () {
              setState(() {
                _otpSent = false;
                _clearOtpInput();
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 14, color: MyTheme.font_grey),
                const SizedBox(width: 4),
                Text(
                  "Change Phone Number",
                  style: TextStyle(
                    color: MyTheme.font_grey,
                    decoration: TextDecoration.underline,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
