import 'package:flutter/material.dart';

themeColor(Map<String, dynamic> colorTheme, bool isDarkMode) {
  const regular = FontWeight.w500;
  const medium = FontWeight.w600;
  const semiBold = FontWeight.w600;
  const bold = FontWeight.w800;

  const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: semiBold,
      fontSize: 62.0,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: semiBold,
      fontSize: 32.0,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: semiBold,
      fontSize: 28.0,
    ),
    titleLarge: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: semiBold,
      fontSize: 24.0,
    ),
    titleMedium: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: semiBold,
      fontSize: 18.0,
    ),
    titleSmall: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: semiBold,
      fontSize: 16.0,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: regular,
      fontSize: 18.0,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: regular,
      fontSize: 16.0,
    ),
    bodySmall: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: regular,
      fontSize: 14.0,
    ),
    labelLarge: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: medium,
      fontSize: 18.0,
    ),
    labelMedium: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: medium,
      fontSize: 16.0,
    ),
    labelSmall: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: medium,
      fontSize: 14.0,
    ),
    displayLarge: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: bold,
      fontSize: 32.0,
    ),
    displayMedium: TextStyle(
      fontFamily: 'HarmonyOS',
      fontWeight: regular,
      fontSize: 24.0,
    ),
  );

  ColorScheme lightColorScheme = ColorScheme(
    primary: Color(int.parse(colorTheme['primary'])),
    secondary: Color(int.parse(colorTheme['secondary'])),
    tertiary: Color(int.parse(colorTheme['tertiary'])),
    surfaceTint: Color(int.parse(colorTheme['background'])), //主要的背景色
    error: Color(int.parse(colorTheme['error'])),
    onTertiaryFixedVariant: Color(int.parse(colorTheme['success'])),
    outline: const Color.fromARGB(255, 191, 191, 191),
    surfaceBright: const Color.fromARGB(255, 239, 243, 246),
    surface: Color(int.parse(colorTheme['background'])), //0xFFEFF3F6
    surfaceContainerHigh: Colors.white,
    onError: Colors.white,
    onPrimary: Colors.white, //字体颜色
    onSecondary: Colors.white,
    onSurface: Color(0xFF171A1D), //0xFF272727),   // Colors.black,
    onSurfaceVariant: Color(0xFF555759), //Color(0xFF606060),  //
    onInverseSurface: Colors.black,
    secondaryFixed: const Color.fromARGB(255, 191, 191, 191), //0xFFBFBFBFF
    onTertiary: Colors.white,
    tertiaryContainer: const Color.fromARGB(255, 251, 253, 248), //0xFFF8F9FD
    primaryContainer: Color(int.parse(colorTheme['primary'])), //0xFFF8F9FD
    scrim: const Color.fromARGB(255, 204, 224, 239), //0xCCE0EF
    shadow: Color(int.parse(colorTheme['primary'])),
    surfaceDim: Color(0xFFEFEFEF), //画布背景灰色
    outlineVariant: Color(0xFFE6E6E6), //输入框边框
    surfaceContainerLow: Color(0xFFF5F5F5), //选中框
    surfaceContainerLowest: Color(0xFFD0D0D0), //很少用
    surfaceContainerHighest: Color(0xFF7D8082), // Color(0xFF8D8D8D),
    secondaryContainer: Color(0xFFE6EEF4),
    onTertiaryContainer: Color(0xFFF4B837),

    brightness: Brightness.light,
  );

  ColorScheme darkColorScheme = ColorScheme(
    primary: Color(int.parse(colorTheme['primary'])),
    secondary: Color(int.parse(colorTheme['secondary'])),
    tertiary: Color(int.parse(colorTheme['tertiary'])),
    surfaceTint: Color(int.parse(colorTheme['background'])), //主要的背景色
    error: Color(int.parse(colorTheme['error'])),
    onTertiaryFixedVariant: Color(int.parse(colorTheme['success'])),
    outline: const Color.fromARGB(255, 191, 191, 191),
    surfaceBright: const Color.fromARGB(255, 239, 243, 246),
    surface: Color(int.parse(colorTheme['background'])), //0xFFEFF3F6
    surfaceContainerHigh: Colors.white,
    onError: Colors.white,
    onPrimary: Colors.white, //字体颜色
    onSecondary: Colors.white,
    onSurface: Color(0xFF333333), // Colors.black,
    onSurfaceVariant: Color(0xFF666666),
    onInverseSurface: Colors.black,
    secondaryFixed: const Color.fromARGB(255, 191, 191, 191), //0xFFBFBFBFF
    onTertiary: Colors.white,
    tertiaryContainer: const Color.fromARGB(255, 251, 253, 248), //0xFFF8F9FD
    primaryContainer: Color(int.parse(colorTheme['primary'])), //0xFFF8F9FD
    scrim: const Color.fromARGB(255, 204, 224, 239), //0xCCE0EF
    shadow: Color(int.parse(colorTheme['primary'])),
    surfaceDim: Color(0xFFEFEFEF), //画布背景灰色
    outlineVariant: Color(0xFFE6E6E6), //输入框边框
    surfaceContainerLow: Color(0xFFF5F5F5), //选中框
    surfaceContainerLowest: Color(0xFFD0D0D0), //很少用
    surfaceContainerHighest: Color(0xFF8D8D8D),
    secondaryContainer: Color(0xFFE6EEF4),
    onTertiaryContainer: Color(0xFFF4B837),
    brightness: Brightness.dark,
  );

  return ThemeData(
    textTheme: textTheme,
    colorScheme: isDarkMode ? darkColorScheme : lightColorScheme,
  );
}

 

  
  
 











// 下面是备份
// themeColor(Map<String, dynamic> colorTheme) {
//   return ThemeData(
//       fontFamily: "HarmonyOS",
//       colorScheme: ColorScheme(
//         primary: Color(0xFF004D8A),
//         // Color(
//         //     int.parse(colorTheme['primary'])), //主色 // 0xFF004D8A),//1599FE
//         secondary: Color(int.parse(colorTheme['secondary'])),
//         tertiary: Color(int.parse(colorTheme['tertiary'])),
//         surfaceTint: Color(int.parse(colorTheme['background'])), //主要的背景色
//         error: Color(int.parse(colorTheme['error'])),
//         onTertiaryFixedVariant: Color(int.parse(colorTheme['success'])),
//         outline: const Color.fromARGB(255, 191, 191, 191),
//         surfaceBright: const Color.fromARGB(255, 239, 243, 246),
//         surface: Color(int.parse(colorTheme['background'])), //0xFFEFF3F6
//         brightness: Brightness.light,
//         surfaceContainerHigh: Colors.white,
//         onError: Colors.white,
//         onPrimary: Colors.white, //字体颜色
//         onSecondary: Colors.white,
//         onSurface: Color(0xFF333333), // Colors.black,
//         onSurfaceVariant: Color(0xFF666666),
//         onInverseSurface: Colors.black,
//         secondaryFixed: const Color.fromARGB(255, 191, 191, 191), //0xFFBFBFBFF
//         onTertiary: Colors.white,
//         tertiaryContainer:
//             const Color.fromARGB(255, 251, 253, 248), //0xFFF8F9FD
//         primaryContainer: Color(int.parse(colorTheme['primary'])), //0xFFF8F9FD
//         scrim: const Color.fromARGB(255, 204, 224, 239), //0xCCE0EF
//         shadow: Color(
//             0xFF004D8A), // const Color.fromARGB(255, 115, 238, 207), 图标的渐变色去掉了//0xFF73EECF
//         // surfaceTint: Colors.white, //主要的背景色
//         // error: Color.fromARGB(255, 199, 0, 38), //0xFFC70026
//         // outline: Color.fromARGB(255, 27, 94, 32), //0xFF1B5E20
//         // tertiary: Color.fromARGB(255, 31, 166, 255), //#0xFF1FA6FF
//         // primary: Color.fromARGB(255, 21, 153, 254), //上方标题栏颜色  //0xFF1599FE
//         // secondary: Color.fromARGB(255, 10, 124, 255), //0xFF0A7CFF
//         // all fields should have a value
//       ));
// }