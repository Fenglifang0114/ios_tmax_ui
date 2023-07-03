import 'package:flutter/material.dart';

themeColor() {
  return ThemeData(
      fontFamily: "msyh",
      colorScheme: const ColorScheme(
          primary: Color.fromARGB(255, 0, 74, 152), //上方标题栏颜色
          secondary: Color.fromARGB(255, 0, 160, 233),
          background: Color.fromARGB(255, 236, 234, 235),
          error: Color.fromARGB(255, 199, 0, 38),
          brightness: Brightness.light,
          onBackground: Color.fromARGB(255, 236, 234, 235),
          onError: Color.fromARGB(255, 240, 133, 0),
          onPrimary: Colors.white, //字体颜色
          onSecondary: Colors.white,
          onSurface: Colors.black,
          surface: Colors.redAccent
          // all fields should have a value
          ));
}
