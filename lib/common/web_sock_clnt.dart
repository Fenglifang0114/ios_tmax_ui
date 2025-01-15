// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';

// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// import '../eventbus/eventbus.dart';

// // late WebSocketSevice webchannel1;

// class WebSocketSevice {
//   late String url;
//   late IOWebSocketChannel channel;
//   WebSocketSevice(this.url);
//   bool heartStatus = false;
//   // 最大重试次数，可根据实际情况调整
//   static const int maxRetryAttempts = 5;
//   // 当前重试次数
//   int retryAttempts = 0;
//   // 重试间隔时间基数，可根据实际情况调整
//   static const Duration retryIntervalBase = Duration(seconds: 2);

//   // 用于标记当前连接状态，初始化为未连接
//   bool isConnected = false;

//   // 根据传入参数决定连接或断开连接
//   void handleConnection(bool shouldConnect) async {
//     if (shouldConnect) {
//       if (!isConnected) {
//         // 在连接之前先检查端口是否通畅
//         if (await isPortAvailable()) {
//           await connect();
//         } else {
//           debugPrint('指定端口不可用，请检查服务器状态后重试。');
//         }
//       } else {
//         debugPrint('已经处于连接状态，无需再次连接');
//       }
//     } else {
//       if (isConnected) {
//         await disconnect();
//       } else {
//         debugPrint('已经处于未连接状态，无需执行断开操作');
//       }
//     }
//   }

//   // 检查指定端口是否可用的函数
//   Future<bool> isPortAvailable() async {
//     try {
//       // 从URL中解析出主机和端口
//       final uri = Uri.parse(url);
//       final host = uri.host;
//       final port = uri.port;

//       // 创建一个TCP套接字并尝试连接到指定端口
//       final socket = await Socket.connect(host, port);
//       // 如果成功连接，关闭套接字并返回true
//       socket.close();
//       return true;
//     } catch (e) {
//       // 如果连接失败，返回false
//       return false;
//     }
//   }

//   // 开始进行链接
//   Future<void> connect() async {
//     heartStatus = true;
//     try {
//       channel = IOWebSocketChannel.connect(url);
//       channel.stream.listen(onData, onError: onError, onDone: onDone);
//       // 连接成功后，设置连接状态为已连接，并重置重试次数
//       isConnected = true;
//       retryAttempts = 0;
//     } catch (e) {
//       // 这里添加更多类型的异常判断和处理
//       if (e is SocketException) {
//         // 处理Socket相关的异常，比如记录错误并触发重连逻辑等
//         onError(e);
//         if (retryAttempts < maxRetryAttempts) {
//           retryAttempts++;
//           // 按照指数退避策略计算下一次重试间隔时间
//           Duration retryInterval =
//               retryIntervalBase * (2 * (retryAttempts - 1));
//           await Future.delayed(retryInterval);
//           await connect();
//         } else {
//           // 达到最大重试次数，可进行更详细的错误处理，比如记录错误并通知用户等
//           debugPrint('已达到最大重试次数，无法连接到WebSocket服务器');
//           isConnected = false;
//           // 不要直接退出程序，而是进行一些提示或记录操作
//           print('服务器可能未开启，请检查服务器状态后重试。');
//           // 可以在这里添加更多的错误处理逻辑，比如通知相关模块或界面进行显示等
//         }
//       } else if (e is FormatException) {
//         // 处理可能的格式相关异常，如URL格式错误等
//         debugPrint('连接时出现格式错误: $e');
//         // 可以根据实际情况决定是否进行重连等操作
//       } else {
//         // 处理其他未知类型的异常
//         debugPrint('连接时出现未知异常: $e');
//         // 可以进行一些通用的错误处理，如记录错误等
//       }
//     }
//   }

//   // 断开连接
//   Future<void> disconnect() async {
//     isConnected = false;
//     heartStatus = false;
//     if (channel != null) {
//       await channel.sink.close();
//       // 取消可能存在的定时器等相关资源清理（如果有），这里假设没有相关定时器了，可根据实际情况添加
//       // 例如，如果有心跳包定时器，需要在这里取消：heartTimer.cancel();
//     }
//     debugPrint('已成功断开WebSocket连接');
//   }

//   // 发送消息
//   void sendMessage(String s) {
//     if (channel != null && isConnected) {
//       channel.sink.add(s);
//     } else {
//       debugPrint('WebSocket通道未建立或未处于连接状态，无法发送消息');
//     }
//   }

//   // 断连，然后执行重连
//   void onDone() {
//     debugPrint("Socket0 onDone");
//     // reconnectSocket();
//   }

//   // 发送心跳包
//   void sendHeartPacket() {
//     if (channel != null && isConnected) {
//       Map<String, dynamic> data = {
//         "code": 9999,
//         "款名": "心跳包",
//       };
//       var jsonData = json.encode(data);
//       sendMessage(jsonData);
//     } else {
//       debugPrint('WebSocket通道未建立或未处于连接状态，无法发送心跳包');
//     }
//   }

//   // 错误日志
//   Future<void> onError(err) async {
//     debugPrint(err.runtimeType.toString());
//     WebSocketChannelException ex = err;
//     debugPrint(ex.message);
//     heartStatus = false;
//     // 连接错误时触发重连逻辑
//     if (err is WebSocketChannelException) {
//       if (retryAttempts < maxRetryAttempts) {
//         retryAttempts++;
//         Duration retryInterval = retryIntervalBase * (2 * (retryAttempts - 1));
//         await Future.delayed(retryInterval);
//         await connect();
//       } else {
//         debugPrint('已达到最大重试次数，无法连接到WebSocket服务器');
//         isConnected = false;
//       }
//     }
//   }

//   // 接受数据，数据json字符串，然后转成Map
//   void onData(event) {
//     if (event != null) {
//       if (kDebugMode) {
//         print('999收到消息:$event');
//       }
//       paster(event);
//     }
//   }

//   void destoryHeart() {
//     //为心跳包则直接
//     if (heartStatus) {
//       // hearTimer.cancel();
//       heartStatus = false;
//     }
//   }

//   /// 重新连接socket
//   void reconnectSocket() {
//     destoryHeart();
//     connect();
//   }

//   void dispose() {
//     if (heartStatus) {
//       // hearTimer.cancel();
//     }
//     if (channel != null) {
//       channel.sink.close();
//     }
//     heartStatus = false;
//     isConnected = false;
//   }

//   /// @desc WebSocket心跳包
//   /// @author Marinda
//   /// @date 2022/9/26
//   void heartPacket() {
//     if (heartStatus && channel != null && isConnected) {
//       // hearTimer = Timer(const Duration(seconds: 100), () async {
//       //   //  重新连接
//       //   sendHeartPacket();
//       //   // connect();
//       // });
//       // sendHeartPacket();
//     }
//   }

//   // 以下其他函数（如getComScaleList、getNetScaleList等）保持不变，省略展示以节省篇幅

//   Future<void> paster(dynamic data) async {
//     var jsonData = json.decode(data);
//     try {
//       if (jsonData['MsgType'] == "resp_detail_list") {
//         var dataString = jsonData['MsgBody'];
//         eventBus.fire(EventRespDetailInfo(dataString));
//       } else {}
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
//   // 其他函数（如pasterLicense、pasterLicenseKey等）保持不变，省略展示以节省篇幅
// }
