//蓝牙设置界面   蓝牙设置只能通过串口

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import '../data/downloadresponse.dart';
import 'package:t_max/functions/methods.dart';
import '../../eventbus/eventbus.dart';
import '../data/language.dart';
import '../functions/adaptive.dart';
import '../widget/page_head.dart';

class BluetoothPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const BluetoothPage(
      {super.key, required this.onNavigate, required this.lastRouteName});

  @override
  BluetoothPageState createState() => BluetoothPageState();
}

class BluetoothPageState extends State<BluetoothPage> {
  final TextEditingController _deviceNameController = TextEditingController();
  // List<String> emissionPowerList = ['Strong', 'Normal', 'Weak'];
  String emissionPowerVale = '';
  Timer? _timer;

  bool isSetting = false;
  dynamic _eventbus1;
  dynamic _eventbus2;
  Map<String, String> emissionPowerMap = {};
  int selScaleId = -1;

  List<Scale> comScalesList = [];
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  void initState() {
    super.initState();
    emissionPowerMap = {
      "Strong": (localizedStrings?.gEPStrong ?? "gEPStrong"),
      "Normal": (localizedStrings?.gEPNormal ?? "gEPNormal"),
      "Weak": (localizedStrings?.gEPWeak ?? "gEPWeak"),
    };
    _deviceNameController.text = '';
    emissionPowerVale = 'Strong';

    for (var scale in myAllScalesList) {
      if (scale.tMedia == comScaleType) {
        comScalesList.add(scale);
      }
    }
    _eventbus1 = eventBus.on<EventConnectBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          isSetting = false;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            if (myRespDataFromScale.msgBody.contains('time out')) {
              showTipInfo((localizedStrings?.gTipTimeOut ?? "gTipTimeOut"), context);
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
            // if (myRespDataFromScale.msgBody.contains("TTM:NAM")) {
            if (myRespDataFromScale.msgBody.contains("+BLENAME:")) {
              _deviceNameController.text =
                  getBtName(myRespDataFromScale.msgBody);
            } else if (myRespDataFromScale.msgBody.contains("OK")) {
              showTipInfo((localizedStrings?.fSuccessMsg ?? "fSuccessMsg"), context);
            } else if (myRespDataFromScale.msgBody.contains('time out')) {
              showTipInfo((localizedStrings?.gTipTimeOut ?? "gTipTimeOut"), context);
            } else {
              showTipInfo(myRespDataFromScale.msgBody, context);
            }
          }
          _stopTimer();
        });
      }
    });
    // 在页面构建完成后显示提示
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

  String getBtName(String data) {
    int blNameIndex = data.indexOf('+BLENAME:');
    String afterBlName = data.substring(blNameIndex + '+BLENAME:'.length);
    int newlineIndex = afterBlName.indexOf('\r\n');
    if (newlineIndex != -1) {
      return afterBlName.substring(0, newlineIndex);
    } else {
      return afterBlName;
    }
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _stopTimer();
    _timer?.cancel();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = Adaptive.isMobile(context);

    return Scaffold(

      drawer: isMobile
          ? Drawer(
              width: scaleListWidth + 20,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    Container(
                      height: btnHeight + 40,
                      padding:
                          const EdgeInsets.only(left: regularPadding, top: 40),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        (localizedStrings?.gTitleDeviceList ?? "gTitleDeviceList"),
                        style: Theme.of(context).textTheme.labelLarge!.apply(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
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
                  ],
                ),
              ),
            )
          : null,
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            pageHeadInfo(context, width - headWidthPadding,
                (localizedStrings?.menuBluetoothSetting ?? "menuBluetoothSetting"), '', () {
              widget.onNavigate(widget.lastRouteName);
            },
                leading: isMobile
                    ? Padding(
                        padding: const EdgeInsets.only(left: regularPadding),
                        child: Builder(builder: (context) {
                          return IconButton(
                            icon: Icon(Icons.menu_open,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          );
                        }),
                      )
                    : null),
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
                        comScalesList.isEmpty
                            ? const SizedBox()
                            : Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight,
                                          maxWidth: constraints.maxWidth,
                                        ),
                                        child: IntrinsicHeight(
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                                regularPadding),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            child: showRightWigdet(),
                                          ),
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
          ],
        ),
      ),
    );
  }

  //切换的时候要修改掉秤的信息
  void changeScale(int scaleId) {
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
                height: 42,
                alignment: Alignment.centerLeft,
                child: Text(
                  (localizedStrings?.tipBluetoothDisconnect ?? "tipBluetoothDisconnect"),
                  overflow: TextOverflow.ellipsis,
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
                                  .outlineVariant), // 设置边框颜色
                          borderRadius: BorderRadius.circular(0), // 设置圆角
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _deviceNameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // 移除默认边框
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
                                    (localizedStrings?.gGetBluetoothName ?? "gGetBluetoothName"),
                                    isSetting || selScaleId == -1
                                        ? null
                                        : () {
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
                          (localizedStrings?.gModifyBluetoothName ?? "gModifyBluetoothName"),
                          isSetting || selScaleId == -1
                              ? null
                              : () {
                                  try {
                                    setState(() {
                                      sendBluetoothName();
                                    });
                                  } catch (e) {
                                    setState(() {
                                      showTipInfo(
                                          (localizedStrings?.gMsgSerialError ?? "gMsgSerialError"),
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
                  (localizedStrings?.gBluetoothEmissionPower ?? "gBluetoothEmissionPower"),
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
                                                .outlineVariant, // 设置边框颜色
                                            width: 1.0, // 设置边框宽度
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0.0))),
                                      border: OutlineInputBorder()),
                                  // 设置默认值
                                  value: emissionPowerVale,
                                  // 选择回调
                                  onChanged: (String? newPosition) {
                                    emissionPowerVale = newPosition.toString();
                                    setState(() {});
                                  },
                                  // 传入可选的数组

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
                        (localizedStrings?.gModifyBluetoothEmission ?? "gModifyBluetoothEmission"),
                        isSetting || selScaleId == -1
                            ? null
                            : () {
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
        showTipInfo((localizedStrings?.gTipDeviceNameEmpty ?? "gTipDeviceNameEmpty"), context);
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
    _timer?.cancel(); // 停止计时器
  }
}
