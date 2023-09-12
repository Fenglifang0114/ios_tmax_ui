import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/eventbus/eventbus.dart';

import '../generated/l10n.dart';

import '../data/comscaleinfo_data.dart';
import '../data/currentport_data.dart';
import '../data/device_data.dart';
import '../functions/methods.dart';

import '../widget/theme_color.dart';
import '../widget/version.dart';
import 'home_page.dart';

class TrialPage extends StatefulWidget {
  const TrialPage({Key? key}) : super(key: key);

  @override
  State<TrialPage> createState() => TrialPageState();
}

class TrialPageState extends State<TrialPage> {
  bool ischangepassword = true;
  bool isPass = false;
  String pId = '';
  String dueDate = '';
  late Timer timer;
  dynamic _eventbus1;
  dynamic _eventbus2;
  TextEditingController pidController = TextEditingController();
  String system_id = '';

  @override
  void initState() {
    super.initState();
    pidController.text = system_id;

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
            pidController.text = system_id + pId;
          }
          if (isPass) {
            PublicFunctions.getScaleList();
            PublicFunctions.getUIConf();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const HomePage(); //AddDevicePage();
            }));
          }
        });
      }
    });
    _eventbus2 = eventBus.on<EventComScaleList>().listen((event) {
      if (mounted) {
        setState(() {
          myComScaleList = event.obj;
          if (myComScaleList.comScaleList.isNotEmpty) {
            myDevicedata.name = myComScaleList.comScaleList[0].scaleModel;
            myDevicedata.type = 'icons.usb';
            myDevicedata.scaleID =
                myComScaleList.comScaleList[0].scaleId.toString();
            myCurrentPort.baud = myComScaleList.comScaleList[0].baudRate;
            myCurrentPort.dataBits = myComScaleList.comScaleList[0].dataBits;
            myCurrentPort.devPath = myComScaleList.comScaleList[0].portName;
            myCurrentPort.parity = myComScaleList.comScaleList[0].parity;
            myCurrentPort.stopBits = myComScaleList.comScaleList[0].stopBits;
            myDevicedata.mediaType = myComScaleList.comScaleList[0].tMedia;
            myDevicedata.scaleSn = myComScaleList.comScaleList[0].scaleSn;
          }
        });
      }
    });
    //初始化
    // WebsocketManager.init();
  }

  dynamic localizedStrings;
  @override
  void dispose() {
    //注销
    // WebsocketManager().dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    system_id = localizedStrings.system_id;
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
                        color: Theme.of(context).colorScheme.background,
                        // decoration: BoxDecoration(
                        //   gradient: boxGradient(),
                        //   // image: DecorationImage(
                        //   //   image: AssetImage('images/background_image.jpg'),
                        //   //   fit: BoxFit.cover,
                        //   // ),
                        // ),
                      ),
                    ),
                    SizedBox(
                      height: _height,
                      width: _width,
                      // decoration: BoxDecoration(
                      //   color: Colors.blue.shade900.withOpacity(0.2),
                      // ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              width: 400,
                              child: Card(
                                shadowColor:
                                    const Color.fromARGB(255, 196, 201, 207),
                                elevation: 40,
                                margin: const EdgeInsets.all(10),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      localizedStrings.welcome,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    TextField(
                                      controller: pidController,
                                      readOnly: true,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    // Text("Your PID is $pId",
                                    //     style: const TextStyle(fontSize: 20)),
                                    const SizedBox(height: 20),
                                    Text(
                                        (isPass)
                                            ? localizedStrings.passed_message
                                            : localizedStrings
                                                .passed_fail_message,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: (isPass)
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Colors.red.shade900)),
                                    Text(
                                        (dueDate.isEmpty)
                                            ? ''
                                            : localizedStrings.expiration_date +
                                                dueDate,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: (isPass)
                                                ? Colors.green.shade900
                                                : Colors.red.shade900)),
                                    const SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton(
                                            onPressed: () {
                                              // MyApp.getSock().send('uicmd', "test");
                                              setState(() {
                                                //跳转页面
                                                if (isPass) {
                                                  PublicFunctions
                                                      .getScaleList();
                                                  PublicFunctions.getUIConf();
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
                                            child: Text((isPass)
                                                ? localizedStrings.button_start
                                                : localizedStrings
                                                    .button_exit)),
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
}
