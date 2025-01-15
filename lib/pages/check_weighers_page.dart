import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/high_low_weight.dart';
import '../../data/device_data.dart';
import '../../data/productlist_data.dart';
import '../../data/report_data.dart';
import '../../data/reqweightdata_data.dart';
import '../../data/settingparam_data.dart';
import '../../data/userinfo_data.dart';
import '../../data/weight_data.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/comscaleinfo_data.dart';
import '../data/const_var_data.dart';
import '../data/manager_scale_channel.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/plu_data_source.dart';
import '../data/plu_info_list_data.dart';
import '../data/record_data.dart';
import '../data/scale_list_data.dart';
import '../data/scalelist_data.dart';
import '../data/timer_manager.dart';
import '../data/weight_report_data.dart';
import '../data/weight_rpt.dart';
import '../data/wgt_rpt_data_source.dart';
import '../dialog/conform_dialog.dart';
import '../dialog/high_low_setting.dart';
import '../dialog/setting_dialog.dart';
import 'package:path/path.dart';
import '../dialog/weight_report_feilds_setting.dart';
import '../functions/weight_funcs.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class CheckWeighersPage extends StatefulWidget {
  const CheckWeighersPage({super.key});
  @override
  State<CheckWeighersPage> createState() => _CheckWeighersPageState();
}

class _CheckWeighersPageState extends State<CheckWeighersPage> {
  List<String> productNameList = [];
  List<String> userNameList = [];
  List<String> items = [];

  List<WeightReportData> _weightReportDatas = <WeightReportData>[];
  List<WeightReportData> myWeightReportData = [];
  List<PluData> myPluInfoList = [];
  PluData? selectedPluData; // 用于存储选中的PluData
  List<NetScaleInfoLocal> scaleNetItems = [];
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  int selScaleId = -1;

  late ScrollController _reportScrollerController;
  String errorText = "";
  late WeightReportDataSource _weightReportDataSource;
  final DataGridController _dataGridController = DataGridController();

  late String lastWeight;
  late double zeroRange;
  late bool _isSaveButtonDisabled;
  late bool _isStableStatusJudge;
  late int weightMode; //0,手动保存，1，连续保存，2，稳定保存
  late int dateformat;

  Timer? _saveTimer;

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
  bool isCnting = false;

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

  Timer? startTimer;
  Timer? innerTimer;

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
        _saveTimer?.cancel();
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
    _reportScrollerController = ScrollController();
    lastWeight = "*";
    dateformat = 1;
    zeroRange = 0;

    if (myModeSettingCheck.recMode == msgManual) {
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
    // getProductNameList();
    _weightReportDatas = getWeightReportData();
    _weightReportDataSource = WeightReportDataSource(_weightReportDatas);
    PublicFunctions.getUserList();
    PublicFunctions.getProductList();
    PublicFunctions.getRecords(myDefScaleInfo.defScaleId!, weighingCheckMode);

    PublicFunctions.getWeight(myDefScaleInfo.defScaleId!);
    cntScaleTimerMgr.startCntScaleTimer(10);

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
                if (!myReqWeightCountine.msgBody!.isStable) {
                  _isStableStatusJudge = false;
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
                    } else if (myModeSettingCheck.saveMode == lowMode &&
                        _isLow) {
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
          weightMode = (myModeSettingCheck.recMode == msgManual)
              ? 1
              : (myModeSettingCheck.recMode == msgAuto)
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
        } else {
          myWeightReportData.clear();
          updateTableData(getWeightReportData());
        }
      });
    });

    eventBus11 = eventBus.on<EventDeleteRec>().listen((event) {
      if (mounted) {
        setState(() {
          PublicFunctions.getRecords(
              myDefScaleInfo.defScaleId!, weighingCheckMode);
        });
      }
    });

    eventBus12 = eventBus.on<EventUpdateSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          PublicFunctions.getUIConfCheck(myDefScaleInfo.defScaleId!);
        });
      }
    });

    eventBus13 = eventBus.on<EventRegWeightResp>().listen((event) {
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

    eventBus14 = eventBus.on<EventRespCheckNetScale>().listen((event) {
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

    eventBus15 = eventBus.on<EventSelWeighingScaleId>().listen((event) {
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
            PublicFunctions.getRecords(
                myDefScaleInfo.defScaleId!, weighingCheckMode);
          });
        }
      }
    });
  }

  void _addDBdataToReport() {
    addDBdataToReport(myWeightReportData, myModeSettingCheck, dateformat);
    setState(() {
      _weightReportDataSource = WeightReportDataSource(_weightReportDatas);
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
    cntScaleTimerMgr.stopPortOffTimer();
    _saveTimer?.cancel();

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
            child:
                pageHeadDefScale(context, localizedStrings.iTitleCheckWeigher),
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

  Widget firstLayout(BuildContext context, double width) {
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
                      flex: 3,
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
                        flex: 6,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildTextWithWeight(
                                  Theme.of(context).colorScheme,
                                  (myReqWeightCountine.msgBody == null ||
                                          !isStart)
                                      ? ("--------")
                                      : myReqWeightCountine.msgBody!.weightVal,
                                  constraints,
                                  Theme.of(context).colorScheme.primary),
                              buildTextWithUnit(
                                Theme.of(context).colorScheme,
                                (myReqWeightCountine.msgBody == null ||
                                        !isStart)
                                    ? ("---")
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
                        isTrue: isStart,
                        icon: Icons.title),
                    _buildFlexibleButtonAndText(
                        buttonText: localizedStrings.iBtnZero,
                        onPressed: PublicFunctions.performZero,
                        constraints: constraints,
                        isTrue: isStart,
                        icon: Icons.exposure_zero),
                    _buildFlexibleButtonAndText(
                        buttonText: localizedStrings.gBtnSave,
                        onPressed: _changeSaveButton,
                        constraints: constraints,
                        isTrue: !_isSaveButtonDisabled && isStart,
                        icon: Icons.save_outlined),
                    _buildFlexibleButtonAndText(
                        buttonText: 'Edit',
                        onPressed: () {
                          highLowSettingDialog(context);
                        },
                        constraints: constraints,
                        isTrue: true,
                        icon: Icons.mode_edit),
                    _buildFlexibleButtonAndText(
                        buttonText: localizedStrings.gBtnSetting,
                        onPressed: () {
                          mySettingParam = myModeSettingCheck;
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
                          //   width: constraints.maxWidth / 5,
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
                            btnWidth: constraints.maxWidth / 10 - 30,
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
            textAlign: TextAlign.right,
            style:
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.normal)));
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
                CustomElevatedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.gBtnConfirm,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(width: 20),
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.gBtnCancel,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        PublicFunctions.deleteAllRecordsCheck((myDefScaleInfo.defScaleId!));
      }
    });
  }

  Widget buildSetReportButton(
      String text, BoxConstraints constraints, BuildContext context) {
    var fontSize = 14 * constraints.maxHeight / 60;
    var width = constraints.maxWidth / 10;
    return SizedBox(
      width: width,
      child: MaterialButton(
          color: Theme.of(context).colorScheme.primary,
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

  Widget buildTextWithWeight(ColorScheme colorScheme, String text,
      BoxConstraints constraints, Color? color) {
    double width = constraints.maxWidth / 10 * 7;
    double height = constraints.maxHeight / 1.1;
    double fontSize = width / 10 / 0.6;

    if (fontSize > 109) {
      fontSize = 109;
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

  Widget buildTextWithUnit(
      ColorScheme colorScheme, String text, BoxConstraints constraints) {
    double width = constraints.maxWidth / 10 * 2;
    double height = constraints.maxHeight / 1.1;
    double fontSize = width / 5 / 0.6;

    if (fontSize > 109) {
      fontSize = 109;
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
    var imageSize = constraints.maxHeight / 5;
    double width = constraints.maxWidth / 1.5;
    var fontSize = 16 * constraints.maxHeight / 150;
    if (imageSize > 60) {
      imageSize = 60;
    }
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
    required String buttonText,
    required VoidCallback onPressed,
    required BoxConstraints constraints,
    required bool isTrue,
    required IconData icon,
  }) {
    double buttonWidth = (constraints.maxWidth / 8); // 自适应按钮宽度
    double buttonH = (constraints.maxHeight / 2); // 自适应按钮宽度
    double fontSize = (buttonWidth / 10 / 0.6); // 自适应字体大小
    if (fontSize > 34) {
      fontSize = 34;
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
              height: buttonH,
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

  Widget secondLayout(BuildContext context, double width) {
    return Container(
        width: width,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Theme.of(context).colorScheme.onPrimary,
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
                                        .surfaceContainerHigh
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
                            width: 50,
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
                            width: 50,
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
                            width: 50,
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
                          width: 300,
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
                                onPressed: !isStart
                                    ? null
                                    : () {
                                        PublicFunctions.performTare();
                                      },
                              ),
                              CustomElevatedButton(
                                btnWidth: constraints.maxWidth / 5,
                                btnHeight: 40,
                                icon: Icons.exposure_zero,
                                text: localizedStrings.iBtnZero,
                                onPressed: !isStart
                                    ? null
                                    : () {
                                        PublicFunctions.performZero();
                                      },
                              ),
                              CustomElevatedButton(
                                btnWidth: constraints.maxWidth / 5,
                                btnHeight: 40,
                                icon: Icons.save_outlined,
                                text: localizedStrings.gBtnSave,
                                onPressed: (_isSaveButtonDisabled || !isStart)
                                    ? null
                                    : _changeSaveButton,
                              ),
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
                                icon: Icons.edit_sharp,
                                text: localizedStrings.button_edit,
                                onPressed: () {
                                  highLowSettingDialog(context);
                                },
                              ),
                              CustomElevatedButton(
                                btnWidth: constraints.maxWidth / 5,
                                btnHeight: 40,
                                icon: Icons.settings_outlined,
                                text: localizedStrings.gBtnSetting,
                                onPressed: () {
                                  //跳转页面
                                  mySettingParam = myModeSettingCheck;
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
                                      allowedExtensions: ["xlsx"],
                                      fileName: 'report.xlsx',
                                    ));
                                    if (outputFile != null) {
                                      if (!outputFile.contains(".xlsx")) {
                                        outputFile = "$outputFile.xlsx";
                                      }
                                      _creatFile(outputFile);
                                      if (mounted && context.mounted) {
                                        showConfirmationDialog(
                                            context, errorText);
                                      }
                                    }
                                  }),
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
                        localizedStrings.gPluName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      height: 53,
                      width: constraints.maxWidth / 6,
                      padding: const EdgeInsets.all(0),
                      child: Autocomplete<PluData>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<PluData>.empty();
                          }
                          return myPluInfoList.where((PluData data) {
                            // 进行模糊查找，这里同时匹配productName和plu转成字符串后的内容
                            return data.productName!.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase()) ||
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

                    // CustomElevatedButton(
                    //   btnWidth: constraints.maxWidth / 10 - 50,
                    //   btnHeight: 40,
                    //   icon: Icons.edit_note_outlined,
                    //   text: localizedStrings.plu_edit,
                    //   onPressed: () {
                    //     PublicFunctions.getProductList();
                    //     addProductDialog(context).then((onvalue) {
                    //       if (!productNameList.contains(productNameValue)) {
                    //         myProductRecInfo.product = "";
                    //         productNameValue = "";
                    //         myProductRecInfo.id = "";
                    //         myProductRecInfo.withPretare = false;
                    //         myProductRecInfo.remarks = "";
                    //       }
                    //     });
                    //   },
                    // ),
                    // SizedBox(
                    //   width: constraints.maxWidth / 10,
                    //   child: TextButton(
                    //       onPressed: () {},
                    //       child: Text(localizedStrings.user_name,
                    //           style: const TextStyle(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.normal))),
                    // ),
                    // Container(
                    //   height: 53,
                    //   width: constraints.maxWidth / 6,
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
                    //     items: userNameList
                    //         .map<DropdownMenuItem<String>>((String value) {
                    //       return DropdownMenuItem(
                    //           value: value,
                    //           child:
                    //               Text(value, overflow: TextOverflow.ellipsis));
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
            ),

            Expanded(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: SfDataGrid(
                    source: _weightReportDataSource,
                    columns: getColumns(),
                    columnWidthMode: ColumnWidthMode.fill,
                    frozenRowsCount: 0,
                    controller: _dataGridController,
                    allowSorting: true,
                  )),
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

  _creatFile(String path) {
    Excel excel = Excel.createExcel();
    creatExcelFile(path, myWeightReportData, excel);

    try {
      var onValue = excel.encode();
      File(join(path))
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue!);

      errorText = "Excel save successful!";
    } catch (ex) {
      errorText = "Excel save failed!";
    }
  }

// "ReqData":"{\"ScaleId\": 2, \"Product\": \"Apple\", \"Weight\": \"1.230\", \"Price\": \"3.25\"}"}
  void sendReportDataToDB() {
    sendRptDataToDB(myWeightReportData, weighingCheckMode);
  }

  void _addWeightToReport() {
    PluData? tempPlu = PluData(null, null, null, null, null, null, null, null,
        null, null, null, null, null, null);
    if (selectedPluData != null) {
      tempPlu = selectedPluData;
    }
    WeightReportData addData = WeightReportData(
      (myWeightReportData.length + 1).toString(),
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

      (myReqWeightCountine.msgBody?.weightVal == null)
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
      getDateTime(myModeSettingNormal.dateSeparator, dateformat),
    );

    myWeightReportData.add(addData);

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
