import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:t_max/data/settingparam_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/pages/flow_rate_page.dart';
import 'package:t_max/pages/formula_scale_page.dart';
import 'package:t_max/pages/labeldesign_page.dart';
import 'package:t_max/pages/sel_four_scales_page.dart';
import 'package:t_max/pages/weight_collection_page.dart';
import 'package:t_max/pages/wifi_setting_page.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../data/company_info.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../dialog/exit_app_dialog.dart';
import '../dialog/language_setting.dart';
import '../functions/methods.dart';
import '../generated/l10n.dart';
import '../widget/app_info.dart';
import '../widget/bluetooth_setting.dart';
import '../widget/box_gradient.dart';
import '../widget/custom_circle_icon.dart';
import '../widget/custom_setting.dart';
import '../dialog/license_info.dart';
import '../widget/home_page_widget.dart';
import '../widget/version.dart';
import 'check_weighers_page.dart';
import 'plu_edit_page.dart';
// import 'scale_manager_page.dart';

import 'take_in_page.dart';
import 'take_out_page.dart';
import 'update_firmware_page.dart';
import 'weighing.dart';

class IndustryHomePage extends StatefulWidget {
  const IndustryHomePage({super.key});

  @override
  State<IndustryHomePage> createState() => IndustryHomePageState();
}

class IndustryHomePageState extends State<IndustryHomePage>
    with TrayListener, WindowListener {
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  late ScrollController _pageScrollerController;
  dynamic _eventbus1;

  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;

  String groupValue = 'zh';
  DateTime now = DateTime.now();
  bool isCardHovered = false;
  bool isCardClicked = false;
  bool editScaleNameFlag = false;
  bool showHint1 = false;
  bool showHint2 = false;
  bool isResize = false;

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
    await windowManager.setPreventClose(true); //关闭前确认
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void onWindowResize() {
    isResize = true;
  }

  @override
  void onWindowMaximize() {
    isResize = true;
  }

  @override
  void onWindowUnmaximize() {
    isResize = true;
  }

  @override
  void onWindowMinimize() {
    isResize = true;
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false, // 允许点击空白处关闭对话框
        builder: (context) {
          return CustomAlertDialog(
            titleText: localizedStrings.gTipExitApp,
            onNoPressed: () {
              Navigator.of(context).pop();
            },
            onYesPressed: () async {
              Navigator.of(context).pop();
              dispose();
              await trayManager.destroy(); //退出系统托盘
              await windowManager.destroy();
              exit(0);
            },
          );
        },
      );
    }
  }

  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    _scrollController2.addListener(_checkScrollPosition2);
    _scrollController1.addListener(_checkScrollPosition1);
    _init();
    _handleSetIcon();
    super.initState();
    _pageScrollerController = ScrollController();
    // cntScaleTimerMgr.startCntScaleTimer(5);
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

    _eventbus3 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        if (myScreenMgr.isMainScreen) {
          // setState(() {
          //   myFactoryInfoFromScale = event.obj;
          //   if (myFactoryInfoFromScale.modelName != '') {
          //     myComScaleInfo.isOnline = true;
          //   } else {
          //     myComScaleInfo.isOnline = false;
          //   }
          // });
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

    _eventbus6 = eventBus.on<EventCloseScalePassthResp>().listen((event) {
      if (mounted) {
        PublicFunctions.stopWeight(myDefScaleInfo.defScaleId!);
      }
    });
    _eventbus7 = eventBus.on<EventServiceOff>().listen((event) {
      setState(() {
        showServiceErrorDialog(context, localizedStrings.gTipServiceOff,
            localizedStrings.gTitleConfirm);
      });
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _pageScrollerController.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    cntScaleTimerMgr.stopCntScaleTimer();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final _width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;
    if (isResize) {
      _checkInitialVisibility();
    }
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
                        mainAxisAlignment: MainAxisAlignment.end,
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

                          // Expanded(
                          //   child: Text(localizedStrings.gSerialPort_status,
                          //       overflow: TextOverflow.ellipsis,
                          //       textAlign: TextAlign.right,
                          //       maxLines: 1,
                          //       style: TextStyle(
                          //           fontSize: 20,
                          //           color: Theme.of(context)
                          //               .colorScheme
                          //               .onPrimary)),
                          // ),
                          // const SizedBox(
                          //   width: 20,
                          // ),
                          // (myComScaleInfo.isOnline)
                          //     ? CustomCircleIcon(
                          //         outerColor:
                          //             Theme.of(context).colorScheme.primary,
                          //         innerColor:
                          //             Theme.of(context).colorScheme.onPrimary,
                          //         icon: Icons.check_circle,
                          //         size: 24.0,
                          //       )
                          //     : CustomCircleIcon(
                          //         outerColor:
                          //             Theme.of(context).colorScheme.error,
                          //         innerColor:
                          //             Theme.of(context).colorScheme.onPrimary,
                          //         icon: Icons.cancel,
                          //         size: 24.0,
                          //       ),
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
        color: Theme.of(context).colorScheme.surfaceBright,
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
                SizedBox(
                    width: 100, height: 30, child: Image.asset(companyImage)),
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
        flex: 6,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
              color: Theme.of(context).colorScheme.tertiaryContainer,
            ),
            margin: const EdgeInsets.only(right: 20), // 根据实际需要设置容器间距
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: functionTitle(
                    localizedStrings.device_configuration_title, Icons.link),
              ),
              Expanded(
                  child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController1,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Column(children: [
                      // (myFactoryInfoFromScale.modelName != null)
                      //     ? SizedBox(
                      //         height: 80,
                      //         child: Column(
                      //           children: [
                      //             Row(
                      //               mainAxisAlignment: MainAxisAlignment.start,
                      //               children: [
                      //                 const SizedBox(
                      //                   width: 30,
                      //                 ),
                      //                 Flexible(
                      //                   child: Text(
                      //                     localizedStrings.scale_model,
                      //                     maxLines: 1,
                      //                     overflow: TextOverflow.ellipsis,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //             Row(
                      //                 mainAxisAlignment: MainAxisAlignment.start,
                      //                 children: [
                      //                   const SizedBox(
                      //                     width: 30,
                      //                   ),
                      //                   Flexible(
                      //                     child: Text(
                      //                       myFactoryInfoFromScale.modelName!,
                      //                       maxLines: 1,
                      //                       textAlign: TextAlign.start,
                      //                       style: const TextStyle(
                      //                           fontWeight: FontWeight.bold),
                      //                       overflow: TextOverflow.ellipsis,
                      //                     ),
                      //                   ),
                      //                 ]),
                      //             Row(
                      //               mainAxisAlignment: MainAxisAlignment.start,
                      //               children: [
                      //                 const SizedBox(
                      //                   width: 30,
                      //                 ),
                      //                 Flexible(
                      //                   child: Text(
                      //                     localizedStrings.gScaleSn,
                      //                     maxLines: 1,
                      //                     overflow: TextOverflow.ellipsis,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //             Row(
                      //                 mainAxisAlignment: MainAxisAlignment.start,
                      //                 children: [
                      //                   const SizedBox(
                      //                     width: 30,
                      //                   ),
                      //                   Flexible(
                      //                     child: Text(
                      //                       myFactoryInfoFromScale.scaleSn!,
                      //                       maxLines: 1,
                      //                       textAlign: TextAlign.start,
                      //                       style: const TextStyle(
                      //                           fontWeight: FontWeight.bold),
                      //                       overflow: TextOverflow.ellipsis,
                      //                     ),
                      //                   ),
                      //                 ]),
                      //           ],
                      //         ),
                      //       )
                      //     : const SizedBox(),
                      // MouseRegion(
                      //   cursor: SystemMouseCursors.click, // 设置光标为手的形状
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       stopCheckSerialPort();
                      //       setState(() {
                      //         PublicFunctions.getProductList();
                      //         PublicFunctions.getPortList();
                      //         showComPortDialog(context);
                      //       });
                      //     },
                      //     child: customFunctionCard(
                      //         context,
                      //         localizedStrings.gTitleSerialPortConnection,
                      //         Icons.cable,
                      //         true),
                      //   ),
                      // ),
                      // MouseRegion(
                      //   cursor: SystemMouseCursors.click, // 设置光标为手的形状
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       stopCheckSerialPort();
                      //       setState(() {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) =>
                      //                   const ScaleManagerPage()),
                      //         ).then((value) => _updateStatus());
                      //       });
                      //     },
                      //     child: customFunctionCard(
                      //         context,
                      //         localizedStrings.menuMultiScaleManagement,
                      //         Icons.schema_outlined,
                      //         true),
                      //   ),
                      // ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              stopCheckSerialPort();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PluEidtPage()),
                              ).then((value) => _updateStatus());
                            });
                          },
                          child: customFunctionCard(
                              context,
                              localizedStrings.menuPluManagement,
                              Icons.edit_road,
                              myFactoryInfoFromScale.modelName == null
                                  ? true
                                  : !myFactoryInfoFromScale.modelName!
                                      .contains('2200')),
                        ),
                      ),
                      // MouseRegion(
                      //   cursor: SystemMouseCursors.click, // 设置光标为手的形状
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       if (myFactoryInfoFromScale.modelName == null ||
                      //           (!myFactoryInfoFromScale.modelName!
                      //               .contains('2200'))) {
                      //         setState(() {
                      //           stopCheckSerialPort();
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (context) =>
                      //                     const ProductDownloadPage()),
                      //           ).then((value) => _updateStatus());
                      //         });
                      //       }
                      //     },
                      //     child: customFunctionCard(
                      //         context,
                      //         localizedStrings.gTitlePluDownload,
                      //         Icons.shopping_bag,
                      //         myFactoryInfoFromScale.modelName == null
                      //             ? true
                      //             : !myFactoryInfoFromScale.modelName!
                      //                 .contains('2200')),
                      //   ),
                      // ),

                      GestureDetector(
                        onTap: () {
                          //蓝牙页面

                          setState(() {
                            stopCheckSerialPort();
                            showBluetoothDialog(context);
                          });
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: customFunctionCard(
                              context,
                              localizedStrings.bt_setting_title,
                              Icons.bluetooth,
                              (myScreenMgr.wifiOrBt.contains('bt'))),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          //wifi页面

                          setState(() {
                            stopCheckSerialPort();
                            PublicFunctions.changeWifiMode(1);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WifiSettingPage(),
                              ),
                            ).then((value) => _updateStatus());
                          });
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: customFunctionCard(
                              context,
                              localizedStrings.menuWifiSetting,
                              Icons.wifi,
                              (myScreenMgr.wifiOrBt.contains('wifi'))),
                        ),
                      ),

                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              stopCheckSerialPort();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const UpdateFirmwarePage()),
                              ).then((value) => _updateStatus());
                            });
                          },
                          child: customFunctionCard(
                              context,
                              localizedStrings.menuFirmwareUpdate,
                              Icons.cloud_upload_outlined,
                              true),
                        ),
                      ),
                    ]),
                  ),
                  if (showHint1)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                          child: IconButton(
                        iconSize: 40,
                        color: Theme.of(context).colorScheme.primary,
                        icon: const Icon(Icons.expand_circle_down),
                        onPressed: () {
                          _scrollController1.animateTo(
                            _scrollController1.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeInOut,
                          );
                        },
                      )),
                    ),
                ],
              )),
            ])));
  }

  void showBluetoothDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const BluetoothDialog();
      },
    ).then((value) => _updateStatus());
  }

  Widget secondCard() {
    return Expanded(
        flex: 8,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
              color: Theme.of(context).colorScheme.tertiaryContainer,
            ),
            margin: const EdgeInsets.only(right: 20), // 根据实际需要设置容器间距
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: functionTitle(
                    localizedStrings.customization_setting_title,
                    Icons.settings),
              ),
              Expanded(
                  child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController2,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Column(children: [
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
                              localizedStrings.menuWeighing,
                              Icons.monitor_weight_outlined,
                              true,
                              'This application is used to display the weighing data in real time.',
                              ''),
                        ),
                      ),
                      // MouseRegion(
                      //   cursor: SystemMouseCursors.click, // 设置光标为手的形状
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         stopCheckSerialPort();
                      //         setState(() {
                      //           showSelFourScaleDialog();
                      //         });
                      //       });
                      //     },
                      //     child: appCard(
                      //         context,
                      //         'Four Weightings',
                      //         Icons.monitor_weight,
                      //         true,
                      //         'This application is used to display the weighing data in real time.',
                      //         ''),
                      //   ),
                      // ),
                      // MouseRegion(
                      //   cursor: SystemMouseCursors.click, // 设置光标为手的形状
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         stopCheckSerialPort();
                      //         setState(() {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (context) =>
                      //                     const ProductionLinePage()),
                      //           );
                      //         });
                      //       });
                      //     },
                      //     child: appCard(
                      //         context,
                      //         'Real-time Production Line',
                      //         Icons.checklist_rtl,
                      //         true,
                      //         'This application is used to check the weighing data in real time.',
                      //         ''),
                      //   ),
                      // ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: myWedaLicInfo.isValid
                              ? () {
                                  setState(() {
                                    PublicFunctions.getUIConfNormal(
                                        wgtCollectionMode);
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
                              localizedStrings.menuWeighingDataCollection,
                              Icons.save_as,
                              myWedaLicInfo.isValid,
                              localizedStrings.iTipWeightCollection,
                              myWedaLicInfo.liceseDate == "2299-01-01"
                                  ? localizedStrings.gTipPerpetual
                                  : myWedaLicInfo.liceseDate),
                        ),
                      ),
                      MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myChweLicInfo.isValid
                                ? () {
                                    setState(() {
                                      PublicFunctions.getUIConfNormal(
                                          wgtCheckMode);

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
                                localizedStrings.menuCheckWeighing,
                                Icons.scale,
                                myChweLicInfo.isValid,
                                'This application is used to check weighing data in real time',
                                myChweLicInfo.liceseDate == "2299-01-01"
                                    ? localizedStrings.gTipPerpetual
                                    : myChweLicInfo.liceseDate),
                          )),
                      MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myInWeLicInfo.isValid
                                ? () {
                                    setState(() {
                                      PublicFunctions.getUIConfNormal(
                                          wgtTakeInMode);

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
                                localizedStrings.menuIncrementWeighing,
                                Icons.add,
                                myInWeLicInfo.isValid,
                                localizedStrings.iTipIncrementWeighting,
                                myInWeLicInfo.liceseDate == "2299-01-01"
                                    ? localizedStrings.gTipPerpetual
                                    : myInWeLicInfo.liceseDate),
                          )),
                      MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myTaouLicInfo.isValid
                                ? () {
                                    setState(() {
                                      PublicFunctions.getUIConfNormal(
                                          wgtTakeOutMode);
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
                                localizedStrings.menuTakeOutScale,
                                Icons.remove,
                                myTaouLicInfo.isValid,
                                localizedStrings.gTipTakeOut,
                                myTaouLicInfo.liceseDate == "2299-01-01"
                                    ? localizedStrings.gTipPerpetual
                                    : myTaouLicInfo.liceseDate),
                          )),
                      MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myTaouLicInfo.isValid
                                ? () {
                                    setState(() {
                                      PublicFunctions.getRawTypeList();
                                      PublicFunctions.getFormulaTypeList();
                                      PublicFunctions.getRawList();
                                      PublicFunctions.getFormulaList();
                                      PublicFunctions.getFormulaRecList();
                                      stopCheckSerialPort();
                                      setState(() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const FormulationScalePage()),
                                        ).then((value) => _updateStatus());
                                      });
                                    });
                                  }
                                : null,
                            child: appCard(
                                context,
                                //增加翻译
                                localizedStrings.fFormulaScaleTitle,
                                Icons.format_color_fill_outlined,
                                myTaouLicInfo.isValid,
                                localizedStrings.fFormulaScaleTitle,
                                myTaouLicInfo.liceseDate == "2299-01-01"
                                    ? localizedStrings.gTipPerpetual
                                    : myTaouLicInfo.liceseDate),
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
                                                  const FlowRatePage()),
                                        ).then((value) => _updateStatus());
                                      });
                                    });
                                  }
                                : null,
                            child: appCard(
                                context,
                                localizedStrings.fFlowRateMeasurement,
                                Icons.format_color_fill_outlined,
                                myTaouLicInfo.isValid,
                                localizedStrings.fFlowRateMeasurement,
                                myTaouLicInfo.liceseDate == "2299-01-01"
                                    ? localizedStrings.gTipPerpetual
                                    : myTaouLicInfo.liceseDate),
                          )),
                    ]),
                  ),
                  if (showHint2)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                          child: IconButton(
                        iconSize: 40,
                        color: Theme.of(context).colorScheme.primary,
                        icon: const Icon(Icons.expand_circle_down),
                        onPressed: () {
                          _scrollController2.animateTo(
                            _scrollController2.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeInOut,
                          );
                        },
                      )),
                    ),
                ],
              )),
            ])));
  }

  //窗口发生变化时判断一下是否要显示浮动图标
  void _checkInitialVisibility() {
    isResize = false;
    setState(() {
      setState(() {
        showHint1 = false;
        showHint2 = false;
      });
    });
    final viewportDimension = MediaQuery.of(context).size.height;

    if (viewportDimension > 700) {
      setState(() {
        showHint1 = false;
        showHint2 = false;
      });
    } else {
      _scrollController2.animateTo(
        _scrollController2.position.minScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
      _scrollController1.animateTo(
        _scrollController2.position.minScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );

      setState(() {
        showHint1 = true;
        showHint2 = true;
      });
    }

    if (viewportDimension > 300) {
      setState(() {
        showHint1 = false;
        showHint2 = false;
      });
    }
  }

  void _checkScrollPosition1() {
    final maxScroll = _scrollController1.position.maxScrollExtent;
    final currentScroll = _scrollController1.position.pixels;
//露出最后半个功能的时候，就不显示了

    if (currentScroll >= maxScroll - 30 && showHint1) {
      setState(() {
        showHint1 = false;
      });
    } else if (currentScroll < maxScroll && !showHint1) {
      setState(() {
        showHint1 = true;
      });
    }
  }

  void _checkScrollPosition2() {
    final maxScroll = _scrollController2.position.maxScrollExtent;
    final currentScroll = _scrollController2.position.pixels;
//露出最后半个功能的时候，就不显示了
    if (currentScroll >= maxScroll - 50 && showHint2) {
      setState(() {
        showHint2 = false;
      });
    } else if (currentScroll < maxScroll && !showHint2) {
      setState(() {
        showHint2 = true;
      });
    }
  }

  void showSelFourScaleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const SltFourScalesPage(mode: weightingMode);
      },
    );
  }

  void showLabelDesign(bool isValid) {
    if (isValid) {
      stopCheckSerialPort();

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const LabelDesignPage(type: "")),
      ).then((value) => _updateStatus());
    }
  }

  // void showComPortDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // 允许点击空白处关闭对话框
  //     builder: (context) {
  //       return const ModifyComPortPage();
  //     },
  //   ).then((value) => _updateStatus());
  // }

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
    // cntScaleTimerMgr.startCntScaleTimer(5);
  }

  void stopCheckSerialPort() {
    myScreenMgr.isMainScreen = false;
    cntScaleTimerMgr.stopCntScaleTimer();
  }
}
