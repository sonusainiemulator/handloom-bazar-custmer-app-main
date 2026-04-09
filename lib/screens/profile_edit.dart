import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';

import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/lang_text.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';

import 'package:active_ecommerce_cms_demo_app/helpers/file_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final ScrollController _mainScrollController = ScrollController();

  final TextEditingController _nameController =
      TextEditingController(text: "${user_name.$}");

  final TextEditingController _phoneController =
      TextEditingController(text: user_phone.$);

  final TextEditingController _emailController =
      TextEditingController(text: user_email.$);
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  //for image uploading
  final ImagePicker _picker = ImagePicker();
  XFile? _file;

  chooseAndUploadImage(context) async {
    var status = await Permission.camera.request();
    // var status = await Permission.photos.request();
    //
    // if (status.isDenied) {
    //   // We didn't ask for permission yet.
    //   showDialog(
    //       context: context,
    //       builder: (BuildContext context) => CupertinoAlertDialog(
    //             title: Text(AppLocalizations.of(context)!.photo_permission_ucf),
    //             content: Text(
    //                 AppLocalizations.of(context)!.this_app_needs_permission),
    //             actions: <Widget>[
    //               CupertinoDialogAction(
    //                 child: Text(AppLocalizations.of(context)!.deny_ucf),
    //                 onPressed: () => Navigator.of(context).pop(),
    //               ),
    //               CupertinoDialogAction(
    //                 child: Text(AppLocalizations.of(context)!.settings_ucf),
    //                 onPressed: () => openAppSettings(),
    //               ),
    //             ],
    //           ));
    // } else if (status.isRestricted) {
    //   ToastComponent.showDialog(
    //       AppLocalizations.of(context)!
    //           .go_to_your_application_settings_and_give_photo_permission,
    //       gravity: Toast.center,
    //       duration: Toast.lengthLong);
    // } else if (status.isGranted) {}

    //file = await ImagePicker.pickImage(source: ImageSource.camera);
    _file = await _picker.pickImage(source: ImageSource.gallery);

    if (_file == null) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.no_file_is_chosen,
      );
      return;
    }

    //return;
    String base64Image = FileHelper.getBase64FormateFile(_file!.path);
    String fileName = _file!.path.split("/").last;

    var profileImageUpdateResponse =
        await ProfileRepository().getProfileImageUpdateResponse(
      base64Image,
      fileName,
    );

    if (profileImageUpdateResponse.result == false) {
      ToastComponent.showDialog(
        profileImageUpdateResponse.message,
      );
      return;
    } else {
      ToastComponent.showDialog(
        profileImageUpdateResponse.message,
      );

      avatar_original.$ = profileImageUpdateResponse.path;
      setState(() {});
    }
  }

  Future<void> _onPageRefresh() async {}

  onPressUpdate() async {
    var name = _nameController.text.toString();
    var phone = _phoneController.text.toString();

    if (name == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_your_name,
      );
      return;
    }
    if (phone == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_phone_number,
      );
      return;
    }

    var postBody = jsonEncode({"name": name, "phone": phone});

    var profileUpdateResponse = await ProfileRepository()
        .getProfileUpdateResponse(post_body: postBody);

    if (profileUpdateResponse.result == false) {
      ToastComponent.showDialog(
        profileUpdateResponse.message,
      );
    } else {
      ToastComponent.showDialog(
        profileUpdateResponse.message,
      );

      user_name.$ = name;
      user_phone.$ = phone;
      setState(() {});
    }
  }

  onPressUpdatePassword() async {
    var password = _passwordController.text.toString();
    var passwordConfirm = _passwordConfirmController.text.toString();

    var changePassword = password != "" ||
        passwordConfirm !=
            ""; // if both fields are empty we will not change user's password

    if (!changePassword && password == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_password,
      );
      return;
    }
    if (!changePassword && passwordConfirm == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.confirm_your_password,
      );
      return;
    }
    if (changePassword && password.length < 6) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!
            .password_must_contain_at_least_6_characters,
      );
      return;
    }
    if (changePassword && password != passwordConfirm) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.passwords_do_not_match,
      );
      return;
    }

    var postBody = jsonEncode({"password": password});

    var profileUpdateResponse =
        await ProfileRepository().getProfileUpdateResponse(
      post_body: postBody,
    );

    if (profileUpdateResponse.result == false) {
      ToastComponent.showDialog(
        profileUpdateResponse.message,
      );
    } else {
      ToastComponent.showDialog(
        profileUpdateResponse.message,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        body: buildBody(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        AppLocalizations.of(context)!.edit_profile_ucf,
        style: TextStyle(
            fontSize: 16,
            color: Color(0xff3E4447),
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildBody(context) {
    if (is_logged_in.$ == false) {
      return SizedBox(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.please_log_in_to_see_the_profile,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      return RefreshIndicator(
        color: MyTheme.accent_color,
        backgroundColor: Colors.white,
        onRefresh: _onPageRefresh,
        displacement: 10,
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                buildTopSection(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                buildProfileForm(context)
              ]),
            )
          ],
        ),
      );
    }
  }

  buildTopSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0, bottom: 8.0),
          child: Stack(
            children: [
              // UsefulElements.roundImageWithPlaceholder(
              //     url: avatar_original.$,
              //     height: 80.0,
              //     width: 80.0,
              //     borderRadius: BorderRadius.circular(60),
              //     elevation: 8.0),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  boxShadow: [MyTheme.commonShadow()],
                  borderRadius: BorderRadius.circular(100),

                  //shape: BoxShape.rectangle,
                ),
                child: ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.all(Radius.circular(100.0)),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: "${avatar_original.$}",
                      fit: BoxFit.fill,
                    )),
              ),
              // Positioned(
              //   right: 2,
              //   bottom: 0,
              //   child: SizedBox(
              //     width: 24,
              //     height: 24,
              //     child: Btn.basic(
              //       padding: EdgeInsets.all(0),
              //       child: Icon(
              //         Icons.edit,
              //         color: Color(0xff3E4447),
              //         size: 14,
              //       ),
              //       shape: CircleBorder(
              //         side:
              //             new BorderSide(color: MyTheme.light_grey, width: 1.0),
              //       ),
              //       color: Color(0xffDBDFE2),
              //       onPressed: () {
              //         chooseAndUploadImage(context);
              //       },
              //     ),
              //   ),
              // )
              Positioned(
                right: 2,
                bottom: 0,
                child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      boxShadow: [MyTheme.commonShadow()],
                      borderRadius: BorderRadius.circular(100),

                      //shape: BoxShape.rectangle,
                    ),
                    child: Btn.basic(
                      padding: EdgeInsets.all(0),
                      child: Icon(
                        Icons.edit,
                        color: Color(0xff3E4447),
                        size: 14,
                      ),
                      shape: CircleBorder(),
                      color: Color(0xffDBDFE2),
                      onPressed: () {
                        chooseAndUploadImage(context);
                      },
                    )),
              )
            ],
          ),
        ),
      ],
    );
  }

  buildProfileForm(context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBasicInfo(context),
            buildChangePassword(context),
          ],
        ),
      ),
    );
  }

  Column buildChangePassword(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 22.0, bottom: 10),
          child: Center(
            child: Text(
              LangText(context).local.password_changes_ucf,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                color: Color(0xffE62E04),
                fontWeight: FontWeight.bold,
              ),
              textHeightBehavior:
                  TextHeightBehavior(applyHeightToFirstAscent: false),
              textAlign: TextAlign.center,
              softWrap: false,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            AppLocalizations.of(context)!.new_password_ucf,
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff3E4447),
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecorations.buildBoxDecoration_with_shadow(),
                height: 40,
                child: TextField(
                  style: TextStyle(fontSize: 12),
                  controller: _passwordController,
                  autofocus: false,
                  obscureText: !_showPassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecorations.buildInputDecoration_1(
                          hint_text: "• • • • • • • •")
                      .copyWith(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyTheme.accent_color),
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        _showPassword = !_showPassword;
                        setState(() {});
                      },
                      child: Icon(
                        _showPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: MyTheme.accent_color,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  AppLocalizations.of(context)!
                      .password_must_contain_at_least_6_characters,
                  style: TextStyle(
                      color: Color(0xffE62E04), fontStyle: FontStyle.italic),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            AppLocalizations.of(context)!.retype_password_ucf,
            style: TextStyle(
                fontSize: 12,
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            decoration: BoxDecorations.buildBoxDecoration_with_shadow(),
            height: 40,
            child: TextField(
              controller: _passwordConfirmController,
              autofocus: false,
              obscureText: !_showConfirmPassword,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: "• • • • • • • •")
                  .copyWith(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: MyTheme.accent_color),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          _showConfirmPassword = !_showConfirmPassword;
                          setState(() {});
                        },
                        child: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: MyTheme.accent_color,
                        ),
                      )),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              onPressUpdatePassword();
            },
            child: Container(
              alignment: Alignment.center,
              width: 129,
              height: 42,
              decoration: BoxDecoration(
                  color: Color(0xffE62E04),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                textAlign: TextAlign.center,
                'Save Changes',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column buildBasicInfo(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 13.0),
          child: Text(
            AppLocalizations.of(context)!.basic_information_ucf,
            style: TextStyle(
                color: Color(0xff6B7377),
                fontWeight: FontWeight.bold,
                fontSize: 14.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            AppLocalizations.of(context)!.name_ucf,
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff3E4447),
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [MyTheme.commonShadow()]),
            height: 40,
            child: TextField(
              controller: _nameController,
              autofocus: false,
              style: TextStyle(color: Color(0xff999999), fontSize: 12),
              decoration:
                  InputDecorations.buildInputDecoration_1(hint_text: "John Doe")
                      .copyWith(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyTheme.accent_color),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            AppLocalizations.of(context)!.phone_ucf,
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff3E4447),
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [MyTheme.commonShadow()]),
            height: 40,
            child: TextField(
              controller: _phoneController,
              autofocus: false,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: Color(0xff999999), fontSize: 12),
              decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: "+01xxxxxxxxxx")
                  .copyWith(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyTheme.accent_color),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  AppLocalizations.of(context)!.email_ucf,
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff3E4447),
                      fontWeight: FontWeight.normal),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [MyTheme.commonShadow()]),
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _emailController.text,
                      style: TextStyle(fontSize: 12, color: Color(0xff999999)),
                    )
                    /*TextField(
                          style: TextStyle(color:MyTheme.grey_153,fontSize: 12),
                          enabled: false,
                          enableIMEPersonalizedLearning: true,
                          controller: _emailController,
                          autofocus: false,
                          decoration: InputDecorations.buildInputDecoration_1(

                              hint_text: "jhon@example.com").copyWith(
                            //enabled: false,
                        labelStyle: TextStyle(color: MyTheme.grey_153),
                        enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,

                        ),),
                        ),*/
                    ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              onPressUpdate();
            },
            child: Container(
              alignment: Alignment.center,
              width: 129,
              height: 42,
              decoration: BoxDecoration(
                  color: Color(0xffE62E04),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                textAlign: TextAlign.center,
                'Update Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
