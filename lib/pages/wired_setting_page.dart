// wifi 璁剧疆鐣岄潰 鍙兘鐢ㄤ覆鍙ｈ缃?

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
import '../functions/adaptive.dart';
import '../widget/page_head.dart';
import '../data/timer_manager.dart';
import '../data/wifi_pwd_info.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';

class WiredSettingPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const WiredSettingPage(
      {super.key, required this.onNavigate, required this.lastRouteName});

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
  bool isBusy = false; //WIFI鍒楄〃杩涙潵鍙幏鍙栦竴娆?

  bool isSetting = false; //姝ｅ湪鎿嶄綔

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
          showTipInfo((localizedStrings?.gTipGetIpFail ?? "gTipGetIpFail"), context);
        }

        try {
          IpInfo ipInfoData = IpInfo.fromJson(json.decode(dataStr));

          setState(() {
            ipController.text = ipInfoData.ip ?? '';
            netMaskController.text = ipInfoData.netmask ?? '';
            gateWayController.text = ipInfoData.gateway ?? '';
          });
          showTipInfo((localizedStrings?.gTipGetIpOk ?? "gTipGetIpOk"), context);
        } catch (e) {
          showTipInfo((localizedStrings?.gTipGetIpFail ?? "gTipGetIpFail"), context);
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
          showTipInfo((localizedStrings?.setIPSuccess ?? "setIPSuccess"), context);
        } else if (dataStr.contains('fail')) {
          showTipInfo((localizedStrings?.setIPFailed ?? "setIPFailed"), context);
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
          showTipInfo((localizedStrings?.setDHCPSuccess ?? "setDHCPSuccess"), context);
          if (_isStatic && isSetting) {
            IpInfo ipInfo = IpInfo(
              ipController.text,
              gateWayController.text,
              netMaskController.text,
            );
            PublicFunctions.setWiredIp(selScaleId, jsonEncode(ipInfo));
          }
        } else if (dataStr.contains('fail')) {
          showTipInfo((localizedStrings?.setDHCPFailed ?? "setDHCPFailed"), context);
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
          showTipInfo((localizedStrings?.gTipGetIpFail ?? "gTipGetIpFail"), context);
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

    // 鍦ㄩ〉闈㈡瀯寤哄畬鎴愬悗鏄剧ず鎻愮ず
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (comScalesList.isEmpty) {
        showTipInfo((localizedStrings?.gTipNoDeviceAddFirst ?? "gTipNoDeviceAddFirst"), context);
      } else {
        if (selScaleId == -1) {
          showTipInfo((localizedStrings?.gTipSelectDeviceFirst ?? "gTipSelectDeviceFirst"), context);
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

    netMaskController.dispose();
    ipController.dispose();
    gateWayController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = Adaptive.isMobile(context);

    return Scaffold(

      drawer: isMobile
          ? Drawer(
              width: 220,
              child: NewComScaleListWidget(
                listWidth: 220,
                selScaleId: selScaleId,
                clickScale: (scale) {
                  if (isSetting) {
                    showTipInfo(
                        (localizedStrings?.gTipPerformingOperation ?? "gTipPerformingOperation"), context);
                    return;
                  }
                  setState(() {
                    changeScale(scale.scaleId);
                  });
                },
              ),
            )
          : null,
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            pageHeadInfo(context, width - headWidthPadding,
                (localizedStrings?.menuWiredSetting ?? "menuWiredSetting"), '', () {
              widget.onNavigate(widget.lastRouteName);
            },
                leading: isMobile
                    ? Padding(
                        padding: const EdgeInsets.only(left: regularPadding),
                        child: Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.menu_open,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      )
                    : null),
            Expanded(
              child: Row(
                children: [
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
                                  showTipInfo((localizedStrings?.gTipPerformingOperation ?? "gTipPerformingOperation"), context);
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
                          child: SingleChildScrollView(
                            child: comScalesList.isEmpty ? const SizedBox() : showRightWigdet(),
                          ),
                        ),
                      ],
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
      if (isBusy) {
        return showTipInfo((localizedStrings?.gTipGetIP ?? "gTipGetIP"), context);
      }
      netMaskController.clear();
      ipController.clear();
      gateWayController.clear();
      selScaleId = scaleId;
      showTipInfo((localizedStrings?.gTipGetIP ?? "gTipGetIP"), context);
      PublicFunctions.getWiredDhcp(selScaleId);

      isBusy = true;
    });
  }

  Widget showRightWigdet() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 670;
        final itemWidth = isNarrow ? constraints.maxWidth.clamp(0.0, 350.0) : 300.0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            if (isNarrow)
              Column(
                children: [
                  _buildWiredField((localizedStrings?.gIpAddress ?? "gIpAddress"), ipController, width: itemWidth),
                  const SizedBox(height: 20),
                  _buildWiredField((localizedStrings?.gNetmask ?? "gNetmask"), netMaskController, width: itemWidth),
                  const SizedBox(height: 20),
                  _buildWiredField((localizedStrings?.gGateway ?? "gGateway"), gateWayController, width: itemWidth),
                  const SizedBox(height: 20),
                  _buildDhcpToggle(width: itemWidth),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWiredField((localizedStrings?.gIpAddress ?? "gIpAddress"), ipController, width: itemWidth),
                      const SizedBox(width: 70),
                      _buildWiredField((localizedStrings?.gNetmask ?? "gNetmask"), netMaskController, width: itemWidth),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWiredField((localizedStrings?.gGateway ?? "gGateway"), gateWayController, width: itemWidth),
                      const SizedBox(width: 70),
                      _buildDhcpToggle(width: itemWidth),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 40),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isStatic)
                    Container(
                      height: 48,
                      margin: EdgeInsets.symmetric(horizontal: smallPadding),
                      child: showTextButton(
                        context,
                        btnHeight,
                        (localizedStrings?.setStaticIP ?? "setStaticIP"),
                        (_isStatic && isValidData())
                            ? () {
                                if (isBusy) {
                                  return showTipInfo((localizedStrings?.pleaseWait ?? "pleaseWait"), context);
                                }
                                isBusy = true;
                                PublicFunctions.setWiredDhcp(selScaleId, 'false');
                                isSetting = true;
                              }
                            : null,
                        Theme.of(context).colorScheme.onPrimary,
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  Container(
                    height: 48,
                    margin: EdgeInsets.symmetric(horizontal: smallPadding),
                    child: showTextButton(
                      context,
                      btnHeight,
                      (localizedStrings?.gBtnGetIp ?? "gBtnGetIp"),
                      () {
                        if (selScaleId == -1) {
                          showTipInfo((localizedStrings?.gTipSelectDeviceFirst ?? "gTipSelectDeviceFirst"), context);
                          return;
                        }
                        showTipInfo((localizedStrings?.gTipGetIP ?? "gTipGetIP"), context);
                        PublicFunctions.getWiredDhcp(selScaleId);
                      },
                      Theme.of(context).colorScheme.onPrimary,
                      Theme.of(context).colorScheme.onTertiaryFixedVariant,
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 58),
          ],
        );
      },
    );
  }

  Widget _buildWiredField(String label, TextEditingController controller, {double width = 300.0}) {
    return Center(
      child: Container(
        width: width,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Container(
              height: 30,
              alignment: Alignment.centerLeft,
              child: Text(label),
            ),
            SizedBox(
              height: 78,
              child: TextField(
                readOnly: !_isStatic,
                controller: controller,
                keyboardType: TextInputType.number,
                maxLines: 1,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: validateIpFlag(controller.text)
                          ? Theme.of(context).colorScheme.outlineVariant
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  errorText: validateIpFlag(controller.text) ? null : (localizedStrings?.gTipErrorIp ?? "gTipErrorIp"),
                ),
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color: !_isStatic
                          ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDhcpToggle({double width = 300.0}) {
    return Container(
      width: width,
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          Container(
            height: 30,
            alignment: Alignment.centerLeft,
            child: const Text("DHCP"),
          ),
          Container(
            height: 78,
            alignment: Alignment.centerLeft,
            child: IconButton(
              iconSize: 40,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                !_isStatic ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
              ),
              color: !_isStatic
                  ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              onPressed: () async {
                if (selScaleId == -1) {
                  showTipInfo((localizedStrings?.gTipSelectDeviceFirst ?? "gTipSelectDeviceFirst"), context);
                  return;
                }
                if (isBusy) {
                  return showTipInfo((localizedStrings?.pleaseWait ?? "pleaseWait"), context);
                }
                if (_isPressing) {
                  showTipInfo((localizedStrings?.pleaseWait ?? "pleaseWait"), context);
                  return;
                }

                setState(() {
                  _isStatic = !_isStatic;
                });
                if (!_isStatic) {
                  isBusy = true;
                  PublicFunctions.setWiredDhcp(selScaleId, 'true');
                }
                _isPressing = true;
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) {
                  setState(() {
                    _isPressing = false;
                  });
                }
              },
            ),
          )
        ],
      ),
    );
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
