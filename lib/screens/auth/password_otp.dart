import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/lang_text.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PasswordOtp extends StatefulWidget {
  const PasswordOtp({super.key, this.verify_by = "email", this.email_or_code, this.phone});
  final String verify_by;
  final String? email_or_code;
  final String? phone;

  @override
  _PasswordOtpState createState() => _PasswordOtpState();
}

class _PasswordOtpState extends State<PasswordOtp> {
  //controllers
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final bool _resetPasswordSuccess = false;

  String headeText = "";

  FlipCardController cardController = FlipCardController();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      if (widget.verify_by == "phone") {
        headeText = "Reset Your Password";
      } else {
        headeText = AppLocalizations.of(context)!.enter_the_code_sent;
      }
      setState(() {});
    });
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressConfirm() async {
    var code = _codeController.text.toString();
    var password = _passwordController.text.toString();
    var passwordConfirm = _passwordConfirmController.text.toString();

    // For phone OTP, skip code validation since it's already verified
    if (widget.verify_by == "email" && code == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_the_code,
      );
      return;
    } else if (password == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_password,
      );
      return;
    } else if (passwordConfirm == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.confirm_your_password,
      );
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!
            .password_must_contain_at_least_6_characters,
      );
      return;
    } else if (password != passwordConfirm) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.passwords_do_not_match,
      );
      return;
    }

    // For phone OTP, use the same password confirm endpoint
    var passwordConfirmResponse;
    passwordConfirmResponse = await AuthRepository().getPasswordConfirmResponse(
      widget.verify_by == "phone" ? (widget.email_or_code ?? "") : code, 
      password,
      emailOrPhone: widget.verify_by == "phone" ? widget.phone : widget.email_or_code
    );

    if (passwordConfirmResponse.result == false) {
      ToastComponent.showDialog(
        passwordConfirmResponse.message!,
      );
    } else {
      ToastComponent.showDialog(
        passwordConfirmResponse.message!,
      );

      headeText = AppLocalizations.of(context)!.password_changed_ucf;
      cardController.toggleCard();
      setState(() {});
    }
  }

  onTapResend() async {
    var passwordResendCodeResponse = await AuthRepository()
        .getPasswordResendCodeResponse();

    if (passwordResendCodeResponse.result == false) {
      ToastComponent.showDialog(
        passwordResendCodeResponse.message!,
      );
    } else {
      ToastComponent.showDialog(
        passwordResendCodeResponse.message!,
      );
    }
  }

  gotoLoginScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    String verify_by = widget.verify_by; //phone or email
    final screen_height = MediaQuery.of(context).size.height;
    final screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
        context,
        headeText,
        WillPopScope(
            onWillPop: () {
              gotoLoginScreen();
              return Future.delayed(Duration.zero);
            },
            child: buildBody(context, screen_width, verify_by)));
  }

  Widget buildBody(
      BuildContext context, double screen_width, String verify_by) {
    return FlipCard(
      flipOnTouch: false,
      controller: cardController,
      //fill: Fill.fillBack, // Fill the back side of the card to make in the same size as the front.
      direction: FlipDirection.HORIZONTAL,
      // default
      front: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                  width: screen_width * (3 / 4),
                  child: verify_by == "email"
                      ? Text(
                          AppLocalizations.of(context)!
                              .enter_the_verification_code_that_sent_to_your_email_recently,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: MyTheme.dark_grey, fontSize: 14))
                      : Text(
                          AppLocalizations.of(context)!
                              .enter_the_verification_code_that_sent_to_your_phone_recently,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: MyTheme.dark_grey, fontSize: 14))),
            ),
            SizedBox(
              width: screen_width * (3 / 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Only show code field for email verification, not for phone OTP
                  if (widget.verify_by == "email") ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        AppLocalizations.of(context)!.enter_the_code,
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontWeight: FontWeight.w600),
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
                              controller: _codeController,
                              autofocus: false,
                              decoration: InputDecorations.buildInputDecoration_1(
                                  hint_text: "A X B 4 J H"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // For phone OTP, show verification success message
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Phone number verified successfully. You can now set a new password.',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      AppLocalizations.of(context)!.password_ucf,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontWeight: FontWeight.w600),
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
                                hint_text: "• • • • • • • •"),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .password_must_contain_at_least_6_characters,
                          style: TextStyle(
                              color: MyTheme.textfield_grey,
                              fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      AppLocalizations.of(context)!.retype_password_ucf,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontWeight: FontWeight.w600),
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
                            hint_text: "• • • • • • • •"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: MyTheme.textfield_grey, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0))),
                      child: Btn.basic(
                        minWidth: MediaQuery.of(context).size.width,
                        color: MyTheme.accent_color,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12.0))),
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
            // Only show resend for email verification
            if (widget.verify_by == "email")
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: InkWell(
                  onTap: () {
                    onTapResend();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.resend_code_ucf,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        decoration: TextDecoration.underline,
                        fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
      back: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                  width: screen_width * (3 / 4),
                  child: Text(LangText(context).local.congratulations_ucf,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                  width: screen_width * (3 / 4),
                  child: Text(
                      LangText(context)
                          .local
                          .you_have_successfully_changed_your_password,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 13,
                      ))),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Image.asset(
                'assets/changed_password.png',
                width: DeviceInfo(context).width! / 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 45,
                child: Btn.basic(
                  minWidth: MediaQuery.of(context).size.width,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(6.0))),
                  child: Text(
                    AppLocalizations.of(context)!.back_to_Login_ucf,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    gotoLoginScreen();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
