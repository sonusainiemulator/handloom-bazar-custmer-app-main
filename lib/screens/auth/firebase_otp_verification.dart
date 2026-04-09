import 'package:active_ecommerce_flutter/custom/aiz_route.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/custom/loading_dialog.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/main.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/screens/auth/login.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/services/firebase_otp_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toast/toast.dart';

class FirebaseOtpVerification extends StatefulWidget {
  const FirebaseOtpVerification({Key? key}) : super(key: key);

  @override
  _FirebaseOtpVerificationState createState() => _FirebaseOtpVerificationState();
}

class _FirebaseOtpVerificationState extends State<FirebaseOtpVerification> {
  String initialCountry = 'IN';
  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  String phoneNumberComplete = "";
  
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  
  bool _isPhoneNumberValid = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  bool _isRegistering = false;
  
  String _verificationId = '';
  int? _resendToken;
  User? _firebaseUser;
  
  late FirebaseOtpService _firebaseOtpService;

  @override
  void initState() {
    super.initState();
    _firebaseOtpService = FirebaseOtpService();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  // Step 1: Send OTP to phone number
  Future<void> _sendOTP() async {
    if (!_isPhoneNumberValid) {
      ToastComponent.showDialog(LangText(context).local.enter_phone_number, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseOtpService.sendOTP(
        phoneNumber: phoneNumberComplete,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          print("Auto verification completed");
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          
          String errorMessage = "Verification failed";
          if (e.code == 'invalid-phone-number') {
            errorMessage = "Invalid phone number format";
          } else if (e.code == 'too-many-requests') {
            errorMessage = "Too many requests. Please try again later";
          } else if (e.code == 'quota-exceeded') {
            errorMessage = "Quota exceeded. Please try again later";
          }
          
          ToastComponent.showDialog(errorMessage, gravity: Toast.center, duration: Toast.lengthLong);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isOtpSent = true;
            _isLoading = false;
          });
          
          ToastComponent.showDialog("OTP sent successfully", gravity: Toast.center, duration: Toast.lengthLong);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastComponent.showDialog("Failed to send OTP: ${e.toString()}", gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  // Step 2: Verify OTP
  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ToastComponent.showDialog("Please enter 6 digit OTP", gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );

      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      String errorMessage = "Invalid OTP";
      if (e.toString().contains('invalid-verification-code')) {
        errorMessage = "Invalid OTP. Please check and try again";
      } else if (e.toString().contains('session-expired')) {
        errorMessage = "OTP expired. Please request a new one";
      }
      
      ToastComponent.showDialog(errorMessage, gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  // Sign in with phone credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      _firebaseUser = userCredential.user;
      
      if (_firebaseUser != null) {
        setState(() {
          _isOtpVerified = true;
          _isLoading = false;
        });
        
        ToastComponent.showDialog("Phone verified successfully! Please complete registration", 
            gravity: Toast.center, duration: Toast.lengthLong);
        
        // Check if user already exists in our database
        await _checkExistingUser();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastComponent.showDialog("Verification failed: ${e.toString()}", gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  // Check if user already exists and try to log them in
  Future<void> _checkExistingUser() async {
    try {
      // Try to login with phone number (without password first)
      var loginResponse = await AuthRepository().getPhoneLoginResponse(phoneNumberComplete, "");
      
      if (loginResponse.result == true && loginResponse.user != null) {
        // User exists, redirect to login page for password entry
        ToastComponent.showDialog("Account exists. Please enter your password to login", 
            gravity: Toast.center, duration: Toast.lengthLong);
        
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => 
            Login(phoneNumber: phoneNumberComplete)));
        return;
      }
    } catch (e) {
      // User doesn't exist, continue with registration
      print("User doesn't exist, proceeding with registration: $e");
    }
  }

  // Step 3: Complete Registration
  Future<void> _completeRegistration() async {
    if (_nameController.text.trim().isEmpty) {
      ToastComponent.showDialog("Please enter your name", gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (_passwordController.text.length < 6) {
      ToastComponent.showDialog("Password must be at least 6 characters", gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      ToastComponent.showDialog("Passwords do not match", gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      var signupResponse = await AuthRepository().verifyFirebaseOTP(
        name: _nameController.text.trim(),
        phoneNumber: phoneNumberComplete,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
      );

      setState(() {
        _isRegistering = false;
      });

      if (signupResponse.result == true) {
        // Registration successful
        ToastComponent.showDialog("Registration successful!", gravity: Toast.center, duration: Toast.lengthLong);
        
        // Save user data
        if (signupResponse.user != null) {
          is_logged_in.$ = true;
          access_token.$ = signupResponse.access_token;
          user_id.$ = signupResponse.user!.id;
          user_name.$ = signupResponse.user!.name;
          user_email.$ = signupResponse.user!.email ?? "";
          user_phone.$ = signupResponse.user!.phone ?? phoneNumberComplete;
          avatar_original.$ = signupResponse.user!.avatar_original;
        }

        // Navigate to main app
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Main()),
          (route) => false,
        );
      } else {
        // Registration failed
        String errorMessage = "Registration failed";
        if (signupResponse.message != null) {
          if (signupResponse.message is List) {
            errorMessage = (signupResponse.message as List).join(', ');
          } else {
            errorMessage = signupResponse.message.toString();
          }
        }
        ToastComponent.showDialog(errorMessage, gravity: Toast.center, duration: Toast.lengthLong);
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      
      String errorMessage = AuthRepository().getErrorMessage(e);
      ToastComponent.showDialog("Registration failed: $errorMessage", gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  // Resend OTP
  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _otpController.clear();
    });

    try {
      await _firebaseOtpService.resendOTP(
        phoneNumber: phoneNumberComplete,
        resendToken: _resendToken,
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isLoading = false;
          });
          ToastComponent.showDialog("OTP resent successfully", gravity: Toast.center, duration: Toast.lengthLong);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          ToastComponent.showDialog("Failed to resend OTP: ${e.message}", gravity: Toast.center, duration: Toast.lengthLong);
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastComponent.showDialog("Failed to resend OTP: ${e.toString()}", gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingDialog(
        isLoading: _isLoading || _isRegistering,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                
                // Logo/Title
                Text(
                  _isOtpVerified ? "Complete Registration" : 
                  _isOtpSent ? "Verify OTP" : "Phone Verification",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.accent_color,
                  ),
                ),
                
                SizedBox(height: 40),

                // Step 1: Phone Number Input
                if (!_isOtpSent && !_isOtpVerified) ...[
                  Text(
                    "Enter your phone number to receive OTP",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  
                  Container(
                    height: 36,
                    child: CustomInternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        setState(() {
                          this.number = number;
                          phoneNumberComplete = number.phoneNumber ?? "";
                          _isPhoneNumberValid = phoneNumberComplete.length > 10;
                        });
                      },
                      onInputValidated: (bool value) {
                        setState(() {
                          _isPhoneNumberValid = value;
                        });
                      },
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: MyTheme.font_grey),
                      initialValue: number,
                      textFieldController: _phoneNumberController,
                      formatInput: true,
                      keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputDecoration: InputDecorations.buildInputDecoration_phone_number(hint_text: "01XXX XXX XXX"),
                      onSaved: (PhoneNumber number) {
                        phoneNumberComplete = number.phoneNumber ?? "";
                      },
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  Btn.basic(
                    min_width: MediaQuery.of(context).size.width,
                    color: MyTheme.accent_color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      "Send OTP",
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    onPressed: _sendOTP,
                  ),
                ],

                // Step 2: OTP Verification
                if (_isOtpSent && !_isOtpVerified) ...[
                  Text(
                    "Enter the 6-digit OTP sent to $phoneNumberComplete",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  
                  Container(
                    height: 36,
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, letterSpacing: 4),
                      decoration: InputDecorations.buildInputDecoration_1(hint_text: "Enter OTP"),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Btn.basic(
                          color: Colors.grey[300],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                          onPressed: _resendOTP,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Btn.basic(
                          color: MyTheme.accent_color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            "Verify OTP",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          onPressed: _verifyOTP,
                        ),
                      ),
                    ],
                  ),
                ],

                // Step 3: Complete Registration
                if (_isOtpVerified) ...[
                  Text(
                    "Complete your registration",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  
                  Container(
                    height: 36,
                    child: TextField(
                      controller: _nameController,
                      autofocus: false,
                      decoration: InputDecorations.buildInputDecoration_1(hint_text: "Full Name"),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  Container(
                    height: 36,
                    child: TextField(
                      controller: _passwordController,
                      autofocus: false,
                      obscureText: true,
                      decoration: InputDecorations.buildInputDecoration_1(hint_text: "Password (min 6 characters)"),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  Container(
                    height: 36,
                    child: TextField(
                      controller: _passwordConfirmController,
                      autofocus: false,
                      obscureText: true,
                      decoration: InputDecorations.buildInputDecoration_1(hint_text: "Confirm Password"),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  Btn.basic(
                    min_width: MediaQuery.of(context).size.width,
                    color: MyTheme.accent_color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      "Complete Registration",
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    onPressed: _completeRegistration,
                  ),
                ],

                SizedBox(height: 30),
                
                // Back to login option
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
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
      ),
    );
  }
}
