// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:t_max/data/comscaleinfo_data.dart';
// import 'package:t_max/data/timer_manager.dart';
// import '../../data/device_data.dart';
// import '../../data/reqweightdata_data.dart';
// import '../../data/weight_data.dart';
// import '../../eventbus/eventbus.dart';
// import '../../functions/methods.dart';
// import '../data/downloadresponse.dart';
// import '../data/high_low_weight.dart';
// import '../data/manager_scale_channel.dart';
// import '../data/language.dart';
// import '../data/scalecmd_data.dart';
// import '../data/scalelist_data.dart';
// import '../dialog/check_value_set.dart';
// import '../widget/page_head.dart';

// class ProductionLinePage extends StatefulWidget {
//   const ProductionLinePage({Key? key}) : super(key: key);
//   @override
//   State<ProductionLinePage> createState() => ProductionLinePageState();
// }

// class ProductionLinePageState extends State<ProductionLinePage> {
//   List<bool> isStartList = [false, false, false];
//   List<bool> isCntingList = [false, false, false];

//   List<int> scaleList = [];

//   List<bool> s1W12HOL = [
//     false,
//     false,
//     false,
//     false,
//     false,
//     false
//   ]; //W1的high ok low  W2的high ok low
//   List<bool> s2W12HOL = [
//     false,
//     false,
//     false,
//     false,
//     false,
//     false
//   ]; //W1的high ok low  W2的high ok low
//   List<bool> s3W12HOL = [
//     false,
//     false,
//     false,
//     false,
//     false,
//     false
//   ]; //W1的high ok low  W2的high ok low

//   CheckWeightSet scale1HighLowInfo = CheckWeightSet(0, 0, 0, 0, 0);
//   CheckWeightSet scale2HighLowInfo = CheckWeightSet(0, 0, 0, 0, 0);
//   CheckWeightSet scale3HighLowInfo = CheckWeightSet(0, 0, 0, 0, 0);

//   int scaleId1 = defaultScaleId; //秤的ID
//   int scaleId2 = 0;
//   int scaleId3 = 0;

//   bool scale1Mode = false; //秤上模式的flag  W1模式 false  W2模式 True
//   bool scale2Mode = false;
//   bool scale3Mode = false;

//   int setScale1Mode = 1; //秤上模式的flag  W1模式 false  W2模式 True
//   int setScale2Mode = 1;
//   int setScale3Mode = 1;

//   String scaleInfo1 = ''; //秤的基础信息
//   String scaleInfo2 = '';
//   String scaleInfo3 = '';

//   dynamic eventBus1;
//   dynamic eventBus2;
//   dynamic eventBus3;
//   dynamic eventBus4;
//   dynamic eventBus5;
//   dynamic eventBus6;
//   dynamic eventBus7;
//   dynamic eventBus8;

//   @override
//   void initState() {
//     super.initState();
//     var fn = CheckWeightFunc();

//     for (int i = 0; i < fourScaleList.length; i++) {
//       String infoStr = fourScaleList[i].scaleModel! +
//           "    Sn:" +
//           fourScaleList[i].scaleSn! +
//           '\n' +
//           "Ip:" +
//           fourScaleList[i].ip! +
//           ":" +
//           fourScaleList[i].port!.toString();
//       var setHighLowValue =
//           fn.findScaleId(myCheckWeightSetList, fourScaleList[i].scaleId!);

//       if (i == 0) {
//         scaleId1 = fourScaleList[i].scaleId!;
//         scaleInfo1 = infoStr;
//         scale1HighLowInfo = setHighLowValue;
//         scaleList.add(scaleId1);
//       } else if (i == 1) {
//         scaleId2 = fourScaleList[i].scaleId!;
//         scaleInfo2 = infoStr;
//         scale2HighLowInfo = setHighLowValue;
//         scaleList.add(scaleId2);
//       } else if (i == 2) {
//         scaleId3 = fourScaleList[i].scaleId!;
//         scaleInfo3 = infoStr;
//         scale3HighLowInfo = setHighLowValue;
//         scaleList.add(scaleId3);
//       }
//     }

//     cntScaleTimerMgr.stopCntScaleTimer();
//     eventBus1 = eventBus.on<EventDeviceName>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myDevicedata = event.obj;
//         });
//       }
//     });

//     eventBus2 = eventBus.on<EventReqWeightCountine>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myReqWeightCountine = event.obj;
//           if (myReqWeightCountine.scaleId! == scaleId1) {
//             myWgtCnt1 = myReqWeightCountine;
//             isStartList[0] = true;
//             isCntingList[0] = true;
//             sendToCalHighLow(1, myWgtCnt1);
//           } else if (myReqWeightCountine.scaleId! == scaleId2) {
//             myWgtCnt2 = myReqWeightCountine;
//             isStartList[1] = true;
//             isCntingList[1] = true;
//             sendToCalHighLow(2, myWgtCnt2);
//           } else if (myReqWeightCountine.scaleId! == scaleId3) {
//             myWgtCnt3 = myReqWeightCountine;
//             isStartList[2] = true;
//             isCntingList[2] = true;
//             sendToCalHighLow(3, myWgtCnt3);
//           }
//         });
//       }
//     });

//     eventBus3 = eventBus.on<EventCurrentPort>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myCurrentPort = event.obj;
//         });
//       }
//     });
//     eventBus4 = eventBus.on<EventWtData>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myWtData = event.obj;
//         });
//       }
//     });

//     eventBus5 = eventBus.on<EventRegWeightResp>().listen((event) {
//       if (mounted) {
//         myRespDataFromScale = event.obj;
//         if (myRespDataFromScale.msgBody.contains('ok')) {
//           setState(() {
//             if (myRespDataFromScale.scaleId == scaleId1) {
//               isStartList[0] = true;
//             } else if (myRespDataFromScale.scaleId == scaleId2) {
//               isStartList[1] = true;
//             } else if (myRespDataFromScale.scaleId == scaleId3) {
//               isStartList[2] = true;
//             }
//           });
//         } else {
//           setState(() {
//             if (myRespDataFromScale.scaleId == scaleId1) {
//               isStartList[0] = false;
//             } else if (myRespDataFromScale.scaleId == scaleId2) {
//               isStartList[1] = false;
//             } else if (myRespDataFromScale.scaleId == scaleId3) {
//               isStartList[2] = false;
//             }
//           });
//         }
//       }
//     });

//     eventBus6 = eventBus.on<EventUnregWeightResp>().listen((event) {
//       if (mounted) {
//         myRespDataFromScale = event.obj;
//         if (myRespDataFromScale.msgBody.contains('ok')) {
//           setState(() {
//             if (myRespDataFromScale.scaleId == scaleId1) {
//               isStartList[0] = false;
//             } else if (myRespDataFromScale.scaleId == scaleId2) {
//               isStartList[1] = false;
//             } else if (myRespDataFromScale.scaleId == scaleId3) {
//               isStartList[2] = false;
//             }
//           });
//         }
//       }
//     });

//     eventBus7 = eventBus.on<EventSetLimitToScale>().listen((event) {
//       if (mounted) {
//         myRespDataFromScale = event.obj;
//         if (myRespDataFromScale.msgBody.contains('ok')) {
//           setState(() {
//             if (myRespDataFromScale.scaleId == scaleId1) {
//               if (setScale1Mode == 1) {
//                 scale1Mode = false;
//               } else {
//                 scale1Mode = true;
//               }
//             } else if (myRespDataFromScale.scaleId == scaleId2) {
//               if (setScale2Mode == 1) {
//                 scale2Mode = false;
//               } else {
//                 scale2Mode = true;
//               }
//             } else if (myRespDataFromScale.scaleId == scaleId3) {
//               if (setScale2Mode == 1) {
//                 scale3Mode = false;
//               } else {
//                 scale3Mode = true;
//               }
//             }
//           });
//         }
//       }
//     });

//     eventBus8 = eventBus.on<EventSwitchLimitFromScale>().listen((event) {
//       if (mounted) {
//         myRespDataFromScale = event.obj;
//         if (myRespDataFromScale.msgBody.contains('ok')) {
//           setState(() {
//             if (myRespDataFromScale.scaleId == scaleId1) {
//               sendLimitToScale(scale1HighLowInfo, scaleId1, scale1Mode);
//               setScale1Mode = 2;
//               if (scale1Mode) {
//                 setScale1Mode = 1;
//               }
//             } else if (myRespDataFromScale.scaleId == scaleId2) {
//               sendLimitToScale(scale2HighLowInfo, scaleId2, scale2Mode);
//               setScale2Mode = 2;
//               if (scale2Mode) {
//                 setScale2Mode = 1;
//               }
//             } else if (myRespDataFromScale.scaleId == scaleId3) {
//               sendLimitToScale(scale3HighLowInfo, scaleId3, scale3Mode);
//               setScale3Mode = 2;
//               if (scale3Mode) {
//                 setScale3Mode = 1;
//               }
//             }
//           });
//         }
//       }
//     });
//   }

//   void sendLimitToScale(CheckWeightSet limitInfo, int scaleId, bool scaleMode) {
//     int mode = 1;
//     if (!scaleMode) {
//       mode = 2;
//     }
//     if (mode == 1) {
//       PublicFunctions.setLowHighLimit(
//           "${limitInfo.lowValue1},${limitInfo.highValue1}", scaleId);
//     } else if (mode == 2) {
//       PublicFunctions.setLowHighLimit(
//           "${limitInfo.lowValue2},${limitInfo.highValue2}", scaleId);
//     }
//   }

//   void sendToCalHighLow(int mode, ReqWeightCountine wgtCnt) {
//     var weight = double.tryParse(wgtCnt.msgBody!.weightVal);
//     if (weight != null) {
//       if (weight >= 0) {
//         if (mode == 1) {
//           s1W12HOL = calHOL(weight, scale1HighLowInfo, scale1Mode);
//         } else if (mode == 2) {
//           s2W12HOL = calHOL(weight, scale2HighLowInfo, scale2Mode);
//         } else {
//           s3W12HOL = calHOL(weight, scale3HighLowInfo, scale3Mode);
//         }
//       }
//     }
//   }

//   List<bool> calHOL(
//       double weightValue, CheckWeightSet setValeInfo, bool scaleMode) {
//     var listHOL = [false, false, false, false, false, false];
//     //  scaleMode =false check Mode   scaleMode =True work mode
//     if (!scaleMode) {
//       if (weightValue < setValeInfo.lowValue1) {
//         listHOL[2] = true;
//       } else if (weightValue >= setValeInfo.lowValue1 &&
//           weightValue <= setValeInfo.highValue1) {
//         listHOL[1] = true;
//       } else if (weightValue > setValeInfo.highValue1) {
//         listHOL[0] = true;
//       }
//     }

//     if (scaleMode) {
//       if (weightValue < setValeInfo.lowValue2) {
//         listHOL[5] = true;
//       } else if (weightValue >= setValeInfo.lowValue2 &&
//           weightValue <= setValeInfo.highValue2) {
//         listHOL[4] = true;
//       } else if (weightValue > setValeInfo.highValue2) {
//         listHOL[3] = true;
//       }
//     }

//     return listHOL;
//   }

//   @override
//   void dispose() {
//     eventBus1.cancel();
//     eventBus2.cancel();
//     eventBus3.cancel();
//     eventBus4.cancel();
//     eventBus5.cancel();
//     eventBus6.cancel();

//     cntScaleTimerMgr.stopPortOffTimer();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final _width = MediaQuery.of(context).size.width;
//     final _height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(50),
//         child: pageHeadDesign(
//           context,
//           // localizedStrings.weighing_title,
//           'Production Line', scaleList,
//         ),
//       ),
//       body: Container(
//         width: _width,
//         height: _height,
//         decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
//         child: Container(
//           color: Theme.of(context).colorScheme.surfaceTint,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 flex: 3,
//                 child: buildOneScale(context, _width / 3, _height, 0, myWgtCnt1,
//                     scaleId1, scaleInfo1, scale1HighLowInfo, s1W12HOL),
//               ),
//               Container(
//                 color: Theme.of(context).colorScheme.primary,
//                 width: 2,
//               ),
//               Expanded(
//                   flex: 3,
//                   child: buildOneScale(
//                       context,
//                       _width / 3,
//                       _height,
//                       1,
//                       myWgtCnt2,
//                       scaleId2,
//                       scaleInfo2,
//                       scale2HighLowInfo,
//                       s2W12HOL)),
//               Container(
//                 color: Theme.of(context).colorScheme.primary,
//                 width: 2,
//               ),
//               Expanded(
//                   flex: 3,
//                   child: buildOneScale(
//                       context,
//                       _width / 3,
//                       _height,
//                       2,
//                       myWgtCnt3,
//                       scaleId3,
//                       scaleInfo3,
//                       scale3HighLowInfo,
//                       s3W12HOL)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildOneScale(
//       dynamic context,
//       double _width,
//       double _height,
//       int scaleNo,
//       ReqWeightCountine reqWgt,
//       int scaleId,
//       String scaleInfo,
//       CheckWeightSet checkHLSet,
//       List<bool> holList) {
//     if (scaleId == 0) {
//       return const SizedBox();
//     }
//     return Container(
//         width: _width,
//         height: _height,
//         decoration:
//             BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               width: _width,
//               height: 100,
//               decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surfaceTint),
//               child: Align(
//                 child: Text(
//                   scaleInfo,
//                   style: TextStyle(
//                       fontSize: 20,
//                       color: Theme.of(context).colorScheme.primary),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 1,
//               child: LayoutBuilder(
//                   builder: (BuildContext context, BoxConstraints constraints) {
//                 return Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       buildTextAndImage(
//                           constraints.maxWidth / 3,
//                           localizedStrings.stable,
//                           (reqWgt.msgBody == null)
//                               ? ("assets/images/gray.png")
//                               : (reqWgt.msgBody!.isStable &&
//                                       isStartList[scaleNo])
//                                   ? ("assets/images/blue.png")
//                                   : ("assets/images/gray.png"),
//                           constraints),
//                       buildTextAndImage(
//                           constraints.maxWidth / 3,
//                           localizedStrings.net,
//                           (reqWgt.msgBody == null)
//                               ? ("assets/images/gray.png")
//                               : (reqWgt.msgBody!.isNet && isStartList[scaleNo])
//                                   ? ("assets/images/blue.png")
//                                   : ("assets/images/gray.png"),
//                           constraints),
//                       buildTextAndImage(
//                           constraints.maxWidth / 3,
//                           localizedStrings.zero,
//                           (reqWgt.msgBody == null)
//                               ? ("assets/images/gray.png")
//                               : (reqWgt.msgBody!.isZero && isStartList[scaleNo])
//                                   ? ("assets/images/blue.png")
//                                   : ("assets/images/gray.png"),
//                           constraints),
//                     ]);
//               }),
//             ),
//             Expanded(
//               flex: 2,
//               child: Container(
//                 color: Theme.of(context).colorScheme.surfaceTint,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(child: LayoutBuilder(builder:
//                         (BuildContext context, BoxConstraints constraints) {
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           buildTextWithWeight(
//                               280,
//                               70,
//                               (reqWgt.msgBody == null)
//                                   ? "8888.8888"
//                                   : reqWgt.msgBody!.weightVal,
//                               55,
//                               constraints,
//                               Theme.of(context).colorScheme.primary),
//                           buildTextWithUnit(
//                               100,
//                               70,
//                               (reqWgt.msgBody == null)
//                                   ? ("kg")
//                                   : reqWgt.msgBody!.weightUnit,
//                               30,
//                               constraints,
//                               Theme.of(context).colorScheme.primary)
//                         ],
//                       );
//                     })),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: LayoutBuilder(
//                   builder: (BuildContext context, BoxConstraints constraints) {
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: buildStartIcon(
//                           constraints,
//                           Theme.of(context).colorScheme.primary,
//                           scaleNo,
//                           scaleId),
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: buildStopIcon(
//                           constraints,
//                           Theme.of(context).colorScheme.primary,
//                           scaleNo,
//                           scaleId),
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: buildTareIcon(
//                         constraints,
//                         Theme.of(context).colorScheme.primary,
//                         scaleNo,
//                         scaleId,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: buildZeroIcon(
//                         constraints,
//                         Theme.of(context).colorScheme.primary,
//                         scaleNo,
//                         scaleId,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                   ],
//                 );
//               }),
//             ),
//             Expanded(
//               flex: 1,
//               child: LayoutBuilder(
//                   builder: (BuildContext context, BoxConstraints constraints) {
//                 return Row(
//                   children: [
//                     buildTextCheck(constraints.maxWidth / 5, "", constraints),
//                     Expanded(
//                         child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                           buildTextCol(
//                               (constraints.maxWidth -
//                                       constraints.maxWidth / 5) /
//                                   3.3,
//                               "Low",
//                               constraints),
//                           buildTextCol(
//                               (constraints.maxWidth -
//                                       constraints.maxWidth / 5) /
//                                   3.3,
//                               "Ok",
//                               constraints),
//                           buildTextCol(
//                               (constraints.maxWidth -
//                                       constraints.maxWidth / 5) /
//                                   3.3,
//                               "High",
//                               constraints),
//                         ]))
//                   ],
//                 );
//               }),
//             ),
//             Expanded(
//               //check 部分
//               flex: 1,
//               child: LayoutBuilder(
//                   builder: (BuildContext context, BoxConstraints constraints) {
//                 return Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       buildTextCheck(
//                           constraints.maxWidth / 5, "Check:", constraints),
//                       Expanded(
//                           child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           buildImage(
//                               (reqWgt.msgBody == null)
//                                   ? ("assets/images/yellow.png")
//                                   : (holList[2])
//                                       ? ("assets/images/yellow.png")
//                                       : ("assets/images/grey_circle.png"),
//                               constraints),
//                           buildImage(
//                               (reqWgt.msgBody == null)
//                                   ? ("assets/images/green.png")
//                                   : (holList[1])
//                                       ? ("assets/images/green.png")
//                                       : ("assets/images/grey_circle.png"),
//                               constraints),
//                           buildImage(
//                               (reqWgt.msgBody == null)
//                                   ? ("assets/images/red.png")
//                                   : (holList[0])
//                                       ? ("assets/images/red.png")
//                                       : ("assets/images/grey_circle.png"),
//                               constraints),
//                         ],
//                       ))
//                     ]);
//               }),
//             ),
//             Expanded(
//               flex: 2,
//               child: LayoutBuilder(
//                   builder: (BuildContext context, BoxConstraints constraints) {
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: buildSetting(
//                           1,
//                           constraints,
//                           Theme.of(context).colorScheme.primary,
//                           scaleNo,
//                           scaleId,
//                           checkHLSet),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: buildSend(
//                           1,
//                           constraints,
//                           Theme.of(context).colorScheme.primary,
//                           scaleNo,
//                           scaleId,
//                           checkHLSet),
//                     ),
//                   ],
//                 );
//               }),
//             ),
//             Expanded(
//               //work 部分
//               flex: 1,
//               child: LayoutBuilder(
//                   builder: (BuildContext context, BoxConstraints constraints) {
//                 return Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       buildTextCheck(
//                           constraints.maxWidth / 5, " Work:", constraints),
//                       Expanded(
//                           child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           buildImage(
//                               (reqWgt.msgBody == null)
//                                   ? ("assets/images/yellow.png")
//                                   : (holList[5])
//                                       ? ("assets/images/yellow.png")
//                                       : ("assets/images/grey_circle.png"),
//                               constraints),
//                           buildImage(
//                               (reqWgt.msgBody == null)
//                                   ? ("assets/images/green.png")
//                                   : (holList[4])
//                                       ? ("assets/images/green.png")
//                                       : ("assets/images/grey_circle.png"),
//                               constraints),
//                           buildImage(
//                               (reqWgt.msgBody == null)
//                                   ? ("assets/images/red.png")
//                                   : (holList[3])
//                                       ? ("assets/images/red.png")
//                                       : ("assets/images/grey_circle.png"),
//                               constraints),
//                         ],
//                       ))
//                     ]);
//               }),
//             ),
//             Expanded(
//               flex: 2,
//               child: LayoutBuilder(
//                   builder: (BuildContext context, BoxConstraints constraints) {
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: buildSetting(
//                           2,
//                           constraints,
//                           Theme.of(context).colorScheme.primary,
//                           scaleNo,
//                           scaleId,
//                           checkHLSet),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: buildSend(
//                           2,
//                           constraints,
//                           Theme.of(context).colorScheme.primary,
//                           scaleNo,
//                           scaleId,
//                           checkHLSet),
//                     ),
//                   ],
//                 );
//               }),
//             ),
//             const SizedBox(
//               height: 10,
//             )
//           ],
//         ));
//   }

//   void performZero(int scaleId) {
//     myScaleCmd.cmdMode = "zero";
//     myScaleCmd.cmdData = "";
//     PublicFunctions.sendMsg(scaleId, jsonEncode(myScaleCmd));
//   }

//   void performTare(int scaleId) {
//     myScaleCmd.cmdMode = "tare";
//     myScaleCmd.cmdData = "";
//     PublicFunctions.sendMsg(scaleId, jsonEncode(myScaleCmd));
//   }

//   Widget buildStartIcon(
//       BoxConstraints constraints, Color? color, int scaleNo, int scaleId) {
//     double width = constraints.maxWidth / 6;
//     double iconSize = constraints.maxHeight * 0.3;

//     return SizedBox(
//       width: width,
//       child: IconButton(
//         //开始按钮
//         icon: const Icon(Icons.play_arrow),
//         iconSize: iconSize,
//         color: (isStartList[scaleNo])
//             ? (Theme.of(context).colorScheme.background)
//             : (color),
//         onPressed: () {
//           setState(() {
//             if (!isStartList[scaleNo]) {
//               isStartList[scaleNo] = true;
//               PublicFunctions.getWeight(scaleId);
//             }
//           });
//         },
//       ),
//     );
//   }

//   Widget buildStopIcon(
//       BoxConstraints constraints, Color? color, int scaleNo, int scaleId) {
//     double width = constraints.maxHeight / 6;
//     double iconSize = constraints.maxHeight * 0.3;
//     return SizedBox(
//       width: width,
//       child: IconButton(
//         onPressed: () {
//           if (isStartList[scaleNo]) {
//             setState(() {
//               isStartList[scaleNo] = false;
//               PublicFunctions.stopWeight(scaleId);
//             });
//           }
//         },
//         icon: const Icon(Icons.pause),
//         iconSize: iconSize,
//         color: (!isStartList[scaleNo])
//             ? (Theme.of(context).colorScheme.background)
//             : color,
//       ),
//     );
//   }

//   Widget buildTareIcon(
//       BoxConstraints constraints, Color? color, int scaleNo, int scaleId) {
//     double width = constraints.maxHeight / 6;
//     double iconSize = constraints.maxHeight * 0.3;
//     return SizedBox(
//       width: width,
//       child: IconButton(
//         onPressed: isStartList[scaleNo]
//             ? () {
//                 performTare(scaleId);
//               }
//             : null,
//         icon: const Icon(Icons.title),
//         iconSize: iconSize,
//         color: (!isStartList[scaleNo])
//             ? (Theme.of(context).colorScheme.background)
//             : color,
//       ),
//     );
//   }

//   Widget buildZeroIcon(
//       BoxConstraints constraints, Color? color, int scaleNo, int scaleId) {
//     double width = constraints.maxHeight / 6;
//     double iconSize = constraints.maxHeight * 0.4;
//     return SizedBox(
//       width: width,
//       child: IconButton(
//         onPressed: isStartList[scaleNo]
//             ? () {
//                 performZero(scaleId);
//               }
//             : null,
//         icon: const Icon(Icons.exposure_zero),
//         iconSize: iconSize,
//         color: (!isStartList[scaleNo])
//             ? (Theme.of(context).colorScheme.background)
//             : color,
//       ),
//     );
//   }

//   Widget buildSetting(int mode, BoxConstraints constraints, Color? color,
//       int scaleNo, int scaleId, CheckWeightSet setValueInfo) {
//     double width = constraints.maxHeight / 6;
//     double iconSize = constraints.maxHeight * 0.4;
//     return SizedBox(
//       width: width,
//       child: IconButton(
//         onPressed: () {
//           highLowSettingDialog(context, setValueInfo, mode);
//         },
//         icon: const Icon(Icons.settings),
//         iconSize: iconSize,
//         color: color,
//       ),
//     );
//   }

//   Widget buildSend(int mode, BoxConstraints constraints, Color? color,
//       int scaleNo, int scaleId, CheckWeightSet setValueInfo) {
//     double width = constraints.maxHeight / 6;
//     double iconSize = constraints.maxHeight * 0.4;
//     return SizedBox(
//       width: width,
//       child: IconButton(
//         onPressed: () {
//           if (mode == 1) {
//             PublicFunctions.setLowHighLimit(
//                 "${setValueInfo.lowValue1},${setValueInfo.highValue1}",
//                 scaleId);
//             setScaleMode(mode, scaleNo);
//           } else if (mode == 2) {
//             PublicFunctions.setLowHighLimit(
//                 "${setValueInfo.lowValue2},${setValueInfo.highValue2}",
//                 scaleId);
//             setScaleMode(mode, scaleNo);
//           }
//           //执行设置上下限设置命令
//         },
//         icon: const Icon(Icons.download),
//         iconSize: iconSize,
//         color: color,
//       ),
//     );
//   }

//   void setScaleMode(int mode, int scaleNo) {
//     if (mode == 1) {
//       if (scaleNo == 0) {
//         setScale1Mode = 1;
//       } else if (scaleNo == 1) {
//         setScale2Mode = 1;
//       }
//       if (scaleNo == 2) {
//         setScale3Mode = 1;
//       }
//     } else if (mode == 2) {
//       if (scaleNo == 0) {
//         setScale1Mode = 2;
//       } else if (scaleNo == 1) {
//         setScale2Mode = 2;
//       }
//       if (scaleNo == 2) {
//         setScale3Mode = 2;
//       }
//     }
//   }

//   Widget buildTextWithWeight(double width, double height, String text,
//       double? fontSize, BoxConstraints constraints, Color? color) {
//     width = width * constraints.maxWidth / 400;
//     height = height * constraints.maxHeight / 80;
//     fontSize = fontSize! * constraints.maxHeight / 150;
//     fontSize = constraints.maxHeight / 2;
//     if (fontSize > constraints.maxWidth / 7) {
//       fontSize = constraints.maxWidth / 7;
//     }
//     return Container(
//       width: width,
//       height: height,
//       color: color,
//       child: Column(
//         // 将 Row 改为 Column
//         mainAxisAlignment: MainAxisAlignment.center, // 垂直方向居中对齐
//         crossAxisAlignment: CrossAxisAlignment.end, // 水平方向居右对齐
//         children: [
//           Text(
//             text,
//             textAlign: TextAlign.right,
//             style: TextStyle(
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 fontSize: fontSize),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildTextWithNOUnit(double width, double height, String text,
//       double? fontSize, BoxConstraints constraints, Color? color) {
//     width = width * constraints.maxWidth / 400;
//     height = height * constraints.maxHeight / 80;
//     return SizedBox(
//       width: width,
//       height: height,
//     );
//   }

//   Widget buildTextWithUnit(double width, double height, String text,
//       double? fontSize, BoxConstraints constraints, Color? color) {
//     width = width * constraints.maxWidth / 400;
//     height = height * constraints.maxHeight / 80;
//     fontSize = constraints.maxHeight / 2;
//     if (fontSize > constraints.maxWidth / 10) {
//       fontSize = constraints.maxWidth / 10;
//     }

//     return Container(
//       width: width,
//       height: height,
//       color: color,
//       child: Column(
//         // 将 Row 改为 Column
//         mainAxisAlignment: MainAxisAlignment.center, // 垂直方向居中对齐
//         crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居右对齐
//         children: [
//           Text(
//             text,
//             textAlign: TextAlign.right,
//             style: TextStyle(
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 fontSize: fontSize),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildTextAndImage(
//       double width, String text, String imageName, BoxConstraints constraints) {
//     var imageSize = constraints.maxHeight * 0.5;
//     width = width - imageSize - 15;
//     var fontSize = constraints.maxHeight * 0.4;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         SizedBox(
//           width: width,
//           child: Text(
//             text,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.right,
//             style: TextStyle(fontSize: fontSize),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Image.asset(
//           imageName,
//           width: imageSize,
//           height: imageSize,
//         ),
//         const SizedBox(width: 5),
//       ],
//     );
//   }

// //竖向排列
//   Widget buildImage(String imageName, BoxConstraints constraints) {
//     var imageSize = constraints.maxHeight;

//     return Image.asset(
//       imageName,
//       width: imageSize,
//       height: imageSize,
//     );
//   }

// //
//   void highLowSettingDialog(
//       BuildContext context, CheckWeightSet setValueInfo, int mode) {
//     double high = 0.0;
//     double low = 0.0;
//     var fn = CheckWeightFunc();

//     if (mode == 1) {
//       high = setValueInfo.highValue1;
//       low = setValueInfo.lowValue1;
//     } else {
//       high = setValueInfo.highValue2;
//       low = setValueInfo.lowValue2;
//     }
//     showDialog(
//       context: context,
//       barrierDismissible: false, // 允许点击空白处关闭对话框
//       builder: (context) => CheckValueSetDialog(
//         initialHigh: high,
//         initialLow: low,
//       ),
//     ).then((values) {
//       if (values != null) {
//         high = values[0];
//         low = values[1];
//         setState(() {
//           if (mode == 1) {
//             setValueInfo.highValue1 = high;
//             setValueInfo.lowValue1 = low;
//           } else {
//             setValueInfo.highValue2 = high;
//             setValueInfo.lowValue2 = low;
//           }
//         });

//         fn.updateHighLow(myCheckWeightSetList, setValueInfo);
//       }
//     });
//   }

//   //竖向排列
//   Widget buildTextCol(double width, String text, BoxConstraints constraints) {
//     width = width;
//     var fontSize = constraints.maxHeight * 0.4;

//     return SizedBox(
//       width: width,
//       child: Text(
//         text,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: TextStyle(fontSize: fontSize),
//       ),
//     );
//   }

//   //竖向排列
//   Widget buildTextCheck(double width, String text, BoxConstraints constraints) {
//     width = width;
//     var fontSize = constraints.maxHeight * 0.3;

//     return SizedBox(
//       width: width,
//       child: Text(
//         text,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: TextStyle(fontSize: fontSize),
//       ),
//     );
//   }

//   Widget buildButton(Color? color, String text, BoxConstraints constraints,
//       VoidCallback onPressed) {
//     var fontSize = 14 * constraints.maxHeight / 60;
//     var width = constraints.maxWidth / 10;

//     return SizedBox(
//         width: width,
//         child: MaterialButton(
//             color: color,
//             textColor: Theme.of(context).colorScheme.onPrimary,
//             elevation: 5.0,
//             child: Text(text,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                     fontSize: fontSize, fontWeight: FontWeight.normal)),
//             onPressed: onPressed));
//   }

//   Widget buildTextString(
//       String text, BoxConstraints constraints, BuildContext context) {
//     var fontSize = 14 * constraints.maxHeight / 60;
//     var width = constraints.maxWidth / 10;
//     return SizedBox(
//         width: width,
//         child: Text(text,
//             style:
//                 TextStyle(fontSize: fontSize, fontWeight: FontWeight.normal)));
//   }

//   Widget _buildFlexibleButtonAndTextT({
//     required int scaleId,
//     required BoxConstraints constraints,
//     required bool isTrue,
//     required IconData icon,
//   }) {
//     double buttonWidth = (constraints.maxWidth / 4); // 自适应按钮宽度
//     double fontSize = (constraints.maxHeight * 0.25); // 自适应字体大小

//     return ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Theme.of(context).colorScheme.primary, // 设置按钮的背景色
//           elevation: 5, // 设置按钮的阴影
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
//           ),
//         ),
//         onPressed: isTrue
//             ? () {
//                 performTare(scaleId);
//               }
//             : null,
//         child: SizedBox(
//             height: constraints.maxHeight * 0.5,
//             child: Center(
//               child: Icon(
//                 icon,
//                 size: fontSize,
//               ),
//             )));
//   }
// }
