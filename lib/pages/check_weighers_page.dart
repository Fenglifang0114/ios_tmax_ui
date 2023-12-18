import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/high_low_weight.dart';

import '../../data/currentport_data.dart';
import '../../data/device_data.dart';
import '../../data/productlist_data.dart';
import '../../data/report_data.dart';
import '../../data/reqweightdata_data.dart';
import '../../data/settingparam_data.dart';
import '../../data/userinfo_data.dart';
import '../../data/weight_data.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../data/downloadresponse.dart';
import '../data/record_data.dart';
import '../data/scalecmd_data.dart';
import '../data/weight_report_data.dart';
import '../dialog/addproduct_dialog.dart';
import '../dialog/adduser_dialog.dart';
import '../dialog/high_low_setting.dart';
import '../dialog/setting_dialog.dart';
import 'package:path/path.dart';
import '../dialog/weight_report_feilds_setting.dart';
import '../functions/weight_funcs.dart';

const String allMode = '1';
const String hiMode = '2';
const String okMode = '3';
const String lowMode = '4';

class CheckWeighersPage extends StatefulWidget {
  const CheckWeighersPage({Key? key}) : super(key: key);
  @override
  State<CheckWeighersPage> createState() => _CheckWeighersPageState();
}

class _CheckWeighersPageState extends State<CheckWeighersPage> {
  List<String> productNameList = [];
  List<String> userNameList = [];
  List<String> items = [];
  List<DataRow> dataRows = [];
  List<WeightReportData> _weightReportDatas = <WeightReportData>[];
  List<WeightReportData> myWeightReportData = [];

  late ScrollController _reportScrollerController;
  final TextEditingController _errorText = TextEditingController();
  late WeightReportDataSource _weightReportDataSource;
  final DataGridController _dataGridController = DataGridController();

  late String lastWeight;
  late double zeroRange;
  late bool _isSaveButtonDisabled;
  late bool _isStableStatusJudge;
  late int weightMode; //0,手动保存，1，连续保存，2，稳定保存
  late int dateformat;

  late Timer _saveTimer;

  String productNameValue = "";
  String userNameValue = "";
  bool isStart = false;
  bool lastStableStatus = false;
  bool _isTiming = false;
  bool _isZero = false;
  bool _isPassZero = false;
  bool _isLow = false;
  bool _isOK = false;
  bool _isHigh = false;
  bool _isFirstLayout = true;

  int _stableSaveTime = 0;

  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus5;
  dynamic eventBus6;
  dynamic eventBus7;
  dynamic eventBus8;
  dynamic eventBus9;
  dynamic eventBus10;
  dynamic eventBus11;
  dynamic eventBus12;
  dynamic eventBus13;

  void updateTableData(List<WeightReportData> newReportData) {
    _weightReportDataSource.updateData(newReportData);
  }

  void _saveWeight(bool isStable) {
    if (_stableSaveTime == 0) {
      _isStableStatusJudge = true;
      _isTiming = false;
    }
    if (_isPassZero) {
      if (isStable && _isTiming) {
      } else if (isStable && !_isTiming && !_isZero) {
        _isTiming = true;
        _performSaveTimer();
      } else if (!isStable && _isTiming) {
        _saveTimer.cancel();
        _isTiming = false;
      }
    }
  }

  _performSaveTimer() {
    if (_isTiming) {
      _saveTimer = Timer(Duration(seconds: _stableSaveTime), () async {
        _isStableStatusJudge = true;
      });
    }
  }

  _changeSaveButton() {
    setState(() {
      _isSaveButtonDisabled = false;
      _addWeightToReport();
      sendReportDataToDB();
    });
  }

  void _toggleLayout() {
    setState(() {
      _isFirstLayout = !_isFirstLayout;
    });
  }

  void isWeightStable() {
    bool res = false;
    if (myReqWeightCountine.msgBody == null) {
      res = false;
    } else if (myReqWeightCountine.msgBody!.isStable) {
      res = true;
    }
    setState(() {
      _isSaveButtonDisabled = !res;
    });
  }

  @override
  void initState() {
    super.initState();
    _reportScrollerController = ScrollController();
    dataRows.clear();
    lastWeight = "*";
    dateformat = 1;
    zeroRange = 0;
    _errorText.text = '';
    if (myModeSettingCheck.recMode == "manual") {
      weightMode = 1;
      _isSaveButtonDisabled = false;
    } else {
      _isSaveButtonDisabled = true;
      weightMode = 2;
    }
    String timeString = (myModeSettingCheck.stableTime == "")
        ? "0"
        : myModeSettingCheck.stableTime.toString();
    _stableSaveTime = int.parse(timeString);
    _isStableStatusJudge = false;
    getProductNameList();
    _weightReportDatas = getWeightReportData();
    _weightReportDataSource = WeightReportDataSource(_weightReportDatas);
    PublicFunctions.getUserList();
    PublicFunctions.getProductList();
    if (myDevicedata.scaleID == "1") {
      PublicFunctions.getCheckWeigherRecords();
    }
    eventBus1 = eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
        });
      }
    });
    eventBus2 = eventBus.on<EventProductRecList>().listen((event) {
      if (mounted) {
        setState(() {
          myProductRecList = event.obj;
          getProductNameList();
        });
      }
    });

    eventBus3 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        setState(() {
          myReqWeightCountine = event.obj;
          isStart = true;
          switch (weightMode) {
            case 1:
              if (PubWeightFuncs.weightIsZero()) {
                _isZero = true;
                _isPassZero = true;
              } else {
                _isZero = false;
              }
              isWeightStable();
              _isLow = false;
              _isOK = false;
              _isHigh = false;
              if (!_isZero) {
                var weight =
                    double.tryParse(myReqWeightCountine.msgBody!.weightVal);
                if (weight != null) {
                  if (weight > 0) {
                    if (weight < myHighLowWeight.lowValue) {
                      _isLow = true;
                    } else if (weight >= myHighLowWeight.lowValue &&
                        weight <= myHighLowWeight.highValue) {
                      _isOK = true;
                    } else if (weight > myHighLowWeight.highValue) {
                      _isHigh = true;
                    }
                  }
                }
              }

              break;
            case 2:
              if (PubWeightFuncs.weightIsZero()) {
                _isZero = true;
                _isPassZero = true;
              } else {
                _isZero = false;
              }
              _saveWeight(myReqWeightCountine.msgBody!.isStable);
              _isLow = false;
              _isOK = false;
              _isHigh = false;
              if (!_isZero) {
                var weight =
                    double.tryParse(myReqWeightCountine.msgBody!.weightVal);
                if (weight != null) {
                  if (weight > 0) {
                    if (weight < myHighLowWeight.lowValue) {
                      _isLow = true;
                    } else if (weight >= myHighLowWeight.lowValue &&
                        weight <= myHighLowWeight.highValue) {
                      _isOK = true;
                    } else if (weight > myHighLowWeight.highValue) {
                      _isHigh = true;
                    }
                  }
                }
              }

              if (myReqWeightCountine.msgBody!.isStable == true &&
                  !_isZero &&
                  _isPassZero &&
                  _isStableStatusJudge) {
                {
                  if (myModeSettingCheck.saveMode == hiMode && _isHigh) {
                    _isPassZero = false;
                    _isTiming = false;
                    _isStableStatusJudge = false;
                    _addWeightToReport();
                    sendReportDataToDB();
                  } else if (myModeSettingCheck.saveMode == okMode && _isOK) {
                    _isPassZero = false;
                    _isTiming = false;
                    _isStableStatusJudge = false;
                    _addWeightToReport();
                    sendReportDataToDB();
                  } else if (myModeSettingCheck.saveMode == lowMode && _isLow) {
                    _isPassZero = false;
                    _isTiming = false;
                    _isStableStatusJudge = false;
                    _addWeightToReport();
                    sendReportDataToDB();
                  } else if (myModeSettingCheck.saveMode == allMode) {
                    _isPassZero = false;
                    _isTiming = false;
                    _isStableStatusJudge = false;
                    _addWeightToReport();
                    sendReportDataToDB();
                  }
                }
                lastWeight = myReqWeightCountine.msgBody!.weightVal;
              }

              break;
            default:
          }
        });
      }
    });

    eventBus4 = eventBus.on<EventCurrentPort>().listen((event) {
      if (mounted) {
        setState(() {
          myCurrentPort = event.obj;
        });
      }
    });
    eventBus5 = eventBus.on<EventWtData>().listen((event) {
      if (mounted) {
        setState(() {
          myWtData = event.obj;
        });
      }
    });
    eventBus6 = eventBus.on<EventReportData>().listen((event) {
      if (mounted) {
        setState(() {
          myReportData = event.obj;
        });
      }
    });
    eventBus7 = eventBus.on<EventProductRecInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myProductRecInfo = event.obj;
          // checkProductList();
        });
      }
    });

    eventBus8 = eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          myModeSettingCheck = event.obj;
          weightMode = (myModeSettingCheck.recMode == "manual")
              ? 1
              : (myModeSettingCheck.recMode == "auto")
                  ? 2
                  : 1;
          dateformat = int.parse(myModeSettingCheck.dateFormat);
          zeroRange = double.tryParse(myModeSettingCheck.zeroRange)!;
          String timeString = (myModeSettingCheck.stableTime == "")
              ? "0"
              : myModeSettingCheck.stableTime.toString();
          _stableSaveTime = int.parse(timeString);
          if (weightMode == 1) {
            _isSaveButtonDisabled = false;
          } else {
            _isSaveButtonDisabled = true;
          }
        });
      }
    });
    eventBus9 = eventBus.on<EventUserInfoList>().listen((event) {
      if (mounted) {
        setState(() {
          myUserInfoList = event.obj;
          getUserNameList();
        });
      }
    });
    eventBus10.on<EventGetScaleRecords>().listen((event) {
      if (!mounted) {
        return;
      }
      setState(() {
        myGetScaleRecords = event.obj;
        final weightRecordsLength = myGetScaleRecords.weightRecords!.length;
        if (weightRecordsLength != 0) {
          _addDBdataToReport();
          getWeightReportData();
        } else {
          myWeightReportData.clear();
          updateTableData(getWeightReportData());
        }
      });
    });

    eventBus11 = eventBus.on<EventDeleteRec>().listen((event) {
      if (mounted) {
        setState(() {
          PublicFunctions.getCheckWeigherRecords();
        });
      }
    });

    eventBus12 = eventBus.on<EventUpdateSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          PublicFunctions.getUIConfCheck();
        });
      }
    });

    eventBus13 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRegWeightResp = event.obj;
        if (myRegWeightResp.msgBody.contains('ok')) {
          setState(() {
            isStart = true;
          });
        } else {
          setState(() {
            isStart = false;
          });
        }
      }
    });
  }

  void _addDBdataToReport() {
    List<WeightRecords>? dbRecs = myGetScaleRecords.weightRecords;
    for (var i = 0; i < dbRecs!.length; i++) {
      myWeightReportData.add(WeightReportData(
        (dbRecs[i].recId).toString(),
        convertDateTime(dbRecs[i].createdAt!, myModeSettingCheck.dateSeparator),
        (dbRecs[i].weight == null) ? '' : dbRecs[i].weight!,
        (dbRecs[i].weightUnit == null) ? '' : dbRecs[i].weightUnit!, //重量单位
        (myProductRecInfo.id == null) ? "" : myProductRecInfo.id.toString(),
        (dbRecs[i].product == null) ? '' : dbRecs[i].product!,
        (dbRecs[i].pluRemarks == null) ? '' : dbRecs[i].pluRemarks!,
        (dbRecs[i].pretare == null) ? '' : dbRecs[i].pretare!,
        (dbRecs[i].userName == null) ? '' : dbRecs[i].userName!,
        (dbRecs[i].userNo == null) ? '' : dbRecs[i].userNo!,
        (dbRecs[i].userRemarks == null)
            ? ''
            : dbRecs[i].userRemarks!, //userremarks
        (dbRecs[i].scaleModel == null) ? '' : dbRecs[i].scaleModel!,
      ));
    }
    setState(() {
      _weightReportDataSource = WeightReportDataSource(_weightReportDatas);
      Future.delayed(const Duration(milliseconds: 100), () {
        _dataGridController
            .scrollToRow(_weightReportDataSource.rows.length - 0);
      });
      // _dataGridController.scrollToRow(_weightReportDataSource.rows.length - 1);
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
    eventBus8.cancel();
    eventBus9.cancel();
    eventBus10.cancel();
    eventBus11.cancel();
    eventBus12.cancel();
    eventBus13.cancel();

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
      body: _isFirstLayout
          ? firstLayout(context, _width)
          : secondLayout(context, _width),
    );
  }

  Widget firstLayout(BuildContext context, double _width) {
    return Container(
        width: _width,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _width,
              height: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                      // width: _width,
                      height: 40,
                      margin: const EdgeInsets.only(left: 5, top: 2),
                      alignment: Alignment.center, //设置控件内容的位置
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 40,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                foregroundColor: Colors.blue,
                                backgroundColor: Colors.white, // 设置按钮的背景色
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(4), // 设置按钮的圆角
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.home,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    Text(
                                      localizedStrings.button_home,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () {
                                PublicFunctions.stopWeight();
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 400,
                            child: Text(
                              localizedStrings.checkweigher_title,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: Text(
                              _errorText.text, //报错信息
                              maxLines: 1,
                              style: TextStyle(
                                color: (_errorText.text).contains('succeed')
                                    ? Theme.of(context).colorScheme.outline
                                    : Theme.of(context).colorScheme.error,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
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
                    Expanded(
                        flex: 2,
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
                    _buildFlexibleButtonAndText(
                      width: 80,
                      buttonText: localizedStrings.button_tare,
                      onPressed: PublicFunctions.performTare,
                      constraints: constraints,
                      isTrue: true,
                    ),
                    _buildFlexibleButtonAndText(
                      width: 80,
                      buttonText: localizedStrings.button_zero,
                      onPressed: PublicFunctions.performZero,
                      constraints: constraints,
                      isTrue: true,
                    ),
                    _buildFlexibleButtonAndText(
                      width: 80,
                      buttonText: localizedStrings.button_save,
                      onPressed: _changeSaveButton,
                      constraints: constraints,
                      isTrue: !_isSaveButtonDisabled && isStart,
                    ),
                    _buildFlexibleButtonAndText(
                      width: 80,
                      buttonText: 'Edit',
                      onPressed: () {
                        highLowSettingDialog(context);
                      },
                      constraints: constraints,
                      isTrue: true,
                    ),
                    _buildFlexibleButtonAndText(
                      width: 80,
                      buttonText: localizedStrings.button_setting,
                      onPressed: () {
                        mySettingParam = myModeSettingCheck;
                        paramSettingDialog(context);
                      },
                      constraints: constraints,
                      isTrue: true,
                    ),
                    _buildFlexibleButtonAndText(
                      width: 80,
                      buttonText: localizedStrings.button_export_report,
                      onPressed: () async {
                        final directory = Directory.current.path;
                        String? outputFile =
                            (await FilePicker.platform.saveFile(
                          initialDirectory: directory,
                          type: FileType.custom,
                          dialogTitle: 'Output file:',
                          allowedExtensions: ["xlsx"],
                          fileName: 'report.xlsx',
                        ));
                        if (outputFile != null) {
                          _creatFile(outputFile);
                        }
                      },
                      constraints: constraints,
                      isTrue: true,
                    ),
                  ],
                );
              }),
            ),
            Expanded(
                flex: 1,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return Container(
                    color: Colors.white,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildTextString(
                              localizedStrings.plu_name, constraints, context),
                          Container(
                            child: DropdownButtonFormField<String>(
                              itemHeight: 50.0,
                              isExpanded: true,
                              // decoration: const InputDecoration(border: OutlineInputBorder()),
                              value: productNameValue,
                              onChanged: (String? newPosition) {
                                setState(() {
                                  productNameValue = newPosition.toString();
                                  for (var i = 0;
                                      i <
                                          myProductRecList
                                              .productRecInfo!.length;
                                      i++) {
                                    if (productNameValue ==
                                        myProductRecList
                                            .productRecInfo![i].product) {
                                      myProductRecInfo =
                                          myProductRecList.productRecInfo![i];
                                      eventBus.fire(EventProductRecInfo(
                                          myProductRecInfo));
                                    }
                                  }
                                });
                              },

                              items: productNameList
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        overflow: TextOverflow.ellipsis));
                              }).toList(),
                            ),
                            height: 53,
                            width: 150,
                            padding: const EdgeInsets.all(0),
                          ),
                          buildPluEditButton(
                              Theme.of(context).colorScheme.primary,
                              localizedStrings.plu_edit,
                              constraints,
                              context),
                          buildTextString(
                              localizedStrings.user_name, constraints, context),
                          Container(
                            child: DropdownButtonFormField<String>(
                              itemHeight: 50.0,
                              isExpanded: true,
                              // decoration: const InputDecoration(border: OutlineInputBorder()),
                              value: userNameValue,
                              onChanged: (String? newPosition) {
                                setState(() {
                                  myUserInfo.name = newPosition.toString();
                                  for (var i = 0;
                                      i < myUserInfoList.userInfo!.length;
                                      i++) {
                                    if (myUserInfo.name ==
                                        myUserInfoList.userInfo![i].name) {
                                      myUserInfo = myUserInfoList.userInfo![i];
                                      eventBus.fire(EventUserInfo(myUserInfo));
                                    }
                                  }
                                });
                              },
                              items: userNameList.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        overflow: TextOverflow.ellipsis));
                              }).toList(),
                            ),
                            height: 53,
                            width: 150,
                            padding: const EdgeInsets.all(0),
                          ),
                          buildUserEditButton(
                              Theme.of(context).colorScheme.primary,
                              localizedStrings.user_edit,
                              constraints,
                              context),
                          buildSetReportButton(
                              Theme.of(context).colorScheme.primary,
                              localizedStrings.report_set_btn,
                              constraints,
                              context),
                          buildButton(
                              Theme.of(context).colorScheme.primary,
                              localizedStrings.report_show_btn,
                              constraints,
                              _toggleLayout),
                          buildButton(
                              Theme.of(context).colorScheme.primary,
                              localizedStrings.report_delete_btn,
                              constraints,
                              () => _showConfirmationDialog(context)),
                        ]),
                  );
                })),
            Expanded(
              flex: 4,
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary,
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // 让Row内部的widget充满父容器的高度
                  children: [
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        ((myHighLowWeight.lowValue == 0) || (_isLow))
                            ? "assets/images/yellow.png"
                            : "assets/images/grey_circle.png",
                        fit: BoxFit.contain, // 根据需要调整填充方式
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        (((myHighLowWeight.lowValue == 0) &&
                                    (myHighLowWeight.highValue == 0)) ||
                                (_isOK))
                            ? "assets/images/green.png"
                            : "assets/images/grey_circle.png",
                        fit: BoxFit.contain, // 根据需要调整填充方式
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        ((myHighLowWeight.highValue == 0) || (_isHigh))
                            ? "assets/images/red.png"
                            : "assets/images/grey_circle.png",
                        fit: BoxFit.contain, // 根据需要调整填充方式
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
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

  _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.confirm_title,
            style: const TextStyle(color: Color.fromARGB(255, 15, 71, 161)),
          ),
          content: Text(localizedStrings.data_delete_confirm),
          actions: <Widget>[
            OutlinedButton(
              child: Text(localizedStrings.button_cancel),
              onPressed: () {
                Navigator.of(context).pop(false); // 不跳转
              },
            ),
            OutlinedButton(
              child: Text(localizedStrings.confirm_btn),
              onPressed: () {
                Navigator.of(context).pop(true); // 跳转
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        PublicFunctions.deleteAllRecordsCheck();
      }
    });
  }

  Widget buildPluEditButton(Color? color, String text,
      BoxConstraints constraints, BuildContext context) {
    var fontSize = 14 * constraints.maxHeight / 60;
    var width = constraints.maxWidth / 10;
    return SizedBox(
        width: width,
        child: MaterialButton(
            color: color,
            textColor: Colors.white,
            elevation: 5.0,
            child: Text(text,
                style: TextStyle(
                    fontSize: fontSize, fontWeight: FontWeight.normal)),
            onPressed: () {
              getProductList();
              addProductDialog(context).then((onvalue) {
                if (!productNameList.contains(productNameValue)) {
                  myProductRecInfo.product = "";
                  productNameValue = "";
                  myProductRecInfo.id = "";
                  myProductRecInfo.withPretare = false;
                  myProductRecInfo.remarks = "";
                }
              });
            }));
  }

  Widget buildUserEditButton(Color? color, String text,
      BoxConstraints constraints, BuildContext context) {
    var fontSize = 14 * constraints.maxHeight / 60;
    var width = constraints.maxWidth / 10;
    return SizedBox(
        width: width,
        child: MaterialButton(
            color: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
            elevation: 5.0,
            child: Text(text,
                style: TextStyle(
                    fontSize: fontSize, fontWeight: FontWeight.normal)),
            onPressed: () {
              PublicFunctions.getUserList();
              getUserNameList();
              if (!userNameList.contains(userNameValue)) {
                myUserInfo.name = "";
                userNameValue = "";
                myUserInfo.id = "";
                myUserInfo.isFemale = true;
                myUserInfo.phone = "";
                myUserInfo.remarks = "";
              }
              addUserDialog(context).then((onvalue) {
                setState(() {
                  PublicFunctions.getUserList();
                  getUserNameList();
                  if (!userNameList.contains(userNameValue)) {
                    myUserInfo.name = "";
                    userNameValue = "";
                    myUserInfo.id = "";
                    myUserInfo.isFemale = true;
                    myUserInfo.phone = "";
                    myUserInfo.remarks = "";
                  }
                });
              });
            }));
  }

  Widget buildSetReportButton(Color? color, String text,
      BoxConstraints constraints, BuildContext context) {
    var fontSize = 14 * constraints.maxHeight / 60;
    var width = constraints.maxWidth / 10;
    return SizedBox(
      width: width,
      child: MaterialButton(
          color: color,
          textColor: Colors.white,
          elevation: 5.0,
          child: Text(text,
              style:
                  TextStyle(fontSize: fontSize, fontWeight: FontWeight.normal)),
          onPressed: () {
            reportFieldsSettingDialog(context);
          }),
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

  Widget buildTextWithUnit(double width, double height, String text,
      double? fontSize, BoxConstraints constraints, Color? color) {
    width = width * constraints.maxWidth / 400;
    height = height * constraints.maxHeight / 80;
    fontSize = constraints.maxHeight / 3;
    if (fontSize > constraints.maxWidth / 11) {
      fontSize = constraints.maxWidth / 11;
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

  Widget _buildFlexibleButtonAndText({
    required double width,
    required String buttonText,
    required VoidCallback onPressed,
    required BoxConstraints constraints,
    required bool isTrue,
  }) {
    double buttonWidth = width * (constraints.maxWidth / 600); // 自适应按钮宽度
    double fontSize = 14 * (constraints.maxWidth / 600); // 自适应字体大小

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

  Widget secondLayout(BuildContext context, double _width) {
    return Container(
        width: _width,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _width,
              height: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                      // width: _width,
                      height: 40,
                      margin: const EdgeInsets.only(left: 5, top: 2),
                      alignment: Alignment.center, //设置控件内容的位置
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 40,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                foregroundColor: Colors.blue,
                                backgroundColor: Colors.white, // 设置按钮的背景色
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(4), // 设置按钮的圆角
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.home,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    Text(
                                      localizedStrings.button_home,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () {
                                PublicFunctions.stopWeight();
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 400,
                            child: Text(
                              localizedStrings.checkweigher_title,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: Text(
                              _errorText.text, //报错信息
                              maxLines: 1,
                              style: TextStyle(
                                color: (_errorText.text).contains('succeed')
                                    ? Theme.of(context).colorScheme.outline
                                    : Theme.of(context).colorScheme.error,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            //////////////////////////////////
            const SizedBox(height: 5),
            Container(
              height: 120,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const SizedBox(width: 20),
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              localizedStrings.stable,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            (myReqWeightCountine.msgBody == null)
                                ? ("assets/images/gray.png")
                                : (myReqWeightCountine.msgBody!.isStable &&
                                        isStart)
                                    ? ("assets/images/blue.png")
                                    : ("assets/images/gray.png"),
                            width: 25,
                            height: 25,
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              localizedStrings.net,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            (myReqWeightCountine.msgBody == null)
                                ? ("assets/images/gray.png")
                                : (myReqWeightCountine.msgBody!.isNet &&
                                        isStart)
                                    ? ("assets/images/blue.png")
                                    : ("assets/images/gray.png"),
                            width: 25,
                            height: 25,
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              localizedStrings.zero,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            (myReqWeightCountine.msgBody == null)
                                ? ("assets/images/gray.png")
                                : (myReqWeightCountine.msgBody!.isZero &&
                                        isStart)
                                    ? ("assets/images/blue.png")
                                    : ("assets/images/gray.png"),
                            width: 25,
                            height: 25,
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Container(
                          width: 300,
                          height: 70,
                          color: Theme.of(context).colorScheme.primary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.right,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("-----")
                                      : myReqWeightCountine.msgBody!.weightVal,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 55),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10)
                            ],
                          )),
                      const SizedBox(width: 5),
                      Container(
                        width: 100,
                        height: 70,
                        color: Theme.of(context).colorScheme.primary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text(
                              textAlign: TextAlign.center,
                              (myReqWeightCountine.msgBody == null)
                                  ? ("kg")
                                  : myReqWeightCountine.msgBody!.weightUnit,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                        //设置控件内容的位置
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 50,
                        child: IconButton(
                          //开始按钮
                          icon: const Icon(Icons.play_arrow),
                          iconSize: 30,
                          color: (isStart)
                              ? (Colors.grey)
                              : (Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              if (!isStart) {
                                if (MyApp.webchannel1.heartStatus == true) {
                                  isStart = true;
                                  PublicFunctions.getWeight();
                                }
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: IconButton(
                          onPressed: () {
                            if (isStart) {
                              setState(() {
                                if (MyApp.webchannel1.heartStatus == true) {
                                  isStart = false;
                                  PublicFunctions.stopWeight();
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.pause),
                          iconSize: 30,
                          color: (!isStart)
                              ? (Colors.grey)
                              : (Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth / 3.5,
                                child: ElevatedButton(
                                    onPressed: () {
                                      PublicFunctions.performTare();
                                    },
                                    child: Text(localizedStrings.button_tare,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal))),
                              ),
                              SizedBox(
                                width: constraints.maxWidth / 3.5,
                                child: ElevatedButton(
                                    onPressed: () {
                                      PublicFunctions.performZero();
                                    },
                                    child: Text(localizedStrings.button_zero,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal))),
                              ),
                              SizedBox(
                                width: constraints.maxWidth / 3.5,
                                child: ElevatedButton(
                                    onPressed:
                                        (_isSaveButtonDisabled || !isStart)
                                            ? null
                                            : _changeSaveButton,
                                    child: Text(localizedStrings.button_save,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal))),
                              ),
                            ],
                          );
                        }),
                        LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth / 3.5,
                                child: ElevatedButton(
                                    onPressed: () {
                                      highLowSettingDialog(context);
                                    },
                                    child: const Text('Edit',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal))),
                              ),
                              SizedBox(
                                width: constraints.maxWidth / 3.5,
                                child: ElevatedButton(
                                    onPressed: () {
                                      //跳转页面
                                      mySettingParam = myModeSettingCheck;
                                      paramSettingDialog(context);
                                    },
                                    child: Text(localizedStrings.button_setting,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal))),
                              ),
                              SizedBox(
                                width: constraints.maxWidth / 3.5,
                                child: ElevatedButton(
                                    // elevation: 5.0,
                                    child: Text(
                                        localizedStrings.button_export_report,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal)),
                                    onPressed: () async {
                                      final directory = Directory.current.path;
                                      String? outputFile =
                                          (await FilePicker.platform.saveFile(
                                        initialDirectory: directory,
                                        type: FileType.custom,
                                        dialogTitle: 'Output file:',
                                        allowedExtensions: ["xlsx"],
                                        fileName: 'report.xlsx',
                                      ));
                                      if (outputFile != null) {
                                        _creatFile(outputFile);
                                      }
                                    }),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  // const SizedBox(width: 10),
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Image.asset(
                            ((myHighLowWeight.lowValue == 0) || (_isLow))
                                ? "assets/images/yellow.png"
                                : "assets/images/grey_circle.png",
                            width: 60,
                            height: 60,
                          ),
                          Image.asset(
                            (((myHighLowWeight.lowValue == 0) &&
                                        (myHighLowWeight.highValue == 0)) ||
                                    (_isOK))
                                ? "assets/images/green.png"
                                : "assets/images/grey_circle.png",
                            width: 60,
                            height: 60,
                          ),
                          Image.asset(
                            ((myHighLowWeight.highValue == 0) || (_isHigh))
                                ? "assets/images/red.png"
                                : "assets/images/grey_circle.png",
                            width: 60,
                            height: 60,
                          )
                        ],
                      ),
                    ],
                  ),

                  // const SizedBox(width: 20),
                  // OutlinedButton(
                  //     onPressed: () {
                  //       fieldModifyDialog(context).then((onValue) {});
                  //     },
                  //     child: const Text("设置报表字段")),
                ],
              ),
            ),
            //////////////
            const SizedBox(height: 5),
            SizedBox(
              height: 40,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth / 10,
                      child: Text(
                        localizedStrings.plu_name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      child: DropdownButtonFormField<String>(
                        itemHeight: 50.0,
                        isExpanded: true,
                        // decoration: const InputDecoration(border: OutlineInputBorder()),
                        value: productNameValue,
                        onChanged: (String? newPosition) {
                          setState(() {
                            productNameValue = newPosition.toString();
                            for (var i = 0;
                                i < myProductRecList.productRecInfo!.length;
                                i++) {
                              if (productNameValue ==
                                  myProductRecList.productRecInfo![i].product) {
                                myProductRecInfo =
                                    myProductRecList.productRecInfo![i];
                                eventBus.fire(
                                    EventProductRecInfo(myProductRecInfo));
                              }
                            }
                          });
                        },

                        items: productNameList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                              value: value,
                              child:
                                  Text(value, overflow: TextOverflow.ellipsis));
                        }).toList(),
                      ),
                      height: 40,
                      width: constraints.maxWidth / 10,
                      padding: const EdgeInsets.all(0),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 10,
                      child: MaterialButton(
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                          elevation: 5.0,
                          child: Text(localizedStrings.plu_edit,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                          onPressed: () {
                            getProductList();
                            addProductDialog(context).then((onvalue) {
                              if (!productNameList.contains(productNameValue)) {
                                myProductRecInfo.product = "";
                                productNameValue = "";
                                myProductRecInfo.id = "";
                                myProductRecInfo.withPretare = false;
                                myProductRecInfo.remarks = "";
                              }
                            });
                          }),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 10,
                      child: TextButton(
                          onPressed: () {},
                          child: Text(localizedStrings.user_name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal))),
                    ),
                    Container(
                      child: DropdownButtonFormField<String>(
                        itemHeight: 50.0,
                        isExpanded: true,
                        // decoration: const InputDecoration(border: OutlineInputBorder()),
                        value: userNameValue,
                        onChanged: (String? newPosition) {
                          setState(() {
                            myUserInfo.name = newPosition.toString();
                            for (var i = 0;
                                i < myUserInfoList.userInfo!.length;
                                i++) {
                              if (myUserInfo.name ==
                                  myUserInfoList.userInfo![i].name) {
                                myUserInfo = myUserInfoList.userInfo![i];
                                eventBus.fire(EventUserInfo(myUserInfo));
                              }
                            }
                          });
                        },
                        items: userNameList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                              value: value,
                              child:
                                  Text(value, overflow: TextOverflow.ellipsis));
                        }).toList(),
                      ),
                      height: 53,
                      width: constraints.maxWidth / 10,
                      padding: const EdgeInsets.all(0),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 10,
                      child: MaterialButton(
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                          elevation: 5.0,
                          child: Text(localizedStrings.user_edit,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                          onPressed: () {
                            PublicFunctions.getUserList();
                            getUserNameList();
                            if (!userNameList.contains(userNameValue)) {
                              myUserInfo.name = "";
                              userNameValue = "";
                              myUserInfo.id = "";
                              myUserInfo.isFemale = true;
                              myUserInfo.phone = "";
                              myUserInfo.remarks = "";
                            }
                            addUserDialog(context).then((onvalue) {
                              setState(() {
                                PublicFunctions.getUserList();
                                getUserNameList();
                                if (!userNameList.contains(userNameValue)) {
                                  myUserInfo.name = "";
                                  userNameValue = "";
                                  myUserInfo.id = "";
                                  myUserInfo.isFemale = true;
                                  myUserInfo.phone = "";
                                  myUserInfo.remarks = "";
                                }
                              });
                            });
                          }),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 10,
                      child: MaterialButton(
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                          elevation: 5.0,
                          child: Text(localizedStrings.report_set_btn,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                          onPressed: () {
                            reportFieldsSettingDialog(context);
                          }),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 10,
                      child: MaterialButton(
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                          elevation: 5.0,
                          child: Text(localizedStrings.report_hide_btn,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                          onPressed: () {
                            _toggleLayout();
                          }),
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 10,
                      child: MaterialButton(
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                          elevation: 5.0,
                          child: Text(localizedStrings.report_delete_btn,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                          onPressed: () {
                            _showConfirmationDialog(context);
                          }),
                    ),
                  ],
                );
              }),
            ),

            Expanded(
              child: SfDataGrid(
                source: _weightReportDataSource,
                columns: getColumns(),
                columnWidthMode: ColumnWidthMode.fill,
                frozenRowsCount: 0,
                controller: _dataGridController,
                allowSorting: true,
              ),
            )
          ],
        ));
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

  void highLowSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const HighLowSettingDialog();
      },
    );
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
        setState(() {
          updateTableData(_weightReportDataSource.weightReportData);
        });
      }
    });
  }

  void getProductNameList() {
    if (myProductRecList.productRecInfo == null ||
        myProductRecList.productRecInfo!.isEmpty) {
      productNameList.clear();
      productNameValue = '';
      productNameList.add("Please select Plu");
      productNameValue = "Please select Plu";
      myProductRecInfo = ProductRecInfo();
    } else if (myProductRecList.productRecInfo!.isNotEmpty) {
      String? name;
      String? id;
      productNameList.clear();
      for (var i = 0; i < myProductRecList.productRecInfo!.length; i++) {
        name = myProductRecList.productRecInfo![i].product;
        id = myProductRecList.productRecInfo![i].id;
        name ??= "";
        id ??= "";
        productNameList.add(name);
      }
      if (!productNameList.contains(productNameValue)) {
        productNameValue = productNameList[0];
        myProductRecInfo = myProductRecList.productRecInfo![0];
        eventBus.fire(EventProductRecInfo(myProductRecInfo));
      } else {
        for (var i = 0; i < myProductRecList.productRecInfo!.length; i++) {
          if (productNameValue == myProductRecList.productRecInfo![i].product) {
            myProductRecInfo = myProductRecList.productRecInfo![i];
            eventBus.fire(EventProductRecInfo(myProductRecInfo));
          }
        }
      }
    }
  }

  void getUserNameList() {
    if (myUserInfoList.userInfo == null || myUserInfoList.userInfo!.isEmpty) {
      userNameList.clear();
      userNameValue = "";
      userNameList.add("Please select User");
      userNameValue = "Please select User";
      myUserInfo = UserInfo();
    } else if (myUserInfoList.userInfo!.isNotEmpty) {
      String? name;
      userNameList.clear();
      for (var i = 0; i < myUserInfoList.userInfo!.length; i++) {
        name = myUserInfoList.userInfo![i].name;
        name ??= "";
        userNameList.add(name);
      }
      if (!userNameList.contains(userNameValue)) {
        userNameValue = userNameList[0];

        myUserInfo = myUserInfoList.userInfo![0];
        eventBus.fire(EventUserInfo(myUserInfo));
      } else {
        for (var i = 0; i < myUserInfoList.userInfo!.length; i++) {
          if (userNameValue == myUserInfoList.userInfo![i].name) {
            myUserInfo = myUserInfoList.userInfo![i];
            eventBus.fire(EventUserInfo(myUserInfo));
          }
        }
      }
    } else {
      userNameList.clear();
      userNameValue = "";
    }
  }

  String pad0(int num) {
    if (num < 10) {
      return '0${num.toString()}';
    }
    return num.toString();
  }

  String convertDateTime(String timestamp, String dateSeparator) {
    // 1 yymmdd   2 ddmmyy 3 mmddyy
    if (timestamp.length < 30) {
      return '';
    }

    timestamp = removeFractionalSeconds(timestamp);
    DateTime currTime = DateTime.parse(timestamp).toLocal();
    String format = '';
    if (dateformat == 1) {
      format =
          "${currTime.year}$dateSeparator${pad0(currTime.month)}$dateSeparator${pad0(currTime.day)} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
    } else if (dateformat == 2) {
      format =
          "${pad0(currTime.day)}$dateSeparator${pad0(currTime.month)}$dateSeparator${currTime.year} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
    } else if (dateformat == 3) {
      format =
          "${pad0(currTime.month)}$dateSeparator${pad0(currTime.day)}$dateSeparator${currTime.year} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
    }
    return format;
  }

  String removeFractionalSeconds(String timestamp) {
    int dotIndex = timestamp.indexOf('.');
    int plusIndex = timestamp.indexOf('+');
    String prefix = timestamp.substring(0, dotIndex);
    String suffix = timestamp.substring(plusIndex);
    String newTimestamp = prefix + suffix;
    return newTimestamp;
  }

  String getDateTime(String dateSeparator) {
    // 1 yymmdd   2 ddmmyy 3 mmddyy
    var currTime = DateTime.now();
    String format = '';
    if (dateformat == 1) {
      format =
          "${currTime.year}$dateSeparator${pad0(currTime.month)}$dateSeparator${pad0(currTime.day)} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
    } else if (dateformat == 2) {
      format =
          "${pad0(currTime.day)}$dateSeparator${pad0(currTime.month)}$dateSeparator${currTime.year} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
    } else if (dateformat == 3) {
      format =
          "${pad0(currTime.month)}$dateSeparator${pad0(currTime.day)}$dateSeparator${currTime.year} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
    }
    return format;
  }

  _creatFile(String path) {
    List<String> title = [];
    title.add('RecId');
    title.addAll(myReportFields.filedsList);

    Excel excel = Excel.createExcel();
    Sheet sh = excel['Sheet1'];
    for (var i = 0; i < title.length; i++) {
      sh.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i)).value =
          title[i];
    }

    for (int row = 1; row <= myWeightReportData.length; row++) {
      for (int col = 0; col < title.length; col++) {
        switch (title[col]) {
          case 'RecId':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].id;
            break;
          case 'Date Time':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].dateTime;
            break;
          case 'Weight':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].weight;
            break;
          case 'Weight Unit':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].weightUnit;
            break;
          case 'PLU NO.':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].plu;
            break;
          case 'PLU Name':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].pluName;
            break;
          case 'PLU Remarks':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].pluRemarks;
            break;
          case 'Pretare':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].pretare;
            break;
          case 'User Name':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].userName;
            break;
          case 'User Remarks':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].userRemarks;
            break;
          case 'User NO.':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].userNo;
            break;
          case 'Scale Name':
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].scaleName;
            break;

          default:
        }

        //'value ${row}_$col';
      }
    }

    try {
      var onValue = excel.encode();
      File(join(path))
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue!);
      setState(() {
        _errorText.text = "Excel save succeed!";
      });
    } catch (ex) {
      setState(() {
        _errorText.text = "Excel save fail!";
      });
    }
  }

// "ReqData":"{\"ScaleId\": 2, \"Product\": \"Apple\", \"Weight\": \"1.230\", \"Price\": \"3.25\"}"}
  void sendReportDataToDB() {
    var currentData = myWeightReportData[myWeightReportData.length - 1];
    myScaleCmd.cmdMode = "add_rec";
    myAddScaleRecord.scaleId = 1;
    myAddScaleRecord.price = '0.0';
    myAddScaleRecord.scaleMode = '1';
    myAddScaleRecord.product = currentData.pluName;
    myAddScaleRecord.weight = currentData.weight.toString();
    myAddScaleRecord.pluNo = currentData.plu;
    myAddScaleRecord.pluRemarks = currentData.pluRemarks;
    myAddScaleRecord.weightUnit = currentData.weightUnit;
    myAddScaleRecord.pretare = currentData.pretare;
    myAddScaleRecord.userNo = currentData.userNo;
    myAddScaleRecord.userName = currentData.userName;
    myAddScaleRecord.userRemarks = currentData.userRemarks;
    myScaleCmd.cmdData = jsonEncode(myAddScaleRecord);
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  void _addWeightToReport() {
    myWeightReportData.add(WeightReportData(
      (myWeightReportData.length + 1).toString(),
      getDateTime(myModeSettingCheck.dateSeparator),
      (myReqWeightCountine.msgBody?.weightVal == null)
          ? (" ")
          : (myReqWeightCountine.msgBody!.weightVal),
      (myReqWeightCountine.msgBody?.weightUnit == null)
          ? (" ")
          : (myReqWeightCountine.msgBody!.weightUnit),
      (myProductRecInfo.id == null) ? "" : myProductRecInfo.id.toString(),
      (myProductRecInfo.product == null)
          ? ""
          : (myProductRecInfo.product.toString().contains("Please"))
              ? ""
              : myProductRecInfo.product.toString(),
      (myProductRecInfo.remarks == null)
          ? ""
          : myProductRecInfo.remarks.toString(),
      (myProductRecInfo.pretare == null)
          ? ""
          : myProductRecInfo.pretare.toString(),
      (myUserInfo.name == null)
          ? ""
          : (myUserInfo.name.toString().contains("Please")
              ? ""
              : myUserInfo.name.toString()),
      (myUserInfo.id == null)
          ? ""
          : (myUserInfo.id.toString().contains("Please")
              ? ""
              : myUserInfo.id.toString()),
      (myUserInfo.remarks == null) ? "" : myUserInfo.remarks.toString(),
      myDevicedata.name,
    ));

    _weightReportDatas = myWeightReportData;
    setState(() {
      String sortColName = 'Date Time';
      DataGridSortDirection sortDirec = DataGridSortDirection.descending;
      if (_weightReportDataSource.sortedColumns.isNotEmpty) {
        sortColName = _weightReportDataSource.sortedColumns[0].name;
        sortDirec = _weightReportDataSource.sortedColumns[0].sortDirection;
      }
      _weightReportDataSource = WeightReportDataSource(_weightReportDatas);
      _weightReportDataSource.sortedColumns
          .add(SortColumnDetails(name: sortColName, sortDirection: sortDirec));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (sortDirec == DataGridSortDirection.descending) {
          _dataGridController.scrollToRow(0);
        } else {
          _dataGridController
              .scrollToRow(_weightReportDataSource.rows.length - 0);
        }
      });
    });
  }

  List<WeightReportData> getWeightReportData() {
    return myWeightReportData;
  }
}

List<GridColumn> getColumns() {
  List<GridColumn> columns = [];
  List<String> columnNames = myReportFields.filedsList;
  columns.add(GridColumn(
      columnName: 'NO',
      label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.center,
          child: const Text(
            'NO',
            overflow: TextOverflow.ellipsis,
          ))));

  for (String columnName in columnNames) {
    columns.add(
      GridColumn(
        columnName: columnName,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.center,
          child: Text(
            columnName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        allowSorting: true,
      ),
    );
  }
  return columns;
}

class WeightReportDataSource extends DataGridSource {
  List<WeightReportData> weightReportData;
  WeightReportDataSource(this.weightReportData) {
    buildDataGridRow();
  }
  void updateData(List<WeightReportData> newReportData) {
    weightReportData = newReportData;
    buildDataGridRow();
    notifyListeners();
  }

  void sortData(String columnName) {
    weightReportData.sort((WeightReportData a, WeightReportData b) {
      if (columnName == 'Date Time') {
        return a.dateTime.compareTo(b.dateTime);
      }
      // 如果有其他需要比较的字段，请在这里添加适当的逻辑
      return 0;
    });
  }

  void sortDataGrid(String columnName, DataGridSortDirection sortDirection) {
    sortData(columnName);
    if (sortDirection == DataGridSortDirection.descending) {
      reverseData();
    }
  }

  void reverseData() {
    weightReportData = weightReportData.reversed.toList();
  }

  List<DataGridRow> dataGridRow = <DataGridRow>[];
  void buildDataGridRow() {
    List<GridColumn> columns = getColumns();
    dataGridRow = weightReportData.map<DataGridRow>((reportData) {
      List<DataGridCell<dynamic>> cells = [];
      for (GridColumn column in columns) {
        String columnName = column.columnName;
        cells.add(DataGridCell<String>(
          columnName: columnName,
          value: getValueForColumn(reportData, columnName),
        ));
      }
      return DataGridRow(cells: cells);
    }).toList();
  }

  // 根据列名获取对应的数据
  dynamic getValueForColumn(WeightReportData reportData, String columnName) {
    switch (columnName) {
      case 'NO':
        return reportData.id;
      case 'Date Time':
        return reportData.dateTime;
      case 'Weight':
        return reportData.weight;
      case 'Weight Unit':
        return reportData.weightUnit;
      case 'PLU NO.':
        return reportData.plu;
      case 'PLU Name':
        return reportData.pluName;
      case 'PLU Remarks':
        return reportData.pluRemarks;
      case 'Pretare':
        return reportData.pretare;
      case 'User NO.':
        return reportData.userNo;
      case 'User Name':
        return reportData.userName;
      case 'User Remarks':
        return reportData.userRemarks;
      case 'Scale Name':
        return reportData.scaleName;
      // 其他属性的处理类似
      default:
        return '';
    }
  }

  @override
  List<DataGridRow> get rows => dataGridRow.isEmpty ? [] : dataGridRow;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(dataGridCell.value.toString()),
      );
    }).toList());
  }
}
