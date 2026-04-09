import 'package:active_ecommerce_cms_demo_app/custom/lang_text.dart';
import 'package:flutter/material.dart';

class Loading {
  static NavigatorState? _navigator;
  static bool _isVisible = false;
  static bool _isClosing = false;

  static show(BuildContext context) async {
    if (_isVisible || _isClosing) {
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    _navigator = navigator;
    _isVisible = true;

    return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Row(
          children: [
            CircularProgressIndicator(),
            const SizedBox(
              width: 10,
            ),
            Text(LangText(context).local.please_wait_ucf),
          ],
        ));
      },
    ).then((_) {
      _isVisible = false;
      _isClosing = false;
      if (identical(_navigator, navigator)) {
        _navigator = null;
      }
    });
  }

  static Future<void> close() async {
    final navigator = _navigator;
    if (!_isVisible || _isClosing || navigator == null) {
      return;
    }

    _isClosing = true;

    // If close is called immediately after show, wait for the dialog route
    // push to finish before popping it.
    await WidgetsBinding.instance.endOfFrame;

    if (navigator.mounted && navigator.canPop()) {
      navigator.pop();
    }
  }

  static Widget bottomLoading(bool value) {
    return value
        ? Container(
            alignment: Alignment.center,
            child: SizedBox(
                height: 20, width: 20, child: CircularProgressIndicator()),
          )
        : SizedBox(
            height: 5,
            width: 5,
          );
  }
}
