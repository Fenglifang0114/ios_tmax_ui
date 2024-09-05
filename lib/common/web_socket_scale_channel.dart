import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/resp_type_data.dart';

class WebSocketScaleChannel {
  late String url; //= 'ws://127.0.0.1:7878/tmax?scaleid=';
  late int scaleId = 1;
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
        print('$scaleId 收到消息:' + event);
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
    if (data != null) {
      try {
        Map<String, dynamic> map = json.decode(data);
        if (RespMsgType.handlers.containsKey(map['MsgType'])) {
          var _handler = RespMsgType.handlers[map['MsgType']];
          await _handler!(map);
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }
}
