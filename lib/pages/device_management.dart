// import 'package:flutter/material.dart';
// import 'package:t_max/data/cominfoslist_data.dart';
// import 'package:t_max/data/comscaleinfo_data.dart';
// import 'package:t_max/data/conninfolist_data.dart';
// import 'package:t_max/data/report_data.dart';
// import 'package:t_max/data/respdata_data.dart';
// import 'package:t_max/pages/home_page.dart';
// import '../common/WebSocketScaleChannel.dart';
// import '../data/device_data.dart';
// import '../data/downloadresponse.dart';
// import '../eventbus/eventbus.dart';
// import '../main.dart';
// import 'dialog/showComPort_dialog.dart';
// import 'widget/connect_scale_ways.dart';
// import 'widget/reusable_list_item.dart';
// import 'widget/showWeightReport.dart';
// import 'widget/appbarMsg.dart';
// import 'widget/version.dart';

// // late WebSocketScaleChannel MyApp.webchannel1;

// class DeviceManagementPage extends StatefulWidget {
//   const DeviceManagementPage({Key? key}) : super(key: key);

//   @override
//   State<DeviceManagementPage> createState() => _DeviceManagementPageState();
// }

// class _DeviceManagementPageState extends State<DeviceManagementPage> {
//   List<String> items = [];
//   List<String> comPortList = [];
//   TextEditingController weightController = TextEditingController();
//   TextEditingController repsController = TextEditingController();
//   List<DataRow> dataRows = [];

//   late ScrollController _pageScrollerController;

//   // String scaleUrl = 'ws://127.0.0.1:56567/tmax?scaleid=1';

//   // String scaleUrl = 'ws://127.0.0.1:7878/tmax?scaleid=1';
//   // String scaleUrl = 'ws://10.5.52.65:7878/tmax?scaleid=1';

//   dynamic _eventbus1;
//   dynamic _eventbus2;
//   dynamic _eventbus3;
//   dynamic _eventbus4;
//   dynamic _eventbus5;
//   dynamic _eventbus6;
//   dynamic _eventbus7;
//   dynamic _eventbus8;
//   dynamic _eventbus9;

//   @override
//   void initState() {
//     super.initState();
//     // MyApp.webchannel1 = WebSocketScaleChannel(scaleUrl);
//     // getPortList();
//     initScaleList();

//     _pageScrollerController = ScrollController();
//     _eventbus1 = eventBus.on<EventDeviceName>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myDevicedata = event.obj;
//         });
//       }
//     });

//     _eventbus2 = eventBus.on<EventSerialinfoData>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myReportData = event.obj;
//         });
//       }
//     });

//     _eventbus3 = eventBus.on<EventConnInfoList>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myConnInfoList = event.obj;
//         });
//       }
//     });
//     _eventbus4 = eventBus.on<EventRespData>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myRespData = event.obj;
//         });
//       }
//     });

//     _eventbus5 = eventBus.on<EventComInfoList>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myComInfoList = event.obj;
//           checkPortList();
//         });
//       }
//     });

//     _eventbus6 = eventBus.on<EventComScaleList>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myComScaleList = event.obj;
//           reconnectScale();
//           // initScaleList();
//         });
//       }
//     });
//     _eventbus7 = eventBus.on<EventDeviceName>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myDevicedata = event.obj;
//           // getWeight();
//           // getRecords();
//         });
//       }
//     });

//     _eventbus8 = eventBus.on<EventSerialPortResponse>().listen((event) {
//       if (mounted) {
//         setState(() {
//           mySerialPortResponse = event.obj;
//           if (mySerialPortResponse.msgBody.isNotEmpty &&
//               mySerialPortStatus.serialPortStatus) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text(mySerialPortResponse.msgBody,
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold)), ////此处需要秤回复
//                 duration: const Duration(seconds: 10),
//                 backgroundColor: Theme.of(context).colorScheme.error.shade900));
//           }
//           mySerialPortStatus.serialPortStatus = false;
//           eventBus.fire(EventSerialPortStatus(mySerialPortStatus));
//         });
//       }
//     });

//     _eventbus9 = eventBus.on<EventSerialPortStatus>().listen((event) {
//       if (mounted) {
//         setState(() {
//           mySerialPortStatus = event.obj;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _eventbus1.cancel();
//     _eventbus2.cancel();
//     _eventbus3.cancel();
//     _eventbus4.cancel();
//     _eventbus5.cancel();
//     _eventbus6.cancel();
//     _eventbus7.cancel();
//     _eventbus8.cancel();
//     _eventbus9.cancel();
//     _pageScrollerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return
//         // MaterialApp(
//         //   debugShowCheckedModeBanner: false,
//         //   theme: themeColor(),
//         //   home:
//         Scaffold(
//       // drawer: leftSidebar(context),
//       // AppBar：相当于iOS 的导航栏
//       appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(30),
//           child: AppBar(
//             title: version(),
//             actions: [AppbarMsg(context)],
//           )),
//       body: ListView(
//         // 水平拉伸
//         scrollDirection: Axis.horizontal,
//         children: [
//           Row(
//             children: [
//               //左侧添加设备
//               Container(
//                 width: 200,
//                 decoration: const BoxDecoration(
//                     border: Border(
//                         right: BorderSide(width: 0.5, color: Theme.of(context).colorScheme.onSurface))),
//                 child: Column(
//                   children: <Widget>[
//                     const Divider(
//                       height: 1.0,
//                       color: Color(0xFF004a98),
//                     ),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(context,
//                               MaterialPageRoute(builder: (context) {
//                             return const HomePage();
//                           }));
//                         },
//                         style: ElevatedButton.styleFrom(
//                           fixedSize: const Size(180, 40),
//                           side: BorderSide(
//                               width: 2,
//                               color: Theme.of(context).colorScheme.primary),
//                           foregroundColor:
//                               Theme.of(context).colorScheme.primary,
//                           backgroundColor: Theme.of(context).colorScheme.onPrimary, //体颜色
//                           textStyle: const TextStyle(
//                               fontWeight: FontWeight.bold), // 字体样式
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8), // 圆角
//                           ),
//                           elevation: 5, // 阴影
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Icon(Icons.home),
//                             Text("Home"),
//                           ],
//                         )),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     Container(
//                       margin: const EdgeInsets.only(
//                           left: 20, top: 5, right: 20), //设置 child 居中
//                       alignment: const Alignment(0, 0),
//                       height: 40,
//                       width: 220, //边框设置

//                       child: Text(
//                         "My device",
//                         style: TextStyle(
//                             color: Theme.of(context).colorScheme.primary,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Divider(
//                       height: 1,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         controller: _pageScrollerController,
//                         itemBuilder: (context, index) {
//                           String idContextIcon = (index + 1).toString() +
//                               "," +
//                               items[index].toString();

//                           return ReusableListItem(idContextIcon);
//                         },
//                         itemCount: items.length,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // GridPage()
//               //右侧重量显示
//               const ConnectScaleWays(),
//             ],
//           )
//         ],
//       ),
//       // ),
//     );
//   }

//   void reconnectScale() {
//     String scaleId;
//     if (MyApp.webchannel1.heartStatus == false) {
//       if (myComScaleList.comScaleList.isNotEmpty) {
//         scaleId = myComScaleList.comScaleList[0].scaleId.toString();
//         // MyApp.webchannel1 = WebSocketScaleChannel(scaleUrl + scaleId);
//         MyApp.webchannel1 =
//             WebSocketScaleChannel('ws://127.0.0.1:7878/tmax?scaleid=1');
//         MyApp.webchannel1.connect();
//       }
//     }
//   }

//   void initScaleList() {
//     if (myComScaleList.comScaleList.isNotEmpty) {
//       items.clear();
//       int tmpLenth = myComScaleList.comScaleList.length;

//       for (int i = 0; i < tmpLenth; i++) {
//         String iconType = "";
//         if (myComScaleList.comScaleList[i].tMedia == 0) {
//           if (myComScaleList.comScaleList[i].isOnline == true) {
//             iconType = "Icons.usb";
//           } else {
//             iconType = "Icons.usb_off";
//           }
//         } else {
//           iconType = "Icons.device_unknown";
//         }
//         items.add(myComScaleList.comScaleList[i].scaleModel.toString() +
//             "," +
//             iconType +
//             "," +
//             myComScaleList.comScaleList[i].scaleId.toString());
//       }
//     }
//   }
// }
