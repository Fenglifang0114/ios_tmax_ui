// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:t_max/data/comscaleinfo_data.dart';
// import 'package:t_max/data/scalecmd_data.dart';
// import 'package:t_max/data/writelog.dart';
// import '../data/cominfoslist_data.dart';
// import '../data/device_data.dart';
// import '../data/downloadresponse.dart';
// import '../data/ipinfodata.dart';
// import '../data/language.dart';
// import '../data/manager_scale_channel.dart';
// import '../data/modifyresult_data.dart';
// import '../data/modifyscale_data.dart';
// import '../data/scale_info_from_scale.dart';
// import '../data/scalelist_data.dart';
// import '../eventbus/eventbus.dart';
// import '../functions/methods.dart';
// import '../widget/comport_dorpdown.dart';
// import '../widget/custom_button.dart';
// import '../widget/page_head.dart';

// class ScaleManagerPage extends StatefulWidget {
//   const ScaleManagerPage({super.key});

//   @override
//   State<ScaleManagerPage> createState() => ScaleManagerPageState();
// }

// class ScaleManagerPageState extends State<ScaleManagerPage> {
//   List<NetScaleInfoLocal> scaleNetItems = [];
//   List<int> wifiRssiList = [];
//   List<String> bssidList = [];

//   TextEditingController scaleModelCtl = TextEditingController(text: '');
//   TextEditingController scaleNameCtl = TextEditingController(text: '');
//   TextEditingController snCtl = TextEditingController(text: '');
//   TextEditingController portCtl = TextEditingController(text: '');
//   TextEditingController ipCtl = TextEditingController(text: '');

//   int selScaleId = -1;

//   bool passwordLock = true;
//   bool isAddScale = false;
//   bool isTesting = false;
//   bool isRename = false;
//   bool _isValidIP = false;
//   bool _isModifyName = false;
//   bool _isEditing = false;
//   bool _isNetPort = false;
//   bool isDel = false; //是否执行删除

//   NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();

//   dynamic _eventbus1;
//   dynamic _eventbus2;
//   dynamic _eventbus3;
//   dynamic _eventbus4;
//   dynamic _eventbus5;
//   dynamic _eventbus6;
//   dynamic _eventbus7;
//   dynamic _eventbus8;
//   dynamic _eventbus9;
//   // dynamic _eventbus10;

//   Timer? checkIsOnlineTimer;
//   Timer? _debounceTimer;

//   ///////////////////
//   List<String> comLists = [];
//   String comPort = "";

//   List<String> baudRateList = [
//     '115200',
//     '57600',
//     '38400',
//     '19200',
//     '14400',
//     '9600',
//     '4800',
//     '2400',
//     '1200'
//   ];
//   List<String> scaleModelList = ['TMax'];
//   String scaleModel = myModifyScale.scaleModel.toString();
//   List<String> dataBitsList = ['8']; //去掉5,6,7,8
//   List<String> stopBitsList = ['1']; //, '1.5', '2'
//   List<String> checkBitsList = ['None']; //, 'Odd', 'Even'
//   List<String> protocolList = [
//     'None'
//   ]; //'Xon/Xoff', 'None', 'Rts/Cts', 'Dsr/Dtr'
//   String dialogtype = "com";
//   String refresh = " ";
//   String serialPortConnect = " ";
//   bool isComSetting = false;
//   bool isClosePort = false;

//   /////////////////////

//   RegExp ipaddressRegex = RegExp(r'[0-9.]');

//   RegExp ipRegex = RegExp(
//     r'^((\d{1,3}\.){3}\d{1,3})$',
//     multiLine: false,
//     caseSensitive: false,
//   );

//   bool _isValidIpAddress(bool tempValid, String value) {
//     if (tempValid) {
//       List<int?> parts = value.split('.').map(int.tryParse).toList();
//       if (parts.any((part) => part == null || part > 255)) {
//         tempValid = false;
//       }
//     }
//     return tempValid;
//   }

//   @override
//   void initState() {
//     super.initState();
//     initScaleList();
//     initEventBus();
//     PublicFunctions.getPortList();
//     PublicFunctions.openSerialPort(1);
//     DefScaleInfo.getDefScaleInfo(1);
//     checkPortList();

//     scaleNameCtl.addListener(_onScaleNameChanged);
//     ipCtl.addListener(_onIpChanged);
//     portCtl.addListener(_onPortChanged);

//     _startTimer();
//   }

//   void initScaleList() {
//     scaleNetItems = myNetScaleList;
//     selScaleId = myDefScaleInfo.defScaleId!;
//     if (myNetScaleList.isNotEmpty) {
//       defNetScaleInfo = NetScaleListMgr.findScaleInfo(
//           myNetScaleList, myDefScaleInfo.defScaleId!);
//     }
//     if (defNetScaleInfo.scaleId != null) {
//       scaleModelCtl.text = defNetScaleInfo.scaleModel!;
//       snCtl.text = defNetScaleInfo.scaleSn!;
//       ipCtl.text = defNetScaleInfo.ip!;
//       portCtl.text = defNetScaleInfo.port!.toString();
//       scaleNameCtl.text = defNetScaleInfo.scaleName!;
//     }
//     if (myDefScaleInfo.defScaleId! == 1) {
//       scaleModelCtl.text = myComScaleInfo.scaleModel;
//       snCtl.text = myComScaleInfo.scaleSn;
//       scaleNameCtl.text = myComScaleInfo.scaleName;
//     }
//   }

//   void initEventBus() {
//     _eventbus1 = eventBus.on<EventRespDelScale>().listen((event) {
//       if (mounted) {
//         setState(() {
//           String dataStr = event.obj;
//           if (dataStr.isNotEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text((dataStr.contains('ok')) ? "OK" : dataStr,
//                     style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.normal)), ////此处需要秤回复
//                 duration: const Duration(seconds: 3),
//                 backgroundColor: (dataStr.contains('ok'))
//                     ? Theme.of(context).colorScheme.onTertiaryFixedVariant
//                     : Theme.of(context).colorScheme.error));
//             if (dataStr.contains('ok') && isDel) {
//               NetScaleListMgr.delScaleById(myNetScaleList, selScaleId);
//               // manager.delete(selScaleId);TODO:检查这个要不要自动删除
//               selScaleId = myDefScaleInfo.defScaleId!;
//               scaleNameCtl.text = myDefScaleInfo.defScaleName!;
//               scaleModelCtl.text = myDefScaleInfo.defScaleModel!;
//               snCtl.text = myDefScaleInfo.defScaleSn!;
//               ipCtl.text = myDefScaleInfo.defScaleIp == null
//                   ? ""
//                   : myDefScaleInfo.defScaleIp!;
//               portCtl.text = myDefScaleInfo.defScalePort == null
//                   ? ""
//                   : myDefScaleInfo.defScalePort!;
//               if (scaleModelCtl.text == "TMax") {
//                 scaleModelCtl.text = "";
//                 snCtl.text = "";
//               }

//               isDel = false;
//             }
//           }
//         });
//       }
//     });

//     _eventbus2 = eventBus.on<EventRespAddScale>().listen((event) {
//       if (mounted) {
//         setState(() {
//           isAddScale = false;
//           String dataStr = event.obj;
//           if (dataStr.isNotEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text((dataStr.contains('ok')) ? "OK" : dataStr,
//                     style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.normal)), ////此处需要秤回复
//                 duration: const Duration(seconds: 3),
//                 backgroundColor: (dataStr.contains('ok'))
//                     ? Theme.of(context).colorScheme.onTertiaryFixedVariant
//                     : Theme.of(context).colorScheme.error));
//           }

//           for (int i = 0; i < myNetScaleList.length; i++) {
//             if (selScaleId < myNetScaleList[i].scaleId!) {
//               selScaleId = myNetScaleList[i].scaleId!;
//               scaleNameCtl.text = myNetScaleList[i].scaleName!;
//               scaleModelCtl.text = myNetScaleList[i].scaleModel!;
//               snCtl.text = myNetScaleList[i].scaleSn!;
//             }
//           }
//           if (scaleModelCtl.text == "TMax") {
//             scaleModelCtl.text = "";
//             snCtl.text = "";
//           }
//         });
//       }
//     });

//     _eventbus3 = eventBus.on<EventRespCheckNetScale>().listen((event) {
//       if (mounted) {
//         myOnlineInfo = event.obj;
//         myFactoryInfoFromScale = myOnlineInfo.factInfo!;
//         setState(() {
//           if (myFactoryInfoFromScale.modelName != '') {
//             setNetScaleStatus(myOnlineInfo.scaleId!, true);
//             if (isTesting) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                   content: const Text("OK",
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.normal)), ////此处需要秤回复
//                   duration: const Duration(seconds: 3),
//                   backgroundColor:
//                       Theme.of(context).colorScheme.onTertiaryFixedVariant));
//             }
//           } else {
//             setNetScaleStatus(myOnlineInfo.scaleId!, false);
//             if (isTesting) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                   content: const Text('fail',
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.normal)), ////此处需要秤回复
//                   duration: const Duration(seconds: 3),
//                   backgroundColor: Theme.of(context).colorScheme.error));
//             }
//           }
//           if (isTesting) {
//             isTesting = false;
//           }
//         });
//       }
//     });

//     _eventbus4 = eventBus.on<EventRespCheckComPort>().listen((event) {
//       if (mounted) {
//         setState(() {
//           if (myComScaleSn.modelName != '') {
//             myComScaleInfo.isOnline = true;
//             if (isTesting) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                   content: const Text("OK",
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.normal)), ////此处需要秤回复
//                   duration: const Duration(seconds: 3),
//                   backgroundColor:
//                       Theme.of(context).colorScheme.onTertiaryFixedVariant));
//             }
//           } else {
//             myComScaleInfo.isOnline = false;
//             myComScaleInfo.isOnline = false;
//             myComScaleSn.modelName = '';
//             myComScaleSn.scaleSn = '';
//             if (isTesting) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                   content: const Text('fail',
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.normal)), ////此处需要秤回复
//                   duration: const Duration(seconds: 3),
//                   backgroundColor: Theme.of(context).colorScheme.error));
//             }
//           }
//           if (isTesting) {
//             isTesting = false;
//           }
//         });
//       }
//     });
//     _eventbus5 = eventBus.on<EventSerialPortResponse>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myRespDataFromScale = event.obj;

//           if (myComScaleInfo.isOnline) {
//             myComScaleInfo.isOnline = false;
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: const Text('The serial port disconnected.',
//                     style: TextStyle(fontSize: 20)), ////此处需要秤回复
//                 duration: const Duration(seconds: 5),
//                 backgroundColor: Theme.of(context).colorScheme.error));
//           }
//           myComScaleInfo.isOnline = false;
//           myComScaleSn.modelName = '';
//           myComScaleSn.scaleSn = '';
//           myComScaleInfo.isOnline = false;
//         });
//       }
//     });

//     _eventbus6 = eventBus.on<EventRespScaleModify>().listen((event) {
//       if (mounted) {
//         myModifyAck = event.obj;
//         isComSetting = false;
//         PublicFunctions.checkSerialPort(1);
//         isTesting = true;
//       }
//     });

//     _eventbus7 = eventBus.on<EventComInfoList>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myComInfoList = event.obj;
//           checkPortList();
//         });
//       }
//     });

//     _eventbus8 = eventBus.on<EventDeviceName>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myDevicedata = event.obj;
//         });
//       }
//     });
//     _eventbus9 = eventBus.on<EventCurrentPort>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myCurrentPort = event.obj;
//         });
//       }
//     });

//     // _eventbus10 = eventBus.on<EventRespCheckComPort>().listen((event) {
//     //   if (mounted) {
//     //     setState(() {
//     //       // isSetting = false;
//     //       myComScaleSn = event.obj;
//     //       if (myComScaleSn.modelName != '') {
//     //         serialPortConnect = localizedStrings.txt_serial_port_connected;
//     //         myComScaleInfo.isOnline = true;
//     //       } else {
//     //         serialPortConnect = localizedStrings.txt_serial_port_connected_fail;
//     //         myComScaleInfo.isOnline = false;
//     //       }
//     //     });
//     //   }
//     // });
//   }

//   void _onPortChanged() {
//     if (portCtl.text.isEmpty) {
//       if (_isNetPort) {
//         setState(() {
//           _isNetPort = false;
//         });
//       }
//       return;
//     }

//     if (_isNetPort != true) {
//       setState(() {
//         _isNetPort = true;
//       });
//     }
//   }

//   void _onIpChanged() {
//     if (ipCtl.text.isEmpty) {
//       if (_isValidIP) {
//         setState(() {
//           _isValidIP = false;
//         });
//       }
//       return;
//     }
//     bool isValid = validateIpFlag(ipCtl.text);
//     if (isValid != _isValidIP) {
//       setState(() {
//         _isValidIP = isValid;
//       });
//     }
//   }

//   void _onScaleNameChanged() {
//     if (scaleNameCtl.text.isNotEmpty) {
//       bool isValid = isValidScaleName(scaleNameCtl.text);
//       if (_isModifyName != isValid) {
//         setState(() {
//           _isModifyName = isValid;
//         });
//       }
//     } else {
//       if (_isModifyName) {
//         setState(() {
//           _isModifyName = false;
//         });
//       }
//     }
//   }

//   void setNetScaleStatus(int scaleId, bool status) {
//     for (int i = 0; i < scaleNetItems.length; i++) {
//       if (scaleNetItems[i].scaleId == scaleId) {
//         scaleNetItems[i].isOnline = status;
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _eventbus1.cancel();
//     _eventbus2.cancel();
//     _eventbus3.cancel();
//     _eventbus4.cancel();
//     _eventbus5.cancel();
//     _eventbus7.cancel();
//     _eventbus8.cancel();
//     _eventbus9.cancel();
//     _eventbus6.cancel();
//     // _eventbus10.cancel();
//     _stopTimer();
//     scaleNameCtl.dispose();
//     _debounceTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final _width = MediaQuery.of(context).size.width;
//     // final _height = MediaQuery.of(context).size.height;
//     tempCurrentPort = myCurrentPort;
//     return Scaffold(
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(50),
//           child: pageHeadDesign(
//             context,
//             localizedStrings.menuMultiScaleManagement,
//             [myDefScaleInfo.defScaleId!],
//             localizedStrings.gTipScaleMgrPageHelp,
//           ),
//         ),
//         body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(
//             width: 350,
//             color: Theme.of(context).colorScheme.surfaceTint,
//             child: SizedBox(
//               height: MediaQuery.of(context).size.height,
//               child: Column(
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Tooltip(
//                         message: localizedStrings.gBtnAdd,
//                         child: CustomOutlinedButton(
//                           btnWidth: 0,
//                           btnHeight: 40,
//                           icon: Icons.add_circle_outline,
//                           text: '', // localizedStrings.gBtnAdd,
//                           onPressed: isTesting ||
//                                   isRename ||
//                                   isDel ||
//                                   isComSetting ||
//                                   isAddScale
//                               ? null
//                               : () {
//                                   setState(() {
//                                     selScaleId = -1;
//                                     isRename = false;
//                                     isAddScale = true;
//                                     ipCtl.text = "";
//                                     snCtl.text = "";
//                                     portCtl.text = "";
//                                   });
//                                 },
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 20,
//                       ),
//                       Tooltip(
//                         message: localizedStrings.gBtnDelete,
//                         child: CustomOutlinedButton(
//                           btnWidth: 0,
//                           btnHeight: 40,
//                           icon: Icons.delete_outline,
//                           text: '', //localizedStrings.gBtnDelete,
//                           onPressed: (isAddScale || isTesting) ||
//                                   (selScaleId == myDefScaleInfo.defScaleId!) ||
//                                   selScaleId == 1 ||
//                                   isRename ||
//                                   isDel
//                               ? null
//                               : () {
//                                   setState(() {
//                                     isDel = true;
//                                     delScale();
//                                   });
//                                 },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   showComScale(),
//                   showNetScaleList(),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 7,
//             child: Row(
//               children: [
//                 Container(
//                   width: 2,
//                   color: Theme.of(context).colorScheme.primary, // 蓝色分隔条颜色
//                 ),
//                 selScaleId == 1
//                     ? showSerialScaleInfo()
//                     : showDetailScaleInfo(), //网络秤
//               ],
//             ),
//           ),
//         ]));
//   }

//   Widget showSerialScaleInfo() {
//     return Expanded(
//       child: SizedBox(
//         width: double.infinity,
//         child: LayoutBuilder(
//             builder: (BuildContext context, BoxConstraints constraints) {
//           return ListView(
//             children: [
//               SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CustomOutlinedButton(
//                     btnWidth: constraints.maxWidth / 10,
//                     btnHeight: 40,
//                     icon: Icons.close_sharp,
//                     text: localizedStrings.gBtnCloseSerialPort,
//                     onPressed: isClosePort || isComSetting || comPort == refresh
//                         ? null
//                         : () {
//                             PublicFunctions.closeSerialPort(1);
//                             setState(() {
//                               isClosePort = true;
//                             });
//                           },
//                   ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   CustomOutlinedButton(
//                     btnWidth: constraints.maxWidth / 10,
//                     btnHeight: 40,
//                     icon: Icons.check_circle_outline,
//                     text: localizedStrings.gBtnOpenSerialPort,
//                     onPressed:
//                         !isClosePort || isComSetting || comPort == refresh
//                             ? null
//                             : () {
//                                 PublicFunctions.openSerialPort(1);
//                                 setState(() {
//                                   isClosePort = false;
//                                 });
//                               },
//                   ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   CustomOutlinedButton(
//                     btnWidth: constraints.maxWidth / 10,
//                     btnHeight: 40,
//                     icon: Icons.arrow_forward_ios,
//                     text: localizedStrings.gBtnConnect,
//                     onPressed: isClosePort || isComSetting || comPort == refresh
//                         ? null
//                         : () {
//                             if (myCurrentPort.devPath != '') {
//                               setState(() {
//                                 serialPortConnect = '';
//                                 isComSetting = true;
//                               });
//                               modifyComInfo();
//                             }
//                           },
//                   ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   CustomOutlinedButton(
//                     btnWidth: constraints.maxWidth / 10,
//                     btnHeight: 40,
//                     icon: Icons.edit,
//                     text: localizedStrings.scale_mgr_btn_rename,
//                     onPressed: isClosePort ||
//                             isAddScale ||
//                             isTesting ||
//                             isDel ||
//                             isComSetting
//                         ? null
//                         : () {
//                             setState(() {
//                               isRename = true;
//                               isAddScale = false;
//                               isComSetting = true;
//                             });
//                           },
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               showScaleName(constraints.maxWidth),
//               const SizedBox(
//                 height: 10,
//               ),
//               showModelName(constraints.maxWidth),
//               const SizedBox(
//                 height: 10,
//               ),
//               showScaleSn(constraints.maxWidth),
//               const SizedBox(
//                 height: 10,
//               ),
//               showPortInfo(constraints.maxWidth),
//               const SizedBox(
//                 height: 10,
//               ),
//               showBaudInfo(constraints.maxWidth),
//               const SizedBox(
//                 height: 10,
//               ),
//               showParityInfo(constraints.maxWidth),
//               const SizedBox(
//                 height: 10,
//               ),
//               showStopBitsInfo(constraints.maxWidth),
//               const SizedBox(
//                 height: 10,
//               ),
//               showDataBitsInfo(constraints.maxWidth),
//               const SizedBox(
//                 height: 10,
//               ),
//               showConfirmRow(),
//             ],
//           );
//         }),
//       ),
//     );
//   }

//   void modifyComInfo() {
//     _stopTimer();

//     String infoString = jsonEncode(tempCurrentPort);
//     myMediaConf.mediaInfoJson = infoString;
//     myMediaConf.type = myDevicedata.mediaType;
//     myModifyScale.scaleId = 1;
//     myModifyScale.scaleModel = scaleModel;
//     myModifyScale.mediaConf = myMediaConf;
//     PublicFunctions.sendModifyInfo(jsonEncode(myModifyScale));
//     myCurrentPort.devPath = tempCurrentPort.devPath;
//     myCurrentPort.baud = tempCurrentPort.baud;
//     myCurrentPort.dataBits = tempCurrentPort.dataBits;
//     myCurrentPort.parity = tempCurrentPort.parity;
//     myCurrentPort.stopBits = tempCurrentPort.stopBits;
//     myComScaleInfo.baudRate = tempCurrentPort.baud!;
//     myComScaleInfo.portName = tempCurrentPort.devPath!;
//   }

//   Widget showDataBitsInfo(double width) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 45,
//           width: width / 4,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               localizedStrings.gDataBits,
//               textAlign: TextAlign.right,
//               style: TextStyle(overflow: TextOverflow.ellipsis),
//             ),
//           ),
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         SizedBox(
//           width: width / 3,
//           height: 45,
//           child: ComPortDropdown(
//               1, dataBitsList, myCurrentPort.dataBits.toString()),
//         )
//       ],
//     );
//   }

//   Widget showStopBitsInfo(double width) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 45,
//           width: width / 4,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               localizedStrings.gStopBits,
//               textAlign: TextAlign.right,
//               style: TextStyle(overflow: TextOverflow.ellipsis),
//             ),
//           ),
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         SizedBox(
//           width: width / 3,
//           height: 45,
//           child: ComPortDropdown(2, stopBitsList, stopBitsList[0]),
//         )
//       ],
//     );
//   }

//   Widget showParityInfo(double width) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 45,
//           width: width / 4,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               localizedStrings.gSerialParity,
//               textAlign: TextAlign.right,
//               style: TextStyle(overflow: TextOverflow.ellipsis),
//             ),
//           ),
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         SizedBox(
//           width: width / 3,
//           height: 45,
//           child: ComPortDropdown(
//               4,
//               checkBitsList,
//               (myCurrentPort.parity == 0)
//                   ? (checkBitsList[0])
//                   : (myCurrentPort.parity == 1)
//                       ? (checkBitsList[1])
//                       : (myCurrentPort.parity == 2)
//                           ? (checkBitsList[2])
//                           : checkBitsList[0]),
//         )
//       ],
//     );
//   }

//   Widget showBaudInfo(double width) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 45,
//           width: width / 4,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               localizedStrings.gBaudRate,
//               textAlign: TextAlign.right,
//               style: TextStyle(overflow: TextOverflow.ellipsis),
//             ),
//           ),
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         SizedBox(
//             width: width / 3,
//             height: 45,
//             child:
//                 ComPortDropdown(3, baudRateList, myCurrentPort.baud.toString()))
//       ],
//     );
//   }

//   Widget showPortInfo(double width) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 45,
//           width: width / 4,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               localizedStrings.gSerialPort,
//               textAlign: TextAlign.right,
//               style: TextStyle(overflow: TextOverflow.ellipsis),
//             ),
//           ),
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         SizedBox(
//           width: width / 3,
//           height: 45,
//           child: DropdownButtonFormField<String>(
//             isExpanded: true,
//             decoration: const InputDecoration(border: OutlineInputBorder()),
//             // 设置默认值
//             value: (comLists.isEmpty) ? refresh : comPort,
//             // 选择回调
//             onChanged: (String? newPosition) {
//               PublicFunctions.getPortList();
//               checkPortList();
//               comPort = newPosition.toString();
//               if (comPort != localizedStrings.gTipRefreshPort) {
//                 tempCurrentPort.devPath = comPort;
//               } else {
//                 tempCurrentPort.devPath = '';
//               }
//             },
//             // 传入可选的数组
//             items: (comLists.isEmpty)
//                 ? [refresh].map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem(value: value, child: Text(value));
//                   }).toList()
//                 : comLists.map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem(value: value, child: Text(value));
//                   }).toList(),
//           ),
//         )
//       ],
//     );
//   }

//   Widget showDetailScaleInfo() {
//     return Expanded(
//         child: SizedBox(
//             width: double.infinity,
//             child: LayoutBuilder(
//                 builder: (BuildContext context, BoxConstraints constraints) {
//               return ListView(
//                 children: [
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   buttonRow(),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   _buildProcess(),
//                   const SizedBox(
//                     height: 50,
//                   ),
//                   if (!isAddScale) showScaleName(constraints.maxWidth),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   showModelName(constraints.maxWidth),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   showScaleSn(constraints.maxWidth),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   if (selScaleId != 1) showIpAddr(constraints.maxWidth),
//                   if (selScaleId != 1)
//                     const SizedBox(
//                       height: 20,
//                     ),
//                   if (selScaleId != 1) showPort(constraints.maxWidth),
//                   if (selScaleId != 1)
//                     const SizedBox(
//                       height: 20,
//                     ),
//                   showConfirmRow(),
//                 ],
//               );
//             })));
//   }

//   void checkPortList() {
//     if (myComInfoList.msgBody!.isEmpty) {
//       comLists = [];
//       comPort = refresh;
//       // tempCurrentPort.devPath = '';
//     } else {
//       comLists = myComInfoList.msgBody!.toList();

//       for (var i = 0; i < comLists.length; i++) {
//         if (comLists[i] == myCurrentPort.devPath) {
//           comPort = myCurrentPort.devPath!;
//           return;
//         }
//       }

//       comPort = comLists[0];
//       myCurrentPort.devPath = comPort; //20240221@F
//     }
//   }

//   bool validateIpFlag(String value) {
//     bool isValid = false;

//     setState(() {
//       if (value != '') {
//         isValid = ipRegex.hasMatch(value);
//         isValid = _isValidIpAddress(isValid, value);
//       } else {
//         isValid = true;
//       }
//     });
//     return isValid;
//   }

//   Widget showConfirmRow() {
//     return isRename || isAddScale
//         ? Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CustomOutlinedButton(
//                 btnWidth: 120,
//                 btnHeight: 40,
//                 icon: Icons.arrow_forward_ios,
//                 text: localizedStrings.gBtnConfirm,
//                 onPressed: (isAddScale &&
//                             ipCtl.text.isNotEmpty &&
//                             portCtl.text.isNotEmpty &&
//                             _isValidIP) ||
//                         (isRename && _isModifyName)
//                     ? () {
//                         if (isAddScale) {
//                           addScale();
//                         } else if (isRename) {
//                           modifyScaleName();
//                           _isEditing = true;
//                         }
//                       }
//                     : null,
//               ),
//               const SizedBox(width: 20),
//               CustomOutlinedButton(
//                 btnWidth: 120,
//                 btnHeight: 40,
//                 icon: Icons.exit_to_app,
//                 text: localizedStrings.gBtnCancel,
//                 onPressed: () {
//                   setState(() {
//                     isAddScale = false;
//                     isRename = false;
//                     selScaleId = myDefScaleInfo.defScaleId!;
//                     if (selScaleId == 1) {
//                       scaleNameCtl.text = myComScaleInfo.scaleName;
//                     } else {
//                       defNetScaleInfo = NetScaleListMgr.findScaleInfo(
//                           myNetScaleList, myDefScaleInfo.defScaleId!);
//                       scaleNameCtl.text = defNetScaleInfo.scaleName!;
//                     }
//                     if (isComSetting) {
//                       isComSetting = false;
//                     }
//                   });
//                 },
//               ),
//             ],
//           )
//         : const SizedBox();
//   }

//   Widget showPort(double width) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 45,
//           width: width / 4,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               'Port:',
//               textAlign: TextAlign.right,
//               style: TextStyle(overflow: TextOverflow.ellipsis),
//             ),
//           ),
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         SizedBox(
//           width: width / 3,
//           height: 45,
//           child: TextField(
//             enabled: isAddScale ? true : false,
//             controller: portCtl,
//             textAlign: TextAlign.start,
//             textAlignVertical: TextAlignVertical.center,
//             maxLines: 1,
//             inputFormatters: [
//               LengthLimitingTextInputFormatter(20),
//               FilteringTextInputFormatter.allow(RegExp(
//                   r'^([1-9]|[1-9]\d|[1-9]\d{2}|[1-9]\d{3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$')), // 允许输入数字
//             ],
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(4)),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget showIpAddr(double width) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 45,
//           width: width / 4,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               localizedStrings.gIpAddress,
//               textAlign: TextAlign.right,
//               style: const TextStyle(overflow: TextOverflow.ellipsis),
//             ),
//           ),
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         SizedBox(
//           width: width / 3,
//           height: 45,
//           child: TextField(
//             enabled: isAddScale ? true : false,
//             controller: ipCtl,
//             textAlign: TextAlign.start,
//             textAlignVertical: TextAlignVertical.center,
//             maxLines: 1,
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(4)),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget showScaleSn(double width) {
//     return isAddScale
//         ? const SizedBox()
//         : Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 45,
//                 width: width / 4,
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: Text(
//                     'SN:',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(overflow: TextOverflow.ellipsis),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 width: 20,
//               ),
//               SizedBox(
//                 width: width / 3,
//                 height: 45,
//                 child: TextField(
//                   enabled: false,
//                   controller: snCtl,
//                   textAlign: TextAlign.start,
//                   textAlignVertical: TextAlignVertical.center,
//                   maxLines: 1,
//                   inputFormatters: [
//                     LengthLimitingTextInputFormatter(20),
//                     FilteringTextInputFormatter.allow(RegExp(
//                         r'^[ -~!@#$%^&*()_+<>?:"{},.\/;]+$')), // 允许输入数字和点
//                   ],
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(4)),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           );
//   }

//   Widget showModelName(double width) {
//     return isAddScale
//         ? const SizedBox()
//         : Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 45,
//                 width: (width / 4),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: Text(
//                     localizedStrings.gModelName + ":",
//                     textAlign: TextAlign.right,
//                     style: TextStyle(overflow: TextOverflow.ellipsis),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 width: 20,
//               ),
//               SizedBox(
//                 width: width / 3,
//                 height: 45,
//                 child: TextField(
//                   enabled: false,
//                   style: const TextStyle(
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   controller: scaleModelCtl,
//                   textAlign: TextAlign.start,
//                   textAlignVertical: TextAlignVertical.center,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(4)),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           );
//   }

//   Widget showScaleName(double width) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 45,
//           width: width / 4,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               localizedStrings.gScaleName + ":",
//               textAlign: TextAlign.right,
//               style: TextStyle(overflow: TextOverflow.ellipsis),
//             ),
//           ),
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         SizedBox(
//           width: width / 3,
//           height: 45,
//           child: TextField(
//             style: const TextStyle(
//               overflow: TextOverflow.ellipsis,
//             ),
//             controller: scaleNameCtl,
//             maxLines: 1,
//             minLines: 1,
//             inputFormatters: [
//               LengthLimitingTextInputFormatter(30),
//             ],
//             textAlign: TextAlign.start,
//             textAlignVertical: TextAlignVertical.center,
//             readOnly: !isRename,
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(4)),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget buttonRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CustomOutlinedButton(
//           btnWidth: 80,
//           btnHeight: 40,
//           icon: Icons.edit,
//           text: localizedStrings.scale_mgr_btn_rename,
//           onPressed: isAddScale || isTesting || isDel || isComSetting
//               ? null
//               : () {
//                   setState(() {
//                     isRename = true;
//                     isAddScale = false;
//                   });
//                 },
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         // CustomOutlinedButton(
//         //   btnWidth: 120,
//         //   btnHeight: 40,
//         //   icon: Icons.scale_outlined,
//         //   text: "Set Default",
//         //   onPressed: (selScaleId == myDefScaleInfo.defScaleId! ||
//         //           selScaleId == -1 ||
//         //           isDel)
//         //       ? null
//         //       : () {
//         //           setState(() {
//         //             DefScaleInfo.getDefScaleInfo(selScaleId);
//         //           });
//         //         },
//         // ),
//         // const SizedBox(
//         //   width: 20,
//         // ),
//         CustomElevatedButton(
//           btnWidth: 120,
//           btnHeight: 40,
//           icon: Icons.connect_without_contact,
//           text: localizedStrings.scale_mgr_btn_test,
//           onPressed: !isAddScale && !isTesting && !isDel && !isComSetting
//               ? () {
//                   PublicFunctions.checkSerialPort(selScaleId);
//                   setState(() {
//                     isTesting = true;
//                   });
//                 }
//               : null,
//         ),
//       ],
//     );
//   }

//   void addScale() {
//     myNetInfo.ip = ipCtl.text;
//     myNetInfo.port = int.tryParse(portCtl.text)!;
//     String netInfoStr = jsonEncode(myNetInfo);
//     myMediaConf.mediaInfoJson = netInfoStr;
//     myMediaConf.type = 1;
//     myAddNetScale.scaleId = 10;
//     myAddNetScale.scaleModel = 'TMax';
//     myAddNetScale.mediaConf = myMediaConf;
//     PublicFunctions.sendAddScale(jsonEncode(myAddNetScale));
//   }

//   bool isValidScaleName(String name) {
//     if (scaleNameCtl.text == "ComScale") {
//       return false;
//     }
//     for (NetScaleInfoLocal scaleInfo in myNetScaleList) {
//       if (scaleInfo.scaleName == scaleNameCtl.text) {
//         return false;
//       }
//     }
//     return true;
//   }

//   void modifyScaleName() {
//     myModifyScaleName.scaleId = selScaleId;
//     myModifyScaleName.scaleName = scaleNameCtl.text;
//     PublicFunctions.sendModifyScaleName(jsonEncode(myModifyScaleName));
//     changeScaleName(myModifyScaleName.scaleId!, myModifyScaleName.scaleName!);
//     setState(() {
//       isRename = false;
//     });
//   }

//   void changeScaleName(int scaleId, String scaleName) {
//     if (scaleId == 1) {
//       setState(() {
//         myComScaleInfo.scaleName = scaleName;
//       });

//       return;
//     }
//     NetScaleInfoLocal tempScale = NetScaleInfoLocal();
//     tempScale = NetScaleListMgr.findScaleInfo(myNetScaleList, scaleId);
//     NetScaleListMgr.updateScale(myNetScaleList, tempScale);
//     setState(() {
//       for (int i = 0; i < scaleNetItems.length; i++) {
//         if (scaleNetItems[i].scaleId == scaleId) {
//           scaleNetItems[i].scaleName = scaleName;
//         }
//       }
//     });
//   }

//   void delScale() {
//     DelScaleInfo delScale = DelScaleInfo();
//     delScale.scaleId = selScaleId;
//     String delStr = jsonEncode(delScale);
//     PublicFunctions.sendDelScale(delStr);
//   }

//   Widget showComScale() {
//     return ListTile(
//       selected: selScaleId == myComScaleInfo.scaleId,
//       dense: true,
//       title: Tooltip(
//         richMessage: TextSpan(
//           text: '${myComScaleInfo.portName}\r\n\r\n',
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           children: <InlineSpan>[
//             TextSpan(
//               text:
//                   'Model:${myComScaleInfo.scaleModel == "TMax" ? "" : myComScaleInfo.scaleModel}\r\nSN:${myComScaleInfo.scaleModel == "TMax" ? "" : myComScaleInfo.scaleSn}\r\nPort:${myComScaleInfo.baudRate}',
//               style:
//                   const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//             ),
//           ],
//         ),
//         child: Text(
//           myComScaleInfo.scaleName,
//           maxLines: 1, // 设置文本最大行数为1
//           style: const TextStyle(
//             fontSize: 16,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ),
//       subtitle: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           SizedBox(
//               width: 100,
//               child: Text(
//                 myComScaleInfo.isOnline
//                     ? localizedStrings.gTipOnline
//                     : localizedStrings.gTipOffline,
//                 maxLines: 1, // 设置文本最大行数为1
//                 style: TextStyle(
//                   fontSize: 14,
//                   overflow: TextOverflow.ellipsis,
//                   color: myComScaleInfo.isOnline
//                       ? Theme.of(context).colorScheme.onTertiaryFixedVariant
//                       : Theme.of(context).colorScheme.error,
//                 ),
//               )),
//           // SizedBox(
//           //   width: 100,
//           //   child: Text(
//           //     myComScaleInfo.scaleId == myDefScaleInfo.defScaleId!
//           //         ? "Default"
//           //         : "",
//           //     maxLines: 1, // 设置文本最大行数为1
//           //     style: const TextStyle(
//           //       fontSize: 14,
//           //       overflow: TextOverflow.ellipsis,
//           //     ),
//           //   ),
//           // )
//         ],
//       ),
//       selectedTileColor: Theme.of(context).colorScheme.primary,
//       trailing: const Icon(Icons.cable),
//       onTap: () {
//         if (!isTesting && !isAddScale && !isDel && !isComSetting && !isRename) {
//           setState(() {
//             selScaleId = myComScaleInfo.scaleId;
//             scaleModelCtl.text = myComScaleInfo.scaleModel;
//             snCtl.text = myComScaleInfo.scaleSn;
//             scaleNameCtl.text = myComScaleInfo.scaleName;
//             // 更新文本框中的值
//           });
//         }
//       },
//     );
//   }

//   Widget showNetScaleList() {
//     return Expanded(
//       child: ListView.builder(
//         itemCount: scaleNetItems.length,
//         itemBuilder: (context, index) {
//           return SizedBox(
//             child: Column(
//               children: [
//                 ListTile(
//                   selected: selScaleId == scaleNetItems[index].scaleId,
//                   dense: true,
//                   title: Tooltip(
//                     richMessage: TextSpan(
//                       text: '${scaleNetItems[index].ip!}\r\n\r\n',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                       children: <InlineSpan>[
//                         TextSpan(
//                           text:
//                               'Model:${scaleNetItems[index].scaleModel! == "TMax" ? "" : scaleNetItems[index].scaleModel!}\r\nSN:${scaleNetItems[index].scaleModel! == "TMax" ? "" : scaleNetItems[index].scaleSn!}\r\nPort:${scaleNetItems[index].port!}',
//                           style: const TextStyle(
//                               fontSize: 14, fontWeight: FontWeight.normal),
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       scaleNetItems[index].scaleName!,
//                       maxLines: 1, // 设置文本最大行数为1
//                       style: const TextStyle(
//                         fontSize: 16,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                   subtitle: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(
//                         width: 100,
//                         child: Text(
//                           scaleNetItems[index].isOnline!
//                               ? localizedStrings.gTipOnline
//                               : localizedStrings.gTipOffline,
//                           maxLines: 1, // 设置文本最大行数为1
//                           style: TextStyle(
//                             fontSize: 14,
//                             overflow: TextOverflow.ellipsis,
//                             color: scaleNetItems[index].isOnline!
//                                 ? Theme.of(context)
//                                     .colorScheme
//                                     .onTertiaryFixedVariant
//                                 : Theme.of(context).colorScheme.error,
//                           ),
//                         ),
//                       ),
//                       // SizedBox(
//                       //   width: 100,
//                       //   child: Text(
//                       //     scaleNetItems[index].scaleId ==
//                       //             myDefScaleInfo.defScaleId!
//                       //         ? "Default"
//                       //         : "",
//                       //     maxLines: 1, // 设置文本最大行数为1
//                       //     style: const TextStyle(
//                       //       fontSize: 14,
//                       //       overflow: TextOverflow.ellipsis,
//                       //     ),
//                       //   ),
//                       // )
//                     ],
//                   ),
//                   selectedTileColor: Theme.of(context).colorScheme.primary,
//                   trailing: const Icon(Icons.wifi),
//                   onTap: () {
//                     if (!isTesting &&
//                         !isAddScale &&
//                         !isDel &&
//                         !isComSetting &&
//                         !isRename) {
//                       setState(() {
//                         selScaleId = scaleNetItems[index].scaleId!;
//                         scaleModelCtl.text = scaleNetItems[index].scaleModel!;
//                         snCtl.text = scaleNetItems[index].scaleSn!;
//                         ipCtl.text = scaleNetItems[index].ip!;
//                         portCtl.text = scaleNetItems[index].port!.toString();
//                         scaleNameCtl.text = scaleNetItems[index].scaleName!;
//                         if (scaleModelCtl.text == "TMax") {
//                           scaleModelCtl.text = "";
//                           snCtl.text = "";
//                         }

//                         // 更新文本框中的值
//                       });
//                     }
//                   },
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void sendToCheckOnline() {
//     PublicFunctions.checkSerialPort(1);
//     if (myNetScaleList.isEmpty) {
//       return;
//     }
//     for (var i = 0; i < myNetScaleList.length; i++) {
//       PublicFunctions.checkSerialPort(myNetScaleList[i].scaleId!);
//     }
//   }

//   void _startTimer() {
//     checkIsOnlineTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       if (!isRename && !isDel && !isTesting && !_isEditing) {
//         sendToCheckOnline();
//       }
//     });
//   }

//   void _stopTimer() {
//     checkIsOnlineTimer?.cancel(); // 停止计时器
//   }

//   void sendStaticIpInfo(String ip, String gateway, String netmask) {
//     myScaleCmd.cmdMode = 'set_wifi_static_ip';
//     myStaticIpInfo.gateway = gateway;
//     myStaticIpInfo.ip = ip;
//     myStaticIpInfo.netmask = netmask;
//     myScaleCmd.cmdData = jsonEncode(myStaticIpInfo).toString();
//     PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
//     writelog(jsonEncode(myScaleCmd));
//   }

//   //等待进度条
//   Widget _buildProcess() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         isDel || isTesting
//             ? Center(
//                 child: CircularProgressIndicator(
//                   backgroundColor: Colors.transparent,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                       Theme.of(context).colorScheme.primary),
//                 ),
//               )
//             : const SizedBox(),
//       ],
//     );
//   }
// }
