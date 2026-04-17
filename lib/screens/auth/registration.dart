
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/google_recaptcha.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/intl_phone_input.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/other_config.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/screens/common_webview_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:active_ecommerce_cms_demo_app/screens/index.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:active_ecommerce_cms_demo_app/widgets/otp_verification_modal.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:validators/validators.dart';

import '../../custom/loading.dart';
import '../../helpers/auth_helper.dart';
import '../../repositories/address_repository.dart';
import 'otp.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String _register_by = "email"; //phone or email
  String initialCountry = 'US';

  var countries_code = <String?>[];

  String? _phone = "";
  bool? _isAgree = false;
  bool _isCaptchaShowing = false;
  String googleRecaptchaKey = "";
  bool _isPhoneVerified = false;
  bool _isOTPSent = false;

  //controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    super.initState();
    fetch_country();
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  onPressSignUp() async {
    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    var passwordConfirm = _passwordConfirmController.text.toString();

    if (name == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_your_name);
      return;
    } else if (_register_by == 'email' && (email == "" || !isEmail(email))) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email);
      return;
    } else if (_register_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_phone_number,
      );
      return;
    } else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_password);
      return;
    } else if (passwordConfirm == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.confirm_your_password,
      );
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog(
        AppLocalizations.of(
          context,
        )!.password_must_contain_at_least_6_characters,
      );
      return;
    } else if (password != passwordConfirm) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.passwords_do_not_match,
      );
      return;
    }

    // If registering by phone, check if phone is verified
    if (_register_by == 'phone') {
      if (!_isPhoneVerified) {
        ToastComponent.showDialog("Please verify your phone number first");
        return;
      }
    }

    // Continue with registration
    _proceedWithRegistration();
  }

  _sendBackendOTP() async {
    if (_phone == "") {
      ToastComponent.showDialog("Please enter phone number");
      return;
    }
    Loading.show(context);

    try {
      var response = await AuthRepository().getOtpRegistrationResponse(_phone!);
      Loading.close();

      if (response.result) {
        setState(() {
          _isOTPSent = true;
        });

        // Show OTP verification modal
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OTPVerificationModal(
            phoneNumber: _phone!,
            title: "Verify Phone Number",
            subtitle: "Enter the 6-digit code sent to your phone number",
            onVerificationSuccess: (code) {
              setState(() {
                _isPhoneVerified = true;
                _isOTPSent = false;
              });
              ToastComponent.showDialog("Phone number verified successfully!");
            },
            onCancel: () {
              setState(() {
                _isOTPSent = false;
              });
            },
          ),
        );
      } else {
        ToastComponent.showDialog(response.message);
      }
    } catch (e) {
      Loading.close();
      ToastComponent.showDialog("An error occurred: ${e.toString()}");
    }
  }

  _proceedWithRegistration() async {
    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    var passwordConfirm = _passwordConfirmController.text.toString();

    Loading.show(context);

    try {
      var signupResponse = await AuthRepository().getSignupResponse(
        name,
        _register_by == 'email' ? (email.isNotEmpty ? email : '') : (_phone ?? ''),
        password,
        passwordConfirm,
        _register_by,
        tempUserId: temp_user_id.$,
      );
      Loading.close();

      if (signupResponse.result == false) {
        var message = "";
        if (signupResponse.message is List) {
          signupResponse.message.forEach((value) {
            message += value + "\n";
          });
        } else {
          message = signupResponse.message.toString();
        }

        ToastComponent.showDialog(message);
      } else {
        ToastComponent.showDialog(signupResponse.message);
        AuthHelper().setUserData(signupResponse);

        // push notification starts
        try {
          if (OtherConfig.USE_PUSH_NOTIFICATION) {
            final FirebaseMessaging fcm = FirebaseMessaging.instance;
            await fcm.requestPermission(
              alert: true,
              announcement: false,
              badge: true,
              carPlay: false,
              criticalAlert: false,
              provisional: false,
              sound: true,
            );

            String? fcmToken = await fcm.getToken();

            print("--fcm token--");
            print(fcmToken);
            if (is_logged_in.$ == true && fcmToken != null) {
              // update device token
              var deviceTokenUpdateResponse = await ProfileRepository()
                  .getDeviceTokenUpdateResponse(fcmToken);
            }
          }
        } catch (e) {
          print("[WARN] Firebase Messaging error (registration): $e");
          // Non-critical error, continue to home
        }

        // Redirect to main home page directly
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Index()),
          (route) => false,
        );
      }
    } catch (e) {
      Loading.close();
      
      // Suppress Firebase initialization errors from being shown to user
      if (e.toString().contains('Firebase') || 
          e.toString().contains('core/no-app') ||
          e.toString().contains('initializeApp')) {
        print('[WARN] Firebase error suppressed: $e');
        
        // If we got this far, the user is likely already signed up but push notification failed
        // Check if we should still redirect to main
        if (is_logged_in.$) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Index()),
            (route) => false,
          );
          return;
        }
        return;
      }
      
      ToastComponent.showDialog("An error occurred: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen_height = MediaQuery.of(context).size.height;
    final screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
      context,
      "${AppLocalizations.of(context)!.join_ucf} ${AppConfig.app_name}",
      buildBody(context, screen_width),
    );
  }

  Column buildBody(BuildContext context, double screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.name_ucf,
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _nameController,
                    autofocus: false,
                    decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: "John Doe",
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  _register_by == "email"
                      ? AppLocalizations.of(context)!.email_ucf
                      : AppLocalizations.of(context)!.phone_ucf,
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Email/Phone selector chips
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Email'),
                          selected: _register_by == 'email',
                          onSelected: (sel) {
                            if (!sel) return;
                            setState(() => _register_by = 'email');
                          },
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Phone (OTP)'),
                          selected: _register_by == 'phone',
                          onSelected: (sel) {
                            if (!sel) return;
                            setState(() => _register_by = 'phone');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_register_by == "email")
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _emailController,
                          autofocus: false,
                          decoration: InputDecorations.buildInputDecoration_1(
                            hint_text: "johndoe@example.com",
                          ),
                        ),
                      ),
                      otp_addon_installed.$
                          ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _register_by = "phone";
                              });
                            },
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.or_register_with_a_phone,
                              style: TextStyle(
                                color: MyTheme.accent_color,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                          : Container(),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 36,
                        child: CustomInternationalPhoneNumberInput(
                          countries: countries_code,
                          onInputChanged: (PhoneNumber number) {
                            print(number.phoneNumber);
                            setState(() {
                              _phone = number.phoneNumber;
                            });
                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: TextStyle(
                            color: MyTheme.font_grey,
                          ),
                          // initialValue: PhoneNumber(
                          //     isoCode: countries_code[0].toString()),
                          textFieldController: _phoneNumberController,
                          formatInput: true,
                          keyboardType: TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          inputDecoration:
                              InputDecorations.buildInputDecoration_phone(
                                hint_text: "01XXX XXX XXX",
                              ),
                          onSaved: (PhoneNumber number) {
                            //print('On Saved: $number');
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Phone verification status and button
                      if (_isPhoneVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Phone number verified',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 45,
                          child: Btn.basic(
                            minWidth: MediaQuery.of(context).size.width,
                            color: _isOTPSent ? MyTheme.font_grey : MyTheme.accent_color,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                            child: Text(
                              _isOTPSent ? 'OTP Sent - Check Modal' : 'Send OTP',
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 13, 
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            onPressed: _isOTPSent ? null : _sendBackendOTP,
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _register_by = "email";
                          });
                        },
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.or_register_with_an_email,
                          style: TextStyle(
                            color: MyTheme.accent_color,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.password_ucf,
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _passwordController,
                        autofocus: false,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecorations.buildInputDecoration_1(
                          hint_text: "* * * * * * * *",
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.password_must_contain_at_least_6_characters,
                      style: TextStyle(
                        color: MyTheme.textfield_grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.retype_password_ucf,
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _passwordConfirmController,
                    autofocus: false,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: "* * * * * * * *",
                    ),
                  ),
                ),
              ),
              if (google_recaptcha.$)
                SizedBox(
                  height: _isCaptchaShowing ? 350 : 50,
                  width: 300,
                  child: Captcha(
                    (keyValue) {
                      googleRecaptchaKey = keyValue;
                      setState(() {});
                    },
                    handleCaptcha: (data) {
                      if (_isCaptchaShowing.toString() != data) {
                        _isCaptchaShowing = data;
                        setState(() {});
                      }
                    },
                    isIOS: Theme.of(context).platform == TargetPlatform.iOS,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                      width: 15,
                      child: Checkbox(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        value: _isAgree,
                        onChanged: (newValue) {
                          _isAgree = newValue;
                          setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: DeviceInfo(context).width! - 130,
                        child: RichText(
                          maxLines: 2,
                          text: TextSpan(
                            style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(text: "I agree to the"),
                              TextSpan(
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => CommonWebviewScreen(
                                                  page_name: "Terms Conditions",
                                                  url:
                                                      "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
                                                ),
                                          ),
                                        );
                                      },
                                style: TextStyle(color: MyTheme.accent_color),
                                text: " Terms Conditions",
                              ),
                              TextSpan(text: " &"),
                              TextSpan(
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => CommonWebviewScreen(
                                                  page_name: "Privacy Policy",
                                                  url:
                                                      "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                                                ),
                                          ),
                                        );
                                      },
                                text: " Privacy Policy",
                                style: TextStyle(color: MyTheme.accent_color),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: SizedBox(
                  height: 45,
                  child: Btn.minWidthFixHeight(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 50,
                    color: MyTheme.accent_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6.0),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.sign_up_ucf,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed:
                        _isAgree!
                            ? () {
                              onPressSignUp();
                            }
                            : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.already_have_an_account,
                        style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      child: Text(
                        AppLocalizations.of(context)!.log_in,
                        style: TextStyle(
                          color: MyTheme.accent_color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Login();
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
