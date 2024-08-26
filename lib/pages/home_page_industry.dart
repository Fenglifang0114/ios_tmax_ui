import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/pages/labeldesign_page.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../data/company_info.dart';
import '../data/comscaleinfo_data.dart';
import '../data/currentport_data.dart';
import '../data/device_data.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../dialog/get_build_info_dialog.dart';
import '../dialog/language_setting.dart';
import '../functions/methods.dart';
import '../generated/l10n.dart';
import '../widget/app_info.dart';
import '../widget/box_gradient.dart';
import '../widget/custom_circle_icon.dart';
import '../widget/custom_setting.dart';
import '../dialog/license_info.dart';
import '../widget/home_page_widget.dart';
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

class IndustryHomePageState extends State<IndustryHomePage> with TrayListener {
  List<String> items = [];
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  // TextEditingController _scaleNameCtl = TextEditingController();

  late ScrollController _pageScrollerController;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;

  String groupValue = 'zh';
  DateTime now = DateTime.now();
  bool isCardHovered = false;
  bool isCardClicked = false;
  bool editScaleNameFlag = false;

  Future<void> _handleSetIcon() async {
    String iconPath =
        Platform.isWindows ? 'assets/images/app.ico' : 'assets/images/app.png';
    await windowManager.setIcon(iconPath);
  }

  Future<void> _init() async {
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/images/app.ico' : 'assets/images/app.png',
    );
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void initState() {
    trayManager.addListener(this);
    _init();
    _handleSetIcon();
    super.initState();
    _pageScrollerController = ScrollController();
    cntScaleTimerMgr.startCntScaleTimer(5);
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
            myFactoryInfoFromScale = event.obj;
            if (myFactoryInfoFromScale.modelName != '') {
              myScreenMgr.serialPortST = true;
            } else {
              myScreenMgr.serialPortST = false;
            }
          });
        }
      }
    });

    _eventbus4 = eventBus.on<EventGetFactoryInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myFactoryInfoFromScale = event.obj;
        });
      }
    });
    _eventbus5 = eventBus.on<EventLicenseData>().listen((event) {
      if (mounted) {
        setState(() {
          var eventInfo = event.obj;
          if (eventInfo.isNotEmpty) {
            var jsonData = json.decode(eventInfo);

            try {
              myLicenseData = LicenseData.fromJson(jsonData);
            } catch (e) {
              myLicenseData = LicenseData([]);
            }
            if (myLicenseData.licList.isNotEmpty) {
              LicenseSetting().setLicInfo();
            }
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
    _eventbus4.cancel();
    _eventbus5.cancel();
    _pageScrollerController.dispose();
    cntScaleTimerMgr.stopCntScaleTimer();
    super.dispose();
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
                decoration: BoxDecoration(gradient: boxGradient(context)),
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
                                'assets/images/app.png',
                                width: 30.0,
                                height: 30.0,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                myAppName.appName!,
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
                              versionInfo(
                                  Theme.of(context).colorScheme.onPrimary),
                              // Text(
                              //     myLicenseInfo.isValid
                              //         ? '(Professional)'
                              //         : '(Basic)',
                              //     style: TextStyle(
                              //       color:
                              //           Theme.of(context).colorScheme.onPrimary,
                              //       fontSize: 16,
                              //     ),
                              //     textAlign: TextAlign.center),
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
                          AppInfoButton(onRefresh: () {
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
                              ? CustomCircleIcon(
                                  outerColor:
                                      Theme.of(context).colorScheme.primary,
                                  innerColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  icon: Icons.check_circle,
                                  size: 24.0,
                                )
                              : CustomCircleIcon(
                                  outerColor:
                                      Theme.of(context).colorScheme.error,
                                  innerColor:
                                      Theme.of(context).colorScheme.onPrimary,
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
                  color: Theme.of(context).colorScheme.surfaceTint,
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    firstCard(),
                    secondCard(),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 100, child: Image.asset(companyImage)),
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
          outerColor: Theme.of(context).colorScheme.primary,
          innerColor: Theme.of(context).colorScheme.onPrimary,
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

  Widget firstCard() {
    return Expanded(
      flex: 4,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          margin: const EdgeInsets.only(right: 20), // 根据实际需要设置容器间距
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: functionTitle(
                    localizedStrings.device_configuration_title, Icons.link),
              ),
              Expanded(
                child: ListView(children: [
                  (myFactoryInfoFromScale.modelName != null)
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
                                      localizedStrings.scale_model,
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
                                        myFactoryInfoFromScale.modelName!,
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
                                        myFactoryInfoFromScale.scaleSn!,
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
                          context,
                          localizedStrings.title_serial_port_connection,
                          Icons.cable,
                          true),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click, // 设置光标为手的形状
                    child: GestureDetector(
                      onTap: () {
                        if (myFactoryInfoFromScale.modelName == null ||
                            (!myFactoryInfoFromScale.modelName!
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
                          context,
                          localizedStrings.plu_download_title,
                          Icons.shopping_bag,
                          myFactoryInfoFromScale.modelName == null
                              ? true
                              : !myFactoryInfoFromScale.modelName!
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
                      child: customFunctionCard(context,
                          localizedStrings.update_firmware, Icons.update, true),
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
                          context,
                          localizedStrings.get_build_info,
                          Icons.privacy_tip,
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
      flex: 8,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          margin: const EdgeInsets.only(right: 20), // 根据实际需要设置容器间距
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: functionTitle(
                    localizedStrings.customization_setting_title,
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
                          child: appCard(
                              context,
                              localizedStrings.weighing_title,
                              Icons.monitor_weight_outlined,
                              true,
                              'This application is used to display the weighing data in real time.',
                              ''),
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: myWedaLicInfo.isValid
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
                          child: appCard(
                              context,
                              localizedStrings.weight_collection_title,
                              Icons.save_as,
                              myWedaLicInfo.isValid,
                              'This application is used to collect weighing data in real time',
                              myWedaLicInfo.liceseDate == "2299-01-01"
                                  ? 'Perpetual'
                                  : myWedaLicInfo.liceseDate),
                        ),
                      ),
                      MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myChweLicInfo.isValid
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
                            child: appCard(
                                context,
                                localizedStrings.checkweigher_title,
                                Icons.scale,
                                myChweLicInfo.isValid,
                                'This application is used to check weighing data in real time',
                                myChweLicInfo.liceseDate == "2299-01-01"
                                    ? 'Perpetual'
                                    : myChweLicInfo.liceseDate),
                          )),
                      MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myInWeLicInfo.isValid
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
                            child: appCard(
                                context,
                                localizedStrings.take_in_title,
                                Icons.add,
                                myInWeLicInfo.isValid,
                                'This app is used to implement the increment scale.',
                                myInWeLicInfo.liceseDate == "2299-01-01"
                                    ? 'Perpetual'
                                    : myInWeLicInfo.liceseDate),
                          )),
                      MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myTaouLicInfo.isValid
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
                            child: appCard(
                                context,
                                localizedStrings.take_out_title,
                                Icons.remove,
                                myTaouLicInfo.isValid,
                                'This app is used to implement the take out scale.',
                                myTaouLicInfo.liceseDate == "2299-01-01"
                                    ? 'Perpetual'
                                    : myTaouLicInfo.liceseDate),
                          )),
                    ]),
              ),
            ],
          )),
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
    cntScaleTimerMgr.stopCntScaleTimer();
    cntScaleTimerMgr.startCntScaleTimer(5);
  }

  void stopCheckSerialPort() {
    myScreenMgr.isMainScreen = false;
    cntScaleTimerMgr.stopCntScaleTimer();
  }
}
