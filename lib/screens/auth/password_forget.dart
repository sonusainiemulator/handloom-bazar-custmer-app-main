import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/loading.dart';
import 'package:active_ecommerce_cms_demo_app/custom/intl_phone_input.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/password_otp.dart';
import 'package:active_ecommerce_cms_demo_app/widgets/otp_verification_modal.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../repositories/address_repository.dart';

class PasswordForget extends StatefulWidget {
  const PasswordForget({super.key});

  @override
  _PasswordForgetState createState() => _PasswordForgetState();
}

class _PasswordForgetState extends State<PasswordForget> {
  String _send_code_by = "email"; //phone or email
  String initialCountry = 'US';
  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US');
  String? _phone = "";
  var countries_code = <String?>[];
  bool _isPhoneVerified = false;
  bool _isOTPSent = false;
  String? _verifiedCode = "";
  //controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

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

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  onPressSendCode() async {
    var email = _emailController.text.toString();

    if (_send_code_by == 'email' && email == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email);
      return;
    } else if (_send_code_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_phone_number,
      );
      return;
    }

    if (_send_code_by == 'phone') {
      if (!_isPhoneVerified) {
        ToastComponent.showDialog("Please verify your phone number first");
        return;
      }
      
      // Phone is verified, proceed to password reset
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordOtp(verify_by: 'phone', phone: _phone, email_or_code: _verifiedCode),
        ),
      );
      return;
    }

    // Email flow stays the same
    var passwordForgetResponse = await AuthRepository()
        .getPasswordForgetResponse(email, _send_code_by);

    if (passwordForgetResponse.result == false) {
      ToastComponent.showDialog(passwordForgetResponse.message!);
    } else {
      ToastComponent.showDialog(passwordForgetResponse.message!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return PasswordOtp(verify_by: _send_code_by);
          },
        ),
      );
    }
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
  }

  _sendBackendOTP() async {
    if (_phone == "") {
      ToastComponent.showDialog("Please enter phone number");
      return;
    }

    Loading.show(context);

    try {
      var response = await AuthRepository().getPasswordForgetResponse(_phone!, "phone");
      Loading.close();

      if (response.result == true) {
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
            isPasswordReset: true,
            onVerificationSuccess: (code) {
              setState(() {
                _isPhoneVerified = true;
                _isOTPSent = false;
                _verifiedCode = code;
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
        ToastComponent.showDialog(response.message ?? "Failed to send code");
      }
    } catch (e) {
      Loading.close();
      ToastComponent.showDialog("An error occurred: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen_height = MediaQuery.of(context).size.height;
    final screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
      context,
      "Forget Password!",
      buildBody(screen_width, context),
    );
  }

  Column buildBody(double screen_width, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        SizedBox(
          width: screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Let the user pick Email or Phone (Backend OTP)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Email'),
                          selected: _send_code_by == 'email',
                          onSelected: (sel) {
                            if (!sel) return;
                            setState(() => _send_code_by = 'email');
                          },
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Phone (OTP)'),
                          selected: _send_code_by == 'phone',
                          onSelected: (sel) {
                            if (!sel) return;
                            setState(() => _send_code_by = 'phone');
                          },
                        ),
                      ],
                    ),
                    // Web phone auth disclaimer
                    if (_send_code_by == 'phone' && kIsWeb)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade600, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Phone verification may have issues on web browser. Email is recommended.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  _send_code_by == "email"
                      ? AppLocalizations.of(context)!.email_ucf
                      : AppLocalizations.of(context)!.phone_ucf,
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_send_code_by == "email")
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
                                _send_code_by = "phone";
                              });
                            },
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.or_send_code_via_phone_number,
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
                            //print(number.phoneNumber);
                            setState(() {
                              _phone = number.phoneNumber;
                            });
                          },
                          onInputValidated: (bool value) {
                            //print(value);
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: TextStyle(
                            color: MyTheme.font_grey,
                          ),
                          // initialValue: phoneCode,
                          textFieldController: _phoneNumberController,
                          formatInput: true,
                          keyboardType: TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          inputDecoration:
                              InputDecorations.buildInputDecoration_phone(
                                hint_text: "01710 333 558",
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
                        Container(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _isOTPSent ? null : _sendBackendOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isOTPSent ? MyTheme.font_grey : MyTheme.accent_color,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              _isOTPSent ? 'OTP Sent - Check Modal' : 'Verify Phone Number',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _send_code_by = "email";
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!.or_send_code_via_email,
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
                padding: const EdgeInsets.only(top: 40.0),
                child: SizedBox(
                  height: 45,
                  child: Btn.basic(
                    minWidth: MediaQuery.of(context).size.width,
                    color: MyTheme.accent_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6.0),
                      ),
                    ),
                    child: Text(
                      _send_code_by == 'phone' && _isPhoneVerified 
                          ? "Continue to Reset Password" 
                          : "Send Code",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      onPressSendCode();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
