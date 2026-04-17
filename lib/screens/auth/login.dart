import 'dart:convert';
// import 'dart:io' show Platform;
import 'dart:math';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/intl_phone_input.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/other_config.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/password_forget.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/registration.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:active_ecommerce_cms_demo_app/screens/index.dart';
import 'package:active_ecommerce_cms_demo_app/social_config.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
//import 'package:twitter_login/twitter_login.dart';

import '../../custom/loading.dart';
import '../../repositories/address_repository.dart';
import 'otp.dart';

class Login extends StatefulWidget {
  final String? phoneNumber;
  
  const Login({super.key, this.phoneNumber});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = "email"; //phone or email
  String initialCountry = 'US';
  bool _isNavigatingAfterLogin = false;
  bool _isSubmittingLogin = false;

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";

  //controllers
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    super.initState();
    fetch_country();
    
    // If phone number is provided, set it and switch to phone login
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      _phone = widget.phoneNumber;
      _phoneNumberController.text = widget.phoneNumber!;
      _login_by = "phone";
    }
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

  Future<void> _navigateAfterLogin(Widget destination,
      {bool clearStack = false}) async {
    if (!mounted || _isNavigatingAfterLogin) {
      return;
    }

    _isNavigatingAfterLogin = true;

    // Let any active dialog pop complete before mutating the navigator stack.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (clearStack) {
        context.go('/');
      } else {
        final route = MaterialPageRoute(builder: (context) => destination);
        Navigator.of(context).push(route);
      }
    });
  }

  onPressedLogin(ctx) async {
    if (_isSubmittingLogin) {
      return;
    }

    _isSubmittingLogin = true;
    FocusScope.of(context).unfocus();

    try {
      Loading.show(context);
      var email = _emailController.text.toString();
      var password = _passwordController.text.toString();

      if (_login_by == 'email' && email == "") {
        await Loading.close();
        ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email);
        return;
      } else if (_login_by == 'phone' && (_phone == "" || _phone == null)) {
        await Loading.close();
        ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
        );
        return;
      } else if (password == "") {
        await Loading.close();
        ToastComponent.showDialog(AppLocalizations.of(context)!.enter_password);
        return;
      }

      var loginResponse = await AuthRepository().getLoginResponse(
        _login_by == 'email' ? email : _phone!,
        password,
        _login_by,
      );
      await Loading.close();

      // empty temp user id after logged in
      temp_user_id.$ = "";
      temp_user_id.save();

      if (loginResponse.result == false) {
        String errorMessage = "Login failed";
        
        if (loginResponse.message != null) {
          if (loginResponse.message.runtimeType == List) {
            errorMessage = loginResponse.message!.join("\n");
          } else {
            errorMessage = loginResponse.message!.toString();
          }
        }
        
        // Handle specific error messages
        if (errorMessage.toLowerCase().contains('matrix')) {
          errorMessage = "Authentication error. Please try again.";
        } else if (errorMessage.toLowerCase().contains('user not found')) {
          errorMessage = "Account not found. Please register first.";
        } else if (errorMessage.toLowerCase().contains('unauthorized')) {
          errorMessage = "Incorrect password. Please try again.";
        }
        
        ToastComponent.showDialog(errorMessage);
        return;
      }

      // Login successful
      if (loginResponse.user != null) {
        ToastComponent.showDialog("Login successful!");
        AuthHelper().setUserData(loginResponse);
        
        // Update push notification token
        try {
          FirebaseMessaging.instance.getToken().then((fcmToken) {
            if (fcmToken != null) {
              ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
            }
          });
        } catch (e) {
          print('[WARN] Firebase Messaging error (login): $e');
        }

        await _navigateAfterLogin(Index(), clearStack: true);
      }
    } catch (e) {
      await Loading.close();
      String errorMessage = "Login failed: ${e.toString()}";
      
      // Don't show Firebase initialization errors
      if (e.toString().contains('Firebase') || 
          e.toString().contains('core/no-app') ||
          e.toString().contains('initializeApp')) {
        print('[WARN] Firebase error suppressed: $e');
        return;
      }
      
      // Handle network and other errors
      if (e.toString().contains('network') || e.toString().contains('timeout')) {
        errorMessage = "Network error. Please check your connection and try again.";
      } else if (e.toString().contains('matrix')) {
        errorMessage = "Authentication error. Please try again.";
      }
      
      ToastComponent.showDialog(errorMessage);
    } finally {
      _isSubmittingLogin = false;
    }
  }

  onPressedFacebookLogin() async {
    try {
      final facebookLogin = await FacebookAuth.instance.login(
        loginBehavior: LoginBehavior.webOnly,
      );

      if (facebookLogin.status == LoginStatus.success) {
        // get the user data
        // by default we get the userId, email,name and picture
        final userData = await FacebookAuth.instance.getUserData();
        var loginResponse = await AuthRepository().getSocialLoginResponse(
          "facebook",
          userData['name'].toString(),
          userData['email'].toString(),
          userData['id'].toString(),
          facebookLogin.accessToken!.tokenString,
        );
        // print("..........................${loginResponse.toString()}");
        if (loginResponse.result == false) {
          ToastComponent.showDialog(loginResponse.message!);
        } else {
          ToastComponent.showDialog(loginResponse.message!);

          AuthHelper().setUserData(loginResponse);
          await _navigateAfterLogin(Main());
          FacebookAuth.instance.logOut();
        }
        // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      } else {
        print("....Facebook auth Failed.........");
        // print(facebookLogin.status);
        // print(facebookLogin.message);
      }
    } on Exception catch (e) {
      print(e);
      // TODO
    }
  }

  onPressedGoogleLogin() async {
    try {
      final GoogleSignInAccount googleUser = (await GoogleSignIn().signIn())!;

      print(googleUser.toString());

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;
      String? accessToken = googleSignInAuthentication.accessToken;

      // print("displayName ${googleUser.displayName}");
      // print("email ${googleUser.email}");
      // print("googleUser.id ${googleUser.id}");

      var loginResponse = await AuthRepository().getSocialLoginResponse(
        "google",
        googleUser.displayName ?? '',
        googleUser.email,
        googleUser.id,
        accessToken ?? '',
      );

      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message!);
      } else {
        ToastComponent.showDialog(loginResponse.message!);
        AuthHelper().setUserData(loginResponse);
        await _navigateAfterLogin(Main());
      }
      GoogleSignIn().disconnect();
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }
  }

  // onPressedTwitterLogin() async {
  //   try {
  //     final twitterLogin =  TwitterLogin(
  //         apiKey: SocialConfig().twitter_consumer_key,
  //         apiSecretKey: SocialConfig().twitter_consumer_secret,
  //         redirectURI: 'activeecommerceflutterapp://');
  //     // Trigger the sign-in flow

  //     final authResult = await twitterLogin.login();

  //     // print("authResult");

  //     // print(json.encode(authResult));

  //     var loginResponse = await AuthRepository().getSocialLoginResponse(
  //         "twitter",
  //         authResult.user!.name,
  //         authResult.user!.email,
  //         authResult.user!.id.toString(),
  //         access_token: authResult.authToken,
  //         secret_token: authResult.authTokenSecret);

  //     if (loginResponse.result == false) {
  //       ToastComponent.showDialog(
  //         loginResponse.message!,
  //       );
  //     } else {
  //       ToastComponent.showDialog(
  //         loginResponse.message!,
  //       );
  //       AuthHelper().setUserData(loginResponse);
  //       Navigator.push(context, MaterialPageRoute(builder: (context) {
  //         return Main();
  //       }));
  //     }
  //   } on Exception catch (e) {
  //     print("error is ....... $e");
  //     // TODO
  //   }
  // }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      var loginResponse = await AuthRepository().getSocialLoginResponse(
        "apple",
        appleCredential.givenName ?? '',
        appleCredential.email ?? '',
        appleCredential.userIdentifier ?? '',
        appleCredential.identityToken ?? '',
      );

      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message!);
      } else {
        ToastComponent.showDialog(loginResponse.message!);
        AuthHelper().setUserData(loginResponse);
        await _navigateAfterLogin(Main());
      }
    } on Exception catch (e) {
      print(e);
      // TODO
    }

    // Create an `OAuthCredential` from the credential returned by Apple.
    // final oauthCredential = OAuthProvider("apple.com").credential(
    //   idToken: appleCredential.identityToken,
    //   rawNonce: rawNonce,
    // );
    //print(oauthCredential.accessToken);

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    //return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    final screen_height = MediaQuery.of(context).size.height;
    final screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
      context,
      "${AppLocalizations.of(context)!.login_to} ${AppConfig.app_name}",
      buildBody(context, screen_width),
    );
  }

  Widget buildBody(BuildContext context, double screen_width) {
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
                  _login_by == "email"
                      ? AppLocalizations.of(context)!.email_ucf
                      : AppLocalizations.of(context)!.login_screen_phone,
                  style: TextStyle(
                    color: MyTheme.accent_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_login_by == "email")
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
                                _login_by = "phone";
                              });
                            },
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.or_login_with_a_phone,
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
                          textStyle: TextStyle(color: MyTheme.font_grey),
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
                            print('On Saved: $number');
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _login_by = "email";
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!.or_login_with_an_email,
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return PasswordForget();
                            },
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.login_screen_forgot_password,
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
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: MyTheme.textfield_grey, width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  ),
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
                      AppLocalizations.of(context)!.login_screen_log_in,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      onPressedLogin(context);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                child: Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.login_screen_or_create_new_account,
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                  ),
                ),
              ),
              SizedBox(
                height: 45,
                child: Btn.minWidthFixHeight(
                  minWidth: MediaQuery.of(context).size.width,
                  height: 50,
                  color: MyTheme.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.login_screen_sign_up,
                    style: TextStyle(
                      color: MyTheme.accent_color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Registration();
                        },
                      ),
                    );
                  },
                ),
              ),
              // Apple Sign-In visible on iOS only; skip Platform check on web to avoid errors
              if (Theme.of(context).platform == TargetPlatform.iOS)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SignInWithAppleButton(
                    onPressed: () async {
                      signInWithApple();
                    },
                  ),
                ),
              Visibility(
                visible: allow_google_login.$ || allow_facebook_login.$,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.login_screen_login_with,
                      style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: allow_google_login.$,
                          child: InkWell(
                            onTap: () {
                              onPressedGoogleLogin();
                            },
                            child: SizedBox(
                              width: 28,
                              child: Image.asset("assets/google_logo.png"),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Visibility(
                            visible: allow_facebook_login.$,
                            child: InkWell(
                              onTap: () {
                                onPressedFacebookLogin();
                              },
                              child: SizedBox(
                                width: 28,
                                child: Image.asset("assets/facebook_logo.png"),
                              ),
                            ),
                          ),
                        ),
                        if (allow_twitter_login.$)
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: InkWell(
                              onTap: () {
                                // onPressedTwitterLogin();
                              },
                              child: SizedBox(
                                width: 28,
                                child: Image.asset("assets/twitter_logo.png"),
                              ),
                            ),
                          ),
                        /* if (Platform.isIOS)
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            // visible: true,
                            child: A(
                              onTap: () async {
                                signInWithApple();
                              },
                              child: Container(
                                width: 28,
                                child: Image.asset("assets/apple_logo.png"),
                              ),
                            ),
                          ),*/
                      ],
                    ),
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
