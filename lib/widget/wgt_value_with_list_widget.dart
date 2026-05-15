//绉伴噸鍏辩敤鐨勯噸閲忔樉绀虹晫�?20250521

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
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/plu_select.dart';

class ScaleWgtWidget extends StatefulWidget {
  final int scaleId;
  final String scaleName;

  const ScaleWgtWidget({
    super.key,
    required this.scaleId,
    required this.scaleName,
  });

  @override
  State<ScaleWgtWidget> createState() => _ScaleWgtWidgetState();
}

class _ScaleWgtWidgetState extends State<ScaleWgtWidget> {
  ReqWeightCountine tempWeight = ReqWeightCountine();
  ReceiveWgtInfo? weightInfo;
  Timer? startTimer;
  Timer? innerTimer;
  bool isCnting = false;
  bool isStart = false;

  dynamic eventBus1;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus6;
  dynamic eventBus7;

  late int dateformat;
  late double zeroRange;
  List<WeightReportData> weightReportDatas = <WeightReportData>[];
  List<WeightReportData> wgtRptDataList = [];
  final DataGridController _dataGridController = DataGridController();

  PluData? selectedPluData; // 鐢ㄤ簬瀛樺偍閫変腑鐨凱luData

  late int weightMode; // 鎵嬪姩淇濆瓨�? �?锛岀ǔ瀹氫繚�?

  final int cstManualSave = 1;
  final int cstStableSave = 2;

  int _stableSaveTime = 0;
  bool firstGetRec = true;
  late bool _isSaveBtnEnable;

  bool lastStableStatus = false;
  int maxRecId = 0;
  Scale? tempDefScaleInfo;

  final ScrollController _horizontalScrollController = ScrollController();

  GetScaleRecords currGetScaleRecords = GetScaleRecords(weightRecords: []);

  //瀹氭椂鍙戦€佺Г杩樻椿鐫€
  Timer? _cntAliveTimer;
  bool _isCntAliveTiming = false;
  bool get isCntAliveTiming => _isCntAliveTiming;

  final _searchRawIdCtl = TextEditingController();

  bool _hasPassedZero = false; // 鏍囪鏄惁缁忚�?0 �?
  Timer? _stableTimer; // 绋冲畾鐘舵€佽鏃跺�?
  int _currentStableDuration = 0; // 褰撳墠绋冲畾鐘舵€佹寔缁椂�?

  void startCntAliveTimer(int time) {
    if (_cntAliveTimer != null) {
      _cntAliveTimer!.cancel();
    }

    _isCntAliveTiming = true;
    _cntAliveTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.sendScaleAlive(widget.scaleId); //鍙涓插彛
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
    dateformat = (int.tryParse(mySettingParam.dateFormat) ?? 0);
    zeroRange = (double.tryParse(mySettingParam.zeroRange) ?? 0.0);
    String timeString = (mySettingParam.stableTime == "")
        ? "0"
        : mySettingParam.stableTime.toString();
    _stableSaveTime = (int.tryParse(timeString) ?? 0);
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
          _checkStableStatus();
        });
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
          dateformat = (int.tryParse(mySettingParam.dateFormat) ?? 0);
          zeroRange = (double.tryParse(mySettingParam.zeroRange) ?? 0.0);
          String timeString = (mySettingParam.stableTime == "")
              ? "0"
              : mySettingParam.stableTime.toString();
          _stableSaveTime = (int.tryParse(timeString) ?? 0);
          if (weightMode == cstStableSave) {
            _isSaveBtnEnable = false;
          } else {
            _isSaveBtnEnable = true;
          }
        });
      }
    });

    eventBus4 = eventBus.on<EventGetScaleRecords>().listen((event) {
      if (mounted) {
        if (mounted) setState(() {
          currGetScaleRecords = event.obj;
          if ((currGetScaleRecords.weightRecords ?? []).isNotEmpty) {
            Scale? tempScale;
            for (var scale in myAllScalesList) {
              if (scale.scaleId == widget.scaleId) {
                tempScale = scale;
              }
            }

            if (tempScale != null &&
                currGetScaleRecords.weightRecords![0].scaleModel ==
                    tempScale.scaleModel &&
                currGetScaleRecords.weightRecords![0].scaleSn ==
                    tempScale.scaleSn) {
              wgtRptDataList.clear();
              _addDBdataToReport();
              getWeightReportData();
              if (firstGetRec) {
                int maxId =
                    int.parse(currGetScaleRecords.weightRecords![0].id!);
                maxRecId = maxId;

                // 閬嶅�?weightRecords 鍒楄�?
                for (var record in (currGetScaleRecords.weightRecords ?? [])) {
                  int currentId = int.parse(record.id!);
                  if (currentId > maxId) {
                    maxId = currentId;
                    maxRecId = maxId;
                  }
                }
              }
            }
          } else {
            // wgtRptDataList.clear();
            // updateTableData(getWeightReportData());
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

    eventBus7 = eventBus.on<EventRevExportRecs>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody != "") {
          if (mounted && context.mounted) {
            // showConfirmationDialog(context, myRespDataFromScale.msgBody);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus6.cancel();
    eventBus7.cancel();

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

  //绋冲畾淇濆瓨閫昏�?

  void _checkStableStatus() {
    // 妫€鏌ユ槸鍚︾粡�?0 �?

    // 鍒ゆ柇鏄惁涓虹ǔ瀹氫繚瀛樻ā寮忎�?_stableSaveTime 澶т簬 0
    if (weightMode == cstStableSave && _stableSaveTime > 0) {
      // 妫€鏌ユ槸鍚︾粡�?0 �?
      if ((weightInfo?.isZero ?? false) && (weightInfo?.isStable ?? false)) {
        _hasPassedZero = true;
      }
      if ((weightInfo?.isStable ?? false)) {
        // 妫€鏌ラ噸閲忔暟鎹槸鍚︽湁�?
        final weightValue = double.tryParse((weightInfo?.weightVal ?? "0")) ?? 0;
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

  // 閲嶇疆绋冲畾鐘舵€佽鏃跺櫒
  void _resetStableTimer() {
    _stableTimer?.cancel();
    _stableTimer = null;
    _currentStableDuration = 0;
  }

  // 淇濆瓨閲嶉噺鏁版�?
  void _saveWeightData() {
    if (_hasPassedZero && (weightInfo?.isStable ?? false)) {
      final weightValue = double.tryParse((weightInfo?.weightVal ?? "0")) ?? 0;
      if (weightValue > 0) {
        _changeSaveButton();
        _hasPassedZero = false; // 淇濆瓨鍚庨噸缃粡杩?0 鐐规爣璁?
      }
    }
  }

  List<WeightReportData> getWeightReportData() {
    return wgtRptDataList;
  }

  void updateTableData(List<WeightReportData> newReportData) {
    // _weightReportDataSource.updateData(newReportData);
  }

  void _addDBdataToReport() {
    addDBdataToReport(wgtRptDataList, mySettingParam, dateformat);
    // if (mounted) setState(() {
    //   _weightReportDataSource =
    //       WeightReportDataSource(_weightReportDatas, weighingMode);
    //   Future.delayed(const Duration(milliseconds: 100), () {
    //     _dataGridController
    //         .scrollToRow(_weightReportDataSource.rows.length - 0);
    //   });
    // });
  }

  void onStartTimer() {
    startTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      isCnting = false; // 閲嶇疆璁℃椂鍣ㄧ姸鎬?
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
    return Container(
        padding: EdgeInsets.only(bottom: regularPadding),
        height: 184,
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Container(
            height: 169,
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.only(
                left: regularPadding, right: regularPadding),
            child: Column(
              children: [
                Container(
                    height: btnHeight,
                    color: Theme.of(context).colorScheme.surface,
                    alignment: Alignment.centerLeft,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 170,
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
                            showSelPluWidget(140, 40, (value) {
                              if (mounted) setState(() {
                                selectedPluData = value;
                              });
                            }),
                        ])),
                Container(
                  height: 1,
                  color: Theme.of(context).colorScheme.surface,
                ),
                Container(
                    height: 52,
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
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
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
                                width: smallPadding,
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
                              if (mySettingParam.wgtMode == 0)
                                SizedBox(
                                  width: smallPadding,
                                ),
                              if (mySettingParam.wgtMode == 0)
                                Tooltip(
                                    message: (localizedStrings?.gBtnSave ?? "gBtnSave"),
                                    child: IconButton(
                                        iconSize: 28,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiaryFixedVariant,
                                        focusColor: Theme.of(context)
                                            .colorScheme
                                            .outline,
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
                                            // 璁剧疆涓虹煩褰㈠舰鐘?
                                            borderRadius:
                                                BorderRadius.zero, // 娌℃湁鍦嗚锛屽嵆姝ｆ柟�?
                                          ),
                                          fixedSize:
                                              const Size(28, 28), // 璁剧疆鍥哄畾澶у皬
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
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: Container(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown, // 褰撴枃瀛楁孩鍑烘椂缂╁皬瀛椾�?
                          alignment: Alignment.centerRight,
                          child: Text(weightInfo?.weightVal ?? '---------',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                    fontSize: 40,
                                    color: isStart
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onTertiaryFixedVariant
                                        : Theme.of(context).colorScheme.error,
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
              // 褰撴寜閽笉鍙敤鏃讹紝璁剧疆鑳屾櫙棰滆壊涓虹伆�?
              disabledBackgroundColor:
                  Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                // 璁剧疆涓虹煩褰㈠舰鐘?
                borderRadius: BorderRadius.zero, // 娌℃湁鍦嗚锛屽嵆姝ｆ柟�?
              ),
              fixedSize: Size(iconBtnSize, iconBtnSize), // 璁剧疆鍥哄畾澶у皬
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
      _addWeightToReport();
      sendReportDataToDB();
    });
  }

  void sendReportDataToDB() {
    sendRptDataToDB(wgtRptDataList, weighingMode, widget.scaleId);
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

      (weightInfo!.weightVal == '---------') ? (" ") : ((weightInfo?.weightVal ?? "0")),
      (weightInfo?.weightUnit == '----') ? (" ") : (weightInfo!.weightUnit!),
      mySysUser.userName ?? "",
      mySysUser.nickName ?? "",

      tempDefScaleInfo?.scaleName ?? '', //姝ゅ搴旇鏄Г鏈虹鍚?
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
              // 璁剧疆涓虹煩褰㈠舰鐘?
              borderRadius: BorderRadius.zero, // 娌℃湁鍦嗚锛屽嵆姝ｆ柟�?
            ),
            fixedSize: const Size(40, 40), // 璁剧疆鍥哄畾澶у皬
          ),
          onPressed: onPressed,
          icon: icon,
        ));
  }

  Widget _buildIconAndText(
      BuildContext context, String text, bool? isConditionMet, int type) {
    return Align(
        child: Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      width: 28,
      height: 28,
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
          24,
          20,
          isConditionMet == null
              ? Theme.of(context).colorScheme.surface
              : isConditionMet
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.surface),
    ));
  }
}
