// wifi 设置界面 只能用串口设置

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/data/wifi_list_info.dart';
import 'package:t_max/data/writelog.dart';
import '../data/ipinfodata.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';
import '../data/wifi_pwd_info.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';

class WiredSettingPage extends StatefulWidget {
  const WiredSettingPage({super.key});

  @override
  State<WiredSettingPage> createState() => WiredSettingPageState();
}

class WiredSettingPageState extends State<WiredSettingPage> {
  TextEditingController netMaskController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController gateWayController = TextEditingController();

  int selectedIndex = -1;
  bool passwordLock = true;

  bool _isStatic = false;
  bool _isPressing = false;
  bool alreadyConnected = false;
  bool isBusy = false; //WIFI列表进来只获取一次

  bool isSetting = false; //正在操作

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;

  int selScaleId = -1;

  List<Scale> comScalesList = [];

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

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();

    for (var scale in myAllScalesList) {
      if (scale.tMedia == comScaleType) {
        comScalesList.add(scale);
      }
    }

    _eventbus1 = eventBus.on<EventRevGetWiredIp>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr.isEmpty || dataStr.contains("fail")) {
          showTipInfo(localizedStrings.localizedStrings.gTipGetIpFail, context);
        }

        try {
          IpInfo ipInfoData = IpInfo.fromJson(json.decode(dataStr));

          setState(() {
            ipController.text = ipInfoData.ip ?? '';
            netMaskController.text = ipInfoData.netmask ?? '';
            gateWayController.text = ipInfoData.gateway ?? '';
          });
          showTipInfo(localizedStrings.gTipGetIpOk, context);
        } catch (e) {
          showTipInfo(localizedStrings.gTipGetIpFail, context);
        }
      }
    });

    _eventbus2 = eventBus.on<EventRevSetWiredIp>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (isSetting) {
          isSetting = false;
        }
        if (dataStr.contains('ok')) {
          showTipInfo(localizedStrings.setIPSuccess, context);
        } else if (dataStr.contains('fail')) {
          showTipInfo(localizedStrings.setIPFailed, context);
        }
      }
    });

    _eventbus3 = eventBus.on<EventRevSetWiredDhcp>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (isBusy) {
          isBusy = false;
        }
        if (dataStr.contains('ok')) {
          showTipInfo(localizedStrings.setDHCPSuccess, context);
          if (_isStatic && isSetting) {
            IpInfo ipInfo = IpInfo(
              ipController.text,
              gateWayController.text,
              netMaskController.text,
            );
            PublicFunctions.setWiredIp(selScaleId, jsonEncode(ipInfo));
          }
        } else if (dataStr.contains('fail')) {
          showTipInfo(localizedStrings.setDHCPFailed, context);
        }
      }
    });

    _eventbus4 = eventBus.on<EventRevGetWiredDhcp>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (isBusy) {
          isBusy = false;
        }
        if (dataStr.isEmpty || dataStr.contains("fail")) {
          showTipInfo(localizedStrings.gTipGetIpFail, context);
          return;
        }

        PublicFunctions.getWiredIp(selScaleId);

        if (dataStr.contains('true')) {
          setState(() {
            _isStatic = false;
          });
        } else if (dataStr.contains('false')) {
          setState(() {
            _isStatic = true;
          });
        }
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
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();

    myWifiListInfo.wifidatalist!.clear();
    myWifiPwdInfoList.clear;

    super.dispose();
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
      if (isBusy) {
        return showTipInfo(localizedStrings.gTipGetIP, context);
      }
      netMaskController.clear();
      ipController.clear();
      gateWayController.clear();
      selScaleId = scaleId;
      showTipInfo(localizedStrings.gTipGetIP, context);
      PublicFunctions.getWiredDhcp(selScaleId);

      isBusy = true;
    });
  }

  Widget showRightWigdet() {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // 让子组件垂直居中
      children: [
        Expanded(
          child: ListView(
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 300,
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
                              ))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 70),
                  Center(
                    child: Container(
                      width: 300,
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
                                      color:
                                          validateIpFlag(netMaskController.text)
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                    ),
                                  ),
                                  border: OutlineInputBorder(),
                                  errorText:
                                      validateIpFlag(netMaskController.text)
                                          ? null
                                          : localizedStrings.gTipErrorIp,
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
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 300,
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
                                      color:
                                          validateIpFlag(gateWayController.text)
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                    ),
                                  ),
                                  border: OutlineInputBorder(),
                                  errorText:
                                      validateIpFlag(gateWayController.text)
                                          ? null
                                          : localizedStrings.gTipErrorIp,
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
                              ))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 70),
                  Container(
                    width: 300,
                    color: Theme.of(context).colorScheme.surface,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          alignment: Alignment.centerLeft,
                          child: Text("DHCP"),
                        ),
                        Container(
                          height: 78,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                              child: IconButton(
                                  iconSize: 40,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    !_isStatic
                                        ? Icons.toggle_on_outlined
                                        : Icons.toggle_off_outlined,
                                  ),
                                  color: !_isStatic
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onTertiaryFixedVariant
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                  onPressed: () async {
                                    if (selScaleId == -1) {
                                      showTipInfo(
                                          localizedStrings
                                              .gTipSelectDeviceFirst,
                                          context);
                                      return;
                                    }
                                    if (isBusy) {
                                      return showTipInfo(
                                          localizedStrings.pleaseWait, context);
                                    }
                                    if (_isPressing) {
                                      showTipInfo(
                                          localizedStrings.pleaseWait, context);
                                      return;
                                    }

                                    setState(() {
                                      _isStatic = !_isStatic;
                                      //开DHCP的时候直接下发，关DHCP的时候，需要确定IP地址后才能下发
                                    });
                                    if (!_isStatic) {
                                      isBusy = true;
                                      PublicFunctions.setWiredDhcp(
                                          selScaleId, 'true');
                                    }
                                    _isPressing = true;
                                    await Future.delayed(Duration(seconds: 2));
                                    setState(() {
                                      _isPressing = false;
                                    });
                                  })),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Spacer(),
        Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_isStatic)
            Container(
              height: 48,
              margin: EdgeInsets.symmetric(horizontal: smallPadding),
              child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.setStaticIP,
                  (_isStatic && isValidData())
                      ? () {
                          if (isBusy) {
                            return showTipInfo(
                                localizedStrings.pleaseWait, context);
                          }
                          isBusy = true;
                          PublicFunctions.setWiredDhcp(selScaleId, 'false');
                          isSetting = true;
                        }
                      : null,
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.onPrimary),
            ),
          Container(
            height: 48,
            margin: EdgeInsets.symmetric(horizontal: smallPadding),
            child: showTextButton(
                context, btnHeight, localizedStrings.gBtnGetIp, () {
              if (selScaleId == -1) {
                showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
                return;
              }
              showTipInfo(localizedStrings.gTipGetIP, context);
              PublicFunctions.getWiredDhcp(selScaleId);
            },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.onTertiaryFixedVariant,
                Theme.of(context).colorScheme.onPrimary),
          ),
        ])),
        SizedBox(
          height: 58,
        ),
      ],
    ));
  }

  bool isValidData() {
    if (!_isStatic) {
      return false;
    }

    if (ipController.text.isNotEmpty &&
        gateWayController.text.isNotEmpty &&
        netMaskController.text.isNotEmpty &&
        validateIpFlag(ipController.text) &&
        validateIpFlag(gateWayController.text) &&
        validateIpFlag(netMaskController.text)) {
      return true;
    }

    return false;
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

    myScaleCmd.cmdData = jsonEncode(myConnectApInfo).toString();

    PublicFunctions.sendMsg(selScaleId, jsonEncode(myScaleCmd));
    isSetting = true;
    writelog(jsonEncode(myScaleCmd));
    addWifiPwd();
  }

  void addWifiPwd() {
    String wifiStr = jsonEncode(myWifiPwdInfo).toString();

    PublicFunctions.addWifiPwd(wifiStr);
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

class IpInfo {
  String? ip;
  String? gateway;
  String? netmask;

  IpInfo(
    this.ip,
    this.gateway,
    this.netmask,
  );

  factory IpInfo.fromJson(Map<String, dynamic> json) => IpInfo(
        json['Ip'] as String?,
        json['Gateway'] as String?,
        json['Netmask'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'Ip': ip,
        'Gateway': gateway,
        'Netmask': netmask,
      };
}
