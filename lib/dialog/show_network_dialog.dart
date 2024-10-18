import 'package:flutter/material.dart';

String connectionType = "";
TextEditingController deviceNum = TextEditingController();
TextEditingController ipaddress = TextEditingController();
TextEditingController deviceName = TextEditingController();
TextEditingController model = TextEditingController();

showAddNetworkDialog(BuildContext context) {
  return showDialog(
      barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            title: Container(
                color: Theme.of(context).colorScheme.primary,
                child: Row(
                  children: [
                    Icon(Icons.wifi,
                        color: Theme.of(context).colorScheme.onPrimary),
                    Text("网络连接",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary))
                  ],
                )),
            content: Container(
              height: 275,
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Text("Basic Information Settings"),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                                const SizedBox(height: 20),
                                const Text("IP地址："),
                                SizedBox(
                                  width: 200,
                                  height: 30,
                                  child: TextField(
                                    controller: ipaddress,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      // hintText: "请输入机种类型，如：ztp",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
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
                              ],
                            ),
                            const SizedBox(width: 60),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("端口号："),
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
                                const SizedBox(height: 20),
                                const Text("设备序列号："),
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
                                const SizedBox(height: 20),
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
                            "${deviceName.text},Icons.wifi";
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
