import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/modifyresult_data.dart';
import 'package:t_max/data/productlist_data.dart';

import 'package:t_max/data/scalelist_data.dart';
import 'package:t_max/data/userinfo_data.dart';
import 'package:t_max/data/wifi_list_info.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/ipinfodata.dart';
import '../data/reqweightdata_data.dart';
import '../eventbus/eventbus.dart';

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
    channel.sink.add(s);
  }

  // 断连，然后执行重连
  void onDone() {
    debugPrint("Socket0 onDone");
    reconnectSocket();
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
  }

  // 接受数据，数据json字符串，然后转成Map
  void onData(event) {
    if (event != Null) {
      if (kDebugMode) {
        print('0收到消息:' + event);
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
    connect();
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

  void getComScaleList(int indexInt) {
    myComScaleInfoList.scaleModel =
        myScaleTotalInfo.scaleDataList![indexInt].scaleModel!;
    myComScaleInfoList.isOnline =
        myScaleTotalInfo.scaleDataList![indexInt].isOnline!;
    myComScaleInfoList.scaleId =
        myScaleTotalInfo.scaleDataList![indexInt].scaleId!;
    myComScaleInfoList.tMedia =
        myScaleTotalInfo.scaleDataList![indexInt].tMedia!;
    myComScaleInfoList.portName = myMediaInfoJson.devPath!;
    myComScaleInfoList.baudRate = myMediaInfoJson.baud!;
    myComScaleInfoList.dataBits = myMediaInfoJson.dataBits!;
    myComScaleInfoList.parity = myMediaInfoJson.parity!;
    myComScaleInfoList.stopBits = myMediaInfoJson.stopBits!;
    myComScaleInfoList.scaleSn =
        myScaleTotalInfo.scaleDataList![indexInt].scaleSn!;
    myComScaleList.comScaleList.add(myComScaleInfoList);
  }

  Future pasterScaleList(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    myScaleTotalInfo = ScaleTotalInfo.fromJson(jsonResponse);

    if (myScaleTotalInfo.scaleDataList!.isNotEmpty) {
      var lenth = myScaleTotalInfo.scaleDataList!.length;
      for (var i = 0; i < lenth; i++) {
        var jsonMediaInfoData =
            myScaleTotalInfo.scaleDataList![i].mediaInfo!.mediaInfoJson;
        if (jsonMediaInfoData!.isNotEmpty) {
          await pasterMediaInfo(jsonMediaInfoData.toString(), i);
        }
      }
    }
  }

  Future pasterMediaInfo(String jsonDataString, int indexInt) async {
    String jsonStrings = jsonDataString;
    myComScaleList.comScaleList.clear();
    final jsonResponse = json.decode(jsonStrings);
    myMediaInfoJson = MediaInfoJson.fromJson(jsonResponse);
    getComScaleList(indexInt);
    eventBus.fire(EventComScaleList(myComScaleList));
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
        if (myComScaleList.comScaleList.isNotEmpty) {
          eventBus.fire(EventComScaleList(myComScaleList));
        }
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
      } else if (jsonData['MsgType'] == "resp_check_license") {
        pasterLicense(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_check_license_key") {
        pasterLicenseKey(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_get_ap_list") {
        pasterWifiList(jsonData['MsgBody']);
      } else if (jsonData['MsgType'] == "resp_get_ip_info") {
        pasterIpInfo(jsonData['MsgBody']);
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void pasterLicense(String jsonDataString) {
    myLicenseData.data = jsonDataString;
    eventBus.fire(EventLicenseData(myLicenseData));
  }

  void pasterLicenseKey(String jsonDataString) {
    myLicenseData.data = jsonDataString;
    eventBus.fire(EventCheckLicenseKey(myLicenseData));
  }

  Future pasterProductList(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    myProductRecList = ProductRecList.fromJson(jsonResponse);
    if (myProductRecList.productRecInfo!.isNotEmpty) {
      eventBus.fire(EventProductRecList(myProductRecList));
    } else {
      myProductRecList.productRecInfo?.clear();
      eventBus.fire(EventProductRecList(myProductRecList));
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













// import 'dart:async';

// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// enum StatusEnum{
//   connect,connecting,close,closing
// }
// class WebsocketManager{
//   static WebsocketManager _singleton;

//   WebSocketChannel channel;
//   factory WebsocketManager() {
//     return _singleton;
//   }
//    StreamController<StatusEnum> socketStatusController = StreamController<StatusEnum>();
//   WebsocketManager._();
//   static void init() async {
//     if (_singleton == null) {
//       _singleton = WebsocketManager._();
//     }
//   }
//   StatusEnum isConnect=StatusEnum.close ;  //默认为未连接
//   String _url="ws://echo.websocket.org";


//   Future connect() async{
//     if(isConnect==StatusEnum.close){
//       isConnect=StatusEnum.connecting;
//       socketStatusController.add(StatusEnum.connecting);
//       channel=await IOWebSocketChannel.connect(Uri.parse(_url));
//       isConnect=StatusEnum.connect;
//       socketStatusController.add(StatusEnum.connect);
//        return true;
//     }

//   }

//   Future disconnect() async{
//     if(isConnect==StatusEnum.connect){
//       isConnect=StatusEnum.closing;
//       socketStatusController.add(StatusEnum.closing);
//       await channel.sink.close(3000,"主动关闭");
//       isConnect=StatusEnum.close;
//       socketStatusController.add(StatusEnum.close);

//     }

//   }

//   bool send(String text){
//     if(isConnect==StatusEnum.connect) {
//       channel.sink.add(text);
//       return true;
//     }
//     return false;
//   }

//   void printStatus(){
//     if(isConnect==StatusEnum.connect){
//       print("websocket 已连接");
//     }else if(isConnect==StatusEnum.connecting){
//       print("websocket 连接中");
//     }else if(isConnect==StatusEnum.close){
//       print("websocket 已关闭");
//     }else if(isConnect==StatusEnum.closing){
//       print("websocket 关闭中");
//     }
//   }

//   void dispose(){
//     socketStatusController.close();
//     socketStatusController=null;
//   }

// }























// import 'dart:async';
// import 'package:dio/dio.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'State.dart';
// import 'dart:convert';

// import 'Result.dart';
// /**
//  * @date 2022/9/26
//  * @author Marinda
//  * @desc websocket的实现
//  */
// class WebSocketHandle {
//   static WebSocketState state = WebSocketState();
//   static late Timer hearTimer;
//   WebSocketHandle();

//    static void connectSocket() async {
//        await closeSocket();
//        String socketUrl = state.socketUrl;
//        LoggerUtil.logger.i("发起WebSocket请求，地址为：${socketUrl}");
//        state.webSocket = IOWebSocketChannel.connect(socketUrl);

//        state.socketStatus = true;
//        initConnectSocket();
//   }

//   static void initConnectSocket(){
//     WebSocketHandle.onMessageListener();
//     heartPacket();
//   }

//   /**
//    * @desc 校验连接配置是否重复
//    * @author Marinda
//    * @date 2022/9/27
//    */
//   static bool validConnection(String ip,int port){
//      return state.ip == ip && state.port == port ? true : false;
//   }
//   /**
//    * @desc WebSocket消息监听器
//    * @author Marinda
//    * @date 2022/9/26
//    */
//   static void onMessageListener(){

//      WebSocketResult webSocketResult = WebSocketResult();
//      state.webSocket?.stream.listen((data){
//       var jsonData = json.decode(data);
//       if(jsonData is Map<String,dynamic>){
//         //检测到心跳包
//         if(jsonData['code'] == 9999){
//         //  不处理
//         }else{
//           Map<String,dynamic> mapData = jsonData['data'];
//           webSocketResult = WebSocketResult.fromJson(mapData);
//             state.webSocketResult = webSocketResult;
//             LoggerUtil.logger.i("监听到服务端Socket返回数据：                   ${state.webSocketResult.toString()}");   
// },onError: (e){
//       state.socketStatus = false;
//       state.isError = true;
//     },onDone: (){
//       state.socketStatus = false;
//     });
//   }

//   /**
//    * 销毁心跳包
//    */
//   static void destoryHeart(){
//      //为心跳包则直接
//      if(state.heartStatus){
//         hearTimer?.cancel();
//         state.heartStatus = false;
//      }
//   }

//   /**
//    * 发送心跳包
//    */
//   static void sendHeartPacket(){
//     Map<String,dynamic> data = {
//       "code": 9999,
//       "msg": "心跳包",
//     };
//     var jsonData = json.encode(data);
//     state.webSocket?.sink.add(jsonData);
//     state.heartStatus = true;
//   }

//   /**
//    * @desc WebSocket心跳包
//    * @author Marinda
//    * @date 2022/9/26
//    */
//   static void heartPacket(){
//      if(state.socketStatus){
//        hearTimer = Timer(Duration(seconds: state.socketClienTime),() async{
//        //  重新连接
//          reconnectSocket();
//        });
//        sendHeartPacket();
//      }
//   }

//   /**
//    * 重新连接socket
//    */
//   static void reconnectSocket(){
//      destoryHeart();
//      connectSocket();
//   }

//   /**
//    * @desc 关闭WebSocket
//    * @author Marinda
//    * @date 2022/9/26
//    */
//   static Future closeSocket() async{
//      if(state.webSocket != null){
//        state.webSocket?.sink.close();
//        state.webSocket = null;
//        state.socketStatus = false;
//      }
//   }

// }
