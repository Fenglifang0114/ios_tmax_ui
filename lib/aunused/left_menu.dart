import 'package:flutter/material.dart';
import '../dialog/launguage_dialog.dart';
import '../dialog/register_dialog.dart';
import '../pages/home_page_config.dart';
import 'account_dialog.dart';

leftMenu(BuildContext context) {
  return Column(
    children: [
      Expanded(
          child: ElevatedButton(
              onPressed: () {},
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  IconButton(
                      onPressed: () {
                        //跳转页面
                        Navigator.of(context).push(MaterialPageRoute(
                            //没有传值
                            builder: (context) => const HomePage()));
                      },
                      icon: Icon(Icons.home,
                          color: Theme.of(context).colorScheme.onPrimary)),
                  IconButton(
                      onPressed: () {
                        registerDialog(context).then((onValue) {});
                      },
                      icon: Icon(Icons.app_registration,
                          color: Theme.of(context).colorScheme.onPrimary)),
                  IconButton(
                      onPressed: () {
                        accountDialog(context).then((onValue) {});
                      },
                      icon: Icon(Icons.account_box,
                          color: Theme.of(context).colorScheme.onPrimary)),
                  IconButton(
                      onPressed: () {
                        launguageDialog(context).then((onValue) {});
                      },
                      icon: Icon(Icons.language,
                          color: Theme.of(context).colorScheme.onPrimary)),
                ],
              )))
    ],
  );
}
