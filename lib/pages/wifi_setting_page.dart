// wifi 璁剧疆鐣岄潰 鍙兘鐢ㄤ覆鍙ｈ缃?

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';
import '../data/const_var_data.dart';
import '../data/downloadresponse.dart';
import 'package:t_max/data/respdata_data.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/data/wifi_ap_info.dart';
import 'package:t_max/data/wifi_list_info.dart';
import 'package:t_max/data/writelog.dart';

import '../data/ipinfodata.dart';
import '../data/language.dart';
import '../functions/adaptive.dart';
import '../data/timer_manager.dart';
import '../data/wifi_pwd_info.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/dialog/mobile_page_help_dialog.dart';

class WifiSettingPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const WifiSettingPage(
      {super.key, required this.onNavigate, required this.lastRouteName});

  @override
  State<WifiSettingPage> createState() => WifiSettingPageState();
}

class WifiSettingPageState extends State<WifiSettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> wifiItems = [];
  List<String> displayedItems = [];
  List<int> wifiRssiList = [];
  List<String> bssidList = [];
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController netMaskController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController gateWayController = TextEditingController();
  // TextEditingController dnsController = TextEditingController();
  final TextEditingController _findWifiText = TextEditingController();
  int selectedIndex = -1;
  bool passwordLock = true;
  final bool _isValidIP = true;
  final bool _isValidMask = true;
  final bool _isValidGateway = true;
  // bool _isValidDns = true;
  bool _isStatic = false;
  bool _enableRefresh = false;
  String bssId = '';
  String connectedSsid = '';
  String connectedMac = '';
  bool isConnecting = false;
  bool alreadyConnected = false;
  bool firstGetApList = true; //WIFI鍒楄〃杩涙潵鍙幏鍙栦竴娆?

  bool isSetting = false; //姝ｅ湪鎿嶄綔

  Timer? getIpTimer;

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;
  dynamic _eventbus10;
  dynamic _eventbus11;
  dynamic _eventbus12;

  int selScaleId = -1;

  List<Scale> comScalesList = [];

  TextEditingController controller = TextEditingController();
  RegExp ipaddressRegex = RegExp(r'[0-9.]');

  RegExp ipRegex = RegExp(
    r'^((\d{1,3}\.){3}\d{1,3})$',
    multiLine: false,
    caseSensitive: false,
  );

  void _startGetIP(int time) {
    getIpTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.getIpInfo(selScaleId);
      isSetting = true;
      _stopGetIp();
    });
  }

  void _stopGetIp() {
    getIpTimer?.cancel(); // 鍋滄璁℃椂鍣?
  }

  bool _isValidIpAddress(bool tempValid, String value) {
    if (tempValid) {
      List<int?> parts = value.split('.').map(int.tryParse).toList();
      if (parts.any((part) => part == null || part > 255)) {
        tempValid = false;
      }
    }
    return tempValid;
  }

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();
    PublicFunctions.getWifiPwdList();

    for (var scale in myAllScalesList) {
      if (scale.tMedia == comScaleType) {
        comScalesList.add(scale);
      }
    }

    if (myWifiListInfo.wifidatalist!.isNotEmpty) {
      for (var i = 0; i < myWifiListInfo.wifidatalist!.length; i++) {
        if (myWifiListInfo.wifidatalist![i].ssid!.isNotEmpty) {
          wifiItems.add(myWifiListInfo.wifidatalist![i].ssid!);
          bssidList.add(myWifiListInfo.wifidatalist![i].mac!);
          wifiRssiList.add(myWifiListInfo.wifidatalist![i].rssi!);
        }
      }
    } else {
      wifiItems = [];
      wifiRssiList = [];
      bssidList = [];
    }
    displayedItems = List.from(wifiItems);
    ssidController.text = "";

    _eventbus1 = eventBus.on<EventWiFiListInfo>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myWifiListInfo = event.obj;
          _findWifiText.text = '';
          wifiRssiList.clear();
          wifiItems.clear();
          bssidList.clear();
          displayedItems.clear();
          if (myWifiListInfo.wifidatalist!.isNotEmpty) {
            for (var i = 0; i < myWifiListInfo.wifidatalist!.length; i++) {
              if (myWifiListInfo.wifidatalist![i].ssid!.isNotEmpty) {
                wifiItems.add(myWifiListInfo.wifidatalist![i].ssid!);
                bssidList.add(myWifiListInfo.wifidatalist![i].mac!);
                wifiRssiList.add(myWifiListInfo.wifidatalist![i].rssi!);
              }
            }
          } else {}
          displayedItems = List.from(wifiItems);
          _enableRefresh = true;
        });
      }
    });
    _eventbus2 = eventBus.on<EventConnectDynamicIp>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            if (myRespDataFromScale.msgBody.contains(msgOk)) {
              isConnecting = false;

              showTipInfo(
                  (localizedStrings?.gTipGetIP ?? "gTipGetIP"), context);

              _startGetIP(2);
            } else {
              isConnecting = false;

              showTipInfo(myRespDataFromScale.msgBody, context);

              _startGetIP(2);
            }
          }
        });
      }
    });
    _eventbus3 = eventBus.on<EventConnectStaticIp>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            if (myRespDataFromScale.msgBody.contains(msgOk)) {
              isConnecting = false;
              if (alreadyConnected) {
                showTipInfo(
                    (localizedStrings?.gTipConnected ?? "gTipConnected"),
                    context);
              } else {
                connectAp();
              }
            } else {
              showTipInfo(myRespDataFromScale.msgBody, context);
            }
          }
        });
      }
    });

    _eventbus4 = eventBus.on<EventIpInfo>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myIpInfoData = event.obj;
          isConnecting = false;

          if (myIpInfoData.iP != null) {
            if (myIpInfoData.iP != '0.0.0.0') {
              ipController.text = myIpInfoData.iP!;
              gateWayController.text = myIpInfoData.gateway!;
              netMaskController.text = myIpInfoData.netmask!;

              showTipInfo(
                  (localizedStrings?.gTipGetIpOk ?? "gTipGetIpOk"), context);
            } else {
              showTipInfo((localizedStrings?.gTipGetIpFail ?? "gTipGetIpFail"),
                  context);
            }

            PublicFunctions.getIpMode(selScaleId);
            isSetting = true;
          }
        });
      }
    });

    _eventbus5 = eventBus.on<EventMessageError>().listen((event) {
      if (mounted) {
        isSetting = false;
        setState(() {
          myMessageError = event.obj;
          if (!myMessageError.messagedata!.contains(msgOk)) {
            showTipInfo(myMessageError.messagedata!, context);
          }
        });
      }
    });

    _eventbus6 = eventBus.on<EventGetIpError>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myGetIpError = event.obj;
          if (!myGetIpError.messagedata!.contains(msgOk)) {
            showTipInfo(myGetIpError.messagedata!, context);
          }

          isConnecting = false;
        });

        setState(() {
          PublicFunctions.getIpMode(selScaleId);
          isSetting = true;
        });
      }
    });
    _eventbus7 = eventBus.on<EventRespGetIpMode>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myRespGetIpMode = event.obj;
          if (myRespGetIpMode.messagedata!.isNotEmpty) {
            if (myRespGetIpMode.messagedata == wifiDhcp) {
              _isStatic = false;
            } else if (myRespGetIpMode.messagedata == wifiStatic) {
              _isStatic = true;
            }
          }
        });
        if (firstGetApList) {
          showTipInfo(
              (localizedStrings?.gTipGetAPList ?? "gTipGetAPList"), context);
          PublicFunctions.getWifiList(selScaleId);
          isSetting = true;
          firstGetApList = false;
        }
      }
    });

    _eventbus8 = eventBus.on<EventGetWifiListError>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myGetWifiListError = event.obj;

          showTipInfo(myGetWifiListError.messagedata!, context);
          _enableRefresh = true;
        });
      }
    });

    _eventbus9 = eventBus.on<EventGetWifiApInfo>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myWiFiAPInfo = event.obj;
          if (myWiFiAPInfo.ssid!.isNotEmpty) {
            connectedSsid = myWiFiAPInfo.ssid!;
            connectedMac = myWiFiAPInfo.bssid!;
            ssidController.text = myWiFiAPInfo.ssid!;
            passwordController.text = getWifiPwd(myWiFiAPInfo.ssid!);
            cntScaleTimerMgr.stopCntScaleTimer();
          } else {
            connectedSsid = "";
            connectedMac = "";
            ssidController.text = "";
            passwordController.text = "";
            ipController.clear();
            gateWayController.clear();
            netMaskController.clear();
          }
          _startGetIP(1);
        });
      }
    });

    _eventbus10 = eventBus.on<EventConnectAp>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            if (myRespDataFromScale.msgBody.contains(msgOk)) {
              isConnecting = false;

              showTipInfo(
                  (localizedStrings?.gTipGetIP ?? "gTipGetIP"), context);
              cntScaleTimerMgr.stopCntScaleTimer();
            } else {
              isConnecting = false;

              showTipInfo(myRespDataFromScale.msgBody, context);
              cntScaleTimerMgr.stopCntScaleTimer();
            }
          }
        });
        PublicFunctions.getApInfo(selScaleId);
        isSetting = true;
      }
    });

    _eventbus11 = eventBus.on<EventRespChangeWiFiMode>().listen((event) {
      if (mounted) {
        setState(() {
          isSetting = false;
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.contains(msgOk)) {
            cntScaleTimerMgr.stopCntScaleTimer();

            isSetting = true;
          } else {
            _enableRefresh = true;

            showTipInfo(myRespDataFromScale.msgBody, context);
          }
          PublicFunctions.getApInfo(selScaleId);
        });
      }
    });
    _eventbus12 = eventBus.on<EventRevWifiPwdAdd>().listen((event) {
      if (mounted) {
        PublicFunctions.getWifiPwdList();
      }
    });
    // 鍦ㄩ〉闈㈡瀯寤哄畬鎴愬悗鏄剧ず鎻愮ず
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (comScalesList.isEmpty) {
        showTipInfo(
            (localizedStrings?.gTipNoDeviceAddFirst ?? "gTipNoDeviceAddFirst"),
            context);
      } else {
        if (selScaleId == -1) {
          showTipInfo(
              (localizedStrings?.gTipSelectDeviceFirst ??
                  "gTipSelectDeviceFirst"),
              context);
        }
      }
    });
  }

  @override
  void dispose() {
    _eventbus3.cancel();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();
    _eventbus10.cancel();
    _eventbus11.cancel();
    _eventbus12.cancel();

    myWifiListInfo.wifidatalist!.clear();
    myWifiPwdInfoList.clear;

    _stopGetIp();
    ssidController.dispose();
    passwordController.dispose();
    netMaskController.dispose();
    ipController.dispose();
    gateWayController.dispose();
    _findWifiText.dispose();
    controller.dispose();
    super.dispose();
  }

  Widget buildWifiList() {
    return Expanded(
      child: ListView.builder(
        itemCount: displayedItems.length,
        itemBuilder: (context, index) {
          return Column(children: [
            if (index > 0) const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.only(
                left: regularPadding,
                right: regularPadding,
              ),
              child: buildWifiItem(index),
            )
          ]);
        },
      ),
    );
  }

  Widget buildWifiItem(int index) {
    return Container(
      height: scaleItemHeight,
      color: selectedIndex == index
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          ListTile(
            dense: true,
            title: SizedBox(
              child: Text(
                displayedItems[index],
                maxLines: 1, // 璁剧疆鏂囨湰鏈€澶ц鏁颁负1
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color: selectedIndex == index
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            subtitle: Container(
                padding: EdgeInsets.only(top: smallPadding),
                child: Text(
                  bssidList[index],
                  maxLines: 1, // 璁剧疆鏂囨湰鏈€澶ц鏁颁负1

                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: selectedIndex == index
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                )),
            trailing: buildWifiIcon(index),
            tileColor: selectedIndex == index
                ? Theme.of(context).colorScheme.scrim
                : null,
            onTap: () {
              setState(() {
                selectedIndex = index;
                ssidController.text = displayedItems[index];
                passwordController.text = getWifiPwd(ssidController.text);
                if (index < myWifiListInfo.wifidatalist!.length) {
                  bssId = myWifiListInfo.wifidatalist![index].mac!;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildWifiIcon(int index) {
    return selectedIndex == index
        ? Image.asset(
            wifiRssiList[index] == 4
                ? wifi4WhiteSvgIcon()
                : wifiRssiList[index] == 3
                    ? wifi3WhiteSvgIcon()
                    : wifiRssiList[index] == 2
                        ? wifi2WhiteSvgIcon()
                        : wifi1WhiteSvgIcon(),
            width: 26,
            height: 26,
          )
        : Image.asset(
            wifiRssiList[index] == 4
                ? wifi4BlueSvgIcon()
                : wifiRssiList[index] == 3
                    ? wifi3BlueSvgIcon()
                    : wifiRssiList[index] == 2
                        ? wifi2BlueSvgIcon()
                        : wifi1BlueSvgIcon(),
            width: 26,
            height: 26,
          );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = Adaptive.isMobile(context);

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: _buildMobileDrawer(context),
        body: _buildMobileContent(context, width),
      );
    }

    return Scaffold(
      drawer: null,
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            if (isMobile)
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Builder(builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.menu_open,
                        color: Theme.of(context).colorScheme.primary, size: 28),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                }),
                title: Text(
                  (localizedStrings?.menuWifiSetting ?? "menuWifiSetting"),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            Expanded(
              child: Row(
                children: [
                  if (!isMobile)
                    Container(
                      width: 220,
                      color: Theme.of(context).colorScheme.surfaceTint,
                      child: NewComScaleListWidget(
                        listWidth: 220,
                        selScaleId: selScaleId,
                        clickScale: (scale) {
                          if (isSetting) {
                            showTipInfo(
                                (localizedStrings?.gTipPerformingOperation ??
                                    "gTipPerformingOperation"),
                                context);
                            return;
                          }
                          setState(() {
                            changeScale(scale.scaleId);
                          });
                        },
                      ),
                    ),
                  if (!isMobile)
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double minWidth = isMobile ? 500 : 760;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: constraints.maxWidth < minWidth
                                ? minWidth
                                : constraints.maxWidth,
                            child: Row(
                              children: [
                                if (!isMobile)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: comScalesList.isEmpty
                                        ? const SizedBox()
                                        : showWifiListWidget(),
                                  ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: comScalesList.isEmpty
                                        ? const SizedBox()
                                        : showRightWigdet(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changeScale(int scaleId) {
    setState(() {
      displayedItems.clear();
      ssidController.clear();
      passwordController.clear();
      netMaskController.clear();
      ipController.clear();
      gateWayController.clear();
      connectedSsid = "";
      connectedMac = "";

      selScaleId = scaleId;
      // PublicFunctions.stopWeight(selScaleId);

      showTipInfo(
          (localizedStrings?.gTipGetApListAndIP ?? "gTipGetApListAndIP"),
          context);
      PublicFunctions.changeWifiMode(selScaleId);

      isSetting = true;
      firstGetApList = true;
    });
  }

  Widget showWifiListWidget() {
    final bool isMobile = Adaptive.isMobile(context);
    return SizedBox(
      width: isMobile ? double.infinity : wifiListWidth,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                  padding: EdgeInsets.only(
                    top: regularPadding,
                    left: regularPadding,
                    right: regularPadding,
                  ),
                  height: 66,
                  child: Column(
                    children: [
                      SizedBox(
                          child: Row(children: [
                        Expanded(
                            child: SizedBox(
                          height: 38,
                          child: TextField(
                            textAlign: TextAlign.left,
                            controller: _findWifiText,
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                splashRadius: 20,
                                icon: Icon(
                                  Icons.close,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _findWifiText.clear();
                                    displayedItems = wifiItems;
                                  });
                                },
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              labelText:
                                  (localizedStrings?.gFindSsid ?? "gFindSsid"),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary, // 璁剧疆杈规棰滆壊
                                  width: 1.0, // 璁剧疆杈规瀹藉害
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(0)),
                              ),
                            ),
                            onChanged: (value) {
                              List<String> filteredItems = wifiItems
                                  .where((item) => item
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              setState(() {
                                displayedItems = filteredItems;
                              });
                            },
                          ),
                        )),
                        SizedBox(
                          width: smallPadding,
                        ),
                        Container(
                          width: 38, // 涓篊ontainer鎸囧畾涓€涓浐瀹氱殑瀹藉害
                          height: 38,
                          color:
                              Theme.of(context).colorScheme.surfaceContainerLow,
                          child: Tooltip(
                            message: (localizedStrings?.gMsgRefresh ??
                                "gMsgRefresh"),
                            child: IconButton(
                              splashRadius: 20,
                              onPressed: _enableRefresh
                                  ? () {
                                      setState(() {
                                        displayedItems.clear();
                                        _enableRefresh = false;
                                      });

                                      showTipInfo(
                                          (localizedStrings?.gTipGetAPList ??
                                              "gTipGetAPList"),
                                          context);
                                      PublicFunctions.getWifiList(selScaleId);
                                      isSetting = true;
                                    }
                                  : null,
                              icon: Icon(
                                Icons.refresh,
                                color: _enableRefresh
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondaryFixed,
                              ),
                            ),
                          ),
                        ),
                      ])),
                    ],
                  )),
              buildWifiList()
            ],
          ),
        ),
      ),
    );
  }

  Widget showRightWigdet() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final fieldWidth = constraints.maxWidth.clamp(0.0, 450.0);
                  return Column(
                    children: [
                      Center(
                        child: Container(
                          width: fieldWidth,
                          height: 100,
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: regularPadding),
                              Text(
                                getScaleModel() == "DPM"
                                    ? (localizedStrings?.gTipConnectedInfo ??
                                            "gTipConnectedInfo") +
                                        "            (Port: 8580)"
                                    : (localizedStrings?.gTipConnectedInfo ??
                                        "gTipConnectedInfo"),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .apply(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: regularPadding),
                              Text(
                                connectedSsid,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: smallPadding),
                              Text(
                                connectedMac,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: regularPadding),
                      Center(
                        child: Container(
                          width: fieldWidth,
                          height: 81,
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    localizedStrings?.gTipSSID ?? "gTipSSID"),
                              ),
                              TextField(
                                readOnly: false,
                                controller: ssidController,
                                onChanged: (value) {},
                                maxLines: 1,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(28),
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[\x00-\xF]+$')),
                                ],
                                textAlign: TextAlign.start,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: regularPadding),
                      Center(
                        child: Container(
                          width: fieldWidth,
                          height: 81,
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    localizedStrings?.gPassword ?? "gPassword"),
                              ),
                              TextField(
                                controller: passwordController,
                                textAlign: TextAlign.start,
                                textAlignVertical: TextAlignVertical.center,
                                obscureText: passwordLock,
                                maxLines: 1,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20),
                                  FilteringTextInputFormatter.allow(RegExp(
                                      r'^[ -~!@#$%^&*()_+<>?:"{},.\/;]+$')),
                                ],
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(passwordLock
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        passwordLock = !passwordLock;
                                      });
                                    },
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                onChanged: (value) {
                                  isValidData();
                                  setState(() {});
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: regularPadding),
                      Center(
                        child: Container(
                          width: fieldWidth,
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                alignment: Alignment.centerLeft,
                                child: Text(localizedStrings?.gIpAddress ??
                                    "gIpAddress"),
                              ),
                              SizedBox(
                                height: 78,
                                child: TextField(
                                  readOnly: !_isStatic,
                                  controller: ipController,
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: validateIpFlag(ipController.text)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .outlineVariant
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                    errorText: validateIpFlag(ipController.text)
                                        ? null
                                        : (localizedStrings?.gTipErrorIp ??
                                            "gTipErrorIp"),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: !_isStatic
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.5)
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: fieldWidth,
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    localizedStrings?.gNetmask ?? "gNetmask"),
                              ),
                              SizedBox(
                                height: 78,
                                child: TextField(
                                  readOnly: !_isStatic,
                                  controller: netMaskController,
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: validateIpFlag(
                                                netMaskController.text)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .outlineVariant
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                    errorText:
                                        validateIpFlag(netMaskController.text)
                                            ? null
                                            : (localizedStrings?.gTipErrorIp ??
                                                "gTipErrorIp"),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                          color: !_isStatic
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: fieldWidth,
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    localizedStrings?.gGateway ?? "gGateway"),
                              ),
                              SizedBox(
                                height: 78,
                                child: TextField(
                                  readOnly: !_isStatic,
                                  controller: gateWayController,
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: validateIpFlag(
                                                gateWayController.text)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .outlineVariant
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                    errorText:
                                        validateIpFlag(gateWayController.text)
                                            ? null
                                            : (localizedStrings?.gTipErrorIp ??
                                                "gTipErrorIp"),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                          color: !_isStatic
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double centerWidth = constraints.maxWidth;
                  double btnWidth = 120.0;
                  if (centerWidth > 560) {
                    btnWidth = (centerWidth - 80) / 4;
                    if (btnWidth > 200) btnWidth = 200;
                  }

                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: btnWidth,
                          height: 48,
                          margin: const EdgeInsets.symmetric(
                              horizontal: smallPadding),
                          child: showTextButton(
                              context,
                              btnHeight,
                              (localizedStrings?.gBtnGetIp ?? "gBtnGetIp"),
                              isConnecting || isSetting
                                  ? null
                                  : () {
                                      PublicFunctions.getIpInfo(selScaleId);
                                      isSetting = true;
                                    },
                              Theme.of(context).colorScheme.onPrimary,
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                        Container(
                          width: btnWidth,
                          height: 48,
                          margin: const EdgeInsets.symmetric(
                              horizontal: smallPadding),
                          child: showTextButton(
                              context,
                              btnHeight,
                              (localizedStrings?.gBtnStatic ?? "gBtnStatic"),
                              (_isStatic || isConnecting || isSetting)
                                  ? null
                                  : () {
                                      setState(() {
                                        _isStatic = true;
                                        showTipInfo(
                                            (localizedStrings
                                                    ?.gTipConnectStaticIp ??
                                                "gTipConnectStaticIp"),
                                            context);
                                      });
                                    },
                              Theme.of(context).colorScheme.onPrimary,
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                        Container(
                          width: btnWidth,
                          height: 48,
                          margin: const EdgeInsets.symmetric(
                              horizontal: smallPadding),
                          child: showTextButton(
                              context,
                              btnHeight,
                              (localizedStrings?.gBtnDynamic ?? "gBtnDynamic"),
                              (_isStatic && !isConnecting && !isSetting)
                                  ? () {
                                      setState(() {
                                        _isStatic = false;
                                      });
                                      PublicFunctions.setWifiDynamicMode(
                                          selScaleId);
                                      isSetting = true;
                                    }
                                  : null,
                              Theme.of(context).colorScheme.onPrimary,
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                        Container(
                          width: btnWidth,
                          height: 48,
                          margin: const EdgeInsets.symmetric(
                              horizontal: smallPadding),
                          child: showTextButton(
                              context,
                              btnHeight,
                              (localizedStrings?.gBtnConnect ?? "gBtnConnect"),
                              (isValidData() && !isConnecting && !isSetting)
                                  ? () {
                                      showTipInfo(
                                          (localizedStrings?.gTipConnecting ??
                                              "gTipConnecting"),
                                          context);
                                      isConnecting = true;
                                      cntScaleTimerMgr.stopCntScaleTimer();
                                      if (_isStatic) {
                                        connectStaticIp();
                                      } else {
                                        connectDynamicIp();
                                      }
                                    }
                                  : null,
                              Theme.of(context).colorScheme.onPrimary,
                              Theme.of(context)
                                  .colorScheme
                                  .onTertiaryFixedVariant,
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getScaleModel() {
    String model = "";
    if (myAllScalesList.isNotEmpty) {
      for (var i = 0; i < myAllScalesList.length; i++) {
        if (myAllScalesList[i].scaleId == selScaleId) {
          model = myAllScalesList[i].scaleModel;
          break;
        }
      }
    }
    return model;
  }

  bool isValidData() {
    if (selScaleId == -1) return false;

    if (ssidController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      return false;
    }

    if (_isStatic) {
      if (ipController.text.trim().isEmpty ||
          netMaskController.text.trim().isEmpty ||
          gateWayController.text.trim().isEmpty) {
        return false;
      }
      if (!validateIpFlag(ipController.text.trim()) ||
          !validateIpFlag(netMaskController.text.trim()) ||
          !validateIpFlag(gateWayController.text.trim())) {
        return false;
      }
    }

    return true;
  }

  String getWifiPwd(String ssid) {
    if (myWifiPwdInfoList.isEmpty) {
      return "";
    }
    for (var i = 0; i < myWifiPwdInfoList.length; i++) {
      if (myWifiPwdInfoList[i].ssid == ssid) {
        return myWifiPwdInfoList[i].pwd;
      }
    }
    return "";
  }

  void connectAp() {
    myScaleCmd.cmdMode = 'connect_ap';
    myConnectApInfo.ssid = ssidController.text;
    myConnectApInfo.password = passwordController.text;
    myConnectApInfo.bssid = bssId; //鎵嬪姩杈撳叆鐨勫浣曞鐞嗭紵id鍐?1
    myScaleCmd.cmdData = jsonEncode(myConnectApInfo).toString();

    PublicFunctions.sendMsg(selScaleId, jsonEncode(myScaleCmd));
    isSetting = true;
    writelog(jsonEncode(myScaleCmd));
    addWifiPwd();
  }

  void addWifiPwd() {
    myWifiPwdInfo.ssid = ssidController.text;
    myWifiPwdInfo.pwd = passwordController.text;
    String wifiStr = jsonEncode(myWifiPwdInfo).toString();

    PublicFunctions.addWifiPwd(wifiStr);
  }

  void connectDynamicIp() {
    if (myWiFiAPInfo.ssid == ssidController.text &&
        myWiFiAPInfo.bssid == bssId) {
      isConnecting = false;

      showTipInfo(
          (localizedStrings?.gTipConnected ?? "gTipConnected"), context);
    } else {
      myRespDataFromScale.msgBody = '';
      connectAp();
    }
  }

  void connectStaticIp() {
    String inputGateway = gateWayController.text;
    String inputIp = ipController.text;
    String inputNetmask = netMaskController.text;

    if (myWiFiAPInfo.ssid == ssidController.text &&
        myWiFiAPInfo.bssid == bssId) {
      alreadyConnected = true;
      sendStaticIpInfo(inputIp, inputGateway, inputNetmask);
    } else {
      alreadyConnected = false;
      sendStaticIpInfo(inputIp, inputGateway, inputNetmask);
    }
  }

  void sendStaticIpInfo(String ip, String gateway, String netmask) {
    myScaleCmd.cmdMode = 'set_wifi_static_ip';
    myStaticIpInfo.gateway = gateway;
    myStaticIpInfo.ip = ip;
    myStaticIpInfo.netmask = netmask;
    myScaleCmd.cmdData = jsonEncode(myStaticIpInfo).toString();

    PublicFunctions.sendMsg(selScaleId, jsonEncode(myScaleCmd));
    isSetting = true;
    writelog(jsonEncode(myScaleCmd));
  }

  bool validateIpFlag(String value) {
    bool isValid = false;

    if (value != '') {
      isValid = ipRegex.hasMatch(value);
      isValid = _isValidIpAddress(isValid, value);
    } else {
      isValid = true;
    }

    return isValid;
  }

  Widget _buildMobileContent(BuildContext context, double width) {
    bool canGetIp = (selScaleId != -1 && !isConnecting && !isSetting);
    bool canToggleStatic =
        (selScaleId != -1 && !_isStatic && !isConnecting && !isSetting);
    bool canToggleDynamic =
        (selScaleId != -1 && _isStatic && !isConnecting && !isSetting);
    bool canConnect =
        (selScaleId != -1 && isValidData() && !isConnecting && !isSetting);

    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 96,
        leading: Builder(
          builder: (BuildContext ctx) {
            return Row(
              children: [
                const SizedBox(width: 4),
                BackButton(
                  color: Colors.black87,
                  onPressed: () => Navigator.pop(context),
                ),
                MobileScaleHeaderIconButton(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ],
            );
          },
        ),
        title: Text(
          localizedStrings?.menuWifiSetting ?? "Wi-Fi Setting",
          style: const TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              showMobilePageHelpDialog(
                context,
                localizedStrings?.menuWifiSetting ?? "Wi-Fi Setting",
                localizedStrings?.gTipWifiSettingPageHelp ?? "Help instructions for Wi-Fi Setting page.",
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedStrings?.gTipConnectedInfo ?? "Connected AP Info",
                    style: const TextStyle(
                        color: Color(0xFF005696),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        connectedSsid.isEmpty ? "-" : connectedSsid,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        connectedMac.isEmpty ? "-" : connectedMac,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                  // Select Wi-Fi Tile
                  GestureDetector(
                    onTap: selScaleId == -1
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MobileSelectWifiPage(
                                  wifiItems: wifiItems,
                                  bssidList: bssidList,
                                  wifiRssiList: wifiRssiList,
                                  currentSelectedSsid: ssidController.text,
                                  onRefresh: () {
                                    showTipInfo(
                                        localizedStrings?.gTipGetAPList ??
                                            "Getting AP List",
                                        context);
                                    PublicFunctions.getWifiList(selScaleId);
                                    setState(() {
                                      isSetting = true;
                                    });
                                  },
                                  onConfirm: (ssid, bssid) {
                                    setState(() {
                                      ssidController.text = ssid;
                                      passwordController.text =
                                          getWifiPwd(ssid);
                                      bssId = bssid;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Select Wi-Fi",
                            style: TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                          Row(
                            children: [
                              Text(
                                ssidController.text.isEmpty
                                    ? ""
                                    : ssidController.text,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: Colors.black54),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),
                  // SSID Field
                  const Text(
                    "SSID",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: ssidController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(28),
                    ],
                    onChanged: (val) => setState(() {}),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password Field
                  const Text(
                    "Password",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: passwordController,
                    obscureText: passwordLock,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                    ],
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      border: const UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordLock
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordLock = !passwordLock;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // IPv4 Field
                  const Text(
                    "IPv4",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: ipController,
                    readOnly: !_isStatic,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      border: const UnderlineInputBorder(),
                      errorText: (_isStatic &&
                              ipController.text.isNotEmpty &&
                              !validateIpFlag(ipController.text))
                          ? (localizedStrings?.gTipErrorIp ?? "Invalid IP")
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Netmask Field
                  const Text(
                    "Netmask",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: netMaskController,
                    readOnly: !_isStatic,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      border: const UnderlineInputBorder(),
                      errorText: (_isStatic &&
                              netMaskController.text.isNotEmpty &&
                              !validateIpFlag(netMaskController.text))
                          ? (localizedStrings?.gTipErrorIp ?? "Invalid IP")
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Gateway Field
                  const Text(
                    "Gateway",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: gateWayController,
                    readOnly: !_isStatic,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      border: const UnderlineInputBorder(),
                      errorText: (_isStatic &&
                              gateWayController.text.isNotEmpty &&
                              !validateIpFlag(gateWayController.text))
                          ? (localizedStrings?.gTipErrorIp ?? "Invalid IP")
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Buttons
          if (!isKeyboardOpen)
            Container(
              padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  // Get Ip
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canGetIp
                          ? () {
                              PublicFunctions.getIpInfo(selScaleId);
                              setState(() {
                                isSetting = true;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canGetIp
                            ? const Color(0xFF005696)
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Text(
                        localizedStrings?.gBtnGetIp ?? "Get Ip",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Static
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canToggleStatic
                          ? () {
                              setState(() {
                                _isStatic = true;
                                showTipInfo(
                                    localizedStrings?.gTipConnectStaticIp ??
                                        "Connect Static IP",
                                    context);
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isStatic
                            ? const Color(0xFF005696)
                            : (canToggleStatic ? Colors.white : Colors.grey[200]),
                        foregroundColor: _isStatic
                            ? Colors.white
                            : (canToggleStatic ? const Color(0xFF005696) : Colors.grey[500]),
                        disabledBackgroundColor: _isStatic
                            ? const Color(0xFF005696)
                            : Colors.grey[200],
                        disabledForegroundColor: _isStatic
                            ? Colors.white
                            : Colors.grey[500],
                        side: BorderSide(
                          color: (selScaleId == -1 || isConnecting || isSetting)
                              ? Colors.grey[300]!
                              : const Color(0xFF005696),
                          width: 1.5,
                        ),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Text(
                        _isStatic
                            ? "${localizedStrings?.gBtnStatic ?? "Static"}  ✓"
                            : (localizedStrings?.gBtnStatic ?? "Static"),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Dynamic
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canToggleDynamic
                          ? () {
                              setState(() {
                                _isStatic = false;
                              });
                              PublicFunctions.setWifiDynamicMode(selScaleId);
                              setState(() {
                                isSetting = true;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isStatic
                            ? const Color(0xFF005696)
                            : (canToggleDynamic ? Colors.white : Colors.grey[200]),
                        foregroundColor: !_isStatic
                            ? Colors.white
                            : (canToggleDynamic ? const Color(0xFF005696) : Colors.grey[500]),
                        disabledBackgroundColor: !_isStatic
                            ? const Color(0xFF005696)
                            : Colors.grey[200],
                        disabledForegroundColor: !_isStatic
                            ? Colors.white
                            : Colors.grey[500],
                        side: BorderSide(
                          color: (selScaleId == -1 || isConnecting || isSetting)
                              ? Colors.grey[300]!
                              : const Color(0xFF005696),
                          width: 1.5,
                        ),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Text(
                        !_isStatic
                            ? "${localizedStrings?.gBtnDynamic ?? "Dynamic"}  ✓"
                            : (localizedStrings?.gBtnDynamic ?? "Dynamic"),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Connect
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canConnect
                          ? () {
                              showTipInfo(
                                  localizedStrings?.gTipConnecting ??
                                      "Connecting",
                                  context);
                              setState(() {
                                isConnecting = true;
                              });
                              cntScaleTimerMgr.stopCntScaleTimer();
                              if (_isStatic) {
                                connectStaticIp();
                              } else {
                                connectDynamicIp();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canConnect
                            ? const Color(0xFF1CB079)
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Text(
                        localizedStrings?.gBtnConnect ?? "Connect",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return UnifiedDeviceDrawerContent(
      scaleList: comScalesList,
      isSelected: (scale) => selScaleId == scale.scaleId,
      onScaleTap: (scale) {
        if (isSetting) {
          showTipInfo(
            localizedStrings?.gTipPerformingOperation ?? "Performing operation",
            context,
          );
          return;
        }
        Navigator.pop(context);
        changeScale(scale.scaleId);
      },
    );
  }
}

class MobileSelectWifiPage extends StatefulWidget {
  final List<String> wifiItems;
  final List<String> bssidList;
  final List<int> wifiRssiList;
  final String currentSelectedSsid;
  final VoidCallback onRefresh;
  final Function(String ssid, String bssid) onConfirm;

  const MobileSelectWifiPage({
    super.key,
    required this.wifiItems,
    required this.bssidList,
    required this.wifiRssiList,
    required this.currentSelectedSsid,
    required this.onRefresh,
    required this.onConfirm,
  });

  @override
  State<MobileSelectWifiPage> createState() => _MobileSelectWifiPageState();
}

class _MobileSelectWifiPageState extends State<MobileSelectWifiPage> {
  TextEditingController searchController = TextEditingController();
  List<String> filteredItems = [];
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(widget.wifiItems);
    if (widget.currentSelectedSsid.isNotEmpty) {
      selectedIndex = widget.wifiItems.indexOf(widget.currentSelectedSsid);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterWifi(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(widget.wifiItems);
      } else {
        filteredItems = widget.wifiItems
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Select Wi-Fi",
          style: TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: _filterWifi,
                      decoration: const InputDecoration(
                        hintText: "Search Name",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    widget.onRefresh();
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEF4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.refresh, color: Color(0xFF005696)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      localizedStrings?.gTipNoData ?? "No Data",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, index) {
                      final ssid = filteredItems[index];
                      final origIndex = widget.wifiItems.indexOf(ssid);
                      final bssid =
                          (origIndex >= 0 && origIndex < widget.bssidList.length)
                              ? widget.bssidList[origIndex]
                              : "";

                      final bool isSelected = (selectedIndex == origIndex);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = origIndex;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          color:
                              isSelected ? const Color(0xFF005696) : Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ssid,
                                    style: TextStyle(
                                      color:
                                          isSelected ? Colors.white : Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bssid,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.wifi,
                                color:
                                    isSelected ? Colors.white : const Color(0xFF005696),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: selectedIndex != -1
                      ? () {
                          final selectedSsid = widget.wifiItems[selectedIndex];
                          final selectedBssid =
                              widget.bssidList[selectedIndex];
                          widget.onConfirm(selectedSsid, selectedBssid);
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedIndex != -1
                        ? const Color(0xFF1CB079)
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    localizedStrings?.gBtnConfirm ?? "Confirm",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
