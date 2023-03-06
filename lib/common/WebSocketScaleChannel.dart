import 'dart:async';
import 'dart:convert';

import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:provider/provider.dart';
import 'package:t_max/data/cominfo_data.dart';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/modifyresult_data.dart';
import 'package:t_max/data/record_data.dart';

import 'package:t_max/data/scalelist_data.dart';
import 'package:t_max/pages/dialog/modifyComPort_dialog.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/comInfo_data.dart';
import '../data/reqweightdata_data.dart';
import '../data/sigalscale_data.dart';
import '../eventbus/eventbus.dart';

class WebSocketScaleChannel {
  late String url; //= 'ws://127.0.0.1:7878/tmax?scaleid=';
  late int scaleId;
  late IOWebSocketChannel channel;
  WebSocketScaleChannel(this.url);
  bool heartStatus = false;
  // late Timer hearTimer;
  late List<int> totalChannel = [];

  void channelAdd() {
    if (!totalChannel.contains(scaleId)) {
      connect();
      totalChannel.add(scaleId);
    }
  }

  // 开始进行链接
  void connect() async {
    // url = url + scaleId.toString();
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
    debugPrint("Socket1 onDone");
    // reconnectSocket();
    heartStatus = false;
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
    if (event != null) {
      print('1收到消息:' + event);
      paster(event);
    }
  }

  // } else if (jsonData['MgrMsgType'] == "scales_list") {
  //   if (jsonData['MsgBody'] != "") {
  //     Map<String, dynamic> map = json.decode(data);
  //     dynamic mobj = ScaleList.fromJson(map);
  //     eventBus.fire(EventScaleList(mobj));
  //     // if (jsonData['MsgBody'].tolist().lenth > 0 && count == 0) {
  //     //   WebSocketChannel webchannel9999 =
  //     //       WebSocketChannel('ws://10.5.52.202:8443/v9999');
  //     //   webchannel9999.connect();

  //     //   mobj.toString().length;
  //     // }
  //     print(map.values);
  //   }
  // }

/**
   * 销毁心跳包
   */
  void destoryHeart() {
    //为心跳包则直接
    if (heartStatus) {
      // hearTimer.cancel();
      heartStatus = false;
    }
  }

  /// 重新连接socket
  void reconnectSocket() {
    // dispose();
    // destoryHeart();
    // connect();
  }

  void dispose() {
    if (heartStatus) {
      // hearTimer.cancel();
    }
    channel.sink.close();
    heartStatus = false;
  }

  /**
   * @desc WebSocket心跳包
   * @author Marinda
   * @date 2022/9/26
   */
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

  // Future pasterRecsList(String jsonDataString) async {
  //   String jsonStrings = jsonDataString;
  //   final jsonResponse = json.decode(jsonStrings);
  //   myGetScaleRecords = GetScaleRecords.fromJson(jsonResponse);
  //   eventBus.fire(EventGetScaleRecords(myGetScaleRecords));
  // }

  Future<void> paster(dynamic data) async {
    try {
      var jsonData = json.decode(data);
      if (jsonData['MsgType'] == 0) {
        Map<String, dynamic> map = json.decode(data);
        dynamic mobj = ReqWeightCountine.fromJson(map);
        eventBus.fire(EventReqWeightCountine(mobj));
      }
      // else if (jsonData['MsgType'] == 6) {
      //   Map<String, dynamic> map = json.decode(data);
      //   dynamic mobj = RevScaleData.fromJson(map);
      //   myRevScaleData = mobj;
      //   if (myRevScaleData.msgBody.isNotEmpty) {
      //     pasterRecsList(myRevScaleData.msgBody);
      //   }
      // }
    } catch (e) {
      print(e);
    }
  }
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
  // static void heartPacket(){
  //    if(state.socketStatus){
  //      hearTimer = Timer(Duration(seconds: state.socketClienTime),() async{
  //      //  重新连接
  //        reconnectSocket();
  //      });
  //      sendHeartPacket();
  //    }
  // }

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
