import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/dialog/get_build_info.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/pages/download_page.dart';
import 'package:t_max/pages/labeldesign_page.dart';
import 'package:t_max/pages/wifisetting_page.dart';
import '../data/comscaleinfo_data.dart';
import '../data/currentport_data.dart';
import '../data/device_data.dart';
import '../data/downloadresponse.dart';
import '../functions/methods.dart';
import '../generated/l10n.dart';
import '../widget/bluetoothsetting.dart';
import '../widget/box_gradient.dart';
import '../widget/custom_circle_icon.dart';
import '../widget/custom_setting.dart';
import '../widget/customcard.dart';
import '../dialog/license_info.dart';
import '../widget/show_weight_report.dart';
import '../widget/update_firmware.dart';
import '../widget/version.dart';
import 'custom_serial_protocol_page.dart';
import 'modify_com_port_page.dart';
import 'product_download_page.dart';
import 'serial_output_page.dart';

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
    'assets/images/11.png',
    'assets/images/12.png',
    'assets/images/13.png',
    'assets/images/14.png',
    'assets/images/15.png',
    'assets/images/16.png',
  ];
  bool isCardHovered = false;
  bool isCardClicked = false;

  void _handleCardHover(bool isHovered) {
    setState(() {
      isCardHovered = isHovered;
    });
  }

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
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    // final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            color: Theme.of(context).colorScheme.onPrimary,
            // foregroundColor: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.onPrimary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 50,
                            ),
                            Image.asset(
                              'assets/images/4.png',
                              width: 30.0,
                              height: 30.0,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            version(),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 100,
                        height: 50,
                        child: Row(
                          children: [
                            CustomSettingButton(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(gradient: boxGradient()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 240,
                          child: Text(
                            "T-CONFIG",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.onPrimary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        height: 50,
                        child: Row(
                          children: [
                            Text('Serial port status:',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                            const SizedBox(
                              width: 20,
                            ),
                            (isComConnected)
                                ? const CustomCircleIcon(
                                    outerColor: Colors.blue,
                                    innerColor: Colors.white,
                                    icon: Icons.check_circle,
                                    size: 24.0,
                                  )
                                : const CustomCircleIcon(
                                    outerColor: Colors.red,
                                    innerColor: Colors.white,
                                    icon: Icons.cancel,
                                    size: 24.0,
                                  )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            //设置状态栏颜色渐变
            // flexibleSpace:
            //     Container(decoration: BoxDecoration(gradient: boxGradient())),
          )),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    firstCard(),
                    secondCard(),
                    thirdCard(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget functionTitle(String titleName, IconData iconName) {
    return Row(
      children: [
        CustomCircleIcon(
          outerColor: Colors.blue,
          innerColor: Colors.white,
          icon: iconName,
          size: 30.0,
        ),
        SizedBox(
          width: 10,
        ),
        Text(titleName),
      ],
    );
  }

  LinearGradient lineGradient() {
    return const LinearGradient(
      colors: [
        Color.fromARGB(255, 21, 129, 238),
        Color.fromARGB(255, 115, 238, 207),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget customFunctionCard(
      String titleName, String iconImage, IconData iconInfo) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Theme.of(context).colorScheme.onPrimary,
        child: SizedBox(
            height: 80,
            child: Row(
              children: [
                Image.asset(
                  iconImage,
                  width: 30,
                  height: 30,
                ),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return lineGradient().createShader(bounds);
                  },
                  child: Icon(
                    size: 30,
                    iconInfo,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Text(
                    titleName,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            )));
  }

  Widget firstCard() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
          color: Theme.of(context).colorScheme.tertiary,
        ),
        margin: const EdgeInsets.only(right: 20), // 根据实际需要设置容器间距
        child: ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            children: [
              functionTitle('Device Connection', Icons.link),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  stopCheckSerialPort();
                  setState(() {
                    PublicFunctions.getProductList();
                    PublicFunctions.getPortList();
                    showComPortDialog(context);
                  });
                },
                child: customFunctionCard(
                    localizedStrings.title_serial_port_connection,
                    "assets/images/line.png",
                    Icons.cable),
              ),
            ]),
      ),
    );
  }

  Widget secondCard() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
          color: Theme.of(context).colorScheme.tertiary,
        ),
        margin: const EdgeInsets.only(right: 20), // 根据实际需要设置容器间距
        child: ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            children: [
              functionTitle('Device Setting', Icons.settings),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  //TODO:蓝牙页面
                  setState(() {
                    stopCheckSerialPort();
                    showBluetoothDialog(context);
                  });
                },
                child: customFunctionCard("Bluetooth Setting",
                    "assets/images/line.png", Icons.bluetooth),
              ),
              GestureDetector(
                onTap: () {
                  //TODO:wifi页面
                  setState(() {
                    stopCheckSerialPort();
                    PublicFunctions.getWifiList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => targetPages[2]),
                    ).then((value) => setState(() {}));
                  });
                },
                child: customFunctionCard(
                    "Wi-Fi Setting", "assets/images/line.png", Icons.wifi),
              )
            ]),
      ),
    );
  }

  Widget thirdCard() {
    return Expanded(
      flex: 1, // 设置一个容器的flex为2，在剩余空间中占用更多的比例
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
          color: Theme.of(context).colorScheme.tertiary,
        ),
        child: ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            children: [
              functionTitle('Customization Setting', Icons.design_services),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  //TODO:  标签设计
                  showWiFiSetting(myLicenseInfo.isValid);
                },
                child: customFunctionCard(
                    "Label Design", "assets/images/line.png", Icons.sell),
              ),
              GestureDetector(
                onTap: () {
                  //TODO:  打印格式下载
                  stopCheckSerialPort();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DownloadPage()),
                  ).then((value) => setState(() {
                        isCardClicked = false;
                      }));
                },
                child: customFunctionCard("Print Format Download",
                    "assets/images/line.png", Icons.receipt_long_outlined),
              ),
              GestureDetector(
                onTap: () {
                  //TODO:  串口输出
                  stopCheckSerialPort();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const CustomSerialProtocol()),
                  // ).then((value) => setState(() {
                  //       isCardClicked = false;
                  //     }));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SerialOutputPage()),
                  ).then((value) => setState(() {
                        isCardClicked = false;
                      }));
                },
                child: customFunctionCard(
                    "Serial Output", "assets/images/line.png", Icons.usb_sharp),
              ),
              GestureDetector(
                onTap: () {
                  //TODO:  PLU下载
                  setState(() {
                    stopCheckSerialPort();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProductDownloadPage()),
                    ).then((value) => setState(() {
                          isCardClicked = false;
                        }));
                  });
                },
                child: customFunctionCard("Plu Download",
                    "assets/images/line.png", Icons.shopping_bag),
              )
            ]),
      ),
    );
  }

  void showWiFiSetting(bool isValid) {
    if (isValid) {
      stopCheckSerialPort();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LabelDesignPage()),
      ).then((value) => setState(() {
            isCardClicked = false;
          }));
    }
  }

  // SizedBox(
  //         height: _height,
  //         width: _width,
  //         // decoration: BoxDecoration(gradient: boxGradient()),
  //         child: ListView(
  //           // 水平拉伸
  //           scrollDirection: Axis.horizontal,
  //           children: [
  //             SizedBox(
  //               height: _height,
  //               width: _width,
  //               // decoration: BoxDecoration(gradient: boxGradient()),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Expanded(
  //                       child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           CustomCard(
  //                             //修改串口
  //                             onTap: () {
  //                               stopCheckSerialPort();
  //                               setState(() {
  //                                 PublicFunctions.getProductList();
  //                                 PublicFunctions.getPortList();
  //                                 showComPortDialog(context);
  //                               });
  //                             },
  //                             title: titleNames[0],
  //                             cardColor: cardColors[0],
  //                             textColor: textColors[0],
  //                             // image: imagePaths[0],
  //                           ),
  //                           CustomCard(
  //                             //设计打印格式
  //                             onTap: myLicenseInfo.isValid
  //                                 ? () {
  //                                     stopCheckSerialPort();
  //                                     setState(() {
  //                                       Navigator.push(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                             builder: (context) =>
  //                                                 targetPages[1]),
  //                                       );
  //                                     });
  //                                   }
  //                                 : () {},
  //                             title: titleNames[1],
  //                             cardColor: myLicenseInfo.isValid
  //                                 ? cardColors[1]
  //                                 : Theme.of(context).colorScheme.background,
  //                             textColor: textColors[1],
  //                             // image: imagePaths[1],
  //                           ),
  //                           CustomCard(
  //                             //WIFI
  //                             onTap: () {
  //                               setState(() {
  //                                 stopCheckSerialPort();
  //                                 PublicFunctions.getWifiList();
  //                                 Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                       builder: (context) => targetPages[2]),
  //                                 );
  //                               });
  //                             },
  //                             title: titleNames[2],
  //                             cardColor: cardColors[2],
  //                             textColor: textColors[2],
  //                             // image: imagePaths[2],
  //                           ),
  //                         ],
  //                       ),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           CustomCard(
  //                             //蓝牙
  //                             onTap: () {
  //                               setState(() {
  //                                 stopCheckSerialPort();
  //                                 showBluetoothDialog(context);
  //                               });
  //                             },
  //                             title: titleNames[3],
  //                             cardColor: cardColors[3],
  //                             textColor: textColors[3],
  //                             // image: imagePaths[3],
  //                           ),
  //                           CustomCard(
  //                             //更新软件
  //                             onTap: () {
  //                               setState(() {
  //                                 stopCheckSerialPort();
  //                                 showUpdateFirmWareDialog(context);
  //                               });
  //                             },
  //                             title: titleNames[4],
  //                             cardColor: cardColors[4],
  //                             textColor: textColors[4],
  //                             // image: imagePaths[4],
  //                           ),
  //                           CustomCard(
  //                             //开发中
  //                             onTap: () {
  //                               setState(() {
  //                                 // waitingBuildDialog(context);
  //                                 // Navigator.push(
  //                                 //   context,
  //                                 //   MaterialPageRoute(
  //                                 //       builder: (context) => targetPages[5]),
  //                                 // );
  //                                 stopCheckSerialPort();
  //                                 Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                       builder: (context) =>
  //                                           const DownloadPage()),
  //                                 );
  //                               });
  //                             },
  //                             title: titleNames[5],
  //                             cardColor: cardColors[5],
  //                             textColor: textColors[5],
  //                             // image: imagePaths[5],
  //                           ),
  //                         ],
  //                       ),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           CustomCard(
  //                             //license
  //                             onTap: () {
  //                               /////////////////////////////////////////////////////////////
  //                               stopCheckSerialPort();
  //                               setState(() {
  //                                 stopCheckSerialPort();
  //                                 showLicenseDialog(context);
  //                               });
  //                             },
  //                             title: titleNames[6],
  //                             cardColor: cardColors[6],
  //                             textColor: textColors[6],
  //                             // image: imagePaths[3],
  //                           ),
  //                           CustomCard(
  //                             //重量
  //                             onTap: myLicenseInfo.isValid
  //                                 ? () {
  //                                     setState(() {
  //                                       stopCheckSerialPort();
  //                                       Navigator.push(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                             builder: (context) =>
  //                                                 const ShowWeightReport()),
  //                                       );
  //                                     });
  //                                   }
  //                                 : () {},
  //                             title: titleNames[7],
  //                             cardColor: myLicenseInfo.isValid
  //                                 ? cardColors[7]
  //                                 : Theme.of(context).colorScheme.background,
  //                             textColor: textColors[7],
  //                             // image: imagePaths[3],
  //                           ),
  //                           CustomCard(
  //                             onTap: () {
  //                               setState(() {
  //                                 stopCheckSerialPort();
  //                                 // Navigator.push(
  //                                 //   context,
  //                                 //   MaterialPageRoute(
  //                                 //       builder: (context) =>
  //                                 //           const CustomSerialProtocol()),
  //                                 // );
  //                                 setLanguageDialog(context);
  //                               });
  //                             },
  //                             title: titleNames[8],
  //                             cardColor: cardColors[7],
  //                             textColor: textColors[7],
  //                             // image: imagePaths[3],
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   )),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       )

  void showBluetoothDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const BluetoothDialog();
      },
    ).then((value) => setState(() {}));
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
    ).then((value) => setState(() {}));
  }

  void setLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        // return const LanguageSettingPage();
        return const GetBuildInfoPage();
      },
    ).then((value) => setState(() {}));
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
