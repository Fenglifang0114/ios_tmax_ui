import 'package:flutter/material.dart';
import 'package:t_max/data/timer_manager.dart';
import '../../data/currentport_data.dart';
import '../../data/device_data.dart';
import '../../data/reqweightdata_data.dart';
import '../../data/weight_data.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../data/downloadresponse.dart';
import '../data/scale_info_from_scale.dart';
import '../data/screen_mgr.dart';
import '../widget/page_head.dart';

class WeightModePage extends StatefulWidget {
  const WeightModePage({Key? key}) : super(key: key);
  @override
  State<WeightModePage> createState() => WeightModePageState();
}

class WeightModePageState extends State<WeightModePage> {
  String dialogString = " ";
  List<String> items = [];

  late ScrollController _reportScrollerController;
  late String lastWeight;
  bool isStart = false;
  String productNameValue = "";
  String userNameValue = "";
  List<String> productNameList = [];
  List<String> userNameList = [];

  ///创建文本控制器实例
  final TextEditingController _errorText = TextEditingController();
  late int weightMode; //0,手动保存，1，连续保存，2，稳定保存
  late int dateformat;
  late double zeroRange;
  bool isCnting = false;

  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus5;
  dynamic eventBus6;
  dynamic eventBus7;

  @override
  void initState() {
    super.initState();
    _reportScrollerController = ScrollController();
    lastWeight = "*";
    dateformat = 1;
    zeroRange = 0;
    _errorText.text = '';
    if (!isStart) {
      cntScaleTimerMgr.stopCntScaleTimer();
      cntScaleTimerMgr.startCntScaleTimer(5);
    }

    eventBus1 = eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
        });
      }
    });

    eventBus2 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        setState(() {
          myReqWeightCountine = event.obj;
          isStart = true;
          myScreenMgr.serialPortST = true;
          isCnting = true;
        });
      }
    });

    eventBus3 = eventBus.on<EventCurrentPort>().listen((event) {
      if (mounted) {
        setState(() {
          myCurrentPort = event.obj;
        });
      }
    });
    eventBus4 = eventBus.on<EventWtData>().listen((event) {
      if (mounted) {
        setState(() {
          myWtData = event.obj;
        });
      }
    });

    eventBus5 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRegWeightResp = event.obj;
        if (myRegWeightResp.msgBody.contains('ok')) {
          setState(() {
            isStart = true;
          });
        } else {
          setState(() {
            isStart = false;
            cntScaleTimerMgr.stopCntScaleTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
          });
        }
      }
    });

    eventBus6 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myUnregWeightResp = event.obj;
        if (myUnregWeightResp.msgBody.contains('ok')) {
          setState(() {
            isStart = false;
          });
          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.startCntScaleTimer(5);
        }
      }
    });
    eventBus7 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        if (isStart) {
          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.stopPortOffTimer();
          cntScaleTimerMgr.startPortOffTimer(2, () {
            if (!isCnting) {
              setState(() {
                myScreenMgr.serialPortST = false;
              });
            }
            isCnting = false;
          });
        }

        setState(() {
          myFactoryInfoFromScale = event.obj;
          if (myFactoryInfoFromScale.modelName != '') {
            myScreenMgr.serialPortST = true;
          } else {
            myScreenMgr.serialPortST = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _reportScrollerController.dispose();
    eventBus1.cancel();
    eventBus2.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    eventBus7.cancel();
    cntScaleTimerMgr.stopPortOffTimer();
    super.dispose();
  }

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: firstLayout(context, _width),
    );
  }

  Widget firstLayout(context, _width) {
    return Container(
        width: _width,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _width,
              height: 50,
              child: pageHead(context, localizedStrings.weighing_title,
                  localizedStrings.serial_port_status),
            ),
            const SizedBox(height: 5),
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildTextAndImage(
                                  50,
                                  localizedStrings.stable,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("assets/images/gray.png")
                                      : (myReqWeightCountine
                                                  .msgBody!.isStable &&
                                              isStart)
                                          ? ("assets/images/blue.png")
                                          : ("assets/images/gray.png"),
                                  constraints),
                              buildTextAndImage(
                                  50,
                                  localizedStrings.net,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("assets/images/gray.png")
                                      : (myReqWeightCountine.msgBody!.isNet &&
                                              isStart)
                                          ? ("assets/images/blue.png")
                                          : ("assets/images/gray.png"),
                                  constraints),
                              buildTextAndImage(
                                  50,
                                  localizedStrings.zero,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("assets/images/gray.png")
                                      : (myReqWeightCountine.msgBody!.isZero &&
                                              isStart)
                                          ? ("assets/images/blue.png")
                                          : ("assets/images/gray.png"),
                                  constraints),
                            ]);
                      }),
                    ),

                    Expanded(
                        flex: 5,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildTextWithWeight(
                                  280,
                                  70,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("-----")
                                      : myReqWeightCountine.msgBody!.weightVal,
                                  55,
                                  constraints,
                                  Theme.of(context).colorScheme.primary),
                              buildTextWithUnit(
                                  100,
                                  70,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("kg")
                                      : myReqWeightCountine.msgBody!.weightUnit,
                                  30,
                                  constraints,
                                  Theme.of(context).colorScheme.primary)
                            ],
                          );
                        })),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        flex: 1,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStartIcon(50, 30, constraints,
                                  Theme.of(context).colorScheme.primary),
                              buildStopIcon(50, 30, constraints,
                                  Theme.of(context).colorScheme.primary)
                            ],
                          );
                        })),
                    Expanded(
                        flex: 1,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFlexibleButtonAndText(
                                width: 150,
                                buttonText: localizedStrings.button_tare,
                                onPressed: PublicFunctions.performTare,
                                constraints: constraints,
                                isTrue: isStart,
                              ),
                              _buildFlexibleButtonAndText(
                                width: 150,
                                buttonText: localizedStrings.button_zero,
                                onPressed: PublicFunctions.performZero,
                                constraints: constraints,
                                isTrue: isStart,
                              ),
                            ],
                          );
                        })),
                  ],
                );
              }),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ));
  }

  Widget buildStartIcon(double width, double? iconSize,
      BoxConstraints constraints, Color? color) {
    width = width * constraints.maxWidth / 100;
    iconSize = iconSize! * constraints.maxHeight / 100;

    return SizedBox(
      width: width,
      child: IconButton(
        //开始按钮
        icon: const Icon(Icons.play_arrow),
        iconSize: iconSize,
        color: (isStart) ? (Colors.grey) : (color),
        onPressed: () {
          setState(() {
            if (!isStart) {
              if (MyApp.webchannel1.heartStatus == true) {
                isStart = true;
                PublicFunctions.getWeight();
              }
            }
            cntScaleTimerMgr.stopPortOffTimer();
            cntScaleTimerMgr.startPortOffTimer(2, () {
              if (!isCnting) {
                setState(() {
                  myScreenMgr.serialPortST = false;
                });
              }
              isCnting = false;
            });
            cntScaleTimerMgr.stopCntScaleTimer();
          });
        },
      ),
    );
  }

  Widget buildStopIcon(double width, double? iconSize,
      BoxConstraints constraints, Color? color) {
    width = width * constraints.maxWidth / 100;
    iconSize = iconSize! * constraints.maxHeight / 100;

    return SizedBox(
      width: width,
      child: IconButton(
        onPressed: () {
          if (isStart) {
            setState(() {
              if (MyApp.webchannel1.heartStatus == true) {
                isStart = false;
                PublicFunctions.stopWeight();
              }
            });
            cntScaleTimerMgr.stopCntScaleTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
            cntScaleTimerMgr.stopPortOffTimer();
          }
        },
        icon: const Icon(Icons.pause),
        iconSize: iconSize,
        color: (!isStart) ? (Colors.grey) : color,
      ),
    );
  }

  Widget buildTextWithWeight(double width, double height, String text,
      double? fontSize, BoxConstraints constraints, Color? color) {
    width = width * constraints.maxWidth / 400;
    height = height * constraints.maxHeight / 80;
    fontSize = fontSize! * constraints.maxHeight / 120;
    fontSize = constraints.maxHeight / 1.6;
    if (fontSize > constraints.maxWidth / 6) {
      fontSize = constraints.maxWidth / 6;
    }
    return Container(
      width: width,
      height: height,
      color: color,
      child: Column(
        // 将 Row 改为 Column
        mainAxisAlignment: MainAxisAlignment.center, // 垂直方向居中对齐
        crossAxisAlignment: CrossAxisAlignment.end, // 水平方向居右对齐
        children: [
          Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white, fontSize: fontSize),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildTextWithNOUnit(double width, double height, String text,
      double? fontSize, BoxConstraints constraints, Color? color) {
    width = width * constraints.maxWidth / 400;
    height = height * constraints.maxHeight / 80;
    return SizedBox(
      width: width,
      height: height,
    );
  }

  Widget buildTextWithUnit(double width, double height, String text,
      double? fontSize, BoxConstraints constraints, Color? color) {
    width = width * constraints.maxWidth / 400;
    height = height * constraints.maxHeight / 80;
    fontSize = constraints.maxHeight / 2;
    if (fontSize > constraints.maxWidth / 10) {
      fontSize = constraints.maxWidth / 10;
    }

    return Container(
      width: width,
      height: height,
      color: color,
      child: Column(
        // 将 Row 改为 Column
        mainAxisAlignment: MainAxisAlignment.center, // 垂直方向居中对齐
        crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居右对齐
        children: [
          Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white, fontSize: fontSize),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildTextAndImage(
      double width, String text, String imageName, BoxConstraints constraints) {
    var imageSize = constraints.maxHeight / 5;
    width = 25 * constraints.maxHeight / 30;
    var fontSize = 16 * constraints.maxHeight / 150;
    return Row(
      children: [
        SizedBox(
          width: width,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: fontSize),
          ),
        ),
        const SizedBox(width: 10),
        Image.asset(
          imageName,
          width: imageSize,
          height: imageSize,
        )
      ],
    );
  }

  Widget buildButton(Color? color, String text, BoxConstraints constraints,
      VoidCallback onPressed) {
    var fontSize = 14 * constraints.maxHeight / 60;
    var width = constraints.maxWidth / 10;

    return SizedBox(
        width: width,
        child: MaterialButton(
            color: color,
            textColor: Colors.white,
            elevation: 5.0,
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: fontSize, fontWeight: FontWeight.normal)),
            onPressed: onPressed));
  }

  Widget buildTextString(
      String text, BoxConstraints constraints, BuildContext context) {
    var fontSize = 14 * constraints.maxHeight / 60;
    var width = constraints.maxWidth / 10;
    return SizedBox(
        width: width,
        child: Text(text,
            style:
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.normal)));
  }

  bool isStartButtonEnable() {
    if (!isStart || myReqWeightCountine.msgBody == null) {
      return false;
    }
    if ((myReqWeightCountine.msgBody != null) &&
        (myReqWeightCountine.msgBody!.isStable)) {
      return true;
    }

    return false;
  }

  Widget _buildFlexibleButtonAndText({
    required double width,
    required String buttonText,
    required VoidCallback onPressed,
    required BoxConstraints constraints,
    required bool isTrue,
  }) {
    double buttonWidth = width * (constraints.maxWidth / 350); // 自适应按钮宽度
    double fontSize = 14 * (constraints.maxWidth / 260); // 自适应字体大小

    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: isTrue ? onPressed : null,
        child: Text(
          buttonText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
