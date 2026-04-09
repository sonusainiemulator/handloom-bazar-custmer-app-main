import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../my_theme.dart';

class ToastComponent {
  static showDialog(String msg, {duration = 0, gravity = 0}) {
    // ToastContext().init(OneContext().context!);
    Fluttertoast.showToast(
      msg: msg,
      // toastLength: duration != 0 ? duration : Toast.LENGTH_LONG,
      // gravity: gravity != 0 ? gravity : ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Color.fromRGBO(239, 239, 239, .9),
      textColor: MyTheme.font_grey,
      // border: Border(
      //     top: BorderSide(
      //       color: Color.fromRGBO(203, 209, 209, 1),
      //     ),
      //     bottom: BorderSide(
      //       color: Color.fromRGBO(203, 209, 209, 1),
      //     ),
      //     right: BorderSide(
      //       color: Color.fromRGBO(203, 209, 209, 1),
      //     ),
      //     left: BorderSide(
      //       color: Color.fromRGBO(203, 209, 209, 1),
      //     )),
      // backgroundRadius: 6,
    );
  }
}
