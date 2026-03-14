import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:t_max/data/manager_scale_channel.dart';
import 'package:t_max/data/resp_sys_data.dart';
import 'package:t_max/data/writelog.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;
  WebSocketManager._internal();

  static final String _url = 'ws://127.0.0.1:$webPort/tmax?scaleid=0';
  IOWebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectInterval = Duration(seconds: 5);
  final Duration _heartbeatInterval = Duration(seconds: 30);

  // 连接状态流控制器
  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  // 获取当前连接状态
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  // 单例连接方法
  Future<void> connect() async {
    if (_isConnecting || _isConnected) {
      writelog('connect is connecting or connected, skip reconnect.');
      debugPrint('连接已存在或正在连接中，跳过重复连接');
      return;
    }

    _isConnecting = true;
    _connectionController.add(false);

    try {
      // 先检查服务器是否可用
      bool serverExists = await _checkServerExists();
      if (!serverExists) {
        writelog('server not exists, trigger service off event.');
        debugPrint('服务器不可用，触发服务离线事件');
        eventBus.fire(EventServiceOff(''));
        _scheduleReconnect();
        return;
      }

      writelog('start connecting to server...');
      debugPrint('开始建立WebSocket连接...');

      // 关闭现有连接（如果有）
      await disconnect();

      // 建立新连接
      _channel = IOWebSocketChannel.connect(_url);

      // 监听连接
      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // 等待连接建立
      await Future.delayed(Duration(milliseconds: 500));

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;

      _connectionController.add(true);
      writelog('connect to server success.');
      debugPrint('WebSocket连接建立成功');

      // 启动心跳检测
      _startHeartbeat();

      // 连接成功后获取必要数据
      _onConnected();
    } catch (e) {
      writelog('connect to server failed: $e');
      debugPrint('连接建立失败: $e');
      _isConnecting = false;
      _connectionController.add(false);
      _scheduleReconnect();
    }
  }

  // 断开连接
  Future<void> disconnect() async {
    _stopHeartbeat();
    _stopReconnectTimer();

    _isConnected = false;
    _isConnecting = false;

    try {
      await _channel?.sink.close();
      _channel = null;
      writelog('disconnect to server success.');
      debugPrint('WebSocket连接已断开');
    } catch (e) {
      writelog('disconnect to server failed: $e');
      debugPrint('断开连接时出错: $e');
    }

    _connectionController.add(false);
  }

  // 发送消息
  void sendMessage(String message) {
    if (!_isConnected || _channel == null) {
      writelog('connect not connected, can not send message: $message');
      debugPrint('连接未就绪，无法发送消息: $message');
      return;
    }

    try {
      _channel!.sink.add(message);
    } catch (e) {
      writelog('send message failed: $e');
      debugPrint('消息发送失败: $e');
      _onError(e);
    }
  }

  // 检查服务器是否可用
  Future<bool> _checkServerExists() async {
    try {
      final socket = await Socket.connect('127.0.0.1', webPort,
          timeout: Duration(seconds: 5));
      await socket.close();
      return true;
    } catch (e) {
      writelog('check server exists failed: $e');
      debugPrint('服务器检查失败: $e');
      return false;
    }
  }

  // 数据接收处理
  void _onData(dynamic data) {
    if (data != null) {
      if (kDebugMode) {
        print('0 收到消息:$data');
      }
      try {
        Map<String, dynamic> map = json.decode(data);

        // 处理心跳响应
        if (map['code'] == 9999) {
          // debugPrint('收到心跳响应');
          return;
        }

        // 处理业务消息
        if (RespSysMsgType.handlers.containsKey(map['MsgType'])) {
          var handler = RespSysMsgType.handlers[map['MsgType']];
          handler!(map);
        }
      } catch (e) {
        writelog('handle message failed: $e');
        debugPrint('消息处理错误: $e');
      }
    }
  }

  // 错误处理
  void _onError(error) {
    writelog('websocket error: $error');
    debugPrint('websocket 错误: $error');
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  // 连接关闭处理
  void _onDone() {
    writelog('WebSocket connection closed.');
    debugPrint('WebSocket连接关闭');
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  // 连接成功后的初始化
  void _onConnected() {
    // 获取必要数据
    PublicFunctions.getLicense();
    PublicFunctions.getScaleList();
    PublicFunctions.getAllSysUsers();

    // 发送初始心跳
    _sendHeartbeat();
  }

  // 启动心跳检测
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        _sendHeartbeat();
      }
    });
  }

  // 停止心跳检测
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // 发送心跳包
  void _sendHeartbeat() {
    if (!_isConnected) return;

    try {
      Map<String, dynamic> heartbeat = {
        "code": 9999,
        "msg": "heartbeat",
        "timestamp": DateTime.now().millisecondsSinceEpoch
      };
      sendMessage(json.encode(heartbeat));
    } catch (e) {
      writelog('send heartbeat failed: $e');
      debugPrint('send heartbeat failed: $e');
    }
  }

  // 安排重连
  void _scheduleReconnect() {
    if (_reconnectTimer != null ||
        _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _reconnectAttempts++;
    writelog(
        'schedule reconnect, try times: $_reconnectAttempts/$_maxReconnectAttempts');
    debugPrint('安排重连，尝试次数: $_reconnectAttempts/$_maxReconnectAttempts');

    _reconnectTimer = Timer(_reconnectInterval, () {
      _reconnectTimer = null;
      if (!_isConnected && !_isConnecting) {
        connect();
      }
    });
  }

  // 停止重连计时器
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  // 手动重连
  Future<void> reconnect() async {
    _reconnectAttempts = 0;
    await disconnect();
    await connect();
  }

  // 清理资源
  void dispose() {
    _stopHeartbeat();
    _stopReconnectTimer();
    disconnect();
    _connectionController.close();
  }
}
