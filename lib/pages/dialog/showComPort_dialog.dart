import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/conninfo_data.dart';
import 'package:t_max/data/conninfosport_data.dart';
import 'package:t_max/data/currentport_data.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/main.dart';
import '../../data/cominfoslist_data.dart';
import '../../data/comport_data.dart';
import '../../data/dialog_data.dart';
import '../../eventbus/eventbus.dart';

List<String> comLists = [];
String comPort = "";

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
List<String> parityList = ['None', 'Odd', 'Even'];
List<String> flowcontrolList = ['Xon/Xoff', 'None', 'Rts/Cts', 'Dsr/Dtr'];
String dialogtype = "com";
String connectionType = "";
TextEditingController deviceNum = TextEditingController();
TextEditingController deviceName = TextEditingController();
TextEditingController model = TextEditingController();
TextEditingController description = TextEditingController();

showAddComPortDialog(BuildContext context) {
  checkPortList();

  String dataBits = dataBitsList[0];
  String stopBits = stopBitsList[0];
  String parity = parityList[0];
  String flowControl = flowcontrolList[0];

  String baud = baudRateList[0];

  return showDialog(
      barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            title: Container(
                color: Colors.blue.shade900,
                child: Row(
                  children: const [
                    Icon(Icons.usb, color: Colors.white),
                    Text("串口连接", style: TextStyle(color: Colors.white))
                  ],
                )),
            content: Container(
              height: 465,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 233, 232, 232)),
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Text("Basic Information Settings"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Connection name:"),
                                SizedBox(
                                  width: 200,
                                  height: 30,
                                  child: TextField(
                                    controller: deviceName,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      // hintText: "请输入机种类型，如：ztp",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Text("串口："),
                                    const Text("        "),
                                    ElevatedButton(
                                        onPressed: () {
                                          getPortList();
                                          setState(() {
                                            checkPortList();
                                          });
                                        },
                                        child: const Text("刷新串口"))
                                  ],
                                ),
                                //const Text("串口："),
                                Container(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    // decoration: const InputDecoration(border: OutlineInputBorder()),
                                    // 设置默认值
                                    value: comPort,
                                    // 选择回调

                                    onChanged: (String? newPosition) {
                                      getPortList();
                                      checkPortList();
                                      comPort = newPosition.toString();
                                      setState(() {
                                        checkPortList();

                                        // eventBus.fire(
                                        //     EventComportdata(myComportdata));
                                      });
                                    },
                                    // 传入可选的数组
                                    items: comLists
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem(
                                          value: value, child: Text(value));
                                    }).toList(),
                                    validator: (String? value) {
                                      if (value == null) {
                                        return 'Must make a selection.';
                                      }
                                      return null;
                                    },
                                  ),
                                  height: 53,
                                  width: 200,
                                  padding: const EdgeInsets.all(0),
                                ),

                                const SizedBox(height: 15),
                                const Text("Data bits"),
                                Container(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    // decoration: const InputDecoration(border: OutlineInputBorder()),
                                    // 设置默认值
                                    value: dataBits,
                                    // 选择回调
                                    onChanged: (String? newPosition) {
                                      dataBits = newPosition.toString();
                                      setState(() {});
                                    },
                                    // 传入可选的数组
                                    items: dataBitsList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem(
                                          value: value, child: Text(value));
                                    }).toList(),
                                  ),
                                  height: 53,
                                  width: 200,
                                  padding: const EdgeInsets.all(0),
                                ),
                                // Dropdown(comPortList),
                                // const SizedBox(height: 15),
                                // const Text("数据位："),
                                // Dropdown(dataBitsList),
                                const SizedBox(height: 15),
                                const Text("Stop bits:"),
                                Container(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    // decoration: const InputDecoration(border: OutlineInputBorder()),
                                    // 设置默认值
                                    value: stopBits,
                                    // 选择回调
                                    onChanged: (String? newPosition) {
                                      stopBits = newPosition.toString();

                                      setState(() {
                                        // eventBus.fire(
                                        //     EventComportdata(myComportdata)
                                        //     );
                                      });
                                    },
                                    // 传入可选的数组
                                    items: stopBitsList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem(
                                          value: value, child: Text(value));
                                    }).toList(),
                                  ),
                                  height: 53,
                                  width: 200,
                                  padding: const EdgeInsets.all(0),
                                ),
                                // Dropdown(stopBitsList),
                                const SizedBox(height: 15),
                                const Text("Device ID:"),
                                SizedBox(
                                  width: 200,
                                  height: 30,
                                  child: TextField(
                                    controller: deviceNum,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    decoration: const InputDecoration(
                                      hintText:
                                          "Automatically retrieve serial number after refresh",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 60),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("机种类型："),
                                SizedBox(
                                  width: 200,
                                  height: 30,
                                  child: TextField(
                                    controller: model,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      // hintText: "请输入机种类型，如：ztp",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Text("波特率："),
                                // Dropdown(baudRateList),
                                Container(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    // decoration: const InputDecoration(border: OutlineInputBorder()),
                                    // 设置默认值
                                    value: baud,
                                    // 选择回调
                                    onChanged: (String? newPosition) {
                                      baud = newPosition.toString();
                                      setState(() {
                                        eventBus.fire(
                                            EventComportdata(myComportdata));
                                      });
                                    },
                                    // 传入可选的数组
                                    items: baudRateList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem(
                                          value: value, child: Text(value));
                                    }).toList(),
                                  ),
                                  height: 53,
                                  width: 200,
                                  padding: const EdgeInsets.all(0),
                                ),
                                const SizedBox(height: 15),
                                const Text("校验："),
                                // Dropdown(checkBitsList),
                                Container(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    // decoration: const InputDecoration(border: OutlineInputBorder()),
                                    // 设置默认值
                                    value: parityList[0],
                                    // 选择回调
                                    onChanged: (String? newPosition) {
                                      myComportdata.parity =
                                          newPosition.toString();
                                      setState(() {
                                        // eventBus.fire(
                                        //     EventComportdata(myComportdata));
                                      });
                                    },
                                    // 传入可选的数组
                                    items: parityList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem(
                                          value: value, child: Text(value));
                                    }).toList(),
                                  ),
                                  height: 53,
                                  width: 200,
                                  padding: const EdgeInsets.all(0),
                                ),
                                const SizedBox(height: 15),
                                const Text("Flow control:"),
                                // Dropdown(protocolList),
                                Container(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    // decoration: const InputDecoration(border: OutlineInputBorder()),
                                    // 设置默认值
                                    value: flowcontrolList[0],
                                    // 选择回调
                                    onChanged: (String? newPosition) {
                                      myComportdata.parity =
                                          newPosition.toString();
                                      if (kDebugMode) {
                                        print(myComportdata.parity);
                                      }
                                      setState(() {
                                        eventBus.fire(
                                            EventComportdata(myComportdata));
                                      });
                                    },
                                    // 传入可选的数组
                                    items: flowcontrolList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem(
                                          value: value, child: Text(value));
                                    }).toList(),
                                  ),
                                  height: 53,
                                  width: 200,
                                  padding: const EdgeInsets.all(0),
                                ),

                                const SizedBox(height: 15),
                                const Text(""),
                                ElevatedButton(
                                    onPressed: () {
                                      getPortList();
                                      setState(() {
                                        checkPortList();
                                      });
                                    },
                                    child: const Text("Refresh port"))
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                        FocusScope.of(context).unfocus();

                        myConnInfoSport.baud = int.parse(baud);
                        myConnInfoSport.dataBits = int.parse(dataBits);
                        myConnInfoSport.parity = parity;
                        myConnInfoSport.portName = comPort;
                        myConnInfoSport.stopbits = int.parse(stopBits);
                        myConnInfo.scaSn = deviceNum.text.toString();
                        myConnInfo.media = myConnInfoSport;
                        myConnInfo.description = deviceName.text.toString();
                        myConnInfo.modelName = model.text.toString();
                        myConnInfo.mediaType = 1;

                        // MyApp.sock.send('conninfo', jsonEncode(myConnInfo));
                        eventBus.fire(EventComportdata(myComportdata));
                        myDialogData.type = dialogtype;
                        connectionType =
                            deviceName.text.toString() + ",Icons.usb";
                        Navigator.of(context).pop(
                            connectionType); // to go back to screen after submitting
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

Future<void> _refresh() async {
  await Future.delayed(const Duration(seconds: 1), () {
    if (myComInfoList.msgBody!.isEmpty == true) {
      comLists = ["Refresh port"];
    } else {
      comLists = myComInfoList.msgBody!.toList();
    }
  });
}

void getPortList() {
  myScaleCmd.cmdMode = "get_port_list";
  myScaleCmd.cmdData = "";
  MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
}

void checkPortList() {
  if (myComInfoList.msgBody!.isEmpty == true) {
    comLists = ["Refresh port"];
    comPort = "Refresh port";
    tempCurrentPort.devPath = '';
  } else {
    comLists = myComInfoList.msgBody!.toList();
    if (!comLists.contains(comPort)) {
      comPort = comLists[0];
      myCurrentPort.devPath = comPort; //20230411@F
    }
  }
  // getPortList();
}

void getUIConf() {
  myScaleCmd.cmdMode = "get_ui_conf";
  myScaleCmd.cmdData = "";
  MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
}
