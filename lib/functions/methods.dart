import 'dart:convert';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/writelog.dart';

import '../common/web_socket_channel.dart';
import '../data/download_prt_fmt.dart';
import '../data/manager_scale_channel.dart';
import '../data/scale_info_from_scale.dart';
import '../data/scalecmd_data.dart';
import '../data/settingparam_data.dart';

const String weighingMode = '0';
const String weighingCheckMode = '1';
const String weighingTakeInMode = '2';
const String weighingTakeOutMode = '3';

class PublicFunctions {
  static void function1() {}

  static void sendMsg(int scaleId, String str) {
    manager.sendMessage(scaleId, str);
  }

  static void sendMsgChan0(String str) {
    webchannel.sendMessage(str);
  }

  static void addUser(String str) {
    myScaleCmd.cmdMode = "add_user";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void modifyUser(String str) {
    myScaleCmd.cmdMode = "modify_user";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void delUser(String str) {
    myScaleCmd.cmdMode = "del_user";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getScaleList() {
    myScaleCmd.cmdMode = "get_scale_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getScaleSrvList(int srvId) {
    myScaleCmd.cmdMode = "get_scale_srv_list";
    myScaleCmd.cmdData = srvId.toString();
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void setScaleSrvStatus(String dataStr) {
    myScaleCmd.cmdMode = "set_scale_srv_val";
    myScaleCmd.cmdData = dataStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getDetailList() {
    myScaleCmd.cmdMode = "get_detail_list";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getDetailListSrv1() {
    myScaleCmd.cmdMode = "get_detail_list";
    myScaleCmd.cmdData = "";
    String infoStr = jsonEncode(myScaleCmd);
    myScaleCmd.cmdMode = "send_to_srv1";
    myScaleCmd.cmdData = infoStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

//获取最新的一条信息，不要全部列表
  static void getNewDetailFormSrv1() {
    myScaleCmd.cmdMode = "get_new_detail";
    myScaleCmd.cmdData = "";
    String infoStr = jsonEncode(myScaleCmd);
    myScaleCmd.cmdMode = "send_to_srv1";
    myScaleCmd.cmdData = infoStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getProductList() {
    myScaleCmd.cmdMode = "get_product_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void addProduct(String str) {
    myScaleCmd.cmdMode = "add_product";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void modifyProduct(String str) {
    myScaleCmd.cmdMode = "modify_product";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getPortList() {
    myScaleCmd.cmdMode = "get_port_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void delProduct(String str) {
    myScaleCmd.cmdMode = "del_product";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void delAllProduct() {
    myScaleCmd.cmdMode = "del_all_product";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void sendModifyInfo(String modifyString) {
    myScaleCmd.cmdMode = "modify_scale";
    myScaleCmd.cmdData = modifyString;
    sendMsgChan0(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void sendAddScale(String addString) {
    myScaleCmd.cmdMode = "add_scale";
    myScaleCmd.cmdData = addString;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void sendModifyScaleName(String scaleName) {
    myScaleCmd.cmdMode = "modify_scale_name";
    myScaleCmd.cmdData = scaleName;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void sendServiceAction(String actionStr) {
    myScaleCmd.cmdMode = "do_service_action";
    myScaleCmd.cmdData = actionStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void sendDelScale(String delString) {
    myScaleCmd.cmdMode = "del_scale";
    myScaleCmd.cmdData = delString;
    sendMsgChan0(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void getUserList() {
    myScaleCmd.cmdMode = "get_user_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getWifiPwdList() {
    myScaleCmd.cmdMode = "get_wifi_pwd_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void addWifiPwd(String wifiStr) {
    myScaleCmd.cmdMode = "add_wifi_pwd";
    myScaleCmd.cmdData = wifiStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void updateLicense(String license) {
    myScaleCmd.cmdMode = "update_license";
    myScaleCmd.cmdData = license;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void checkLicenseKey(String license) {
    myScaleCmd.cmdMode = "check_license_key";
    myScaleCmd.cmdData = license;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getLicense() {
    myScaleCmd.cmdMode = "get_license";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getNewUiConf(int scaleId) {
    if (mySettingParam.scaleMode == 0) {
      PublicFunctions.getUIConfNormal(scaleId);
    } else if (mySettingParam.scaleMode == 1) {
      PublicFunctions.getUIConfCheck(scaleId);
    } else if (mySettingParam.scaleMode == 2) {
      PublicFunctions.getUIConfTakeIn(scaleId);
    } else if (mySettingParam.scaleMode == 3) {
      PublicFunctions.getUIConfTakeOut(scaleId);
    }
  }

  static void closeSerialPort(int scaleId) {
    myScaleCmd.cmdMode = "close_serial_port";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void openSerialPort(int scaleId) {
    myScaleCmd.cmdMode = "open_serial_port";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void sendFormatToScale(String firmwarePathStr) {
    myScaleCmd.cmdMode = "update_firmware";
    myScaleCmd.cmdData = firmwarePathStr;
    sendMsg(1, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void updateFirmWareOnline(String str, int scaleId) {
    myScaleCmd.cmdMode = "update_firmware_wifi";
    myScaleCmd.cmdData = str;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getUIConfNormal(int scaleId) {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = "0";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getUIConfCheck(int scaleId) {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = "1";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getUIConfTakeIn(int scaleId) {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = "2";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getUIConfTakeOut(int scaleId) {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = "3";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getIpInfo(int scaleId) {
    myScaleCmd.cmdMode = 'get_ip_info';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getApInfo(int scaleId) {
    myScaleCmd.cmdMode = 'get_wifi_info';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getScaleTime(int scaleId) {
    myScaleCmd.cmdMode = 'get_scale_time';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setScaleTime(String time, int scaleId) {
    myScaleCmd.cmdMode = 'set_scale_time';
    myScaleCmd.cmdData = time;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void changeWifiMode(int scaleId) {
    myScaleCmd.cmdMode = 'change_wifi_mode';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void reScanApList(int scaleId) {
    myScaleCmd.cmdMode = 'rescan_ap_list';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getIpMode(int scaleId) {
    myScaleCmd.cmdMode = "get_ip_mode";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getWifiList(int scaleId) {
    myScaleCmd.cmdMode = 'get_ap_list';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getWeight(int scaleId) {
    myScaleCmd.cmdMode = "reg_weight_data";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void stopWeight(int scaleId) {
    myScaleCmd.cmdMode = "unreg_weight_data";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static performZero() {
    myScaleCmd.cmdMode = "zero";
    myScaleCmd.cmdData = "";
    sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static performTare() {
    myScaleCmd.cmdMode = "tare";
    myScaleCmd.cmdData = "";
    sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void openBillSend(int scaleId) {
    //开启结账发送
    myScaleCmd.cmdMode = 'open_bill_send';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  // static void getRecords(int scaleId, String mode) {
  //   myScaleCmd.cmdMode = "get_recs";
  //   myScaleCmd.cmdData =
  //       '$mode,${myDefScaleInfo.defScaleModel},${myDefScaleInfo.defScaleSn},${myDefScaleInfo.defScaleModel}'; //根据scale model scale sn  scale name(别名)
  //   sendMsg(scaleId, jsonEncode(myScaleCmd));
  // }

  static void exportRecords(int scaleId, String mode, String path) {
    myScaleCmd.cmdMode = "export_recs";
    myScaleCmd.cmdData =
        '$mode,${myDefScaleInfo.defScaleModel},${myDefScaleInfo.defScaleSn},${myDefScaleInfo.defScaleModel},$path'; //根据scale model scale sn  scale name(别名)
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getRecords(int scaleId, String mode, int page, int pageSize,
      String sortColumnName, String direction) {
    myScaleCmd.cmdMode = "get_recs";
    myScaleCmd.cmdData =
        '$mode,${myDefScaleInfo.defScaleModel},${myDefScaleInfo.defScaleSn},${myDefScaleInfo.defScaleModel},$page,$pageSize,$sortColumnName,$direction'; //根据scale model scale sn  scale name(别名)
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void modifyBtPowerStrong(int scaleId) {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:TPL-(+10)";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void modifyBtPowerNormal(int scaleId) {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:TPL-(+6)";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void modifyBtPowerWeak(int scaleId) {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:TPL-(0)";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void getBtName(int scaleId) {
    myScaleCmd.cmdMode = "send_data_to_bt";
    myScaleCmd.cmdData = "TTM:NAM-?";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void modifyBtName(String btName, int scaleId) {
    myScaleCmd.cmdMode = "modify_bt_name";
    myScaleCmd.cmdData = btName;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void setLowHighLimit(String data, int scaleId) {
    myScaleCmd.cmdMode = "set_limit_to_scale";
    myScaleCmd.cmdData = data;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getOneEepromInfo(String func, int scaleId) {
    myScaleCmd.cmdMode = "get_one_eeprom_info";
    myScaleCmd.cmdData = func;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getAllEepromInfo(int scaleId) {
    myScaleCmd.cmdMode = "get_all_eeprom_info";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void modifyEepromInfo(String dataStr, int scaleId) {
    myScaleCmd.cmdMode = "modify_eeprom_info";
    myScaleCmd.cmdData = dataStr;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setWifiDynamicMode(int scaleId) {
    myScaleCmd.cmdMode = 'set_wifi_dynamic_ip';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void sendOutputFmtToScale(List<String> list, int scaleId) async {
    scaleId = 1;
    myDownLoadSetOutputFmt.filePath = list;
    String json = jsonEncode(myDownLoadSetOutputFmt);
    myScaleCmd.cmdMode = "set_output_format";
    myScaleCmd.cmdData = json;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void sendServerIpToScale(String str, int scaleId) async {
    myScaleCmd.cmdMode = "set_server_ip";
    myScaleCmd.cmdData = str;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    // print(jsonEncode(myScaleCmd));
  }

  static void checkSerialPort(int scaleId) {
    myScaleCmd.cmdMode = "check_serial_port";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void sendScaleAlive(int scaleId) {
    myScaleCmd.cmdMode = "send_scale_alive";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getBuildInfo(int scaleId) {
    myScaleCmd.cmdMode = "get_build_info";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getWeightErr(int scaleId) {
    myScaleCmd.cmdMode = "get_weight_err";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getBasicData(int scaleId) {
    myScaleCmd.cmdMode = "get_basic_data";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void openScalePassth(int scaleId) {
    if (scaleId == 1) {
      myScaleCmd.cmdMode = "open_scale_passthrough";
      myScaleCmd.cmdData = 'string';
      sendMsg(scaleId, jsonEncode(myScaleCmd));
    }
  }

  static void changeScalePassth(bool isHex, int scaleId) {
    if (scaleId == 1) {
      myScaleCmd.cmdMode = "change_scale_passth_mode";
      if (isHex) {
        myScaleCmd.cmdData = 'hex';
      } else {
        myScaleCmd.cmdData = 'string';
      }

      sendMsg(scaleId, jsonEncode(myScaleCmd));
    }
  }

  static void closeScalePassth(int scaleId) {
    if (scaleId == 1) {
      myScaleCmd.cmdMode = "close_scale_passthrough";
      myScaleCmd.cmdData = '';
      sendMsg(scaleId, jsonEncode(myScaleCmd));
    }
  }

  static void closewifiPassth(int scaleId) {
    if (scaleId == 1) {
      myScaleCmd.cmdMode = "dis_passth_mode";
      myScaleCmd.cmdData = '';
      sendMsg(scaleId, jsonEncode(myScaleCmd));
    }
  }

  static void getFactoryInfo(int scaleId) {
    myScaleCmd.cmdMode = "get_factory_info";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void deleteAllRecords(int scaleId) {
    String modelName = myDefScaleInfo.defScaleModel == null
        ? ''
        : myDefScaleInfo.defScaleModel!;
    String scaleSn =
        myDefScaleInfo.defScaleSn == null ? '' : myDefScaleInfo.defScaleSn!;

    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,0,$modelName,$scaleSn';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsCheck(int scaleId) {
    String modelName = myDefScaleInfo.defScaleModel == null
        ? ''
        : myDefScaleInfo.defScaleModel!;
    String scaleSn =
        myDefScaleInfo.defScaleSn == null ? '' : myDefScaleInfo.defScaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,1,$modelName,$scaleSn';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsTakeIn(int scaleId) {
    String modelName = myDefScaleInfo.defScaleModel == null
        ? ''
        : myDefScaleInfo.defScaleModel!;
    String scaleSn =
        myDefScaleInfo.defScaleSn == null ? '' : myDefScaleInfo.defScaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,2,$modelName,$scaleSn';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsTakeOut(int scaleId) {
    String modelName = myDefScaleInfo.defScaleModel == null
        ? ''
        : myDefScaleInfo.defScaleModel!;
    String scaleSn =
        myDefScaleInfo.defScaleSn == null ? '' : myDefScaleInfo.defScaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,3,$modelName,$scaleSn';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }
}
