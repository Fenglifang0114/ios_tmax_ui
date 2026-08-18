//钃濈墮璁剧疆鐣岄潰   钃濈墮璁剧疆鍙兘閫氳繃涓插彛

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';
import '../data/downloadresponse.dart';
import 'package:t_max/functions/methods.dart';
import '../../eventbus/eventbus.dart';
import '../data/language.dart';
import '../functions/adaptive.dart';
import '../data/writelog.dart';

class BluetoothPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const BluetoothPage(
      {super.key, required this.onNavigate, required this.lastRouteName});

  @override
  BluetoothPageState createState() => BluetoothPageState();
}

class BluetoothPageState extends State<BluetoothPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _deviceNameController = TextEditingController();
  String emissionPowerVale = '';
  Timer? _timer;

  bool isSetting = false;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  Map<String, String> emissionPowerMap = {};
  int selScaleId = -1;

  List<Scale> comScalesList = [];
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  void initState() {
    super.initState();
    writelog("[BT_PAGE] initState called");
    emissionPowerMap = {
      "Strong": (localizedStrings?.gEPStrong ?? "gEPStrong"),
      "Normal": (localizedStrings?.gEPNormal ?? "gEPNormal"),
      "Weak": (localizedStrings?.gEPWeak ?? "gEPWeak"),
    };
    _deviceNameController.text = '';
    emissionPowerVale = 'Strong';

    PublicFunctions.getScaleList();

    comScalesList =
        myAllScalesList.where((scale) => scale.tMedia == comScaleType).toList();
    if (comScalesList.isNotEmpty && selScaleId == -1) {
      selScaleId = comScalesList.first.scaleId;
    }
    _eventbus1 = eventBus.on<EventConnectBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          isSetting = false;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            if (myRespDataFromScale.msgBody.contains('time out')) {
              showTipInfo(
                  (localizedStrings?.gTipTimeOut ?? "gTipTimeOut"), context);
            } else {
              showTipInfo(myRespDataFromScale.msgBody, context);
            }
          }
          _stopTimer();
        });
      }
    });
    _eventbus2 = eventBus.on<EventBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          isSetting = false;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            if (myRespDataFromScale.msgBody.contains("+BLENAME:") ||
                myRespDataFromScale.msgBody.contains("TTM:NAM")) {
              _deviceNameController.text =
                  getBtName(myRespDataFromScale.msgBody);
            } else if (myRespDataFromScale.msgBody.contains("OK")) {
              showTipInfo(
                  (localizedStrings?.fSuccessMsg ?? "fSuccessMsg"), context);
            } else if (myRespDataFromScale.msgBody.contains('time out')) {
              showTipInfo(
                  (localizedStrings?.gTipTimeOut ?? "gTipTimeOut"), context);
            } else {
              showTipInfo(myRespDataFromScale.msgBody, context);
            }
          }
          _stopTimer();
        });
      }
    });
    _eventbus3 = eventBus.on<EventRespAddScale>().listen((event) {
      if (mounted) {
        setState(() {
          comScalesList =
              myAllScalesList.where((scale) => scale.tMedia == comScaleType).toList();
          if (comScalesList.isNotEmpty && selScaleId == -1) {
            selScaleId = comScalesList.first.scaleId;
          }
        });
      }
    });
    // 在页面构建完成后显示提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (myAllScalesList.isEmpty) {
        showTipInfo(
            (localizedStrings?.gTipNoDeviceAddFirst ?? "gTipNoDeviceAddFirst"),
            context);
      }
    });
  }

  String getBtName(String data) {
    if (data.contains('+BLENAME:')) {
      int blNameIndex = data.indexOf('+BLENAME:');
      String afterBlName = data.substring(blNameIndex + '+BLENAME:'.length);
      int newlineIndex = afterBlName.indexOf('\r\n');
      if (newlineIndex != -1) {
        return afterBlName.substring(0, newlineIndex).trim();
      } else {
        return afterBlName.trim();
      }
    } else if (data.contains('TTM:NAM-')) {
      int start = data.indexOf('TTM:NAM-') + 'TTM:NAM-'.length;
      int end = data.indexOf('\r\n');
      if (end != -1 && end > start) {
        return data.substring(start, end).trim();
      } else {
        return data.substring(start).replaceAll('\u0000', '').trim();
      }
    } else if (data.contains('TTM:NAM')) {
      int start = data.indexOf('TTM:NAM') + 'TTM:NAM'.length;
      int end = data.indexOf('\r\n');
      if (end != -1 && end > start) {
        return data.substring(start, end).trim();
      } else {
        return data.substring(start).replaceAll('\u0000', '').trim();
      }
    }
    return data.trim();
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _eventbus1?.cancel();
    _eventbus2?.cancel();
    _eventbus3?.cancel();
    _stopTimer();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Platform.isAndroid || Platform.isIOS || Adaptive.isMobile(context);
    writelog("[BT_PAGE] build called: isMobile=$isMobile, platformIsAndroid=${Platform.isAndroid}, screenWidth=${MediaQuery.of(context).size.width}, selScaleId=$selScaleId");

    if (myAllScalesList.isNotEmpty) {
      comScalesList =
          myAllScalesList.where((scale) => scale.tMedia == comScaleType).toList();
      if (selScaleId == -1 && comScalesList.isNotEmpty) {
        selScaleId = comScalesList.first.scaleId;
      }
    }

    return Scaffold(
        key: _scaffoldKey,
        drawer: isMobile ? _buildMobileDrawer(context) : null,
        appBar: isMobile
            ? AppBar(
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
                          onPressed: () {
                            writelog("[BT_PAGE] Back arrow pressed");
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              widget.onNavigate(widget.lastRouteName);
                            }
                          },
                        ),
                        MobileScaleHeaderIconButton(
                          onTap: () {
                            writelog("[BT_PAGE] Scale icon clicked -> opening drawer");
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ],
                    );
                  },
                ),
                title: Text(
                  localizedStrings?.menuBluetoothSetting ?? "Bluetooth Setting",
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              )
            : null,
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile)
                    Container(
                      width: scaleListWidth,
                      color: Theme.of(context).colorScheme.surfaceTint,
                      child: NewComScaleListWidget(
                        listWidth: scaleListWidth,
                        selScaleId: selScaleId,
                        clickScale: (scale) {
                          setState(() {
                            changeScale(scale.scaleId);
                          });
                        },
                      ),
                    ),
                  Expanded(
                    child: Row(
                      children: [
                        if (!isMobile)
                          Container(
                            width: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(regularPadding),
                            child: showRightWigdet(),
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

  Widget _buildMobileDrawer(BuildContext context) {
    List<Scale> comScales =
        myAllScalesList.where((scale) => scale.tMedia == comScaleType).toList();

    return UnifiedDeviceDrawerContent(
      scaleList: comScales,
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
        setState(() {
          changeScale(scale.scaleId);
        });
      },
    );
  }

  //切换的时候要修改掉秤的信息
  void changeScale(int scaleId) {
    writelog("[BT_PAGE] Scale changed to: $scaleId");
    setState(() {
      selScaleId = scaleId;
    });
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  Widget showRightWigdet() {
    final bool isMobile = Adaptive.isMobile(context);
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(
            height: regularPadding * 2,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  (localizedStrings?.tipBluetoothDisconnect ??
                      "tipBluetoothDisconnect"),
                  softWrap: true,
                  style: getTextStyle(color: colorScheme.error),
                ),
              ),
              Container(
                height: 42,
                alignment: Alignment.centerLeft,
                child: Text(
                  (localizedStrings?.gDeviceName ?? "gDeviceName"),
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700),
                child: Wrap(
                  spacing: regularPadding,
                  runSpacing: regularPadding,
                  children: [
                    Container(
                        height: btnHeight,
                        width: isMobile ? double.infinity : 460,
                        padding: const EdgeInsets.only(
                            left: regularPadding, right: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant), // 璁剧疆杈规棰滆壊
                          borderRadius: BorderRadius.circular(0), // 璁剧疆鍦嗚
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _deviceNameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // 绉婚櫎榛樿杈规
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  style: getTextStyle(),
                                ),
                              ),
                              SizedBox(
                                width: 140,
                                child: showTextButton(
                                    context,
                                    38,
                                    (localizedStrings?.gGetBluetoothName ??
                                        "gGetBluetoothName"),
                                    isSetting
                                        ? null
                                        : () {
                                            if (selScaleId == -1) {
                                              showTipInfo(
                                                  (localizedStrings?.gTipSelectDeviceFirst ??
                                                      "gTipSelectDeviceFirst"),
                                                  context);
                                              return;
                                            }
                                            writelog("[BT_PAGE] Get Bluetooth Name clicked for scaleId: $selScaleId");
                                            setState(() {
                                              _deviceNameController.clear();
                                            });
                                            PublicFunctions.getBtName(
                                                selScaleId);
                                            _startTimer(15);
                                          },
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    Theme.of(context).colorScheme.onPrimary),
                              )
                            ])),
                    SizedBox(
                      width: isMobile ? double.infinity : 220,
                      child: showTextButton(
                          context,
                          btnHeight,
                          (localizedStrings?.gModifyBluetoothName ??
                              "gModifyBluetoothName"),
                          isSetting
                              ? null
                              : () {
                                  if (selScaleId == -1) {
                                    showTipInfo(
                                        (localizedStrings?.gTipSelectDeviceFirst ??
                                            "gTipSelectDeviceFirst"),
                                    context);
                                    return;
                                  }
                                  writelog("[BT_PAGE] Modify Bluetooth Name clicked for scaleId: $selScaleId");
                                  try {
                                    setState(() {
                                      sendBluetoothName();
                                    });
                                  } catch (e) {
                                    setState(() {
                                      showTipInfo(
                                          (localizedStrings?.gMsgSerialError ??
                                              "gMsgSerialError"),
                                          context);
                                    });
                                  }
                                },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary),
                    ),
                  ],
                ),
              )
            ]),
          ),
          const SizedBox(
            height: regularPadding,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700),
            child: Column(children: [
              Container(
                height: 42,
                alignment: Alignment.centerLeft,
                child: Text(
                  (localizedStrings?.gBluetoothEmissionPower ??
                      "gBluetoothEmissionPower"),
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(),
                ),
              ),
              Wrap(
                spacing: regularPadding,
                runSpacing: regularPadding,
                children: [
                  SizedBox(
                      height: btnHeight,
                      width: isMobile ? double.infinity : 350,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                borderRadius: BorderRadius.circular(0),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant, // 璁剧疆杈规棰滆壊
                                          width: 1.0, // 璁剧疆杈规瀹藉害
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0.0))),
                                    border: OutlineInputBorder()),
                                // 璁剧疆榛樿鍊?
                                value: emissionPowerVale,
                                // 閫夋嫨鍥炶皟
                                onChanged: (String? newPosition) {
                                  emissionPowerVale = newPosition.toString();
                                  setState(() {});
                                },
                                // 浼犲叆鍙€夌殑鏁扮粍

                                items: emissionPowerMap.entries
                                    .map<DropdownMenuItem<String>>((entry) {
                                  return DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      style: getTextStyle(),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ])),
                  SizedBox(
                    width: isMobile ? double.infinity : 320,
                    child: showTextButton(
                        context,
                        btnHeight,
                        (localizedStrings?.gModifyBluetoothEmission ??
                            "gModifyBluetoothEmission"),
                        isSetting
                            ? null
                            : () {
                                if (selScaleId == -1) {
                                  showTipInfo(
                                      (localizedStrings?.gTipSelectDeviceFirst ??
                                          "gTipSelectDeviceFirst"),
                                  context);
                                  return;
                                }
                                writelog("[BT_PAGE] Modify Emission Power clicked for scaleId: $selScaleId, power: $emissionPowerVale");
                                if (emissionPowerVale == 'Strong') {
                                  PublicFunctions.modifyBtPowerStrong(
                                      selScaleId);
                                } else if (emissionPowerVale == 'Normal') {
                                  PublicFunctions.modifyBtPowerNormal(
                                      selScaleId);
                                } else {
                                  PublicFunctions.modifyBtPowerWeak(selScaleId);
                                }
                                _startTimer(15);
                              },
                        Theme.of(context).colorScheme.onPrimary,
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void sendBluetoothName() async {
    if (_deviceNameController.text.isNotEmpty) {
      PublicFunctions.modifyBtName(_deviceNameController.text, selScaleId);
      isSetting = true;
      _startTimer(15);
    } else {
      setState(() {
        showTipInfo(
            (localizedStrings?.gTipDeviceNameEmpty ?? "gTipDeviceNameEmpty"),
            context);
      });
    }
  }

  void _startTimer(int time) {
    setState(() {
      isSetting = true;
      // print(time);
    });

    _timer = Timer(Duration(seconds: time), () {
      setState(() {
        isSetting = false;
        showTipInfo((localizedStrings?.gTipTimeOut ?? "gTipTimeOut"), context);
      });
    });
  }

  void _stopTimer() {
    isSetting = false;
    _timer?.cancel(); // 鍋滄璁℃椂鍣?
  }
}
