import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/company_info.dart';

String getVersion() {
  return "V1.24";
}

Widget versionInfo(Color? color) {
  return Text(getVersion(),
      style: TextStyle(
        color: color,
        fontSize: 20,
      ),
      textAlign: TextAlign.center);
}

Future openAppJson() async {
  final ByteData bytes = await rootBundle.load('assets/template/app_info.json');
  List<int> byteList = bytes.buffer.asUint8List();
  String jsonString = utf8.decode(byteList);

  try {
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    myCompanyInfo = CompanyInfo.fromJson(jsonMap);
    print('Failed to parse JSON: ');
  } catch (e) {
    print('Failed to parse JSON: $e');
  }
}
