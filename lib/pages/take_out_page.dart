import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../data/device_data.dart';
import '../../data/report_data.dart';
import '../../data/reqweightdata_data.dart';
import '../../data/settingparam_data.dart';
import '../../data/userinfo_data.dart';
import '../../data/weight_data.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/comscaleinfo_data.dart';
import '../data/const_var_data.dart';
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import '../data/language.dart';
import '../data/plu_data_source.dart';
import '../data/plu_info_list_data.dart';
import '../data/productlist_data.dart';
import '../data/record_data.dart';
import '../data/scale_list_data.dart';
import '../data/scalelist_data.dart';
import '../data/timer_manager.dart';
import '../data/weight_report_data.dart';
import '../data/weight_rpt.dart';
import '../data/wgt_rpt_data_source.dart';
import '../dialog/conform_dialog.dart';
import '../dialog/setting_dialog.dart';
import '../dialog/show_warning.dart';
import '../dialog/weight_report_feilds_setting.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class TakeOutPage extends StatefulWidget {
  const TakeOutPage({super.key});
  @override
  State<TakeOutPage> createState() => TakeOutPageState();
}

class TakeOutPageState extends State<TakeOutPage> {
  String dialogString = " ";
  List<String> items = [];
  late ScrollController _reportScrollerController;
  late String lastWeight;
  bool isStart = false;
  String productNameValue = "";
  String userNameValue = "";
  String startWeightUnit = "";
  List<String> productNameList = [];
  List<String> userNameList = [];

  ///创建文本控制器实例
  String errorText = "";
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
  bool isCnting = false;

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
  List<NetScaleInfoLocal> scaleNetItems = [];
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  int selScaleId = -1;
  List<PluData> myPluInfoList = [];
  PluData? selectedPluData; // 用于存储选中的PluData

  Timer? startTimer;
  Timer? innerTimer;

  int maxRecId = 0;
  bool firstGetRec = true;

  int _currentPage = 1;

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
  dynamic eventBus15;
  dynamic eventBus16;
  dynamic eventBus17;

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
      _weightReportDataSource.sortDataGrid(
        "Date Time",
        DataGridSortDirection.descending,
      );
    });
  }

  bool _isFirstLayout = true;

  void _toggleLayout() {
    setState(() {
      _isFirstLayout = !_isFirstLayout;
    });
  }

  void initScaleList() {
    scaleNetItems = myNetScaleList;
    selScaleId = myDefScaleInfo.defScaleId!;
    if (myNetScaleList.isNotEmpty) {
      defNetScaleInfo = NetScaleListMgr.findScaleInfo(
          myNetScaleList, myDefScaleInfo.defScaleId!);
    }
  }

  @override
  void initState() {
    super.initState();
    initScaleList();
    updateMyReportFeildsMap();
    _reportScrollerController = ScrollController();
    lastWeight = "*";
    dateformat = 1;
    zeroRange = 0;
    sortColumnName = 'Id';
    sortDirectValue = DataGridSortDirection.descending;

    if (myModeSettingTakeOut.recMode == msgManual) {
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
    // getProductNameList();

    _weightReportDatas = getWeightReportData();
    _weightReportDataSource =
        WeightReportDataSource(_weightReportDatas, weighingTakeOutMode);
    _weightReportDataSource.loadPage(_currentPage);

    PublicFunctions.getUserList();
    PublicFunctions.getProductList();

    cntScaleTimerMgr.startCntScaleTimer(10);
    PublicFunctions.getWeight(myDefScaleInfo.defScaleId!);
    onStartTimer();

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

          // getWeight();
          // getRecords();
        });
      }
    });

    eventBus3 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        setState(() {
          ReqWeightCountine tempWeight = ReqWeightCountine();
          tempWeight = event.obj;
          if (tempWeight.scaleId == myDefScaleInfo.defScaleId!) {
            myReqWeightCountine = tempWeight;
            isStart = true;
            myComScaleInfo.isOnline = true;
            isCnting = true;

            if (_isTakeOutStart && !isSameUnit()) {
              showDialogFlag = true;
            } else {
              showDialogFlag = false;
              checkWeight();
            }
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
          weightMode = (myModeSettingTakeOut.recMode == msgManual)
              ? 1
              : (myModeSettingTakeOut.recMode == msgAuto)
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
      if (!mounted) {
        return;
      }
      setState(() {
        myGetScaleRecords = event.obj;
        final weightRecordsLength = myGetScaleRecords.weightRecords!.length;
        if (weightRecordsLength != 0) {
          _addDBdataToReport();
          getWeightReportData();
          if (firstGetRec) {
            int maxId = int.parse(myGetScaleRecords.weightRecords![0].id!);
            maxRecId = maxId;

            // 遍历 weightRecords 列表
            for (var record in myGetScaleRecords.weightRecords!) {
              int currentId = int.parse(record.id!);
              if (currentId > maxId) {
                maxId = currentId;
                maxRecId = maxId;
              }
            }
          }
        } else {
          myWeightReportData.clear();
          updateTableData(getWeightReportData());
        }
      });
    });
    eventBus11 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains(msgOk)) {
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
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains(msgOk)) {
          setState(() {
            isStart = false;
          });
        }
      }
    });

    eventBus13 = eventBus.on<EventDeleteRec>().listen((event) {
      if (mounted) {
        setState(() {
          maxRecId = 0;
          _weightReportDatas.clear();
          _weightReportDataSource.updateData(_weightReportDatas);
        });
      }
    });

    eventBus14 = eventBus.on<EventUpdateSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          PublicFunctions.getUIConfTakeOut(myDefScaleInfo.defScaleId!);
        });
      }
    });

    eventBus15 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        // if (isStart) {
        //   cntScaleTimerMgr.stopCntScaleTimer();
        //   cntScaleTimerMgr.stopPortOffTimer();
        //   cntScaleTimerMgr.startPortOffTimer(2, () {
        //     if (!isCnting) {
        //       setState(() {
        //         myComScaleInfo.isOnline = false;
        //       });
        //     }
        //     isCnting = false;
        //   });
        // }

        // setState(() {
        //   myFactoryInfoFromScale = event.obj;
        //   if (myFactoryInfoFromScale.modelName != '') {
        //     myComScaleInfo.isOnline = true;
        //   } else {
        //     myComScaleInfo.isOnline = false;
        //   }
        // });
      }
    });

    eventBus16 = eventBus.on<EventSelWeighingScaleId>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        int scaleId = event.obj;

        if (scaleId != selScaleId) {
          setState(() {
            PublicFunctions.stopWeight(selScaleId);
            selScaleId = scaleId;
            PublicFunctions.getWeight(selScaleId);
            DefScaleInfo.getDefScaleInfo(scaleId);
            myWeightReportData.clear();
            updateTableData(getWeightReportData());
            sortColumnName = 'Id';
            maxRecId = 0;
            firstGetRec = true;
            sortDirectValue = DataGridSortDirection.descending;
            _weightReportDataSource.loadPage(_currentPage);
          });
        }
      }
    });
    eventBus17 = eventBus.on<EventRevExportRecs>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody != "") {
          if (mounted) {
            showConfirmationDialog(context, myRespDataFromScale.msgBody);
          }
        }
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
            _weightReportDataSource.sortDataGrid(
              "Date Time",
              DataGridSortDirection.descending,
            );
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
    addDBdataToReport(myWeightReportData, myModeSettingTakeOut, dateformat);
    setState(() {
      _weightReportDataSource =
          WeightReportDataSource(_weightReportDatas, weighingTakeOutMode);
      Future.delayed(const Duration(milliseconds: 100), () {
        _dataGridController
            .scrollToRow(_weightReportDataSource.rows.length - 0);
      });
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
    eventBus15.cancel();
    eventBus16.cancel();
    eventBus17.cancel();
    cntScaleTimerMgr.stopPortOffTimer();
    myGetScaleRecords.weightRecords?.clear();
    myWeightReportData.clear();
    PublicFunctions.stopWeight(selScaleId);
    super.dispose();
  }

  void onStartTimer() {
    startTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      isCnting = false;
      innerTimer = Timer(Duration(seconds: 1), () {
        if (!isCnting && mounted && isStart) {
          setState(() {
            isStart = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: Container(
            child: pageHeadDefScale(context, localizedStrings.gTitleTakeOut,
                localizedStrings.gTipTakeOutPageHelp),
          ),
          leading: IconTheme(
              data: IconThemeData(
                  color: Theme.of(context).colorScheme.primary // 设置抽屉图标颜色
                  ),
              child: Builder(builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }))),
      body: _isFirstLayout
          ? firstLayout(context, width)
          : secondLayout(context, width),
      drawer: Drawer(
          child: myWeighingScaleListDrawer(
              context,
              localizedStrings.gTipScaleList,
              scaleNetItems,
              selScaleId) // showNetScaleList(),
          ),
    );
  }

  void handleOKPressed(bool isOKPressed) {
    // 根据用户点击 OK 的结果更新 _isShowing 值
    _isShowing = !isOKPressed;
  }

  Widget firstLayout(context, width) {
    if (showDialogFlag) {
      if (!_isShowing) {
        _isShowing = true;
        showWarningDialog(context, handleOKPressed);
      }
    }
    return Container(
        width: width,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceTint,
              child: Row(
                children: [
                  Container(
                      // width: _width,
                      height: 20,
                      margin: const EdgeInsets.only(left: 5, top: 2),
                      alignment: Alignment.center, //设置控件内容的位置
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              errorText, //报错信息
                              maxLines: 1,
                              style: TextStyle(
                                color: (errorText).contains('succeed')
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onTertiaryFixedVariant
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
                color: Theme.of(context).colorScheme.surfaceTint,
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
                                  localizedStrings.iStable,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("assets/images/gray.png")
                                      : (myReqWeightCountine
                                                  .msgBody!.isStable &&
                                              isStart)
                                          ? ("assets/images/blue.png")
                                          : ("assets/images/gray.png"),
                                  constraints),
                              buildTextAndImage(
                                  localizedStrings.iTextNet,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("assets/images/gray.png")
                                      : (myReqWeightCountine.msgBody!.isNet &&
                                              isStart)
                                          ? ("assets/images/blue.png")
                                          : ("assets/images/gray.png"),
                                  constraints),
                              buildTextAndImage(
                                  localizedStrings.iTextZero,
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
                                  Theme.of(context).colorScheme,
                                  (myReqWeightCountine.msgBody == null)
                                      ? ("-----")
                                      : myReqWeightCountine.msgBody!.weightVal,
                                  constraints),
                              buildTextWithUnit(
                                Theme.of(context).colorScheme,
                                (myReqWeightCountine.msgBody == null)
                                    ? ("kg")
                                    : myReqWeightCountine.msgBody!.weightUnit,
                                constraints,
                              )
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
                color: Theme.of(context).colorScheme.surfaceTint,
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
                                      Theme.of(context).colorScheme,
                                      (takeOutWeightValue == '-0.000')
                                          ? '0.000'
                                          : isPcsTakeOutVal(),
                                      constraints,
                                    )
                                  : const SizedBox(),
                              buildTextWithNoUnit(constraints)
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
                        constraints: constraints,
                        icon: Icons.title),
                    _buildFlexibleButtonAndTextZ(
                        buttonText: localizedStrings.iBtnZero,
                        constraints: constraints,
                        icon: Icons.exposure_zero),
                    _buildFlexibleButtonAndTextEnd(
                        buttonText: (myReqWeightCountine.msgBody == null)
                            ? localizedStrings.gBtnStart
                            : (_isTakeOutStart)
                                ? localizedStrings.gBtnEnd
                                : localizedStrings.gBtnStart,
                        constraints: constraints,
                        isTrue: isStart && !_isTakeOutStart,
                        icon: Icons.swipe_right_outlined),
                    _buildFlexibleButtonAndText(
                        buttonText: localizedStrings.gBtnSave,
                        onPressed: _changeSaveButton,
                        constraints: constraints,
                        isTrue: !_isSaveButtonDisabled && isStart,
                        icon: Icons.save_outlined),
                    _buildFlexibleButtonAndText(
                        buttonText: localizedStrings.gBtnSetting,
                        onPressed: () {
                          mySettingParam = myModeSettingTakeOut;
                          paramSettingDialog(context);
                        },
                        constraints: constraints,
                        isTrue: true,
                        icon: Icons.settings_outlined),
                  ],
                );
              }),
            ),
            Expanded(
                flex: 1,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceTint,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildTextString(
                              localizedStrings.gPluName, constraints, context),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 53,
                            width: constraints.maxWidth / 5,
                            padding: const EdgeInsets.all(0),
                            child: Autocomplete<PluData>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<PluData>.empty();
                                }
                                return myPluInfoList.where((PluData data) {
                                  // 进行模糊查找，这里同时匹配productName和plu转成字符串后的内容
                                  return data.productName!
                                          .toLowerCase()
                                          .contains(textEditingValue.text
                                              .toLowerCase()) ||
                                      data.plu
                                          .toString()
                                          .contains(textEditingValue.text);
                                }).toList()
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
                          // buildTextString(
                          //     localizedStrings.user_name, constraints, context),
                          // Container(
                          //   height: 53,
                          //   width: 150,
                          //   padding: const EdgeInsets.all(0),
                          //   child: DropdownButtonFormField<String>(
                          //     itemHeight: 50.0,
                          //     isExpanded: true,
                          //     // decoration: const InputDecoration(border: OutlineInputBorder()),
                          //     value: userNameValue,
                          //     onChanged: (String? newPosition) {
                          //       setState(() {
                          //         userNameValue = newPosition.toString();
                          //         for (var i = 0;
                          //             i < myUserInfoList.userInfo!.length;
                          //             i++) {
                          //           if (userNameValue ==
                          //               myUserInfoList.userInfo![i].name) {
                          //             myUserInfo = myUserInfoList.userInfo![i];
                          //             eventBus.fire(EventUserInfo(myUserInfo));
                          //           }
                          //         }
                          //       });
                          //     },
                          //     items: userNameList.map<DropdownMenuItem<String>>(
                          //         (String value) {
                          //       return DropdownMenuItem(
                          //           value: value,
                          //           child: Text(value,
                          //               overflow: TextOverflow.ellipsis));
                          //     }).toList(),
                          //   ),
                          // ),
                          // CustomElevatedButton(
                          //   btnWidth: constraints.maxWidth / 10 - 50,
                          //   btnHeight: 40,
                          //   icon: Icons.edit_note_outlined,
                          //   text: localizedStrings.user_edit,
                          //   onPressed: () {
                          //     PublicFunctions.getUserList();
                          //     getUserNameList();
                          //     if (!userNameList.contains(userNameValue)) {
                          //       myUserInfo.name = "";
                          //       userNameValue = "";
                          //       myUserInfo.id = "";
                          //       myUserInfo.isFemale = true;
                          //       myUserInfo.phone = "";
                          //       myUserInfo.remarks = "";
                          //     }
                          //     addUserDialog(context).then((onvalue) {
                          //       setState(() {
                          //         PublicFunctions.getUserList();
                          //         getUserNameList();
                          //         if (!userNameList.contains(userNameValue)) {
                          //           myUserInfo.name = "";
                          //           userNameValue = "";
                          //           myUserInfo.id = "";
                          //           myUserInfo.isFemale = true;
                          //           myUserInfo.phone = "";
                          //           myUserInfo.remarks = "";
                          //         }
                          //       });
                          //     });
                          //   },
                          // ),
                          CustomOutlinedButton(
                            btnWidth: constraints.maxWidth / 10 - 50,
                            btnHeight: 40,
                            icon: Icons.settings_applications_rounded,
                            text: localizedStrings.report_set_btn,
                            onPressed: () {
                              reportFieldsSettingDialog(context);
                            },
                          ),
                          CustomOutlinedButton(
                            btnWidth: constraints.maxWidth / 10 - 50,
                            btnHeight: 40,
                            icon: Icons.show_chart,
                            text: localizedStrings.report_show_btn,
                            onPressed: () {
                              _toggleLayout();
                            },
                          ),
                        ]),
                  );
                })),
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceTint,
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
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(localizedStrings.data_delete_confirm),
          actions: <Widget>[
            Row(
              children: [
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.gBtnCancel,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                CustomElevatedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.gBtnConfirm,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            )
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        PublicFunctions.deleteAllRecordsTakeOut(myDefScaleInfo.defScaleId!);
      }
    });
  }

  Widget buildWeightNameText(String text, BoxConstraints constraints) {
    double width = constraints.maxWidth / 1.2;
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

  Widget buildTextWithWeight(
    ColorScheme colorScheme,
    String text,
    BoxConstraints constraints,
  ) {
    double width = constraints.maxWidth / 10 * 7;
    double height = constraints.maxHeight / 1.1;
    double fontSize = width / 10 / 0.6;

    if (height - 80 < fontSize && fontSize > 110) {
      fontSize = height - 80;
    }
    return Container(
      width: width,
      height: height,
      color: colorScheme.primary,
      child: Column(
        // 将 Row 改为 Column
        mainAxisAlignment: MainAxisAlignment.center, // 垂直方向居中对齐
        crossAxisAlignment: CrossAxisAlignment.end, // 水平方向居右对齐
        children: [
          Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(color: colorScheme.onPrimary, fontSize: fontSize),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildTextWithNoUnit(BoxConstraints constraints) {
    double width = constraints.maxWidth / 10 * 2;
    double height = constraints.maxHeight / 1.1;
    return SizedBox(
      width: width,
      height: height,
    );
  }

  Widget buildTextWithUnit(
      ColorScheme colorScheme, String text, BoxConstraints constraints) {
    double width = constraints.maxWidth / 10 * 2;
    double height = constraints.maxHeight / 1.1;
    double fontSize = width / 5 / 0.6;

    if (height - 80 < fontSize && fontSize > 110) {
      fontSize = height - 80;
    }

    return Container(
      width: width,
      height: height,
      color: colorScheme.primary,
      child: Column(
        // 将 Row 改为 Column
        mainAxisAlignment: MainAxisAlignment.center, // 垂直方向居中对齐
        crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居右对齐
        children: [
          Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(color: colorScheme.onPrimary, fontSize: fontSize),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildTextAndImage(
      String text, String imageName, BoxConstraints constraints) {
    var imageSize = constraints.maxHeight / 4;
    double width = constraints.maxWidth / 10 * 9;
    var fontSize = width / 30 / 0.6;
    if (imageSize > 60) {
      imageSize = 60;
    }
    if (fontSize > 35) {
      fontSize = 35;
    }
    return Row(
      children: [
        SizedBox(
          width: width - imageSize - 10,
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

  Widget buildButton(ColorScheme colorScheme, String text,
      BoxConstraints constraints, VoidCallback onPressed) {
    var fontSize = 14 * constraints.maxHeight / 60;
    var width = constraints.maxWidth / 10;

    return SizedBox(
        width: width,
        child: MaterialButton(
            color: colorScheme.primary,
            textColor: colorScheme.onPrimary,
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

  Widget _buildFlexibleButtonAndText({
    required String buttonText,
    required VoidCallback onPressed,
    required BoxConstraints constraints,
    required bool isTrue,
    required IconData icon,
  }) {
    double buttonWidth = (constraints.maxWidth / 8); // 自适应按钮宽度
    double fontSize = (buttonWidth / 15 / 0.6); // 自适应字体大小
    double btnH = (constraints.maxHeight / 2); // 自适应按钮宽度
    if (fontSize > 40) {
      fontSize = 40;
    }
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5, // 设置按钮的阴影
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
          ),
        ),
        onPressed: isTrue ? onPressed : null,
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
              height: btnH,
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
      ),
    );
  }

  Widget _buildFlexibleButtonAndTextZ({
    required String buttonText,
    required BoxConstraints constraints,
    required IconData icon,
  }) {
    double buttonWidth = (constraints.maxWidth / 8); // 自适应按钮宽度
    double fontSize = (buttonWidth / 15 / 0.6); // 自适应字体大小
    double btnH = (constraints.maxHeight / 2); // 自适应按钮宽度
    if (fontSize > 40) {
      fontSize = 40;
    }

    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5, // 设置按钮的阴影
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
          ),
        ),
        onPressed: (isStart && !_isTakeOutStart)
            ? () {
                PublicFunctions.performZero();
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
              height: btnH,
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
      ),
    );
  }

  Widget _buildFlexibleButtonAndTextT({
    required String buttonText,
    required BoxConstraints constraints,
    required IconData icon,
  }) {
    double buttonWidth = (constraints.maxWidth / 8); // 自适应按钮宽度
    double fontSize = (buttonWidth / 15 / 0.6); // 自适应字体大小
    double btnH = (constraints.maxHeight / 2); // 自适应按钮宽度
    if (fontSize > 40) {
      fontSize = 40;
    }
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5, // 设置按钮的阴影
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
          ),
        ),
        onPressed: (isStart && !_isTakeOutStart)
            ? () {
                PublicFunctions.performTare();
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
              height: btnH,
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
      ),
    );
  }

  Widget _buildFlexibleButtonAndTextEnd({
    required String buttonText,
    required BoxConstraints constraints,
    required bool isTrue,
    required IconData icon,
  }) {
    double buttonWidth = (constraints.maxWidth / 8); // 自适应按钮宽度
    double fontSize = (buttonWidth / 15 / 0.6); // 自适应字体大小
    double btnH = (constraints.maxHeight / 2); // 自适应按钮宽度
    if (fontSize > 40) {
      fontSize = 40;
    }
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5, // 设置按钮的阴影
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
          ),
        ),
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
              height: btnH,
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
      ),
    );
  }

  Widget secondLayout(context, width) {
    if (showDialogFlag) {
      if (!_isShowing) {
        _isShowing = true;
        showWarningDialog(context, handleOKPressed);
      }
    }
    return Container(
        width: width,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Container(
              height: 120,
              color: Theme.of(context).colorScheme.onPrimary,
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
                            width: 120,
                            child: Text(
                              localizedStrings.iStable,
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
                            width: 120,
                            child: Text(
                              localizedStrings.iTextNet,
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
                            width: 120,
                            child: Text(
                              localizedStrings.iTextZero,
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
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 55),
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
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
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
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 55),
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
                              CustomElevatedButton(
                                btnWidth: constraints.maxWidth / 5,
                                btnHeight: 40,
                                icon: Icons.title,
                                text: localizedStrings.gBtnTare,
                                onPressed: (isStart && !_isTakeOutStart)
                                    ? () {
                                        PublicFunctions.performTare();
                                      }
                                    : null,
                              ),
                              CustomElevatedButton(
                                btnWidth: constraints.maxWidth / 5,
                                btnHeight: 40,
                                icon: Icons.exposure_zero,
                                text: localizedStrings.iBtnZero,
                                onPressed: (isStart && !_isTakeOutStart)
                                    ? () {
                                        PublicFunctions.performZero();
                                      }
                                    : null,
                              ),
                              CustomElevatedButton(
                                  btnWidth: constraints.maxWidth / 5,
                                  btnHeight: 40,
                                  icon: Icons.save_outlined,
                                  text: localizedStrings.gBtnSave,
                                  onPressed: (!_isSaveButtonDisabled && isStart)
                                      ? _changeSaveButton
                                      : null),
                            ],
                          );
                        }),
                        LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomElevatedButton(
                                btnWidth: constraints.maxWidth / 5,
                                btnHeight: 40,
                                icon: Icons.settings_outlined,
                                text: localizedStrings.gBtnSetting,
                                onPressed: () {
                                  mySettingParam = myModeSettingTakeOut;
                                  paramSettingDialog(context);
                                },
                              ),
                              CustomElevatedButton(
                                btnWidth: constraints.maxWidth / 5,
                                btnHeight: 40,
                                icon: Icons.swipe_right_outlined,
                                text: (myReqWeightCountine.msgBody == null)
                                    ? localizedStrings.gBtnStart
                                    : (_isTakeOutStart)
                                        ? localizedStrings.gBtnEnd
                                        : localizedStrings.gBtnStart,
                                onPressed: checkStartButton()
                                    ? () {
                                        if (_isTakeOutStart) {
                                          _isTakeOutStart = false;
                                          weightValueList.clear();
                                          lastTakeOutWeightval = 0.000;
                                        } else {
                                          if (isWeightValue()) {
                                            basicWeightval = double.tryParse(
                                                myReqWeightCountine
                                                    .msgBody!.weightVal)!;
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
                              ),
                              CustomElevatedButton(
                                  btnWidth: constraints.maxWidth / 5,
                                  btnHeight: 40,
                                  icon: Icons.outbox,
                                  text: localizedStrings.gBtnExport,
                                  onPressed: () async {
                                    final directory = Directory.current.path;
                                    String? outputFile =
                                        (await FilePicker.platform.saveFile(
                                      initialDirectory: directory,
                                      type: FileType.custom,
                                      dialogTitle: 'Output file:',
                                      allowedExtensions: ["csv"],
                                      fileName: 'report.csv',
                                    ));
                                    if (outputFile != null) {
                                      if (!outputFile.contains(".csv")) {
                                        outputFile = "$outputFile.csv";
                                      }
                                      PublicFunctions.exportRecords(
                                          myDefScaleInfo.defScaleId!,
                                          weighingTakeOutMode,
                                          outputFile);
                                    }
                                  }),
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
            // displayGrid(),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: SfDataGrid(
                  source: _weightReportDataSource,
                  columns: getColumns().map((column) {
                    return GridColumn(
                      columnName: column.columnName,
                      label: Container(
                        padding: EdgeInsets.all(2),
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            final currentSortDirection = _weightReportDataSource
                                .sortDirectionForColumn(column.columnName);
                            final newSortDirection = currentSortDirection ==
                                    DataGridSortDirection.ascending
                                ? DataGridSortDirection.descending
                                : DataGridSortDirection.ascending;
                            _weightReportDataSource.sortDataGrid(
                              column.columnName,
                              newSortDirection,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  myReportFeildsMap[column.columnName]!
                                      .showName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _getSortIconForColumn(column.columnName),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  columnWidthMode: ColumnWidthMode.fill,
                  frozenRowsCount: 0,
                  // controller: null,
                  allowSorting: false,
                ),
              ),
            ),

            // 分页控件
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                            _weightReportDataSource.loadPage(_currentPage);
                          });
                        }
                      : null,
                ),
                Text('Page $_currentPage'),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _currentPage++;
                      _weightReportDataSource.loadPage(_currentPage);
                    });
                  },
                ),
              ],
            ),
          ],
        ));
  }

  Widget _getSortIconForColumn(String columnName) {
    if (!_weightReportDataSource.isColumnSorted(columnName)) {
      return SizedBox.shrink();
    }
    final sortDirection =
        _weightReportDataSource.sortDirectionForColumn(columnName);
    switch (sortDirection) {
      case DataGridSortDirection.ascending:
        return Icon(
          Icons.arrow_upward,
          size: 18,
        );
      case DataGridSortDirection.descending:
        return Icon(
          Icons.arrow_downward,
          size: 18,
        );
    }
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
      color: Theme.of(context).colorScheme.onPrimary,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: constraints.maxWidth / 10,
              child: Text(
                localizedStrings.gPluName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              height: 53,
              width: constraints.maxWidth / 5,
              padding: const EdgeInsets.all(0),
              child: Autocomplete<PluData>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<PluData>.empty();
                  }
                  return myPluInfoList.where((PluData data) {
                    // 进行模糊查找，这里同时匹配productName和plu转成字符串后的内容
                    return data.productName!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()) ||
                        data.plu.toString().contains(textEditingValue.text);
                  }).toList()
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
            // SizedBox(
            //   width: constraints.maxWidth / 10,
            //   child: TextButton(
            //       onPressed: () {},
            //       child: Text(localizedStrings.user_name,
            //           style: const TextStyle(
            //               fontSize: 14, fontWeight: FontWeight.normal))),
            // ),
            // Container(
            //   height: 53,
            //   width: constraints.maxWidth / 10,
            //   padding: const EdgeInsets.all(0),
            //   child: DropdownButtonFormField<String>(
            //     itemHeight: 50.0,
            //     isExpanded: true,
            //     // decoration: const InputDecoration(border: OutlineInputBorder()),
            //     value: userNameValue,
            //     onChanged: (String? newPosition) {
            //       setState(() {
            //         userNameValue = newPosition.toString();
            //         for (var i = 0; i < myUserInfoList.userInfo!.length; i++) {
            //           if (userNameValue == myUserInfoList.userInfo![i].name) {
            //             myUserInfo = myUserInfoList.userInfo![i];
            //             eventBus.fire(EventUserInfo(myUserInfo));
            //           }
            //         }
            //       });
            //     },
            //     items:
            //         userNameList.map<DropdownMenuItem<String>>((String value) {
            //       return DropdownMenuItem(
            //           value: value,
            //           child: Text(value, overflow: TextOverflow.ellipsis));
            //     }).toList(),
            //   ),
            // ),
            // CustomElevatedButton(
            //   btnWidth: constraints.maxWidth / 10 - 50,
            //   btnHeight: 40,
            //   icon: Icons.edit_note_outlined,
            //   text: localizedStrings.user_edit,
            //   onPressed: () {
            //     PublicFunctions.getUserList();
            //     getUserNameList();
            //     if (!userNameList.contains(userNameValue)) {
            //       myUserInfo.name = "";
            //       userNameValue = "";
            //       myUserInfo.id = "";
            //       myUserInfo.isFemale = true;
            //       myUserInfo.phone = "";
            //       myUserInfo.remarks = "";
            //     }
            //     addUserDialog(context).then((onvalue) {
            //       setState(() {
            //         PublicFunctions.getUserList();
            //         getUserNameList();
            //         if (!userNameList.contains(userNameValue)) {
            //           myUserInfo.name = "";
            //           userNameValue = "";
            //           myUserInfo.id = "";
            //           myUserInfo.isFemale = true;
            //           myUserInfo.phone = "";
            //           myUserInfo.remarks = "";
            //         }
            //       });
            //     });
            //   },
            // ),
            CustomOutlinedButton(
              btnWidth: constraints.maxWidth / 10 - 50,
              btnHeight: 40,
              icon: Icons.settings_applications_rounded,
              text: localizedStrings.report_set_btn,
              onPressed: () {
                reportFieldsSettingDialog(context);
              },
            ),
            CustomOutlinedButton(
              btnWidth: constraints.maxWidth / 10 - 50,
              btnHeight: 40,
              icon: Icons.hide_source,
              text: localizedStrings.report_hide_btn,
              onPressed: () {
                _toggleLayout();
              },
            ),
            CustomOutlinedButton(
              btnWidth: constraints.maxWidth / 10 - 50,
              btnHeight: 40,
              icon: Icons.delete_forever_outlined,
              text: localizedStrings.report_delete_btn,
              onPressed: () {
                _showConfirmationDialog(context);
              },
            ),
          ],
        );
      }),
    );
  }

  Widget displayGrid() {
    return Expanded(
        child: Container(
      padding: EdgeInsets.all(10),
      child: SfDataGrid(
        source: _weightReportDataSource,
        columns: getColumns(),
        columnWidthMode: ColumnWidthMode.fill,
        frozenRowsCount: 0,
        controller: _dataGridController,
        allowSorting: true,
      ),
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

  // _creatFile(String path) async {
  //   Excel excel = Excel.createExcel();
  //   // await creatExcelFile(path, myWeightReportData, excel);
  //   await creatCsvFile(path, myWeightReportData);

  //   try {
  //     var onValue = excel.encode();
  //     File(join(path))
  //       ..createSync(recursive: true)
  //       ..writeAsBytesSync(onValue!);
  //     errorText = "Excel save succeed!";
  //   } catch (ex) {
  //     errorText = "Excel save fail!";
  //   }
  // }

// "ReqData":"{\"ScaleId\": 2, \"Product\": \"Apple\", \"Weight\": \"1.230\", \"Price\": \"3.25\"}"}
  void sendReportDataToDB() {
    sendRptDataToDB(myWeightReportData, weighingTakeOutMode);
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
      // performAddToReport();
    }
  }

  void performAddToReport() {
    PluData? tempPlu = PluData(null, null, null, null, null, null, null, null,
        null, null, null, null, null, null);
    if (selectedPluData != null) {
      tempPlu = selectedPluData;
    }
    maxRecId++;
    WeightReportData addData = WeightReportData(
      (maxRecId).toString(),
      myDefScaleInfo.defScaleModel == null ? '' : myDefScaleInfo.defScaleModel!,
      myDefScaleInfo.defScaleSn == null ? '' : myDefScaleInfo.defScaleSn!,
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

      (_isTakeOutStart)
          ? diffWeightVal.toString()
          : (myReqWeightCountine.msgBody?.weightVal == null)
              ? (" ")
              : (myReqWeightCountine.msgBody!.weightVal),
      (myReqWeightCountine.msgBody?.weightUnit == null)
          ? (" ")
          : (myReqWeightCountine.msgBody!.weightUnit),
      (myUserInfo.id == null)
          ? ""
          : (myUserInfo.id.toString().contains("Please")
              ? ""
              : myUserInfo.id.toString()),
      (myUserInfo.name == null)
          ? ""
          : (myUserInfo.name.toString().contains("Please")
              ? ""
              : myUserInfo.name.toString()),

      myDefScaleInfo.defScaleName == null
          ? ''
          : myDefScaleInfo.defScaleName!, //此处应该是秤机种名
      getDateTime(myModeSettingTakeOut.dateSeparator, dateformat),
    );

    myWeightReportData.add(addData);
  }

  List<WeightReportData> getWeightReportData() {
    return myWeightReportData;
  }
}
