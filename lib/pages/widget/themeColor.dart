import 'package:flutter/material.dart';

themeColor() {
  return ThemeData(
      fontFamily: "msyh",
      colorScheme: ColorScheme(
          primary: Colors.blue.shade900, //上方标题栏颜色
          secondary: Colors.blue.shade200,
          background: const Color.fromARGB(255, 236, 234, 235),
          error: Colors.red,
          brightness: Brightness.light,
          onBackground: const Color.fromARGB(255, 236, 234, 235),
          onError: Colors.yellow,
          onPrimary: Colors.white, //字体颜色
          onSecondary: Colors.white,
          onSurface: Colors.black,
          surface: Colors.redAccent
          // all fields should have a value
          ));
}
