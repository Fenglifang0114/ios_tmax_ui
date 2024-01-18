import 'package:flutter/material.dart';

import '../data/screen_mgr.dart';
import '../widget/dropdown.dart';

List<String> firstField = ['简体中文', '繁体中文', 'English'];
List<String> secondField = ['简体中文', '繁体中文', 'English'];
List<String> thirdField = ['简体中文', '繁体中文', 'English'];
List<String> fourthField = ['简体中文', '繁体中文', 'English'];
List<String> fifthField = ['简体中文', '繁体中文', 'English'];
List<String> sixthField = ['简体中文', '繁体中文', 'English'];
List<String> seventhField = ['简体中文', '繁体中文', 'English'];
List<String> eighthField = ['简体中文', '繁体中文', 'English'];
List<String> ninthField = ['简体中文', '繁体中文', 'English'];
List<String> tenthField = ['简体中文', '繁体中文', 'English'];
fieldModifyDialog(BuildContext context) {
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
                    Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text("报表字段修改", style: TextStyle(color: Colors.white)),
                  ],
                )),
            content: Container(
              height: 300,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text("第一个字段："),
                      const SizedBox(width: 20),
                      Dropdown(firstField),
                      const SizedBox(width: 50),
                      const Text("第二个字段："),
                      const SizedBox(width: 20),
                      Dropdown(secondField)
                    ],
                  ),
                  Row(
                    children: [
                      const Text("第三个字段："),
                      const SizedBox(width: 20),
                      Dropdown(thirdField),
                      const SizedBox(width: 50),
                      const Text("第四个字段："),
                      const SizedBox(width: 20),
                      Dropdown(fourthField)
                    ],
                  ),
                  Row(
                    children: [
                      const Text("第五个字段："),
                      const SizedBox(width: 20),
                      Dropdown(fifthField),
                      const SizedBox(width: 50),
                      const Text("第六个字段："),
                      const SizedBox(width: 20),
                      Dropdown(sixthField)
                    ],
                  ),
                  Row(
                    children: [
                      const Text("第七个字段："),
                      const SizedBox(width: 20),
                      Dropdown(seventhField),
                      const SizedBox(width: 50),
                      const Text("第八个字段："),
                      const SizedBox(width: 20),
                      Dropdown(eighthField)
                    ],
                  ),
                  Row(
                    children: [
                      const Text("第九个字段："),
                      const SizedBox(width: 20),
                      Dropdown(ninthField),
                      const SizedBox(width: 50),
                      const Text("第十个字段："),
                      const SizedBox(width: 20),
                      Dropdown(tenthField)
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        myScreenMgr.isMainScreen = true;
                        Navigator.of(context).pop();
                      },
                      child: const Text("确定")),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("取消"),
                      onPressed: () {
                        myScreenMgr.isMainScreen = true;
                        Navigator.of(context).pop();
                      })
                ],
              )
            ],
          );
        }));
      });
}
