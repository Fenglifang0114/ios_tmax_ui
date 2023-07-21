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

  static void getWifiList() {
    myScaleCmd.cmdMode = 'get_ap_list';
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    print(jsonEncode(myScaleCmd));
  }
}
