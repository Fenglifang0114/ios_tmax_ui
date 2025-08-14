import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:t_max/data/resp_sys_data.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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

  Future<void> paster(dynamic data) async {
    if (data != null) {
      try {
        Map<String, dynamic> map = json.decode(data);
        if (RespSysMsgType.handlers.containsKey(map['MsgType'])) {
          var handler = RespSysMsgType.handlers[map['MsgType']];
          await handler!(map);
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }
}
