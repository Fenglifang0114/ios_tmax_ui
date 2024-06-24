import 'dart:convert';
import 'package:t_max/data/server_ip_data.dart';
import 'package:t_max/data/writelog.dart';

import '../data/download_prt_fmt.dart';
import '../data/scale_info_from_scale.dart';
import '../data/scalecmd_data.dart';
import '../data/settingparam_data.dart';
import '../main.dart';

class PublicFunctions {
  static void function1() {}

  static void getUIConfNormal() {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = "0";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getUIConfCheck() {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = "1";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getUIConfTakeIn() {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = "2";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getUIConfTakeOut() {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = "3";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
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

  static void getScaleTime() {
    myScaleCmd.cmdMode = 'get_scale_time';
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void setScaleTime(String time) {
    myScaleCmd.cmdMode = 'set_scale_time';
    myScaleCmd.cmdData = time;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void changeWifiMode() {
    myScaleCmd.cmdMode = 'change_wifi_mode';
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
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
    writelog(jsonEncode(myScaleCmd));
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
    writelog(jsonEncode(myScaleCmd));
  }

  static void performTare() {
    myScaleCmd.cmdMode = "tare";
    myScaleCmd.cmdData = "";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void getRecords() {
    String scaleName = myFactoryInfoFromScale.modelName == null
        ? ''
        : myFactoryInfoFromScale.modelName!;
    myScaleCmd.cmdMode = "get_recs";
    myScaleCmd.cmdData = "0" +
        ',' +
        myFactoryInfoFromScale.modelName! +
        ',' +
        myFactoryInfoFromScale.scaleSn! +
        ',' +
        scaleName; //根据scale model scale sn  scale name(别名)
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getCheckWeigherRecords() {
    String scaleName = myFactoryInfoFromScale.modelName == null
        ? ''
        : myFactoryInfoFromScale.modelName!;
    myScaleCmd.cmdMode = "get_recs";
    myScaleCmd.cmdData = "1" +
        ',' +
        myFactoryInfoFromScale.modelName! +
        ',' +
        myFactoryInfoFromScale.scaleSn! +
        ',' +
        scaleName; //根据scale model scale sn  scale name(别名)
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getTakeInRecords() {
    String scaleName = myFactoryInfoFromScale.modelName == null
        ? ''
        : myFactoryInfoFromScale.modelName!;
    myScaleCmd.cmdMode = "get_recs";
    myScaleCmd.cmdData = "2" +
        ',' +
        myFactoryInfoFromScale.modelName! +
        ',' +
        myFactoryInfoFromScale.scaleSn! +
        ',' +
        scaleName; //根据scale model scale sn  scale name(别名)
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getTakeOutRecords() {
    String scaleName = myFactoryInfoFromScale.modelName == null
        ? ''
        : myFactoryInfoFromScale.modelName!;
    myScaleCmd.cmdMode = "get_recs";
    myScaleCmd.cmdData = "3" +
        ',' +
        myFactoryInfoFromScale.modelName! +
        ',' +
        myFactoryInfoFromScale.scaleSn! +
        ',' +
        scaleName; //根据scale model scale sn  scale name(别名)
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void modifyBtPowerStrong() {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:TPL-(+10)";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void modifyBtPowerNormal() {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:TPL-(+6)";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void modifyBtPowerWeak() {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:TPL-(0)";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void getBtName() {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:NAM-?";
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void modifyBtName(String btName) {
    myScaleCmd.cmdMode = "modify_bt_name";
    myScaleCmd.cmdData = btName;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void getOneEepromInfo(String func) {
    myScaleCmd.cmdMode = "get_one_eeprom_info";
    myScaleCmd.cmdData = func;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getAllEepromInfo() {
    myScaleCmd.cmdMode = "get_all_eeprom_info";
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void modifyEepromInfo(String dataStr) {
    myScaleCmd.cmdMode = "modify_eeprom_info";
    myScaleCmd.cmdData = dataStr;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void setWifiDynamicMode() {
    myScaleCmd.cmdMode = 'set_wifi_dynamic_ip';
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
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

  static void getLicense() {
    myScaleCmd.cmdMode = "get_license";
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

  static void getWeightErr() {
    myScaleCmd.cmdMode = "get_weight_err";
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

  static void getFactoryInfo() {
    myScaleCmd.cmdMode = "get_factory_info";
    myScaleCmd.cmdData = '';
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void deleteAllRecords() {
    String modelName = myFactoryInfoFromScale.modelName == null
        ? ''
        : myFactoryInfoFromScale.modelName!;
    String scaleSn = myFactoryInfoFromScale.scaleSn == null
        ? ''
        : myFactoryInfoFromScale.scaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,0,' + modelName + ',' + scaleSn;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsCheck() {
    String modelName = myFactoryInfoFromScale.modelName == null
        ? ''
        : myFactoryInfoFromScale.modelName!;
    String scaleSn = myFactoryInfoFromScale.scaleSn == null
        ? ''
        : myFactoryInfoFromScale.scaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,1,' + modelName + ',' + scaleSn;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsTakeIn() {
    String modelName = myFactoryInfoFromScale.modelName == null
        ? ''
        : myFactoryInfoFromScale.modelName!;
    String scaleSn = myFactoryInfoFromScale.scaleSn == null
        ? ''
        : myFactoryInfoFromScale.scaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,2,' + modelName + ',' + scaleSn;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsTakeOut() {
    String modelName = myFactoryInfoFromScale.modelName == null
        ? ''
        : myFactoryInfoFromScale.modelName!;
    String scaleSn = myFactoryInfoFromScale.scaleSn == null
        ? ''
        : myFactoryInfoFromScale.scaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,3,' + modelName + ',' + scaleSn;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  static void getNewUiConf() {
    if (mySettingParam.scaleMode == 0) {
      PublicFunctions.getUIConfNormal();
    } else if (mySettingParam.scaleMode == 1) {
      PublicFunctions.getUIConfCheck();
    } else if (mySettingParam.scaleMode == 2) {
      PublicFunctions.getUIConfTakeIn();
    } else if (mySettingParam.scaleMode == 3) {
      PublicFunctions.getUIConfTakeOut();
    }
  }

  static void sendOutputFmtToScale(List<String> list) async {
    myDownLoadSetOutputFmt.filePath = list;
    String json = jsonEncode(myDownLoadSetOutputFmt);
    myScaleCmd.cmdMode = "set_output_format";
    myScaleCmd.cmdData = json;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void sendServerIpToScale(ServerIpData serverData) async {
    String json = jsonEncode(serverData);
    myScaleCmd.cmdMode = "set_server_ip";
    myScaleCmd.cmdData = json;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    print(jsonEncode(myScaleCmd));
  }
}
