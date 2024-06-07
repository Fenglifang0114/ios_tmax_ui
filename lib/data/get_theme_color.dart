import 'dart:convert';
import 'package:flutter/services.dart';
import 'encrypt_data.dart';

Map<String, dynamic> colorTheme = {
  "primary": 0xFF1599FE,
  "secondary": 0xFF0A7CFF,
  "background": 0xFFFFFFFF,
  "error": 0xFFC70026,
  "tertiary": 0xFF1FA6FF,
  "success": 0xFF1B5E20,
};

Future<Map<String, dynamic>> loadColorsFromJson() async {
  String colorData =
      await rootBundle.loadString('assets/template/customized_colors.json');
  try {
    String decryptData = myFilePassword.decryptCsv(colorData);
    return json.decode(decryptData);
  } catch (e) {
    return colorTheme;
  }
}

//可以用下面的程序写入json
// Future<Map<String, dynamic>> loadColorsFromJson() async {
//   String colorData =
//       await rootBundle.loadString('assets/template/customized_colors.json');
//   String encryptData = myFilePassword.encryptCsv(colorData);
//   final file = File(
//       'G:\\T-max\\20230530\\TMaxPcServiceUI\\assets\\template\\customized_colors.json');
//   await file.writeAsString(encryptData, mode: FileMode.write, encoding: utf8);

//   String decryptData = myFilePassword.decryptCsv(encryptData);
//   print(decryptData);

//   return json.decode(decryptData);
// }
