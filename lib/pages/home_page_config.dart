import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../data/comscaleinfo_data.dart';
import '../data/manager_scale_channel.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/pages/labeldesign_page.dart';
import 'package:t_max/pages/wifisetting_page.dart';
import 'package:window_manager/window_manager.dart';
import '../data/company_info.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../dialog/get_build_info_dialog.dart';
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
import '../widget/update_firmware.dart';
import '../widget/version.dart';
import 'basic_data_page.dart';
import 'batch_delivery.dart';
import 'custom_serial_protocol_page.dart';
import 'down_recipt_fmt_page.dart';
import 'down_serial_output.dart';
import 'firmware_down_wifi.dart';
import 'lable_down_prn_fmt_page.dart';
import 'modify_com_port_page.dart';
import 'receipt_design_page.dart';
import 'scale_manager_page.dart';
import 'set_system_parameter.dart';
import 'set_system_time.dart';
import 'package:tray_manager/tray_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener, WindowListener {
  List<String> items = [];

  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  late ScrollController _pageScrollerController;
  dynamic _eventbus1;

  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;

  bool showHint1 = true;
  bool showHint2 = true;

  bool isResize = false;

  String groupValue = 'zh';
  DateTime now = DateTime.now();

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
  void onWindowClose() {
    // 关闭工厂模式（所有秤都关闭吗？）
  }

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    _scrollController2.addListener(_checkScrollPosition2);
    _scrollController1.addListener(_checkScrollPosition1);
    _init();
    _handleSetIcon();
    windowManager.setMinimumSize(Size(1320, 720));
    super.initState();
    _pageScrollerController = ScrollController();
    cntScaleTimerMgr.startCntScaleTimer(5);
    PublicFunctions.getWifiPwdList();

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
              PublicFunctions.getOneEepromInfo("wifi_or_bt", 1);
            } else {
              myComScaleInfo.isOnline = false;
              myComScaleSn.modelName = '';
              myComScaleSn.scaleSn = '';
              myComScaleInfo.isOnline = false;
              myScreenMgr.wifiOrBt = 'off';
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

    _eventbus5 = eventBus.on<EventGetOneEepromDateResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.contains('ok')) {
            if (myRespDataFromScale.msgBody.contains('bt')) {
              myScreenMgr.wifiOrBt = 'bt';
            } else if (myRespDataFromScale.msgBody.contains('wifi')) {
              myScreenMgr.wifiOrBt = 'wifi';
            } else if (myRespDataFromScale.msgBody.contains('off')) {
              myScreenMgr.wifiOrBt = 'off';
            }
          }
        });
      }
    });
    _eventbus6 = eventBus.on<EventLicenseData>().listen((event) {
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
    _eventbus7 = eventBus.on<EventCloseScalePassthResp>().listen((event) {
      if (mounted) {
        PublicFunctions.stopWeight(myDefScaleInfo.defScaleId!);
      }
    });
    _eventbus8 = eventBus.on<EventSerialPortResponse>().listen((event) {
      if (mounted) {
        if (myScreenMgr.isMainScreen) {
          setState(() {
            myRespDataFromScale = event.obj;
            if (myComScaleInfo.isOnline) {
              myComScaleInfo.isOnline = false;
              myComScaleSn.modelName = '';
              myComScaleSn.scaleSn = '';
              myComScaleInfo.isOnline = false;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('The serial port disconnected.',
                      style: const TextStyle(fontSize: 20)), ////此处需要秤回复
                  duration: const Duration(seconds: 5),
                  backgroundColor: Theme.of(context).colorScheme.error));
            }
          });
        }
      }
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
    _eventbus8.cancel();

    _pageScrollerController.dispose();
    cntScaleTimerMgr.stopCntScaleTimer();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    _scrollController2.dispose();
    _scrollController1.dispose();
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
                              Text(
                                  myTConLicInfo.isValid
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
                          (myComScaleInfo.isOnline)
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
                    thirdCard(),
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
      flex: 1,
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
                  (myComScaleSn.modelName != null)
                      ? SizedBox(
                          height: 90,
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
                                        myComScaleSn.modelName!,
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
                                        myComScaleSn.scaleSn!,
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
                        stopCheckSerialPort();
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ScaleManagerPage()),
                          ).then((value) => _updateStatus());
                        });
                      },
                      child: customFunctionCard(
                          context,
                          localizedStrings.m_scale_title,
                          Icons.schema_outlined,
                          true),
                    ),
                  ),
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
                                        const SetSystemTimePage()),
                              ).then((value) => _updateStatus());
                            });
                          });
                        },
                        child: customFunctionCard(
                            context,
                            localizedStrings.device_time_title,
                            Icons.date_range,
                            true),
                      )),
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
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            margin: const EdgeInsets.only(right: 20), // 根据实际需要设置容器间距
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: functionTitle(
                    localizedStrings.device_setting_title, Icons.settings),
              ),
              Expanded(
                  child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController1,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Column(children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: () {
                            //蓝牙页面\
                            if (myScreenMgr.wifiOrBt.contains('bt')) {
                              setState(() {
                                stopCheckSerialPort();
                                showBluetoothDialog(context);
                              });
                            }
                          },
                          child: customFunctionCard(
                              context,
                              localizedStrings.bt_setting_title,
                              Icons.bluetooth,
                              (myScreenMgr.wifiOrBt.contains('bt'))),
                        ),
                      ),
                      MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: () {
                              //wifi页面
                              if (myScreenMgr.wifiOrBt.contains('wifi')) {
                                setState(() {
                                  stopCheckSerialPort();
                                  PublicFunctions.changeWifiMode(1);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WifiSettingPage(),
                                    ),
                                  ).then((value) => _updateStatus());
                                });
                              }
                            },
                            child: customFunctionCard(
                                context,
                                localizedStrings.wifi_setting_title,
                                Icons.wifi,
                                (myScreenMgr.wifiOrBt.contains('wifi'))),
                          )),
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
                              context,
                              localizedStrings.update_firmware,
                              Icons.update,
                              true),
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
                                        const FirmwareDownPage()),
                              ).then((value) => _updateStatus());
                            });
                          },
                          child: customFunctionCard(
                              context,
                              localizedStrings.firm_down_online,
                              Icons.cloud_upload_outlined,
                              true),
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: () {
                            stopCheckSerialPort();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DownloadLabelPage()),
                            ).then((value) => _updateStatus());
                          },
                          child: customFunctionCard(
                              context,
                              localizedStrings.label_fmt_download,
                              Icons.arrow_circle_down_outlined,
                              true),
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: () {
                            stopCheckSerialPort();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DownReciptPage()),
                            ).then((value) => _updateStatus());
                          },
                          child: customFunctionCard(
                            context,
                            localizedStrings.receipt_format_download,
                            Icons.receipt_long_outlined,
                            true,
                          ),
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click, // 设置光标为手的形状
                        child: GestureDetector(
                          onTap: () {
                            stopCheckSerialPort();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DownSerialOutputPage()),
                            ).then((value) => _updateStatus());
                          },
                          child: customFunctionCard(
                              context,
                              localizedStrings.serial_output_download,
                              Icons.file_download_outlined,
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
                              context,
                              localizedStrings.get_build_info,
                              Icons.privacy_tip,
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

  Widget thirdCard() {
    return Expanded(
        flex: 1, // 设置一个容器的flex为2，在剩余空间中占用更多的比例
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: functionTitle(localizedStrings.advanced_setting_title,
                    Icons.settings_applications_outlined),
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
                            onTap: myTConLicInfo.isValid
                                ? () {
                                    showLabelDesign(myTConLicInfo.isValid);
                                  }
                                : null,
                            child: customFunctionCard(
                                context,
                                localizedStrings.label_design_title,
                                Icons.design_services,
                                myTConLicInfo.isValid),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myTConLicInfo.isValid
                                ? () {
                                    showReceiptDesign(myTConLicInfo.isValid);
                                  }
                                : null,
                            child: customFunctionCard(
                              context,
                              localizedStrings.receipt_design_title,
                              Icons.receipt,
                              myTConLicInfo.isValid,
                            ),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myTConLicInfo.isValid
                                ? () {
                                    stopCheckSerialPort();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const BatchDeliveryPage()),
                                    ).then((value) => _updateStatus());
                                  }
                                : null,
                            child: customFunctionCard(
                                context,
                                localizedStrings.batch_delivery_title,
                                Icons.system_update_alt,
                                myTConLicInfo.isValid),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click, // 设置光标为手的形状
                          child: GestureDetector(
                            onTap: myTConLicInfo.isValid
                                ? () {
                                    stopCheckSerialPort();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CustomSerialProtocol()),
                                    ).then((value) => _updateStatus());
                                  }
                                : null,
                            child: customFunctionCard(
                                context,
                                localizedStrings.serial_output_design,
                                Icons.usb_sharp,
                                myTConLicInfo.isValid),
                          ),
                        ),
                        MouseRegion(
                            cursor: SystemMouseCursors.click, // 设置光标为手的形状
                            child: GestureDetector(
                              onTap: myTConLicInfo.isValid
                                  ? () {
                                      setState(() {
                                        stopCheckSerialPort();
                                        setState(() {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const BasicDataPage()),
                                          ).then((value) => _updateStatus());
                                        });
                                      });
                                    }
                                  : null,
                              child: customFunctionCard(
                                  context,
                                  localizedStrings.abnormal_data_title,
                                  Icons.warning,
                                  myTConLicInfo.isValid),
                            )),
                        MouseRegion(
                            cursor: SystemMouseCursors.click, // 设置光标为手的形状
                            child: GestureDetector(
                              onTap: myTConLicInfo.isValid
                                  ? () {
                                      setState(() {
                                        stopCheckSerialPort();
                                        setState(() {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const SetParameterPage()),
                                          ).then((value) => _updateStatus());
                                        });
                                      });
                                    }
                                  : null,
                              child: customFunctionCard(
                                  context,
                                  localizedStrings.parameter_set_title,
                                  Icons.tune_outlined,
                                  myTConLicInfo.isValid),
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
                ),
              ),
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

    if (viewportDimension > 880) {
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

    if (viewportDimension > 700) {
      setState(() {
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

  void showReceiptDesign(bool isValid) {
    if (isValid) {
      stopCheckSerialPort();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReceiptDesignPage()),
      ).then((value) => _updateStatus());
    }
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

  void showBluetoothDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const BluetoothDialog();
      },
    ).then((value) => _updateStatus());
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

  void _updateStatus() {
    setState(() {});
    cntScaleTimerMgr.stopCntScaleTimer();
    cntScaleTimerMgr.startCntScaleTimer(5);
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

  void stopCheckSerialPort() {
    myScreenMgr.isMainScreen = false;
    cntScaleTimerMgr.stopCntScaleTimer();
  }
}
