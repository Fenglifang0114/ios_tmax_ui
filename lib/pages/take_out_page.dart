import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
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
import '../dialog/setting_dialog.dart';
import 'package:path/path.dart';

import '../dialog/showWarning.dart';
import '../dialog/weight_report_feilds_setting.dart';

class TakeOutPage extends StatefulWidget {
  const TakeOutPage({Key? key}) : super(key: key);
  @override
  State<TakeOutPage> createState() => TakeOutPageState();
}

class TakeOutPageState extends State<TakeOutPage> {
  String dialogString = " ";
  List<String> items = [];
  List<DataRow> dataRows = [];
  late ScrollController _reportScrollerController;
  late String lastWeight;
  bool isStart = false;
  String productNameValue = "";
  String userNameValue = "";
  String startWeightUnit = "";
  List<String> productNameList = [];
  List<String> userNameList = [];

  ///创建文本控制器实例
  final TextEditingController _errorText = TextEditingController();
  late int weightMode; //0,手动保存，1，连续保存，2，稳定保存
  late int dateformat;
  late double zeroRange;
  late bool _isSaveButtonDisabled;
  late Timer _saveTimer;
  late bool _isStableStatusJudge;
  int _stableSaveTime = 0;
  bool lastStableStatus = false;
  bool _isTiming = false;
  bool _isZero = false;
  bool _isPassZero = false;
  bool showDialogFlag = false;
  bool _isShowing = false;

  late bool _isTakeOutStart = false;
  double basicWeightval = 0.000; //开始加法秤的时候的基础重量
  String showTakeOutWeight = '';
  String diffWeightVal = '0.000'; //差值
  List<double> weightValueList = [];
  double lastTakeOutWeightval = 0.000;
  String takeOutWeightValue = '0.000';

  late WeightReportDataSource _weightReportDataSource;
  List<WeightReportData> _weightReportDatas = <WeightReportData>[];
  List<WeightReportData> myWeightReportData = [];
  final DataGridController _dataGridController = DataGridController();

  void updateTableData(List<WeightReportData> newReportData) {
    _weightReportDataSource.updateData(newReportData);
  }

  void _saveWeight(bool isStable) {
    if (_stableSaveTime == 0) {
      _isStableStatusJudge = true;
      _isTiming = false;
    }
    if (_isTakeOutStart) {
      _isPassZero = true;
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

  bool _isFirstLayout = true;

  void _toggleLayout() {
    setState(() {
      _isFirstLayout = !_isFirstLayout;
    });
  }

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
  dynamic eventBus14;

  @override
  void initState() {
    super.initState();
    _reportScrollerController = ScrollController();
    dataRows.clear();
    lastWeight = "*";
    dateformat = 1;
    zeroRange = 0;
    _errorText.text = '';
    if (myModeSettingTakeOut.recMode == "manual") {
      weightMode = 1;
      _isSaveButtonDisabled = false;
    } else {
      _isSaveButtonDisabled = true;
      weightMode = 2;
      String timeString = (myModeSettingTakeOut.stableTime == "")
          ? "0"
          : myModeSettingTakeOut.stableTime.toString();
      _stableSaveTime = int.parse(timeString);
      if (_stableSaveTime == 0) {
        _stableSaveTime = 1;
      }
    }

    _isStableStatusJudge = false;
    getProductNameList();
    _weightReportDatas = getWeightReportData();
    _weightReportDataSource = WeightReportDataSource(_weightReportDatas);
    PublicFunctions.getUserList();
    PublicFunctions.getProductList();
    if (myDevicedata.scaleID == "1") {
      PublicFunctions.getTakeOutRecords();
    }
    eventBus1 = eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
          // getWeight();
          // getRecords();
        });
      }
    });
    eventBus2 = eventBus.on<EventProductRecList>().listen((event) {
      if (mounted) {
        setState(() {
          myProductRecList = event.obj;
          getProductNameList();
          // getWeight();
          // getRecords();
        });
      }
    });

    eventBus3 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        setState(() {
          myReqWeightCountine = event.obj;
          isStart = true;
          if (_isTakeOutStart && !isSameUnit()) {
            showDialogFlag = true;
          } else {
            showDialogFlag = false;
            checkWeight();
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
          myModeSettingTakeOut = event.obj;
          weightMode = (myModeSettingTakeOut.recMode == "manual")
              ? 1
              : (myModeSettingTakeOut.recMode == "auto")
                  ? 2
                  : 1;
          dateformat = int.parse(myModeSettingTakeOut.dateFormat);
          zeroRange = double.tryParse(myModeSettingTakeOut.zeroRange)!;
          String timeString = (myModeSettingTakeOut.stableTime == "")
              ? "0"
              : myModeSettingTakeOut.stableTime.toString();
          _stableSaveTime = int.parse(timeString);
          if (weightMode == 1) {
            _isSaveButtonDisabled = false;
          } else {
            _isSaveButtonDisabled = true;
            if (_stableSaveTime == 0) {
              _stableSaveTime = 1;
            }
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
    eventBus10 = eventBus.on<EventGetScaleRecords>().listen((event) {
      if (mounted) {
        setState(() {
          myGetScaleRecords = event.obj;
          if (myGetScaleRecords.weightRecords!.length != 0) {
            _addDBdataToReport();
            getWeightReportData();
          } else {
            myWeightReportData.clear();
            updateTableData(getWeightReportData());
          }
        });
      }
    });
    eventBus11 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myUnregWeightResp = event.obj;
        if (myUnregWeightResp.msgBody.contains('ok')) {
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

    eventBus12 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myUnregWeightResp = event.obj;
        if (myUnregWeightResp.msgBody.contains('ok')) {
          setState(() {
            isStart = false;
          });
        }
      }
    });

    eventBus13 = eventBus.on<EventDeleteRec>().listen((event) {
      if (mounted) {
        setState(() {
          if (myDevicedata.scaleID == "1") {
            PublicFunctions.getTakeOutRecords();
          }
        });
      }
    });

    eventBus14 = eventBus.on<EventUpdateSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          PublicFunctions.getUIConfTakeOut();
        });
      }
    });
  }

  void takeOutModeWeight() {
    if (_isTakeOutStart && myReqWeightCountine.msgBody != null) {
      if (isWeightValue()) {
        showDiffWeightVal();
      } else {
        showTakeOutWeight = myReqWeightCountine.msgBody!.weightVal;
        takeOutWeightValue = myReqWeightCountine.msgBody!.weightVal;
      }
    }
  }

  bool isSameUnit() {
    if (!isWeightValue()) {
      return true;
    }
    if (startWeightUnit != myReqWeightCountine.msgBody!.weightUnit &&
        _isTakeOutStart) {
      return false;
    }
    return true;
  }

  void checkWeight() {
    switch (weightMode) {
      case 1:
        if (isZeroValue()) {
          _isZero = true;
          _isPassZero = true;
        } else {
          _isZero = false;
        }
        takeOutModeWeight();
        isWeightStable();
        break;
      case 2:
        if (!myReqWeightCountine.msgBody!.isStable) {
          _isStableStatusJudge = false;
        }
        if (isZeroValue()) {
          _isZero = true;
          _isPassZero = true;
        } else {
          _isZero = false;
        }
        _saveWeight(myReqWeightCountine.msgBody!.isStable);
        if (_isTakeOutStart && isWeightValue() && _isStableStatusJudge) {
          double? nowWeightVal =
              double.tryParse(myReqWeightCountine.msgBody!.weightVal);
          if ((basicWeightval - nowWeightVal!) - lastTakeOutWeightval > 0.02) {
            lastTakeOutWeightval = double.parse(
                (basicWeightval - nowWeightVal).toStringAsFixed(3));
            _isPassZero = true;
          } else {
            _isPassZero = false;
          }
          //如果是加法秤，不需要判断是否重新归零
        }
        if (myReqWeightCountine.msgBody!.isStable == true &&
            !_isZero &&
            _isPassZero &&
            _isStableStatusJudge) {
          {
            _isPassZero = false;
            _isTiming = false;
            _isStableStatusJudge = false;
            _addWeightToReport();
            sendReportDataToDB();
          }
          lastWeight = myReqWeightCountine.msgBody!.weightVal;
        }
        takeOutModeWeight();
        break;
      default:
        break;
    }
  }

  void _addDBdataToReport() {
    List<WeightRecords>? dbRecs = myGetScaleRecords.weightRecords;
    for (var i = 0; i < dbRecs!.length; i++) {
      myWeightReportData.add(WeightReportData(
        (dbRecs[i].recId).toString(),
        convertDateTime(
            dbRecs[i].createdAt!, myModeSettingTakeOut.dateSeparator),
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
    eventBus14.cancel();

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

  void handleOKPressed(bool isOKPressed) {
    // 根据用户点击 OK 的结果更新 _isShowing 值
    _isShowing = !isOKPressed;
  }

  Widget firstLayout(context, _width) {
    if (showDialogFlag) {
      if (!_isShowing) {
        _isShowing = true;
        showWarningDialog(context, handleOKPressed);
      }
    }
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
                              localizedStrings.take_out_title,
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
                      flex: 2,
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
                        flex: 1,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return buildWeightNameText(
                              50,
                              localizedStrings.show_current_weight,
                              constraints);
                        })),

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
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              buildWeightNameText(
                                  400,
                                  _isTakeOutStart
                                      ? localizedStrings.show_reduced_weight
                                      : '',
                                  constraints)
                            ],
                          );
                        })),
                    Expanded(
                        flex: 5,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _isTakeOutStart
                                  ? buildTextWithWeight(
                                      280,
                                      70,
                                      (takeOutWeightValue == '-0.000')
                                          ? '0.000'
                                          : isPcsTakeOutVal(),
                                      55,
                                      constraints,
                                      Theme.of(context).colorScheme.primary)
                                  : const SizedBox(),
                              buildTextWithNOUnit(
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
                    const Expanded(flex: 2, child: SizedBox()),
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
                      isTrue: (isStart && !_isTakeOutStart),
                    ),
                    _buildFlexibleButtonAndText(
                      width: 80,
                      buttonText: localizedStrings.button_zero,
                      onPressed: PublicFunctions.performZero,
                      constraints: constraints,
                      isTrue: (isStart && !_isTakeOutStart),
                    ),
                    _buildFlexibleButtonAndText(
                      width: 80,
                      buttonText: localizedStrings.button_save,
                      onPressed: _changeSaveButton,
                      constraints: constraints,
                      isTrue: (!_isSaveButtonDisabled && isStart),
                    ),
                    _buildStartButton(
                      width: 80,
                      buttonText: (myReqWeightCountine.msgBody == null)
                          ? 'Start'
                          : (_isTakeOutStart)
                              ? 'End'
                              : 'Start',
                      constraints: constraints,
                    ),
                    _buildFlexibleButtonAndText(
                      width: 80,
                      buttonText: localizedStrings.button_setting,
                      onPressed: () {
                        mySettingParam = myModeSettingTakeOut;
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
              flex: 1,
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ));
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
        PublicFunctions.deleteAllRecordsTakeOut();
      }
    });
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

  Widget buildWeightNameText(
      double width, String text, BoxConstraints constraints) {
    width = 25 * constraints.maxHeight / 30;
    var fontSize = 16 * constraints.maxHeight / 150;
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: fontSize),
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

  Widget buildTextWithNOUnit(double width, double height, String text,
      double? fontSize, BoxConstraints constraints, Color? color) {
    width = width * constraints.maxWidth / 400;
    height = height * constraints.maxHeight / 80;
    return SizedBox(
      width: width,
      height: height,
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

  Widget _buildStartButton({
    required double width,
    required String buttonText,
    required BoxConstraints constraints,
  }) {
    double buttonWidth = width * (constraints.maxWidth / 600); // 自适应按钮宽度
    double fontSize = 14 * (constraints.maxWidth / 600); // 自适应字体大小

    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: checkStartButton()
            ? () {
                if (_isTakeOutStart) {
                  _isTakeOutStart = false;
                  weightValueList.clear();
                  lastTakeOutWeightval = 0.000;
                } else {
                  if (isWeightValue()) {
                    basicWeightval = double.tryParse(
                        myReqWeightCountine.msgBody!.weightVal)!;
                    startWeightUnit = myReqWeightCountine.msgBody!.weightUnit;
                  }
                  lastTakeOutWeightval = 0.000;
                  _isTakeOutStart = true;
                  weightValueList.clear();
                }
              }
            : (_isTakeOutStart)
                ? () {
                    _isTakeOutStart = false;
                    weightValueList.clear();
                    lastTakeOutWeightval = 0.000;
                  }
                : null,
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

  Widget secondLayout(context, _width) {
    if (showDialogFlag) {
      if (!_isShowing) {
        _isShowing = true;
        showWarningDialog(context, handleOKPressed);
      }
    }
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
                              localizedStrings.take_out_title,
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
                          width: 240,
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
                                  myReqWeightCountine.msgBody = null;
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
                  _isTakeOutStart
                      ? Row(
                          children: [
                            Container(
                                width: 240,
                                height: 70,
                                color: Theme.of(context).colorScheme.primary,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        textAlign: TextAlign.right,
                                        (takeOutWeightValue == '-0.000')
                                            ? '0.000'
                                            : isPcsTakeOutVal(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 55),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10)
                                  ],
                                )),
                          ],
                        )
                      : const SizedBox(
                          width: 240,
                        ),
                  const SizedBox(width: 10),
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
                                    onPressed: (isStart && !_isTakeOutStart)
                                        ? () {
                                            PublicFunctions.performTare();
                                          }
                                        : null,
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
                                    onPressed: (isStart && !_isTakeOutStart)
                                        ? () {
                                            PublicFunctions.performZero();
                                          }
                                        : null,
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
                                        (!_isSaveButtonDisabled && isStart)
                                            ? _changeSaveButton
                                            : null,
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
                                    onPressed: checkStartButton()
                                        ? () {
                                            if (_isTakeOutStart) {
                                              _isTakeOutStart = false;
                                              weightValueList.clear();
                                              lastTakeOutWeightval = 0.000;
                                            } else {
                                              if (isWeightValue()) {
                                                basicWeightval =
                                                    double.tryParse(
                                                        myReqWeightCountine
                                                            .msgBody!
                                                            .weightVal)!;
                                                startWeightUnit =
                                                    myReqWeightCountine
                                                        .msgBody!.weightUnit;
                                              }
                                              lastTakeOutWeightval = 0.000;
                                              _isTakeOutStart = true;
                                              weightValueList.clear();
                                            }
                                          }
                                        : (_isTakeOutStart)
                                            ? () {
                                                _isTakeOutStart = false;
                                                weightValueList.clear();
                                                lastTakeOutWeightval = 0.000;
                                              }
                                            : null,
                                    child: Text(
                                        (myReqWeightCountine.msgBody == null)
                                            ? 'Start'
                                            : (_isTakeOutStart)
                                                ? 'End'
                                                : 'Start',
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
                                      //跳转页面
                                      mySettingParam = myModeSettingTakeOut;
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
                ],
              ),
            ),
            const SizedBox(height: 5),
            buttonRow(context),
            displayGrid(),
          ],
        ));
  }

  bool checkStartButton() {
    var res = false;
    if (!isStart || myReqWeightCountine.msgBody == null) {
      if (_isTakeOutStart) {
        _isTakeOutStart = false;
        weightValueList.clear();
        lastTakeOutWeightval = 0.000;
      }
      res = false;
    } else if ((myReqWeightCountine.msgBody != null) &&
        (myReqWeightCountine.msgBody!.isStable) &&
        isWeightValue()) {
      double nowWeightVal = double.parse(
          ((double.tryParse(myReqWeightCountine.msgBody!.weightVal)))!
              .toStringAsFixed(3));
      if (nowWeightVal > 0.02) {
        res = true;
      }
    }

    return res;
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

  Widget buttonRow(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.white,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: constraints.maxWidth / 10,
              child: Text(
                localizedStrings.plu_name,
                maxLines: 1,
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
                        myProductRecInfo = myProductRecList.productRecInfo![i];
                        eventBus.fire(EventProductRecInfo(myProductRecInfo));
                      }
                    }
                  });
                },

                items: productNameList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis));
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
                  child: Text(localizedStrings.plu_edit,
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
                          fontSize: 14, fontWeight: FontWeight.normal))),
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
                    for (var i = 0; i < myUserInfoList.userInfo!.length; i++) {
                      if (myUserInfo.name == myUserInfoList.userInfo![i].name) {
                        myUserInfo = myUserInfoList.userInfo![i];
                        eventBus.fire(EventUserInfo(myUserInfo));
                      }
                    }
                  });
                },
                items:
                    userNameList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis));
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
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal)),
                  onPressed: () {
                    reportFieldsSettingDialog(context);
                  }),
            ),
            MaterialButton(
                color: Theme.of(context).colorScheme.primary,
                textColor: Colors.white,
                elevation: 5.0,
                child: Text(localizedStrings.report_hide_btn,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.normal)),
                onPressed: () {
                  _toggleLayout();
                }),
            SizedBox(
              width: constraints.maxWidth / 10,
              child: MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                  elevation: 5.0,
                  child: Text(localizedStrings.report_delete_btn,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal)),
                  onPressed: () {
                    _showConfirmationDialog(context);
                  }),
            ),
          ],
        );
      }),
    );
  }

  Widget displayGrid() {
    return Expanded(
      child: SfDataGrid(
        source: _weightReportDataSource,
        columns: getColumns(),
        columnWidthMode: ColumnWidthMode.fill,
        frozenRowsCount: 0,
        controller: _dataGridController,
        allowSorting: true,
      ),
    );
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

  // void checkProductList() {
  //   if ((myProductRecList.productRecInfo == null)) {
  //     productNameList.add("Please select Plu");
  //     productNameValue = "Please select Plu";
  //   } else {
  //     getProductNameList();
  //     if (!productNameList.contains(productNameValue)) {
  //       productNameList.add("Please select Plu");
  //       productNameValue = productNameList[0];
  //     }
  //   }
  //   // getPortList();
  // }

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
    myAddScaleRecord.scaleMode = '3';
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

  bool isWeightValue() {
    if (myReqWeightCountine.msgBody == null) {
      return false;
    }
    if (!(myReqWeightCountine.msgBody!.weightVal.contains('--')) &&
        !(myReqWeightCountine.msgBody!.weightVal.contains('E')) &&
        !(myReqWeightCountine.msgBody!.weightVal.contains('UL')) &&
        !(myReqWeightCountine.msgBody!.weightVal.contains('OL')) &&
        !(myReqWeightCountine.msgBody!.weightVal.contains(':'))) {
      return true;
    }
    return false;
  }

  bool isZeroValue() {
    if (myReqWeightCountine.msgBody != null) {
      return false;
    }
    if (myReqWeightCountine.msgBody!.weightVal == "0" ||
        myReqWeightCountine.msgBody!.weightVal == "0.0" ||
        myReqWeightCountine.msgBody!.weightVal == "0.00" ||
        myReqWeightCountine.msgBody!.weightVal == "0.000" ||
        myReqWeightCountine.msgBody!.weightVal == "0.0000" ||
        myReqWeightCountine.msgBody!.weightVal == "0.00000") {
      return true;
    }
    return false;
  }

  void showDiffWeightVal() {
    double? nowWeightVal =
        double.tryParse(myReqWeightCountine.msgBody!.weightVal);
    nowWeightVal =
        double.parse((basicWeightval - nowWeightVal!).toStringAsFixed(3));
    if (weightValueList.isNotEmpty) {
      double tempDouble = nowWeightVal;
      for (var i = 0; i < weightValueList.length; i++) {
        tempDouble = tempDouble - weightValueList[i];
      }
      takeOutWeightValue = tempDouble.toStringAsFixed(3);
    } else {
      takeOutWeightValue = nowWeightVal.toStringAsFixed(3);
    }
    showTakeOutWeight = nowWeightVal.toStringAsFixed(3);
  }

  String isPcsTakeOutVal() {
    var takeInValue = '0.000';
    if (myReqWeightCountine.msgBody == null) {
      takeInValue = '0.000';
    } else if (myReqWeightCountine.msgBody!.weightUnit == 'PCS') {
      double? result = double.tryParse(takeOutWeightValue);

      if (result != null) {
        takeInValue = result.toStringAsFixed(0);
      } else {
        takeInValue = '0';
      }
    } else {
      takeInValue = takeOutWeightValue;
    }
    return takeInValue;
  }

  void _addWeightToReport() {
    diffWeightVal = '0.000';
    if (_isTakeOutStart) {
      if (isWeightValue()) {
        double? nowWeightVal =
            double.tryParse(myReqWeightCountine.msgBody!.weightVal);
        nowWeightVal =
            double.parse((basicWeightval - nowWeightVal!).toStringAsFixed(3));
        if (weightValueList.isNotEmpty) {
          double tempDouble = nowWeightVal;
          for (var i = 0; i < weightValueList.length; i++) {
            tempDouble = tempDouble - weightValueList[i];
          }

          if (myReqWeightCountine.msgBody!.weightUnit == 'PCS') {
            diffWeightVal = tempDouble.toStringAsFixed(0);
          } else {
            diffWeightVal = tempDouble.toStringAsFixed(3);
          }
          if (tempDouble > 0.02) {
            weightValueList.add(double.parse(tempDouble.toStringAsFixed(3)));
          }
        } else {
          if (myReqWeightCountine.msgBody!.weightUnit == 'PCS') {
            diffWeightVal = nowWeightVal.toStringAsFixed(0);
          } else {
            diffWeightVal = nowWeightVal.toStringAsFixed(3);
          }

          if (nowWeightVal > 0.02) {
            weightValueList.add(double.parse(nowWeightVal.toStringAsFixed(3)));
          }
        }
        showTakeOutWeight = nowWeightVal.toStringAsFixed(3);
        performAddToReport();
        takeOutWeightValue = "0.000";
      } else {
        showTakeOutWeight = myReqWeightCountine.msgBody!.weightVal;
      }
    } else {
      performAddToReport();
    }
  }

  void performAddToReport() {
    myWeightReportData.add(WeightReportData(
      (myWeightReportData.length + 1).toString(),
      getDateTime(myModeSettingTakeOut.dateSeparator),
      (_isTakeOutStart)
          ? diffWeightVal.toString()
          : (myReqWeightCountine.msgBody?.weightVal == null)
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
