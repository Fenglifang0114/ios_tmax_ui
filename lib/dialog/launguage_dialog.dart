import 'package:flutter/material.dart';
import '../widget/dropdown.dart';

List<String> launguage = ['简体中文', 'Русский', 'English'];

launguageDialog(BuildContext context) {
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
                    Text("语言设置", style: TextStyle(color: Colors.white)),
                  ],
                )),
            content: Container(
              height: 200,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("当前语言："),
                      const SizedBox(width: 50),
                      Container(
                          height: 53,
                          width: 200,
                          padding: const EdgeInsets.all(0),
                          child: const Text("简体中文")),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("切换语言："),
                      const SizedBox(width: 50),
                      Dropdown(launguage)
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
                        Navigator.of(context).pop();
                        //此处处理语言切换操作
                      },
                      child: const Text("确定")),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("取消"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              )
            ],
          );
        }));
      });
}
