import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration buildInputDecoration_1({hint_text = ""}) {
    return InputDecoration(
        hintText: hint_text,
        filled: true,
        fillColor: MyTheme.white,
        hintStyle: const TextStyle(fontSize: 12.0, color: Color(0xffA8AFB3)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.accent_color.withOpacity(0.6), width: 1.2),
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.accent_color, width: 1.8),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0));
  }

  static InputDecoration buildInputDecoration_phone({hint_text = ""}) {
    return InputDecoration(
        hintText: hint_text,
        hintStyle: const TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.accent_color.withOpacity(0.6), width: 1.2),
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0)),
        ),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.accent_color, width: 1.8),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0));
  }
}
