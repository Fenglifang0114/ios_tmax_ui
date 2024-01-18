import 'package:flutter/material.dart';
import '../../pages/login_page.dart';
import '../data/screen_mgr.dart';
import '../dialog/launguage_dialog.dart';
import '../dialog/register_dialog.dart';
import 'account_dialog.dart';
import 'enter_register_dialog.dart';

leftSidebar(BuildContext context) {
  return Drawer(
    child: ListView(
      ///edit start
      padding: EdgeInsets.zero,

      ///edit end
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromARGB(126, 18, 51, 169),
          ),
          child: Center(
            child: SizedBox(
              width: 100.0,
              height: 100.0,
              child: CircleAvatar(
                child: Text('DC500'),
              ),
            ),
          ),
        ),
        ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Trial'),
            onTap: () {
              myScreenMgr.isMainScreen = true;
              Navigator.of(context).pop(); //隐藏侧边栏
              enterRegisterDialog(context).then((onValue) {});
            }),
        ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Register'),
            onTap: () {
              myScreenMgr.isMainScreen = true;
              Navigator.of(context).pop(); //隐藏侧边栏
              registerDialog(context).then((onValue) {});
            }),
        ListTile(
            leading: const Icon(Icons.account_box),
            title: const Text('Account and password'),
            onTap: () {
              myScreenMgr.isMainScreen = true;
              Navigator.of(context).pop(); //隐藏侧边栏
              accountDialog(context).then((onValue) {});
            }),
        ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language settings'),
            onTap: () {
              myScreenMgr.isMainScreen = true;
              Navigator.of(context).pop(); //隐藏侧边栏
              launguageDialog(context).then((onValue) {});
            }),
        ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () {
              myScreenMgr.isMainScreen = true;
              Navigator.of(context).pop(); //隐藏侧边栏
              //跳转页面
              Navigator.of(context).push(MaterialPageRoute(
                  //没有传值
                  builder: (context) => const LoginPage()));
            }),
      ],
    ),
  );
}
