import 'dart:convert';

import 'package:flutter/services.dart';

Map<String, dynamic> colorTheme = {
  "primary": 0xFF1599FE,
  "secondary": 0xFF0A7CFF,
  "background": 0xFFEFF3F6,
  "error": 0xFFC70026,
  "tertiary": 0xFF1FA6FF,
  "success": 0xFF1B5E20,
};

Future<Map<String, dynamic>> loadColorsFromJson() async {
  String colorData =
      await rootBundle.loadString('assets/template/customized_colors.json');
  return json.decode(colorData);
}
