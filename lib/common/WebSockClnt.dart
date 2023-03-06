// // ignore_for_file: file_names, avoid_print

// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;
// import 'package:t_max/data/conninfolist_data.dart';
// import '../data/cominfoslist_data.dart';
// import '../data/dialog_data.dart';
// import '../data/notifydata_data.dart';
// import '../data/recdata_data.dart';
// import '../data/report_data.dart';
// import '../data/respdata_data.dart';
// import '../data/siganl.dart';
// import '../data/sportinfolist_data.dart';
// import '../data/uicmd_data.dart';
// import '../data/login_data.dart';
// import '../data/weight_data.dart';
// import '../data/weightparam_data.dart';
// import '../data/date_data.dart';
// import '../data/device_data.dart';
// import '../data/time_data.dart';
// import '../eventbus/eventbus.dart';

// class WebSockClnt {
//   late String url;
//   late io.Socket socket;

//   WebSockClnt(this.url);

//   connect() async {
//     try {
//       socket = io.io(url, <String, dynamic>{
// //         'path': '/ws',
// //         Host: localhost:8080
// // Origin:http: //127.0.0.1:3000
// // Connection: Upgrade
// // Upgrade: websocket
//         // 构造的header放这里

//         'transports': ['websocket']
//       });
//       // Dart client

//       socket.on('connect', (_) {
//         if (kDebugMode) {
//           print('connected');
//         }
//         dynamic mobj = Siganl('connect');
//         eventBus.fire(EventSignal(mobj));
//       });

//       socket.on("devicename", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = Devicedata.fromJson(map);
//         eventBus.fire(EventDeviceName(mobj));
//       });

//       socket.on("time", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = Time.fromJson(map);
//         eventBus.fire(EventTime(mobj));
//       });

//       socket.on("date", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = Date.fromJson(map);
//         eventBus.fire(EventDate(mobj));
//       });

//       socket.on("uicmd", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = UiCmd.fromJson(map);
//         eventBus.fire(EventUiCmd(mobj));
//       });

//       socket.on("weightsdata", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = WtData.fromJson(map);
//         eventBus.fire(EventWtData(mobj));
//       });

//       socket.on("launguage", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = DialogData.fromJson(map);
//         eventBus.fire(EventDialogData(mobj));
//       });

//       socket.on("reportdata", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = ReportData.fromJson(map);
//         eventBus.fire(EventDialogData(mobj));
//       });
//       socket.on("userdata", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = UserData.fromJson(map);
//         eventBus.fire(EventUserData(mobj));
//       });
//       socket.on("weightparamdata", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = WeightParamData.fromJson(map);
//         eventBus.fire(EventWeightParamData(mobj));
//       });

//       socket.on("conninfolist", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = ConnInfoList.fromJson(map);
//         eventBus.fire(EventConnInfoList(mobj));
//         // dynamic mobj1 = mobj.infolist;
//         // eventBus.fire(EventConnInfo(mobj1));
//         // dynamic mobj2 = mobj1.media;
//         // eventBus.fire(EventConnInfo(mobj2));
//       });
//       socket.on("recorddata", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = RecData.fromJson(map);
//         eventBus.fire(EventRecData(mobj));
//       });

//       socket.on("respdata", (data) {
//         if (kDebugMode) {
//           print('data:  => $data');
//         }
//         Map<String, dynamic> map = json.decode(data);
//         dynamic mobj = RespData.fromJson(map);
//         eventBus.fire(EventRespData(mobj));
//       });

//       // socket.on("notifydata", (data) {
//       //   if (kDebugMode) {
//       //     print('data:  => $data');
//       //   }
//       //   Map<String, dynamic> map = json.decode(data);
//       //   dynamic mobj = NotifyData.fromJson(map);
//       //   eventBus.fire(EventNotifyData(mobj));
//       // });

//       socket.on('exception', (e) => print('Exception: $e'));
//       socket.on('connect_error', (e) => print('Connect error: $e'));
//       socket.on('disconnect', (data) {
//         if (kDebugMode) {
//           print('disconnect');
//         }
//         dynamic mobj = Siganl('disconnect');
//         eventBus.fire(EventSignal(mobj));
//       });
//       socket.on('fromServer', (_) => print(_));
//     } catch (e) {
//       if (kDebugMode) {
//         print('Exception: ' + e.toString());
//       }
//     }
//   }

//   send(event, data) {
//     if (socket.connected) {
//       socket.emit(event, data);
//       if (kDebugMode) {
//         print('send: $event - $data');
//       }
//     }
//   }

//   close() {
//     socket.close();
//   }
// }
