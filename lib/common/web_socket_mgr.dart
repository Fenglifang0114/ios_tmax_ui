import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/resp_type_data.dart';

class WebSocketScaleManager {
  final Map<int, IOWebSocketChannel> _connections = {};

  // 开始进行特定 scaleId 的链接
  Future<void> connect(int scaleId, String url) async {
    if (!_connections.containsKey(scaleId)) {
      _connections[scaleId] = IOWebSocketChannel.connect(url);
      _connections[scaleId]!.stream.listen(
            (event) => onData(scaleId, event),
            onError: (err) => onError(scaleId, err),
            onDone: () => onDone(scaleId),
          );
    }
  }

  // 发送消息到特定 scaleId 的连接
  void sendMessage(int scaleId, String s) {
    if (_connections.containsKey(scaleId)) {
      _connections[scaleId]!.sink.add(s);
    }
  }

  // 特定 scaleId 的连接完成处理
  void onDone(int scaleId) {
    debugPrint("Socket for scaleId $scaleId on Done");
    reconnectSocket(scaleId);
  }

  /// 发送心跳包到特定 scaleId 的连接
  void sendHeartPacket(int scaleId) {
    if (_connections.containsKey(scaleId)) {
      Map<String, dynamic> data = {
        "code": 9999,
        "msg": "心跳包",
      };
      var jsonData = json.encode(data);
      sendMessage(scaleId, jsonData);
    }
  }

  // 错误日志
  void onError(int scaleId, err) {
    debugPrint(err.runtimeType.toString());
    WebSocketChannelException ex = err;
    debugPrint(ex.message);
  }

  // 接受数据，数据 json字符串，然后转成 Map
  void onData(int scaleId, event) {
    if (event != null) {
      if (kDebugMode) {
        print('$scaleId 收到消息:' + event);
      }
      paster(scaleId, event);
    }
  }

  /// 销毁特定 scaleId 的心跳包
  void destoryHeart(int scaleId) {
    // 为心跳包则直接
    // if (_connections.containsKey(scaleId) && _connections[scaleId]!.sink.isNull) {
    //   hearTimer.cancel();
    // }
  }

  /// 重新连接特定 scaleId 的 socket
  void reconnectSocket(int scaleId) {
    dispose(scaleId);
    destoryHeart(scaleId);
    if (_connections.containsKey(scaleId)) {
      connect(scaleId, _connections[scaleId]!.sink.toString());
    }
  }

  void dispose(int scaleId) {
    if (_connections.containsKey(scaleId)) {
      _connections[scaleId]!.sink.close();
    }
  }

  void delete(int scaleId) {
    if (_connections.containsKey(scaleId)) {
      _connections[scaleId]!.sink.close();
      _connections.remove(scaleId);
    }
  }

  Future<void> paster(int scaleId, dynamic data) async {
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
