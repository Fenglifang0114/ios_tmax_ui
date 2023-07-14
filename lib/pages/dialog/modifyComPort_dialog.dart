import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/currentport_data.dart';
import 'package:t_max/data/modifyscale_data.dart';
import 'package:t_max/pages/dialog/showComPort_dialog.dart';
import '../../data/comport_data.dart';
import '../../data/device_data.dart';
import '../../data/downloadresponse.dart';
import '../../data/scalecmd_data.dart';
import '../../eventbus/eventbus.dart';
import '../../main.dart';
import '../widget/comdropdown.dart';
import '../widget/comportdorpdown.dart';

List<String> comLists = [];
String comPort = "";
// List<String> comPortList = ['COM1', 'COM2', 'COM3'];
List<String> baudRateList = [
  '115200',
  '57600',
  '19200',
  '14400',
  '9600',
  '4800',
  '2400'
];
List<String> dataBitsList = ['8', '7', '6', '5'];
List<String> stopBitsList = ['1', '1.5', '2'];
List<String> checkBitsList = ['None', 'Odd', 'Even'];
List<String> protocolList = ['Xon/Xoff', 'None', 'Rts/Cts', 'Dsr/Dtr'];
String dialogtype = "com";
String connectionType = "";
TextEditingController deviceNum =
    TextEditingController(text: myDevicedata.scaleSn);
TextEditingController deviceName =
    TextEditingController(text: myDevicedata.name);
TextEditingController model = TextEditingController();
TextEditingController description = TextEditingController();

modifyAddComPortDialog(BuildContext context) {
  getPortList();
  tempCurrentPort = myCurrentPort;
  return showDialog(
      barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            title: Container(
                color: Colors.blue.shade900,
                child: const Row(
                  children: [
                    Icon(Icons.usb, color: Colors.white),
                    Text("Device information modification",
                        style: TextStyle(color: Colors.white))
                  ],
                )),
            content: Container(
              height: 350,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 233, 232, 232)),
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        // const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 15),
                                const Text("Connection name:"),
                                SizedBox(
                                  width: 200,
                                  height: 30,
                                  child: TextField(
                                    controller: deviceName,
                                    maxLength: 20,
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    maxLines: 1,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      // hintText: "请输入机种类型，如：ztp",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      if (kDebugMode) {
                                        print(value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Text("Serial port:"),
                                ComDropdown(),
                                const SizedBox(height: 15),
                                const Text("Data bits:"),
                                ComPortDropdown(1, dataBitsList,
                                    myCurrentPort.dataBits.toString()),
                                const SizedBox(height: 15),
                                const Text("Stop bits:"),
                                ComPortDropdown(
                                    2,
                                    stopBitsList,
                                    (myCurrentPort.stopBits == 0)
                                        ? (stopBitsList[0])
                                        : (myCurrentPort.stopBits == 1)
                                            ? (stopBitsList[1])
                                            : (myCurrentPort.stopBits == 2)
                                                ? (stopBitsList[2])
                                                : stopBitsList[0]),
                                // const SizedBox(height: 15),
                              ],
                            ),
                            const SizedBox(width: 60),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 15),
                                const Text("Device Type:"),
                                SizedBox(
                                  width: 200,
                                  height: 30,
                                  child: TextField(
                                    controller: deviceName,
                                    maxLength: 20,
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    maxLines: 1,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      // hintText: "请输入机种类型，如：ztp",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      if (kDebugMode) {
                                        print(value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Text("Baud rate:"),
                                ComPortDropdown(3, baudRateList,
                                    myCurrentPort.baud.toString()),
                                const SizedBox(height: 15),
                                const Text("Parity"),
                                ComPortDropdown(
                                    4,
                                    checkBitsList,
                                    (myCurrentPort.parity == 0)
                                        ? (checkBitsList[0])
                                        : (myCurrentPort.parity == 1)
                                            ? (checkBitsList[1])
                                            : (myCurrentPort.parity == 2)
                                                ? (checkBitsList[2])
                                                : checkBitsList[0]),
                                // Dropdown(checkBitsList),
                                const SizedBox(height: 15),
                                const Text(""),
                                // Dropdown(protocolList),
                                Container(
                                  // child: DropdownButtonFormField<String>(
                                  //   isExpanded: true,

                                  //   // decoration: const InputDecoration(border: OutlineInputBorder()),
                                  //   // 设置默认值
                                  //   // value: protocolList[0],

                                  //   // 选择回调
                                  //   onChanged: (String? newPosition) {
                                  //     myComportdata.parity =
                                  //         newPosition.toString();
                                  //     if (kDebugMode) {
                                  //       print(myComportdata.parity);
                                  //     }
                                  //     setState(() {
                                  //       eventBus.fire(
                                  //           EventComportdata(myComportdata));
                                  //     });
                                  //   },
                                  //   // 传入可选的数组
                                  //   items: protocolList
                                  //       .map<DropdownMenuItem<String>>(
                                  //           (String value) {
                                  //     return DropdownMenuItem(
                                  //         value: value, child: Text(value));
                                  //   }).toList(),
                                  // ),
                                  height: 53,
                                  width: 200,
                                  padding: const EdgeInsets.all(0),
                                ),
                                // const SizedBox(height: 15),
                                // const Text(""),
                                // ElevatedButton(
                                //     onPressed: () {}, child: const Text("测试连接"))
                              ],
                            ),
                          ],
                        ),
                        // const SizedBox(height: 15),
                        // const Text("Device Id:"),
                        // SizedBox(
                        //   width: 465,
                        //   height: 30,
                        //   child: TextField(
                        //     controller: deviceNum,
                        //     maxLength: 20,
                        //     maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        //     maxLines: 1,
                        //     textAlignVertical: TextAlignVertical.top,
                        //     decoration: const InputDecoration(
                        //       counterText: "",
                        //       // hintText: "请输入机种类型，如：ztp",
                        //       border: OutlineInputBorder(),
                        //     ),
                        //     onChanged: (value) {
                        //       if (kDebugMode) {
                        //         print(value);
                        //       }
                        //     },
                        //   ),
                        // ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                      child: const Text("Ok"),
                      onPressed: () {
                        mySerialPortStatus.serialPortStatus = true;
                        eventBus
                            .fire(EventSerialPortStatus(mySerialPortStatus));
                        if (myCurrentPort.devPath != '') {
                          modifyComInfo();
                        }

                        // myDialogData.type = dialogtype;
                        // print(myDialogData.type);
                        // connectionType =
                        // deviceName.text.toString() + ",Icons.usb";
                        // 传值
                        Navigator.of(context).pop(connectionType);
                      }),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // to go back to screen after submitting
                      })
                ],
              )
            ],
          );
        }));
      });
}

void sendModifyInfo(String modifyString) {
  myScaleCmd.cmdMode = "modify_scale";
  myScaleCmd.cmdData = modifyString;
  if (kDebugMode) {
    print(jsonEncode(myScaleCmd));
  }
  MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
}

void getScaleList() {
  myScaleCmd.cmdMode = "get_scale_list";
  myScaleCmd.cmdData = "";
  MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
}

void modifyComInfo() {
  String infoString = jsonEncode(tempCurrentPort);
  myMediaConf.mediaInfoJson = infoString;
  myMediaConf.type = myDevicedata.mediaType;
  myModifyScale.scaleId = int.parse(myDevicedata.scaleID);
  myModifyScale.mediaConf = myMediaConf;
  String modifyInfoString = jsonEncode(myModifyScale);
  sendModifyInfo(modifyInfoString);
}
