//保密配方
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/formula_wgt_process_data.dart';
import 'package:t_max/data/get_auto_next_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/req_add_fma_rec_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/timer_manager.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/widget/fma_process_bar.dart';
import 'package:t_max/widget/sticky_table.dart';
import '../data/language.dart';

class FormulaSecretWeighingPage extends StatefulWidget {
  const FormulaSecretWeighingPage(
      {super.key,
      required this.selectFormula,
      required this.selScaleId,
      required this.totalFmaWgt,
      required this.fmaUnit});
  final FormulaInfoDb selectFormula;
  final int selScaleId;
  final double totalFmaWgt;
  final String fmaUnit;
  @override
  State<FormulaSecretWeighingPage> createState() =>
      FormulaSecretWeighingPageState();
}

class FormulaSecretWeighingPageState extends State<FormulaSecretWeighingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool sort = false;
  final ScrollController _scrollController =
      ScrollController(); // 添加 ScrollController

  bool selectAll = false; // 添加全选状态
  int clickedRow = 0; // 添加点击行状态
  final TextEditingController encryptedCtl = TextEditingController();
  final TextEditingController formulaTypeCtl = TextEditingController();
  final TextEditingController rawTypeCtl = TextEditingController();
  List<FormulaWgtProcessData> processWgtList = []; //配方中的原料重量集合
  FormulaWgtProcessData selectedProcessWgt = FormulaWgtProcessData(); //选中的原料重量

  double initTotalWeight = 1000.0; //总重量百分比模式传入的总重量
  String totalUnit = 'g'; //总重量百分比模式传入的总重量单位
  bool isWgtStart = false; //是否开始重量
  bool isShowTipDialog = false; //是否显示提示对话框
  bool enableSelRaw = false; //是否启用选择原料  按顺序制作，需要添加补充的时候再去做选择物料
  bool startFormula = false; //是否开始配方  配方开始后，归零和扣重不能使用
  String recRecNumber = ''; //配方订单编号
  double currentRawWgt = 0.000; //当前的原料重量 默认为0
  String fmaUnit = 'g'; //配方重量单位

  bool isEnableNext = true; //是否禁用下一个
  bool isFinish = false; //是否完成
  double needTotalWgt = 0.000; //需要的总重量 默认为0  这个主要是修正后的重量

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;

  Timer? setWgtStartFalseTimer; // 用于每3秒将isWgtStart设置为false的定时器
  Timer? checkWgtStartTimer; // 用于每5秒检查isWgtStart的定时器

  late Scale myScale;

  bool autoNextStep = false;
  final TextEditingController stableTimeCtl = TextEditingController();
  Timer? autoNextStepTimer;
  int stableDurationCounter = 0; // 稳定时长计数器
  final ValueNotifier<bool> autoNextStepNotifier = ValueNotifier(false);
  int stableTime = 0;

  // 每3秒钟将isWgtStart设置为false
  void startSetWgtStartFalseTimer() {
    setWgtStartFalseTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          isWgtStart = false;
        });
      }
    });
  }

  // 每5秒判断一下isWgtStart是不是false，是false的话，就重新发送请求开启连续发送
  void startCheckWgtStartTimer() {
    checkWgtStartTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isWgtStart == false) {
        // 重新发送请求开启连续发送
        PublicFunctions.getWeight(widget.selScaleId);
      }
    });
  }

  // 启动自动下一步定时器
  void startAutoNextStepTimer() {
    autoNextStepTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!myReqWeightCountine.msgBody!.isStable) {
        stableDurationCounter = 0;
      } else if (myReqWeightCountine.msgBody != null &&
          myReqWeightCountine.msgBody!.isStable &&
          isEnableNext &&
          isWgtStart &&
          checkValueIsOk() == 'ok') {
        stableDurationCounter++;
        if (stableDurationCounter >= stableTime * 20) {
          final isOk = checkValueIsOk();
          if (isOk == "ok") {
            nextStep(isOk); // 执行下一步操作
            stableDurationCounter = 0; // 重置计数器
          }
        }
      }
    });
  }

  // 停止自动下一步定时器
  void stopAutoNextStepTimer() {
    autoNextStepTimer?.cancel();
    autoNextStepTimer = null;
    stableDurationCounter = 0;
  }

  // nextStep 方法
  void nextStep(String isWgtOk) {
    double currentTempWgtValue = currentRawWgt;
    handleOkStatus(isWgtOk, currentTempWgtValue);
  }

//百分比模式下初始化重量和单位
  void initTotalWgtUnit() {
    if (widget.selectFormula.header!.formulaHeader!.formulaMode == 'pct') {
      initTotalWeight = widget.totalFmaWgt;
      initTotalWeight = double.parse(initTotalWeight.toStringAsFixed(3));
      widget.selectFormula.header!.formulaHeader!.formulaUnit = widget.fmaUnit;
      widget.selectFormula.header!.formulaHeader!.totalWeight = initTotalWeight;
      needTotalWgt = initTotalWeight;
    }
  }

  void initWgtList() {
    double minValue = 0.0;
    double maxValue = 0.0;
    double errorWgt = 0.0; //误差重量值
    double targetWgt = 0.0; //目标重量值
    String fmode =
        widget.selectFormula.header!.formulaHeader!.formulaMode ?? '';
    needTotalWgt = widget.selectFormula.header!.formulaHeader!.totalWeight!;
    //如果包含容器，第一个写容器  修改了此处
    if (widget.selectFormula.header!.formulaHeader!.needContainer!) {
      FormulaWgtProcessData processWgt = FormulaWgtProcessData(
        no: 0,
        rawId: '-',
        rawName: '-',
        fmaMode: fmode,
        targetWgt: 80,
        targetPct: 80,
        currentWgt: 0.0,
        minWgt: 50,
        maxWgt: 100,
        errorWgt: 0,
        errorPct: 0,
        currentErrorWgt: 0.0,
        currentErrorPct: 0.0,
        isOK: 'no', //no 未开始 low: 低，high: 高，ok: 正常 初始值都是 low
      );
      processWgtList.add(processWgt);
    }

    for (var detail in widget.selectFormula.details!) {
      if (fmode == 'wgt') {
        minValue = detail.formulaDetail!.materialWeight! -
            detail.formulaDetail!.allowableError!;
        maxValue = detail.formulaDetail!.materialWeight! +
            detail.formulaDetail!.allowableError!;
        errorWgt = detail.formulaDetail!.allowableError!;
        targetWgt = detail.formulaDetail!.materialWeight!;
      } else {
        minValue = initTotalWeight *
                (detail.formulaDetail!.materialPercentage! / 100) -
            detail.formulaDetail!.allowableError! * initTotalWeight / 100;
        minValue = double.parse(minValue.toStringAsFixed(3));
        maxValue = initTotalWeight *
                (detail.formulaDetail!.materialPercentage! / 100) +
            detail.formulaDetail!.allowableError! * initTotalWeight / 100;
        maxValue = double.parse(maxValue.toStringAsFixed(3));
        errorWgt =
            detail.formulaDetail!.allowableError! * initTotalWeight / 100;
        errorWgt = double.parse(errorWgt.toStringAsFixed(3));
        targetWgt =
            initTotalWeight * (detail.formulaDetail!.materialPercentage! / 100);
        targetWgt = double.parse(targetWgt.toStringAsFixed(3));
      }
      FormulaWgtProcessData processWgt = FormulaWgtProcessData(
        no: detail.formulaDetail?.sequence,
        rawId: detail.formulaDetail?.materialId,
        rawName: detail.rawMaterialTypeName?.rawMaterial!.materialName,
        fmaMode: fmode,
        targetWgt: targetWgt,
        targetPct: detail.formulaDetail?.materialPercentage,
        currentWgt: 0.0,
        minWgt: minValue < 0 ? 0 : minValue,
        maxWgt: maxValue,
        errorWgt: errorWgt,
        errorPct: detail.formulaDetail?.allowableError,
        currentErrorWgt: 0.0,
        currentErrorPct: 0.0,
        isOK: 'no', //no 未开始 low: 低，high: 高，ok: 正常 初始值都是 low
      );
      processWgtList.add(processWgt);
    }
    if (processWgtList.isNotEmpty) {
      selectedProcessWgt = processWgtList[0]; //默认选中第一个原料重量
    }
  }

  getFmaUnit() {
    fmaUnit = widget.selectFormula.header!.formulaHeader!.formulaUnit ?? '';
  }

  void getScaleInfo() {
    PublicFunctions.getWeight(widget.selScaleId);
  }

  //生成订单编号
  void createRecNumber() {
    String company = "F"; // 公司名称
    DateTime now = DateTime.now();
    String year = now.year.toString(); // 取年份的后两位
    String month = now.month.toString().padLeft(2, '0'); // 取月份，不足两位时补零
    String day = now.day.toString().padLeft(2, '0'); // 取日期，不足两位时补零
    String hour = now.hour.toString().padLeft(2, '0'); // 取小时，不足两位时补零
    String minute = now.minute.toString().padLeft(2, '0'); // 取分钟，不足两位时补零
    String second = now.second.toString().padLeft(2, '0'); // 取秒数，不足两位时补零
// 拼接成订单编号
    String orderNumber = "$company-$year$month$day$hour$minute$second";
    recRecNumber = orderNumber;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    for (var scale in myAllScalesList) {
      if (scale.scaleId == widget.selScaleId) {
        myScale = scale;
        break;
      }
    }
    //将传入的配方信息赋值给processWgtList
    initTotalWgtUnit();
    initWgtList();
    getScaleInfo();
    createRecNumber();
    getFmaUnit();
    cntScaleTimerMgr.startCntAliveTimer(10);
    startSetWgtStartFalseTimer();
    startCheckWgtStartTimer();

    //自动启停定时器
    autoNextStepNotifier.addListener(() {
      if (autoNextStepNotifier.value) {
        startAutoNextStepTimer();
      } else {
        stopAutoNextStepTimer();
      }
    });

    PublicFunctions.getAutoNext();

    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            rawTypeList = [];
          });
        }
      }
    });
    _eventbus2 = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            formulaTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            formulaTypeList = [];
          });
        }
      }
    });
    _eventbus3 = eventBus.on<EventRespGetRawDataList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            rawDataList = rawDataInfoFromJson(dataStr);
            // print(rawDataList.length);
          });
        } else {
          setState(() {
            rawDataList = [];
          });
        }
      }
    });
    _eventbus4 = eventBus.on<EventRespAddRawData>().listen((event) {
      if (mounted) {
        PublicFunctions.getRawList();
      }
    });
    _eventbus5 = eventBus.on<EventRespAddFormulaType>().listen((event) {
      if (mounted) {
        PublicFunctions.getFormulaTypeList();
      }
    });

    _eventbus6 = eventBus.on<EventRespFormulaList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            formulaDataList = formulaInfoDbFromJson(dataStr);
            // print(formulaDataList.length);
          });
        } else {
          setState(() {
            formulaDataList = [];
          });
        }
      }
    });

    _eventbus7 = eventBus.on<EventRespFormulaRecAdd>().listen((event) {
      if (mounted) {
        PublicFunctions.getFormulaRecList();
      }
    });

    _eventbus8 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        setState(() {
          ReqWeightCountine tempWeight = ReqWeightCountine();
          tempWeight = event.obj;
          if (tempWeight.scaleId == myScale.scaleId) {
            myReqWeightCountine = tempWeight;
            if (tempWeight.scaleId == 1) {
              myComScaleInfo.isOnline = true;
            }

            // isCnting = true;
            isWgtStart = true;
            if (myReqWeightCountine.msgBody!.weightUnit !=
                    widget.selectFormula.header!.formulaHeader!.formulaUnit &&
                isShowTipDialog == false) {
              isShowTipDialog = true;
              showTipDialog();
            }
            if (myReqWeightCountine.msgBody != null) {
              try {
                currentRawWgt =
                    double.parse(myReqWeightCountine.msgBody!.weightVal);
                // currentRawWgt =
                //     double.parse(myReqWeightCountine.msgBody!.weightVal) -
                //         actualTotalRawWgt;
                currentRawWgt = double.parse(currentRawWgt.toStringAsFixed(3));
                // if (currentRawWgt < 0) {
                //   currentRawWgt = 0.0;
                // }
              } catch (e) {
                // 处理转换失败的情况
                // print('Failed to parse weight value: $e');
                currentRawWgt = 0.0;
              }
            }
          }
        });
      }
    });
    _eventbus9 = eventBus.on<EventRespGetAutoNext>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            autoNextStep = getAutoNextFormDbFromJson(dataStr).autoNext;

            autoNextStepNotifier.value = autoNextStep;

            stableTime = getAutoNextFormDbFromJson(dataStr).stableTime;
            stableTimeCtl.text = stableTime.toString();
          });
        } else {
          setState(() {
            autoNextStepNotifier.value = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();
    cntScaleTimerMgr.stopCntAliveTimer();
    setWgtStartFalseTimer?.cancel(); // 取消定时器
    checkWgtStartTimer?.cancel(); // 取消定时器
    stopAutoNextStepTimer();
    stableTimeCtl.dispose();
    autoNextStepNotifier.dispose();
  }

  // 提示切换单位对话框
  void showTipDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowUnitTipDialog(
          title: localizedStrings.fTipTitle,
          msg:
              '${localizedStrings.fWgtUnit} ${widget.selectFormula.header!.formulaHeader!.formulaUnit!},${localizedStrings.fSwitchUnitHint}',
        );
      },
    ).then((value) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            isShowTipDialog = false;
          });
        }
      });
    });
  }

  // 显示新增配方类型对话框
  void showDeleteTipDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowDeleteTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.fClearWeighingDataMsg,
        );
      },
    ).then((value) {
      if (value) {
        setState(() {
          //清空所有称重数据
          processWgtList.clear();

          currentRawWgt = 0.0;
          clickedRow = 0;
          startFormula = false;
          isEnableNext = true;

          initWgtList();
        });
      }
    });
  }

  //获取原料OK的数量
  int getOKCount() {
    int count = 0;
    for (var wgt in processWgtList) {
      if (wgt.isOK == okStr) {
        count++;
      }
    }
    return count;
  }

  //检查是否全部OK
  bool checkAllOK() {
    for (var wgt in processWgtList) {
      if (wgt.isOK != okStr) {
        return false;
      }
    }
    return true;
  }

  saveFmaRec(bool isAllOK) {
    //修改了此处
    //通过当前原料的重量计算总的原料的实际重量
    double actualTotalRawWgt = 0.0;
    for (var wgtRec in processWgtList) {
      if (wgtRec.currentWgt != null && wgtRec.no != 0) {
        actualTotalRawWgt += wgtRec.currentWgt!;
      }
    }
    RecHeader recHeader = RecHeader(
      recordId: recRecNumber, //配方订单编号
      recHeaderOperator: 'admin', //操作员
      formulaId: widget.selectFormula.header!.formulaHeader!.formulaId, //配方ID
      formulaTypeName:
          widget.selectFormula.header!.formulaHeader!.formulaName, //配方名称
      totalWeight:
          widget.selectFormula.header!.formulaHeader!.totalWeight!, //总重量
      actualFmaTotalWgt: needTotalWgt, //实际配方总重量包括修正的重量
      actualTotalWeight: actualTotalRawWgt, //实际原料总重量
      totalWeightUnit:
          widget.selectFormula.header!.formulaHeader!.formulaUnit, //总重量单位

      totalMaterialWeightUnit:
          widget.selectFormula.header!.formulaHeader!.formulaUnit, //总原料重量单位
      isQualified: isAllOK ? 'yes' : 'no', //是否合格
      scaleId: widget.selScaleId, //秤ID
      scaleName: myScale.scaleName, //秤名称
      scaleModel: myScale.scaleModel, //秤型号
      scaleSn: myScale.scaleSn, //秤SN
    );

    List<RecDetail>? reqRecDetailList = []; //配方明细集合
    for (var wgtRec in processWgtList) {
//计算实际百分比
      double actualPct = 0.0;
      if (needTotalWgt != 0) {
        actualPct = wgtRec.currentWgt! / needTotalWgt * 100;
        actualPct = double.parse(actualPct.toStringAsFixed(3));
      }

      RecDetail recDetail = RecDetail(
        recordId: recRecNumber, //配方订单编号
        materialId: wgtRec.rawId, //原料ID
        sequence: wgtRec.no, //顺序
        allowableError: wgtRec.errorWgt, //允许误差
        targetWgt: wgtRec.targetWgt, //目标重量
        actualWeight: wgtRec.currentWgt, //实际重量
        actualWeightUnit: fmaUnit, //实际重量单位
        actualPercentage: actualPct, //实际百分比
        actualErrorWgt: wgtRec.currentErrorWgt, //实际误差重量
        actualErrorPct: wgtRec.currentErrorPct, //实际误差百分比
        isQualified: wgtRec.isOK, //是否合格
      );
      reqRecDetailList.add(recDetail);
    }

    ReqAddFmaRec reqAddFmaRec =
        ReqAddFmaRec(recHeader: recHeader, recDetail: reqRecDetailList); //配方

    PublicFunctions.addFormulaRec(reqAddFmaRecToJson(reqAddFmaRec));

    setState(() {
      isFinish = true;
      isEnableNext = false;
    });
  }

  showBottomBtn() {
    return Expanded(
        flex: 5,
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    fixedSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                    ),
                  ),
                  onPressed: !isFinish
                      ? () {
                          bool isAllOK = checkAllOK();
                          if (!isAllOK) {
                            showDialog(
                              context: context,
                              barrierDismissible: false, // 点击对话框外部不关闭对话框
                              builder: (BuildContext context) {
                                return ShowNormalTipDialog(
                                  title: localizedStrings.fTipTitle,
                                  msg: localizedStrings.fFormulaUnqualifiedMsg,
                                );
                              },
                            ).then((value) {
                              if (value) {
                                // 保存
                                saveFmaRec(isAllOK);
                                PublicFunctions.stopWeight(widget.selScaleId);
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              } else {
                                return;
                              }
                            });
                          } else {
                            saveFmaRec(isAllOK);
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  child: Text(
                    localizedStrings.fCompleteIngredientsBtn,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onPrimary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                      ),
                    ),
                    onPressed: () {
                      if (!isFinish) {
                        showDialog(
                          context: context,
                          barrierDismissible: false, // 点击对话框外部不关闭对话框
                          builder: (BuildContext context) {
                            return ShowDeleteTipDialog(
                              title: localizedStrings.fTipTitle,
                              msg: localizedStrings.fClearWeighingDataMsg,
                            );
                          },
                        ).then((value) {
                          if (value) {
                            setState(() {
                              PublicFunctions.stopWeight(widget.selScaleId);
                              Navigator.pop(context);
                            });
                          }
                        });
                      } else {
                        PublicFunctions.stopWeight(widget.selScaleId);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      localizedStrings.fAbandonIngredientsBtn,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )),
              SizedBox(
                width: 20,
              ),
              SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                      ),
                    ),
                    onPressed: () {
                      showDeleteTipDialog();
                    },
                    child: Text(
                      localizedStrings.fClearBtn,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )),
            ])));
  }

  //传入index判断是否达标
  bool checkIndexIsOK(int index) {
    return processWgtList[index].isOK == "ok" ? true : false;
  }

  showRawOrderDetail() {
    final List<Widget> children = [];
    final List<FormulaWgtProcessData> list = processWgtList;

    for (int index = 0; index < list.length; index++) {
      bool isSelected = clickedRow == index;
      Color backgroundColor = (checkIndexIsOK(index))
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerLow;
      Color innerContainerColor = isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surface;
      Color textColor = (checkIndexIsOK(index))
          ? Theme.of(context).colorScheme.onTertiaryFixedVariant
          : isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant;
      Color numberTextColor = isSelected
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSurfaceVariant;

      Widget item = InkWell(
        onTap: () {
          setState(() {
            if (enableSelRaw) {
              setState(() {
                clickedRow = index; // 更新选中的 index
                selectedProcessWgt = list[index];
              });
            }
          });
          // 这里添加点击事件的处理逻辑
          // print('点击了第 $index 项');
        },
        child: Container(
          width: (MediaQuery.of(context).size.width - 6 * 10 - 300) /
              5, // 计算每个项的宽度，每行显示 5 个
          height: 32,
          color: backgroundColor,
          child: Row(children: [
            SizedBox(
              width: 2,
            ),
            (checkIndexIsOK(index))
                ? Container(
                    width: 28,
                    height: 28,
                    color: Theme.of(context).colorScheme.onTertiaryFixedVariant,
                    child: Center(
                        child: Icon(Icons.check_circle_outline,
                            size: 24,
                            color: Theme.of(context).colorScheme.onPrimary)),
                  )
                : Container(
                    width: 28,
                    height: 28,
                    color: innerContainerColor,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: numberTextColor,
                        ),
                      ),
                    ),
                  ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                // 修改显示内容
                list[index].no == 0
                    ? localizedStrings.fFmaContainer
                    : list[index].rawName ?? '',
                style: TextStyle(
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ]),
        ),
      );

      children.add(item);

      // 不是最后一个元素时，添加图标
      if (index < list.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              Icons.keyboard_double_arrow_right_outlined, // 可替换为你想要的图标
              size: 30,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          spacing: 10, // 水平间距
          runSpacing: 10, // 垂直间距
          alignment: WrapAlignment.start, // 设置为左对齐
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      color: Theme.of(context).colorScheme.surfaceDim, //对接时修改颜色值
      child:
          // Padding(
          //   padding: const EdgeInsets.all(14.0),
          //   child:
          Row(
        children: [
          Expanded(
            child: Column(
              children: [
                showTitleBar(),
                Divider(
                  color: Theme.of(context).colorScheme.outline,
                  thickness: 1,
                  height: 1,
                ),
                showFormulaInfoAndWgt(),
                Divider(
                  color: Theme.of(context).colorScheme.outline,
                  thickness: 1,
                  height: 1,
                ),
                Expanded(
                  flex: 9,
                  child: Column(children: [
                    Container(
                        height: 42,
                        color: Theme.of(context).colorScheme.surface,
                        child: Row(children: [
                          SizedBox(
                            width: 17,
                          ),
                          Expanded(
                            child: Text(localizedStrings.fIngredientOrder),
                          ),
                        ])),
                    Expanded(
                      child: Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 17,
                                ),
                                showRawOrderDetail(),
                              ])),
                    )
                  ]),
                ),
                if (!checkAllOK()) showWgtTable(),
                if (!checkAllOK()) showNextBtn(),
                if (checkAllOK()) showCompleteStatus(),
                Container(
                  height: 14,
                  color: Theme.of(context).colorScheme.surface,
                ),
                showBottomBtn(),
              ],
            ),
          ),
        ],
        // ),
      ),
    ));
  }

  bool checkRawDelete(Object? data) {
    if (data == null || data is! RawDataInfo) {
      return false;
    }
    final targetMaterialId = data.rawMaterial.materialId;
    return formulaDataList.every((formula) {
      return formula.details?.every((detail) {
            return detail.formulaDetail?.materialId != targetMaterialId;
          }) ??
          true;
    });
  }

  //显示速度

  showSpeed() {
    return Expanded(
        flex: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //当目标值与当前值相差500g以上时，快速
            //当目标值与当前值100到500g之间时，中速
            //当目标值与当前值100g以下时，慢速
            //当当前值大于目标值，不显示
            if (currentRawWgt <=
                selectedProcessWgt.targetWgt! - selectedProcessWgt.currentWgt!)
              IntrinsicWidth(
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  color: Color(0xFFFFB44A),
                  child: Center(
                    child: Text(
                      selectedProcessWgt.targetWgt! -
                                  selectedProcessWgt.currentWgt! -
                                  currentRawWgt >
                              500
                          ? localizedStrings.fHighSpeed
                          : (selectedProcessWgt.targetWgt! -
                                          selectedProcessWgt.currentWgt! -
                                          currentRawWgt <
                                      500) &&
                                  (selectedProcessWgt.targetWgt! -
                                          selectedProcessWgt.currentWgt! -
                                          currentRawWgt >
                                      100)
                              ? localizedStrings.fMediumSpeed
                              : localizedStrings.fLowSpeed,
                      style: TextStyle(
                        color: Colors.black,
                        // 保留文本截断设置，以防空间不足
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ));
  }

//扣重归零等按钮
  showTareZero() {
    return Container(
        height: 52,
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(children: [
          showSpeed(),
          SizedBox(
            width: 20,
          ),
          Expanded(
              flex: 2,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                SizedBox(
                  width: 150,
                  child: Row(children: [
                    Expanded(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                            side: BorderSide(
                              color: startFormula
                                  ? Theme.of(context).colorScheme.outline
                                  : Theme.of(context).colorScheme.primary,
                            )),
                      ),
                      onPressed: startFormula
                          ? null
                          : () {
                              PublicFunctions.performZeroWithScaleId(
                                  widget.selScaleId);
                            },
                      child: Text(
                        localizedStrings.iBtnZero,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.primary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )),
                  ]),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 150,
                  child: Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          fixedSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                              side: BorderSide(
                                color: startFormula
                                    ? Theme.of(context).colorScheme.outline
                                    : Theme.of(context).colorScheme.primary,
                              )),
                        ),
                        onPressed: startFormula
                            ? null
                            : () {
                                PublicFunctions.performTareWithScaleId(
                                    widget.selScaleId);
                              },
                        child: Text(
                          localizedStrings.gBtnTare,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.primary,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ]))
        ]));
  }

  //扣重归零等按钮
  showNextBtn() {
    return Container(
        height: 50,
        color: Theme.of(context).colorScheme.surface,
        child: Row(children: [
          SizedBox(
            width: 17,
          ),
          Expanded(
              flex: 1,
              child: SizedBox(
                  child: Row(children: [
                Spacer(),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 200,
                  child: Row(children: [
                    Expanded(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                        ),
                      ),
                      onPressed: isEnableNext
                          ? () {
                              handleNexBtn();
                            }
                          : null,
                      child: Text(
                        //下一步
                        localizedStrings.fNextStepBtn,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )),
                  ]),
                ),
                SizedBox(
                  width: 20,
                )
              ]))),
          SizedBox(
            width: 20,
          )
        ]));
  }

  showCompleteStatus() {
    //显示一张图片
    return Expanded(
        flex: 20,
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            alignment: Alignment.center,
            child: Row(children: [
              Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SizedBox(
                          //   height: 20,
                          // ),
                          Container(
                              height: 150,
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                "assets/images/complete.png",
                                fit: BoxFit.cover,
                              )),
                          // SizedBox(
                          //   height: 14,
                          // ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              localizedStrings.fFormulaCompletedTip,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ])),
              )
            ])));
  }

  showTable() {
    return Expanded(
        flex: 3,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          // 获取表格的最大宽度
          double maxWidth = constraints.maxWidth;
          // 计算表格的实际宽度，减去左侧和右侧的边距
          double tableWidth = maxWidth - 40;
          double columnWidth = tableWidth / 8;
          return Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            color: Theme.of(context).colorScheme.surface,
            child: StickyTable(
              controller: _scrollController, // 传递 ScrollController
              // 修改 data 属性
              data: processWgtList.isEmpty
                  ? []
                  : sort
                      ? processWgtList.reversed.toList()
                      : processWgtList,
              defaultColumnWidth: const FixedColumnWidth(130),
              titleHeight: 48,
              cellHeight: 44,
              clickedRow: clickedRow,
              onRowClick: (row) {
                if (enableSelRaw) {
                  setState(() {
                    clickedRow = row;
                    selectedProcessWgt = processWgtList[row];
                  });
                }
              },

              cellDecoration: (context, column, data, row, columnIndex) {
                // 添加点击行背景色
                if (row == clickedRow) {
                  return BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1),
                    ),
                  );
                }
                return BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1),
                  ),
                );
              },
              columns: [
                StickyTableColumn(
                  localizedStrings.gTabOrder,
                  fixedStart: true,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onTitleClick: (context, title) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(const SnackBar(content: Text("排序")));
                    // setState(() {
                    //   sort = !(title.sort ?? false);
                    // });
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text((data as FormulaWgtProcessData).no.toString());
                  },
                  renderTitle: (context, title) {
                    return Text(
                      title.title,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 4, 68, 230)),
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fMaterialIdCol,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text((data as FormulaWgtProcessData).rawId!);
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fMaterialNameCol,
                  columnWidth: FixedColumnWidth(columnWidth),
                  showSort: true,
                  sort: false,
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text((data as FormulaWgtProcessData).rawName!);
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fTargetWeightLabel,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        (data as FormulaWgtProcessData).targetWgt.toString());
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fCurrentWeightLabel,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        (data as FormulaWgtProcessData).currentWgt.toString());
                  },
                ),
                StickyTableColumn(
                  "允许误差重量",
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        (data as FormulaWgtProcessData).errorWgt.toString());
                  },
                ),
                StickyTableColumn(
                  "当前误差重量",
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text((data as FormulaWgtProcessData)
                        .currentErrorWgt
                        .toString());
                  },
                ),
                StickyTableColumn(
                  "是否达标",
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                      (data as FormulaWgtProcessData).isOK! == "no"
                          ? "未完成"
                          : (data).isOK! == "ok"
                              ? "已达标"
                              : "未达标",
                      style: TextStyle(
                        color: (data).isOK! == "no"
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : (data).isOK! == "ok"
                                ? Theme.of(context)
                                    .colorScheme
                                    .onTertiaryFixedVariant
                                : Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                ),
                // StickyTableColumn(
                //   "补充",
                //   fixedEnd: true,
                //   columnWidth: const FixedColumnWidth(50),
                //   renderCell: (context, title, data, row, column) {
                //     return MaterialButton(
                //       onPressed: () {
                //         // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                //         // ScaffoldMessenger.of(
                //         //   context,
                //         // ).showSnackBar(SnackBar(
                //         //     content: Text(
                //         //         "删除${(data as FormulaInfoDb)..header!.formulaHeader!.formulaName!}成功")));
                //       },
                //       // color: Colors.red,
                //       minWidth: 0,
                //       child: Center(
                //           child: Icon(
                //         size: 20,
                //         Icons.add_comment_outlined,
                //         color: Theme.of(context).colorScheme.primary,
                //       )),
                //     );
                //   },
                // ),
              ],
            ),
          );
        }));
  }

  showWgtTable() {
    return Expanded(
        flex: 13,
        child: Container(
          color: Theme.of(context).colorScheme.onPrimary,
          child: Column(children: [
            SizedBox(
                height: 48,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Expanded(
                      child: Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Text(
                              selectedProcessWgt.no == 0
                                  ? localizedStrings.fFmaContainer
                                  : selectedProcessWgt.rawName ?? '',
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          )))
                ])),
            Expanded(
                child: SizedBox(
              child: Row(children: [
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(children: [
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                            child: Column(children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    localizedStrings.fRawMaterialWeightLabel),
                              )),
                          Expanded(
                            flex: 1,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                // 获取 Container 的最大宽度
                                double maxWidth = constraints.maxWidth;
                                double maxHeight = constraints.maxHeight;

                                return Container(
                                  // 使用自定义进度条组件
                                  alignment: Alignment.centerLeft,
                                  child: CustomProgressBar(
                                    value: currentRawWgt < 0
                                        ? 0
                                        : currentRawWgt, // 传入当前值
                                    minValue: double.parse(
                                                (selectedProcessWgt.minWgt! -
                                                        selectedProcessWgt
                                                            .currentWgt!)
                                                    .toStringAsFixed(3)) <
                                            0
                                        ? 0.0
                                        : double.parse((selectedProcessWgt
                                                    .minWgt! -
                                                selectedProcessWgt.currentWgt!)
                                            .toStringAsFixed(3)), // 传入最小值

                                    maxValue: double.parse(
                                                (selectedProcessWgt.maxWgt! -
                                                        selectedProcessWgt
                                                            .currentWgt!)
                                                    .toStringAsFixed(3)) <
                                            0
                                        ? 0.0
                                        : double.parse((selectedProcessWgt
                                                    .maxWgt! -
                                                selectedProcessWgt.currentWgt!)
                                            .toStringAsFixed(3)), // 传入最大值
                                    targetValue: double.parse(
                                                (selectedProcessWgt.targetWgt! -
                                                        selectedProcessWgt
                                                            .currentWgt!)
                                                    .toStringAsFixed(3)) <
                                            0
                                        ? 0.0
                                        : double.parse((selectedProcessWgt
                                                    .targetWgt! -
                                                selectedProcessWgt.currentWgt!)
                                            .toStringAsFixed(3)), // 传入目标值
                                    maxWidth: maxWidth, // 传递最大宽度
                                    maxHeight: maxHeight, // 传递最大高度
                                  ),
                                );
                              },
                            ),
                          ),
                        ]))),

                    showTareZero(),

                    Expanded(
                        flex: 1,
                        child: SizedBox(
                            child: Column(children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    localizedStrings.fFormulaProgressLabel),
                              )),
                          Expanded(
                            flex: 1,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                // 获取 Container 的最大宽度
                                double maxWidth = constraints.maxWidth;
                                double maxHeight = constraints.maxHeight;

                                return Container(
                                  // 使用自定义进度条组件
                                  alignment: Alignment.centerLeft,
                                  child: CustomFmaProgressBar(
                                    currentValue: getOKCount(), // 传入当前值
                                    max: processWgtList.isEmpty
                                        ? 1
                                        : processWgtList.length, // 传入最大值

                                    maxWidth: maxWidth, // 传递最大宽度
                                    maxHeight: maxHeight, // 传递最大高度
                                  ),
                                );
                              },
                            ),
                          ),
                        ]))),

                    //重量表格 调试用，无须删除
                    // showTable(),
                    SizedBox(
                      height: 20,
                    )
                  ]),
                )),
                SizedBox(
                  width: 10,
                ),
              ]),
            )),
          ]),
        ));
  }

  showFCode() {
    String id = "";
    if (widget.selectFormula.header == null ||
        widget.selectFormula.header!.formulaHeader == null ||
        widget.selectFormula.header!.formulaHeader!.formulaId == null) {
      id = "";
    } else {
      id = widget.selectFormula.header!.formulaHeader!.formulaId!;
    }
    return Expanded(
      child: Text(
        id,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  showFName() {
    String name = "";
    if (widget.selectFormula.header == null ||
        widget.selectFormula.header!.formulaHeader == null ||
        widget.selectFormula.header!.formulaHeader!.formulaName == null) {
      name = "";
    } else {
      name = widget.selectFormula.header!.formulaHeader!.formulaName!;
    }
    return Expanded(
      child: Text(
        name,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  showFormulaName() {
    return Container(
      height: 28,
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerLeft,
      child: Row(children: [
        // 显示标签部分，设置固定宽度
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 0, // 最小宽度为 0
            maxWidth: 200, // 最大宽度为 200
          ),
          child: Text(
            localizedStrings.fFmaNameLabel + ": ",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        // 显示编号内容部分，用 Expanded 约束宽度
        showFName()
      ]),
    );
  }
//显示总重和单位

  showTotalWgtAndUnit() {
    final header = widget.selectFormula.header;
    final formulaHeader = header?.formulaHeader;
    final totalWeight = formulaHeader?.totalWeight;
    final formulaUnit = formulaHeader?.formulaUnit;

    final displayText = totalWeight != null && formulaUnit != null
        ? '$totalWeight  $formulaUnit'
        : '';

    return Expanded(
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  showFInfo() {
    return Expanded(
      flex: 9,
      child: Column(children: [
        Container(
          height: 40,
          color: Theme.of(context).colorScheme.surface,
          alignment: Alignment.centerLeft,
          child: Row(children: [
            // 显示标签部分，设置固定宽度
            Expanded(
              child: Text(
                localizedStrings.fRemarkCol,
                style: Theme.of(context).textTheme.labelMedium!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // 显示编号内容部分，用 Expanded 约束宽度
          ]),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            child: SelectableText(
              widget.selectFormula.header == null ||
                      widget.selectFormula.header!.formulaHeader == null ||
                      widget.selectFormula.header!.formulaHeader!.remark == null
                  ? ""
                  : widget.selectFormula.header!.formulaHeader!.remark!,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ]),
    );
  }

  String checkIsOk(double currValue, double minValue, double maxValue) {
    //判断当前的值是否达标
    String isWgtOk = '';
    if (currValue >= minValue && currValue <= maxValue) {
      isWgtOk = "ok";
    } else if (currValue < minValue) {
      isWgtOk = "low";
    } else if (currValue > maxValue) {
      isWgtOk = "high";
    }
    return isWgtOk;
  }

  String checkValueIsOk() {
    //判断当前的值是否达标
    String isWgtOk = '';
    double minWgt = double.parse(selectedProcessWgt.minWgt!.toStringAsFixed(3));
    double maxWgt = double.parse(selectedProcessWgt.maxWgt!.toStringAsFixed(3));
    if (currentRawWgt + selectedProcessWgt.currentWgt! >= minWgt &&
        currentRawWgt + selectedProcessWgt.currentWgt! <= maxWgt) {
      isWgtOk = "ok";
    } else if (currentRawWgt + selectedProcessWgt.currentWgt! < minWgt) {
      isWgtOk = "low";
    } else if (currentRawWgt + selectedProcessWgt.currentWgt! > maxWgt) {
      isWgtOk = "high";
    }
    return isWgtOk;
  }

  showWgtData() {
    return Expanded(
      flex: 20,
      child: Column(children: [
        Container(
          height: 28,
          color: Theme.of(context).colorScheme.surface,
          alignment: Alignment.centerLeft,
          child: Row(children: [
            // 显示标签部分，设置固定宽度
            Expanded(
              child: Text(
                localizedStrings.fIngredientsDataLabel,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // 显示编号内容部分，用 Expanded 约束宽度
          ]),
        ),
        Expanded(
            child: SizedBox(
          child: Row(children: [
            Expanded(
                flex: 3,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Column(children: [
                    Expanded(
                        flex: 3,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.only(left: 8.0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                selectedProcessWgt.rawName ?? "",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )),
                          ]),
                        )),
                    Expanded(
                        flex: 4,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.only(left: 8.0),
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft, // 保持文本左对齐
                                  child: Text(
                                    (myReqWeightCountine.msgBody == null ||
                                            !isWgtStart)
                                        ? '-----'
                                        : currentRawWgt.toString(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 48,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    fmaUnit,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )),
                          ]),
                        )),
                  ]),
                )),
            SizedBox(
              width: 14,
            ),
            Expanded(
                flex: 2,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Column(children: [
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    localizedStrings.fTargetWeightLabel,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )),
                          ]),
                        )),
                    Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.only(left: 8.0),
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft, // 保持文本左对齐
                                  child: Text(
                                    double.parse((selectedProcessWgt
                                                    .targetWgt! -
                                                selectedProcessWgt.currentWgt!)
                                            .toStringAsFixed(3))
                                        .toString(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 48,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    fmaUnit,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )),
                          ]),
                        )),
                  ]),
                )),
            SizedBox(
              width: 14,
            ),
            Expanded(
                flex: 2,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Column(children: [
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.only(left: 8.0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                localizedStrings.fAllowableError,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )),
                          ]),
                        )),
                    Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.only(left: 8.0),
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft, // 保持文本左对齐
                                  child: Text(
                                    '$showErrorStr ${selectedProcessWgt.errorWgt}',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 48,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    fmaUnit,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )),
                          ]),
                        )),
                  ]),
                )),
            SizedBox(
              width: 14,
            ),
          ]),
        )),
      ]),
    );
  }

  showFormulaInfoAndWgt() {
    return Expanded(
      flex: 5,
      child: Container(
        color: const Color.fromARGB(255, 253, 252, 252),
        child: Column(children: [
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: 17,
              ),
              showFInfo(),

              //显示重量
              // showWgtData(),
              SizedBox(
                width: 20,
              ),
            ],
          ))
        ]),
      ),
    );
  }

  void handleNexBtn() {
    //判断为空
    if (myReqWeightCountine.msgBody == null) {
      showTipInfo(localizedStrings.fDeviceDisconnected, context);
      return;
    }
    //判断当前是否已经稳定
    if (myReqWeightCountine.msgBody!.isStable == false) {
      showTipInfo(localizedStrings.fStableOperationHint, context);
      return;
    }
    //判断是否已经开始,开始后就不能再归零扣重了
    if (!startFormula) {
      startFormula = true;
    }
    if (selectedProcessWgt.no == 0) {
      //如果是第一个原料，直接赋值，这个原料是容器，直接赋值，执行扣重
      selectedProcessWgt.currentWgt = currentRawWgt;
      selectedProcessWgt.isOK = okStr;
      PublicFunctions.performTareWithScaleId(widget.selScaleId);
      //然后去找下一个原料
      findNextRaw();
      return;
    }
    //判断是否合格
    String isWgtOk = checkValueIsOk();

    //不合格，重量轻了 轻了就不让往下走
    if (isWgtOk == 'low') {
      showTipInfo(localizedStrings.fCurrentMaterialWeightInvalidMsg, context);
      return;
    } else if (isWgtOk == highStr) {
      //锁定当前重量
      double currentTempWgtValue = currentRawWgt;
      // 提示超重
      showDialog(
        context: context,
        barrierDismissible: false, // 点击对话框外部不关闭对话框
        builder: (BuildContext context) {
          return ShowHignWgtTipDialog(
            title: localizedStrings.fTipTitle,
            msg: localizedStrings.fCurrentMaterialOverweightMsg,
          );
        },
      ).then((value) {
        if (value == 1) {
          //放弃此次配料
          setState(() {
            //清空所有称重数据
            processWgtList.clear();

            currentRawWgt = 0.0;
            clickedRow = 0;
            startFormula = false;

            initWgtList();
          });
        } else if (value == 2) {
          //接受修正
          handleReviseWgt(currentTempWgtValue);
          PublicFunctions.performTareWithScaleId(widget.selScaleId);
          setState(() {});
        } else {
          return;
        }
      });
    } else {
      double currentTempWgtValue = currentRawWgt;
      handleOkStatus(isWgtOk, currentTempWgtValue);
    }
  }

  //重新计算需要的重量
  recalculateWgtList(double lastNeedTotalWgt) {
    //根据模式计算需要的重量
    if (widget.selectFormula.header == null ||
        widget.selectFormula.header!.formulaHeader == null ||
        widget.selectFormula.header!.formulaHeader!.formulaMode == null) {
      return;
    }
    String fmaMode = widget.selectFormula.header!.formulaHeader!.formulaMode!;

    if (fmaMode == 'wgt') {
      //按重量
      for (var item in processWgtList) {
        //如果第一个是容器，就不用去计算
        if (item.no == 0) {
          continue;
        }
        item.targetWgt = needTotalWgt * item.targetWgt! / lastNeedTotalWgt;
        item.targetWgt = double.parse(item.targetWgt!.toStringAsFixed(3));
        item.minWgt = item.targetWgt! - item.errorWgt!;
        item.minWgt = double.parse(item.minWgt!.toStringAsFixed(3));
        item.maxWgt = item.targetWgt! + item.errorWgt!;
        item.maxWgt = double.parse(item.maxWgt!.toStringAsFixed(3));
        item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
        item.currentErrorWgt =
            double.parse(item.currentErrorWgt!.toStringAsFixed(3));
        item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
      }
    } else {
      //按百分比
      for (var item in processWgtList) {
        if (item.no == 0) {
          continue;
        }
        item.targetWgt = needTotalWgt * item.targetPct! / 100;
        item.targetWgt = double.parse(item.targetWgt!.toStringAsFixed(3));
        item.errorWgt = needTotalWgt * item.errorPct! / 100;
        item.errorWgt = double.parse(item.errorWgt!.toStringAsFixed(3));
        item.minWgt = item.targetWgt! - item.errorWgt!;
        item.minWgt = double.parse(item.minWgt!.toStringAsFixed(3));
        item.maxWgt = item.targetWgt! + item.errorWgt!;
        item.maxWgt = double.parse(item.maxWgt!.toStringAsFixed(3));
        item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
        item.currentErrorWgt =
            double.parse(item.currentErrorWgt!.toStringAsFixed(3));
        item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
      }
    }
  }

//查找下一个原料
  void findNextRaw() {
    //修改了此处

    //重头找第一个不合格的开始处理
    FormulaWgtProcessData nextItem;
    // 先查找 isOK 不为 'ok' 的项
    try {
      nextItem = processWgtList.firstWhere((item) => item.isOK != 'ok');
      selectedProcessWgt = nextItem; // 更新选中的原料重量项
      //如果有容器
      if (widget.selectFormula.header != null &&
          widget.selectFormula.header!.formulaHeader != null &&
          widget.selectFormula.header!.formulaHeader!.needContainer!) {
        clickedRow = selectedProcessWgt.no!; // 更新点击的行索引
      } else {
        clickedRow = selectedProcessWgt.no! - 1; // 更新点击的行索引
      }

      // print(clickedRow);

      currentRawWgt = 0.000;
    } catch (e) {
      // 如果没有 isOK 不为 'ok' 的项，说明配方完成了
      setState(() {
        isEnableNext = false; // 禁用按钮
      });
      showTipInfo(localizedStrings.fFormulaCompletionMsg, context);
      return;
    }
  }

  handleReviseWgt(double tmpCurrWgt) {
    //修正重量，将当前的原料重量赋值给目标重量
    if (processWgtList.isNotEmpty) {
      try {
        //先根据当前的重量计算出需要的总重量
        if (widget.selectFormula.header != null &&
            widget.selectFormula.header!.formulaHeader != null &&
            widget.selectFormula.header!.formulaHeader!.totalWeight != null &&
            selectedProcessWgt.targetWgt != null &&
            selectedProcessWgt.targetWgt! != 0) {
          double lastNeedTotalWgt = needTotalWgt;
          needTotalWgt = needTotalWgt *
              (tmpCurrWgt + selectedProcessWgt.currentWgt!) /
              selectedProcessWgt.targetWgt!;
          needTotalWgt = double.parse(needTotalWgt.toStringAsFixed(3));
          //赋值给当前的原料重量
          var targetItem = processWgtList
              .firstWhere((item) => item.no == selectedProcessWgt.no);
          targetItem.currentWgt = tmpCurrWgt + targetItem.currentWgt!;
          targetItem.currentWgt =
              double.parse(targetItem.currentWgt!.toStringAsFixed(3));

          //重新计算所有的数据
          recalculateWgtList(lastNeedTotalWgt);
          findNextRaw();
        } else {
          // 处理空值情况
          needTotalWgt = 0.0;
          showTipInfo('配方数据错误！', context);
        }
      } catch (e) {
        return;
      }
    }
  }

  handleOkStatus(String isWgtOk, double currentRawWgt) {
    //将当前的原料重量赋值给目标重量
    if (processWgtList.isNotEmpty) {
      try {
        //重量模式
        var targetItem = processWgtList
            .firstWhere((item) => item.no == selectedProcessWgt.no);
        targetItem.currentWgt = currentRawWgt + selectedProcessWgt.currentWgt!;
        targetItem.isOK = isWgtOk;
        targetItem.currentErrorWgt =
            (targetItem.currentWgt! - selectedProcessWgt.targetWgt!);
        targetItem.currentErrorWgt =
            double.parse(targetItem.currentErrorWgt!.toStringAsFixed(3));
        //百分比模式算出百分比
        if (widget.selectFormula.header!.formulaHeader!.formulaMode! == 'pct') {
          //计算误差的百分比
          if (needTotalWgt > 0) {
            targetItem.currentErrorPct =
                (targetItem.currentErrorWgt! / needTotalWgt) * 100;
            targetItem.currentErrorPct =
                double.parse(targetItem.currentErrorPct!.toStringAsFixed(3));
          }
        }
        PublicFunctions.performTareWithScaleId(widget.selScaleId);

        //查找下一个
        findNextRaw();

        // print(clickedRow);
      } catch (e) {
        // 处理未找到匹配项的情况
        // print('未找到匹配的原料重量项: $e');
      }
    }
  }

//单据编号
  showTitleBar() {
    return Container(
      height: 54,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: 17,
          ),
          Expanded(
            child: RichText(
                text: TextSpan(
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    children: [
                  TextSpan(
                      text: localizedStrings.fOrderNo + ': ',
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  TextSpan(
                      text: recRecNumber,
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: Theme.of(context).colorScheme.onSurface)),
                  TextSpan(
                    text: '       ',
                  ),
                  TextSpan(
                      text: localizedStrings.fFmaNameLabel + ': ',
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  TextSpan(
                      text: widget
                          .selectFormula.header!.formulaHeader!.formulaName!,
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: Theme.of(context).colorScheme.onSurface)),
                  TextSpan(
                    text: '       ',
                  ),
                  TextSpan(
                      text: localizedStrings.fFmaIdLabel + ': ',
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  TextSpan(
                      text: widget
                          .selectFormula.header!.formulaHeader!.formulaId!,
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: Theme.of(context).colorScheme.onSurface)),
                ])),
          ),
          Text(
            localizedStrings.gTipAutoNextStep,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(
            width: regularPadding,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  autoNextStep = !autoNextStep;
                  autoNextStepNotifier.value = autoNextStep;
                  if (autoNextStep) {
                    stableTimeCtl.text = stableTime.toString();
                  }
                });
                setAutoNext();
              },
              icon: Icon(
                autoNextStep
                    ? Icons.toggle_on_outlined
                    : Icons.toggle_off_outlined,
                color: autoNextStep
                    ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                    : Theme.of(context).colorScheme.onSurface,
              )),
          SizedBox(
            width: regularPadding,
          ),
          if (autoNextStep)
            Text(
              localizedStrings.gTipStableTime,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .apply(color: Theme.of(context).colorScheme.onSurface),
            ),
          if (autoNextStep)
            SizedBox(
              width: regularPadding,
            ),
          if (autoNextStep)
            SizedBox(
              width: 65,
              height: 35,
              child: DropdownButtonFormField<String>(
                borderRadius: BorderRadius.circular(0),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 10), // 调整垂直和水平内边距
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant, // 设置边框颜色
                          width: 1.0, // 设置边框宽度
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(0.0))),
                    border: OutlineInputBorder()),
                isExpanded: true,
                value: stableTimeCtl.text == "" ? null : stableTimeCtl.text,
                items: [
                  ...['1', '2', '5', '10'].map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    );
                  })
                ],
                onChanged: (value) {
                  setState(() {
                    stableTimeCtl.text = value!;
                    stableTime = int.tryParse(stableTimeCtl.text) ?? 1;
                  });
                  setAutoNext();
                },
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .apply(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }

  void setAutoNext() {
    ReqAutoNext reqAutoNext = ReqAutoNext(
      autoNext: autoNextStep,
      stableTime: stableTime,
    );

    PublicFunctions.updateAutoNext(reqAutoNextToJson(reqAutoNext));
  }

  showAddFormulaIconBtn(String tip, IconData icon, Function() onPressed) {
    return Tooltip(
        message: tip, // 提示信息
        child: IconButton(
          iconSize: 24,
          color: Theme.of(context).colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              // 设置为矩形形状
              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
            ),
            fixedSize: const Size(40, 40), // 设置固定大小
          ),
          onPressed: onPressed,
          icon: Icon(icon),
        ));
  }

  showIconButton(String tip, IconData icon, Function() onPressed) {
    return Tooltip(
      message: tip, // 提示信息
      child: IconButton(
        iconSize: 24,
        color: Theme.of(context).colorScheme.onPrimary,
        focusColor: Theme.of(context).colorScheme.outline,
        hoverColor: Theme.of(context).colorScheme.outline,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            // 设置为矩形形状
            borderRadius: BorderRadius.zero, // 没有圆角，即正方形
          ),
          fixedSize: const Size(40, 40), // 设置固定大小
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class HandlerClearButton extends StatelessWidget {
  const HandlerClearButton({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.clear,
        size: 20,
      ),
      onPressed: () => controller.clear(),
    );
  }
}
