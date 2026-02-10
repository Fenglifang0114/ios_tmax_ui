// wifi 设置界面 只能用串口设置

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
  bool firstGetApList = true; //WIFI列表进来只获取一次

  bool isSetting = false; //正在操作

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

              showTipInfo(localizedStrings.gTipGetIP, context);

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
                showTipInfo(localizedStrings.gTipConnected, context);
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

              showTipInfo(localizedStrings.gTipGetIpOk, context);
            } else {
              showTipInfo(localizedStrings.gTipGetIpFail, context);
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
          showTipInfo(localizedStrings.gTipGetAPList, context);
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

              showTipInfo(localizedStrings.gTipGetIP, context);
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
    // 在页面构建完成后显示提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (comScalesList.isEmpty) {
        showTipInfo(localizedStrings.gTipNoDeviceAddFirst, context);
      } else {
        if (selScaleId == -1) {
          showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
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
                maxLines: 1, // 设置文本最大行数为1
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
                  maxLines: 1, // 设置文本最大行数为1

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
    // final _height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Container(
            width: width,
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // pageHeadInfo(
                //     context,
                //     width - headWidthPadding,
                //     localizedStrings.menuWifiSetting,
                //     localizedStrings.gTipWifiSettingPageHelp),
                Expanded(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      //串口秤的列表
                      Container(
                        width: 220,
                        color: Theme.of(context).colorScheme.surfaceTint,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                height: regularPadding,
                              ),
                              Expanded(
                                child: NewComScaleListWidget(
                                  listWidth: 220, // 列表宽度
                                  selScaleId: selScaleId,
                                  clickScale: (scale) {
                                    if (isSetting) {
                                      showTipInfo(
                                          localizedStrings
                                              .gTipPerformingOperation,
                                          context);
                                      return;
                                    }
                                    setState(() {
                                      changeScale(scale.scaleId);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant, //  分隔条颜色
                      ),
                      //wifi列表
                      comScalesList.isEmpty ? SizedBox() : showWifiListWidget(),

                      Container(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant, //  分隔条颜色
                      ),
                      comScalesList.isEmpty ? SizedBox() : showRightWigdet()
                    ])),
              ],
            )));
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

      showTipInfo(localizedStrings.gTipGetApListAndIP, context);
      PublicFunctions.changeWifiMode(selScaleId);

      isSetting = true;
      firstGetApList = true;
    });
  }

  Widget showWifiListWidget() {
    return SizedBox(
      width: wifiListWidth,
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
                              labelText: localizedStrings.gFindSsid,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary, // 设置边框颜色
                                  width: 1.0, // 设置边框宽度
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
                          width: 38, // 为Container指定一个固定的宽度
                          height: 38,
                          color:
                              Theme.of(context).colorScheme.surfaceContainerLow,
                          child: Tooltip(
                            message: localizedStrings.gMsgRefresh,
                            child: IconButton(
                              splashRadius: 20,
                              onPressed: _enableRefresh
                                  ? () {
                                      setState(() {
                                        displayedItems.clear();
                                        _enableRefresh = false;
                                      });

                                      showTipInfo(
                                          localizedStrings.gTipGetAPList,
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
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // 让子组件垂直居中
      children: [
        Expanded(
          child: ListView(
            children: [
              // 使用 Center 组件让 Container 左右居中
              Center(
                child: Container(
                  width: 450,
                  height: 100,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // 让 Column 内的子组件靠左对齐
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: regularPadding,
                      ),
                      Text(
                        getScaleModel() == "DPM"
                            ? localizedStrings.gTipConnectedInfo +
                                "            (Port: 8580)"
                            : localizedStrings.gTipConnectedInfo,
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: regularPadding,
                      ),
                      Text(
                        connectedSsid,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: smallPadding,
                      ),
                      Text(
                        connectedMac,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
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
              // 后续 Container 都用 Center 包裹实现居中
              SizedBox(
                height: regularPadding,
              ),
              Center(
                child: Container(
                  width: 450,
                  height: 81,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        alignment: Alignment.centerLeft,
                        child: Text(localizedStrings.gTipSSID),
                      ),
                      TextField(
                        readOnly: false,
                        controller: ssidController,
                        onChanged: (value) {},
                        maxLines: 1,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(28),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[\x00-\xF]+$')), // 允许输入数字和点
                        ],
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: regularPadding,
              ),
              Center(
                child: Container(
                  width: 450,
                  height: 81,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        alignment: Alignment.centerLeft,
                        child: Text(localizedStrings.gPassword),
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
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
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
              SizedBox(
                height: regularPadding,
              ),
              Center(
                child: Container(
                  width: 450,
                  // height: 78,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        alignment: Alignment.centerLeft,
                        child: Text(localizedStrings.gIpAddress),
                      ),
                      // 替换为新的输入框
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
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                              border: OutlineInputBorder(),
                              errorText: validateIpFlag(ipController.text)
                                  ? null
                                  : localizedStrings.gTipErrorIp,
                            ),
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                color: !_isStatic
                                    ? Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                    : Theme.of(context).colorScheme.onSurface),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ))
                    ],
                  ),
                ),
              ),

              Center(
                child: Container(
                  width: 450,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        alignment: Alignment.centerLeft,
                        child: Text(localizedStrings.gNetmask),
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
                                  color: validateIpFlag(netMaskController.text)
                                      ? Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                              border: OutlineInputBorder(),
                              errorText: validateIpFlag(netMaskController.text)
                                  ? null
                                  : localizedStrings.gTipErrorIp,
                            ),
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                color: !_isStatic
                                    ? Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                    : Theme.of(context).colorScheme.onSurface),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ))
                    ],
                  ),
                ),
              ),

              Center(
                child: Container(
                  width: 450,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        alignment: Alignment.centerLeft,
                        child: Text(localizedStrings.gGateway),
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
                                  color: validateIpFlag(gateWayController.text)
                                      ? Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                              border: OutlineInputBorder(),
                              errorText: validateIpFlag(gateWayController.text)
                                  ? null
                                  : localizedStrings.gTipErrorIp,
                            ),
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                color: !_isStatic
                                    ? Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                    : Theme.of(context).colorScheme.onSurface),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ))
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                double centerWidth = constraints.maxWidth;

                double btnWidth = 120.0;
                if (centerWidth > 560) {
                  btnWidth = (centerWidth - 80) / 4;
                  if (btnWidth > 200) {
                    btnWidth = 200;
                  }
                }

                return Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Container(
                        width: btnWidth,
                        height: 48,
                        margin: EdgeInsets.symmetric(horizontal: smallPadding),
                        child: showTextButton(
                            context,
                            btnHeight,
                            localizedStrings.gBtnGetIp,
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
                        margin: EdgeInsets.symmetric(horizontal: smallPadding),
                        child: showTextButton(
                            context,
                            btnHeight,
                            localizedStrings.gBtnStatic,
                            (_isStatic || isConnecting || isSetting)
                                ? null
                                : () {
                                    setState(() {
                                      _isStatic = true;

                                      showTipInfo(
                                          localizedStrings.gTipConnectStaticIp,
                                          context);
                                    });

                                    // sendDataToWifi();
                                  },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary),
                      ),
                      Container(
                        width: btnWidth,
                        height: 48,
                        margin: EdgeInsets.symmetric(horizontal: smallPadding),
                        child: showTextButton(
                            context,
                            btnHeight,
                            localizedStrings.gBtnDynamic,
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
                        margin: EdgeInsets.symmetric(horizontal: smallPadding),
                        child: showTextButton(
                            context,
                            btnHeight,
                            localizedStrings.gBtnConnect,
                            (isValidData() && !isConnecting && !isSetting)
                                ? () {
                                    showTipInfo(localizedStrings.gTipConnecting,
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
                    ]));
              }),
            ],
          ),
        ),
      ],
    ));
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
    bool res = false;

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

      showTipInfo(localizedStrings.gTipConnected, context);
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
}
