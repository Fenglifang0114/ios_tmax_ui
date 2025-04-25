import 'package:flutter/material.dart';

themeColor(Map<String, dynamic> colorTheme) {
  return ThemeData(
      fontFamily: "alibaba",
      colorScheme: ColorScheme(
        primary: Color(0xFF004D8A),
        // Color(
        //     int.parse(colorTheme['primary'])), //主色 // 0xFF004D8A),//1599FE
        secondary: Color(int.parse(colorTheme['secondary'])),
        tertiary: Color(int.parse(colorTheme['tertiary'])),
        surfaceTint: Color(int.parse(colorTheme['background'])), //主要的背景色
        error: Color(int.parse(colorTheme['error'])),
        onTertiaryFixedVariant: Color(int.parse(colorTheme['success'])),
        outline: const Color.fromARGB(255, 191, 191, 191),
        surfaceBright: const Color.fromARGB(255, 239, 243, 246),
        surface: Color(int.parse(colorTheme['background'])), //0xFFEFF3F6
        brightness: Brightness.light,
        surfaceContainerHigh: Colors.white,
        onError: Colors.white,
        onPrimary: Colors.white, //字体颜色
        onSecondary: Colors.white,
        onSurface: Color(0xFF333333), // Colors.black,
        onSurfaceVariant: Color(0xFF666666),
        onInverseSurface: Colors.black,
        secondaryFixed: const Color.fromARGB(255, 191, 191, 191), //0xFFBFBFBFF
        onTertiary: Colors.white,
        tertiaryContainer:
            const Color.fromARGB(255, 251, 253, 248), //0xFFF8F9FD
        primaryContainer: Color(int.parse(colorTheme['primary'])), //0xFFF8F9FD
        scrim: const Color.fromARGB(255, 204, 224, 239), //0xCCE0EF
        shadow: Color(
            0xFF004D8A), // const Color.fromARGB(255, 115, 238, 207), 图标的渐变色去掉了//0xFF73EECF
        // surfaceTint: Colors.white, //主要的背景色
        // error: Color.fromARGB(255, 199, 0, 38), //0xFFC70026
        // outline: Color.fromARGB(255, 27, 94, 32), //0xFF1B5E20
        // tertiary: Color.fromARGB(255, 31, 166, 255), //#0xFF1FA6FF
        // primary: Color.fromARGB(255, 21, 153, 254), //上方标题栏颜色  //0xFF1599FE
        // secondary: Color.fromARGB(255, 10, 124, 255), //0xFF0A7CFF
        // all fields should have a value
      ));
}
