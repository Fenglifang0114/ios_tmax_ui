import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/ipinfodata.dart';
import 'package:t_max/data/record_data.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/reqweightdata_data.dart';
import '../data/respdata_data.dart';
import '../data/wifi_ap_info.dart';
import '../data/wifi_list_info.dart';
import '../eventbus/eventbus.dart';

class WebSocketScaleChannel {
  late String url; //= 'ws://127.0.0.1:7878/tmax?scaleid=';
  late int scaleId;
  late IOWebSocketChannel channel = IOWebSocketChannel.connect(url);
  WebSocketScaleChannel(this.url);
  bool heartStatus = false;
  late List<int> totalChannel = [];

  // 开始进行链接
  void connect() async {
    heartStatus = true;
    channel = IOWebSocketChannel.connect(url);
    channel.stream.listen(onData, onError: onError, onDone: onDone);
  }

  // 发送消息
  void sendMessage(String s) {
    channel.sink.add(s);
  }

  // 断连，然后执行重连
  void onDone() {
    debugPrint("Socket1 onDone");
    reconnectSocket();
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
  }

  // 接受数据，数据json字符串，然后转成Map
  void onData(event) {
    if (event != null) {
      if (kDebugMode) {
        print('1 收到消息:' + event);
      }
      paster(event);
    }
  }

  /// 销毁心跳包
  void destoryHeart() {
    //为心跳包则直接
    if (heartStatus) {
      // hearTimer.cancel();
      heartStatus = false;
    }
  }

  /// 重新连接socket
  void reconnectSocket() {
    dispose();
    destoryHeart();
    connect();
  }

  void dispose() {
    // if (heartStatus) {
    //   // hearTimer.cancel();
    // }
    // channel.sink.close();
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

  Future<void> paster(dynamic data) async {
    try {
      var jsonData = json.decode(data);
      if (jsonData['MsgType'] == 'weight_data') {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ReqWeightCountine.fromJson(map);
        eventBus.fire(EventReqWeightCountine(mobj));
      } else if (jsonData['MsgType'] == 'resp_down_prn_fmt') {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventDownloadResponse(mobj));
      } else if (jsonData['MsgType'] == 'resp_err_serial') {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventSerialPortResponse(mobj));
      } else if (jsonData['MsgType'] == "resp_get_ap_list") {
        pasterWifiList(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_get_ip_info") {
        pasterIpInfo(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_modify_bt_name") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventConnectBTResponse(mobj));
      } else if (jsonData['MsgType'] == "resp_bt_passth_data") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventBTResponse(mobj));
      } else if (jsonData['MsgType'] == "resp_connect_ap") {
        pasterConnectApInfo(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_set_wifi_dynamic_ip") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventConnectDynamicIp(mobj));
      } else if (jsonData['MsgType'] == "resp_set_wifi_static_ip") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventConnectStaticIp(mobj));
      } else if (jsonData['MsgType'] == "resp_get_ip_mode") {
        pasterGetIpMode(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_get_wifi_ap_info") {
        pasterWifiApInfo(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_update_firmware") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventRespUpdateFirmware(mobj));
      } else if (jsonData['MsgType'] == "resp_update_firmware_progress") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventRespUpdateFirmwareProcess(mobj));
      } else if (jsonData['MsgType'] == "resp_check_serial_port") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventRespCheckSerialPort(mobj));
      } else if (jsonData['MsgType'] == "resp_get_build_info") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventGetBuildInfo(mobj));
      } else if (jsonData['MsgType'] == "resp_set_output_fmt") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventSerialOutputResp(mobj));
      } else if (jsonData['MsgType'] == "scale_passth_data") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventScalePassthData(mobj));
      } else if (jsonData['MsgType'] == "resp_get_recs") {
        pasterGetRecords(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_open_scale_passthrough") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventOpenScalePassthResp(mobj));
      } else if (jsonData['MsgType'] == "resp_close_scale_passthrough") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventCloseScalePassthResp(mobj));
      } else if (jsonData['MsgType'] == "resp_reg_weight") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventRegWeightResp(mobj));
      } else if (jsonData['MsgType'] == "resp_unreg_weight") {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ChannelResponse.fromJson(map);
        eventBus.fire(EventUnregWeightResp(mobj));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future pasterWifiList(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    if (jsonStrings.contains('error') ||
        jsonStrings.contains('fail') ||
        jsonStrings.contains('done')) {
      myGetWifiListError.messagedata = jsonStrings;
      eventBus.fire(EventGetWifiListError(myGetWifiListError));
      return;
    }
    final jsonResponse = json.decode(jsonStrings);
    myWifiListInfo = WifiListInfo.fromJson(jsonResponse);
    eventBus.fire(EventWiFiListInfo(myWifiListInfo));
  }

  Future pasterIpInfo(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    if (jsonStrings.contains('error') || jsonStrings.contains('fail')) {
      myGetIpError.messagedata = jsonStrings;
      eventBus.fire(EventGetIpError(myGetIpError));
      return;
    }
    final jsonResponse = json.decode(jsonStrings);
    myIpInfoData = IpInfoData.fromJson(jsonResponse);
    eventBus.fire(EventIpInfo(myIpInfoData));
  }

// TODO:
  Future pasterWifiApInfo(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    if (jsonStrings.contains('error') || jsonStrings.contains('fail')) {
      myMessageError.messagedata = jsonStrings;
      eventBus.fire(EventMessageError(myMessageError));
      return;
    }
    final jsonResponse = json.decode(jsonStrings);
    myWiFiAPInfo = WiFiAPInfo.fromJson(jsonResponse);
    eventBus.fire(EventGetWifiApInfo(myWiFiAPInfo));
  }
}

Future pasterConnectApInfo(String jsonDataString) async {
  String jsonStrings = jsonDataString;
  myConnectApResponse.msgBody = jsonStrings;
  eventBus.fire(EventConnectAp(myConnectApResponse));
}

Future pasterGetIpMode(String jsonDataString) async {
  String jsonStrings = jsonDataString;
  myRespGetIpMode.messagedata = jsonStrings;
  eventBus.fire(EventRespGetIpMode(myRespGetIpMode));
}

Future pasterGetRecords(String jsonDataString) async {
  if (jsonDataString.isNotEmpty) {
    myGetScaleRecords = GetScaleRecords.fromJson(json.decode(jsonDataString));
  } else {
    if (myGetScaleRecords.weightRecords != null) {
      myGetScaleRecords.weightRecords!.clear();
    }
  }
  await Future.delayed(Duration.zero);
  eventBus.fire(EventGetScaleRecords(myGetScaleRecords));
}
