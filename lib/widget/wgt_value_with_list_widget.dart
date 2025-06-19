//称重共用的重量显示界面 20250521

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/const_var_data.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/data/plu_info_list_data.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/record_data.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/settingparam_data.dart';
import 'package:t_max/data/userinfo_data.dart';
import 'package:t_max/data/weight_report_data.dart';
import 'package:t_max/data/weight_rpt.dart';
import 'package:t_max/data/wgt_rpt_data_source.dart';
import 'package:t_max/dialog/setting_dialog.dart';
import 'package:t_max/dialog/weight_report_feilds_setting.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';

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
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus6;
  dynamic eventBus7;

  late int dateformat;
  late double zeroRange;

  List<PluData> myPluInfoList = [];

  List<WeightReportData> _weightReportDatas = <WeightReportData>[];
  List<WeightReportData> wgtRptDataList = [];
  final DataGridController _dataGridController = DataGridController();

  PluData? selectedPluData; // 用于存储选中的PluData
  int _currentPage = 1;

  late int weightMode; // 手动保存，1 ，2，稳定保存

  final int cstManualSave = 1;
  final int cstStableSave = 2;
  UserInfo tmpUserInfo = UserInfo();

  int _stableSaveTime = 0;
  bool firstGetRec = true;
  late bool _isSaveBtnEnable;
  late bool _isStableStatusJudge;
  bool lastStableStatus = false;
  int maxRecId = 0;
  late Scale tempDefScaleInfo;

  final ScrollController _horizontalScrollController = ScrollController();

  GetScaleRecords currGetScaleRecords = GetScaleRecords(weightRecords: []);

  //定时发送秤还活着
  Timer? _cntAliveTimer;
  bool _isCntAliveTiming = false;
  bool get isCntAliveTiming => _isCntAliveTiming;

  var _searchRawIdCtl = TextEditingController();

  bool _hasPassedZero = false; // 标记是否经过 0 点
  Timer? _stableTimer; // 稳定状态计时器
  int _currentStableDuration = 0; // 当前稳定状态持续时间

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

    dateformat = 1;
    zeroRange = 0;
    sortColumnName = 'Id';
    sortDirectValue = DataGridSortDirection.descending;

    if (myModeSettingNormal.recMode == msgManual) {
      weightMode = cstManualSave;
      _isSaveBtnEnable = true;
    } else {
      _isSaveBtnEnable = false;
      weightMode = cstStableSave;
    }
    _isStableStatusJudge = false;

    weightInfo = ReceiveWgtInfo(
      weightVal: '---------',
      weightUnit: '----',
      isStable: false,
      isZero: false,
      isNet: false,
    );
    PublicFunctions.getProductList();

    eventBus1 = eventBus.on<EventReqWeightCountine>().listen((event) {
      tempWeight = event.obj;
      if (tempWeight.scaleId == widget.scaleId &&
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
          _checkStableStatus();
        });
      } else {}
      if (mounted) {
        for (var scale in myAllScalesList) {
          if (scale.scaleId == tempWeight.scaleId && scale.isOnline == false) {
            setState(() {
              scale.isOnline = true;
            });
          }
        }
      }
    });

    eventBus2 = eventBus.on<EventProductRecList>().listen((event) {
      if (mounted) {
        setState(() {
          List<PluInfoList> pluInfoList = event.obj;
          for (int i = 0; i < pluInfoList.length; i++) {
            PluData newPlu =
                PluData(0, 0, 0, 0, '', '', 0, 0, 0, 0, 0, 0, 0, '');
            newPlu.recId = pluInfoList[i].recId;
            newPlu.plu = int.tryParse(pluInfoList[i].plu) ?? 0;
            newPlu.productCode = int.tryParse(pluInfoList[i].productCode) ?? 0;
            newPlu.itemCode = int.tryParse(pluInfoList[i].itemCode) ?? 0;
            newPlu.category = pluInfoList[i].category;
            newPlu.productName = pluInfoList[i].productName;
            newPlu.price = double.tryParse(pluInfoList[i].price) ?? 0;
            newPlu.taxType = int.tryParse(pluInfoList[i].taxType) ?? 0;
            newPlu.generalUnit = int.tryParse(pluInfoList[i].generalUnit) ?? 0;
            newPlu.unitWeight = double.tryParse(pluInfoList[i].unitWeight) ?? 0;
            newPlu.pretare = double.tryParse(pluInfoList[i].pretare) ?? 0;
            newPlu.limitHigh = double.tryParse(pluInfoList[i].limitHigh) ?? 0;
            newPlu.limitLow = double.tryParse(pluInfoList[i].limitLow) ?? 0;
            newPlu.creatAt = pluInfoList[i].creatAt ?? " ";
            myPluInfoList.add(newPlu);
          }

          // getProductNameList();
          // getWeight();
          // getRecords();
        });
      }
    });

    eventBus3 = eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          myModeSettingNormal = event.obj;
          weightMode = (myModeSettingNormal.recMode == msgManual)
              ? cstManualSave
              : (myModeSettingNormal.recMode == msgAuto)
                  ? cstStableSave
                  : cstManualSave;
          dateformat = int.parse(myModeSettingNormal.dateFormat);
          zeroRange = double.tryParse(myModeSettingNormal.zeroRange)!;
          String timeString = (myModeSettingNormal.stableTime == "")
              ? "0"
              : myModeSettingNormal.stableTime.toString();
          _stableSaveTime = int.parse(timeString);
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
        setState(() {
          currGetScaleRecords = event.obj;
          if (currGetScaleRecords.weightRecords!.isNotEmpty) {
            late Scale tempScale;
            for (var scale in myAllScalesList) {
              if (scale.scaleId == widget.scaleId) {
                tempScale = scale;
              }
            }

            if (currGetScaleRecords.weightRecords![0].scaleModel ==
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

                // 遍历 weightRecords 列表
                for (var record in currGetScaleRecords.weightRecords!) {
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
          setState(() {
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
    eventBus2.cancel();
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
    super.dispose();
  }

  //稳定保存逻辑

  void _checkStableStatus() {
    // 检查是否经过 0 点

    // 判断是否为稳定保存模式且 _stableSaveTime 大于 0
    if (weightMode == cstStableSave && _stableSaveTime > 0) {
      // 检查是否经过 0 点
      if (weightInfo!.isZero! && weightInfo!.isStable!) {
        _hasPassedZero = true;
      }
      if (weightInfo!.isStable!) {
        // 检查重量数据是否有效
        final weightValue = double.tryParse(weightInfo!.weightVal!) ?? 0;
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
    if (_hasPassedZero && weightInfo!.isStable!) {
      final weightValue = double.tryParse(weightInfo!.weightVal!) ?? 0;
      if (weightValue > 0) {
        _changeSaveButton();
        _hasPassedZero = false; // 保存后重置经过 0 点标记
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
    addDBdataToReport(wgtRptDataList, myModeSettingNormal, dateformat);
    // setState(() {
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
      isCnting = false; // 重置计时器状态
      innerTimer = Timer(Duration(milliseconds: 1000), () {
        if (!isCnting) {
          isStart = false;
          setState(() {
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
              setState(() {
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                                  .labelMedium!
                                  .apply(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 140,
                            height: 40,
                            alignment: Alignment.centerLeft,
                            child: Autocomplete<PluData>(
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return TextField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  onSubmitted: (String value) {
                                    onFieldSubmitted();
                                  },
                                  maxLines: 1,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                  // 设置输入框的装饰
                                  decoration: InputDecoration(
                                    // 去掉下划线
                                    border: OutlineInputBorder(
                                      gapPadding: 2,
                                      // 添加四周边框
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // 聚焦时的边框样式
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // 正常状态的边框样式
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outlineVariant,
                                        width: 1,
                                      ),
                                    ),
                                    // 可以添加提示文本等其他装饰属性
                                    hintText:
                                        'PLU', //localizedStrings.fSearchHint,
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<PluData>.empty();
                                }

                                final resultSet = <PluData>{};
                                resultSet
                                    .addAll(myPluInfoList.where((PluData data) {
                                  // 进行模糊查找，这里同时匹配productName和plu转成字符串后的内容
                                  return data.productName!
                                          .toLowerCase()
                                          .contains(textEditingValue.text
                                              .toLowerCase()) ||
                                      data.plu
                                          .toString()
                                          .contains(textEditingValue.text);
                                }));

                                List<PluData> newList = [];
                                final seenRecIds = <int>{};
                                for (var item in resultSet) {
                                  // 检查 recId 是否不为 null 且未在 seenRecIds 中出现过
                                  if (item.recId != null &&
                                      seenRecIds.add(item.recId!)) {
                                    newList.add(item);
                                    seenRecIds.add(item.recId!);
                                  }
                                }

                                return newList.toList()
                                  ..sort((a, b) => a.plu!.compareTo(b.plu!));
                              },
                              onSelected: (PluData selection) {
                                setState(() {
                                  selectedPluData = selection;
                                });
                              },
                              displayStringForOption: (PluData option) =>
                                  '${option.plu}:${option.productName}',
                            ),
                          ),
                        ])),
                Container(
                  height: 1,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                                localizedStrings.iStable,
                                weightInfo?.isStable,
                                1,
                              ),
                              _buildIconAndText(
                                context,
                                localizedStrings.iTextNet,
                                weightInfo?.isNet,
                                2,
                              ),
                              _buildIconAndText(
                                context,
                                localizedStrings.iTextZero,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              showPerformIconBtn(
                                  performTareSvgIcon(),
                                  localizedStrings.gBtnTare,
                                  isStart
                                      ? () {
                                          PublicFunctions
                                              .performTareWithScaleId(
                                                  widget.scaleId);
                                        }
                                      : null),
                              showPerformIconBtn(
                                  performZeroSvgIcon(),
                                  localizedStrings.iBtnZero,
                                  isStart
                                      ? () {
                                          PublicFunctions
                                              .performZeroWithScaleId(
                                                  widget.scaleId);
                                        }
                                      : null),
                              Tooltip(
                                  message: localizedStrings.gBtnSave,
                                  child: IconButton(
                                      iconSize: 28,
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                                .surfaceContainerLow,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: RoundedRectangleBorder(
                                          // 设置为矩形形状
                                          borderRadius:
                                              BorderRadius.zero, // 没有圆角，即正方形
                                        ),
                                        fixedSize: const Size(28, 28), // 设置固定大小
                                      ),
                                      onPressed: isStart && _isSaveBtnEnable
                                          ? () {
                                              _changeSaveButton();
                                            }
                                          : null,
                                      icon: getSvgIcon(
                                          saveSvgIcon(),
                                          28,
                                          28,
                                          isStart && _isSaveBtnEnable
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest))),
                            ],
                          ),
                        )
                      ],
                    )),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                          fit: BoxFit.scaleDown, // 当文字溢出时缩小字体
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
                            style: Theme.of(context).textTheme.bodyLarge!.apply(
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
              // 当按钮不可用时，设置背景颜色为灰色
              disabledBackgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                // 设置为矩形形状
                borderRadius: BorderRadius.zero, // 没有圆角，即正方形
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
                    : Theme.of(context).colorScheme.surfaceContainerHighest)));
  }

  _changeSaveButton() {
    setState(() {
      _addWeightToReport();
      sendReportDataToDB();
    });
  }

  void sendReportDataToDB() {
    sendRptDataToDB(wgtRptDataList, weighingMode, widget.scaleId);
  }

  void _addWeightToReport() {
    PluData? tempPlu = PluData(null, null, null, null, null, null, null, null,
        null, null, null, null, null, null);
    if (selectedPluData != null) {
      tempPlu = selectedPluData;
    }

    maxRecId++;
    WeightReportData addData = WeightReportData(
      (maxRecId).toString(),
      tempDefScaleInfo.scaleModel,
      tempDefScaleInfo.scaleSn,
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

      (weightInfo!.weightVal == '---------') ? (" ") : (weightInfo!.weightVal!),
      (weightInfo?.weightUnit == '----') ? (" ") : (weightInfo!.weightUnit!),
      (tmpUserInfo.id == null)
          ? ""
          : (tmpUserInfo.id.toString().contains("Please")
              ? ""
              : tmpUserInfo.id.toString()),
      (tmpUserInfo.name == null)
          ? ""
          : (tmpUserInfo.name.toString().contains("Please")
              ? ""
              : tmpUserInfo.name.toString()),

      tempDefScaleInfo.scaleName, //此处应该是秤机种名
      getDateTime(myModeSettingNormal.dateSeparator, dateformat),
    );
    wgtRptDataList.add(addData);
  }

  void reportFieldsSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const ReportFeildsSettingDialog();
      },
    ).then((value) {
      if (value) {
        setState(() {});
      }
    });
  }

  void paramSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const ParamSettingDialog();
      },
    );
  }

  Widget showIconBtn(
      String message, Function()? onPressed, Color bkColor, Widget icon) {
    return Tooltip(
        message: message,
        child: IconButton(
          iconSize: 24,
          hoverColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          style: IconButton.styleFrom(
            backgroundColor: bkColor,
            shape: RoundedRectangleBorder(
              // 设置为矩形形状
              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
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
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : isConditionMet
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.surfaceContainerHighest),
    ));
  }
}
/////////////////////////////////////////////以下是备份
///
/////称重共用的重量显示界面 20250521

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:t_max/data/const_var_data.dart';
// import 'package:t_max/data/downloadresponse.dart';
// import 'package:t_max/data/home_page_common_data.dart';
// import 'package:t_max/data/icons.dart';
// import 'package:t_max/data/language.dart';
// import 'package:t_max/data/manager_scale_channel.dart';
// import 'package:t_max/data/plu_data_source.dart';
// import 'package:t_max/data/plu_info_list_data.dart';
// import 'package:t_max/data/received_wgt_value.dart';
// import 'package:t_max/data/record_data.dart';
// import 'package:t_max/data/reqweightdata_data.dart';
// import 'package:t_max/data/scale_info_from_db.dart';
// import 'package:t_max/data/settingparam_data.dart';
// import 'package:t_max/data/userinfo_data.dart';
// import 'package:t_max/data/weight_report_data.dart';
// import 'package:t_max/data/weight_rpt.dart';
// import 'package:t_max/data/wgt_rpt_data_source.dart';
// import 'package:t_max/dialog/setting_dialog.dart';
// import 'package:t_max/dialog/weight_report_feilds_setting.dart';
// import 'package:t_max/eventbus/eventbus.dart';
// import 'package:t_max/functions/methods.dart';
// import 'package:t_max/widget/common_widget.dart';

// class ScaleItemWithListWidget extends StatefulWidget {
//   final int scaleId;

//   final String scaleName;

//   const ScaleItemWithListWidget({
//     super.key,
//     required this.scaleId,
//     required this.scaleName,
//   });

//   @override
//   State<ScaleItemWithListWidget> createState() =>
//       _ScaleItemWithListWidgetState();
// }

// class _ScaleItemWithListWidgetState extends State<ScaleItemWithListWidget> {
//   ReqWeightCountine tempWeight = ReqWeightCountine();
//   ReceiveWgtInfo? weightInfo;
//   Timer? startTimer;
//   Timer? innerTimer;
//   bool isCnting = false;
//   bool isStart = false;
//   dynamic eventBus1;
//   dynamic eventBus2;
//   dynamic eventBus3;
//   dynamic eventBus4;
//   dynamic eventBus5;
//   dynamic eventBus6;
//   dynamic eventBus7;
//   dynamic eventBus8;

//   late int dateformat;
//   late double zeroRange;

//   List<PluData> myPluInfoList = [];
//   late WeightReportDataSource _weightReportDataSource;
//   List<WeightReportData> _weightReportDatas = <WeightReportData>[];
//   List<WeightReportData> wgtRptDataList = [];
//   final DataGridController _dataGridController = DataGridController();

//   PluData? selectedPluData; // 用于存储选中的PluData
//   int _currentPage = 1;

//   late int weightMode; // 手动保存，1 ，2，稳定保存

//   final int cstManualSave = 1;
//   final int cstStableSave = 2;
//   UserInfo tmpUserInfo = UserInfo();

//   int _stableSaveTime = 0;
//   bool firstGetRec = true;
//   late bool _isSaveBtnEnable;
//   late bool _isStableStatusJudge;
//   bool lastStableStatus = false;
//   int maxRecId = 0;
//   late Scale tempDefScaleInfo;

//   final ScrollController _horizontalScrollController = ScrollController();

//   GetScaleRecords currGetScaleRecords = GetScaleRecords(weightRecords: []);

//   //定时发送秤还活着
//   Timer? _cntAliveTimer;
//   bool _isCntAliveTiming = false;
//   bool get isCntAliveTiming => _isCntAliveTiming;

//   var _searchRawIdCtl = TextEditingController();
//   bool isExpaned = false;

//   bool _hasPassedZero = false; // 标记是否经过 0 点
//   Timer? _stableTimer; // 稳定状态计时器
//   int _currentStableDuration = 0; // 当前稳定状态持续时间

//   void startCntAliveTimer(int time) {
//     if (_cntAliveTimer != null) {
//       _cntAliveTimer!.cancel();
//     }

//     _isCntAliveTiming = true;
//     _cntAliveTimer = Timer(Duration(seconds: time), () {
//       PublicFunctions.sendScaleAlive(widget.scaleId); //只管串口
//       if (!isStart) {
//         PublicFunctions.getWeight(widget.scaleId);
//       }
//       startCntAliveTimer(10);
//     });
//   }

//   void stopCntAliveTimer() {
//     _cntAliveTimer?.cancel();
//     _isCntAliveTiming = false;
//   }

//   @override
//   void initState() {
//     super.initState();
//     onStartTimer();
//     startCntAliveTimer(10);
//     for (int i = 0; i < myAllScalesList.length; i++) {
//       if (myAllScalesList[i].scaleId == widget.scaleId) {
//         tempDefScaleInfo = myAllScalesList[i];
//       }
//     }

//     dateformat = 1;
//     zeroRange = 0;
//     sortColumnName = 'Id';
//     sortDirectValue = DataGridSortDirection.descending;
//     PublicFunctions.getUIConfNormal(widget.scaleId);
//     // tempDefScaleInfo = DefScaleInfo.getScaleInfoById(widget.scaleId);

//     if (myModeSettingNormal.recMode == msgManual) {
//       weightMode = cstManualSave;
//       _isSaveBtnEnable = true;
//     } else {
//       _isSaveBtnEnable = false;
//       weightMode = cstStableSave;
//     }
//     _isStableStatusJudge = false;

//     _weightReportDatas = getWeightReportData();
//     _weightReportDataSource =
//         WeightReportDataSource(_weightReportDatas, weighingMode);
//     _weightReportDataSource.loadPage(_currentPage, scaleId: widget.scaleId);

//     weightInfo = ReceiveWgtInfo(
//       weightVal: '---------',
//       weightUnit: '----',
//       isStable: false,
//       isZero: false,
//       isNet: false,
//     );
//     PublicFunctions.getProductList();

//     eventBus1 = eventBus.on<EventReqWeightCountine>().listen((event) {
//       tempWeight = event.obj;
//       if (tempWeight.scaleId == widget.scaleId &&
//           mounted &&
//           tempWeight.msgBody != null) {
//         setState(() {
//           isCnting = true;
//           isStart = true;
//           weightInfo = ReceiveWgtInfo(
//             weightVal: tempWeight.msgBody!.weightVal,
//             weightUnit: tempWeight.msgBody!.weightUnit,
//             isNet: tempWeight.msgBody!.isNet,
//             isStable: tempWeight.msgBody!.isStable,
//             isZero: tempWeight.msgBody!.isZero,
//           );
//           _checkStableStatus();
//         });
//       } else {}
//     });

//     eventBus2 = eventBus.on<EventProductRecList>().listen((event) {
//       if (mounted) {
//         setState(() {
//           List<PluInfoList> pluInfoList = event.obj;
//           for (int i = 0; i < pluInfoList.length; i++) {
//             PluData newPlu =
//                 PluData(0, 0, 0, 0, '', '', 0, 0, 0, 0, 0, 0, 0, '');
//             newPlu.recId = pluInfoList[i].recId;
//             newPlu.plu = int.tryParse(pluInfoList[i].plu) ?? 0;
//             newPlu.productCode = int.tryParse(pluInfoList[i].productCode) ?? 0;
//             newPlu.itemCode = int.tryParse(pluInfoList[i].itemCode) ?? 0;
//             newPlu.category = pluInfoList[i].category;
//             newPlu.productName = pluInfoList[i].productName;
//             newPlu.price = double.tryParse(pluInfoList[i].price) ?? 0;
//             newPlu.taxType = int.tryParse(pluInfoList[i].taxType) ?? 0;
//             newPlu.generalUnit = int.tryParse(pluInfoList[i].generalUnit) ?? 0;
//             newPlu.unitWeight = double.tryParse(pluInfoList[i].unitWeight) ?? 0;
//             newPlu.pretare = double.tryParse(pluInfoList[i].pretare) ?? 0;
//             newPlu.limitHigh = double.tryParse(pluInfoList[i].limitHigh) ?? 0;
//             newPlu.limitLow = double.tryParse(pluInfoList[i].limitLow) ?? 0;
//             newPlu.creatAt = pluInfoList[i].creatAt ?? " ";
//             myPluInfoList.add(newPlu);
//           }

//           // getProductNameList();
//           // getWeight();
//           // getRecords();
//         });
//       }
//     });

//     eventBus3 = eventBus.on<EventSettingParam>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myModeSettingNormal = event.obj;
//           weightMode = (myModeSettingNormal.recMode == msgManual)
//               ? cstManualSave
//               : (myModeSettingNormal.recMode == msgAuto)
//                   ? cstStableSave
//                   : cstManualSave;
//           dateformat = int.parse(myModeSettingNormal.dateFormat);
//           zeroRange = double.tryParse(myModeSettingNormal.zeroRange)!;
//           String timeString = (myModeSettingNormal.stableTime == "")
//               ? "0"
//               : myModeSettingNormal.stableTime.toString();
//           _stableSaveTime = int.parse(timeString);
//           if (weightMode == cstStableSave) {
//             _isSaveBtnEnable = false;
//           } else {
//             _isSaveBtnEnable = true;
//           }
//         });
//       }
//     });

//     eventBus4 = eventBus.on<EventGetScaleRecords>().listen((event) {
//       if (mounted) {
//         setState(() {
//           currGetScaleRecords = event.obj;
//           if (currGetScaleRecords.weightRecords!.isNotEmpty) {
//             DefScaleInfo tempScaleInfo =
//                 DefScaleInfo.getScaleInfoById(widget.scaleId);
//             if (currGetScaleRecords.weightRecords![0].scaleModel ==
//                     tempScaleInfo.defScaleModel &&
//                 currGetScaleRecords.weightRecords![0].scaleSn ==
//                     tempScaleInfo.defScaleSn) {
//               wgtRptDataList.clear();
//               _addDBdataToReport();
//               getWeightReportData();
//               if (firstGetRec) {
//                 int maxId =
//                     int.parse(currGetScaleRecords.weightRecords![0].id!);
//                 maxRecId = maxId;

//                 // 遍历 weightRecords 列表
//                 for (var record in currGetScaleRecords.weightRecords!) {
//                   int currentId = int.parse(record.id!);
//                   if (currentId > maxId) {
//                     maxId = currentId;
//                     maxRecId = maxId;
//                   }
//                 }
//               }
//             }
//           } else {
//             // wgtRptDataList.clear();
//             // updateTableData(getWeightReportData());
//           }
//         });
//       }
//     });

//     eventBus5 = eventBus.on<EventUpdateSettingParam>().listen((event) {
//       if (mounted) {
//         setState(() {
//           PublicFunctions.getUIConfNormal(widget.scaleId);
//         });
//       }
//     });

//     eventBus6 = eventBus.on<EventRegWeightResp>().listen((event) {
//       if (mounted) {
//         myRespDataFromScale = event.obj;
//         if (myRespDataFromScale.msgBody.contains(msgOk)) {
//           setState(() {
//             isStart = true;
//           });
//         } else {
//           setState(() {
//             isStart = false;
//           });
//         }
//       }
//     });

//     eventBus7 = eventBus.on<EventRevExportRecs>().listen((event) {
//       if (mounted) {
//         myRespDataFromScale = event.obj;
//         if (myRespDataFromScale.msgBody != "") {
//           if (mounted && context.mounted) {
//             // showConfirmationDialog(context, myRespDataFromScale.msgBody);
//           }
//         }
//       }
//     });

//     eventBus8 = eventBus.on<EventRevAddRec>().listen((event) {
//       if (mounted) {
//         _weightReportDataSource.sortDataGrid(
//           "Date Time",
//           DataGridSortDirection.descending,
//           scaleId: widget.scaleId,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     eventBus1.cancel();
//     eventBus2.cancel();
//     eventBus3.cancel();
//     eventBus4.cancel();
//     eventBus5.cancel();
//     eventBus6.cancel();
//     eventBus7.cancel();
//     eventBus8.cancel();
//     _horizontalScrollController.dispose();
//     _dataGridController.dispose();
//     _weightReportDataSource.dispose();
//     _searchRawIdCtl.dispose();

//     startTimer?.cancel();
//     innerTimer?.cancel();
//     _stableTimer?.cancel();

//     stopCntAliveTimer();
//     super.dispose();
//   }

//   //稳定保存逻辑

//   void _checkStableStatus() {
//     // 检查是否经过 0 点

//     // 判断是否为稳定保存模式且 _stableSaveTime 大于 0
//     if (weightMode == cstStableSave && _stableSaveTime > 0) {
//       // 检查是否经过 0 点
//       if (weightInfo!.isZero! && weightInfo!.isStable!) {
//         _hasPassedZero = true;
//       }
//       if (weightInfo!.isStable!) {
//         // 检查重量数据是否有效
//         final weightValue = double.tryParse(weightInfo!.weightVal!) ?? 0;
//         if (weightValue > 0 && _hasPassedZero) {
//           if (_stableTimer == null) {
//             _currentStableDuration = 0;
//             _stableTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//               _currentStableDuration++;
//               if (_currentStableDuration >= _stableSaveTime) {
//                 _stableTimer?.cancel();
//                 _stableTimer = null;
//                 _currentStableDuration = 0;
//                 _saveWeightData();
//               }
//             });
//           }
//         } else {
//           _resetStableTimer();
//         }
//       } else {
//         _resetStableTimer();
//       }
//     }
//   }

//   // 重置稳定状态计时器
//   void _resetStableTimer() {
//     _stableTimer?.cancel();
//     _stableTimer = null;
//     _currentStableDuration = 0;
//   }

//   // 保存重量数据
//   void _saveWeightData() {
//     if (_hasPassedZero && weightInfo!.isStable!) {
//       final weightValue = double.tryParse(weightInfo!.weightVal!) ?? 0;
//       if (weightValue > 0) {
//         _changeSaveButton();
//         _hasPassedZero = false; // 保存后重置经过 0 点标记
//       }
//     }
//   }

//   List<WeightReportData> getWeightReportData() {
//     return wgtRptDataList;
//   }

//   void updateTableData(List<WeightReportData> newReportData) {
//     _weightReportDataSource.updateData(newReportData);
//   }

//   void _addDBdataToReport() {
//     addDBdataToReport(wgtRptDataList, myModeSettingNormal, dateformat);
//     setState(() {
//       _weightReportDataSource =
//           WeightReportDataSource(_weightReportDatas, weighingMode);
//       Future.delayed(const Duration(milliseconds: 100), () {
//         _dataGridController
//             .scrollToRow(_weightReportDataSource.rows.length - 0);
//       });
//     });
//   }

//   void onStartTimer() {
//     startTimer = Timer.periodic(Duration(seconds: 3), (timer) {
//       isCnting = false; // 重置计时器状态
//       innerTimer = Timer(Duration(milliseconds: 1000), () {
//         if (!isCnting) {
//           isStart = false;
//           setState(() {
//             weightInfo = ReceiveWgtInfo(
//               weightVal: '---------',
//               weightUnit: '----',
//               isStable: false,
//               isZero: false,
//               isNet: false,
//             );
//           });
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: isExpaned ? 500 : 164,
//         color: Theme.of(context).colorScheme.surfaceDim,
//         child: Column(children: [
//           Container(
//             height: 150,
//             color: Theme.of(context).colorScheme.surface,
//             padding: const EdgeInsets.only(
//                 left: regularPadding, right: regularPadding),
//             child: Column(
//               children: [
//                 Container(
//                     height: 42,
//                     color: Theme.of(context).colorScheme.surface,
//                     alignment: Alignment.centerLeft,
//                     child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             widget.scaleName,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium!
//                                 .apply(
//                                   color:
//                                       Theme.of(context).colorScheme.onSurface,
//                                 ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           SizedBox(
//                               width: 28,
//                               child: FloatingActionButton.small(
//                                 onPressed: () {
//                                   setState(() {
//                                     isExpaned = !isExpaned;
//                                   });
//                                 },
//                                 backgroundColor: Theme.of(context)
//                                     .colorScheme
//                                     .primary, // 设置背景颜色为主题的主色（通常为蓝色）
//                                 foregroundColor: Colors.white, // 设置图标颜色为白色
//                                 shape: const CircleBorder(), // 确保按钮为圆形
//                                 child: Icon(isExpaned
//                                     ? Icons.keyboard_arrow_up_outlined
//                                     : Icons.keyboard_arrow_down_outlined),
//                               )),
//                         ])),
//                 Container(
//                   height: 1,
//                   color: Theme.of(context).colorScheme.surfaceContainerLow,
//                 ),
//                 Expanded(
//                   child: Container(
//                       color: Theme.of(context).colorScheme.surface,
//                       child: Row(
//                         children: [
//                           Expanded(
//                             flex: 2,
//                             child: LayoutBuilder(
//                               builder: (BuildContext context,
//                                   BoxConstraints constraints) {
//                                 // 获取可用宽度
//                                 double availableWidth = constraints.maxWidth;
//                                 return Center(
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceAround,
//                                     children: [
//                                       _buildIconAndText(
//                                         context,
//                                         localizedStrings.iStable,
//                                         weightInfo?.isStable,
//                                         availableWidth / 3.1,
//                                       ),
//                                       _buildIconAndText(
//                                         context,
//                                         localizedStrings.iTextNet,
//                                         weightInfo?.isNet,
//                                         availableWidth / 3.1,
//                                       ),
//                                       _buildIconAndText(
//                                         context,
//                                         localizedStrings.iTextZero,
//                                         weightInfo?.isZero,
//                                         availableWidth / 3.1,
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 Expanded(
//                                     child: Container(
//                                   alignment: Alignment.centerRight,
//                                   child: FittedBox(
//                                     fit: BoxFit.scaleDown, // 当文字溢出时缩小字体
//                                     alignment: Alignment.centerRight,
//                                     child: Text(
//                                         weightInfo?.weightVal ?? '---------',
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                         textAlign: TextAlign.right,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .headlineLarge!
//                                             .copyWith(
//                                               color: Theme.of(context)
//                                                   .colorScheme
//                                                   .onTertiaryFixedVariant,
//                                             )),
//                                   ),
//                                 )),
//                                 Container(
//                                   width: 80,
//                                   height: 80,
//                                   alignment: Alignment.bottomLeft,
//                                   child: Text(weightInfo?.weightUnit ?? '----',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyLarge!
//                                           .apply(
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface,
//                                           )),
//                                 )
//                               ],
//                             ),
//                           ),
//                           SizedBox(
//                               width: 240,
//                               child: Column(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       SizedBox(
//                                         width: 100,
//                                         child: showTextButton(
//                                             context,
//                                             36,
//                                             localizedStrings.gBtnTare,
//                                             isStart
//                                                 ? () {
//                                                     PublicFunctions
//                                                         .performTareWithScaleId(
//                                                             widget.scaleId);
//                                                   }
//                                                 : null,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .primary,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary),
//                                       ),
//                                       SizedBox(
//                                         width: 100,
//                                         child: showTextButton(
//                                             context,
//                                             36,
//                                             localizedStrings.iBtnZero,
//                                             isStart
//                                                 ? () {
//                                                     PublicFunctions
//                                                         .performZeroWithScaleId(
//                                                             widget.scaleId);
//                                                   }
//                                                 : null,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .primary,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary),
//                                       )
//                                     ],
//                                   ),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       Container(
//                                         constraints: BoxConstraints(
//                                             maxWidth: 200, minWidth: 100),
//                                         child: showTextButton(
//                                             context,
//                                             36,
//                                             localizedStrings.gBtnSave,
//                                             isStart && _isSaveBtnEnable
//                                                 ? () {
//                                                     _changeSaveButton();
//                                                   }
//                                                 : null,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .onTertiaryFixedVariant,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary),
//                                       )
//                                     ],
//                                   ),
//                                 ],
//                               )),
//                         ],
//                       )),
//                 ),
//                 Divider(
//                   height: 1,
//                   color: Theme.of(context).colorScheme.surfaceContainerLow,
//                 ),
//               ],
//             ),
//           ),
//           if (isExpaned)
//             Expanded(
//                 child: Container(
//               color: Theme.of(context).colorScheme.surface,
//               padding: const EdgeInsets.only(
//                   left: regularPadding, right: regularPadding),
//               child: Column(
//                 children: [
//                   Container(
//                     height: 56,
//                     padding: const EdgeInsets.only(
//                         top: smallPadding, bottom: smallPadding),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           width: 300,
//                           child: Container(
//                             height: 40,
//                             alignment: Alignment.centerLeft,
//                             child: Autocomplete<PluData>(
//                               fieldViewBuilder: (BuildContext context,
//                                   TextEditingController textEditingController,
//                                   FocusNode focusNode,
//                                   VoidCallback onFieldSubmitted) {
//                                 return TextField(
//                                   controller: textEditingController,
//                                   focusNode: focusNode,
//                                   onSubmitted: (String value) {
//                                     onFieldSubmitted();
//                                   },
//                                   maxLines: 1,
//                                   textAlignVertical: TextAlignVertical.top,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .onSurface,
//                                       ),
//                                   // 设置输入框的装饰
//                                   decoration: InputDecoration(
//                                     // 去掉下划线
//                                     border: OutlineInputBorder(
//                                       gapPadding: 2,
//                                       // 添加四周边框
//                                       borderRadius: BorderRadius.circular(0),
//                                       borderSide: BorderSide(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .outline,
//                                         width: 1,
//                                       ),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       // 聚焦时的边框样式
//                                       borderRadius: BorderRadius.circular(0),
//                                       borderSide: BorderSide(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .primary,
//                                         width: 1,
//                                       ),
//                                     ),
//                                     enabledBorder: OutlineInputBorder(
//                                       // 正常状态的边框样式
//                                       borderRadius: BorderRadius.circular(0),
//                                       borderSide: BorderSide(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .outlineVariant,
//                                         width: 1,
//                                       ),
//                                     ),
//                                     // 可以添加提示文本等其他装饰属性
//                                     hintText: localizedStrings.fSearchHint,
//                                     hintStyle: TextStyle(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .onSurfaceVariant,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.normal,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               optionsBuilder:
//                                   (TextEditingValue textEditingValue) {
//                                 if (textEditingValue.text == '') {
//                                   return const Iterable<PluData>.empty();
//                                 }
//                                 return myPluInfoList.where((PluData data) {
//                                   // 进行模糊查找，这里同时匹配productName和plu转成字符串后的内容
//                                   return data.productName!
//                                           .toLowerCase()
//                                           .contains(textEditingValue.text
//                                               .toLowerCase()) ||
//                                       data.plu
//                                           .toString()
//                                           .contains(textEditingValue.text);
//                                 }).toList()
//                                   ..sort((a, b) => a.plu!.compareTo(b.plu!));
//                               },
//                               onSelected: (PluData selection) {
//                                 setState(() {
//                                   selectedPluData = selection;
//                                 });
//                               },
//                               displayStringForOption: (PluData option) =>
//                                   '${option.plu}:${option.productName}',
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                             child: Container(
//                                 alignment: Alignment.center,
//                                 child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       showIconBtn(
//                                         localizedStrings.gBtnExport,
//                                         () {},
//                                         Theme.of(context).colorScheme.primary,
//                                         getSvgIcon(
//                                             exportSvgIcon(),
//                                             24,
//                                             24,
//                                             Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary),
//                                       ),
//                                       SizedBox(
//                                         width: regularPadding,
//                                       ),
//                                       showIconBtn(localizedStrings.gBtnSetting,
//                                           () {
//                                         reportFieldsSettingDialog(context);
//                                       },
//                                           Theme.of(context).colorScheme.primary,
//                                           Icon(
//                                             Icons.settings_outlined,
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary,
//                                           )),
//                                       SizedBox(
//                                         width: regularPadding,
//                                       ),
//                                       showIconBtn('设置参数', () {
//                                         paramSettingDialog(context);
//                                       },
//                                           Theme.of(context).colorScheme.primary,
//                                           getSvgIcon(
//                                               rptSettingSvgIcon(),
//                                               24,
//                                               24,
//                                               Theme.of(context)
//                                                   .colorScheme
//                                                   .onPrimary)),
//                                       SizedBox(
//                                         width: regularPadding,
//                                       ),
//                                       showIconBtn(localizedStrings.gBtnDelete,
//                                           () {
//                                         PublicFunctions.deleteAllRecordsById(
//                                             widget.scaleId);
//                                         maxRecId = 0;
//                                         _weightReportDatas.clear();
//                                         _weightReportDataSource
//                                             .updateData(_weightReportDatas);
//                                       },
//                                           Theme.of(context).colorScheme.error,
//                                           Icon(
//                                             Icons.delete_forever_outlined,
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary,
//                                           )),
//                                     ]))),
//                       ],
//                     ),
//                   ),
//                   Expanded(child: LayoutBuilder(
//                     builder: (BuildContext context, BoxConstraints builder) {
//                       final double width = builder.maxWidth; // 获取当前可用宽度
//                       double minWidth = width;
//                       if (getColumns().length * 120 > width) {
//                         minWidth = getColumns().length * 120;
//                       }
//                       return Container(
//                         child: Scrollbar(
//                           controller:
//                               _horizontalScrollController, // 将 ScrollController 传递给 Scrollbar
//                           thumbVisibility: true, // 始终显示滚动条
//                           trackVisibility: true, // 始终显示滚动条轨道
//                           interactive: true, // 允许用户直接与滚动条交互
//                           child: SingleChildScrollView(
//                             controller:
//                                 _horizontalScrollController, // 将 ScrollController 传递给 SingleChildScrollView
//                             scrollDirection: Axis.horizontal,
//                             child: SizedBox(
//                               width: minWidth,
//                               child: SfDataGrid(
//                                 source: _weightReportDataSource,
//                                 columns: getColumns().map((column) {
//                                   return GridColumn(
//                                     columnName: column.columnName,
//                                     label: GestureDetector(
//                                       // 将 GestureDetector 提升到最外层
//                                       onTap: () {
//                                         final currentSortDirection =
//                                             _weightReportDataSource
//                                                 .sortDirectionForColumn(
//                                                     column.columnName);
//                                         final newSortDirection =
//                                             currentSortDirection ==
//                                                     DataGridSortDirection
//                                                         .ascending
//                                                 ? DataGridSortDirection
//                                                     .descending
//                                                 : DataGridSortDirection
//                                                     .ascending;
//                                         _weightReportDataSource.sortDataGrid(
//                                           column.columnName,
//                                           newSortDirection,
//                                         );
//                                       },
//                                       child: MouseRegion(
//                                         cursor: SystemMouseCursors
//                                             .click, // 设置光标为手的形状
//                                         child: Container(
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .surfaceDim,
//                                           padding: EdgeInsets.all(2),
//                                           alignment: Alignment.center,
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Flexible(
//                                                 child: Text(
//                                                   myReportFeildsMap[
//                                                           column.columnName]!
//                                                       .showName,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.normal),
//                                                 ),
//                                               ),
//                                               _getSortIconForColumn(
//                                                   column.columnName),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 columnWidthMode: ColumnWidthMode.fill,
//                                 frozenRowsCount: 0,
//                                 // controller: null,
//                                 allowSorting: false,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   )),

//                   // 分页控件
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.arrow_back),
//                         onPressed: _currentPage > 1
//                             ? () {
//                                 setState(() {
//                                   _currentPage--;
//                                   _weightReportDataSource
//                                       .loadPage(_currentPage);
//                                 });
//                               }
//                             : null,
//                       ),
//                       Text('Page $_currentPage'),
//                       IconButton(
//                         icon: Icon(Icons.arrow_forward),
//                         onPressed: () {
//                           setState(() {
//                             _currentPage++;
//                             _weightReportDataSource.loadPage(_currentPage);
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             )),
//           Container(
//             height: regularPadding,
//             color: Theme.of(context).colorScheme.surfaceDim,
//           )
//         ]));
//   }

//   _changeSaveButton() {
//     setState(() {
//       _addWeightToReport();
//       sendReportDataToDB();
//     });
//   }

//   void sendReportDataToDB() {
//     sendRptDataToDB(wgtRptDataList, weighingMode);
//   }

//   void _addWeightToReport() {
//     PluData? tempPlu = PluData(null, null, null, null, null, null, null, null,
//         null, null, null, null, null, null);
//     if (selectedPluData != null) {
//       tempPlu = selectedPluData;
//     }

//     maxRecId++;
//     WeightReportData addData = WeightReportData(
//       (maxRecId).toString(),
//       tempDefScaleInfo.scaleModel,
//       tempDefScaleInfo.scaleSn,
//       (tempPlu!.plu == null) ? "" : tempPlu.plu.toString(),
//       (tempPlu.productCode == null) ? "" : tempPlu.productCode.toString(),

//       (tempPlu.itemCode == null) ? "" : tempPlu.itemCode.toString(),

//       (tempPlu.category == null) ? "" : tempPlu.category.toString(),

//       (tempPlu.productName == null) ? "" : tempPlu.productName.toString(),

//       (tempPlu.generalUnit == null) ? "" : tempPlu.generalUnit.toString(),

//       (tempPlu.taxType == null) ? "" : tempPlu.taxType.toString(),

//       (tempPlu.price == null) ? "" : tempPlu.price.toString(),

//       (tempPlu.unitWeight == null) ? "" : tempPlu.unitWeight.toString(),

//       (tempPlu.pretare == null) ? "" : tempPlu.pretare.toString(),

//       (tempPlu.limitHigh == null) ? "" : tempPlu.limitHigh.toString(),

//       (tempPlu.limitLow == null) ? "" : tempPlu.limitLow.toString(),

//       (weightInfo!.weightVal == '---------') ? (" ") : (weightInfo!.weightVal!),
//       (weightInfo?.weightUnit == '----') ? (" ") : (weightInfo!.weightUnit!),
//       (tmpUserInfo.id == null)
//           ? ""
//           : (tmpUserInfo.id.toString().contains("Please")
//               ? ""
//               : tmpUserInfo.id.toString()),
//       (tmpUserInfo.name == null)
//           ? ""
//           : (tmpUserInfo.name.toString().contains("Please")
//               ? ""
//               : tmpUserInfo.name.toString()),

//       tempDefScaleInfo.scaleName, //此处应该是秤机种名
//       getDateTime(myModeSettingNormal.dateSeparator, dateformat),
//     );
//     wgtRptDataList.add(addData);
//   }

//   void reportFieldsSettingDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // 允许点击空白处关闭对话框
//       builder: (context) {
//         return const ReportFeildsSettingDialog();
//       },
//     ).then((value) {
//       if (value) {
//         setState(() {
//           updateTableData(_weightReportDataSource.weightReportData);
//         });
//       }
//     });
//   }

//   void paramSettingDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // 允许点击空白处关闭对话框
//       builder: (context) {
//         return const ParamSettingDialog();
//       },
//     );
//   }

//   Widget _getSortIconForColumn(String columnName) {
//     if (!_weightReportDataSource.isColumnSorted(columnName)) {
//       return SizedBox.shrink();
//     }
//     final sortDirection =
//         _weightReportDataSource.sortDirectionForColumn(columnName);
//     switch (sortDirection) {
//       case DataGridSortDirection.ascending:
//         return Icon(
//           Icons.arrow_upward,
//           size: 18,
//         );
//       case DataGridSortDirection.descending:
//         return Icon(
//           Icons.arrow_downward,
//           size: 18,
//         );
//     }
//   }

//   Widget showIconBtn(
//       String message, Function()? onPressed, Color bkColor, Widget icon) {
//     return Tooltip(
//         message: message,
//         child: IconButton(
//           iconSize: 24,
//           hoverColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
//           style: IconButton.styleFrom(
//             backgroundColor: bkColor,
//             shape: RoundedRectangleBorder(
//               // 设置为矩形形状
//               borderRadius: BorderRadius.zero, // 没有圆角，即正方形
//             ),
//             fixedSize: const Size(40, 40), // 设置固定大小
//           ),
//           onPressed: onPressed,
//           icon: icon,
//         ));
//   }

//   Widget _buildIconAndText(
//       BuildContext context, String text, bool? isConditionMet, double width) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Align(
//             alignment: Alignment.bottomCenter,
//             child: Image.asset(
//               isConditionMet == null
//                   ? "assets/images/gray.png"
//                   : isConditionMet
//                       ? "assets/images/blue.png"
//                       : "assets/images/gray.png",
//               width: 24,
//               height: 24,
//             ),
//           ),
//         ),
//         Expanded(
//             child: Container(
//           width: width,
//           alignment: Alignment.center,
//           child: Text(
//             text,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.bodySmall!.apply(
//                   color: Theme.of(context).colorScheme.onSurface,
//                 ),
//           ),
//         )),
//       ],
//     );
//   }
// }
