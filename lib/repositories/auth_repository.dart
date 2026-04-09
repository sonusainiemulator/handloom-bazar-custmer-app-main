import 'dart:convert';
import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/login_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/logout_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/password_confirm_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/password_forget_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/resend_code_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/signup_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/user_by_token.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/common_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<LoginResponse> getLoginResponse(
      String email, String password, String loginBy) async {
    var postBody = jsonEncode({
      "email": email,
      "password": password,
      "login_by": loginBy,
      // Remove the identity_matrix parameter that was causing the matrix error
      // "identity_matrix": AppConfig.purchase_code,
    });

    String url = ("${AppConfig.BASE_URL}/auth/login");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return loginResponseFromJson(response.body);
  }

  Future<LoginResponse> getSocialLoginResponse(String socialProvider,
      String name, String email, String provider, String accessToken,
      {String secretToken = ""}) async {
    var postBody = jsonEncode({
      "name": name,
      "email": email,
      "provider": provider, // actual provider response id
      "social_provider":
          socialProvider, // is string like facebook, google, twitter, apple
      "access_token": accessToken
    });
    if (secretToken != "") {
      postBody = jsonEncode({
        "name": name,
        "email": email,
        "provider": provider,
        "social_provider": socialProvider,
        "access_token": accessToken,
        "secret_token": secretToken
      });
    }

    String url = ("${AppConfig.BASE_URL}/auth/social-login");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return loginResponseFromJson(response.body);
  }

  Future<LoginResponse> getSignupResponse(String name, String emailOrPhone,
      String password, String passwordConfirmation, String registerBy,
      {String? tempUserId}) async {
    var postBody = jsonEncode({
      "name": name,
      "email_or_phone": emailOrPhone,
      "password": password,
      "password_confirmation": passwordConfirmation,
      "register_by": registerBy,
      if (tempUserId != null) "temp_user_id": tempUserId,
    });

    String url = ("${AppConfig.BASE_URL}/auth/signup");

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return loginResponseFromJson(response.body);
  }

  Future<PasswordForgetResponse> getPasswordForgetResponse(
      String emailOrPhone, String sendCodeBy) async {
    var postBody = jsonEncode(
        {"email_or_phone": emailOrPhone, "send_code_by": sendCodeBy});

    String url = ("${AppConfig.BASE_URL}/auth/password/forget_request");
    final response = await ApiRequest.post(
        url: url,
        headers: {
            "Content-Type": "application/json",
            "App-Language": app_language.$!,
        },
        body: postBody);

    return passwordForgetResponseFromJson(response.body);
  }

  Future<CommonResponse> getOtpRegistrationResponse(String phone) async {
    var postBody = jsonEncode({"phone": phone});
    String url = ("${AppConfig.BASE_URL}/auth/send-otp-registration");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);
    
    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> getVerifyOtpResponse(String phone, String otp) async {
    var postBody = jsonEncode({"phone": phone, "otp": otp});
    String url = ("${AppConfig.BASE_URL}/auth/verify-otp");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return commonResponseFromJson(response.body);
  }

  Future<PasswordConfirmResponse> getPasswordConfirmResponse(
      String verificationCode, String password, {String? emailOrPhone}) async {
    var postBody = jsonEncode({
      "verification_code": verificationCode,
      "password": password,
      if (emailOrPhone != null) "email_or_phone": emailOrPhone,
      if (emailOrPhone != null) "phone": emailOrPhone,
    });

    String url = ("${AppConfig.BASE_URL}/auth/password/confirm_reset");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return passwordConfirmResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getPasswordResendCodeResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/password/resend_code");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
          "Authorization": "Bearer ${access_token.$}",
        },
        body: '');

    return resendCodeResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getResendCodeResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/resend_code");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
          "Authorization": "Bearer ${access_token.$}",
        },
        body: '');

    return resendCodeResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getConfirmCodeResponse(
      String verificationCode) async {
    var postBody = jsonEncode({"verification_code": verificationCode});

    String url = ("${AppConfig.BASE_URL}/auth/confirm_code");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
          "Authorization": "Bearer ${access_token.$}",
        },
        body: postBody);

    return resendCodeResponseFromJson(response.body);
  }

  Future<LogoutResponse> getLogoutResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/logout");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: '');

    return logoutResponseFromJson(response.body);
  }

  Future<UserByTokenResponse> getUserByTokenResponse() async {
    var postBody = jsonEncode({"access_token": "${access_token.$}"});

    String url = ("${AppConfig.BASE_URL}/get-user-by-access_token");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return userByTokenResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getAccountDeleteResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/account-deletion");
    final response = await ApiRequest.delete(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );

    return resendCodeResponseFromJson(response.body);
  }

  // Method to register after phone is verified via backend OTP
  Future<LoginResponse> signupAfterPhoneVerified({
    required String name,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    String? tempUserId,
  }) async {
    return getSignupResponse(
      name,
      phoneNumber,
      password,
      passwordConfirmation,
      'phone',
      tempUserId: tempUserId,
    );
  }

  // Phone login method
  Future<LoginResponse> getPhoneLoginResponse(
      String phoneNumber, String password) async {
    return getLoginResponse(phoneNumber, password, 'phone');
  }

  // Helper method to validate phone number format
  String formatPhoneNumber(String phone) {
    // Remove any non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it starts with + if it doesn't already
    if (!cleaned.startsWith('+')) {
      // Assume it's an Indian number if it doesn't have country code
      if (cleaned.length == 10) {
        cleaned = '+91$cleaned';
      } else {
        cleaned = '+$cleaned';
      }
    }
    
    return cleaned;
  }

  // Method to check if user registration is complete
  Future<bool> checkUserRegistrationStatus(String accessToken) async {
    try {
      var postBody = jsonEncode({"access_token": accessToken});
      String url = ("${AppConfig.BASE_URL}/get-user-by-access_token");
      
      final response = await ApiRequest.post(
          url: url,
          headers: {
            "Content-Type": "application/json",
            "App-Language": app_language.$!,
          },
          body: postBody);

      var responseData = jsonDecode(response.body);
      
      // Check if user exists and is properly registered
      if (responseData['result'] == true && responseData['user'] != null) {
        var user = responseData['user'];
        // Verify user has required fields
        return user['name'] != null && 
               user['name'].toString().trim().isNotEmpty &&
               (user['email'] != null || user['phone'] != null);
      }
      
      return false;
    } catch (e) {
      print("Error checking user registration status: $e");
      return false;
    }
  }

  // Enhanced error handling method
  String getErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      if (error['message'] is List) {
        List<dynamic> messages = error['message'];
        return messages.isNotEmpty ? messages.first.toString() : 'Unknown error occurred';
      } else if (error['message'] is String) {
        return error['message'];
      }
    }
    
    String message = error.toString();
    
    // Handle common error patterns
    if (message.contains('matrix')) {
      return 'Authentication error. Please try again.';
    } else if (message.contains('verification')) {
      return 'Verification failed. Please check your details.';
    } else if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (message.contains('timeout')) {
      return 'Request timeout. Please try again.';
    }
    
    return message;
  }
}
