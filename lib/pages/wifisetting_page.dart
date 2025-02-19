import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/comscaleinfo_data.dart';
import '../data/const_var_data.dart';
import '../data/downloadresponse.dart';
import 'package:t_max/data/respdata_data.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/data/wifi_ap_info.dart';
import 'package:t_max/data/wifi_list_info.dart';
import 'package:t_max/data/writelog.dart';

import '../data/ipinfodata.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';
import '../data/wifi_pwd_info.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';
import '../widget/wifitextfeild.dart';

class WifiSettingPage extends StatefulWidget {
  const WifiSettingPage({super.key});

  @override
  State<WifiSettingPage> createState() => WifiSettingPageState();
}

class WifiSettingPageState extends State<WifiSettingPage> {
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
  bool _isValidIP = true;
  bool _isValidMask = true;
  bool _isValidGateway = true;
  // bool _isValidDns = true;
  bool _isStatic = false;
  bool _enableRefresh = false;
  String bssId = '';
  String connectedSsid = '';
  String connectedMac = '';
  bool isConnecting = false;
  bool alreadyConnected = false;
  bool firstGetApList = true; //WIFI列表进来只获取一次

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

  TextEditingController controller = TextEditingController();
  RegExp ipaddressRegex = RegExp(r'[0-9.]');

  RegExp ipRegex = RegExp(
    r'^((\d{1,3}\.){3}\d{1,3})$',
    multiLine: false,
    caseSensitive: false,
  );

  void _startGetIP(int time) {
    getIpTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.getIpInfo(1);
      _stopGetIp();
    });
  }

  void _stopGetIp() {
    getIpTimer?.cancel(); // 停止计时器
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

  var errorMessage = '';

  @override
  void initState() {
    cntScaleTimerMgr.stopCntScaleTimer();
    errorMessage = localizedStrings.gTipGetApListAndIP;

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
    // PublicFunctions.getWifiList();
    _eventbus1 = eventBus.on<EventWiFiListInfo>().listen((event) {
      if (mounted) {
        setState(() {
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
            // cntScaleTimerMgr.stopCntScaleTimer();
            // PublicFunctions.getApInfo(1);
          } else {
            // cntScaleTimerMgr.stopCntScaleTimer();
            // cntScaleTimerMgr.startCntScaleTimer(5);
          }
          displayedItems = List.from(wifiItems);
          _enableRefresh = true;
          errorMessage = "";
        });
      }
    });
    _eventbus2 = eventBus.on<EventConnectDynamicIp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            if (myRespDataFromScale.msgBody.contains(msgOk)) {
              isConnecting = false;
              errorMessage = localizedStrings.gTipGetIP;
              // cntScaleTimerMgr.stopCntScaleTimer();
              _startGetIP(2);
            } else {
              isConnecting = false;
              errorMessage = myRespDataFromScale.msgBody;
              // cntScaleTimerMgr.stopCntScaleTimer();
              _startGetIP(2);
            }
          }
        });
      }
    });
    _eventbus3 = eventBus.on<EventConnectStaticIp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            if (myRespDataFromScale.msgBody.contains(msgOk)) {
              isConnecting = false;
              if (alreadyConnected) {
                errorMessage = localizedStrings.gTipGetIP;
                // cntScaleTimerMgr.stopCntScaleTimer();
              } else {
                // cntScaleTimerMgr.stopCntScaleTimer();
                connectAp();
              }
            } else {
              errorMessage = myRespDataFromScale.msgBody;
            }
          }
        });
        if (firstGetApList) {
          PublicFunctions.getApInfo(1);
          firstGetApList = false;
        }
      }
    });

    _eventbus4 = eventBus.on<EventIpInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myIpInfoData = event.obj;
          isConnecting = false;

          if (myIpInfoData.iP != null) {
            if (myIpInfoData.iP != '0.0.0.0') {
              ipController.text = myIpInfoData.iP!;
              gateWayController.text = myIpInfoData.gateway!;
              netMaskController.text = myIpInfoData.netmask!;
              errorMessage = localizedStrings.gTipGetIpOk;
            } else {
              errorMessage = localizedStrings.gTipGetIpFail;
            }
            // cntScaleTimerMgr.stopCntScaleTimer();
            PublicFunctions.getIpMode(1);
          }
        });
      }
    });

    _eventbus5 = eventBus.on<EventMessageError>().listen((event) {
      if (mounted) {
        setState(() {
          myMessageError = event.obj;
          if (!errorMessage.contains(msgOk)) {
            errorMessage = myMessageError.messagedata!;
          }
        });
      }
    });

    _eventbus6 = eventBus.on<EventGetIpError>().listen((event) {
      if (mounted) {
        setState(() {
          myGetIpError = event.obj;
          if (!myGetIpError.messagedata!.contains(msgOk)) {
            errorMessage = myGetIpError.messagedata!;
          }
          // cntScaleTimerMgr.stopCntScaleTimer();
          // cntScaleTimerMgr.startCntScaleTimer(5);

          isConnecting = false;
        });
      }
    });
    _eventbus7 = eventBus.on<EventRespGetIpMode>().listen((event) {
      if (mounted) {
        setState(() {
          myRespGetIpMode = event.obj;
          if (myRespGetIpMode.messagedata!.isNotEmpty) {
            if (myRespGetIpMode.messagedata == wifiDhcp) {
              _isStatic = false;
            } else if (myRespGetIpMode.messagedata == wifiStatic) {
              _isStatic = true;
            }
          }
          // cntScaleTimerMgr.stopCntScaleTimer();
          // cntScaleTimerMgr.startCntScaleTimer(5);
        });
        PublicFunctions.getWifiList(1);
      }
    });

    _eventbus8 = eventBus.on<EventGetWifiListError>().listen((event) {
      if (mounted) {
        setState(() {
          myGetWifiListError = event.obj;
          errorMessage = myGetWifiListError.messagedata!;
          _enableRefresh = true;
        });
        // cntScaleTimerMgr.stopCntScaleTimer();
        // cntScaleTimerMgr.startCntScaleTimer(5);
      }
    });

    _eventbus9 = eventBus.on<EventGetWifiApInfo>().listen((event) {
      if (mounted) {
        setState(() {
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
            // cntScaleTimerMgr.stopCntScaleTimer();
            // cntScaleTimerMgr.startCntScaleTimer(5);
          }
          _startGetIP(1);
        });
      }
    });

    _eventbus10 = eventBus.on<EventConnectAp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            if (myRespDataFromScale.msgBody.contains(msgOk)) {
              isConnecting = false;
              errorMessage = localizedStrings.gTipGetIP;
              cntScaleTimerMgr.stopCntScaleTimer();
            } else {
              isConnecting = false;
              errorMessage = myRespDataFromScale.msgBody;
              cntScaleTimerMgr.stopCntScaleTimer();
            }
          }
        });
        PublicFunctions.getApInfo(1);
      }
    });

    _eventbus11 = eventBus.on<EventRespChangeWiFiMode>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.contains(msgOk)) {
            myComScaleInfo.isOnline = true;
            cntScaleTimerMgr.stopCntScaleTimer();
            // PublicFunctions.getWifiList(1);
          } else {
            _enableRefresh = true;
            errorMessage = myRespDataFromScale.msgBody;
            // cntScaleTimerMgr.stopCntScaleTimer();
            // cntScaleTimerMgr.startCntScaleTimer(5);
          }
        });
        PublicFunctions.getApInfo(1);
      }
    });
    _eventbus12 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        // setState(() {
        //   myFactoryInfoFromScale = event.obj;
        //   if (myFactoryInfoFromScale.modelName != '') {
        //     myComScaleInfo.isOnline = true;
        //   } else {
        //     myComScaleInfo.isOnline = false;
        //   }
        // });
      }
    });

    super.initState();
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
    _stopGetIp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final _width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: pageHeadDesign(context, localizedStrings.wifi_setting_title,
              [1], localizedStrings.gTipWifiSettingPageHelp),
        ),
        body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceTint,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                        height: 100,
                        // color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          children: [
                            Expanded(
                                child: Row(children: [
                              SizedBox(
                                width: 40, // 为Container指定一个固定的宽度
                                child: Tooltip(
                                  message: localizedStrings.gMsgRefresh,
                                  child: IconButton(
                                    splashRadius: 20,
                                    onPressed: _enableRefresh
                                        ? () {
                                            setState(() {
                                              _enableRefresh = false;
                                              errorMessage = '';
                                            });
                                            cntScaleTimerMgr
                                                .stopCntScaleTimer();

                                            PublicFunctions.getWifiList(1);
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.refresh,
                                      color: _enableRefresh
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondaryFixed,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _findWifiText,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceTint,
                                    suffixIcon: IconButton(
                                      splashRadius: 20,
                                      icon: Icon(
                                        Icons.close,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    labelText: localizedStrings.gFindSsid,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary, // 设置边框颜色
                                        width: 2.0, // 设置边框宽度
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4)),
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
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ])),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        )),
                    Divider(
                      height: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayedItems.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            child: Column(
                              children: [
                                ListTile(
                                  dense: true,
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayedItems[index],
                                        maxLines: 1, // 设置文本最大行数为1
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                  subtitle: Text(
                                    bssidList[index],
                                    maxLines: 1, // 设置文本最大行数为1
                                    style: const TextStyle(
                                      fontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  trailing: Icon((wifiRssiList[index] == 4)
                                      ? Icons.wifi
                                      : (wifiRssiList[index] == 3)
                                          ? Icons.wifi_2_bar
                                          : (wifiRssiList[index] == 2 ||
                                                  wifiRssiList[index] == 1)
                                              ? Icons.wifi_1_bar
                                              : Icons.wifi),
                                  tileColor: selectedIndex == index
                                      ? Theme.of(context).colorScheme.scrim
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                      // 更新文本框中的值
                                      ssidController.text =
                                          displayedItems[index];
                                      passwordController.text =
                                          getWifiPwd(ssidController.text);
                                      if (index <
                                          myWifiListInfo.wifidatalist!.length) {
                                        bssId = myWifiListInfo
                                            .wifidatalist![index].mac!;
                                      }
                                    });
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 7,
              child: Container(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: Column(
                    children: [
                      Container(
                        height: 2,
                        color: Theme.of(context).colorScheme.primary, // 蓝色分隔条颜色
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 2,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary, // 蓝色分隔条颜色
                                ),
                              ],
                            ),
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Center(
                                    child: ListView(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Center(
                                          child: Text(
                                            localizedStrings.gNetworkSetting,
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              SizedBox(
                                                height: 40,
                                                width: 200,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    localizedStrings
                                                        .gTipConnectedInfo,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: 30,
                                                    width: 200,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        connectedSsid,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                    width: 200,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        connectedMac,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ]),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              width: 200,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  localizedStrings.gTipSSID,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            SizedBox(
                                              width: 300,
                                              height: 40,
                                              child: TextField(
                                                readOnly: false,
                                                style: const TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                controller: ssidController,
                                                onChanged: (value) {
                                                  // List<String> filteredItems =
                                                  //     wifiItems
                                                  //         .where((item) => item
                                                  //             .toLowerCase()
                                                  //             .contains(value
                                                  //                 .toLowerCase()))
                                                  //         .toList();
                                                  // setState(() {
                                                  //   displayedItems =
                                                  //       filteredItems;
                                                  // });
                                                },
                                                maxLines: 1,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      28),
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'[\x00-\xF]+$')), // 允许输入数字和点
                                                ],
                                                textAlign: TextAlign.start,
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(4)),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 60,
                                              width: 200,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  localizedStrings.gPassword,
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            SizedBox(
                                              width: 300,
                                              height: 40,
                                              child: TextField(
                                                controller: passwordController,
                                                textAlign: TextAlign.start,
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                obscureText: passwordLock,
                                                maxLines: 1,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      20),
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'^[ -~!@#$%^&*()_+<>?:"{},.\/;]+$')), // 允许输入数字和点
                                                ],
                                                decoration: InputDecoration(
                                                  suffixIcon: IconButton(
                                                    icon: Icon(passwordLock
                                                        ? Icons.visibility_off
                                                        : Icons.visibility),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (passwordLock) {
                                                          passwordLock = false;
                                                        } else {
                                                          passwordLock = true;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  border:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(4)),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  isValidData();
                                                  setState(() {
                                                    errorMessage = '';
                                                  });
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        buildCommonRow(
                                          localizedStrings.gIpAddress,
                                          15,
                                          ipaddressRegex,
                                          _isValidIP,
                                          localizedStrings.error_ip_tip,
                                          (value) {
                                            setState(() {
                                              _isValidIP =
                                                  validateIpFlag(value);
                                            });
                                          },
                                          ipController,
                                          _isStatic,
                                        ),
                                        buildCommonRow(
                                          localizedStrings.gNetmask,
                                          15,
                                          ipaddressRegex,
                                          _isValidMask,
                                          localizedStrings.error_ip_tip,
                                          (value) {
                                            setState(() {
                                              _isValidMask =
                                                  validateIpFlag(value);
                                            });
                                          },
                                          netMaskController,
                                          _isStatic,
                                        ),
                                        buildCommonRow(
                                          localizedStrings.gGateway,
                                          15,
                                          ipaddressRegex,
                                          _isValidGateway,
                                          localizedStrings.error_ip_tip,
                                          (value) {
                                            setState(() {
                                              _isValidGateway =
                                                  validateIpFlag(value);
                                            });
                                          },
                                          gateWayController,
                                          _isStatic,
                                        ),
                                        // buildCommonRow(
                                        //   "DNS:",
                                        //   15,
                                        //   ipaddressRegex,
                                        //   _isValidDns,
                                        //   'Incorrect DNS! e.g. 8.8.8.8',
                                        //   (value) => validateDns(value),
                                        //   dnsController,
                                        //   _isStatic,
                                        // ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                errorMessage,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: (errorMessage
                                                                .contains(
                                                                    msgOk) ||
                                                            errorMessage
                                                                .contains('OK'))
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .outline
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .error),
                                              ),
                                            ]),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomOutlinedButton(
                                              btnWidth: 120,
                                              btnHeight: 40,
                                              icon: Icons.double_arrow,
                                              text: localizedStrings
                                                  .button_get_ip,
                                              onPressed: isConnecting
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        errorMessage = '';
                                                      });
                                                      cntScaleTimerMgr
                                                          .stopCntScaleTimer();

                                                      PublicFunctions.getIpInfo(
                                                          1);
                                                    },
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            CustomOutlinedButton(
                                              btnWidth: 120,
                                              btnHeight: 40,
                                              icon:
                                                  Icons.check_box_outline_blank,
                                              text: localizedStrings.gBtnStatic,
                                              onPressed:
                                                  (_isStatic || isConnecting)
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            _isStatic = true;
                                                            errorMessage =
                                                                localizedStrings
                                                                    .gTipConnectStaticIp;
                                                          });

                                                          // sendDataToWifi();
                                                        },
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            CustomOutlinedButton(
                                              btnWidth: 120,
                                              btnHeight: 40,
                                              icon: Icons
                                                  .wifi_protected_setup_outlined,
                                              text:
                                                  localizedStrings.gBtnDynamic,
                                              onPressed:
                                                  (_isStatic && !isConnecting)
                                                      ? () {
                                                          setState(() {
                                                            _isStatic = false;
                                                            errorMessage = '';
                                                          });
                                                          cntScaleTimerMgr
                                                              .stopCntScaleTimer();

                                                          PublicFunctions
                                                              .setWifiDynamicMode(
                                                                  1);
                                                        }
                                                      : null,
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            CustomElevatedButton(
                                              btnWidth: 120,
                                              btnHeight: 40,
                                              icon: Icons.wifi,
                                              text:
                                                  localizedStrings.gBtnConnect,
                                              onPressed: (isValidData() &&
                                                      !isConnecting)
                                                  ? () {
                                                      setState(() {
                                                        errorMessage =
                                                            localizedStrings
                                                                .gTipConnecting;
                                                      });
                                                      isConnecting = true;
                                                      cntScaleTimerMgr
                                                          .stopCntScaleTimer();
                                                      if (_isStatic) {
                                                        connectStaticIp();
                                                      } else {
                                                        connectDynamicIp();
                                                      }
                                                    }
                                                  : null,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // 右侧剩余部分分配给此Container
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ))),
        ]));
  }

  bool isValidData() {
    bool res = false;
    // setState(() {
    if (_isStatic) {
      if (ssidController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          ipController.text.isNotEmpty &&
          gateWayController.text.isNotEmpty &&
          // dnsController.text.isNotEmpty &&
          netMaskController.text.isNotEmpty &&
          // _isValidDns &&
          _isValidGateway &&
          _isValidMask &&
          _isValidIP) {
        res = true;
      }
    } else {
      if (ssidController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        res = true;
      }
    }
    // });
    setState(() {
      res;
    });

    return res;
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
    myConnectApInfo.bssid = bssId; //手动输入的如何处理？id写-1
    myScaleCmd.cmdData = jsonEncode(myConnectApInfo).toString();
    PublicFunctions.sendMsg(1, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
    addWifiPwd();
  }

  void addWifiPwd() {
    myWifiPwdInfo.ssid = ssidController.text;
    myWifiPwdInfo.pwd = passwordController.text;
    String wifiStr = jsonEncode(myWifiPwdInfo).toString();
    PublicFunctions.addWifiPwd(wifiStr);
    WifiPwdInfoList wifiInfo = WifiPwdInfoList(
        id: myWifiPwdInfoList.length,
        ssid: myWifiPwdInfo.ssid!,
        pwd: myWifiPwdInfo.pwd!);
    myWifiPwdInfoList.add(wifiInfo);
  }

  void connectDynamicIp() {
    if (myWiFiAPInfo.ssid == ssidController.text &&
        myWiFiAPInfo.bssid == bssId) {
      isConnecting = false;
      errorMessage = localizedStrings.gTipConnected;
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
    PublicFunctions.sendMsg(1, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  bool validateIpFlag(String value) {
    bool isValid = false;

    setState(() {
      if (value != '') {
        isValid = ipRegex.hasMatch(value);
        isValid = _isValidIpAddress(isValid, value);
      } else {
        isValid = true;
      }
    });
    return isValid;
  }
}
