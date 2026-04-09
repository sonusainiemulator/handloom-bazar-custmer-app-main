import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_add_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_count_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_delete_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_process_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_summary_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/banned_user.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

class CartRepository {
  // get cart list
  Future<dynamic> getCartResponseList(
    int? uid,
  ) async {
    try {
      String url = ("${AppConfig.BASE_URL}/carts");
      String postBody;

      if (guest_checkout_status.$ && !is_logged_in.$) {
        postBody = jsonEncode({"temp_user_id": temp_user_id.$});
        print('🛒 Fetching cart for temp user: ${temp_user_id.$}');
      } else {
        postBody = jsonEncode({"user_id": user_id.$});
        print('🛒 Fetching cart for user: ${user_id.$}');
      }

      print('🛒 Cart API URL: $url');
      print('🛒 Cart request body: $postBody');

      final response = await ApiRequest.post(
          url: url,
          headers: {
            "Content-Type": "application/json",
            "App-Language": app_language.$!,
          },
          body: postBody,
          middleware: BannedUser());

      print('🛒 Cart API response status: ${response.statusCode}');
      print('🛒 Cart API response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final cartResponse = cartResponseFromJson(response.body);
          print('🛒 Cart parsed successfully');
          print('🛒 Grand total: ${cartResponse.grandTotal}');
          print('🛒 Data count: ${cartResponse.data?.length ?? 0}');
          return cartResponse;
        } catch (parseError) {
          print('❌ Cart parsing error: $parseError');
          print('❌ Response body that failed to parse: ${response.body}');
          rethrow;
        }
      } else {
        print('❌ Cart API error: ${response.statusCode}');
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Cart repository error: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  // cart count
  Future<dynamic> getCartCount() async {
    String postBody;
    if (guest_checkout_status.$ && !is_logged_in.$) {
      postBody = jsonEncode({"temp_user_id": temp_user_id.$});
    } else {
      postBody = jsonEncode({"user_id": user_id.$});
    }

    // if (guest_checkout_status.$ && !is_logged_in.$) {
    // var postBody = jsonEncode({"temp_user_id": temp_user_id.$});
    String url = ("${AppConfig.BASE_URL}/cart-count");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
      },
      body: postBody,
    );

    return cartCountResponseFromJson(response.body);
  }

  // cart item delete
  Future<dynamic> getCartDeleteResponse(int cartId) async {
    String url = "${AppConfig.BASE_URL}/carts/$cartId";

    final response = await ApiRequest.delete(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
      middleware: BannedUser(),
    );

    if (response.statusCode == 200) {
      print('cart_delate${response.body}');
      return cartDeleteResponseFromJson(response.body);
    } else {
      throw Exception("Failed to delete item: ${response.body}");
    }
  }

  // cart process
  Future<dynamic> getCartProcessResponse(
      String cartIds, String cartQuantities) async {
    var postBody = jsonEncode(
        {"cart_ids": cartIds, "cart_quantities": cartQuantities});

    String url = ("${AppConfig.BASE_URL}/carts/process");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: postBody,
        middleware: BannedUser());
    return cartProcessResponseFromJson(response.body);
  }

  // cart add
  Future<dynamic> getCartAddResponse(
      int? id, String? variant, int? userId, int? quantity) async {
    String postBody;

    if (guest_checkout_status.$ && !is_logged_in.$) {
      postBody = jsonEncode({
        "id": "$id",
        "variant": variant,
        "quantity": "$quantity",
        "temp_user_id": temp_user_id.$
      });
    } else {
      postBody = jsonEncode({
        "id": "$id",
        "variant": variant,
        "user_id": "$userId",
        "quantity": "$quantity",
      });
    }

    String url = ("${AppConfig.BASE_URL}/carts/add");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!
      },
      body: postBody,
      middleware: BannedUser(),
    );
    print("digital cart add response: ${response.body}");
    return cartAddResponseFromJson(response.body);
  }

  Future<dynamic> getCartSummaryResponse() async {
    String postBody;

    if (guest_checkout_status.$ && !is_logged_in.$) {
      postBody = jsonEncode({"temp_user_id": temp_user_id.$});
    } else {
      postBody = jsonEncode({"user_id": user_id.$});
    }

    String url = ("${AppConfig.BASE_URL}/cart-summary");
    final response = await ApiRequest.post(
        url: url,
        body: postBody,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());

    return cartSummaryResponseFromJson(response.body);
  }
}
