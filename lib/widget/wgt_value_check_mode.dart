//检重模式称重共用的重量显示界面 20250521

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/const_var_data.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/record_data.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/settingparam_data.dart';
import 'package:t_max/data/weight_report_data.dart';
import 'package:t_max/data/weight_rpt.dart';
import 'package:t_max/data/wgt_rpt_data_source.dart';
import 'package:t_max/dialog/high_low_setting_new.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/plu_select.dart';

class ScaleWgtCheckModeWidget extends StatefulWidget {
  final int scaleId;
  final String scaleName;

  const ScaleWgtCheckModeWidget({
    super.key,
    required this.scaleId,
    required this.scaleName,
  });

  @override
  State<ScaleWgtCheckModeWidget> createState() =>
      _ScaleWgtCheckModeWidgetState();
}

class _ScaleWgtCheckModeWidgetState extends State<ScaleWgtCheckModeWidget> {
  ReqWeightCountine tempWeight = ReqWeightCountine();
  ReceiveWgtInfo? weightInfo;
  Timer? startTimer;
  Timer? innerTimer;
  bool isCnting = false;
  bool isStart = false;

  dynamic eventBus1;
  dynamic eventBus3;
  dynamic eventBus6;

  late int dateformat;
  late double zeroRange;
  List<WeightReportData> weightReportDatas = <WeightReportData>[];
  List<WeightReportData> wgtRptDataList = [];
  final DataGridController _dataGridController = DataGridController();

  PluData? selectedPluData; // 用于存储选中的PluData

  late int weightMode; // 手动保存�? �?，稳定保�?

  final int cstManualSave = 1;
  final int cstStableSave = 2;

  int _stableSaveTime = 0;

  int maxRecId = 0;
  Scale? tempDefScaleInfo;

  bool firstGetRec = true;
  bool _isSaveBtnEnable = false;

  bool lastStableStatus = false;

  bool _isLow = false;
  bool _isOK = false;
  bool _isHigh = false;

  final ScrollController _horizontalScrollController = ScrollController();

  GetScaleRecords currGetScaleRecords = GetScaleRecords(weightRecords: []);

  //定时发送秤还活着
  Timer? _cntAliveTimer;
  bool _isCntAliveTiming = false;
  bool get isCntAliveTiming => _isCntAliveTiming;

  final _searchRawIdCtl = TextEditingController();

  bool _hasPassedZero = false; // 标记是否经过 0 �?
  Timer? _stableTimer; // 稳定状态计时器
  int _currentStableDuration = 0; // 当前稳定状态持续时�?
  double highValue = 0.0;
  double lowValue = 0.0;

  void startCntAliveTimer(int time) {
    if (_cntAliveTimer != null) {
      _cntAliveTimer!.cancel();
    }

    _isCntAliveTiming = true;
    _cntAliveTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.sendScaleAlive(widget.scaleId); //只管串口
      if (!isStart) {
        PublicFunctions.getWeight(widget.scaleId);
      }
      startCntAliveTimer(10);
    });
  }

  void stopCntAliveTimer() {
    _cntAliveTimer?.cancel();
    _isCntAliveTiming = false;
  }

  @override
  void initState() {
    super.initState();
    onStartTimer();
    startCntAliveTimer(10);
    for (int i = 0; i < myAllScalesList.length; i++) {
      if (myAllScalesList[i].scaleId == widget.scaleId) {
        tempDefScaleInfo = myAllScalesList[i];
      }
    }

    sortColumnName = 'Id';
    sortDirectValue = DataGridSortDirection.descending;

    if (mySettingParam.recMode == msgManual) {
      weightMode = cstManualSave;
      _isSaveBtnEnable = true;
    } else {
      _isSaveBtnEnable = false;
      weightMode = cstStableSave;
    }

    weightMode = (mySettingParam.recMode == msgManual)
        ? cstManualSave
        : (mySettingParam.recMode == msgAuto)
            ? cstStableSave
            : cstManualSave;
    dateformat = int.tryParse(mySettingParam.dateFormat) ?? 0;
    zeroRange = double.tryParse(mySettingParam.zeroRange) ?? 0.0;
    String timeString = (mySettingParam.stableTime == "")
        ? "0"
        : mySettingParam.stableTime.toString();
    _stableSaveTime = int.tryParse(timeString) ?? 0;
    if (weightMode == cstStableSave) {
      _isSaveBtnEnable = false;
    } else {
      _isSaveBtnEnable = true;
    }

    weightInfo = ReceiveWgtInfo(
      weightVal: '---------',
      weightUnit: '----',
      isStable: false,
      isZero: false,
      isNet: false,
    );

    eventBus1 = eventBus.on<EventReqWeightCountine>().listen((event) {
      tempWeight = event.obj;
      if (tempWeight.scaleId == widget.scaleId &&
          mounted &&
          tempWeight.msgBody != null) {
        _isLow = false;
        _isOK = false;
        _isHigh = false;
        if (mounted) setState(() {
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

        var weight = double.tryParse((weightInfo?.weightVal ?? '0'));
        if (weight != null) {
          if (weight >= 0) {
            if (weight < lowValue) {
              _isLow = true;
            } else if (weight >= lowValue && weight <= highValue) {
              _isOK = true;
            } else if (weight > highValue) {
              _isHigh = true;
            }
          }
        }

        switch (weightMode) {
          case 1:
            break;
          case 2:
            _checkStableStatus();
            break;
          default:
        }
      } else {}
      if (mounted) {
        for (var scale in myAllScalesList) {
          if (scale.scaleId == tempWeight.scaleId && scale.isOnline == false) {
            if (mounted) setState(() {
              scale.isOnline = true;
            });
          }
        }
      }
    });

    eventBus3 = eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) {
        if (mounted) setState(() {
          mySettingParam = event.obj;
          weightMode = (mySettingParam.recMode == msgManual)
              ? cstManualSave
              : (mySettingParam.recMode == msgAuto)
                  ? cstStableSave
                  : cstManualSave;
          dateformat = int.tryParse(mySettingParam.dateFormat) ?? 0;
          zeroRange = double.tryParse(mySettingParam.zeroRange) ?? 0.0;
          String timeString = (mySettingParam.stableTime == "")
              ? "0"
              : mySettingParam.stableTime.toString();
          _stableSaveTime = int.tryParse(timeString) ?? 0;
          if (weightMode == cstStableSave) {
            _isSaveBtnEnable = false;
          } else {
            _isSaveBtnEnable = true;
          }
        });
      }
    });

    eventBus6 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains(msgOk)) {
          if (mounted) setState(() {
            isStart = true;
          });
        } else {}
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus3.cancel();
    eventBus6.cancel();

    _horizontalScrollController.dispose();
    _dataGridController.dispose();
    _searchRawIdCtl.dispose();

    startTimer?.cancel();
    innerTimer?.cancel();
    _stableTimer?.cancel();
    stopCntAliveTimer();
    _cntAliveTimer?.cancel();
    super.dispose();
  }

  //稳定保存逻辑

  void _checkStableStatus() {
    // 检查是否经�?0 �?

    // 判断是否为稳定保存模式且 _stableSaveTime 大于 0
    if (weightMode == cstStableSave && _stableSaveTime > 0) {
      // 检查是否经�?0 �?
      if (weightInfo!.isZero! && (weightInfo?.isStable ?? false)) {
        _hasPassedZero = true;
      }
      if ((weightInfo?.isStable ?? false)) {
        // 检查重量数据是否有�?
        final weightValue = double.tryParse((weightInfo?.weightVal ?? '0')) ?? 0;
        if (weightValue > 0 && _hasPassedZero) {
          if (_stableTimer == null) {
            _currentStableDuration = 0;
            _stableTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              _currentStableDuration++;
              if (_currentStableDuration >= _stableSaveTime) {
                _stableTimer?.cancel();
                _stableTimer = null;
                _currentStableDuration = 0;
                _saveWeightData();
              }
            });
          }
        } else {
          _resetStableTimer();
        }
      } else {
        _resetStableTimer();
      }
    }
  }

  // 重置稳定状态计时器
  void _resetStableTimer() {
    _stableTimer?.cancel();
    _stableTimer = null;
    _currentStableDuration = 0;
  }

  // 保存重量数据
  void _saveWeightData() {
    if (_hasPassedZero && (weightInfo?.isStable ?? false)) {
      final weightValue = double.tryParse((weightInfo?.weightVal ?? '0')) ?? 0;
      if (weightValue > 0) {
        if (mySettingParam.saveMode == hiMode && _isHigh) {
          _changeSaveButton();
          _hasPassedZero = false; // 保存后重置经�?0 点标�?
        } else if (mySettingParam.saveMode == okMode && _isOK) {
          _changeSaveButton();
          _hasPassedZero = false; // 保存后重置经�?0 点标�?
        } else if (mySettingParam.saveMode == lowMode && _isLow) {
          _changeSaveButton();
          _hasPassedZero = false; // 保存后重置经�?0 点标�?
        } else if (mySettingParam.saveMode == allMode) {
          _changeSaveButton();
          _hasPassedZero = false; // 保存后重置经�?0 点标�?
        }
      }
    }
  }

  List<WeightReportData> getWeightReportData() {
    return wgtRptDataList;
  }

  void updateTableData(List<WeightReportData> newReportData) {
    // _weightReportDataSource.updateData(newReportData);
  }

  void onStartTimer() {
    startTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      isCnting = false; // 重置计时器状�?
      innerTimer = Timer(Duration(milliseconds: 2500), () {
        if (!isCnting) {
          isStart = false;
          if (mounted) setState(() {
            weightInfo = ReceiveWgtInfo(
              weightVal: '---------',
              weightUnit: '----',
              isStable: false,
              isZero: false,
              isNet: false,
            );
          });
          for (var scale in myAllScalesList) {
            if (scale.scaleId == widget.scaleId && scale.isOnline == true) {
              if (mounted) setState(() {
                scale.isOnline = false;
              });
              break;
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
        padding: EdgeInsets.only(bottom: isMobile ? 4 : regularPadding),
        color: Colors.transparent,
        child: Column(children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : regularPadding),
            child: Column(
              children: [
                Container(
                    height: btnHeight,
                    color: Theme.of(context).colorScheme.surface,
                    alignment: Alignment.centerLeft,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.scaleName,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.apply(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (mySettingParam.wgtMode == 0)
                            const SizedBox(width: smallPadding),
                          if (mySettingParam.wgtMode == 0)
                            showSelPluWidget(140, 40, (value) {
                              if (mounted) setState(() {
                                selectedPluData = value;
                                highValue = selectedPluData?.limitHigh ?? 0;
                                lowValue = selectedPluData?.limitLow ?? 0;
                              });
                            }),
                        ])),
                Container(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Container(
                    height: isMobile ? 40 : 52,
                    color: Theme.of(context).colorScheme.surface,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 104,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildIconAndText(
                                context,
                                (localizedStrings?.iStable ?? "iStable"),
                                weightInfo?.isStable,
                                1,
                              ),
                              _buildIconAndText(
                                context,
                                (localizedStrings?.iTextNet ?? "iTextNet"),
                                weightInfo?.isNet,
                                2,
                              ),
                              _buildIconAndText(
                                context,
                                (localizedStrings?.iTextZero ?? "iTextZero"),
                                weightInfo?.isZero,
                                3,
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: isMobile ? 240 : 280, // 增加宽度以确保保存按钮显示，并减小中间间距
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              showPerformIconBtn(
                                  highLowSettingSvgIcon(),
                                  (localizedStrings?.iTitleHLSetting ?? "iTitleHLSetting"),
                                  isStart
                                      ? () {
                                          highLowSettingDialog(context);
                                        }
                                      : null),
                              SizedBox(
                                width: isMobile ? 4 : smallPadding,
                              ),
                              showPerformIconBtn(
                                  performTareSvgIcon(),
                                  (localizedStrings?.gBtnTare ?? "gBtnTare"),
                                  isStart
                                      ? () {
                                          PublicFunctions
                                              .performTareWithScaleId(
                                                  widget.scaleId);
                                        }
                                      : null),
                              SizedBox(
                                width: isMobile ? 4 : smallPadding,
                              ),
                              showPerformIconBtn(
                                  performZeroSvgIcon(),
                                  (localizedStrings?.iBtnZero ?? "iBtnZero"),
                                  isStart
                                      ? () {
                                          PublicFunctions
                                              .performZeroWithScaleId(
                                                  widget.scaleId);
                                        }
                                      : null),
                              SizedBox(
                                width: isMobile ? 4 : smallPadding,
                              ),
                              Tooltip(
                                  message: (localizedStrings?.gBtnSave ?? "gBtnSave"),
                                  child: IconButton(
                                      iconSize: 28,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryFixedVariant,
                                      focusColor:
                                          Theme.of(context).colorScheme.outline,
                                      hoverColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withOpacity(0.1),
                                      style: IconButton.styleFrom(
                                        disabledBackgroundColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .surface,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .onTertiaryFixedVariant,
                                        shape: RoundedRectangleBorder(
                                          // 设置为矩形形�?
                                          borderRadius:
                                              BorderRadius.zero, // 没有圆角，即正方�?
                                        ),
                                        fixedSize: const Size(28, 28), // 设置固定大小
                                      ),
                                      onPressed: isStart &&
                                              _isSaveBtnEnable &&
                                              (weightInfo?.isStable ?? false)
                                          ? () {
                                              _changeSaveButton();
                                            }
                                          : null,
                                      icon: getSvgIcon(
                                          saveSvgIcon(),
                                          28,
                                          28,
                                          isStart &&
                                                  _isSaveBtnEnable &&
                                                  (weightInfo?.isStable ?? false)
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surface))),
                            ],
                          ),
                        )
                      ],
                    )),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Container(
                  height: isMobile ? 50 : 60,
                  color: (lowValue == 0 && highValue == 0 || !isStart || (!_isHigh && !_isOK && !_isLow))
                      ? Colors.transparent
                      : (_isHigh
                          ? Theme.of(context).colorScheme.error
                          : (_isOK
                              ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                              : Theme.of(context).colorScheme.onTertiaryContainer)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: Container(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown, // 当文字溢出时缩小字体
                          alignment: Alignment.centerRight,
                          child: Text(weightInfo?.weightVal ?? '---------',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge?.copyWith(
                                    fontSize: 40,
                                    color: (lowValue == 0 && highValue == 0 || !isStart || (!_isHigh && !_isOK && !_isLow))
                                        ? (isStart
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onTertiaryFixedVariant
                                            : Theme.of(context).colorScheme.error)
                                        : Colors.white,
                                  )),
                        ),
                      )),
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.bottomLeft,
                        child: Text(weightInfo?.weightUnit ?? '----',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge?.apply(
                                  color: (lowValue == 0 && highValue == 0 || !isStart || (!_isHigh && !_isOK && !_isLow))
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.white,
                                )),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]));
  }

  void highLowSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return NewHighLowSettingDialog(
            highValue: highValue, lowValue: lowValue);
      },
    ).then((value) {
      if (value != null) {
        if (mounted) setState(() {
          highValue = value.highValue;
          lowValue = value.lowValue;
        });
      }
    });
  }

  final iconBtnSize = 28.0;

  Widget showPerformIconBtn(
      String iconPath, String title, VoidCallback? onPressed) {
    return Tooltip(
        message: title,
        child: IconButton(
            iconSize: iconBtnSize,
            color: Theme.of(context).colorScheme.primary,
            disabledColor: Theme.of(context).colorScheme.primary,
            focusColor: Theme.of(context).colorScheme.outline,
            hoverColor:
                Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
            style: IconButton.styleFrom(
              // 当按钮不可用时，设置背景颜色为灰�?
              disabledBackgroundColor:
                  Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                // 设置为矩形形�?
                borderRadius: BorderRadius.zero, // 没有圆角，即正方�?
              ),
              fixedSize: Size(iconBtnSize, iconBtnSize), // 设置固定大小
            ),
            onPressed: onPressed,
            icon: getSvgIcon(
                iconPath,
                iconBtnSize,
                iconBtnSize,
                isStart
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.surface)));
  }

  _changeSaveButton() {
    if (mounted) setState(() {
      wgtRptDataList.clear();
      _addWeightToReport();
      sendReportDataToDB();
    });
  }

  void sendReportDataToDB() {
    sendRptDataToDB(wgtRptDataList, wgtCheckMode, widget.scaleId);
  }

  void _addWeightToReport() {
    PluData? tempPlu = PluData(null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, '', '');

    if (selectedPluData != null) {
      tempPlu = selectedPluData;
    }

    maxRecId++;
    WeightReportData addData = WeightReportData(
      (maxRecId).toString(),
      tempDefScaleInfo?.scaleModel ?? '',
      tempDefScaleInfo?.scaleSn ?? '',
      (tempPlu!.plu == null) ? "" : tempPlu.plu.toString(),
      (tempPlu.productCode == null) ? "" : tempPlu.productCode.toString(),

      (tempPlu.itemCode == null) ? "" : tempPlu.itemCode.toString(),

      (tempPlu.category == null) ? "" : tempPlu.category.toString(),

      (tempPlu.productName == null) ? "" : tempPlu.productName.toString(),

      (tempPlu.generalUnit == null) ? "" : tempPlu.generalUnit.toString(),

      (tempPlu.taxType == null) ? "" : tempPlu.taxType.toString(),

      (tempPlu.price == null) ? "" : tempPlu.price.toString(),

      (tempPlu.unitWeight == null) ? "" : tempPlu.unitWeight.toString(),

      (tempPlu.pretare == null) ? "" : tempPlu.pretare.toString(),

      (tempPlu.limitHigh == null) ? "" : tempPlu.limitHigh.toString(),

      (tempPlu.limitLow == null) ? "" : tempPlu.limitLow.toString(),

      (weightInfo!.weightVal == '---------') ? (" ") : ((weightInfo?.weightVal ?? '0')),
      (weightInfo?.weightUnit == '----') ? (" ") : ((weightInfo?.weightUnit ?? 'kg')),
      mySysUser.userName ?? "",
      mySysUser.nickName ?? "",
      tempDefScaleInfo?.scaleName ?? '', //此处应该是秤机种�?
      getDateTime(mySettingParam.dateSeparator, dateformat),
    );
    wgtRptDataList.add(addData);
  }

  Widget showIconBtn(
      String message, Function()? onPressed, Color bkColor, Widget icon) {
    return Tooltip(
        message: message,
        child: IconButton(
          iconSize: 24,
          hoverColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          style: IconButton.styleFrom(
            backgroundColor: bkColor,
            shape: RoundedRectangleBorder(
              // 设置为矩形形�?
              borderRadius: BorderRadius.zero, // 没有圆角，即正方�?
            ),
            fixedSize: const Size(40, 40), // 设置固定大小
          ),
          onPressed: onPressed,
          icon: icon,
        ));
  }

  Widget _buildIconAndText(
      BuildContext context, String text, bool? isConditionMet, int type) {
    return Align(
        child: Container(
      padding: const EdgeInsets.only(left: 3, right: 3),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isConditionMet == null
              ? Theme.of(context).colorScheme.outlineVariant
              : isConditionMet
                  ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                  : Theme.of(context).colorScheme.outlineVariant),
      child: getSvgIcon(
          type == 1
              ? stableSvgIcon()
              : type == 2
                  ? netSvgIcon()
                  : zeroSvgIcon(),
          20,
          20,
          isConditionMet == null
              ? Theme.of(context).colorScheme.surface
              : isConditionMet
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.surface),
    ));
  }
}
