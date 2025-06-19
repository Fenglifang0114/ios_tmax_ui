import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/downloadresponse.dart';

import 'package:t_max/data/modifyresult_data.dart';
import 'package:t_max/data/pak_info_data.dart';
import 'package:t_max/data/plu_info_list_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';

import 'package:t_max/data/scalelist_data.dart';
import 'package:t_max/data/settingparam_data.dart';
import 'package:t_max/data/userinfo_data.dart';
import 'package:t_max/data/wifi_list_info.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/ipinfodata.dart';
import '../data/manager_scale_channel.dart';
import '../data/reqweightdata_data.dart';
import '../data/wifi_pwd_info.dart';
import '../eventbus/eventbus.dart';

late WebSocketChannel webchannel;

class WebSocketChannel {
  late String url;
  late IOWebSocketChannel channel;
  WebSocketChannel(this.url);
  bool heartStatus = false;
  // late Timer hearTimer;

  // 开始进行链接
  void connect() async {
    heartStatus = true;
    channel = IOWebSocketChannel.connect(url);
    channel.stream.listen(onData, onError: onError, onDone: onDone);

    // heartPacket();
  }

  // 发送消息
  void sendMessage(String s) {
    if (heartStatus) {
      channel.sink.add(s);
    }
  }

  // 断连，然后执行重连
  void onDone() {
    debugPrint("Socket0 onDone");
    Future.delayed(const Duration(seconds: 5), () {
      reconnectSocket();
    });
    // reconnectSocket();
    // debugPrint("Socket is closed");
    // channel = IOWebSocketChannel.connect(url);
    // heartStatus = true;
    // channel.stream.listen(this.onData, onError: onError, onDone: onDone);
    // (() async {});
  }

  /// 发送心跳包
  void sendHeartPacket() {
    Map<String, dynamic> data = {
      "code": 9999,
      "msg": "心跳包",
    };
    var jsonData = json.encode(data);
    sendMessage(jsonData);
  }

  // 错误日志
  void onError(err) {
    debugPrint(err.runtimeType.toString());
    WebSocketChannelException ex = err;
    debugPrint(ex.message);
    heartStatus = false;

    // eventBus.fire(EventServiceOff(""));
    // reconnectSocket();
  }

  // 接受数据，数据json字符串，然后转成Map
  void onData(event) {
    if (event != Null) {
      if (kDebugMode) {
        print('0收到消息:$event');
      }
      paster(event);
    }
  }

  void destoryHeart() {
    //为心跳包则直接
    if (heartStatus) {
      // hearTimer.cancel();
      heartStatus = false;
    }
  }

  /// 重新连接socket
  void reconnectSocket() {
    destoryHeart();
    connectService();

    // connect();
  }

  void dispose() {
    if (heartStatus) {
      // hearTimer.cancel();
    }
    channel.sink.close();
    heartStatus = false;
  }

  /// @desc WebSocket心跳包
  /// @author Marinda
  /// @date 2022/9/26
  void heartPacket() {
    if (heartStatus) {
      // hearTimer = Timer(const Duration(seconds: 100), () async {
      //   //  重新连接
      //   sendHeartPacket();
      //   // connect();
      // });
      // sendHeartPacket();
    }
  }

  Future<bool> checkServerExists() async {
    try {
      var channel = await Socket.connect('127.0.0.1', 7878);
      channel.close();
      return true;
    } catch (e) {
      // print("检查WebSocket服务器是否启动时出错: $e");

      return false;
    }
  }

  Future<void> connectService() async {
    bool res = await checkServerExists();
    if (!res) {
      eventBus.fire(EventServiceOff(''));
    } else {
      try {
        // 进行连接操作
        // connect();
        channel = IOWebSocketChannel.connect(url);
        channel.stream.listen(onData, onError: onError, onDone: onDone);
      } catch (e) {
        // 如果连接失败，继续延迟5秒后重连
        Future.delayed(const Duration(seconds: 5), () {
          reconnectSocket();
        });
      }
    }
  }

  void getComScaleList(ScaleDataInfo scaleInfo, CurrentPort mediaJson) {
    ComScaleInfo tempScaleInfo =
        ComScaleInfo(1, 1, true, "", 1, 1, 1, 1, "", "", false, "");
    tempScaleInfo.scaleModel = scaleInfo.scaleModel!;

    tempScaleInfo.isOnline = scaleInfo.isOnline!;
    tempScaleInfo.scaleId = scaleInfo.scaleId!;
    tempScaleInfo.tMedia = scaleInfo.tMedia!;
    tempScaleInfo.scaleSn = scaleInfo.scaleSn!;
    tempScaleInfo.isDefault = scaleInfo.isDefault!;
    tempScaleInfo.scaleName = scaleInfo.scaleName!;

    tempScaleInfo.portName = myCurrentPort.devPath!;
    tempScaleInfo.baudRate = myCurrentPort.baud!;
    tempScaleInfo.dataBits = myCurrentPort.dataBits!;
    tempScaleInfo.parity = myCurrentPort.parity!;
    tempScaleInfo.stopBits = myCurrentPort.stopBits!;
    // 查找是否存在相同 scaleId 的秤信息
    final existingIndex = myComScaleList
        .indexWhere((scale) => scale.scaleId == tempScaleInfo.scaleId);
    if (existingIndex != -1) {
      return;
    } else {}
    myComScaleList.add(tempScaleInfo);
    String url = GetUrl.getUrl(scaleInfo.scaleId!);

    manager.connect(scaleInfo.scaleId!, url);
    //TODO: 这个部分要去的，没有默认的秤
    if (myDefScaleInfo.defScaleId == scaleInfo.scaleId!) {
      DefScaleInfo.getDefScaleInfo(scaleInfo.scaleId!);
    }
  }

  void getNetScaleList(ScaleDataInfo scaleInfo, NetInfo netInfo) {
    NetScaleInfoLocal newNetScale = NetScaleInfoLocal();
    newNetScale.scaleModel = scaleInfo.scaleModel!;
    newNetScale.isOnline = scaleInfo.isOnline!;
    newNetScale.scaleId = scaleInfo.scaleId!;
    newNetScale.scaleSn = scaleInfo.scaleSn!;
    newNetScale.tMedia = scaleInfo.tMedia!;
    newNetScale.isDefault = scaleInfo.isDefault!;
    newNetScale.scaleCat = scaleInfo.scaleCat!;
    newNetScale.ip = netInfo.ip;
    newNetScale.port = netInfo.port;
    newNetScale.scaleName = scaleInfo.scaleName!;
    NetScaleListMgr.addScale(myNetScaleList, newNetScale);
    String url = GetUrl.getUrl(scaleInfo.scaleId!);
    manager.connect(scaleInfo.scaleId!, url);
    if (myDefScaleInfo.defScaleId == scaleInfo.scaleId!) {
      DefScaleInfo.getDefScaleInfo(scaleInfo.scaleId!);
    }
  }

  Future pasterScaleList(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    myScaleTotalInfo = ScaleTotalInfo.fromJson(jsonResponse);

    if (myScaleTotalInfo.scaleDataList!.isNotEmpty) {
      final tempScalesList = ScaleParser.parseScales(jsonStrings);

      for (int i = 0; i < tempScalesList.length; i++) {
        var tempScale = tempScalesList[i];
        // 查找 myAllScalesList 中是否存在相同 scaleId 的项
        final existingIndex = myAllScalesList
            .indexWhere((scale) => scale.scaleId == tempScale.scaleId);
        if (existingIndex == -1) {
          // 若不存在，则添加新项
          myAllScalesList.add(tempScale);
          String url = GetUrl.getUrl(tempScale.scaleId);
          manager.connect(tempScale.scaleId, url);
        } else {
          // 若存在，则更新相应项的属性
          var existingScale = myAllScalesList[existingIndex];
          tempScale.isOnline = existingScale.isOnline;
          tempScale.scaleModel = existingScale.scaleModel;
          tempScale.scaleSn = existingScale.scaleSn;
        }
      }
      myAllScalesList = List<Scale>.from(tempScalesList);

      for (var key in manager.connections.keys) {
        final existingIndex =
            myAllScalesList.indexWhere((scale) => scale.scaleId == key);
        if (existingIndex == -1) {
          // 若 myAllScalesList 中不存在该 scaleId，则关闭连接
          manager.dispose(key);
        }
      }

      // var lenth = myScaleTotalInfo.scaleDataList!.length;
      // for (var i = 0; i < lenth; i++) {
      //   var scaleInfo = myScaleTotalInfo.scaleDataList![i];
      //   var jsonMediaInfoData = scaleInfo.mediaInfo!.mediaInfoJson;
      //   if (jsonMediaInfoData == null) {
      //     continue;
      //   }
      //   if (scaleInfo.tMedia == 0) {
      //     await pasterComMediaInfo(jsonMediaInfoData.toString(), scaleInfo);
      //   } else if (scaleInfo.tMedia == 1) {
      //     await pasterNetMediaInfo(jsonMediaInfoData.toString(), scaleInfo);
      //   }
      // }
    } else {
      myAllScalesList.clear();
      for (var key in manager.connections.keys) {
        manager.dispose(key);
      }
    }
    eventBus.fire(EventRespAddScale('ok'));
  }

  Future pasterComMediaInfo(
      String jsonDataString, ScaleDataInfo scaleInfo) async {
    final jsonResponse = json.decode(jsonDataString);
    myCurrentPort = CurrentPort.fromJson(jsonResponse);

    getComScaleList(scaleInfo, myCurrentPort);
  }

  Future pasterNetMediaInfo(
      String jsonDataString, ScaleDataInfo scaleInfo) async {
    final jsonResponse = json.decode(jsonDataString);
    myNetInfo = NetInfo.fromJson(jsonResponse);
    getNetScaleList(scaleInfo, myNetInfo);
  }

  Future pasterWifiList(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    myWifiListInfo = WifiListInfo.fromJson(jsonResponse);

    if (myWifiListInfo.wifidatalist!.isNotEmpty) {
      eventBus.fire(EventWiFiListInfo(myWifiListInfo));
    }
  }

  Future pasterIpInfo(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    myIpInfoData = IpInfoData.fromJson(jsonResponse);
    eventBus.fire(EventIpInfoData(myIpInfoData));
  }

  Future<void> paster(dynamic data) async {
    var jsonData = json.decode(data);
    try {
      if (jsonData['MsgType'] == "resp_ports_list") {
        String dataString;
        dataString = jsonData['MsgBody'];
        List<String> dataList = <String>[];
        for (var value in const JsonDecoder().convert(dataString)) {
          dataList.add(value);
        }
        myComInfoList.msgBody = dataList;
        Map<String, dynamic> map = json.decode(json.encode(myComInfoList));
        dynamic mobj = ComInfoList.fromJson(map);
        eventBus.fire(EventComInfoList(mobj));
      } else if (jsonData['MsgType'] == "resp_scales_list") {
        pasterScaleList(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_scale_modify") {
        await pasterModifyAck(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == 'weight_data') {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ReqWeightCountine.fromJson(map);
        eventBus.fire(EventReqWeightCountine(mobj));
      } else if (jsonData['MsgType'] == "resp_product_list") {
        pasterProductList(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_user_list") {
        pasterUserList(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_get_license") {
        pasterLicense(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_check_license_key") {
        pasterLicenseKey(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_get_ap_list") {
        pasterWifiList(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_get_ip_info") {
        pasterIpInfo(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_update_license") {
        var dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespUpdateLic(dataString));
      } else if (jsonData['MsgType'] == "resp_scale_del") {
        var dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespDelScale(dataString));
      } else if (jsonData['MsgType'] == "resp_scale_add") {
        var dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespAddScale(dataString));
      } else if (jsonData['MsgType'] == "resp_detail_list") {
        var dataString = jsonData['MsgBody'];

        try {
          PakInfo pakInfo = pakInfoFromJson(dataString);
          if (pakInfo.pagId == 1) {
            myDetailPakList = [];
          }
          if (pakInfo.msgBody == "null") {
            return;
          }
          myDetailPakList.add(pakInfo);
          if (pakInfo.pakCount == myDetailPakList.length) {
            //先把包排序
            myDetailPakList.sort((a, b) => a.pagId.compareTo(b.pagId));
            for (int i = 0; i < myDetailPakList.length; i++) {
              myDetailRevPak.msgBody.write(myDetailPakList[i].msgBody);
            }
            eventBus.fire(EventRespDetailInfo(''));
            myDetailPakList = [];
          }
        } catch (e) {
          return;
        }
      } else if (jsonData['MsgType'] == "resp_new_detail") {
        var dataString = jsonData['MsgBody'];

        try {
          PakInfo pakInfo = pakInfoFromJson(dataString);
          if (pakInfo.pagId == 1) {
            myDetailPakList = [];
          }
          if (pakInfo.msgBody == "null") {
            return;
          }
          myDetailPakList.add(pakInfo);
          if (pakInfo.pakCount == myDetailPakList.length) {
            //先把包排序
            myDetailPakList.sort((a, b) => a.pagId.compareTo(b.pagId));
            for (int i = 0; i < myDetailPakList.length; i++) {
              myDetailRevPak.msgBody.write(myDetailPakList[i].msgBody);
            }
            eventBus.fire(EventRespNewDetailInfo(''));
            myDetailPakList = [];
          }
        } catch (e) {
          return;
        }
      } else if (jsonData['MsgType'] == "resp_detail_add") {
        var dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespDetailAdd(dataString));
      } else if (jsonData['MsgType'] == "resp_wifi_pwd_list") {
        String dataString = jsonData['MsgBody'];
        if (dataString.isNotEmpty) {
          myWifiPwdInfoList = wifiPwdInfoListFromJson(dataString);
        }
      } else if (jsonData['MsgType'] == "resp_scale_online") {
        String dataString = jsonData['MsgBody'];
        try {
          final jsonInfo = json.decode(dataString);
          ScaleIsOnline scaleOnline;
          scaleOnline = ScaleIsOnline.fromJson(jsonInfo);
          for (var scale in myAllScalesList) {
            if (scale.scaleId == scaleOnline.scaleId) {
              // 现在可以正常更新状态
              scale.isOnline = scaleOnline.isOnline!;
              eventBus.fire(EventRespScaleOnline(''));
              break;
            }
          }
          // NetScaleInfoLocal newScale;
          // newScale = NetScaleListMgr.findScaleInfo(
          //     myNetScaleList, scaleOnline.scaleId!);
          // if (newScale.isOnline != scaleOnline.isOnline) {
          //   newScale.isOnline = scaleOnline.isOnline;
          //   NetScaleListMgr.updateScale(myNetScaleList, newScale);
          //   eventBus.fire(EventRespScaleOnline(''));
          // }
        } catch (e) {
          return;
        }
      } else if (jsonData['MsgType'] == "resp_get_scale_srv_list") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespScaleSrvList(dataString));
      } else if (jsonData['MsgType'] == "resp_do_service_action") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespDoSrvAction(dataString));
      } else if (jsonData['MsgType'] == "resp_raw_type_list") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespGetRawTypeList(dataString));
      } else if (jsonData['MsgType'] == "resp_formula_type_list") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespGetFormulaTypeList(dataString));
      } else if (jsonData['MsgType'] == "resp_raw_list") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespGetRawDataList(dataString));
      } else if (jsonData['MsgType'] == "resp_raw_data_add" ||
          jsonData['MsgType'] == "resp_raw_data_delete" ||
          jsonData['MsgType'] == "resp_raw_data_edit") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespAddRawData(dataString));
      } else if (jsonData['MsgType'] == "resp_formula_type_add") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespAddFormulaType(dataString));
      } else if (jsonData['MsgType'] == "resp_formula_list") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespFormulaList(dataString));
      } else if (jsonData['MsgType'] == "resp_formula_add" ||
          jsonData['MsgType'] == "resp_formula_update" ||
          jsonData['MsgType'] == "resp_formula_delete") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespAddFormula(dataString));
      } else if (jsonData['MsgType'] == "resp_formula_rec_list") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespFormulaRecList(dataString));
      } else if (jsonData['MsgType'] == "resp_formula_rec_add") {
        eventBus.fire(EventRespFormulaRecAdd(''));
      } else if (jsonData['MsgType'] == "resp_raw_type_add") {
        eventBus.fire(EventRespRawTypeAdd(''));
      } else if (jsonData['MsgType'] == "resp_flow_rate_list") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespFlowRateList(dataString));
      } else if (jsonData['MsgType'] == "resp_flow_rate_add") {
        eventBus.fire(EventRespFlowRateAdd(''));
      } else if (jsonData['MsgType'] == "resp_get_all_wgt_rec_list") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespGetAllWgtRecs(dataString));
      } else if (jsonData['MsgType'] == "resp_get_ui_config") {
        String dataString = jsonData['MsgBody'];
        handleGetUIConf(dataString);
      } else if (jsonData['MsgType'] == "resp_update_ui_config") {
        eventBus.fire(EventUpdateSettingParam(''));
      } else if (jsonData['MsgType'] == "resp_del_wgt_rec") {
        eventBus.fire(EventDelAllWgtRecs(''));
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static void handleGetUIConf(String data) {
    var jsonData = json.decode(data);
    mySettingParam = SettingParam.fromJson(jsonData);
    if (mySettingParam.scaleMode == 0) {
      myModeSettingNormal = mySettingParam;
    } else if (mySettingParam.scaleMode == 1) {
      myModeSettingCheck = mySettingParam;
    } else if (mySettingParam.scaleMode == 2) {
      myModeSettingTakeIn = mySettingParam;
    } else if (mySettingParam.scaleMode == 3) {
      myModeSettingTakeOut = mySettingParam;
    }
    eventBus.fire(EventSettingParam(mySettingParam));
  }

  void pasterLicense(String jsonDataString) {
    eventBus.fire(EventLicenseData(jsonDataString));
  }

  void pasterLicenseKey(String jsonDataString) {
    eventBus.fire(EventCheckLicenseKey(jsonDataString));
  }

  // Future pasterProductList(String jsonDataString) async {
  //   String jsonStrings = jsonDataString;
  //   final jsonResponse = json.decode(jsonStrings);
  //   myProductRecList = ProductRecList.fromJson(jsonResponse);
  //   if (myProductRecList.productRecInfo!.isNotEmpty) {
  //     eventBus.fire(EventProductRecList(myProductRecList));
  //   } else {
  //     myProductRecList.productRecInfo?.clear();
  //     eventBus.fire(EventProductRecList(myProductRecList));
  //   }
  // }

  Future pasterProductList(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    // final jsonResponse = json.decode(jsonStrings);

    myPluListFormDb = pluInfoListFromJson(jsonStrings);
    if (myPluListFormDb.isNotEmpty) {
      eventBus.fire(EventProductRecList(myPluListFormDb));
    } else {
      myPluListFormDb.clear();
      eventBus.fire(EventProductRecList(myPluListFormDb));
    }
  }

  Future pasterUserList(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    myUserInfoList = UserInfoList.fromJson(jsonResponse);
    if (myUserInfoList.userInfo!.isNotEmpty) {
      eventBus.fire(EventUserInfoList(myUserInfoList));
    } else {
      myUserInfoList.userInfo?.clear();
      eventBus.fire(EventUserInfoList(myUserInfoList));
    }
  }

  Future pasterModifyAck(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    myModifyAck = ModifyAck.fromJson(jsonResponse);

    eventBus.fire(EventRespScaleModify(myModifyAck));
    //   if (myModifyAck.isAck == true) {
    //     getScaleList();
    //   }
    // }

    // void getScaleList() {
    //   myScaleCmd.cmdMode = "get_scale_list";
    //   myScaleCmd.cmdData = "";
    //   MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  // void getWeight() {
  //   myScaleCmd.cmdMode = "get_weight";
  //   myScaleCmd.cmdData = "";
  //   MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  // }
}
