import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:t_max/pages/wifi_setting_page.dart';
// import 'package:t_max/pages/scale_manager_page.dart';

import '../data/comscaleinfo_data.dart';

import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/pages/down_recipt_fmt_page.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../data/company_info.dart';
import '../data/language.dart';
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

import 'header_footer_page.dart';
import 'plu_edit_page.dart';

import 'receipt_design_page.dart';
import 'retail_report_page.dart';
import 'update_firmware_page.dart';

class RetailHomePage extends StatefulWidget {
  const RetailHomePage({super.key});

  @override
  State<RetailHomePage> createState() => _RetailHomePageState();
}

class _RetailHomePageState extends State<RetailHomePage>
    with TrayListener, WindowListener {
  List<String> items = [];

  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();

  late ScrollController _pageScrollerController;
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  dynamic _eventbus1;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;

  String groupValue = 'zh';
  DateTime now = DateTime.now();

  bool isCardHovered = false;
  bool isCardClicked = false;
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
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
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
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    _scrollController2.addListener(_checkScrollPosition2);
    _scrollController1.addListener(_checkScrollPosition1);

    _init();
    _handleSetIcon();

    super.initState();
    _pageScrollerController = ScrollController();
    // cntScaleTimerMgr.stopCntScaleTimer();
    // cntScaleTimerMgr.startCntScaleTimer(1);
    // _checkTimerFuc(5);
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
    _eventbus3 = eventBus.on<EventRespCheckComPort>().listen((event) {
      if (mounted) {
        if (myScreenMgr.isMainScreen) {
          setState(() {
            myComScaleSn = event.obj;
            if (myComScaleSn.modelName != '') {
              myComScaleInfo.isOnline = true;
              myComScaleInfo.isOnline = true;
            } else {
              myComScaleInfo.isOnline = false;
              myComScaleSn.modelName = '';
              myComScaleSn.scaleSn = '';
              myComScaleInfo.isOnline = false;
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
    _eventbus6 = eventBus.on<EventServiceOff>().listen((event) {
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
    _pageScrollerController.dispose();
    cntScaleTimerMgr.stopCntScaleTimer();
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    _scrollController2.dispose();
    _scrollController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isResize) {
      _checkInitialVisibility();
    }

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
              color: Theme.of(context).colorScheme.onPrimary,
              // foregroundColor: Theme.of(context).colorScheme.primary,
              child: Container(
                decoration: BoxDecoration(gradient: boxGradient(context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: SizedBox(
                          width: 360,
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
                          //   child: Text(localizedStrings.gSerialPortStatus,
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: functionTitle(
                  localizedStrings.device_configuration_title, Icons.settings),
            ),
            Expanded(
                child: Stack(
              children: [
                SingleChildScrollView(
                    controller: _scrollController1,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Column(
                      children: [
                        // (myComScaleSn.modelName != null)
                        //     ? SizedBox(
                        //         height: 90,
                        //         child: Column(
                        //           children: [
                        //             Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.start,
                        //               children: [
                        //                 const SizedBox(
                        //                   width: 30,
                        //                 ),
                        //                 Flexible(
                        //                   child: Text(
                        //                     localizedStrings.gModelName,
                        //                     maxLines: 1,
                        //                     overflow: TextOverflow.ellipsis,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //             Row(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.start,
                        //                 children: [
                        //                   const SizedBox(
                        //                     width: 30,
                        //                   ),
                        //                   Flexible(
                        //                     child: Text(
                        //                       myComScaleSn.modelName!,
                        //                       maxLines: 1,
                        //                       textAlign: TextAlign.start,
                        //                       style: const TextStyle(
                        //                           fontWeight: FontWeight.bold),
                        //                       overflow: TextOverflow.ellipsis,
                        //                     ),
                        //                   ),
                        //                 ]),
                        //             Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.start,
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
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.start,
                        //                 children: [
                        //                   const SizedBox(
                        //                     width: 30,
                        //                   ),
                        //                   Flexible(
                        //                     child: Text(
                        //                       myComScaleSn.scaleSn!,
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
                        // GestureDetector(
                        //   onTap: () {
                        //     stopCheckSerialPort();
                        //     setState(() {
                        //       PublicFunctions.getProductList();
                        //       PublicFunctions.getPortList();
                        //       showComPortDialog(context);
                        //     });
                        //   },
                        //   child: MouseRegion(
                        //     cursor: SystemMouseCursors.click,
                        //     child: customFunctionCard(
                        //       context,
                        //       localizedStrings.gTitleSerialPortConnection,
                        //       Icons.cable,
                        //       true,
                        //     ),
                        //   ),
                        // ),
                        // GestureDetector(
                        //   onTap: () {
                        //     stopCheckSerialPort();
                        //     setState(() {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) =>
                        //                 const ScaleManagerPage()),
                        //       ).then((value) => _updateStatus());
                        //     });
                        //   },
                        //   child: MouseRegion(
                        //     cursor: SystemMouseCursors.click,
                        //     child: customFunctionCard(
                        //         context,
                        //         localizedStrings.m_scale_title,
                        //         Icons.schema_outlined,
                        //         true),
                        //   ),
                        // ),
                        // GestureDetector(
                        //   onTap: () {
                        //     setState(() {
                        //       stopCheckSerialPort();
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) =>
                        //               const CableIpSettingPage(),
                        //         ),
                        //       ).then((value) => _updateStatus());
                        //     });
                        //   },
                        //   child: MouseRegion(
                        //     cursor: SystemMouseCursors.click,
                        //     child: customFunctionCard(
                        //       context,
                        //       localizedStrings.set_ethernet_ip_title,
                        //       Icons.settings_ethernet,
                        //       true,
                        //     ),
                        //   ),
                        // ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              stopCheckSerialPort();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateFirmwarePage()),
                              ).then((value) => _updateStatus());
                            });
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: customFunctionCard(
                                context,
                                localizedStrings.menuFirmwareUpdate,
                                Icons.cloud_upload_outlined,
                                true),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              stopCheckSerialPort();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PluEidtPage()),
                              ).then((value) => _updateStatus());
                            });
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: customFunctionCard(
                                context,
                                localizedStrings.menuPluManagement,
                                Icons.import_export,
                                true),
                          ),
                        ),

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
                      ],
                    )),
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
          ]),
        ));
  }

  Widget secondCard() {
    return Expanded(
      flex: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.tertiaryContainer,
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: functionTitle(localizedStrings.customization_setting_title,
                  Icons.app_registration),
            ),
            Expanded(
                child: Stack(children: [
              SingleChildScrollView(
                controller: _scrollController2,
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        stopCheckSerialPort();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionReportPage()),
                        ).then((value) => _updateStatus());
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: appCard(
                          context,
                          localizedStrings.menuRetailReport,
                          Icons.data_thresholding_outlined,
                          true,
                          localizedStrings.rTipDetailRpt,
                          '',
                        ),
                      ),
                    ),
                    //业务要求屏蔽
                    // GestureDetector(
                    //   onTap: () {
                    //     stopCheckSerialPort();
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => const DownloadLabelPage()),
                    //     ).then((value) => _updateStatus());
                    //   },
                    //   child: MouseRegion(
                    //     cursor: SystemMouseCursors.click,
                    //     child: appCard(
                    //       context,
                    //       localizedStrings.menuLabelFormatDownload,
                    //       Icons.design_services,
                    //       true,
                    //       localizedStrings.gTipLabelFmtDownload ,
                    //       '',
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          stopCheckSerialPort();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HeaderFooterPage(),
                            ),
                          ).then((value) => _updateStatus());
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: appCard(
                            context,
                            localizedStrings.menuVariableValueSetting,
                            Icons.edit_attributes_outlined,
                            true,
                            localizedStrings.rTipSetVariableValues,
                            ''),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       stopCheckSerialPort();
                    //       PublicFunctions.stopWeight(
                    //           myDefScaleInfo.defScaleId!);
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) =>
                    //                 const ProductDownloadPage()),
                    //       ).then((value) => _updateStatus());
                    //     });
                    //   },
                    //   child: MouseRegion(
                    //     cursor: SystemMouseCursors.click,
                    //     child: appCard(
                    //         context,
                    //         localizedStrings.gTitlePluDownload,
                    //         Icons.shopping_bag,
                    //         true,
                    //         localizedStrings.gTipPluDownload,
                    //         ''),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        stopCheckSerialPort();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DownReciptPage()),
                        ).then((value) => _updateStatus());
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: appCard(
                            context,
                            localizedStrings.menuReceiptFormatDownload,
                            Icons.receipt,
                            true,
                            localizedStrings.gTipReceiptDownload,
                            ''),
                      ),
                    ),
                    GestureDetector(
                      onTap: myRedeLicInfo.isValid
                          ? () {
                              showReceiptDesign(myRedeLicInfo.isValid);
                            }
                          : null,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: appCard(
                            context,
                            localizedStrings.menuReceiptDesign,
                            Icons.receipt,
                            myRedeLicInfo.isValid,
                            localizedStrings.gTipReceiptDesign,
                            myRedeLicInfo.liceseDate == "2299-01-01"
                                ? localizedStrings.gTipPerpetual
                                : myRedeLicInfo.liceseDate),
                      ),
                    ),
                  ],
                ),
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
            ])),
          ],
        ),
      ),
    );
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
    if (viewportDimension > 300) {
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

  void _updateStatus() {
    setState(() {});
    cntScaleTimerMgr.stopCntScaleTimer();
    // cntScaleTimerMgr.startCntScaleTimer(5);
  }

  void showReceiptDesign(bool isValid) {
    if (isValid) {
      stopCheckSerialPort();

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ReceiptDesignPage(
                  type: "",
                )),
      ).then((value) => _updateStatus());
    }
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

  void stopCheckSerialPort() {
    cntScaleTimerMgr.stopCntScaleTimer();
  }
}
