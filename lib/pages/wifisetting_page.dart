import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/data/wifi_list_info.dart';
import 'package:t_max/main.dart';
import '../data/downloadresponse.dart';
import '../data/ipinfodata.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../generated/l10n.dart';
import 'widget/wifitextfeild.dart';

class WifiSettingPage extends StatefulWidget {
  const WifiSettingPage({Key? key}) : super(key: key);

  @override
  State<WifiSettingPage> createState() => WifiSettingPageState();
}

class WifiSettingPageState extends State<WifiSettingPage> {
  List<String> wifiItems = [];
  List<String> displayedItems = [];
  List<int> wifiRssiList = [];
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController netMaskController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController gateWayController = TextEditingController();
  TextEditingController dnsController = TextEditingController();
  final TextEditingController _findWifiText = TextEditingController();
  int selectedIndex = -1;
  bool passwordLock = true;
  bool _isValidIP = true;
  bool _isValidMask = true;
  bool _isValidGateway = true;
  bool _isValidDns = true;
  bool _isStatic = false;
  int _ssidNo = -1;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  // dynamic _eventbus2 = EventBus();

  TextEditingController controller = TextEditingController();
  RegExp ipaddressRegex = RegExp(r'[0-9.]');

  RegExp ipRegex = RegExp(
    r'^((\d{1,3}\.){3}\d{1,3})$',
    multiLine: false,
    caseSensitive: false,
  );

  bool _isValidIpAddress(bool tempValid, String value) {
    if (tempValid) {
      List<int?> parts = value.split('.').map(int.tryParse).toList();
      if (parts.any((part) => part == null || part > 255)) {
        tempValid = false;
      }
    }
    return tempValid;
  }

  var localizedStrings;
  String set_message = '';
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
          wifiRssiList.add(myWifiListInfo.wifidatalist![i].rssi!);
        }
      }
    } else {
      wifiItems = [];
      wifiRssiList = [];
    }
    displayedItems = List.from(wifiItems);
    ssidController.text = "";
    PublicFunctions.getWifiList();
    _eventbus1 = eventBus.on<EventWiFiListInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myWifiListInfo = event.obj;
          _findWifiText.text = '';
          wifiRssiList.clear();
          wifiItems.clear();
          displayedItems.clear();
          if (myWifiListInfo.wifidatalist!.isNotEmpty) {
            for (var i = 0; i < myWifiListInfo.wifidatalist!.length; i++) {
              if (myWifiListInfo.wifidatalist![i].ssid!.isNotEmpty) {
                wifiItems.add(myWifiListInfo.wifidatalist![i].ssid!);
                wifiRssiList.add(myWifiListInfo.wifidatalist![i].rssi!);
              }
            }
          }
          displayedItems = List.from(wifiItems);
        });
      }
    });
    _eventbus2 = eventBus.on<EventConnectDynamicIp>().listen((event) {
      if (mounted) {
        setState(() {
          myConnectDynamicIpResponse = event.obj;
          if (myConnectDynamicIpResponse.msgBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myConnectDynamicIpResponse.msgBody.contains('ok'))
                        ? set_message
                        : myConnectDynamicIpResponse.msgBody,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor:
                    (myConnectDynamicIpResponse.msgBody.contains('ok'))
                        ? Colors.green.shade900
                        : Colors.red.shade900));
          }
        });
      }
    });
    _eventbus3 = eventBus.on<EventConnectStaticIp>().listen((event) {
      if (mounted) {
        setState(() {
          myConnectStaticIpResponse = event.obj;
          if (myConnectStaticIpResponse.msgBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myConnectStaticIpResponse.msgBody.contains('ok'))
                        ? localizedStrings.set_wifi_success
                        : myConnectStaticIpResponse.msgBody,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor:
                    (myConnectStaticIpResponse.msgBody.contains('ok'))
                        ? Colors.green.shade900
                        : Colors.red.shade900));
          }
        });
      }
    });

    _eventbus4 = eventBus.on<EventIpInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myIpInfoData = event.obj;
          if (myIpInfoData.dns != null) {
            dnsController.text = myIpInfoData.dns![0];
          }
          gateWayController.text = myIpInfoData.gateway!;
          if (myIpInfoData.address != null) {
            ipController.text = myIpInfoData.address![0].address!;
            if (myIpInfoData.address![0].proto == 'manual') {
              _isStatic = true;
            } else {
              _isStatic = false;
            }
            if (myIpInfoData.address![0].mask == 24) {
              netMaskController.text = '255.255.255.0';
            }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);
    set_message = localizedStrings.set_wifi_success;
    // final _width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;
    return Scaffold(
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
                      const Divider(
                        thickness: 2,
                        height: 2,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(180, 40),
                            side: BorderSide(
                                width: 2,
                                color: Theme.of(context).colorScheme.primary),
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.white, //体颜色
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold), // 字体样式
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // 圆角
                            ),
                            elevation: 5, // 阴影
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.home),
                              Text(localizedStrings.button_home),
                            ],
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                          child: Container(
                        // height: 48,
                        color: Theme.of(context).colorScheme.primary,
                        child: Row(children: [
                          SizedBox(
                            width: 40, // 为Container指定一个固定的宽度
                            child: Tooltip(
                              message: localizedStrings.refresh_tip,
                              child: IconButton(
                                splashRadius: 20,
                                onPressed: () {
                                  PublicFunctions.reScanApList();
                                },
                                icon: Icon(
                                  Icons.refresh,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
              Expanded(
                child: ListView.builder(
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                        height: 50,
                        child: Column(
                          children: [
                            Divider(
                              height: 2,
                              color: Theme.of(context).colorScheme.background,
                            ),
                            ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayedItems[index],

                                      maxLines: 1, // 设置文本最大行数为1
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Icon((wifiRssiList[index] == 4)
                                      ? Icons.wifi
                                      : (wifiRssiList[index] == 3)
                                          ? Icons.wifi_2_bar
                                          : (wifiRssiList[index] == 2 ||
                                                  wifiRssiList[index] == 1)
                                              ? Icons.wifi_1_bar
                                              : Icons.wifi)
                                ],
                              ),
                              tileColor: selectedIndex == index
                                  ? const Color.fromARGB(255, 167, 215, 255)
                                  : null,
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                  // 更新文本框中的值
                                  ssidController.text = displayedItems[index];
                                });
                              },
                            )
                          ],
                        ));
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
                                        const SizedBox(
                                          height: 40,
                                          width: 100,
                                          child: Align(
                                            alignment: Alignment.centerRight,
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
                                              overflow: TextOverflow.ellipsis,
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
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(
                                                      r'[\x00-\xF]+$')), // 允许输入数字和点
                                            ],
                                            textAlign: TextAlign.start,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
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
                                            alignment: Alignment.centerRight,
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
                                                  28),
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(
                                                      r'[\x00-\xF]+$')), // 允许输入数字和点
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
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30)),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              isValidData();
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
                                      localizedStrings.gatway,
                                      15,
                                      ipaddressRegex,
                                      _isValidGateway,
                                      'Incorrect Gateway! e.g. 192.168.100.1',
                                      (value) => validateGateWay(value),
                                      gateWayController,
                                      _isStatic,
                                    ),
                                    buildCommonRow(
                                      "DNS:",
                                      15,
                                      ipaddressRegex,
                                      _isValidDns,
                                      'Incorrect DNS! e.g. 8.8.8.8',
                                      (value) => validateDns(value),
                                      dnsController,
                                      _isStatic,
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
                                            width: 100,
                                            height: 40,
                                            child: Center(
                                              child: Text(
                                                localizedStrings.button_static,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 20.0),
                                              ),
                                            ),
                                          ),
                                          onPressed: _isStatic
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _isStatic = true;
                                                  });
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
                                            width: 100,
                                            height: 40,
                                            child: Center(
                                              child: Text(
                                                localizedStrings.button_dynamic,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 20.0),
                                              ),
                                            ),
                                          ),
                                          onPressed: _isStatic
                                              ? () {
                                                  setState(() {
                                                    _isStatic = false;
                                                    dnsController.clear();
                                                    netMaskController.clear();
                                                    ipController.clear();
                                                    gateWayController.clear();
                                                    _isValidDns = true;
                                                    _isValidGateway = true;
                                                    _isValidIP = true;
                                                    _isValidMask = true;
                                                  });
                                                }
                                              : null,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
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
                                            width: 100,
                                            height: 40,
                                            child: Center(
                                              child: Text(
                                                localizedStrings.button_set,
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
                                          onPressed: isValidData()
                                              ? () {
                                                  if (_isStatic) {
                                                    sendStaticIpInfo();
                                                  } else {
                                                    sendDynamicIpInfo();
                                                  }
                                                  PublicFunctions.getIpInfo();
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
          dnsController.text.isNotEmpty &&
          netMaskController.text.isNotEmpty &&
          _isValidDns &&
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

  void sendDynamicIpInfo() {
    myScaleCmd.cmdMode = 'connect_ap_dynamic_ip';
    if (ssidController.text.isEmpty || passwordController.text.isEmpty) {
    } else if (ssidController.text.isEmpty) {
      // var e
    } else if (passwordController.text.isEmpty) {
      // var e
    } else {
      myDynamicIpInfo.ssid = ssidController.text;
      myDynamicIpInfo.password = passwordController.text;
      myDynamicIpInfo.seqno = _ssidNo; //手动输入的如何处理？id写-1
      myScaleCmd.cmdData = jsonEncode(myDynamicIpInfo).toString();
      MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    }
  }

  void sendStaticIpInfo() {
    myScaleCmd.cmdMode = 'connect_ap_static_ip';
    if (ssidController.text.isEmpty || passwordController.text.isEmpty) {
    } else if (ssidController.text.isEmpty) {
      // var e
    } else if (passwordController.text.isEmpty) {
      // var e
    } else {
      myStaticIpInfo.ssid = ssidController.text;
      myStaticIpInfo.password = passwordController.text;
      myStaticIpInfo.seqno = _ssidNo; //手动输入的如何处理？id写-1
      myStaticIpInfo.gateway = gateWayController.text;
      myStaticIpInfo.dns = dnsController.text;
      myStaticAddresses.address = ipController.text;
      myStaticAddresses.family = 'ipv4';
      myStaticAddresses.mask = 24;
      myStaticIpInfo.addresses ??= [];
      myStaticIpInfo.addresses?.add(myStaticAddresses);

      myScaleCmd.cmdData = jsonEncode(myStaticIpInfo).toString();
      MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    }
  }

  void validateNetMask(String value) {
    bool isValid = false;
    _isValidMask = false;
    setState(() {
      _isValidMask = isValid;
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
    });
    isValid = ipRegex.hasMatch(value);
    isValid = _isValidIpAddress(isValid, value);
    setState(() {
      _isValidIP = isValid;
    });
  }

  void validateDns(String value) {
    bool isValid = false;
    _isValidDns = false;
    setState(() {
      _isValidDns = isValid;
    });
    isValid = ipRegex.hasMatch(value);
    isValid = _isValidIpAddress(isValid, value);
    setState(() {
      _isValidDns = isValid;
    });
  }
}
