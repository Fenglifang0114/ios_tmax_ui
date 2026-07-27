//钃濈墮璁剧疆鐣岄潰   钃濈墮璁剧疆鍙兘閫氳繃涓插彛

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/no_device_widget.dart';
import 'package:t_max/data/icons.dart';
import '../data/downloadresponse.dart';
import 'package:t_max/functions/methods.dart';
import '../../eventbus/eventbus.dart';
import '../data/language.dart';
import '../functions/adaptive.dart';

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
            // if (myRespDataFromScale.msgBody.contains("TTM:NAM")) {
            if (myRespDataFromScale.msgBody.contains("+BLENAME:")) {
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
    final bool isMobile = Adaptive.isMobile(context);

    return Scaffold(
      drawer: isMobile ? _buildMobileDrawer(context) : null,
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leadingWidth: 100,
              leading: Builder(
                builder: (BuildContext ctx) {
                  return Row(
                    children: [
                      BackButton(
                        color: Colors.black87,
                        onPressed: () => Navigator.pop(context),
                      ),
                      GestureDetector(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: getSvgIcon(
                              weighingSvgIcon(), 24, 24, Colors.black87),
                        ),
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
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

  Widget _buildMobileDrawer(BuildContext context) {
    List<Scale> comScales =
        myAllScalesList.where((scale) => scale.tMedia == comScaleType).toList();

    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 16, right: 16),
              child: Text(
                localizedStrings?.gTitleDeviceList ?? "Device List",
                style: const TextStyle(
                  color: Color(0xFF005696),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: comScales.isEmpty
                  ? showNoDeviceWidget(context)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: comScales.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final scale = comScales[index];
                        final bool isSelect = (selScaleId == scale.scaleId);
                        final bool isOnline = scale.isOnline;

                        return GestureDetector(
                          onTap: () {
                            if (isSetting) {
                              showTipInfo(
                                localizedStrings?.gTipPerformingOperation ??
                                    "Performing operation",
                                context,
                              );
                              return;
                            }
                            Navigator.pop(context);
                            setState(() {
                              changeScale(scale.scaleId);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelect
                                  ? const Color(0xFF005696)
                                  : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelect
                                        ? Colors.white.withOpacity(0.2)
                                        : const Color(0xFFE8EEF4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  child: getSvgIcon(
                                    serialPortSvgIcon(),
                                    24,
                                    24,
                                    isSelect ? Colors.white : const Color(0xFF005696),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        scale.scaleName,
                                        style: TextStyle(
                                          color:
                                              isSelect ? Colors.white : Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isOnline
                                            ? (localizedStrings?.gTipOnline ?? "Online")
                                            : (localizedStrings?.gTipOffline ??
                                                "Offline"),
                                        style: TextStyle(
                                          color: isSelect
                                              ? Colors.white.withOpacity(0.9)
                                              : (isOnline
                                                  ? const Color(0xFF005696)
                                                  : const Color(0xFFFF4D4F)),
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
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
    );
  }

  //鍒囨崲鐨勬椂鍊欒淇敼鎺夌Г鐨勪俊鎭?
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
                          (localizedStrings?.gModifyBluetoothName ??
                              "gModifyBluetoothName"),
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
