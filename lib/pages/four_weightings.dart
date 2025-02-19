import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/timer_manager.dart';
import '../../data/device_data.dart';
import '../../data/reqweightdata_data.dart';
import '../../data/weight_data.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import '../data/language.dart';
import '../data/scalecmd_data.dart';
import '../data/scalelist_data.dart';
import '../widget/page_head.dart';

class FourWeightsPage extends StatefulWidget {
  const FourWeightsPage({super.key});
  @override
  State<FourWeightsPage> createState() => FourWeightsPageState();
}

class FourWeightsPageState extends State<FourWeightsPage> {
  List<bool> isStartList = [false, false, false, false];
  List<bool> isCntingList = [false, false, false, false];
  List<int> scaleList = [];

  int scaleId1 = myDefScaleInfo.defScaleId!;
  int scaleId2 = 0;
  int scaleId3 = 0;
  int scaleId4 = 0;

  String scaleInfo1 = '';
  String scaleInfo2 = '';
  String scaleInfo3 = '';
  String scaleInfo4 = '';

  Timer? startTimer1;
  Timer? startTimer2;
  Timer? startTimer3;
  Timer? startTimer4;

  Timer? innerTimer1;
  Timer? innerTimer2;
  Timer? innerTimer3;
  Timer? innerTimer4;

  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus5;
  dynamic eventBus6;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < fourScaleList.length; i++) {
      String model = fourScaleList[i].scaleModel!;
      String sn = fourScaleList[i].scaleSn!;
      if (model == "TMax") {
        sn = "";
        model = "";
      }
      var scaleInfo =
          "$model    Sn:$sn    Ip:${fourScaleList[i].ip!}:${fourScaleList[i].port!}";
      if (i == 0) {
        scaleId1 = fourScaleList[i].scaleId!;
        scaleInfo1 = scaleInfo;
        scaleList.add(scaleId1);
        onStartTimer(i, startTimer1, innerTimer1);
      } else if (i == 1) {
        scaleId2 = fourScaleList[i].scaleId!;
        scaleInfo2 = scaleInfo;
        scaleList.add(scaleId2);
        onStartTimer(i, startTimer2, innerTimer2);
      } else if (i == 2) {
        scaleId3 = fourScaleList[i].scaleId!;
        scaleInfo3 = scaleInfo;
        scaleList.add(scaleId3);
        onStartTimer(i, startTimer3, innerTimer3);
      } else if (i == 3) {
        scaleId4 = fourScaleList[i].scaleId!;
        scaleInfo4 = scaleInfo;
        scaleList.add(scaleId4);
        onStartTimer(i, startTimer4, innerTimer4);
      }
    }

    startWgtCnt();
    cntScaleTimerMgr.stopCntScaleTimer();
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
          if (myReqWeightCountine.scaleId! == scaleId1) {
            myWgtCnt1 = myReqWeightCountine;
            isStartList[0] = true;
            isCntingList[0] = true;
          } else if (myReqWeightCountine.scaleId! == scaleId2) {
            myWgtCnt2 = myReqWeightCountine;
            isStartList[1] = true;
            isCntingList[1] = true;
          } else if (myReqWeightCountine.scaleId! == scaleId3) {
            myWgtCnt3 = myReqWeightCountine;
            isStartList[2] = true;
            isCntingList[2] = true;
          } else if (myReqWeightCountine.scaleId! == scaleId4) {
            myWgtCnt4 = myReqWeightCountine;
            isStartList[3] = true;
            isCntingList[3] = true;
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
          setState(() {
            if (myRespDataFromScale.scaleId == scaleId1) {
              isStartList[0] = true;
            } else if (myRespDataFromScale.scaleId == scaleId2) {
              isStartList[1] = true;
            } else if (myRespDataFromScale.scaleId == scaleId3) {
              isStartList[2] = true;
            } else if (myRespDataFromScale.scaleId == scaleId4) {
              isStartList[3] = true;
            }
          });
        } else {
          setState(() {
            if (myRespDataFromScale.scaleId == scaleId1) {
              isStartList[0] = false;
            } else if (myRespDataFromScale.scaleId == scaleId2) {
              isStartList[1] = false;
            } else if (myRespDataFromScale.scaleId == scaleId3) {
              isStartList[2] = false;
            } else if (myRespDataFromScale.scaleId == scaleId4) {
              isStartList[3] = false;
            }
          });
        }
      }
    });

    eventBus6 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
          setState(() {
            if (myRespDataFromScale.scaleId == scaleId1) {
              isStartList[0] = false;
            } else if (myRespDataFromScale.scaleId == scaleId2) {
              isStartList[1] = false;
            } else if (myRespDataFromScale.scaleId == scaleId3) {
              isStartList[2] = false;
            } else if (myRespDataFromScale.scaleId == scaleId4) {
              isStartList[3] = false;
            }
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

    startTimer1?.cancel();
    startTimer2?.cancel();
    startTimer3?.cancel();
    startTimer4?.cancel();

    innerTimer1?.cancel();
    innerTimer2?.cancel();
    innerTimer3?.cancel();
    innerTimer4?.cancel();

    cntScaleTimerMgr.stopPortOffTimer();

    super.dispose();
  }

  void startWgtCnt() {
    for (int i = 0; i < fourScaleList.length; i++) {
      PublicFunctions.getWeight(fourScaleList[i].scaleId!);
    }
  }

  void onStartTimer(int index, Timer? timer1, Timer? inner) {
    timer1 = Timer.periodic(Duration(seconds: 3), (timer) {
      isCntingList[index] = false;
      inner = Timer(Duration(seconds: 1), () {
        if (!isCntingList[index] && mounted) {
          setState(() {
            isStartList[index] = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: pageHeadDesign(
          context,
          localizedStrings.iTitleWeighting,
          scaleList,
          '',
        ),
      ),
      body: Container(
        width: width,
        height: height - 50,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
        child: buildScales(width, height - 50),
      ),
    );
  }

  Widget buildScales(double width, double height) {
    int selectedOption = fourScaleList.length;
    switch (selectedOption) {
      //选择一个时
      case 1:
        return Row(
          children: [
            Expanded(
              child: Center(
                child: buildOneScale(
                    context, width, height, 0, myWgtCnt1, scaleId1, scaleInfo1),
              ),
            ),
          ],
        );
      //选择2个时
      case 2:
        return Row(
          children: [
            Expanded(
              child: Center(
                child: buildOneScale(context, width / 2, height, 0, myWgtCnt1,
                    scaleId1, scaleInfo1),
              ),
            ),
            Expanded(
              child: Center(
                child: buildOneScale(context, width / 2, height, 1, myWgtCnt2,
                    scaleId2, scaleInfo2),
              ),
            ),
          ],
        );
      //选择3个时
      default:
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: buildOneScale(context, width / 2, height / 2, 0,
                          myWgtCnt1, scaleId1, scaleInfo1),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: buildOneScale(context, width / 2, height / 2, 1,
                          myWgtCnt2, scaleId2, scaleInfo2),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: buildOneScale(context, width / 2, height / 2, 2,
                          myWgtCnt3, scaleId3, scaleInfo3),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: buildOneScale(context, width / 2, height / 2, 3,
                          myWgtCnt4, scaleId4, scaleInfo4),
                    ),
                  ),
                ],
              )
            ]);
    }
  }

  Widget buildOneScale(dynamic context, double width, double height,
      int scaleNo, ReqWeightCountine reqWgt, int scaleId, String scaleInfo) {
    if (scaleId == 0) {
      return const SizedBox();
    }
    return Container(
        width: width,
        height: height,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              height: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceTint),
              child: Align(
                child: Text(
                  scaleInfo,
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
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
                                  localizedStrings.iStable,
                                  (reqWgt.msgBody == null)
                                      ? ("assets/images/gray.png")
                                      : (reqWgt.msgBody!.isStable &&
                                              isStartList[scaleNo])
                                          ? ("assets/images/blue.png")
                                          : ("assets/images/gray.png"),
                                  constraints),
                              buildTextAndImage(
                                  localizedStrings.iTextNet,
                                  (reqWgt.msgBody == null)
                                      ? ("assets/images/gray.png")
                                      : (reqWgt.msgBody!.isNet &&
                                              isStartList[scaleNo])
                                          ? ("assets/images/blue.png")
                                          : ("assets/images/gray.png"),
                                  constraints),
                              buildTextAndImage(
                                  localizedStrings.iTextZero,
                                  (reqWgt.msgBody == null)
                                      ? ("assets/images/gray.png")
                                      : (reqWgt.msgBody!.isZero &&
                                              isStartList[scaleNo])
                                          ? ("assets/images/blue.png")
                                          : ("assets/images/gray.png"),
                                  constraints),
                            ]);
                      }),
                    ),

                    Expanded(
                        flex: 7,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildTextWithWeight(
                                  (reqWgt.msgBody == null ||
                                          !isStartList[scaleNo])
                                      ? ("--------")
                                      : reqWgt.msgBody!.weightVal,
                                  constraints,
                                  Theme.of(context).colorScheme.primary),
                              buildTextWithUnit(
                                  (reqWgt.msgBody == null ||
                                          !isStartList[scaleNo])
                                      ? ("---")
                                      : reqWgt.msgBody!.weightUnit,
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
                    _buildFlexibleButtonAndTextT(
                        buttonText: localizedStrings.gBtnTare,
                        scaleId: scaleId,
                        constraints: constraints,
                        isTrue: isStartList[scaleNo],
                        icon: Icons.title),
                    _buildFlexibleButtonAndTextZ(
                        buttonText: localizedStrings.iBtnZero,
                        scaleId: scaleId,
                        constraints: constraints,
                        isTrue: isStartList[scaleNo],
                        icon: Icons.exposure_zero),
                  ],
                );
              }),
            ),
          ],
        ));
  }

  void performZero(int scaleId) {
    myScaleCmd.cmdMode = "zero";
    myScaleCmd.cmdData = "";
    PublicFunctions.sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  void performTare(int scaleId) {
    myScaleCmd.cmdMode = "tare";
    myScaleCmd.cmdData = "";
    PublicFunctions.sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  Widget buildTextWithWeight(
      String text, BoxConstraints constraints, Color? color) {
    double width = constraints.maxWidth / 10 * 7;
    double height = constraints.maxHeight / 1.2;
    double fontSize = 0;

    fontSize = width / 9 / 0.6;
    if (fontSize > 180) {
      fontSize = 180;
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

  Widget buildTextWithNOUnit(double width, double height, String text,
      double? fontSize, BoxConstraints constraints, Color? color) {
    width = width * constraints.maxWidth / 400;
    height = height * constraints.maxHeight / 80;
    return SizedBox(
      width: width,
      height: height,
    );
  }

  Widget buildTextWithUnit(
      String text, BoxConstraints constraints, Color? color) {
    double width = constraints.maxWidth / 10 * 2;
    double height = constraints.maxHeight / 1.2;
    double fontSize = 0;
    fontSize = width / 4 / 0.6; //一个字号占0.6
    if (fontSize > 180) {
      fontSize = 180;
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
      String text, String imageName, BoxConstraints constraints) {
    double width = 0;
    double fontSize = 0;

    fontSize = constraints.maxHeight / 10;
    width = constraints.maxWidth / 1.5;
    if (fontSize > 40) {
      fontSize = 40;
    }
    if (fontSize > width / 10 / 0.6) {
      fontSize = width / 10 / 0.6;
    }
    double imageSize = constraints.maxHeight / 5;
    if (imageSize > 60) {
      imageSize = 60;
    }
    if (imageSize > width / 3) {
      imageSize = width / 3;
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
    return SizedBox(
        width: width,
        child: Text(text,
            style:
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.normal)));
  }

  Widget _buildFlexibleButtonAndTextT({
    required String buttonText,
    required int scaleId,
    required BoxConstraints constraints,
    required bool isTrue,
    required IconData icon,
  }) {
    double buttonWidth = (constraints.maxWidth / 3); // 自适应按钮宽度
    double buttonH = (constraints.maxHeight / 2); // 自适应按钮宽度
    double fontSize = (buttonWidth / 10 / 0.6); // 自适应字体大小
    if (fontSize > 60) {
      fontSize = 60;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary, // 设置按钮的背景色
        elevation: 5, // 设置按钮的阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
        ),
      ),
      onPressed: isTrue
          ? () {
              performTare(scaleId);
            }
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: fontSize,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: buttonWidth,
            height: buttonH,
            child: Center(
              child: Text(
                buttonText,
                maxLines: 1,
                textAlign: TextAlign.left,
                style: TextStyle(
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

  Widget _buildFlexibleButtonAndTextZ({
    required String buttonText,
    required int scaleId,
    required BoxConstraints constraints,
    required bool isTrue,
    required IconData icon,
  }) {
    double buttonWidth = (constraints.maxWidth / 3); // 自适应按钮宽度
    double buttonH = (constraints.maxHeight / 2); // 自适应按钮宽度
    double fontSize = (buttonWidth / 10 / 0.6); // 自适应字体大小
    if (fontSize > 60) {
      fontSize = 60;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary, // 设置按钮的背景色
        elevation: 5, // 设置按钮的阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
        ),
      ),
      onPressed: isTrue
          ? () {
              performZero(scaleId);
            }
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: fontSize,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: buttonWidth,
            height: buttonH,
            child: Center(
              child: Text(
                buttonText,
                maxLines: 1,
                textAlign: TextAlign.left,
                style: TextStyle(
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
