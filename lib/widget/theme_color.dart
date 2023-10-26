import 'package:flutter/material.dart';

themeColor() {
  return ThemeData(
      fontFamily: "msyh",
      colorScheme: ColorScheme(
        primary: const Color.fromARGB(255, 21, 153, 254), //上方标题栏颜色
        secondary: const Color.fromARGB(255, 21, 153, 254),
        background: const Color.fromARGB(255, 191, 191, 191),
        error: const Color.fromARGB(255, 199, 0, 38),
        brightness: Brightness.light,
        onBackground: Colors.black,
        onError: Colors.white,
        onPrimary: Colors.white, //字体颜色
        onSecondary: Colors.white,
        onSurface: Colors.black,
        surface: Color.fromARGB(255, 239, 243, 246),
        outline: Colors.green.shade900,
        tertiary: const Color.fromARGB(255, 248, 249, 253),
        onTertiary: Colors.black,
        scrim: Color.fromARGB(255, 204, 224, 239),
        secondaryContainer: Color.fromARGB(171, 191, 191, 191),
        // all fields should have a value
      ));
}
