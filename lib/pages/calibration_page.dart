import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/log_data.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import '../../functions/methods.dart';
import '../data/language.dart';
import '../functions/adaptive.dart';
import '../widget/page_head.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';

const int step1 = 1; //姝ラ1
const int step2 = 2; //姝ラ2
const int step3 = 3; //姝ラ2
const int step4 = 4; //姝ラ3
const int step5 = 5; //姝ラ4

const double thisScaleListWidth = 251;

class CalibrationPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const CalibrationPage(
      {super.key, required this.onNavigate, required this.lastRouteName});
  @override
  State<CalibrationPage> createState() => CalibrationPageState();
}

class CalibrationPageState extends State<CalibrationPage> {

  ReqWeightCountine tempWeight = ReqWeightCountine();
  TextEditingController scaleRangeCtl = TextEditingController(text: "");
  TextEditingController scaleUnitCtl = TextEditingController(text: "kg");
  TextEditingController scaleCap1Ctl = TextEditingController(text: "10");
  TextEditingController decimalCtl = TextEditingController(text: "0");
  TextEditingController gaduation1Ctl = TextEditingController(text: "1");
  TextEditingController initialZeroCtl = TextEditingController(text: "0");
  TextEditingController zeroTrackingCtl = TextEditingController(text: "0.5d");
  TextEditingController manualZeroCtl = TextEditingController(text: "0");
  TextEditingController unitCtl = TextEditingController(text: "kg");
  TextEditingController gravAccCtl = TextEditingController(text: "9.8"); //閲嶅姏鍔犻€熷害

  int selScaleId = -1; //閫夋嫨鐨勭ГID

  DateTime customDate = DateTime.now();
  DateTime customTime = DateTime.now();
  DateTime deviceTime = DateTime.now();

  bool isCalSuccess = false;

  ReceiveWgtInfo? weightInfo;

  int curStep = 1; //褰撳墠姝ラ
  bool isManaul = false;
  bool isFinish = false; //鏄惁瀹屾垚鏍″噯
  bool isCnting = false; //鏄惁姝ｅ湪璁℃暟
  bool isStart = false; //鏄惁寮€濮?
  bool isCalibration = false; //鏄惁鏍″噯

// 瀛樺偍鍒濆鍊?
  String initialMaxRange1 = '';
  String initialWgtUnit = '';
  String initialInitZero = '';
  String initialManualZero = '';
  String initialZeroTracking = '';
  String initialGravAcc = '';
  String initialDecimal = '';
  String initialGaduation1 = '';
  String currentWgtUnit = '';

  dynamic eventBus1; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus2; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus3; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus4; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus5; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus6; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus7; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus8; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus9; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus10; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus11; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus12; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus13; //鎺ユ敹绉ゆ暟鎹?
  dynamic eventBus14; //鎺ユ敹绉ゆ暟鎹?

  //瀹氭椂鍙戦€佺Г杩樻椿鐫€
  Timer? _cntAliveTimer;
  bool _isCntAliveTiming = false;
  bool get isCntAliveTiming => _isCntAliveTiming;
  Timer? startTimer;
  Timer? innerTimer;
  Timer? calHeartBeatTimer;

  double oldWeight = 0;
  double newWeight = 0;

  void startCntAliveTimer(int time) {
    if (_cntAliveTimer != null) {
      _cntAliveTimer!.cancel();
    }

    _isCntAliveTiming = true;
    _cntAliveTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.sendScaleAlive(selScaleId);
      if (!isStart) {
        PublicFunctions.getWeight(selScaleId);
      }
      startCntAliveTimer(10);
    });
  }

  void stopCntAliveTimer() {
    _cntAliveTimer?.cancel();
    _isCntAliveTiming = false;
  }

  void startCalHeartBeatTimer() {
    if (calHeartBeatTimer != null) {
      calHeartBeatTimer!.cancel();
    }

    calHeartBeatTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      PublicFunctions.sendCalHeartBeat(selScaleId);
    });
  }

  void onStartTimer() {
    startTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      isCnting = false; // 閲嶇疆璁℃椂鍣ㄧ姸鎬?
      innerTimer = Timer(Duration(milliseconds: 1000), () {
        if (!isCnting) {
          isStart = false;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    startCntAliveTimer(10);
    onStartTimer();

    startCalHeartBeatTimer();
    weightInfo = ReceiveWgtInfo(
      weightVal: '---------',
      weightUnit: '----',
      isStable: false,
      isZero: false,
      isNet: false,
    );
    eventBus1 = eventBus.on<EventReqWeightCountine>().listen((event) {
      tempWeight = event.obj;

      if (tempWeight.scaleId == selScaleId &&
          mounted &&
          tempWeight.msgBody != null) {
        setState(() {
          isCnting = true;
          isStart = true;
          weightInfo = ReceiveWgtInfo(
            weightVal: tempWeight.msgBody!.weightVal,
            weightUnit: tempWeight.msgBody!.weightUnit,
            isNet: tempWeight.msgBody!.isNet,
            isStable: tempWeight.msgBody!.isStable,
            isZero: tempWeight.msgBody!.isZero,
          );
        });
      }
      if (mounted) {
        for (var item in myAllScalesList) {
          if (item.scaleId == tempWeight.scaleId && !item.isOnline) {
            setState(() {
              item.isOnline = true;
              return;
            });
          }
        }
      }
    });

    eventBus2 = eventBus.on<EventRevCalValue>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (!tempRespData.msgBody.contains('ok') && curStep == step5) {
            setState(() {
              isFinish = true;
              isCalSuccess = false;
            });
          } else if (!tempRespData.msgBody.contains('ok')) {
            showTipInfo((localizedStrings?.gTipRedoLastStep ?? "gTipRedoLastStep"), context);
            setState(() {
              curStep = curStep - 1;
              if (curStep < 1) {
                curStep = 1;
              }
            });
          } else if (tempRespData.msgBody.contains('ok') && curStep == step5) {
            setState(() {
              isFinish = true;
              isCalSuccess = true;
            });
          }
        }
      }
    });

    eventBus3 = eventBus.on<EventRevCalWeight>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (!tempRespData.msgBody.contains('ok')) {
            showTipInfo((localizedStrings?.gTipRedoLastStep ?? "gTipRedoLastStep"), context);
            setState(() {
              curStep = curStep - 1;
              if (curStep < 1) {
                curStep = 1;
              }
            });
          } else {
            if (curStep == step5) {
              setState(() {
                // 鑾峰彇鏍″噯鍚庣殑閲嶉噺闂撮殧200ms
                Future.delayed(Duration(milliseconds: 200), () {
                  setState(() {
                    isFinish = true;
                    isCalSuccess = true;
                    newWeight = (double.tryParse((weightInfo?.weightVal?.toString() ?? "0")) ?? 0.0);
                    currentWgtUnit = (weightInfo?.weightUnit?.toString() ?? "kg");

                    CalLog calLog = CalLog(
                        scaleId: selScaleId,
                        type: "single",
                        mode: "1", //鏍囧畾鐐规暟閲?
                        unit: currentWgtUnit,
                        calValue: scaleRangeCtl.text,
                        before: oldWeight.toString(),
                        after: newWeight.toString(),
                        calError: (newWeight - oldWeight).toStringAsFixed(3),
                        calResult: 'ok');
                    String jsonStr = json.encode(calLog);

                    PublicFunctions.addCalLog(jsonStr);
                  });
                });
              });
            }
          }
        }
      }
    });

    eventBus4 = eventBus.on<EventRevSetDecimalValue>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (!tempRespData.msgBody.contains('ok')) {
            showTipInfo((localizedStrings?.gTipSetParameterFail ?? "gTipSetParameterFail"), context);
          } else {
            showTipInfo((localizedStrings?.fSuccessMsg ?? "fSuccessMsg"), context);
          }
        }
      }
    });

    eventBus5 = eventBus.on<EventRevSetGaduationValue>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (!tempRespData.msgBody.contains('ok')) {
          } else {}
        }
      }
    });

    eventBus6 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
        } else {
          for (var item in myAllScalesList) {
            if (item.scaleId == myRespDataFromScale.scaleId &&
                item.isOnline &&
                myRespDataFromScale.scaleId == selScaleId) {
              setState(() {
                item.isOnline = false;
              });
            }
          }
        }
      }
    });

    eventBus7 = eventBus.on<EventRevGetDecimalValue>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 1 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }

          initialDecimal = tempRespData.msgBody;

          setState(() {
            decimalCtl.text = initialDecimal;
          });
        }
      }
    });
    eventBus8 = eventBus.on<EventRevGetGaduation1Value>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 1 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          initialGaduation1 = tempRespData.msgBody;

          setState(() {
            gaduation1Ctl.text = initialGaduation1;
          });
        }
      }
    });

    eventBus9 = eventBus.on<EventRevGetGravAcc>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            showTipInfo((localizedStrings?.gTipGetParameterFail ?? "gTipGetParameterFail"), context);
            return;
          }
          initialGravAcc = (tempRespData.msgBody);

          setState(() {
            gravAccCtl.text = initialGravAcc;
          });
          showTipInfo((localizedStrings?.fSuccessMsg ?? "fSuccessMsg"), context);
        }
      }
    });

    eventBus10 = eventBus.on<EventRevGetInitialZero>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          initialInitZero = (tempRespData.msgBody);
          setState(() {
            initialZeroCtl.text = initialInitZero;
          });
        }
      }
    });

    eventBus11 = eventBus.on<EventRevGetZeroTracking>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          String revStr = tempRespData.msgBody;
          switch (revStr) {
            case '0':
              initialZeroTracking = 'off';
              break;
            case '1':
              initialZeroTracking = '0.5d';
              break;
            case '2':
              initialZeroTracking = '1d';
              break;
            case '3':
              initialZeroTracking = '2d';
              break;
            case '4':
              initialZeroTracking = '3d';
              break;
            case '5':
              initialZeroTracking = '4d';
              break;
            default:
              initialZeroTracking = '';
          }

          setState(() {
            zeroTrackingCtl.text = initialZeroTracking;
          });
        }
      }
    });

    eventBus12 = eventBus.on<EventRevGetManualZero>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          initialManualZero = (tempRespData.msgBody);

          setState(() {
            manualZeroCtl.text = initialManualZero;
          });
        }
      }
    });
    //鑾峰彇閲嶉噺鍗曚綅
    eventBus13 = eventBus.on<EventRevGetWeightUnit>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 1 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);

            return;
          }
          initialWgtUnit = tempRespData.msgBody;
          switch (initialWgtUnit) {
            case '0':
              initialWgtUnit = 'kg';
              break;
            case '1':
              initialWgtUnit = 'g';
              break;
            case '2':
              initialWgtUnit = 'lb';
              break;
            default:
              initialWgtUnit = '';
          }
          setState(() {
            unitCtl.text = initialWgtUnit;
          });
        }
      }
    });

    //鑾峰彇绉ょ殑鏈€澶ч噺绋?
    eventBus14 = eventBus.on<EventRevGetMaxRange1>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          initialMaxRange1 = tempRespData.msgBody;

          setState(() {
            scaleCap1Ctl.text = initialMaxRange1;
          });
        }
      }
    });

    // 鍦ㄩ〉闈㈡瀯寤哄畬鎴愬悗鏄剧ず鎻愮ず
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (myAllScalesList.isEmpty) {
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
    eventBus1.cancel();
    eventBus2.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    eventBus7.cancel();
    eventBus8.cancel();
    eventBus9.cancel();
    eventBus10.cancel();
    eventBus11.cancel();
    eventBus12.cancel();
    eventBus13.cancel();
    eventBus14.cancel();

    stopCntAliveTimer();
    startTimer?.cancel();
    calHeartBeatTimer?.cancel();
    if (innerTimer != null) {
      innerTimer!.cancel();
    }

    scaleRangeCtl.dispose();
    scaleUnitCtl.dispose();
    PublicFunctions.stopWeight(selScaleId);

    scaleCap1Ctl.dispose();
    decimalCtl.dispose();
    gaduation1Ctl.dispose();
    initialZeroCtl.dispose();
    zeroTrackingCtl.dispose();
    manualZeroCtl.dispose();
    unitCtl.dispose();
    gravAccCtl.dispose();
    _cntAliveTimer?.cancel();
    innerTimer?.cancel();
    super.dispose();
  }

  void performChangeScale(int scaleId) {
    PublicFunctions.stopWeight(selScaleId);
    setState(() {
      curStep = step1;
      isFinish = false;
      isCalSuccess = false;
      selScaleId = scaleId;
      isStart = false;
      weightInfo = ReceiveWgtInfo(
        weightVal: '---------',
        weightUnit: '----',
        isStable: false,
        isZero: false,
        isNet: false,
      );
      initialMaxRange1 = '';
      initialWgtUnit = '';
      initialInitZero = '';
      initialManualZero = '';
      initialZeroTracking = '';
      initialGravAcc = '';
      initialDecimal = '';
      initialGaduation1 = '';
    });
    getAllParameter();
  }

  void getAllParameter() {
    showTipInfo((localizedStrings?.gTipGettingParameter ?? "gTipGettingParameter"), context);
    PublicFunctions.getMaxRange1(selScaleId);
    PublicFunctions.getWeightUnit(selScaleId);
    PublicFunctions.getInitialZero(selScaleId);
    PublicFunctions.getManualZero(selScaleId);
    PublicFunctions.getZeroTracking(selScaleId);
    PublicFunctions.getGravityAcceleration(selScaleId);
    PublicFunctions.getDecimalValue(selScaleId);
    PublicFunctions.getGaduation1Value(selScaleId);
  }

  showCalibrationWarning() {
    showTipInfo((localizedStrings?.gTipCalibrating ?? "gTipCalibrating"), context);
  }

  void changeScale(int scaleId) {
    if (curStep != step1 && curStep != step5) {
      showDialog(
        context: context,
        barrierDismissible: false, // 鐐瑰嚮瀵硅瘽妗嗗閮ㄤ笉鍏抽棴瀵硅瘽妗?
        builder: (BuildContext ctx) {
          return ShowNormalTipDialog(
            title: (localizedStrings?.fTipTitle ?? "fTipTitle"),
            msg: (localizedStrings?.gTipCalibrationWarning ?? "gTipCalibrationWarning"),
          );
        },
      ).then((value) {
        if (value == null) {
          return;
        }
        if (value) {
          performChangeScale(scaleId);
        } else {
          return;
        }
      });
    } else {
      performChangeScale(scaleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = Adaptive.isMobile(context);

    return Scaffold(

      drawer: isMobile
          ? UnifiedDeviceDrawerContent(
              scaleList: myAllScalesList,
              isSelected: (scale) => selScaleId == scale.scaleId,
              onScaleTap: (scale) {
                bool isS15 = false;
                for (var item in myAllScalesList) {
                  if (item.scaleId == scale.scaleId) {
                    if (item.scaleModel != "S15") {
                      showTipInfo("Please select S15 scale", context);
                    } else {
                      isS15 = true;
                    }
                  }
                }
                if (isS15) {
                  Navigator.pop(context);
                  changeScale(scale.scaleId);
                }
              },
            )
          : null,
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            pageHeadInfo(context, width - headWidthPadding,
                (localizedStrings?.menuCalibration ?? "menuCalibration"), '', () {
              widget.onNavigate(widget.lastRouteName);
            },
                showBackBtn: false,
                leading: isMobile
                    ? Builder(
                        builder: (context) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black87),
                              onPressed: () => widget.onNavigate(widget.lastRouteName),
                            ),
                            MobileScaleHeaderIconButton(
                              onTap: () => Scaffold.of(context).openDrawer(),
                            ),
                          ],
                        ),
                      )
                    : null),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile)
                    Container(
                      width: thisScaleListWidth,
                      color: Theme.of(context).colorScheme.surfaceTint,
                      child: NewAllScaleListWidget(
                        listWidth: thisScaleListWidth,
                        selScaleId: selScaleId,
                        clickScale: (scale) {
                          setState(() {
                            bool isS15 = false;
                            for (var item in myAllScalesList) {
                              if (item.scaleId == scale.scaleId) {
                                if (item.scaleModel != "S15") {
                                  showTipInfo(
                                      "Please select S15 scale", context);
                                } else {
                                  isS15 = true;
                                }
                              }
                            }
                            if (isS15) {
                              changeScale(scale.scaleId);
                            }
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
                        myAllScalesList.isEmpty
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
                                            child: Column(
                                              children: [
                                                showSetParameterBtn(),
                                                const SizedBox(
                                                  height: largePadding,
                                                ),
                                                if (isCalibration &&
                                                    selScaleId != -1)
                                                  ...showCalibrationPart(),
                                                if (!isCalibration &&
                                                    selScaleId != -1)
                                                  ...showParameterSettingPart()
                                              ],
                                            ),
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


  Widget showTitle(String title) {
    return SizedBox(
      height: 42,
      width: 300,
      child: Row(children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> showParameterSettingPart() {
    return [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings?.gTipMaxRange ?? "gTipMaxRange"),
            showCapInputBox(scaleCap1Ctl),
          ]),
        ),
        SizedBox(
          width: largePadding * 2,
        ),
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings?.gTipGaduation ?? "gTipGaduation"),
            showDropDownButton(context, '', gaduation1Ctl, [
              '1',
              '2',
              '5',
              '10',
              '20',
              '50',
              '100',
            ], (onValue) {
              setState(() {
                gaduation1Ctl.text = onValue!;
              });
            }),
          ]),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings?.gTipWeightUnit ?? "gTipWeightUnit"),
            SizedBox(
                child: showDropDownButton(context, '', unitCtl, [
              'kg',
              'g',
              'lb',
            ], (onValue) {
              showDialog(
                context: context,
                barrierDismissible: false, // 鐐瑰嚮瀵硅瘽妗嗗閮ㄤ笉鍏抽棴瀵硅瘽妗?
                builder: (BuildContext ctx) {
                  return ShowNormalTipDialog(
                    title: (localizedStrings?.fTipTitle ?? "fTipTitle"),
                    msg: (localizedStrings?.gTipSwitchUnit ?? "gTipSwitchUnit"),
                  );
                },
              );
              setState(() {
                unitCtl.text = onValue!;
              });
            })),
          ]),
        ),
        SizedBox(
          width: largePadding * 2,
        ),
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings?.gTipDecimal ?? "gTipDecimal"),
            SizedBox(
                child: showDropDownButton(context, '', decimalCtl, [
              '0',
              '1',
              '2',
              '3',
            ], (onValue) {
              setState(() {
                decimalCtl.text = onValue!;
              });
            })),
          ]),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings?.gTipInitialZero ?? "gTipInitialZero"),
            SizedBox(
                child: showDropDownButton(context, '', initialZeroCtl,
                    ['0', '2', '3', '4', '10', '20', '50', '100'], (onValue) {
              setState(() {
                initialZeroCtl.text = onValue!;
              });
            })),
          ]),
        ),
        SizedBox(
          width: largePadding * 2,
        ),
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings?.gTipManualZero ?? "gTipManualZero"),
            SizedBox(
                child: showDropDownButton(context, '', manualZeroCtl,
                    ['0', '2', '3', '4', '10', '20', '50', '100'], (onValue) {
              setState(() {
                manualZeroCtl.text = onValue!;
              });
            })),
          ]),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings?.gTipZeroTracking ?? "gTipZeroTracking"),
            //   0:off 1:0.5 2:1 3:2 4:3 5:4
            SizedBox(
                child: showDropDownButton(context, '', zeroTrackingCtl,
                    ['off', '0.5d', '1d', '2d', '3d', '4d'], (onValue) {
              setState(() {
                zeroTrackingCtl.text = onValue!;
              });
            })),
          ]),
        ),
        SizedBox(
          width: largePadding * 2,
        ),
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings?.gTipGravityAcceleration ?? "gTipGravityAcceleration"),
            showGravAccInputBox(),
          ]),
        ),
      ]),
      SizedBox(
        height: largePadding,
      ),
      Container(
        height: 96,
        width: 400,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  fixedSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: scaleCap1Ctl.text.isEmpty
                    ? null
                    : () {
                        if (!chackGravAcc()) {
                          showTipInfo(
                              localizedStrings
                                  .gTipGravityAccelerationInputError,
                              context);
                          return;
                        }
                        performModifyParameter();
                      },
                child: Text(
                  (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  fixedSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  //鍙栨秷鐨勮瘽閲嶆柊鑾峰彇涓嬪弬鏁?

                  showTipInfo((localizedStrings?.gTipGettingParameter ?? "gTipGettingParameter"), context);

                  Future.delayed(const Duration(seconds: 2), () {
                    getAllParameter();
                  });
                },
                child: Text(
                  (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    ];
  }

  void performModifyParameter() {
    // 姣旇緝骞跺彂閫佷慨鏀瑰崗璁?
    if (scaleCap1Ctl.text != initialMaxRange1) {
      PublicFunctions.setMaxRange1(selScaleId, scaleCap1Ctl.text);
    }

    if (unitCtl.text != initialWgtUnit) {
      int unitIndex = 0;
      switch (unitCtl.text) {
        case 'kg':
          unitIndex = 0;
          break;
        case 'g':
          unitIndex = 1;
          break;
        case 'lb':
          unitIndex = 2;
          break;
      }

      PublicFunctions.setWeightUnit(selScaleId, unitIndex.toString());
    }

    if (initialZeroCtl.text != initialInitZero) {
      PublicFunctions.setInitialZero(
          selScaleId, initialZeroCtl.text); // 鍋囪瀛樺湪姝ゆ柟娉?
    }

    if (manualZeroCtl.text != initialManualZero) {
      PublicFunctions.setManualZero(selScaleId, manualZeroCtl.text); // 鍋囪瀛樺湪姝ゆ柟娉?
    }

    if (zeroTrackingCtl.text != initialZeroTracking) {
      // 0:off 1:0.5 2:1 3:2 4:3 5:4
      int zeroTrackingIndex = 0;
      switch (zeroTrackingCtl.text) {
        case 'off':
          zeroTrackingIndex = 0;
          break;
        case '0.5d':
          zeroTrackingIndex = 1;
          break;
        case '1d':
          zeroTrackingIndex = 2;
          break;
        case '2d':
          zeroTrackingIndex = 3;
          break;
        case '3d':
          zeroTrackingIndex = 4;
          break;
        case '4d':
          zeroTrackingIndex = 5;
          break;
      }
      PublicFunctions.setZeroTracking(selScaleId, zeroTrackingIndex.toString());
    }

    if (gravAccCtl.text != initialGravAcc) {
      String gravAccValue =
          (double.tryParse(gravAccCtl.text)! * 100000).toStringAsFixed(0);
      PublicFunctions.setGravityAcceleration(selScaleId, gravAccValue);
    }

    if (decimalCtl.text != initialDecimal) {
      PublicFunctions.setDecimalValue(selScaleId, decimalCtl.text);
    }

    if (gaduation1Ctl.text != initialGaduation1) {
      PublicFunctions.setGaduation1Value(selScaleId, gaduation1Ctl.text);
    }
    Future.delayed(const Duration(seconds: 2), () {
      getAllParameter();
    });
  }

  bool chackGravAcc() {
    if (gravAccCtl.text == "") {
      return false;
    }
    if ((double.tryParse(gravAccCtl.text) ?? 0.0) < 9.7 ||
        (double.tryParse(gravAccCtl.text) ?? 0.0) > 9.9) {
      return false;
    }
    return true;
  }

  Widget showCapInputBox(TextEditingController capCtl) {
    return SizedBox(
      height: inputHeight,
      child: TextField(
        enabled: true,
        controller: capCtl,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) return newValue; // 鍏佽娓呯┖杈撳叆
            if (newValue.text.startsWith('0') && newValue.text.length > 1) {
              return oldValue; // 涓嶅厑璁镐互 0 寮€澶翠笖闀垮害澶т簬 1 鐨勮緭鍏?
            }
            final intValue = int.tryParse(newValue.text);
            if (intValue != null && intValue > 0) {
              return newValue; // 鍙厑璁告鏁存暟
            }
            return oldValue;
          }),
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          hintText: '',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          counterText: '',
        ),
        maxLength: 9,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .apply(color: Theme.of(context).colorScheme.onSurface),
        onChanged: (onValue) {},
      ),
    );
  }

  Widget showGravAccInputBox() {
    return SizedBox(
      height: inputHeight,
      child: TextField(
        enabled: true,
        controller: gravAccCtl,
        // 鍏佽杈撳叆鏁板瓧鍜屽皬鏁扮偣
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          // 淇鍚庣殑姝ｅ垯琛ㄨ揪寮忥紝鍏佽9涔嬪悗鐩存帴杈撳叆灏忔暟鐐?
          FilteringTextInputFormatter.allow(
              RegExp(r'^9(\.?|(\.(7|8)\d{0,4})?)$')),
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          hintText: '',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .apply(color: Theme.of(context).colorScheme.onSurface),
        onChanged: (onValue) {},
      ),
    );
  }

  List<Widget> showCalibrationPart() {
    return [
      showStepPart(),
      showStepTip(),
      Expanded(
        child: curStep == step1
            ? showStep1()
            : curStep == step2
                ? showStep2()
                : curStep == step3
                    ? showStep3()
                    : curStep == step4
                        ? showStep4()
                        : showStep5(),
      ),
      showBtnRow()
    ];
  }

  Widget showStep2() {
    return Container(
      height: leftBarIconHeight,
      alignment: Alignment.center,
      child: Column(
        children: [
          Expanded(child: SizedBox()),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(flex: 2, child: SizedBox()),
                // 浣跨敤 Expanded 璁╄緭鍏ユ瀹藉害闅忛〉闈㈠彉鍖?
                Expanded(
                    flex: 5, // 鍒嗛厤姣斾緥
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(localizedStrings?.gTipCalibrationWeight ?? "gTipCalibrationWeight"),
                        ),
                        SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: scaleRangeCtl,
                            // 鍙厑璁歌緭鍏ユ暟瀛?
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // 鍙厑璁歌緭鍏ユ暟瀛?
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                if (newValue.text.isEmpty) return newValue;
                                final intValue = int.tryParse(newValue.text);
                                if (intValue != null &&
                                    intValue >= 1 &&
                                    intValue <= 999999) {
                                  return newValue;
                                }
                                return oldValue;
                              }),
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0.0))),
                              hintText: (localizedStrings?.gTipCalibrationWeight ?? "gTipCalibrationWeight"),
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface, // 璁剧疆鎻愮ず鏂囨湰棰滆壊
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface, // 璁剧疆杈撳叆鏂囨湰棰滆壊
                                ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  width: largePadding,
                ),
                // 浣跨敤 Expanded 璁╀笅鎷夋寜閽搴﹂殢椤甸潰鍙樺寲
                Expanded(
                    flex: 2, // 鍒嗛厤姣斾緥
                    child: Column(
                      children: [
                        SizedBox(
                          height: 23,
                        ),
                        showDropDownButton(context, '', scaleUnitCtl, ['kg'],
                            (value) {
                          setState(() {});
                        }),
                      ],
                    )),
                Expanded(flex: 2, child: SizedBox()),
              ],
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget showStep3() {
    return Container(
      height: leftBarIconHeight,
      alignment: Alignment.center,
      child: Column(
        children: [
          Expanded(child: SizedBox()),
          Container(
            padding: EdgeInsets.all(largePadding),
            child: getSvgIcon(
                stableLightSvgIcon(),
                60,
                60,
                (weightInfo?.isStable ?? false)
                    ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                    : Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                    flex: 5, // 鍒嗛厤姣斾緥
                    child: Column(
                      children: [
                        SizedBox(
                          width: 230,
                          child: Text(
                            (localizedStrings?.gTipBeforeCalibration ?? "gTipBeforeCalibration") + ":  ",
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          height: regularPadding,
                        ),
                        Container(
                            width: 230,
                            height: 40,
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 180,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest,
                                    alignment: Alignment.center,
                                    child: Text(
                                      (weightInfo?.weightVal?.toString() ?? "0"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 40,
                                    alignment: Alignment.center,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest,
                                    child: Text(
                                      (weightInfo?.weightUnit?.toString() ?? "kg"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ])),
                      ],
                    )),
              ],
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget showStep4() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Container(
        padding: EdgeInsets.all(largePadding),
        child: getSvgIcon(
            stableLightSvgIcon(),
            60,
            60,
            (weightInfo?.isStable ?? false)
                ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                : Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      Column(children: [
        Container(
          height: 48,
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: (localizedStrings?.gTipPleaseLoadWeight ?? "gTipPleaseLoadWeight"),
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                TextSpan(
                  text: '  ${scaleRangeCtl.text} ${scaleUnitCtl.text}',
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiaryFixedVariant,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
              ],
            ),
          ),
        ),
        Image.asset(
          'assets/images/calibration2.png',
          width: 600,
          height: 70,
          fit: BoxFit.scaleDown,
        ),
      ])
    ]);
  }

  Widget showStep5() {
    return !isFinish
        ? SizedBox()
        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: EdgeInsets.all(largePadding),
              child: getSvgIcon(
                  isCalSuccess ? calSuccessSvgIcon() : calFailSvgIcon(),
                  48,
                  50,
                  isCalSuccess
                      ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                      : Theme.of(context).colorScheme.error),
            ),
            Column(children: [
              Container(
                height: 48,
                alignment: Alignment.center,
                child: Text(
                  isCalSuccess
                      ? (localizedStrings?.gTipCalibrationSuccess ?? "gTipCalibrationSuccess")
                      : (localizedStrings?.gTipCalibrationFailed ?? "gTipCalibrationFailed"),
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: isCalSuccess
                            ? Theme.of(context)
                                .colorScheme
                                .onTertiaryFixedVariant
                            : Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
              if (isCalSuccess)
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (localizedStrings?.gTipBeforeCalibration ?? "gTipBeforeCalibration") +
                            ":  ${oldWeight.toString()} $currentWgtUnit",
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        (localizedStrings?.gTipAfterCalibration ?? "gTipAfterCalibration") +
                            ":  ${newWeight.toString()} $currentWgtUnit",
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        (localizedStrings?.gTipErrorValue ?? "gTipErrorValue") +
                            ":  ${(newWeight - oldWeight).toStringAsFixed(3)} $currentWgtUnit",
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
            ])
          ]);
  }

  Widget showStep1() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Container(
        padding: EdgeInsets.all(largePadding),
        child: getSvgIcon(
            stableLightSvgIcon(),
            60,
            60,
            (weightInfo?.isStable ?? false)
                ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                : Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      Column(children: [
        // Container(
        //   height: 48,
        //   alignment: Alignment.center,
        //   child: Text(
        //     (localizedStrings?.gTipPleaseEmptyScalePan ?? "gTipPleaseEmptyScalePan"),
        //     style: Theme.of(context).textTheme.bodySmall!.apply(
        //           color: Theme.of(context).colorScheme.onSurface,
        //         ),
        //   ),
        // ),
        Image.asset(
          'assets/images/calibration1.png',
          width: 600,
          height: 70,
          fit: BoxFit.scaleDown,
        ),
      ])
    ]);
  }

  Widget showBtnRow() {
    return SizedBox(
        height: 100,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          curStep == step5 || curStep == step1
              ? SizedBox()
              : showTextButton(
                  context, btnHeight, (localizedStrings?.gBtnPrevious ?? "gBtnPrevious"), () {
                  setState(() {
                    curStep = curStep - 1;
                  });
                },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  Theme.of(context).colorScheme.onSurfaceVariant),
          curStep == step5
              ? SizedBox()
              : SizedBox(
                  width: largePadding,
                ),
          showTextButton(
              context,
              btnHeight,
              curStep == step5 && !isCalSuccess
                  ? (localizedStrings?.gTipCalibrationAgain ?? "gTipCalibrationAgain")
                  : curStep == step5 && isCalSuccess
                      ? (localizedStrings?.finishBtn ?? "finishBtn")
                      : (localizedStrings?.fNextStepBtn ?? "fNextStepBtn"),
              curStep == step4 && scaleRangeCtl.text == ''
                  ? null
                  : isStart && (weightInfo?.isStable ?? false)
                      ? () {
                          setState(() {
                            if (curStep == step1) {
                              curStep = step2;
                              PublicFunctions.calibrationWeight(
                                  selScaleId, '0');
                            } else if (curStep == step2) {
                              curStep = step3;
                            } else if (curStep == step3) {
                              oldWeight = (double.tryParse((weightInfo?.weightVal?.toString() ?? "0")) ?? 0.0);
                              oldWeight <= 0 ? oldWeight = 0 : oldWeight;
                              curStep = step4;
                            } else if (curStep == step4) {
                              curStep = step5;
                              PublicFunctions.calibrationWeight(
                                  selScaleId, scaleRangeCtl.text);
                            } else if (curStep == step5) {
                              curStep = step1;
                              // isFinish = true?
                            }
                          });
                        }
                      : null,
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.onPrimary)
        ]));
  }

  Widget showStepTip() {
    String stepTip = getStepTip(curStep);
    return SizedBox(
      height: leftBarIconHeight,
      child: Row(children: [
        Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        Expanded(
          flex: 7,
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              '$curStep. $stepTip ',
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        )
      ]),
    );
  }

  String getStepTip(int stepIndex) {
    switch (stepIndex) {
      case step1:
        return (localizedStrings?.gTipEmptyScalePanThenNext ?? "gTipEmptyScalePanThenNext");
      case step3:
        return (localizedStrings?.gTipPlaceCalibrationWeight ?? "gTipPlaceCalibrationWeight") +
            " ${scaleRangeCtl.text} kg";
      case step2:
        return (localizedStrings?.gTipSetCalibrationWeightThenNext ?? "gTipSetCalibrationWeightThenNext");
      case step4:
        return (localizedStrings?.gTipLoadWeightThenNext ?? "gTipLoadWeightThenNext");
      case step5:
        return (localizedStrings?.gTipCalResult ?? "gTipCalResult");
      default:
        return "";
    }
  }

  String getStepTitle(int stepIndex) {
    switch (stepIndex) {
      case step1:
        return (localizedStrings?.gTipEmptyScalePan ?? "gTipEmptyScalePan");
      case step3:
        return (localizedStrings?.gTipPlaceCalibrationWeight ?? "gTipPlaceCalibrationWeight");
      case step2:
        return (localizedStrings?.gTipSetCalibrationWeight ?? "gTipSetCalibrationWeight");
      case step4:
        return (localizedStrings?.gTipPlaceWeight ?? "gTipPlaceWeight");
      case step5:
        return (localizedStrings?.gTipCalibrationResult ?? "gTipCalibrationResult");
      default:
        return "";
    }
  }

  Widget buildStepInfo(
    int stepIndex,
  ) {
    Color initColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    Color fillingColor = Theme.of(context).colorScheme.onPrimary;

    Color textColor = initColor;
    Color leftLineColor = initColor;
    Color rightLineColor = initColor;
    Color circleColor = initColor;
    Color circleTextColor = initColor;

    if (curStep == stepIndex) {
      fillingColor = Theme.of(context).colorScheme.primary; // 宸插畬鎴愮殑姝ラ棰滆壊
      textColor = Theme.of(context).colorScheme.primary; // 宸插畬鎴愮殑姝ラ棰滆壊
      circleColor = Theme.of(context).colorScheme.primary; // 宸插畬鎴愮殑姝ラ棰滆壊
      circleTextColor = Theme.of(context).colorScheme.onPrimary; // 宸插畬鎴愮殑姝ラ鏂囧瓧棰滆壊
      leftLineColor = Theme.of(context).colorScheme.primary; // 宸插畬鎴愮殑姝ラ宸︾嚎棰滆壊
    } else if (curStep > stepIndex) {
      fillingColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 宸插畬鎴愮殑姝ラ棰滆壊
      textColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 宸插畬鎴愮殑姝ラ鏂囧瓧棰滆壊
      circleColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 宸插畬鎴愮殑姝ラ棰滆壊
      circleTextColor = Theme.of(context).colorScheme.onPrimary; // 宸插畬鎴愮殑姝ラ鏂囧瓧棰滆壊
      leftLineColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 宸插畬鎴愮殑姝ラ宸︾嚎棰滆壊

      rightLineColor = curStep - stepIndex > 1
          ? Theme.of(context).colorScheme.onTertiaryFixedVariant
          : Theme.of(context).colorScheme.primary; // 宸插畬鎴愮殑姝ラ宸︾嚎棰滆壊
    }

    if (isFinish && curStep == step5) {
      fillingColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 宸插畬鎴愮殑姝ラ棰滆壊
      textColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 宸插畬鎴愮殑姝ラ鏂囧瓧棰滆壊
      circleColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 宸插畬鎴愮殑姝ラ棰滆壊
      circleTextColor = Theme.of(context).colorScheme.onPrimary; // 宸插畬鎴愮殑姝ラ鏂囧瓧棰滆壊
      leftLineColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 宸插畬鎴愮殑姝ラ宸︾嚎棰滆壊
      rightLineColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 宸插畬鎴愮殑姝ラ宸︾嚎棰滆壊
    }

    if (stepIndex == step1) {
      leftLineColor = Colors.transparent;
    }
    if (stepIndex == step5) {
      rightLineColor = Colors.transparent;
    }

    return Expanded(
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: leftLineColor,

                    // 鍙牴鎹渶姹備慨鏀规í绾块鑹?
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fillingColor, // 鍐呴儴濉厖鐧借壊
                    border: Border.all(
                      color: circleColor,
                      width: 2, // 杈规瀹藉害涓?2
                    ),
                  ),
                  child: Center(
                    child: Text(
                      stepIndex.toString(), // 鍙牴鎹渶姹備慨鏀规暟缁勶紝杩欓噷浠ユ暟瀛?1 涓轰緥
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                            color: circleTextColor, // 鏂囧瓧涓虹伆鑹?
                          ), // 鏂囧瓧涓虹伆鑹?
                    ),
                  ),
                ),
                Expanded(
                  child: Container(height: 1, color: rightLineColor // 鏈畬鎴愮殑姝ラ棰滆壊
                      ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
                alignment: Alignment.topCenter,
                height: 40,
                child: Text(
                  getStepTitle(stepIndex),
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: textColor, // 鏂囧瓧棰滆壊
                      ),
                  // overflow: TextOverflow.ellipsis, // 瓒呭嚭閮ㄥ垎鐪佺暐鍙峰鐞?
                ))
          ],
        ),
      ),
    );
  }

  Widget showSetParameterBtn() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: showTextButton(
                context,
                48,
                (localizedStrings?.menuParameterSetting ?? "menuParameterSetting"),
                selScaleId == -1
                    ? null
                    : () {
                        if (curStep != step1 && curStep != step5) {
                          showCalibrationWarning();
                          return;
                        }
                        setState(() {
                          isCalibration = false;
                        });
                      },
                !isCalibration
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                !isCalibration
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceDim,
                Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          SizedBox(
            width: 200,
            child: showTextButton(
                context,
                48,
                (localizedStrings?.menuCalibration ?? "menuCalibration"),
                selScaleId == -1
                    ? null
                    : () {
                        setState(() {
                          isCalibration = true;
                        });
                      },
                isCalibration
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                isCalibration
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceDim,
                Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget showStepPart() {
    return Container(
        padding: const EdgeInsets.only(
          top: largePadding,
        ),
        height: 100, //leftBarIconHeight,
        child: Row(
          children: [
            buildStepInfo(step1),
            buildStepInfo(step2),
            buildStepInfo(step3),
            buildStepInfo(step4),
            buildStepInfo(step5),
          ],
        ));
  }
}
