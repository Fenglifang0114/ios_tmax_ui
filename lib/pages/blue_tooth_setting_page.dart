//蓝牙设置界面   蓝牙设置只能通过串口

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import 'package:t_max/functions/methods.dart';
import '../../eventbus/eventbus.dart';
import '../data/language.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

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
      "Strong": localizedStrings.gEPStrong,
      "Normal": localizedStrings.gEPNormal,
      "Weak": localizedStrings.gEPWeak,
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
              showTipInfo(localizedStrings.gTipTimeOut, context);
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
              showTipInfo(localizedStrings.fSuccessMsg, context);
            } else if (myRespDataFromScale.msgBody.contains('time out')) {
              showTipInfo(localizedStrings.gTipTimeOut, context);
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
        showTipInfo(localizedStrings.gTipNoDeviceAddFirst, context);
      } else {
        if (selScaleId == -1) {
          showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(body: firstLayout(context, width));
  }

  //切换的时候要修改掉秤的信息
  void changeScale(int scaleId) {
    setState(() {
      selScaleId = scaleId;
    });
  }

  Widget firstLayout(context, width) {
    return Container(
        width: width,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // pageHeadInfo(context, width - headWidthPadding,
            //     localizedStrings.menuBluetoothSetting, ''),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    width: scaleListWidth,
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
                              listWidth: scaleListWidth, // 列表宽度
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
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant, //  分隔条颜色
                        ),
                        comScalesList.isEmpty ? SizedBox() : showRightWigdet()
                      ],
                    ),
                  ),
                ])),
          ],
        ));
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  Widget showRightWigdet() {
    return Expanded(
        child: Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          SizedBox(
            height: 50,
          ),
          SizedBox(
            width: 700,
            child: Column(children: [
              Container(
                height: 42,
                alignment: Alignment.centerLeft,
                child: Text(
                  localizedStrings.tipBluetoothDisconnect,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(color: colorScheme.error),
                ),
              ),
              Container(
                height: 42,
                alignment: Alignment.centerLeft,
                child: Text(
                  localizedStrings.gDeviceName,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(),
                ),
              ),
              SizedBox(
                width: 700,
                child: Row(children: [
                  Container(
                      height: btnHeight,
                      padding:
                          const EdgeInsets.only(left: regularPadding, right: 5),
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
                            SizedBox(
                              width: 300,
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
                              width: 150,
                              child: showTextButton(
                                  context,
                                  38,
                                  localizedStrings.gGetBluetoothName,
                                  isSetting || selScaleId == -1
                                      ? null
                                      : () {
                                          setState(() {
                                            _deviceNameController.clear();
                                          });
                                          PublicFunctions.getBtName(
                                              myDefScaleInfo.defScaleId!);
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
                    width: regularPadding,
                  ),
                  SizedBox(
                    width: 200,
                    child: showTextButton(
                        context,
                        btnHeight,
                        localizedStrings.gModifyBluetoothName,
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
                                        localizedStrings.gMsgSerialError,
                                        context);
                                  });
                                }
                              },
                        Theme.of(context).colorScheme.onPrimary,
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.onPrimary),
                  ),
                ]),
              )
            ]),
          ),
          const SizedBox(
            height: regularPadding,
          ),
          SizedBox(
            width: 700,
            child: Column(children: [
              Container(
                height: 42,
                alignment: Alignment.centerLeft,
                child: Text(
                  localizedStrings.gBluetoothEmissionPower,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(),
                ),
              ),
              SizedBox(
                width: 700,
                child: Row(children: [
                  SizedBox(
                      height: btnHeight,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 350,
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
                    width: regularPadding,
                  ),
                  SizedBox(
                    width: 320,
                    child: showTextButton(
                        context,
                        btnHeight,
                        localizedStrings.gModifyBluetoothEmission,
                        isSetting || selScaleId == -1
                            ? null
                            : () {
                                if (emissionPowerVale == 'Strong') {
                                  PublicFunctions.modifyBtPowerStrong(
                                      myDefScaleInfo.defScaleId!);
                                } else if (emissionPowerVale == 'Normal') {
                                  PublicFunctions.modifyBtPowerNormal(
                                      myDefScaleInfo.defScaleId!);
                                } else {
                                  PublicFunctions.modifyBtPowerWeak(
                                      myDefScaleInfo.defScaleId!);
                                }
                                _startTimer(15);
                              },
                        Theme.of(context).colorScheme.onPrimary,
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.onPrimary),
                  ),
                ]),
              )
            ]),
          ),
        ],
      ),
    ));
  }

  void sendBluetoothName() async {
    if (_deviceNameController.text.isNotEmpty) {
      PublicFunctions.modifyBtName(
          _deviceNameController.text, myDefScaleInfo.defScaleId!);
      isSetting = true;
      _startTimer(15);
    } else {
      setState(() {
        showTipInfo(localizedStrings.gTipDeviceNameEmpty, context);
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
        showTipInfo(localizedStrings.gTipTimeOut, context);
      });
    });
  }

  void _stopTimer() {
    isSetting = false;
    _timer?.cancel(); // 停止计时器
  }
}
