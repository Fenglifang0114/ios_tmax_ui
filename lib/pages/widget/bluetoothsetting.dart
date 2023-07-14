import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/scalecmd_data%20copy.dart';
import 'package:t_max/main.dart';
import '../../data/device_data.dart';
import '../addDevice_page.dart';

String connectionType = "";

TextEditingController deviceNum = TextEditingController();
TextEditingController deviceName =
    TextEditingController(text: myDevicedata.name);

setBlueToothDialog(BuildContext context) {
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
                    Icon(Icons.bluetooth, color: Colors.white),
                    Text("Device information modification",
                        style: TextStyle(color: Colors.white))
                  ],
                )),
            content: Container(
              height: 292,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Device name:"),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 400,
                                  height: 30,
                                  child: TextField(
                                    maxLines: 1,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(35),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[\x00-\xF]+$')),
                                    ],
                                    controller: deviceName,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      // hintText: "请输入机种类型，如：ztp",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
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
                      child: const Text("Set"),
                      onPressed: () {
                        sendBlueToothName();
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

void sendBlueToothName() {
  myScaleCmd.cmdMode = 'modify_bt_name';
  if (deviceName.text.isNotEmpty) {
    myScaleCmd.cmdData = deviceName.text;
    webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }
}
