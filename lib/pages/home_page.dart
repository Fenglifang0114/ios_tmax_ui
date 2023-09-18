import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/pages/download_page.dart';
import 'package:t_max/pages/labeldesign_page.dart';

import 'package:t_max/pages/wifisetting_page.dart';
import '../data/comscaleinfo_data.dart';
import '../data/currentport_data.dart';
import '../data/device_data.dart';
import '../data/downloadresponse.dart';
import '../data/scalecmd_data.dart';
import '../dialog/language_setting.dart';
import '../dialog/waitingbuildtips.dart';
import '../functions/methods.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../widget/bluetoothsetting.dart';
import '../widget/box_gradient.dart';
import '../widget/customcard.dart';
import '../dialog/license_info.dart';
import '../widget/show_weight_report.dart';
import '../widget/update_firmware.dart';

import '../widget/version.dart';
import 'modify_com_port_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> items = [];
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  List<DataRow> dataRows = [];

  late ScrollController _pageScrollerController;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  bool isComConnected = false;
  Timer? _timer;
  Timer? _checkTimer;
  bool isTiming = false;

  String groupValue = 'zh';
  DateTime now = DateTime.now();

  List<Color> cardColors = List.generate(9, (index) => Colors.white);
  List<Color> textColors = List.generate(9, (index) => Colors.blue.shade900);
  List<Widget> targetPages = [
    const ModifyComPortPage(), // 第一个Card对应的目标界面
    const LabelDesignPage(), // 第二个Card对应的目标界面
    const WifiSettingPage(), // 第三个Card对应的目标界面
    const LabelDesignPage(), // 第一个Card对应的目标界面
    const LabelDesignPage(), // 第二个Card对应的目标界面
    const ShowWeightReport(), // 第三个Card对应的目标界面
    // ...
  ];

  List<String> imagePaths = [
    'images/11.png',
    'images/12.png',
    'images/13.png',
    'images/14.png',
    'images/15.png',
    'images/16.png',
  ];

  // 初始文字颜色

  @override
  void initState() {
    super.initState();
    _pageScrollerController = ScrollController();
    _startTimer(5);
    _checkTimerFuc(5);
    _eventbus1 = eventBus.on<EventDialogData>().listen((event) {
      if (mounted) {
        setState(() {
          myDialogData = event.obj;
        });
      }
    });
    setState(() {
      now = DateTime.now();
    });
    _eventbus2 = eventBus.on<EventComScaleList>().listen((event) {
      if (mounted) {
        setState(() {
          myComScaleList = event.obj;
          if (myComScaleList.comScaleList.isNotEmpty) {
            myDevicedata.name = myComScaleList.comScaleList[0].scaleModel;
            myDevicedata.type = 'icons.usb';
            myComScaleList.comScaleList[0].scaleId.toString();
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

    _eventbus3 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        setState(() {
          myRespCheckSerialPort = event.obj;
          if (myRespCheckSerialPort.msgBody == 'ok') {
            isComConnected = true;
          } else {
            isComConnected = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _pageScrollerController.dispose();
    super.dispose();
  }

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  Widget build(BuildContext context) {
    List<String> titleNames = [
      localizedStrings.home_page_title1,
      localizedStrings.home_page_title2,
      localizedStrings.home_page_title3,
      localizedStrings.home_page_title4,
      localizedStrings.home_page_title5,
      localizedStrings.home_page_title6,
      localizedStrings.home_page_title7,
      localizedStrings.home_page_title8,
      localizedStrings.home_page_title9,
    ];
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    // final _height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  version(),
                  SizedBox(
                    width: 200,
                    child: Row(
                      children: [
                        Text('Serial port status:',
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary)),
                        const SizedBox(
                          width: 20,
                        ),
                        Icon(
                          Icons.circle,
                          color: (isComConnected)
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.error,
                        )
                      ],
                    ),
                  )
                ],
              ),
              //设置状态栏颜色渐变
              flexibleSpace:
                  Container(decoration: BoxDecoration(gradient: boxGradient())),
            )),
        body: SizedBox(
          height: _height,
          width: _width,
          // decoration: BoxDecoration(gradient: boxGradient()),
          child: ListView(
            // 水平拉伸
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                height: _height,
                width: _width,
                // decoration: BoxDecoration(gradient: boxGradient()),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomCard(
                              //修改串口
                              onTap: () {
                                stopCheckSerialPort();
                                setState(() {
                                  PublicFunctions.getProductList();
                                  PublicFunctions.getPortList();
                                  showComPortDialog(context);
                                });
                              },
                              title: titleNames[0],
                              cardColor: cardColors[0],
                              textColor: textColors[0],
                              // image: imagePaths[0],
                            ),
                            CustomCard(
                              //设计打印格式
                              onTap: myLicenseInfo.isValid
                                  ? () {
                                      stopCheckSerialPort();
                                      setState(() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  targetPages[1]),
                                        );
                                      });
                                    }
                                  : () {},
                              title: titleNames[1],
                              cardColor: myLicenseInfo.isValid
                                  ? cardColors[1]
                                  : Theme.of(context).colorScheme.background,
                              textColor: textColors[1],
                              // image: imagePaths[1],
                            ),
                            CustomCard(
                              //WIFI
                              onTap: () {
                                setState(() {
                                  stopCheckSerialPort();
                                  PublicFunctions.getWifiList();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => targetPages[2]),
                                  );
                                });
                              },
                              title: titleNames[2],
                              cardColor: cardColors[2],
                              textColor: textColors[2],
                              // image: imagePaths[2],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomCard(
                              //蓝牙
                              onTap: () {
                                setState(() {
                                  stopCheckSerialPort();
                                  showBluetoothDialog(context);
                                });
                              },
                              title: titleNames[3],
                              cardColor: cardColors[3],
                              textColor: textColors[3],
                              // image: imagePaths[3],
                            ),
                            CustomCard(
                              //更新软件
                              onTap: () {
                                setState(() {
                                  stopCheckSerialPort();
                                  showUpdateFirmWareDialog(context);
                                });
                              },
                              title: titleNames[4],
                              cardColor: cardColors[4],
                              textColor: textColors[4],
                              // image: imagePaths[4],
                            ),
                            CustomCard(
                              //开发中
                              onTap: () {
                                setState(() {
                                  // waitingBuildDialog(context);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => targetPages[5]),
                                  // );
                                  stopCheckSerialPort();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DownloadPage()),
                                  );
                                });
                              },
                              title: titleNames[5],
                              cardColor: cardColors[5],
                              textColor: textColors[5],
                              // image: imagePaths[5],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomCard(
                              //license
                              onTap: () {
                                setState(() {
                                  stopCheckSerialPort();
                                  showLicenseDialog(context);
                                });
                              },
                              title: titleNames[6],
                              cardColor: cardColors[6],
                              textColor: textColors[6],
                              // image: imagePaths[3],
                            ),
                            CustomCard(
                              //重量
                              onTap: myLicenseInfo.isValid
                                  ? () {
                                      setState(() {
                                        stopCheckSerialPort();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ShowWeightReport()),
                                        );
                                      });
                                    }
                                  : () {},
                              title: titleNames[7],
                              cardColor: myLicenseInfo.isValid
                                  ? cardColors[7]
                                  : Theme.of(context).colorScheme.background,
                              textColor: textColors[7],
                              // image: imagePaths[3],
                            ),
                            CustomCard(
                              onTap: () {
                                setState(() {
                                  stopCheckSerialPort();
                                  setLanguageDialog(context);
                                });
                              },
                              title: titleNames[8],
                              cardColor: cardColors[7],
                              textColor: textColors[7],
                              // image: imagePaths[3],
                            ),
                          ],
                        ),
                      ],
                    )),
                    Container(
                        height: 20,
                        color: Colors.blue.shade900,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(S.of(context).contact_us,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void showBluetoothDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const BluetoothDialog();
      },
    );
  }

  void showUpdateFirmWareDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const UpdateFirmWareDialog();
      },
    );
  }

  void showComPortDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const ModifyComPortPage();
      },
    );
  }

  void showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LicenseInfoDialog();
      },
    );
  }

  void setLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LanguageSettingPage();
      },
    );
  }

  void _startTimer(int time) {
    isTiming = true;
    _timer = Timer(Duration(seconds: time), () {
      PublicFunctions.checkSerialPort();
      _startTimer(5);
    });
  }

  void _stopTimer() {
    _timer?.cancel(); // 停止计时器
    isTiming = false;
    myCheckSerialPortOnOFF.isCheck = false;
  }

  void _checkTimerFuc(int time) {
    _checkTimer = Timer(Duration(seconds: time), () {
      if (myCheckSerialPortOnOFF.isCheck && !isTiming) {
        _startTimer(5);
      }
      _checkTimerFuc(5);
    });
  }

  void stopCheckSerialPort() {
    _stopTimer();
  }
}
