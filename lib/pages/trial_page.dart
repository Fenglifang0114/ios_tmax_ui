import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import '../../pages/widget/themeColor.dart';
import '../data/scalecmd_data copy.dart';
import '../main.dart';
import 'dialog/showComPort_dialog.dart';
import 'home_page.dart';
import 'widget/version.dart';

class TrialPage extends StatefulWidget {
  const TrialPage({Key? key}) : super(key: key);

  @override
  State<TrialPage> createState() => _TrialPageState();
}

class _TrialPageState extends State<TrialPage> {
  bool ischangepassword = true;
  bool isPass = false;
  String pId = '';
  String dueDate = '';
  late Timer timer;
  var _eventbus1;
  TextEditingController pidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pidController.text = 'Your PID is ';

    _eventbus1 = eventBus.on<EventLicenseData>().listen((event) {
      if (mounted) {
        setState(() {
          myLicenseData = event.obj;
          if (myLicenseData.data.isNotEmpty) {
            List<String> strList = myLicenseData.data.split(',');
            pId = strList[1]; // id
            dueDate = strList[2];
            if (strList[0] == 'true') {
              isPass = true;
            }
            setState(() {
              pidController.text = 'Your PID is $pId';
            });
          }
        });
      }
    });
    //初始化
    // WebsocketManager.init();
  }

  @override
  void dispose() {
    //注销
    // WebsocketManager().dispose();
    _eventbus1.dispose();
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
                // flexibleSpace:
                //     Container(decoration: BoxDecoration(gradient: boxGradient())),
              )),
            ),
            body: ListView(
              children: [
                Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/background_image.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: _height,
                      width: _width,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900.withOpacity(0.2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              width: 400,
                              child: Card(
                                shadowColor: Colors.grey,
                                elevation: 40,
                                margin: const EdgeInsets.all(10),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    const Text(
                                      "Welcome",
                                      style: TextStyle(fontSize: 40),
                                    ),
                                    const SizedBox(height: 30),
                                    TextField(
                                      controller: pidController,
                                      readOnly: true,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    // Text("Your PID is $pId",
                                    //     style: const TextStyle(fontSize: 20)),
                                    const SizedBox(height: 20),
                                    Text(
                                        (isPass)
                                            ? 'Authentication passed.\r\n'
                                            : " No authentication. \r\n Please send the PID to us.\r\nEmail:sales@taiwanscale.com",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: (isPass)
                                                ? Colors.green.shade900
                                                : Colors.red.shade900)),
                                    Text(
                                        (dueDate.isEmpty)
                                            ? ''
                                            : "Expiration date: $dueDate",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: (isPass)
                                                ? Colors.green.shade900
                                                : Colors.red.shade900)),
                                    const SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              // MyApp.getSock().send('uicmd', "test");
                                              setState(() {
                                                //跳转页面
                                                if (isPass) {
                                                  getScaleList();
                                                  getUIConf();
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return const HomePage(); //AddDevicePage();
                                                  }));
                                                } else {
                                                  exit(0);
                                                }
                                              });
                                            },
                                            child: Text(
                                                (isPass) ? "Start" : 'Exit')),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 100),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  width: 250,
                                  child: Image.asset('images/tscale.png')),
                              const SizedBox(width: 100)
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            )));
  }

  void getScaleList() {
    myScaleCmd.cmdMode = "get_scale_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  void getProductList() {
    myScaleCmd.cmdMode = "get_product_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }
}
