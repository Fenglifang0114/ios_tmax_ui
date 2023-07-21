import 'package:flutter/material.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/pages/labeldesign_page.dart';
import 'package:t_max/pages/widget/license_info.dart';
import 'package:t_max/pages/wifisetting_page.dart';
import '../data/comscaleinfo_data.dart';
import '../data/currentport_data.dart';
import '../data/device_data.dart';
import '../functions/methods.dart';
import 'dialog/waitingbuildtips.dart';
import 'modify_com_port_page.dart';
import 'widget/bluetoothsetting.dart';
import 'widget/customcard.dart';

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

  String groupValue = 'zh';
  DateTime now = DateTime.now();

  List<Color> cardColors = List.generate(7, (index) => Colors.white);
  List<Color> textColors = List.generate(7, (index) => Colors.blue.shade900);
  List<Widget> targetPages = [
    const ModifyComPortPage(), // 第一个Card对应的目标界面
    const LabelDesignPage(), // 第二个Card对应的目标界面
    const WifiSettingPage(), // 第三个Card对应的目标界面
    const LabelDesignPage(), // 第一个Card对应的目标界面
    const LabelDesignPage(), // 第二个Card对应的目标界面
    const LabelDesignPage(), // 第三个Card对应的目标界面
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

  List<String> titleNames = [
    'Serial port connection',
    'Label Design',
    'Wifi Setting',
    'Bluetooth Setting',
    'Update FW',
    'Scale Records',
    'License Information',
  ];
  // 初始文字颜色

  @override
  void initState() {
    super.initState();

    _pageScrollerController = ScrollController();
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
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _pageScrollerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    // final _height = MediaQuery.of(context).size.height;
    return Scaffold(
        // appBar: PreferredSize(
        //     preferredSize: const Size.fromHeight(30),
        //     child: AppBar(
        //       title: version(),
        //       leading: const Text(''),
        //       actions: [
        //         Row(
        //           children: [
        //             SizedBox(
        //               height: 20,
        //               child: Row(
        //                 children: [
        //                   SizedBox(
        //                     child: TimerWidget(),
        //                   ),
        //                   const SizedBox(width: 30),
        //                 ],
        //               ),
        //             ),
        //             const SizedBox(width: 30),
        //             // PopupMenuButton(
        //             //   offset: const Offset(0, 40),
        //             //   onSelected: (value) {
        //             //     _changed(value);
        //             //   },
        //             //   itemBuilder: (BuildContext context) => [
        //             //     PopupMenuItem(
        //             //         value: "zh",
        //             //         child: Text(
        //             //           "简体中文",
        //             //           style: Theme.of(context).textTheme.bodyMedium,
        //             //         )),
        //             //     PopupMenuItem(
        //             //         value: "en",
        //             //         child: Text(
        //             //           "English",
        //             //           style: Theme.of(context).textTheme.bodyMedium,
        //             //         )),
        //             //   ],
        //             // ),
        //           ],
        //         )
        //       ],
        //     )),
        //左侧边栏
        // drawer: leftSidebar(context),

        body: Container(
      height: _height,
      width: _width,
      // decoration: BoxDecoration(gradient: boxGradient()),
      child: ListView(
        // 水平拉伸
        scrollDirection: Axis.horizontal,
        children: [
          Container(
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
                          onTap: () {
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
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => targetPages[1]),
                              );
                            });
                          },
                          title: titleNames[1],
                          cardColor: cardColors[1],
                          textColor: textColors[1],
                          // image: imagePaths[1],
                        ),
                        CustomCard(
                          onTap: () {
                            setState(() {
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
                          onTap: () {
                            setState(() {
                              showBluetoothDialog(context);
                            });
                          },
                          title: titleNames[3],
                          cardColor: cardColors[3],
                          textColor: textColors[3],
                          // image: imagePaths[3],
                        ),
                        CustomCard(
                          onTap: () {
                            setState(() {
                              waitingBuildDialog(context);
                            });
                          },
                          title: titleNames[4],
                          cardColor: cardColors[4],
                          textColor: textColors[4],
                          // image: imagePaths[4],
                        ),
                        CustomCard(
                          onTap: () {
                            setState(() {
                              waitingBuildDialog(context);
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => targetPages[5]),
                              // );
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
                          onTap: () {
                            setState(() {
                              showLicenseDialog(context);
                            });
                          },
                          title: titleNames[6],
                          cardColor: cardColors[6],
                          textColor: textColors[6],
                          // image: imagePaths[3],
                        ),
                        const SizedBox(
                          height: 150,
                          width: 200,
                        ),
                        const SizedBox(
                          height: 150,
                          width: 200,
                        ),
                      ],
                    ),
                  ],
                )),
                Container(
                    height: 20,
                    color: Colors.blue.shade900,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Contact us:sales@taiwanscale.com",
                            style:
                                TextStyle(color: Colors.white, fontSize: 15)),
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

  // void _changed(value) {
  //   if (value != null) {
  //     //SpUtil.putString(SpConstant.LANGUAGE, value);
  //     setState(() {
  //       groupValue = value;
  //       if (value == "zh") S.load(const Locale('zh', 'CN'));
  //       if (value == "en") S.load(const Locale('en', 'US'));
  //     });
  //   }
  // }
}
