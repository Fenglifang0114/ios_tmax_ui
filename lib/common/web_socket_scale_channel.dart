import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/ipinfodata.dart';
import 'package:t_max/data/record_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/reqweightdata_data.dart';
import '../data/resp_type_data.dart';
import '../data/respdata_data.dart';
import '../data/settingparam_data.dart';
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

  void pasterSettingParam(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    mySettingParam = SettingParam.fromJson(jsonResponse);
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

  Future<void> paster(dynamic data) async {
    if (data != null) {
      try {
        var jsonData = json.decode(data);
        Map<String, dynamic> map = jsonData;
        dynamic mobj;
        switch (jsonData['MsgType']) {
          case RespMsgType.respGetUIConf:
            pasterSettingParam(jsonData['MsgBody']);
            break;
          case RespMsgType.weightData:
            mobj = ReqWeightCountine.fromJson(map);
            eventBus.fire(EventReqWeightCountine(mobj));
            break;
          case RespMsgType.respDownPrnFmt:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventDownPrnFmtResp(mobj));
            break;
          case RespMsgType.respErrSerial:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventSerialPortResponse(mobj));
            break;
          case RespMsgType.respGetApList:
            pasterWifiList(jsonData['MsgBody']);
            break;
          case RespMsgType.respGetIpInfo:
            pasterIpInfo(jsonData['MsgBody']);
            break;
          case RespMsgType.respModifyBTName:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventConnectBTResponse(mobj));
            break;
          case RespMsgType.respBTPassthData:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventBTResponse(mobj));
            break;
          case RespMsgType.respConnectAp:
            pasterConnectApInfo(jsonData['MsgBody']);
            break;
          case RespMsgType.respSetWifiDynamicIp:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventConnectDynamicIp(mobj));
            break;
          case RespMsgType.respSetWifiStaticIp:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventConnectStaticIp(mobj));
            break;
          case RespMsgType.respGetIpMode:
            pasterGetIpMode(jsonData['MsgBody']);
            break;
          case RespMsgType.respGetWifiApInfo:
            pasterWifiApInfo(jsonData['MsgBody']);
            break;
          case RespMsgType.respUpdateFirmware:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventRespUpdateFirmware(mobj));
            break;
          case RespMsgType.respUpdateFirmwareProgress:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventRespUpdateFirmwareProcess(mobj));
            break;
          case RespMsgType.respCheckSerialPort:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventRespCheckSerialPort(mobj));
            break;
          case RespMsgType.respGetBuildInfo:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventGetBuildInfo(mobj));
            break;
          case RespMsgType.respSetOutputFmt:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventSerialOutputResp(mobj));
            break;
          case RespMsgType.scalePassthData:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventScalePassthData(mobj));
            break;
          case RespMsgType.respGetRecs:
            pasterGetRecords(jsonData['MsgBody']);
            break;
          case RespMsgType.respOpenScalePassthrough:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventOpenScalePassthResp(mobj));
            break;
          case RespMsgType.respCloseScalePassthrough:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventCloseScalePassthResp(mobj));
            break;
          case RespMsgType.respRegWeight:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventRegWeightResp(mobj));
            break;
          case RespMsgType.respUnregWeight:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventUnregWeightResp(mobj));
            break;
          case RespMsgType.respGetScaleInfo:
            if (!jsonData['MsgBody'].contains('fail')) {
              mobj =
                  ScaleInfoFromScale.fromJson(json.decode(jsonData['MsgBody']));
            } else {
              mobj = ScaleInfoFromScale();
            }
            eventBus.fire(EventGetScaleInfo(mobj));
            break;
          case RespMsgType.respDelRec:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventDeleteRec(mobj));
            break;
          case RespMsgType.respDownPlu:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventRespDownPlu(mobj));
            break;
          case RespMsgType.respUpdateUIConf:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventUpdateSettingParam(mobj));
            break;
          case RespMsgType.respChangeWifiMode:
            mobj = ChannelResponse.fromJson(map);
            eventBus.fire(EventRespChangeWiFiMode(mobj));
            break;
          default:
            break;
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
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
  if (jsonDataString == '[]') {
    if (myGetScaleRecords.weightRecords != null) {
      myGetScaleRecords.weightRecords!.clear();
    }
  } else if (jsonDataString.isNotEmpty) {
    myGetScaleRecords = GetScaleRecords.fromJson(json.decode(jsonDataString));
  } else {
    if (myGetScaleRecords.weightRecords != null) {
      myGetScaleRecords.weightRecords!.clear();
    }
  }
  await Future.delayed(Duration.zero);
  eventBus.fire(EventGetScaleRecords(myGetScaleRecords));
}
