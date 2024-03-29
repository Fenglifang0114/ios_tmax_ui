import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/pages/labeldesign_page.dart';
import '../data/comscaleinfo_data.dart';
import '../data/currentport_data.dart';
import '../data/device_data.dart';
import '../data/downloadresponse.dart';
import '../data/screen_mgr.dart';
import '../data/setting_version_info.dart';
import '../dialog/get_build_info_dialog.dart';
import '../dialog/language_setting.dart';
import '../functions/methods.dart';
import '../generated/l10n.dart';
import '../widget/box_gradient.dart';
import '../widget/custom_circle_icon.dart';
import '../widget/custom_setting.dart';
import '../dialog/license_info.dart';
import '../widget/update_firmware.dart';
import '../widget/version.dart';
import 'check_weighers_page.dart';
import 'modify_com_port_page.dart';
import 'product_download_page.dart';
import 'take_in_page.dart';
import 'take_out_page.dart';
import 'weighing.dart';
import 'weight_mode_page.dart';

class IndustryHomePage extends StatefulWidget {
  const IndustryHomePage({Key? key}) : super(key: key);

  @override
  State<IndustryHomePage> createState() => IndustryHomePageState();
}

class IndustryHomePageState extends State<IndustryHomePage> {
  List<String> items = [];
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();

  late ScrollController _pageScrollerController;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;

  Timer? _timer;
  bool isTiming = false;

  String groupValue = 'zh';
  DateTime now = DateTime.now();
  bool isCardHovered = false;
  bool isCardClicked = false;

  // 初始文字颜色
  @override
  void initState() {
    super.initState();
    _pageScrollerController = ScrollController();
    _startTimer(5);
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
        if (myScreenMgr.isMainScreen) {
          setState(() {
            myRespCheckSerialPort = event.obj;
            if (myRespCheckSerialPort.msgBody == 'ok') {
              myScreenMgr.serialPortST = true;
              PublicFunctions.getScaleInfo();
            } else {
              myScreenMgr.serialPortST = false;
            }
          });
        }
      }
    });

    _eventbus4 = eventBus.on<EventGetScaleInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myScaleInfoFromScale = event.obj;
        });
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _pageScrollerController.dispose();
    _stopTimer();
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
    // final _width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
              color: Theme.of(context).colorScheme.onPrimary,
              child: Container(
                decoration: BoxDecoration(gradient: boxGradient()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: SizedBox(
                          width: 400,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Image.asset(
                                'assets/images/4.png',
                                width: 30.0,
                                height: 30.0,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                mySystemVersionInfo.getTitle(mySystemVersion),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              version(Theme.of(context).colorScheme.onPrimary),
                              Text(
                                  myLicenseInfo.isValid
                                      ? '(Professional)'
                                      : '(Basic)',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center),
                            ],
                          )),
                    ),
                    SizedBox(
                      width: 360,
                      height: 50,
                      child: Row(
                        children: [
                          CustomSettingButton(onRefresh: () {
                            setState(() {});
                          }),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(localizedStrings.serial_port_status,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          (myScreenMgr.serialPortST)
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
                                ),
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                    width: 100, child: Image.asset('assets/images/tscale.png')),
              ],
            ),
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
        const SizedBox(
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
      String titleName, String iconImage, IconData iconInfo, bool isValid) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: isValid
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.background,
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: functionTitle(
                    localizedStrings.device_connection_title, Icons.link),
              ),
              Expanded(
                child: ListView(children: [
                  (myScaleInfoFromScale.modelName != null)
                      ? SizedBox(
                          height: 80,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Flexible(
                                    child: Text(
                                      localizedStrings.scale_name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    Flexible(
                                      child: Text(
                                        myScaleInfoFromScale.modelName!,
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Flexible(
                                    child: Text(
                                      localizedStrings.scale_sn,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    Flexible(
                                      child: Text(
                                        myScaleInfoFromScale.scaleSn!,
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click, // 设置光标为手的形状
                    child: GestureDetector(
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
                          Icons.cable,
                          true),
                    ),
                  ),
                ]),
              ),
            ],
          )),
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: functionTitle(
                    localizedStrings.general_configuration_title,
                    Icons.settings),
              ),
              Expanded(
                child: ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: () {
                            if (myScaleInfoFromScale.modelName == null ||
                                (!myScaleInfoFromScale.modelName!
                                    .contains('2200'))) {
                              setState(() {
                                stopCheckSerialPort();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProductDownloadPage()),
                                ).then((value) => _updateStatus());
                              });
                            }
                          },
                          child: customFunctionCard(
                              localizedStrings.plu_download_title,
                              "assets/images/line.png",
                              Icons.shopping_bag,
                              myScaleInfoFromScale.modelName == null
                                  ? true
                                  : !myScaleInfoFromScale.modelName!
                                      .contains('2200')),
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              stopCheckSerialPort();
                              showUpdateFirmWareDialog(context);
                            });
                          },
                          child: customFunctionCard(
                              localizedStrings.update_firmware,
                              "assets/images/line.png",
                              Icons.update,
                              true),
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showBuildInfo();
                            });
                          },
                          child: customFunctionCard(
                              localizedStrings.get_build_info,
                              "assets/images/line.png",
                              Icons.info,
                              true),
                        ),
                      ),
                    ]),
              ),
            ],
          )),
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
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: functionTitle(
                  localizedStrings.application_title, Icons.design_services),
            ),
            Expanded(
              child: ListView(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click, // 设置光标为手的形状
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            stopCheckSerialPort();
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const WeightModePage()),
                              ).then((value) => _updateStatus());
                            });
                          });
                        },
                        child: customFunctionCard(
                            localizedStrings.weighing_title,
                            "assets/images/line.png",
                            Icons.monitor_weight_outlined,
                            true),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click, // 设置光标为手的形状
                      child: GestureDetector(
                        onTap: myLicenseInfo.isValid
                            ? () {
                                setState(() {
                                  stopCheckSerialPort();
                                  setState(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const WeightDataCollectionPage()),
                                    ).then((value) => _updateStatus());
                                  });
                                });
                              }
                            : null,
                        child: customFunctionCard(
                            localizedStrings.weight_collection_title,
                            "assets/images/line.png",
                            Icons.save_as,
                            myLicenseInfo.isValid),
                      ),
                    ),
                    MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: myLicenseInfo.isValid
                              ? () {
                                  setState(() {
                                    stopCheckSerialPort();
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CheckWeighersPage()),
                                      ).then((value) => _updateStatus());
                                    });
                                  });
                                }
                              : null,
                          child: customFunctionCard(
                              localizedStrings.checkweigher_title,
                              "assets/images/line.png",
                              Icons.scale,
                              myLicenseInfo.isValid),
                        )),
                    MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: myLicenseInfo.isValid
                              ? () {
                                  setState(() {
                                    stopCheckSerialPort();
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TakeInPage()),
                                      ).then((value) => _updateStatus());
                                    });
                                  });
                                }
                              : null,
                          child: customFunctionCard(
                              localizedStrings.take_in_title,
                              "assets/images/line.png",
                              Icons.add,
                              myLicenseInfo.isValid),
                        )),
                    MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: myLicenseInfo.isValid
                              ? () {
                                  setState(() {
                                    stopCheckSerialPort();
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TakeOutPage()),
                                      ).then((value) => _updateStatus());
                                    });
                                  });
                                }
                              : null,
                          child: customFunctionCard(
                              localizedStrings.take_out_title,
                              "assets/images/line.png",
                              Icons.remove,
                              myLicenseInfo.isValid),
                        )),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  void showBuildInfo() {
    stopCheckSerialPort();
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const GetBuildInfoPage();
      },
    ).then((value) => _updateStatus());
  }

  void showLabelDesign(bool isValid) {
    if (isValid) {
      stopCheckSerialPort();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LabelDesignPage()),
      ).then((value) => _updateStatus());
    }
  }

  void showUpdateFirmWareDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const UpdateFirmWareDialog();
      },
    ).then((value) => _updateStatus());
  }

  void showComPortDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const ModifyComPortPage();
      },
    ).then((value) => _updateStatus());
  }

  void showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LicenseInfoDialog();
      },
    ).then((value) => _updateStatus());
  }

  void setLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LanguageSettingPage();
      },
    ).then((value) => _updateStatus());
  }

  void _updateStatus() {
    setState(() {});
    _startTimer(5);
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
  }

  void stopCheckSerialPort() {
    myScreenMgr.isMainScreen = false;
    _stopTimer();
  }
}
