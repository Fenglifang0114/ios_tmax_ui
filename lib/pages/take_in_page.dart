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
import '../dialog/adduser_dialog.dart';
import '../dialog/conform_dialog.dart';
import '../dialog/setting_dialog.dart';
import '../dialog/show_warning.dart';
import '../dialog/weight_report_feilds_setting.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class TakeInPage extends StatefulWidget {
  const TakeInPage({super.key});
  @override
  State<TakeInPage> createState() => TakeInPageState();
}

class TakeInPageState extends State<TakeInPage> {
  List<String> items = [];
  List<String> productNameList = [];
  List<String> userNameList = [];
  List<WeightReportData> _weightReportDatas = <WeightReportData>[];
  List<WeightReportData> myWeightReportData = [];
  List<double> weightValueList = [];
  List<NetScaleInfoLocal> scaleNetItems = [];
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  int selScaleId = -1;

  final DataGridController _dataGridController = DataGridController();
  String errorText = '';

  late ScrollController _reportScrollerController;
  late String lastWeight;
  late int weightMode; //0,手动保存，1，连续保存，2，稳定保存
  late int dateformat;
  late double zeroRange;
  late Timer _saveTimer;
  late bool _isStableStatusJudge;
  late bool _isTakeInStart = false;
  late bool _isSaveButtonDisabled;
  List<PluData> myPluInfoList = [];
  late WeightReportDataSource _weightReportDataSource;
  PluData? selectedPluData; // 用于存储选中的PluData

  bool isStart = false;
  bool lastStableStatus = false;
  bool _isTiming = false;
  bool _isZero = false;
  bool _isPassZero = false;
  bool _isFirstLayout = true;
  bool showDialogFlag = false;
  bool _isShowing = false;

  int _stableSaveTime = 0;

  double basicWeightval = 0.000; //开始加法秤的时候的基础重量
  double lastTakeInWeightval = 0.000;

  String showTakeInWeight = '';
  String diffWeightVal = '0.000'; //差值
  String takeInWeightValue = '-----';
  String dialogString = " ";
  String productNameValue = "";
  String userNameValue = "";
  String startWeightUnit = "--";

  Timer? startTimer;
  Timer? innerTimer;

  int maxRecId = 0;
  bool firstGetRec = true;

  int _currentPage = 1;

  void updateTableData(List<WeightReportData> newReportData) {
    _weightReportDataSource.updateData(newReportData);
  }

  void _saveWeight(bool isStable) {
    if (_stableSaveTime == 0) {
      _isStableStatusJudge = true;
      _isTiming = false;
    }

    if (isStable && !_isTiming && !_isZero) {
      _isTiming = true;
      _performSaveTimer();
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
  dynamic eventBus18;

  bool isCnting = false;
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

    String timeString = (myModeSettingTakeIn.stableTime == "")
        ? "0"
        : myModeSettingTakeIn.stableTime.toString();
    _stableSaveTime = int.parse(timeString);
    if (myModeSettingTakeIn.recMode == msgManual) {
      weightMode = 1;
      _isSaveButtonDisabled = false;
    } else {
      _isSaveButtonDisabled = true;
      weightMode = 2;
      if (_stableSaveTime == 0) {
        _stableSaveTime = 1;
      }
    }

    _isStableStatusJudge = false;
    // getProductNameList();

    _weightReportDatas = getWeightReportData();
    _weightReportDataSource =
        WeightReportDataSource(_weightReportDatas, weighingTakeInMode);
    _weightReportDataSource.loadPage(_currentPage);

    PublicFunctions.getUserList();
    PublicFunctions.getProductList();

    cntScaleTimerMgr.startCntAliveTimer(10);

    PublicFunctions.getWeight(myDefScaleInfo.defScaleId!);
    onStartTimer();

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

            if (_isTakeInStart && !isSameUnit()) {
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
        });
      }
    });

    eventBus8 = eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          myModeSettingTakeIn = event.obj;
          weightMode = (myModeSettingTakeIn.recMode == msgManual)
              ? 1
              : (myModeSettingTakeIn.recMode == msgAuto)
                  ? 2
                  : 1;
          dateformat = int.parse(myModeSettingTakeIn.dateFormat);
          zeroRange = double.tryParse(myModeSettingTakeIn.zeroRange)!;
          String timeString = (myModeSettingTakeIn.stableTime == "")
              ? "0"
              : myModeSettingTakeIn.stableTime.toString();
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
          PublicFunctions.getUIConfTakeIn(myDefScaleInfo.defScaleId!);
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
    eventBus18 = eventBus.on<EventRevAddRec>().listen((event) {
      if (mounted) {
        _weightReportDataSource.sortDataGrid(
          "Date Time",
          DataGridSortDirection.descending,
        );
      }
    });
  }

  void takeInModeWeight() {
    if (_isTakeInStart && isStart && myReqWeightCountine.msgBody != null) {
      if (isWeightValue()) {
        showDiffWeightVal();
      } else {
        showTakeInWeight = myReqWeightCountine.msgBody!.weightVal;
        takeInWeightValue = myReqWeightCountine.msgBody!.weightVal;
      }
    }
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
        takeInModeWeight();
        isWeightStable();
        break;
      case 2:
        takeInModeWeight();
        if (!myReqWeightCountine.msgBody!.isStable) {
          if (_isTiming) {
            _saveTimer.cancel();
          }
          _isPassZero = false;
          _isTiming = false;
          _isStableStatusJudge = false;
          return;
        }
        if (!_isTakeInStart) {
          return;
        }
        _isPassZero = true;
        _saveWeight(myReqWeightCountine.msgBody!.isStable);
        if (isWeightValue() && _isStableStatusJudge) {
          double? nowWeightVal =
              double.tryParse(myReqWeightCountine.msgBody!.weightVal);
          if ((nowWeightVal! - basicWeightval) - lastTakeInWeightval > 0.02) {
            if (myReqWeightCountine.msgBody!.weightUnit == 'PCS') {
              lastTakeInWeightval = double.parse(
                  (nowWeightVal - basicWeightval).toStringAsFixed(0));
            } else {
              lastTakeInWeightval = double.parse(
                  (nowWeightVal - basicWeightval).toStringAsFixed(3));
            }

            _isPassZero = true;
          } else {
            _isPassZero = false;
          }
          //如果是加法秤，不需要判断是否重新归零
        }
        if (_isPassZero && _isStableStatusJudge) {
          {
            _isPassZero = false;
            _isTiming = false;
            _isStableStatusJudge = false;
            _addWeightToReport();
            sendReportDataToDB();
            updateLastWeight();
          }
          lastWeight = myReqWeightCountine.msgBody!.weightVal;
        }

        break;
      default:
        break;
    }
  }

  void updateLastWeight() {
    double? nowWeightVal =
        double.tryParse(myReqWeightCountine.msgBody!.weightVal);
    if (myReqWeightCountine.msgBody!.weightUnit == 'PCS') {
      lastTakeInWeightval =
          double.parse((nowWeightVal! - basicWeightval).toStringAsFixed(0));
    } else {
      lastTakeInWeightval =
          double.parse((nowWeightVal! - basicWeightval).toStringAsFixed(3));
    }
  }

  void _addDBdataToReport() {
    addDBdataToReport(myWeightReportData, myModeSettingTakeIn, dateformat);
    setState(() {
      _weightReportDataSource =
          WeightReportDataSource(_weightReportDatas, weighingTakeInMode);
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
    eventBus18.cancel();
    cntScaleTimerMgr.stopPortOffTimer();
    myGetScaleRecords.weightRecords?.clear();
    myWeightReportData.clear();
    PublicFunctions.stopWeight(selScaleId);
    cntScaleTimerMgr.stopCntAliveTimer();
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
            child: pageHeadDefScale(
                context,
                localizedStrings.iTitleIncrementWeighting,
                localizedStrings.gTipIncrementWgtPageHelp),
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
                                  (myReqWeightCountine.msgBody == null ||
                                          !isStart)
                                      ? ("-----")
                                      : myReqWeightCountine.msgBody!.weightVal,
                                  constraints,
                                  Theme.of(context).colorScheme.primary),
                              buildTextWithUnit(
                                  Theme.of(context).colorScheme,
                                  (myReqWeightCountine.msgBody == null ||
                                          !isStart)
                                      ? ("--")
                                      : myReqWeightCountine.msgBody!.weightUnit,
                                  constraints)
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
                                  _isTakeInStart
                                      ? localizedStrings.show_increment_weight
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
                              _isTakeInStart
                                  ? buildTextWithWeight(
                                      Theme.of(context).colorScheme,
                                      (takeInWeightValue == '-0.000')
                                          ? '0.000'
                                          : isPcsTakeInVal(),
                                      constraints,
                                      Theme.of(context).colorScheme.primary)
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
                    _buildFlexibleButtonAndText(
                        buttonText: localizedStrings.gBtnTare,
                        onPressed: PublicFunctions.performTare,
                        constraints: constraints,
                        isTrue: isStart && !_isTakeInStart,
                        icon: Icons.title),
                    _buildFlexibleButtonAndText(
                        buttonText: localizedStrings.iBtnZero,
                        onPressed: PublicFunctions.performZero,
                        constraints: constraints,
                        isTrue: isStart && !_isTakeInStart,
                        icon: Icons.exposure_zero),
                    _buildFlexibleButtonAndText(
                        buttonText: (myReqWeightCountine.msgBody == null)
                            ? localizedStrings.gBtnStart
                            : (myReqWeightCountine.msgBody!.isStable &&
                                    _isTakeInStart)
                                ? localizedStrings.gBtnEnd
                                : localizedStrings.gBtnStart,
                        onPressed: () {
                          if (_isTakeInStart) {
                            _isTakeInStart = false;
                            weightValueList.clear();
                            lastTakeInWeightval = 0.000;
                          } else {
                            if (isWeightValue()) {
                              basicWeightval = double.tryParse(
                                  myReqWeightCountine.msgBody!.weightVal)!;
                              startWeightUnit =
                                  myReqWeightCountine.msgBody!.weightUnit;
                            }
                            lastTakeInWeightval = 0.000;
                            _isTakeInStart = true;
                            weightValueList.clear();
                          }
                        },
                        constraints: constraints,
                        isTrue: isStartButtonEnable(),
                        icon: Icons.swipe_right_outlined),
                    _buildFlexibleButtonAndText(
                        buttonText: localizedStrings.gBtnSave,
                        onPressed: _changeSaveButton,
                        constraints: constraints,
                        isTrue:
                            !_isSaveButtonDisabled && isStart && _isTakeInStart,
                        icon: Icons.save_outlined),
                    _buildFlexibleButtonAndText(
                        buttonText: localizedStrings.gBtnSetting,
                        onPressed: () {
                          mySettingParam = myModeSettingTakeIn;
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

  String isPcsTakeInVal() {
    var takeInValue = '0.000';
    if (myReqWeightCountine.msgBody == null || !isStart) {
      takeInValue = '-----';
    } else if (myReqWeightCountine.msgBody!.weightUnit == 'PCS') {
      double? result = double.tryParse(takeInWeightValue);

      if (result != null) {
        takeInValue = result.toStringAsFixed(0);
      } else {
        takeInValue = '0';
      }
    } else {
      takeInValue = takeInWeightValue;
    }
    return takeInValue;
  }

  bool isSameUnit() {
    if (!isWeightValue()) {
      return true;
    }
    if (startWeightUnit != myReqWeightCountine.msgBody!.weightUnit &&
        _isTakeInStart) {
      return false;
    }
    return true;
  }

  Widget buildTextWithWeight(ColorScheme colorScheme, String text,
      BoxConstraints constraints, Color? color) {
    double width = constraints.maxWidth / 10 * 7;
    double height = constraints.maxHeight / 1.1;
    double fontSize = width / 10 / 0.6;

    if (height - 80 < fontSize && fontSize > 110) {
      fontSize = height - 80;
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

  Widget buildSetReportButton(Color? color, String text,
      BoxConstraints constraints, BuildContext context) {
    var fontSize = 14 * constraints.maxHeight / 60;
    var width = constraints.maxWidth / 10;
    return SizedBox(
      width: width,
      child: MaterialButton(
          color: color,
          textColor: Theme.of(context).colorScheme.onPrimary,
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
            textColor: Theme.of(context).colorScheme.onPrimary,
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

  bool isStartButtonEnable() {
    if (!isStart || myReqWeightCountine.msgBody == null) {
      return false;
    }
    if ((myReqWeightCountine.msgBody != null) &&
        (myReqWeightCountine.msgBody!.isStable) &&
        (myReqWeightCountine.msgBody!.weightUnit != 'lb:oz')) {
      return true;
    }

    return false;
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
                                  (myReqWeightCountine.msgBody == null ||
                                          !isStart)
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
                              (myReqWeightCountine.msgBody == null || !isStart)
                                  ? ("--")
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
                  const SizedBox(width: 10),

                  _isTakeInStart
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
                                        (takeInWeightValue == '-0.000')
                                            ? '0.000'
                                            : isPcsTakeInVal(),
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
                                onPressed: (isStart && !_isTakeInStart)
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
                                onPressed: () {
                                  PublicFunctions.performZero();
                                },
                              ),
                              CustomElevatedButton(
                                  btnWidth: constraints.maxWidth / 5,
                                  btnHeight: 40,
                                  icon: Icons.save_outlined,
                                  text: localizedStrings.gBtnSave,
                                  onPressed: (!_isSaveButtonDisabled &&
                                          isStart &&
                                          _isTakeInStart)
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
                                icon: Icons.swipe_right_outlined,
                                text: (myReqWeightCountine.msgBody == null)
                                    ? localizedStrings.gBtnStart
                                    : (myReqWeightCountine.msgBody!.isStable &&
                                            _isTakeInStart)
                                        ? localizedStrings.gBtnEnd
                                        : localizedStrings.gBtnStart,
                                onPressed: (!isStart ||
                                        myReqWeightCountine.msgBody == null)
                                    ? null
                                    : ((myReqWeightCountine.msgBody != null) &&
                                            (myReqWeightCountine
                                                .msgBody!.isStable) &&
                                            (myReqWeightCountine
                                                    .msgBody!.weightUnit !=
                                                'lb:oz'))
                                        ? () {
                                            if (_isTakeInStart) {
                                              _isTakeInStart = false;
                                              weightValueList.clear();
                                              lastTakeInWeightval = 0.000;
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
                                              lastTakeInWeightval = 0.000;
                                              _isTakeInStart = true;
                                              weightValueList.clear();
                                            }
                                          }
                                        : null,
                              ),
                              CustomElevatedButton(
                                btnWidth: constraints.maxWidth / 5,
                                btnHeight: 40,
                                icon: Icons.settings_outlined,
                                text: localizedStrings.gBtnSetting,
                                onPressed: () {
                                  mySettingParam = myModeSettingTakeIn;
                                  paramSettingDialog(context);
                                },
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
                                          weighingTakeInMode,
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal),
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
            SizedBox(
              width: 10,
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
            //           maxLines: 1,
            //           overflow: TextOverflow.ellipsis,
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
        PublicFunctions.deleteAllRecordsTakeIn(myDefScaleInfo.defScaleId!);
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
  //     errorText = "Excel save successful!";
  //   } catch (ex) {
  //     errorText = "Excel save fail!";
  //   }
  // }

  buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext innerContext) => AlertDialog(
        title: Text('导出结果'),
        content: Text('Excel 保存成功！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(innerContext).pop();
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

// "ReqData":"{\"ScaleId\": 2, \"Product\": \"Apple\", \"Weight\": \"1.230\", \"Price\": \"3.25\"}"}
  void sendReportDataToDB() {
    sendRptDataToDB(myWeightReportData, weighingTakeInMode);
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
    if (myReqWeightCountine.msgBody == null) {
      return false;
    }
    if (myReqWeightCountine.msgBody!.isZero) {
      return true;
    }
    return false;
  }

  void showDiffWeightVal() {
    double? nowWeightVal =
        double.tryParse(myReqWeightCountine.msgBody!.weightVal);
    nowWeightVal =
        double.parse((nowWeightVal! - basicWeightval).toStringAsFixed(3));
    if (weightValueList.isNotEmpty) {
      double tempDouble = nowWeightVal;
      for (var i = 0; i < weightValueList.length; i++) {
        tempDouble = tempDouble - weightValueList[i];
      }

      takeInWeightValue = tempDouble.toStringAsFixed(3);
    } else {
      takeInWeightValue = nowWeightVal.toStringAsFixed(3);
    }
    showTakeInWeight = nowWeightVal.toStringAsFixed(3);
  }

  void _addWeightToReport() {
    diffWeightVal = '0.000';
    if (_isTakeInStart) {
      if (isWeightValue()) {
        double? nowWeightVal =
            double.tryParse(myReqWeightCountine.msgBody!.weightVal);
        nowWeightVal =
            double.parse((nowWeightVal! - basicWeightval).toStringAsFixed(3));
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
        showTakeInWeight = nowWeightVal.toStringAsFixed(3);
        performAddToReport();
        takeInWeightValue = '0.000';
      } else {
        showTakeInWeight = myReqWeightCountine.msgBody!.weightVal;
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

      (_isTakeInStart)
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
      getDateTime(myModeSettingTakeIn.dateSeparator, dateformat),
    );

    myWeightReportData.add(addData);
  }

  List<WeightReportData> getWeightReportData() {
    return myWeightReportData;
  }
}
