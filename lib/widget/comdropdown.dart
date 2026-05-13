// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:t_max/data/cominfoslist_data.dart';
// import 'package:t_max/data/currentport_data.dart';

// import '../../data/scalecmd_data copy.dart';
// import '../../eventbus/eventbus.dart';
// import '../../functions/methods.dart';
// import '../../main.dart';

// // ignore: must_be_immutable
// class ComDropdown extends StatefulWidget {
//   ComDropdown({Key? key}) : super(key: key);
//   late List dropDownList = [];

//   @override
//   State<ComDropdown> createState() => DropdownState();
// }

// class DropdownState extends State<ComDropdown> {
//   late List<dynamic> dropDownList;
//   DropdownState({Key? key}) : super();

//   dynamic _eventbus1;
//   @override
//   void initState() {
//     super.initState();
//     checkPortList();
//     if (comLists.contains(myCurrentPort.devPath)) {
//       comPort = myCurrentPort.devPath.toString();
//     }

//     _eventbus1 = eventBus.on<EventComInfoList>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myComInfoList = event.obj;
//           checkPortList();
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _eventbus1.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 53,
//       width: 200,
//       padding: const EdgeInsets.all(0),
//       child: DropdownButtonFormField<String>(
//         isExpanded: true,
//         // decoration: const InputDecoration(border: OutlineInputBorder()),
//         // 设置默认值
//         value: comPort,
//         // 选择回调
//         onChanged: (String? newPosition) {
//           PublicFunctions.getPortList();
//           checkPortList();
//           comPort = newPosition.toString();
//           if (comPort != 'Refresh port') {
//             tempCurrentPort.devPath = comPort;
//           } else {
//             tempCurrentPort.devPath = '';
//           }

//           // setState(() {
//           //   checkPortList();
//           //   // eventBus.fire(EventDialogData(myDialogData));
//           // });
//         },
//         // 传入可选的数组
//         items: comLists.map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem(value: value, child: Text(value));
//         }).toList(),
//       ),
//     );
//   }

//   void checkPortList() {
//     if (myComInfoList.msgBody!.isEmpty == true) {
//       comLists = ["Refresh port"];
//       comPort = "Refresh port";
//       tempCurrentPort.devPath = '';
//     } else {
//       comLists = myComInfoList.msgBody!.toList();
//       if (!comLists.contains(comPort)) {
//         comPort = comLists[0];
//         myCurrentPort.devPath = comPort; //20230411@F
//       }
//     }
    
//   }
// }
