import 'package:flutter/material.dart';
import 'account_warn_dialog.dart';

TextEditingController userName = TextEditingController();
TextEditingController newPassword = TextEditingController();
TextEditingController lodPassword = TextEditingController();
TextEditingController confirmPassword = TextEditingController();
accountDialog(BuildContext context) {
  bool ispasswordChecked = true;
  bool ischangepassword = false;
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
                      Icons.lock_outline,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text("账号密码", style: TextStyle(color: Colors.white)),
                  ],
                )),
            content: Container(
              height: 280,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(
                          value: ispasswordChecked,
                          onChanged: (value) {
                            setState(() {
                              ispasswordChecked = value!;
                            });
                          }),
                      const Text("登录时需要密码验证")
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: ischangepassword,
                          onChanged: (value) {
                            setState(() {
                              ischangepassword = value!;
                            });
                          }),
                      const Text("修改密码")
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("用户名称"),
                          SizedBox(
                            width: 200,
                            height: 30,
                            child: TextField(
                              controller: userName,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                // hintText: "请输入机种类型，如：ztp",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const Text("新密码"),
                          SizedBox(
                            width: 200,
                            height: 30,
                            child: TextField(
                              controller: newPassword,
                              obscureText: true,
                              obscuringCharacter: '*',
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
                          const Text("旧密码"),
                          SizedBox(
                            width: 200,
                            height: 30,
                            child: TextField(
                              controller: lodPassword,
                              obscureText: true,
                              obscuringCharacter: '*',
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                // hintText: "请输入机种类型，如：ztp",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const Text("确认密码"),
                          SizedBox(
                            width: 200,
                            height: 30,
                            child: TextField(
                              controller: confirmPassword,
                              obscureText: true,
                              obscuringCharacter: '*',
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                // hintText: "请输入机种类型，如：ztp",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        accountWarnDialog(context).then((onValue) {});
                      },
                      child: const Text("确定")),
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
