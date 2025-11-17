import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

import 'company_info.dart';
import 'encrypt_data.dart';

const int tConfig = 1;
const int tIndustry = 2;
const int tRetail = 3;
int mySystemVersion = 1;
const String appTConfig = "T-Connect";
const String appTIndustrial = "T-Connect";
const String appTRetail = "T-Connect";

class SystemVersionInfo {
  Future<void> openAppNameJson() async {
    String appNameData =
        await rootBundle.loadString('assets/template/app_name.json');
    try {
      String decryptData = myFilePassword.decryptCsv(appNameData);
      Map<String, dynamic> jsonMap = jsonDecode(decryptData);
      myAppName = AppName.fromJson(jsonMap);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to parse JSON: $e');
      }
    }
  }

  Future<void> getAppName() async {
    await openAppNameJson();
  }

  Future<void> getTitle() async {
    if (myAppName.appName != "") {
      return;
    }
    await getAppName();
    if (myAppName.appName != "") {
      return;
    }

    if (mySystemVersion == tConfig) {
      myAppName.appName = appTConfig;
    } else if (mySystemVersion == tIndustry) {
      myAppName.appName = appTIndustrial;
    } else {
      myAppName.appName = appTRetail;
    }
    return;
  }

  //写版本号 将json写为字符串，调用这个函数，可以加密json
  // Future<void> openAppNameJson() async {
  //   String appNameData =
  //       await rootBundle.loadString('assets/template/app_name.json');
  //   String encryptData = myFilePassword.encryptCsv(appNameData);
  //   final file = File(
  //       'G:\\T-max\\20230530\\TMaxPcServiceUI\\assets\\template\\app_name.json');
  //   await file.writeAsString(encryptData, mode: FileMode.write, encoding: utf8);

  //   try {
  //     String decryptData = myFilePassword.decryptCsv(encryptData);
  //     print(decryptData);
  //     Map<String, dynamic> jsonMap = jsonDecode(decryptData);
  //     myAppName = AppName.fromJson(jsonMap);
  //   } catch (e) {
  //     print('Failed to parse JSON: $e');
  //   }
  // }
}

SystemVersionInfo mySystemVersionInfo = SystemVersionInfo();
