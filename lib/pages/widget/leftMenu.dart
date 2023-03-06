import 'package:flutter/material.dart';
import '../dialog/account_dialog.dart';
import '../dialog/launguage_dialog.dart';
import '../dialog/register_dialog.dart';
import '../home_page.dart';

leftMenu(BuildContext context) {
  return Column(
    children: [
      Expanded(
          child: ElevatedButton(
              onPressed: () {},
              child: Column(
                children: [
                  SizedBox(height: 30),
                  IconButton(
                      onPressed: () {
                        //跳转页面
                        Navigator.of(context).push(MaterialPageRoute(
                            //没有传值
                            builder: (context) => const HomePage()));
                      },
                      icon: Icon(Icons.home, color: Colors.white)),
                  IconButton(
                      onPressed: () {
                        registerDialog(context).then((onValue) {});
                      },
                      icon: Icon(Icons.app_registration, color: Colors.white)),
                  IconButton(
                      onPressed: () {
                        accountDialog(context).then((onValue) {});
                      },
                      icon: Icon(Icons.account_box, color: Colors.white)),
                  IconButton(
                      onPressed: () {
                        launguageDialog(context).then((onValue) {});
                      },
                      icon: Icon(Icons.language, color: Colors.white)),
                ],
              )))
    ],
  );
}
