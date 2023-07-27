import 'package:flutter/material.dart';

accountWarnDialog(BuildContext context) {
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
                      Icons.message,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text("提示信息！", style: TextStyle(color: Colors.white)),
                  ],
                )),
            content: const Text("对不起，您输入的密码不正确，\n请重新输入！"),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                      child: const Text("关闭"),
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
