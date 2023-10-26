import 'dart:convert';

import '../data/scalecmd_data.dart';
import '../main.dart';

class PublicFunctions {
  static void function1() {}

  static void getUIConf() {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getScaleList() {
    myScaleCmd.cmdMode = "get_scale_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getProductList() {
    myScaleCmd.cmdMode = "get_product_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getIpInfo() {
    myScaleCmd.cmdMode = 'get_ip_info';
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getApInfo() {
    myScaleCmd.cmdMode = 'get_wifi_info';
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void reScanApList() {
    myScaleCmd.cmdMode = 'rescan_ap_list';
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getPortList() {
    myScaleCmd.cmdMode = "get_port_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getIpMode() {
    myScaleCmd.cmdMode = "get_ip_mode";
    myScaleCmd.cmdData = "";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getWifiList() {
    myScaleCmd.cmdMode = 'get_ap_list';
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void sendModifyInfo(String modifyString) {
    myScaleCmd.cmdMode = "modify_scale";
    myScaleCmd.cmdData = modifyString;
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getWeight() {
    myScaleCmd.cmdMode = "reg_weight_data";
    myScaleCmd.cmdData = "";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void stopWeight() {
    myScaleCmd.cmdMode = "unreg_weight_data";
    myScaleCmd.cmdData = "";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getUserList() {
    myScaleCmd.cmdMode = "get_user_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  static void performZero() {
    myScaleCmd.cmdMode = "zero";
    myScaleCmd.cmdData = "";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void performTare() {
    myScaleCmd.cmdMode = "tare";
    myScaleCmd.cmdData = "";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getRecords() {
    myScaleCmd.cmdMode = "get_recs";
    myScaleCmd.cmdData = "";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void modifyBtEmissionPower3() {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:TPL-(+10)";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void modifyBtEmissionPower2() {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:TPL-(+6)";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void modifyBtEmissionPower1() {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:TPL-(0)";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getBtName() {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:NAM-?";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void updateLicense(String license) {
    myScaleCmd.cmdMode = "update_license";
    myScaleCmd.cmdData = license;
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  static void checkLicenseKey(String license) {
    myScaleCmd.cmdMode = "check_license_key";
    myScaleCmd.cmdData = license;
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  static void checkLicense() {
    myScaleCmd.cmdMode = "check_license";
    myScaleCmd.cmdData = '';
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  static void checkSerialPort() {
    myScaleCmd.cmdMode = "check_serial_port";
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getBuildInfo() {
    myScaleCmd.cmdMode = "get_build_info";
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void openScalePassth() {
    myScaleCmd.cmdMode = "open_scale_passthrough";
    myScaleCmd.cmdData = 'string';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void changeScalePassth(bool isHex) {
    myScaleCmd.cmdMode = "change_scale_passth_mode";
    if (isHex) {
      myScaleCmd.cmdData = 'hex';
    } else {
      myScaleCmd.cmdData = 'string';
    }

    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void closeScalePassth() {
    myScaleCmd.cmdMode = "close_scale_passthrough";
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }
}
