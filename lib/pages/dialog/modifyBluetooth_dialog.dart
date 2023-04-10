import 'package:flutter/material.dart';
import '../../data/device_data.dart';
import '../widget/dropdown.dart';

String connectionType = "";
List<String> deviceList = ['设备1', '设备2', '设备3'];
TextEditingController deviceNum = TextEditingController();
TextEditingController deviceName =
    TextEditingController(text: myDevicedata.name);

modifyAddBluetoothDialog(BuildContext context) {
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
                    Icon(Icons.bluetooth, color: Colors.white),
                    Text("设备信息修改", style: TextStyle(color: Colors.white))
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
                          children: const [
                            Text("基本信息设置"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("连接名称："),
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
                                const SizedBox(height: 20),
                                const Text("可用设备："),
                                Dropdown(deviceList),
                                const SizedBox(height: 20),
                                const Text("设备编号："),
                                const SizedBox(
                                  width: 200,
                                  height: 30,
                                  child: TextField(
                                    // controller: deviceName,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: InputDecoration(
                                      // hintText: "请输入机种类型，如：ztp",
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
                                    controller: deviceNum,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      // hintText: "请输入机种类型，如：ztp",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 116),
                                const Text(""),
                                // ElevatedButton(
                                //     onPressed: () {}, child: const Text("测试连接"))
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
                      child: const Text("确定"),
                      onPressed: () {
                        connectionType =
                            deviceName.text.toString() + ",Icons.bluetooth";
                        Navigator.of(context).pop(
                            connectionType); // to go back to screen after submitting
                      }),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("取消"),
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
