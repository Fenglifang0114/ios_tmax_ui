import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';

import '../../pages/widget/themeColor.dart';

import 'dialog/register_dialog.dart';
import 'home_page.dart';
import 'widget/boxGradient.dart';
import 'widget/version.dart';

class TrialPage extends StatefulWidget {
  const TrialPage({Key? key}) : super(key: key);

  @override
  State<TrialPage> createState() => _TrialPageState();
}

class _TrialPageState extends State<TrialPage> {
  bool ischangepassword = true;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    //初始化
    // WebsocketManager.init();
  }

  @override
  void dispose() {
    //注销
    // WebsocketManager().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeColor(),
      home: Scaffold(
          // AppBar：相当于iOS 的导航栏
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: Offstage(
                child: AppBar(
              title: version(),
              //设置状态栏颜色渐变
              flexibleSpace:
                  Container(decoration: BoxDecoration(gradient: boxGradient())),
            )),
          ),
          body: ListView(
            children: [
              Container(
                height: _height,
                width: _width,
                decoration: BoxDecoration(gradient: boxGradient()),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: 400,
                        child: Card(
                          shadowColor: Colors.grey,
                          elevation: 40,
                          margin: const EdgeInsets.all(10),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                "Welcome",
                                style: TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                  "You can try this product for 7 days, \n remaining days: 5 days.",
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          registerDialog(context)
                                              .then((onValue) {});
                                        });
                                      },
                                      child:
                                          const Text("License this software")),
                                  const SizedBox(width: 40),
                                  ElevatedButton(
                                      onPressed: () {
                                        // MyApp.getSock().send('uicmd', "test");
                                        setState(() {
                                          setState(() {
                                            //跳转页面
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    //没有传值
                                                    builder: (context) =>
                                                        const HomePage()));
                                          });
                                        });
                                      },
                                      child: const Text("Start trial")),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 40),
                                  TextButton(
                                      onPressed: () {
                                        exit(0);
                                      },
                                      child: const Text("Exit"))
                                ],
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            width: 250,
                            child: Image.asset('images/tscale.png')),
                        const SizedBox(width: 100)
                      ],
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
