// import 'package:flutter/material.dart';
// import 'package:t_max/data/comscaleinfo_data.dart';
// import 'package:t_max/data/currentport_data.dart';

// import '../../data/device_data.dart';
// import '../../eventbus/eventbus.dart';

// // ignore: must_be_immutable
// class ReusableListItem extends StatefulWidget {
//   ReusableListItem(this.pill, {Key? key}) : super(key: key);
//   late String pill;

//   @override
//   State<ReusableListItem> createState() => _ReusableListItemState();
// }

// class _ReusableListItemState extends State<ReusableListItem> {
//   final List<Color> _color = [];

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.pill.toString().contains("null")) {
//       return Row();
//     }
//     List<String> pillParts = widget.pill.split(",");
//     String index = pillParts[0];
//     String content = pillParts[1];
//     String icons = pillParts[2];
//     String scaleId = pillParts[3];

//     while (
//         (int.parse(index) >= int.parse(myDevicedata.color.length.toString()))) {
//       myDevicedata.color.add(Colors.transparent);
//     }

//     if (icons == "") {
//       return Row();
//     }
//     return Container(
//       margin: const EdgeInsets.all(1),
//       child: Center(
//           child: Container(
//               decoration:
//                   BoxDecoration(color: myDevicedata.color[int.parse(index)]),
//               child: Row(
//                 children: [
//                   (icons == "Icons.usb")
//                       ? const Icon(Icons.usb, color: Color(0xff006e1a))
//                       : (icons == "Icons.usb_off")
//                           ? Icon(Icons.usb, color: Theme.of(context).colorScheme.error.shade900)
//                           : (icons == "Icons.device_unknown")
//                               ? const Icon(Icons.device_unknown,
//                                   color: Color.fromARGB(255, 240, 133, 0))
//                               : (icons == "Icons.wifi")
//                                   ? Icon(Icons.wifi,
//                                       color: Theme.of(context).colorScheme.primary)
//                                   : Icon(Icons.bluetooth,
//                                       color: Theme.of(context).colorScheme.primary),
//                   SizedBox(
//                     width: 135,
//                     height: 50,
//                     child: MaterialButton(
//                       hoverColor: const Color(0xFFD7E3FF),
//                       focusColor: const Color(0xFFD7E3FF),
//                       onPressed: () {
//                         setState(() {
//                           while ((int.parse(index) >=
//                               int.parse(_color.length.toString()))) {
//                             _color.add(Colors.transparent);
//                           }

//                           _color[int.parse(index)] = const Color(0xFFD7E3FF);
//                           myDevicedata.color = _color;
//                           myDevicedata.name = content;
//                           myDevicedata.type = icons;
//                           myDevicedata.index = index;
//                           myDevicedata.scaleID = scaleId;

//                           for (var i = 0;
//                               i < myComScaleList.comScaleList.length;
//                               i++) {
//                             var tmpScaleId = myComScaleList
//                                 .comScaleList[i].scaleId
//                                 .toString();
//                             if (tmpScaleId == myDevicedata.scaleID) {
//                               myCurrentPort.baud =
//                                   myComScaleList.comScaleList[i].baudRate;
//                               myCurrentPort.dataBits =
//                                   myComScaleList.comScaleList[i].dataBits;
//                               myCurrentPort.devPath =
//                                   myComScaleList.comScaleList[i].portName;
//                               myCurrentPort.parity =
//                                   myComScaleList.comScaleList[i].parity;
//                               myCurrentPort.stopBits =
//                                   myComScaleList.comScaleList[i].stopBits;
//                               myDevicedata.mediaType =
//                                   myComScaleList.comScaleList[i].tMedia;
//                               myDevicedata.scaleSn =
//                                   myComScaleList.comScaleList[i].scaleSn;
//                             }
//                           }
//                           eventBus.fire(EventDeviceName(myDevicedata));

//                           eventBus.fire(EventCurrentPort(myCurrentPort));
//                         });
//                       },
//                       child: (index == myDevicedata.index)
//                           ? Text(
//                               content,
//                               style: const TextStyle(
//                                   color: Color(0xff004a98), //字体颜色
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold),
//                             )
//                           : Text(
//                               content,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 // color: Theme.of(context).colorScheme.onPrimary, //字体颜色
//                                 fontWeight: FontWeight.bold, //字体粗细
//                               ),
//                             ),
//                     ),
//                   ),
//                 ],
//               ))),
//     );
//   }
// }
