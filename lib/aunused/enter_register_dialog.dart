import 'dart:io';
import 'package:flutter/material.dart';
import '../data/screen_mgr.dart';

TextEditingController computerid = TextEditingController();
TextEditingController license = TextEditingController();
TextEditingController newlicense = TextEditingController();
TextEditingController dateofExpiry = TextEditingController();

enterRegisterDialog(BuildContext context) {
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
                    Text("DC500 Trial version",
                        style: TextStyle(color: Colors.white)),
                  ],
                )),
            content: Container(
              height: 130,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  const Text(
                      "You can try this product for 7 days, \n remaining days: 5 days."),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      OutlinedButton(
                          child: const Text("License this software"),
                          onPressed: () {
                            myScreenMgr.isMainScreen = true;
                            Navigator.of(context).pop();
                          }),
                      const SizedBox(width: 30),
                      ElevatedButton(
                          child: const Text("Start trial"),
                          onPressed: () {
                            myScreenMgr.isMainScreen = true;
                            Navigator.of(context).pop();
                          })
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                      child: const Text("Exit"),
                      onPressed: () {
                        exit(0);
                      })
                ],
              )
            ],
          );
        }));
      });
}
