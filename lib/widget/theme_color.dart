import 'package:flutter/material.dart';

themeColor() {
  return ThemeData(
      fontFamily: "msyh",
      colorScheme: ColorScheme(
        primary: const Color.fromARGB(255, 0, 74, 152), //上方标题栏颜色
        secondary: const Color.fromARGB(255, 0, 160, 233),
        background: Color.fromARGB(255, 211, 213, 217),
        error: const Color.fromARGB(255, 199, 0, 38),
        brightness: Brightness.light,
        onBackground: Colors.black,
        onError: Colors.white,
        onPrimary: Colors.white, //字体颜色
        onSecondary: Colors.white,
        onSurface: Colors.black,
        surface: const Color.fromARGB(255, 181, 181, 182),
        outline: Colors.green.shade900,
        // all fields should have a value
      ));
}
