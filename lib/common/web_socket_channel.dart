import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:t_max/data/manager_scale_channel.dart';
import 'package:t_max/data/resp_sys_data.dart';
import 'package:t_max/data/resp_type_data.dart';
import 'package:t_max/data/writelog.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:web_socket_channel/io.dart';

enum ServiceState {
  disconnected,
  connecting,
  connected,
  retrying
}

/// 全局的 [WebSocket] 通信管理器。
/// 采用单例模式 (Singleton) 维持与后端网关的长连接，统一分发 JSON 消息到底层网关的监听器，
/// 并且内置了断线重拨机制 (Reconnect) 与心跳监控 (Heartbeat)。
class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;
  WebSocketManager._internal();

  String get _url => 'ws://$ipAddress:$webPort/tmax?scaleid=0';
  IOWebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _hasEverConnected = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 10;
  final Duration _heartbeatInterval = const Duration(seconds: 30);
  int _nextRetrySeconds = 0;
  int get nextRetrySeconds => _nextRetrySeconds;

  /// 内部统一的日志追踪控制器。
  /// 捕获底层通信的状态转折并写入本机存储日志。
  void _log(String message) {
    writelog(message);
    if (kDebugMode) {
      print(message);
    }
  }

  // 连接状态流控制器
  final _connectionController = StreamController<ServiceState>.broadcast();
  Stream<ServiceState> get connectionStream => _connectionController.stream;

  // 获取当前连接状态
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  ServiceState get currentState {
    if (_isConnected) return ServiceState.connected;
    if (_isConnecting) return ServiceState.connecting;
    if (_reconnectTimer != null) return ServiceState.retrying;
    return ServiceState.disconnected;
  }

  /// 发起长连接通信 (WebSocket Connection)。
  /// 当与主机通信失败或抛出异常时会触发断网事件 [EventServiceOff]，并立即启动自动重连检测。
  Future<void> connect() async {
    if (_isConnecting || _isConnected) {
      _log('connect is connecting or connected, skip reconnect.');
      return;
    }

    _isConnecting = true;
    _connectionController.add(ServiceState.connecting);

    try {
      _log('start connecting to server...');

      // 关闭现有连接（如果有）
      await disconnect();

      // 建立新连接并等待建立完成
      final ws =
          await WebSocket.connect(_url).timeout(const Duration(seconds: 5));
      _channel = IOWebSocketChannel(ws);

      // 监听连接
      _channelSubscription = _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _isConnected = true;
      _isConnecting = false;
      _hasEverConnected = true;
      _reconnectAttempts = 0;

      _connectionController.add(ServiceState.connected);
      _log('connect to server success.');

      // 启动心跳检测
      _startHeartbeat();

      // 连接成功后获取必要数据
      _onConnected();
    } catch (e) {
      _log('connect to server failed: $e');
      _isConnecting = false;
      _connectionController.add(ServiceState.disconnected);

      if (_hasEverConnected) {
        _log('Triggering service off event due to connection failure.');
        eventBus.fire(EventServiceOff(''));
      } else {
        _log('Silent reconnect on initial startup failure.');
      }

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
      await _channelSubscription?.cancel();
      _channelSubscription = null;
      await _channel?.sink.close();
      _channel = null;
      _log('WebSocket connection disconnected properly.');
    } catch (e) {
      _log('disconnect to server failed: $e');
    }

    _connectionController.add(ServiceState.disconnected);
  }

  // 发送消息
  void sendMessage(String message) {
    debugPrint("WebSocketManager sending: $message");
    if (!_isConnected || _channel == null) {
      _log('connect not connected, can not send message: $message');
      return;
    }

    try {
      _channel!.sink.add(message);
    } catch (e) {
      _log('send message failed: $e');
      _onError(e);
    }
  }

  /// 底层通信数据流入总闸口。包含数据接收与 JSON 解析。
  /// 解析底层传入包后，过滤掉心跳包 (`code == 9999`)，
  /// 并根据 [MsgType] 反射派发至全局业务处理器 [RespSysMsgType.handlers]。
  void _onData(dynamic data) {
    if (data == null) return;

    if (kDebugMode) {
      print('0 收到消息:$data');
    }

    try {
      Map<String, dynamic> map = json.decode(data);

      // 处理心跳响应
      if (map['code'] == 9999) {
        return;
      }

      writelog("[WS_RECV_RAW] $data");

      // 处理业务消息
      var msgType = map['MsgType'];
      if (msgType != null) {
        if (RespSysMsgType.handlers.containsKey(msgType)) {
          var handler = RespSysMsgType.handlers[msgType];
          handler?.call(map);
        } else if (RespMsgType.handlers.containsKey(msgType)) {
          var handler = RespMsgType.handlers[msgType];
          handler?.call(map);
        } else {
          writelog("[WS_RECV_UNHANDLED] Unknown MsgType: $msgType, full map: $map");
        }
      }
    } catch (e) {
      _log('handle message failed: $e\nData: $data');
    }
  }

  // 错误处理
  void _onError(error) {
    _log('websocket error: $error');
    _handleDisconnectEvent();
    _scheduleReconnect();
  }

  // 连接关闭处理
  void _onDone() {
    _log('WebSocket connection closed.');
    _handleDisconnectEvent();
    _scheduleReconnect();
  }

  void _handleDisconnectEvent() {
    if (_isConnected || _isConnecting) {
      if (_hasEverConnected) {
        _log('Triggering service off event from stream disconnect.');
        eventBus.fire(EventServiceOff(''));
      } else {
        _log('Silent stream disconnect on initial startup.');
      }
    }
    _isConnected = false;
    _isConnecting = false;
    _connectionController.add(ServiceState.disconnected);
  }

  // 连接成功后的初始化
  void _onConnected() async {
    // 获取必要数据
    PublicFunctions.getLicense();
    await Future.delayed(const Duration(milliseconds: 200));
    PublicFunctions.getScaleList();
    await Future.delayed(const Duration(milliseconds: 200));
    PublicFunctions.getAllSysUsers();

    await Future.delayed(const Duration(milliseconds: 200));
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
      _log('send heartbeat failed: $e');
    }
  }

  /// 断线后的智能重连策略处理器。
  /// 采用 Exponential backoff (指数退避) 算法休眠机制，
  /// 网络丢失后会在逐步延迟增加 (2s, 4s, 8s, 最高不超过 60s) 的时间梯次里发出重新连接申请。
  void _scheduleReconnect() {
    if (_reconnectTimer != null) {
      return;
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _log('Max reconnect attempts reached. Stop reconnecting.');
      return;
    }

    _reconnectAttempts++;
    // Exponential backoff: 2s, 4s, 8s, 16s, 32s...
    int delaySeconds = 2 << (_reconnectAttempts - 1);
    if (delaySeconds > 60) delaySeconds = 60; // Max 60 seconds
    _nextRetrySeconds = delaySeconds;

    _log(
        'schedule reconnect, try times: $_reconnectAttempts/$_maxReconnectAttempts, delay: ${delaySeconds}s');

    _connectionController.add(ServiceState.retrying);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
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
