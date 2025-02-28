import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/timer_manager.dart';
import '../../data/device_data.dart';
import '../../data/reqweightdata_data.dart';
import '../../data/weight_data.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/comscaleinfo_data.dart';
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import '../data/language.dart';
import '../data/scale_list_data.dart';
import '../data/scalelist_data.dart';
import '../widget/page_head.dart';

class WeightModePage extends StatefulWidget {
  const WeightModePage({super.key});
  @override
  State<WeightModePage> createState() => WeightModePageState();
}

class WeightModePageState extends State<WeightModePage> {
  late String lastWeight;
  List<NetScaleInfoLocal> scaleNetItems = [];
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  int selScaleId = -1;
  bool isCnting = false;
  bool isStart = false;
  Timer? startTimer;
  Timer? innerTimer;

  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus5;
  dynamic eventBus6;
  dynamic eventBus7;

  void initScaleList() {
    scaleNetItems = myNetScaleList;
    selScaleId = myDefScaleInfo.defScaleId!;
    if (myNetScaleList.isNotEmpty) {
      defNetScaleInfo = NetScaleListMgr.findScaleInfo(
          myNetScaleList, myDefScaleInfo.defScaleId!);
    }
  }

  @override
  void initState() {
    super.initState();
    lastWeight = "*";

    onStartTimer();
    initScaleList();

    // cntScaleTimerMgr.startCntScaleTimer(10);
    cntScaleTimerMgr.startCntAliveTimer(10);
    PublicFunctions.getWeight(myDefScaleInfo.defScaleId!);

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
          ReqWeightCountine tempWeight = ReqWeightCountine();
          tempWeight = event.obj;
          if (tempWeight.scaleId == myDefScaleInfo.defScaleId!) {
            myReqWeightCountine = tempWeight;
            myComScaleInfo.isOnline = true;
            isCnting = true;
            isStart = true;
          }
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
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
        } else {}
      }
    });

    eventBus6 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {}
      }
    });

    eventBus7 = eventBus.on<EventSelWeighingScaleId>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        int scaleId = event.obj;
        //不需要去拿数据
        if (scaleId != selScaleId) {
          setState(() {
            PublicFunctions.stopWeight(selScaleId);
            selScaleId = scaleId;
            PublicFunctions.getWeight(selScaleId);
            DefScaleInfo.getDefScaleInfo(scaleId);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus2.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    eventBus7.cancel();
    startTimer?.cancel();
    innerTimer?.cancel();
    PublicFunctions.stopWeight(selScaleId);

    cntScaleTimerMgr.stopPortOffTimer();
    cntScaleTimerMgr.stopCntScaleTimer();
    super.dispose();
  }

  void onStartTimer() {
    startTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      isCnting = false;
      innerTimer = Timer(Duration(milliseconds: 1500), () {
        if (!isCnting) {
          setState(() {
            isStart = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: Container(
            child: pageHeadDefScale(context, localizedStrings.iTitleWeighting,
                localizedStrings.gTipWeighingPageHelp),
          ),
          leading: IconTheme(
              data: IconThemeData(
                  color: Theme.of(context).colorScheme.primary // 设置抽屉图标颜色
                  ),
              child: Builder(builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }))),
      body: firstLayout(context, width),
      drawer: Drawer(
          child: myWeighingScaleListDrawer(
              context,
              localizedStrings.gTipScaleList,
              scaleNetItems,
              selScaleId) // showNetScaleList(),
          ),
    );
  }

  Widget firstLayout(context, width) {
    return Container(
        width: width,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Expanded(
              flex: 3,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceTint,
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
                                  localizedStrings.iStable,
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
                                  localizedStrings.iTextNet,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("assets/images/gray.png")
                                      : (myReqWeightCountine.msgBody!.isNet &&
                                              isStart)
                                          ? ("assets/images/blue.png")
                                          : ("assets/images/gray.png"),
                                  constraints),
                              buildTextAndImage(
                                  50,
                                  localizedStrings.iTextZero,
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
                                  (myReqWeightCountine.msgBody == null ||
                                          !isStart)
                                      ? '---------'
                                      : myReqWeightCountine.msgBody!.weightVal,
                                  55,
                                  constraints,
                                  Theme.of(context).colorScheme.primary),
                              buildTextWithUnit(
                                  100,
                                  70,
                                  (myReqWeightCountine.msgBody == null ||
                                          !isStart)
                                      ? ("----")
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
                              _buildFlexibleButtonAndText(
                                  width: 150,
                                  buttonText: localizedStrings.gBtnTare,
                                  onPressed: PublicFunctions.performTare,
                                  constraints: constraints,
                                  isTrue: isStart,
                                  icon: Icons.title),
                              _buildFlexibleButtonAndText(
                                  width: 150,
                                  buttonText: localizedStrings.iBtnZero,
                                  onPressed: PublicFunctions.performZero,
                                  constraints: constraints,
                                  isTrue: isStart,
                                  icon: Icons.exposure_zero),
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
                color: Theme.of(context).colorScheme.surfaceTint,
              ),
            ),
          ],
        ));
  }

  Widget buildTextWithWeight(double width, double height, String text,
      double? fontSize, BoxConstraints constraints, Color? color) {
    width = constraints.maxWidth / 1.5;
    height = constraints.maxHeight / 1.2;
    fontSize = constraints.maxHeight / 2;
    fontSize = width / 5;
    if (fontSize > 160) {
      fontSize = 160;
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
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: fontSize),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildTextWithUnit(double width, double height, String text,
      double? fontSize, BoxConstraints constraints, Color? color) {
    width = constraints.maxWidth / 4;
    height = constraints.maxHeight / 1.2;
    fontSize = constraints.maxHeight / 5;
    fontSize = width / 2;
    if (fontSize > 80) {
      fontSize = 80;
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
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: fontSize),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildTextAndImage(
      double width, String text, String imageName, BoxConstraints constraints) {
    var imageSize = constraints.maxHeight / 6;
    width = constraints.maxWidth / 2;
    var fontSize = constraints.maxHeight / 12;
    if (constraints.maxHeight > constraints.maxWidth) {
      imageSize = constraints.maxWidth / 6;
      fontSize = constraints.maxWidth / 12;
    }
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
            textColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 5.0,
            onPressed: onPressed,
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: fontSize, fontWeight: FontWeight.normal))));
  }

  Widget buildTextString(
      String text, BoxConstraints constraints, BuildContext context) {
    var fontSize = 14 * constraints.maxHeight / 60;
    var width = constraints.maxWidth / 10;
    if (constraints.maxHeight > constraints.maxWidth) {
      fontSize = 14 * constraints.maxWidth / 60;
    }
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
    required IconData icon,
  }) {
    double buttonWidth = width * (constraints.maxWidth / 400); // 自适应按钮宽度
    double buttonHeight = (constraints.maxHeight / 2); // 自适应按钮宽度
    double fontSize = (constraints.maxHeight) / 4; // 自适应字体大小

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary, // 设置按钮的背景色
        elevation: 5, // 设置按钮的阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
        ),
      ),
      onPressed: isTrue ? onPressed : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: fontSize,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: Center(
              child: Text(
                buttonText,
                maxLines: 1,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: fontSize,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
