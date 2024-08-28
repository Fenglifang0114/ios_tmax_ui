import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/pages/home_page_config.dart';
import 'package:t_max/pages/home_page_industry.dart';
import '../functions/methods.dart';
import '../pages/home_page_retail.dart';
import 'company_info.dart';
import 'encrypt_data.dart';

const int tConfig = 1;
const int tIndustry = 2;
const int tRetail = 3;
int mySystemVersion = tRetail;
const String appTConfig = "T-CONFIG";
const String appTIndustrial = "T-Industrial";
const String appTRetail = "T-RETAIL";

class SystemVersionInfo {
  Widget getHomePage() {
    PublicFunctions.getScaleList();
    if (mySystemVersion == tConfig) {
      return const HomePage();
    } else if (mySystemVersion == tIndustry) {
      PublicFunctions.getUIConfNormal();
      PublicFunctions.getUIConfCheck();
      PublicFunctions.getUIConfTakeIn();
      PublicFunctions.getUIConfTakeOut();
      return const IndustryHomePage();
    } else {
      return const RetailHomePage();
    }
  }

  Future<void> openAppNameJson() async {
    String appNameData =
        await rootBundle.loadString('assets/template/app_name.json');
    try {
      String decryptData = myFilePassword.decryptCsv(appNameData);
      Map<String, dynamic> jsonMap = jsonDecode(decryptData);
      myAppName = AppName.fromJson(jsonMap);
    } catch (e) {
      print('Failed to parse JSON: $e');
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
