import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/data/comscaleinfo_data.dart';

import 'package:t_max/data/modifyresult_data.dart';
import 'package:t_max/data/pak_info_data.dart';
import 'package:t_max/data/plu_info_list_data.dart';

import 'package:t_max/data/scalelist_data.dart';
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
    myComScaleInfo.scaleModel = scaleInfo.scaleModel!;

    myComScaleInfo.isOnline = scaleInfo.isOnline!;
    myComScaleInfo.scaleId = scaleInfo.scaleId!;
    myComScaleInfo.tMedia = scaleInfo.tMedia!;
    myComScaleInfo.scaleSn = scaleInfo.scaleSn!;
    myComScaleInfo.isDefault = scaleInfo.isDefault!;
    myComScaleInfo.scaleName = scaleInfo.scaleName!;

    myComScaleInfo.portName = myCurrentPort.devPath!;
    myComScaleInfo.baudRate = myCurrentPort.baud!;
    myComScaleInfo.dataBits = myCurrentPort.dataBits!;
    myComScaleInfo.parity = myCurrentPort.parity!;
    myComScaleInfo.stopBits = myCurrentPort.stopBits!;
    String url = GetUrl.getUrl(scaleInfo.scaleId!);
    manager.connect(scaleInfo.scaleId!, url);
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
      var lenth = myScaleTotalInfo.scaleDataList!.length;
      for (var i = 0; i < lenth; i++) {
        var scaleInfo = myScaleTotalInfo.scaleDataList![i];
        var jsonMediaInfoData = scaleInfo.mediaInfo!.mediaInfoJson;
        if (jsonMediaInfoData == null) {
          continue;
        }
        if (scaleInfo.tMedia == 0) {
          await pasterComMediaInfo(jsonMediaInfoData.toString(), scaleInfo);
        } else if (scaleInfo.tMedia == 1) {
          await pasterNetMediaInfo(jsonMediaInfoData.toString(), scaleInfo);
        }
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
          NetScaleInfoLocal newScale;
          newScale = NetScaleListMgr.findScaleInfo(
              myNetScaleList, scaleOnline.scaleId!);
          if (newScale.isOnline != scaleOnline.isOnline) {
            newScale.isOnline = scaleOnline.isOnline;
            NetScaleListMgr.updateScale(myNetScaleList, newScale);
            eventBus.fire(EventRespScaleOnline(''));
          }
        } catch (e) {
          return;
        }
      } else if (jsonData['MsgType'] == "resp_get_scale_srv_list") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespScaleSrvList(dataString));
      } else if (jsonData['MsgType'] == "resp_do_service_action") {
        String dataString = jsonData['MsgBody'];
        eventBus.fire(EventRespDoSrvAction(dataString));
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
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
