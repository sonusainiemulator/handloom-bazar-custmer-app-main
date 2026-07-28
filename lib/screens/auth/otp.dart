import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../main.dart';

class Otp extends StatefulWidget {
  String? title;
  Otp({super.key, this.title});

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> with CodeAutoFill {
  //controllers
  final TextEditingController _verificationCodeController = TextEditingController();

  @override
  void codeUpdated() {
    if (code != null && code!.isNotEmpty) {
      String digitsOnly = code!.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.isNotEmpty) {
        _verificationCodeController.text = digitsOnly;
        if (mounted) {
          setState(() {});
          onPressConfirm();
        }
      }
    }
  }

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    listenForCode();
    _logAppSignature();
  }

  /// Fetches and logs the app hash required by Android SMS Retriever API.
  /// The backend must append this 11-char hash at the END of every OTP SMS.
  /// Example SMS: "Your OTP is 123456\n<HASH>"
  Future<void> _logAppSignature() async {
    try {
      final hash = await SmsAutoFill().getAppSignature;
      print("[SMS Autofill] App Signature Hash: $hash");
      print("[SMS Autofill] Include this at the END of your OTP SMS body.");
    } catch (e) {
      print("[SMS Autofill] Could not get app hash: $e");
    }
  }

  @override
  void dispose() {
    cancel();
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onTapResend() async {
    var resendCodeResponse = await AuthRepository().getResendCodeResponse();

    if (resendCodeResponse.result == false) {
      ToastComponent.showDialog(
        resendCodeResponse.message!,
      );
    } else {
      ToastComponent.showDialog(
        resendCodeResponse.message!,
      );
    }
  }

  onPressConfirm() async {
    var code = _verificationCodeController.text.toString();

    if (code == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_verification_code,
      );
      return;
    }

    var confirmCodeResponse =
        await AuthRepository().getConfirmCodeResponse(code);

    if (!(confirmCodeResponse.result == true)) {
      ToastComponent.showDialog(
        confirmCodeResponse.message ?? 'Verification failed',
      );
    } else {
      ToastComponent.showDialog(
        confirmCodeResponse.message ?? 'Verified successfully',
      );
      if (SystemConfig.systemUser != null) {
        SystemConfig.systemUser!.emailVerified = true;
      }
      context.go("/");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen_width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              color: Colors.red,
              width: screen_width,
              height: 200,
              child: Image.asset(
                  "assets/splash_login_registration_background_image.png"),
            ),
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: TextStyle(fontSize: 25, color: MyTheme.font_grey),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 15),
                    child: SizedBox(
                      width: 75,
                      height: 75,
                      child: Image.asset(
                          'assets/login_registration_form_logo.png'),
                    ),
                  ),
                  SizedBox(
                    width: screen_width * (3 / 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 36,
                                child: TextField(
                                  controller: _verificationCodeController,
                                  autofocus: false,
                                  keyboardType: TextInputType.number,
                                  autofillHints: const [AutofillHints.oneTimeCode],
                                  decoration:
                                      InputDecorations.buildInputDecoration_1(
                                          hint_text: "A X B 4 J H"),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Paste OTP from clipboard button
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final clipData = await Clipboard.getData(Clipboard.kTextPlain);
                                  final text = clipData?.text ?? '';
                                  final digits = text.replaceAll(RegExp(r'\D'), '');
                                  if (digits.isNotEmpty) {
                                    _verificationCodeController.text = digits.length >= 6 ? digits.substring(0, 6) : digits;
                                    if (mounted) setState(() {});
                                    if (digits.length >= 6) onPressConfirm();
                                  } else {
                                    ToastComponent.showDialog("No OTP found in clipboard");
                                  }
                                },
                                icon: const Icon(Icons.content_paste_rounded, size: 16),
                                label: const Text("Paste OTP"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: MyTheme.accent_color,
                                  side: BorderSide(color: MyTheme.accent_color),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: MyTheme.textfield_grey, width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0))),
                            child: Btn.basic(
                              minWidth: MediaQuery.of(context).size.width,
                              color: MyTheme.accent_color,
                              shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
                              child: Text(
                                AppLocalizations.of(context)!.confirm_ucf,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                onPressConfirm();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: InkWell(
                      onTap: () {
                        onTapResend();
                      },
                      child: Text(AppLocalizations.of(context)!.resend_code_ucf,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              decoration: TextDecoration.underline,
                              fontSize: 13)),
                    ),
                  ),
                  // SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: InkWell(
                      onTap: () {
                        onTapLogout(context);
                      },
                      child: Text(AppLocalizations.of(context)!.logout_ucf,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              decoration: TextDecoration.underline,
                              fontSize: 13)),
                    ),
                  ),
                ],
              )),
            )
          ],
        ),
      ),
    );
  }

  onTapLogout(context) {
    try {
      AuthHelper().clearUserData(); // Ensure this clears user data properly
      routes.push("/");
    } catch (e) {
      print('Error navigating to Main: $e');
    }
  }
}
