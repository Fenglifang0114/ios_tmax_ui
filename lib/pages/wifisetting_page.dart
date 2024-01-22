import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/respdata_data.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/data/wifi_ap_info.dart';
import 'package:t_max/data/wifi_list_info.dart';
import 'package:t_max/data/writelog.dart';
import 'package:t_max/main.dart';
import '../data/downloadresponse.dart';
import '../data/ipinfodata.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../generated/l10n.dart';
import '../widget/page_head.dart';
import '../widget/wifitextfeild.dart';

class WifiSettingPage extends StatefulWidget {
  const WifiSettingPage({Key? key}) : super(key: key);

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
      PublicFunctions.getIpInfo();
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

  var errorMessage = 'Obtaining AP list and Ip info,please wait...';
  dynamic localizedStrings;
  String setMessage = '';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void initState() {
    // super.initState();
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
            cntScaleTimerMgr.stopCntScaleTimer();
            PublicFunctions.getApInfo();
          } else {
            cntScaleTimerMgr.stopCntScaleTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
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
          mySetDynamicIpResp = event.obj;
          if (mySetDynamicIpResp.msgBody.isNotEmpty) {
            if (mySetDynamicIpResp.msgBody.contains('ok')) {
              isConnecting = false;
              errorMessage = 'Obtaining IP, please wait...';
              cntScaleTimerMgr.stopCntScaleTimer();
              _startGetIP(1);
            } else {
              isConnecting = false;
              errorMessage = mySetDynamicIpResp.msgBody;
              cntScaleTimerMgr.stopCntScaleTimer();
              PublicFunctions.getApInfo();
            }
          }
        });
      }
    });
    _eventbus3 = eventBus.on<EventConnectStaticIp>().listen((event) {
      if (mounted) {
        setState(() {
          mySetStaticIpResp = event.obj;
          if (mySetStaticIpResp.msgBody.isNotEmpty) {
            if (mySetStaticIpResp.msgBody.contains('ok')) {
              isConnecting = false;
              if (alreadyConnected) {
                errorMessage = 'Obtaining IP, please wait...';
                cntScaleTimerMgr.stopCntScaleTimer();

                PublicFunctions.getApInfo();
              } else {
                cntScaleTimerMgr.stopCntScaleTimer();
                connectAp();
              }
            } else {
              errorMessage = mySetStaticIpResp.msgBody;
            }
          }
        });
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
              errorMessage = 'Get Ip OK !';
            } else {
              errorMessage = 'Get ip fail !';
            }
            cntScaleTimerMgr.stopCntScaleTimer();
            PublicFunctions.getIpMode();
          }
        });
      }
    });

    _eventbus5 = eventBus.on<EventMessageError>().listen((event) {
      if (mounted) {
        setState(() {
          myMessageError = event.obj;
          if (!errorMessage.contains('ok')) {
            errorMessage = myMessageError.messagedata!;
          }
        });
      }
    });

    _eventbus6 = eventBus.on<EventGetIpError>().listen((event) {
      if (mounted) {
        setState(() {
          myGetIpError = event.obj;
          if (!myGetIpError.messagedata!.contains('ok')) {
            errorMessage = myGetIpError.messagedata!;
          }
          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.startCntScaleTimer(5);

          isConnecting = false;
        });
      }
    });
    _eventbus7 = eventBus.on<EventRespGetIpMode>().listen((event) {
      if (mounted) {
        setState(() {
          myRespGetIpMode = event.obj;
          if (myRespGetIpMode.messagedata!.isNotEmpty) {
            if (myRespGetIpMode.messagedata == 'dhcp') {
              _isStatic = false;
            } else if (myRespGetIpMode.messagedata == 'static') {
              _isStatic = true;
            }
          }
          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.startCntScaleTimer(5);
        });
      }
    });

    _eventbus8 = eventBus.on<EventGetWifiListError>().listen((event) {
      if (mounted) {
        setState(() {
          myGetWifiListError = event.obj;
          errorMessage = myGetWifiListError.messagedata!;
          _enableRefresh = true;
        });
        cntScaleTimerMgr.stopCntScaleTimer();
        cntScaleTimerMgr.startCntScaleTimer(5);
      }
    });

    _eventbus9 = eventBus.on<EventGetWifiApInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myWiFiAPInfo = event.obj;
          if (myWiFiAPInfo.ssid!.isNotEmpty) {
            connectedSsid = myWiFiAPInfo.ssid!;
            connectedMac = myWiFiAPInfo.bssid!;
            cntScaleTimerMgr.stopCntScaleTimer();
            PublicFunctions.getIpInfo();
          } else {
            connectedSsid = "";
            connectedMac = "";
            ipController.clear();
            gateWayController.clear();
            netMaskController.clear();
            cntScaleTimerMgr.stopCntScaleTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
          }
        });
      }
    });

    _eventbus10 = eventBus.on<EventConnectAp>().listen((event) {
      if (mounted) {
        setState(() {
          myConnectApResponse = event.obj;
          if (myConnectApResponse.msgBody.isNotEmpty) {
            if (myConnectApResponse.msgBody.contains('ok')) {
              isConnecting = false;
              errorMessage = 'Obtaining IP, please wait...';
              cntScaleTimerMgr.stopCntScaleTimer();
              PublicFunctions.getIpInfo();
            } else {
              isConnecting = false;
              errorMessage = myConnectApResponse.msgBody;
              cntScaleTimerMgr.stopCntScaleTimer();
              PublicFunctions.getApInfo();
            }
          }
        });
      }
    });

    _eventbus11 = eventBus.on<EventRespChangeWiFiMode>().listen((event) {
      if (mounted) {
        setState(() {
          myRespChangeWifiMode = event.obj;
          if (myRespChangeWifiMode.msgBody.contains('ok')) {
            myScreenMgr.serialPortST = true;
            cntScaleTimerMgr.stopCntScaleTimer();
            PublicFunctions.getWifiList();
          } else {
            _enableRefresh = true;
            errorMessage = myRespChangeWifiMode.msgBody;
            cntScaleTimerMgr.stopCntScaleTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
          }
        });
      }
    });
    _eventbus12 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        setState(() {
          myRespCheckSerialPort = event.obj;
          if (myRespCheckSerialPort.msgBody == 'ok') {
            myScreenMgr.serialPortST = true;
          } else {
            myScreenMgr.serialPortST = false;
          }
        });
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
    localizedStrings = S.of(context);
    setMessage = localizedStrings.set_wifi_success;
    // final _width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: pageHead(context, localizedStrings.wifi_setting_title,
              localizedStrings.serial_port_status),
        ),
        body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 2,
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
                              child: Container(
                            // height: 48,
                            // color: Theme.of(context).colorScheme.primary,
                            child: Row(children: [
                              SizedBox(
                                width: 40, // 为Container指定一个固定的宽度
                                child: Tooltip(
                                  message: localizedStrings.refresh_tip,
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

                                            PublicFunctions.getWifiList();
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
                                              .background,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _findWifiText,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
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
                                    labelText: localizedStrings.find_ssid,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white, // 设置边框颜色
                                        width: 2.0, // 设置边框宽度
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
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
                            ]),
                          )),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    ? const Color.fromARGB(255, 167, 215, 255)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                    // 更新文本框中的值
                                    ssidController.text = displayedItems[index];
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
          Expanded(
              flex: 7,
              child: Container(
                  color: Theme.of(context).colorScheme.onPrimary,
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
                                            localizedStrings.network_setting,
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
                                                    "Connected AP Info:",
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
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const SizedBox(
                                              height: 40,
                                              width: 100,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  "SSID:",
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
                                                            Radius.circular(
                                                                30)),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
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
                                              height: 60,
                                              width: 100,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  localizedStrings.password,
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
                                                            Radius.circular(
                                                                30)),
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
                                          localizedStrings.ip_address,
                                          15,
                                          ipaddressRegex,
                                          _isValidIP,
                                          'Incorrect IP! e.g. 192.168.100.188',
                                          (value) => validateIp(value),
                                          ipController,
                                          _isStatic,
                                        ),
                                        buildCommonRow(
                                          localizedStrings.netmask,
                                          15,
                                          ipaddressRegex,
                                          _isValidMask,
                                          'Incorrect NetMask! e.g. 255.255.255.0',
                                          (value) => validateNetMask(value),
                                          netMaskController,
                                          _isStatic,
                                        ),
                                        buildCommonRow(
                                          localizedStrings.gateway,
                                          15,
                                          ipaddressRegex,
                                          _isValidGateway,
                                          'Incorrect Gateway! e.g. 192.168.100.1',
                                          (value) => validateGateWay(value),
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
                                                                    'ok') ||
                                                            errorMessage
                                                                .contains('OK'))
                                                        ? Colors.green.shade900
                                                        : Colors.red.shade900),
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
                                            OutlinedButton(
                                              style: ButtonStyle(
                                                side: MaterialStateProperty.all(
                                                    BorderSide(
                                                        width: 2,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary)),
                                              ),
                                              child: SizedBox(
                                                width: 150,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    localizedStrings
                                                        .button_get_ip,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 20.0),
                                                  ),
                                                ),
                                              ),
                                              onPressed: isConnecting
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        errorMessage = '';
                                                      });
                                                      cntScaleTimerMgr
                                                          .stopCntScaleTimer();

                                                      PublicFunctions
                                                          .getIpInfo();
                                                    },
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            OutlinedButton(
                                              style: ButtonStyle(
                                                side: MaterialStateProperty.all(
                                                    BorderSide(
                                                        width: 2,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary)),
                                              ),
                                              child: SizedBox(
                                                width: 150,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    localizedStrings
                                                        .button_static,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 20.0),
                                                  ),
                                                ),
                                              ),
                                              onPressed:
                                                  (_isStatic || isConnecting)
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            _isStatic = true;
                                                            errorMessage =
                                                                'Enter IP information and click the connect button!';
                                                          });

                                                          // sendDataToWifi();
                                                        },
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            OutlinedButton(
                                              style: ButtonStyle(
                                                side: MaterialStateProperty.all(
                                                    BorderSide(
                                                        width: 2,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary)),
                                              ),
                                              child: SizedBox(
                                                width: 150,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    localizedStrings
                                                        .button_dynamic,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 20.0),
                                                  ),
                                                ),
                                              ),
                                              onPressed:
                                                  (_isStatic && !isConnecting)
                                                      ? () {
                                                          setState(() {
                                                            _isStatic = false;
                                                            errorMessage = '';
                                                            // dnsController.clear();
                                                            // netMaskController.clear();
                                                            // ipController.clear();
                                                            // gateWayController.clear();
                                                            // _isValidDns = true;
                                                            // _isValidGateway = true;
                                                            // _isValidIP = true;
                                                            // _isValidMask = true;
                                                          });
                                                          cntScaleTimerMgr
                                                              .stopCntScaleTimer();

                                                          PublicFunctions
                                                              .setWifiDynamicMode();
                                                        }
                                                      : null,
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary, // 设置按钮的背景色
                                                elevation: 10, // 设置按钮的阴影
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // 设置按钮的圆角
                                                ),
                                              ),
                                              child: SizedBox(
                                                width: 150,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    localizedStrings.button_set,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              onPressed: (isValidData() &&
                                                      !isConnecting)
                                                  ? () {
                                                      setState(() {
                                                        errorMessage =
                                                            'Connecting...';
                                                      });
                                                      isConnecting = true;
                                                      cntScaleTimerMgr
                                                          .stopCntScaleTimer();
                                                      if (_isStatic) {
                                                        connectStaticIp();
                                                      } else {
                                                        connectDynamicIp();
                                                      }

                                                      // ipController.clear();
                                                      // netMaskController.clear();
                                                      // dnsController.clear();
                                                      // gateWayController.clear();
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

  // void sendDataToWifi() {
  //   myScaleCmd.cmdMode = 'send_data_to_wifi';
  //   myScaleCmd.cmdData = 'AT+CWMODE?\r\n';
  //   MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  // }

  // void _startTimer(int time) {
  //   setState(() {
  //     isConnecting = true;
  //   });

  //   _timer = Timer(Duration(seconds: time), () {
  //     setState(() {
  //       isConnecting = false;
  //       errorMessage = 'Time out!';
  //     });
  //   });
  // }

  // void _stopTimer() {
  //   setState(() {
  //     isConnecting = false;
  //   });
  //   _timer?.cancel(); // 停止计时器
  // }

  void connectAp() {
    myScaleCmd.cmdMode = 'connect_ap';
    myConnectApInfo.ssid = ssidController.text;
    myConnectApInfo.password = passwordController.text;
    myConnectApInfo.bssid = bssId; //手动输入的如何处理？id写-1
    myScaleCmd.cmdData = jsonEncode(myConnectApInfo).toString();
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  void connectDynamicIp() {
    if (myWiFiAPInfo.ssid == ssidController.text &&
        myWiFiAPInfo.bssid == bssId) {
      isConnecting = false;
      errorMessage = 'You are already connected!';
    } else {
      mySetDynamicIpResp.msgBody = '';
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
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  void validateNetMask(String value) {
    bool isValid = false;
    _isValidMask = false;
    setState(() {
      _isValidMask = isValid;
      errorMessage = '';
    });
    isValid = ipRegex.hasMatch(value);
    isValid = _isValidIpAddress(isValid, value);
    setState(() {
      _isValidMask = isValid;
    });
  }

  void validateGateWay(String value) {
    bool isValid = false;
    _isValidGateway = false;
    setState(() {
      _isValidGateway = isValid;
      errorMessage = '';
    });
    isValid = ipRegex.hasMatch(value);
    isValid = _isValidIpAddress(isValid, value);
    setState(() {
      _isValidGateway = isValid;
    });
  }

  void validateIp(String value) {
    bool isValid = false;
    _isValidIP = false;
    setState(() {
      _isValidIP = isValid;
      errorMessage = '';
    });
    isValid = ipRegex.hasMatch(value);
    isValid = _isValidIpAddress(isValid, value);
    setState(() {
      _isValidIP = isValid;
    });
  }

  // void validateDns(String value) {
  //   bool isValid = false;
  //   _isValidDns = false;
  //   setState(() {
  //     _isValidDns = isValid;
  //     errorMessage = '';
  //   });
  //   isValid = ipRegex.hasMatch(value);
  //   isValid = _isValidIpAddress(isValid, value);
  //   setState(() {
  //     _isValidDns = isValid;
  //   });
  // }
}
