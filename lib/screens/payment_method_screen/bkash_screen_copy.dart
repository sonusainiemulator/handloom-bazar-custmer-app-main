import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/payment_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/orders/order_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../profile.dart';

class BkashScreen extends StatefulWidget {
  double? amount;
  String payment_type;
  String? payment_method_key;
  var package_id;
  int? orderId;
  BkashScreen(
      {super.key,
      this.amount = 0.00,
      this.orderId = 0,
      this.payment_type = "",
      this.payment_method_key = "",
      this.package_id = "0"});

  @override
  _BkashScreenState createState() => _BkashScreenState();
}

class _BkashScreenState extends State<BkashScreen> {
  int? _combined_order_id = 0;
  bool _order_init = false;
  String? _initial_url = "";
  bool _initial_url_fetched = false;

  String? _token = "";
  bool showLoading = false;

  final WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.payment_type == "cart_payment") {
      createOrder();
    }

    if (widget.payment_type != "cart_payment") {
      // on cart payment need proper order id
      getSetInitialUrl();
    }
  }

  createOrder() async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponse(widget.payment_method_key);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(
        orderCreateResponse.message,
      );
      Navigator.of(context).pop();
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});

    getSetInitialUrl();
  }

  getSetInitialUrl() async {
    var bkashUrlResponse = await PaymentRepository().getBkashBeginResponse(
        widget.payment_type,
        _combined_order_id,
        widget.package_id,
        widget.amount,
        widget.orderId!);

    if (bkashUrlResponse.result == false) {
      ToastComponent.showDialog(
        bkashUrlResponse.message!,
      );
      Navigator.of(context).pop();
      return;
    }
    _token = bkashUrlResponse.token;

    _initial_url = bkashUrlResponse.url;
    _initial_url_fetched = true;

    setState(() {});
    bkash();

    // print(_initial_url);
    // print(_initial_url_fetched);
  }

  bkash() {
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {},
          onPageFinished: (page) {
            if (page.contains("/bkash/api/callback")) {
              getData();
            } else if (page.contains("/bkash/api/fail")) {
              ToastComponent.showDialog(
                "Payment cancelled",
              );
              Navigator.of(context).pop();
              return;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_initial_url!), headers: commonHeader);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: buildBody(),
    );
  }

  void getData() {
    String? paymentDetails = '';
    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      var responseJSON = jsonDecode(data as String);
      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }
      print(data);
      if (responseJSON["result"] == false) {
        ToastComponent.showDialog(
          responseJSON["message"],
        );
        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        paymentDetails = responseJSON['payment_details'];
        onPaymentSuccess(responseJSON);
      }
    });
  }

  onPaymentSuccess(paymentDetails) async {
    showLoading = true;
    setState(() {});

    var bkashPaymentProcessResponse =
        await PaymentRepository().getBkashPaymentProcessResponse(
      amount: widget.amount,
      token: _token,
      payment_type: widget.payment_type,
      combined_order_id: _combined_order_id,
      package_id: widget.package_id,
      payment_id: paymentDetails['paymentID'],
    );

    if (bkashPaymentProcessResponse.result == false) {
      ToastComponent.showDialog(
        bkashPaymentProcessResponse.message!,
      );
      Navigator.pop(context);
      return;
