import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';

import '../data_model/login_response.dart';
import 'shared_value_helper.dart';

class AuthHelper {
  setUserData(dynamic response) {
    if (response.result == true) {
      SystemConfig.systemUser = response.user;
      is_logged_in.$ = true;
      is_logged_in.save();
      access_token.$ = response.access_token ?? response.accessToken ?? "";
      access_token.save();
      user_id.$ = response.user?.id;
      user_id.save();
      user_name.$ = response.user?.name;
      user_name.save();
      user_email.$ = response.user?.email ?? "";
      user_email.save();
      user_phone.$ = response.user?.phone ?? "";
      user_phone.save();
      avatar_original.$ = response.user?.avatar_original ?? response.user?.avatarOriginal ?? "";
      avatar_original.save();
    }
  }

  clearUserData() {
    SystemConfig.systemUser = null;
    is_logged_in.$ = false;
    is_logged_in.save();
    access_token.$ = "";
    access_token.save();
    user_id.$ = 0;
    user_id.save();
    user_name.$ = "";
    user_name.save();
    user_email.$ = "";
    user_email.save();
    user_phone.$ = "";
    user_phone.save();
    avatar_original.$ = "";
    avatar_original.save();

    temp_user_id.$ = "";
    temp_user_id.save();
  }

  fetch_and_set() async {
    var userByTokenResponse = await AuthRepository().getUserByTokenResponse();
    if (userByTokenResponse.result == true) {
      setUserData(userByTokenResponse);
    } else {
      clearUserData();
    }
  }
}
