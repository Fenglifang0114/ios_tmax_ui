import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import '../../functions/methods.dart';
import '../data/language.dart';

const int step1 = 1; //步骤1
const int step2 = 2; //步骤2
const int step3 = 3; //步骤3
const int step4 = 4; //步骤4

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});
  @override
  State<CalibrationPage> createState() => CalibrationPageState();
}

class CalibrationPageState extends State<CalibrationPage> {
  ReqWeightCountine tempWeight = ReqWeightCountine();
  TextEditingController scaleRangeCtl = TextEditingController(text: "");
  TextEditingController scaleUnitCtl = TextEditingController(text: "kg");

  int selScaleId = -1; //选择的秤ID

  DateTime customDate = DateTime.now();
  DateTime customTime = DateTime.now();
  DateTime deviceTime = DateTime.now();

  bool isCalSuccess = false;

  ReceiveWgtInfo? weightInfo;

  int curStep = 1; //当前步骤
  bool isManaul = false;
  bool isFinish = false; //是否完成校准
  bool isCnting = false; //是否正在计数
  bool isStart = false; //是否开始

  dynamic eventBus1; //接收秤数据
  dynamic eventBus2; //接收秤数据
  dynamic eventBus3; //接收秤数据
  dynamic eventBus4; //接收秤数据
  dynamic eventBus5; //接收秤数据
  dynamic eventBus6; //接收秤数据

  //定时发送秤还活着
  Timer? _cntAliveTimer;
  bool _isCntAliveTiming = false;
  bool get isCntAliveTiming => _isCntAliveTiming;
  Timer? startTimer;
  Timer? innerTimer;
  Timer? calHeartBeatTimer;

  void startCntAliveTimer(int time) {
    if (_cntAliveTimer != null) {
      _cntAliveTimer!.cancel();
    }

    _isCntAliveTiming = true;
    _cntAliveTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.sendScaleAlive(selScaleId); //只管串口
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
      isCnting = false; // 重置计时器状态
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
          if (!tempRespData.msgBody.contains('ok') && curStep == step4) {
            setState(() {
              isFinish = true;
              isCalSuccess = false;
            });
          } else if (!tempRespData.msgBody.contains('ok')) {
            showTipInfo(localizedStrings.gTipRedoLastStep, context);
            setState(() {
              curStep = curStep - 1;
              if (curStep < 1) {
                curStep = 1;
              }
            });
          } else if (tempRespData.msgBody.contains('ok') && curStep == step4) {
            setState(() {
              isFinish = true;
              isCalSuccess = true;
            });
          }
        }
      }
    });

    eventBus3 = eventBus.on<EventRevSetMaxRange>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (!tempRespData.msgBody.contains('ok')) {
            showTipInfo(localizedStrings.gTipResetMaxRange, context);
            setState(() {
              curStep = step2;
            });
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
            showTipInfo('fail,set decimal fail!', context);
          } else {
            showTipInfo(localizedStrings.fSuccessMsg, context);
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
            showTipInfo('fail,set gaduation fail!', context);
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
    // 在页面构建完成后显示提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (myAllScalesList.isEmpty) {
        showTipInfo(localizedStrings.gTipNoDeviceAddFirst, context);
      } else {
        if (selScaleId == -1) {
          showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
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
    stopCntAliveTimer();
    startTimer?.cancel();
    calHeartBeatTimer?.cancel();
    if (innerTimer != null) {
      innerTimer!.cancel();
    }

    scaleRangeCtl.dispose();
    scaleUnitCtl.dispose();
    PublicFunctions.stopWeight(selScaleId);

    super.dispose();
  }

  void showParameterSettingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ParameterSettingDialog(
          selScaleId: selScaleId,
        );
      },
    );
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
    });
    PublicFunctions.getWeight(selScaleId);
  }

  void changeScale(int scaleId) {
    if (curStep != step1) {
      showDialog(
        context: context,
        barrierDismissible: false, // 点击对话框外部不关闭对话框
        builder: (BuildContext ctx) {
          return ShowNormalTipDialog(
            title: localizedStrings.fTipTitle,
            msg: localizedStrings.gTipCalibrationWarning,
          );
        },
      ).then((value) {
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
    return Scaffold(body: firstLayout(context, width));
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
            //     localizedStrings.menuCalibration, ''),
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
                            child: NewAllScaleListWidget(
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
                        myAllScalesList.isEmpty
                            ? SizedBox()
                            : Expanded(
                                child: Container(
                                    padding:
                                        const EdgeInsets.all(regularPadding),
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: Column(
                                      children: [
                                        showSetParameterBtn(),
                                        showStepPart(),
                                        showStepTip(),
                                        Expanded(
                                          child: curStep == step1
                                              ? showStep1()
                                              : curStep == step2
                                                  ? showStep2()
                                                  : curStep == step3
                                                      ? showStep3()
                                                      : showStep4(),
                                        ),
                                        showBtnRow()
                                      ],
                                    )))
                      ],
                    ),
                  ),
                ])),
          ],
        ));
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
                // 使用 Expanded 让输入框宽度随页面变化
                Expanded(
                    flex: 5, // 分配比例
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(localizedStrings.gTipInputRange),
                        ),
                        SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: scaleRangeCtl,
                            // 只允许输入数字
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // 只允许输入数字
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
                              hintText: localizedStrings.gTipInputRange,
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface, // 设置提示文本颜色
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface, // 设置输入文本颜色
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
                // 使用 Expanded 让下拉按钮宽度随页面变化
                Expanded(
                    flex: 2, // 分配比例
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
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Container(
        padding: EdgeInsets.all(largePadding),
        child: getSvgIcon(
            stableLightSvgIcon(),
            60,
            60,
            weightInfo!.isStable!
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
                  text: localizedStrings.gTipPleaseLoadWeight,
                  style: Theme.of(context).textTheme.bodyLarge!.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                TextSpan(
                  text: '  ${scaleRangeCtl.text} ${scaleUnitCtl.text}',
                  style: Theme.of(context).textTheme.bodyLarge!.apply(
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

  Widget showStep4() {
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
                      ? localizedStrings.gTipCalibrationSuccess
                      : localizedStrings.gTipCalibrationFailed,
                  style: Theme.of(context).textTheme.bodyLarge!.apply(
                        color: isCalSuccess
                            ? Theme.of(context)
                                .colorScheme
                                .onTertiaryFixedVariant
                            : Theme.of(context).colorScheme.error,
                      ),
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
            weightInfo!.isStable!
                ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                : Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      Column(children: [
        Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            localizedStrings.gTipPleaseEmptyScalePan,
            style: Theme.of(context).textTheme.bodyLarge!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
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
          curStep == step4 || curStep == step1
              ? SizedBox()
              : showTextButton(
                  context, btnHeight, localizedStrings.gBtnPrevious, () {
                  setState(() {
                    curStep = curStep - 1;
                  });
                },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  Theme.of(context).colorScheme.onSurfaceVariant),
          curStep == step4
              ? SizedBox()
              : SizedBox(
                  width: largePadding,
                ),
          showTextButton(
              context,
              btnHeight,
              curStep == step4
                  ? localizedStrings.gTipCalibrationAgain
                  : localizedStrings.fNextStepBtn,
              curStep == step3 && scaleRangeCtl.text == ''
                  ? null
                  : isStart && weightInfo!.isStable!
                      ? () {
                          setState(() {
                            if (curStep == step1) {
                              curStep = step2;
                              PublicFunctions.calibrationZero(selScaleId);
                            } else if (curStep == step2) {
                              curStep = step3;
                              int range = int.tryParse(scaleRangeCtl.text)!;
                              PublicFunctions.setMaxRange(selScaleId, range);
                            } else if (curStep == step3) {
                              curStep = step4;
                              PublicFunctions.calibrationMaxRange(selScaleId);
                            } else if (curStep == step4) {
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
              style: Theme.of(context).textTheme.bodyLarge!.apply(
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
        return localizedStrings.gTipEmptyScalePanThenNext;
      case step2:
        return localizedStrings.gTipSetFullScaleThenNext;
      case step3:
        return localizedStrings.gTipLoadWeightThenNext;
      case step4:
        return localizedStrings.gTipCalResult;
      default:
        return "";
    }
  }

  String getStepTitle(int stepIndex) {
    switch (stepIndex) {
      case step1:
        return localizedStrings.gTipEmptyScalePan;
      case step2:
        return localizedStrings.gTipSetFullScale;
      case step3:
        return localizedStrings.gTipPlaceWeight;
      case step4:
        return localizedStrings.gTipCalibrationResult;
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
      fillingColor = Theme.of(context).colorScheme.primary; // 已完成的步骤颜色
      textColor = Theme.of(context).colorScheme.primary; // 已完成的步骤颜色
      circleColor = Theme.of(context).colorScheme.primary; // 已完成的步骤颜色
      circleTextColor = Theme.of(context).colorScheme.onPrimary; // 已完成的步骤文字颜色
      leftLineColor = Theme.of(context).colorScheme.primary; // 已完成的步骤左线颜色
    } else if (curStep > stepIndex) {
      fillingColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤颜色
      textColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤文字颜色
      circleColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤颜色
      circleTextColor = Theme.of(context).colorScheme.onPrimary; // 已完成的步骤文字颜色
      leftLineColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤左线颜色

      rightLineColor = curStep - stepIndex > 1
          ? Theme.of(context).colorScheme.onTertiaryFixedVariant
          : Theme.of(context).colorScheme.primary; // 已完成的步骤左线颜色
    }

    if (isFinish && curStep == step4) {
      fillingColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤颜色
      textColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤文字颜色
      circleColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤颜色
      circleTextColor = Theme.of(context).colorScheme.onPrimary; // 已完成的步骤文字颜色
      leftLineColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤左线颜色
      rightLineColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤左线颜色
    }

    if (stepIndex == step1) {
      leftLineColor = Theme.of(context).colorScheme.surface;
    }
    if (stepIndex == step4) {
      rightLineColor = Theme.of(context).colorScheme.surface;
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

                    // 可根据需求修改横线颜色
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fillingColor, // 内部填充白色
                    border: Border.all(
                      color: circleColor,
                      width: 2, // 边框宽度为 2
                    ),
                  ),
                  child: Center(
                    child: Text(
                      stepIndex.toString(), // 可根据需求修改数组，这里以数字 1 为例
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                            color: circleTextColor, // 文字为灰色,
                          ), // 文字为灰色,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(height: 1, color: rightLineColor // 未完成的步骤颜色
                      ),
                ),
              ],
            ),
            Container(
                alignment: Alignment.center,
                child: Text(
                  getStepTitle(stepIndex),
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: textColor, // 文字颜色
                      ),
                  overflow: TextOverflow.ellipsis, // 超出部分省略号处理
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          showTextButton(
              context,
              48,
              localizedStrings.menuParameterSetting,
              selScaleId == -1
                  ? null
                  : () {
                      showParameterSettingDialog();
                    },
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.onSurfaceVariant)
        ],
      ),
    );
  }

  Widget showStepPart() {
    return Container(
        padding: const EdgeInsets.only(
          top: largePadding,
        ),
        height: leftBarIconHeight,
        child: Row(
          children: [
            buildStepInfo(step1),
            buildStepInfo(step2),
            buildStepInfo(step3),
            buildStepInfo(step4),
          ],
        ));
  }
}

// 定义新增配方类型弹框组件
class ParameterSettingDialog extends StatefulWidget {
  final int selScaleId;
  const ParameterSettingDialog({super.key, required this.selScaleId});
  @override
  ParameterSettingDialogState createState() => ParameterSettingDialogState();
}

class ParameterSettingDialogState extends State<ParameterSettingDialog> {
  TextEditingController decimalCtl = TextEditingController(text: '3');
  TextEditingController gaduationCtl = TextEditingController(text: '5');

  @override
  Widget build(BuildContext ctx) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 376,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            Container(
                height: 54,
                padding: const EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizedStrings.menuParameterSetting,
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                      })
                ])),
            // 分割线
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            // 中部
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(26),
                  height: 150,
                  width: 600,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 265,
                          child: Column(children: [
                            SizedBox(
                              height: 42,
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Decimal',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: showDropDownButton(
                                          context, '', decimalCtl, [
                                        '0',
                                        '1',
                                        '2',
                                        '3',
                                      ], (onValue) {
                                        setState(() {
                                          decimalCtl.text = onValue!;
                                        });
                                      })),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                        SizedBox(
                          width: 265,
                          child: Column(children: [
                            SizedBox(
                              height: 42,
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Gaduation',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: showDropDownButton(
                                          context, '', gaduationCtl, [
                                        '1',
                                        '2',
                                        '5',
                                        '10',
                                        '20',
                                        '50',
                                        '100',
                                      ], (onValue) {
                                        setState(() {
                                          gaduationCtl.text = onValue!;
                                        });
                                      })),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                      ])),
            ),

            // 底部
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
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed:
                          decimalCtl.text.isEmpty && gaduationCtl.text.isEmpty
                              ? null
                              : () {
                                  PublicFunctions.setDecimalValue(
                                      widget.selScaleId, decimalCtl.text);
                                  PublicFunctions.setGaduationValue(
                                      widget.selScaleId, gaduationCtl.text);
                                  Navigator.pop(ctx);
                                },
                      child: Text(
                        localizedStrings.gBtnConfirm,
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
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        localizedStrings.gBtnCancel,
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
          ],
        ),
      ),
    );
  }
}
