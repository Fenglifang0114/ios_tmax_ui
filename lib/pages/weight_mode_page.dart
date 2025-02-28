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
import '../data/record_data.dart';
import '../data/scale_list_data.dart';
import '../data/scalelist_data.dart';
import '../data/timer_manager.dart';
import '../data/weight_report_data.dart';
import '../data/weight_rpt.dart';
import '../data/wgt_rpt_data_source.dart';
import '../dialog/conform_dialog.dart';
import '../dialog/setting_dialog.dart';
import '../dialog/weight_report_feilds_setting.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class WeightDataCollectionPage extends StatefulWidget {
  const WeightDataCollectionPage({super.key});
  @override
  State<WeightDataCollectionPage> createState() =>
      _WeightDataCollectionPageState();
}

class _WeightDataCollectionPageState extends State<WeightDataCollectionPage> {
  String dialogString = " ";

  late ScrollController _reportScrollerController;
  List<NetScaleInfoLocal> scaleNetItems = [];
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  int selScaleId = -1;

  late String lastWeight;
  String productNameValue = "";
  String userNameValue = "";
  String errorText = "";
  List<String> productNameList = [];
  List<String> userNameList = [];
  List<PluData> myPluInfoList = [];
  List<String> items = [];
  PluData? selectedPluData; // 用于存储选中的PluData

  ///创建文本控制器实例

  late int weightMode; //0,手动保存，1，连续保存，2，稳定保存
  late int dateformat;
  late double zeroRange;

  late Timer _saveTimer;
  late bool _isSaveButtonDisabled;
  late bool _isStableStatusJudge;
  int _stableSaveTime = 0;
  bool lastStableStatus = false;
  bool _isTiming = false;
  bool _isZero = false;
  bool _isPassZero = false;
  bool isCnting = false;
  bool isStart = false;
  int maxRecId = 0;
  bool firstGetRec = true;

  Timer? startTimer;
  Timer? innerTimer;

  late WeightReportDataSource _weightReportDataSource;
  List<WeightReportData> _weightReportDatas = <WeightReportData>[];
  List<WeightReportData> myWeightReportData = [];
  final DataGridController _dataGridController = DataGridController();

  int _currentPage = 1;
  void updateTableData(List<WeightReportData> newReportData) {
    _weightReportDataSource.updateData(newReportData);
  }

  _saveWeight(
    bool isStable,
  ) {
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
      _weightReportDataSource.sortDataGrid(
        "Date Time",
        DataGridSortDirection.descending,
      );
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

  void onStartTimer() {
    startTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      isCnting = false;
      innerTimer = Timer(Duration(seconds: 1), () {
        if (!isCnting && mounted) {
          setState(() {
            isStart = false;
          });
        }
      });
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
    cntScaleTimerMgr.startCntScaleTimer(10);
    _reportScrollerController = ScrollController();

    lastWeight = "*";
    dateformat = 1;
    zeroRange = 0;
    sortColumnName = 'Id';
    sortDirectValue = DataGridSortDirection.descending;

    PublicFunctions.getWeight(myDefScaleInfo.defScaleId!);
    if (myModeSettingNormal.recMode == msgManual) {
      weightMode = 1;
      _isSaveButtonDisabled = false;
    } else {
      _isSaveButtonDisabled = true;
      weightMode = 2;
    }
    _isStableStatusJudge = false;
    // getProductNameList();
    _weightReportDatas = getWeightReportData();
    _weightReportDataSource =
        WeightReportDataSource(_weightReportDatas, weighingMode);
    _weightReportDataSource.loadPage(_currentPage);

    PublicFunctions.getUserList();
    PublicFunctions.getProductList();
    // PublicFunctions.getRecords(myDefScaleInfo.defScaleId!, weighingMode);

    // onStartTimer();

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

          // getProductNameList();
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
                if (myReqWeightCountine.msgBody!.isZero) {
                  _isZero = true;
                  _isPassZero = true;
                } else {
                  _isZero = false;
                }

                // if (!_isZero) {
                //   var weight =
                //       double.tryParse(myReqWeightCountine.msgBody!.weightVal);
                // }

                break;
              case 2:
                if (myReqWeightCountine.msgBody!.isZero) {
                  _isZero = true;
                  _isPassZero = true;
                } else {
                  _isZero = false;
                }
                if (!myReqWeightCountine.msgBody!.isStable) {
                  _isStableStatusJudge = false;
                }
                _saveWeight(myReqWeightCountine.msgBody!.isStable);

                if (myReqWeightCountine.msgBody!.isStable == true &&
                    !_isZero &&
                    _isPassZero &&
                    _isStableStatusJudge &&
                    checkWgtValue(myReqWeightCountine.msgBody!.weightVal)) {
                  _isPassZero = false;
                  _isTiming = false;
                  _isStableStatusJudge = false;
                  _addWeightToReport();
                  sendReportDataToDB();

                  lastWeight = myReqWeightCountine.msgBody!.weightVal;
                }

                // if (!_isZero) {
                //   var weight =
                //       double.tryParse(myReqWeightCountine.msgBody!.weightVal);
                // }
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
          selectedPluData = event.obj;
          // checkProductList();
        });
      }
    });

    eventBus8 = eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          myModeSettingNormal = event.obj;
          weightMode = (myModeSettingNormal.recMode == msgManual)
              ? 1
              : (myModeSettingNormal.recMode == msgAuto)
                  ? 2
                  : 1;
          dateformat = int.parse(myModeSettingNormal.dateFormat);
          zeroRange = double.tryParse(myModeSettingNormal.zeroRange)!;
          String timeString = (myModeSettingNormal.stableTime == "")
              ? "0"
              : myModeSettingNormal.stableTime.toString();
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
      if (mounted) {
        setState(() {
          myGetScaleRecords = event.obj;
          if (myGetScaleRecords.weightRecords!.isNotEmpty) {
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
      }
    });
    eventBus11 = eventBus.on<EventDeleteRec>().listen((event) {
      if (mounted) {
        setState(() {
          maxRecId = 0;
          _weightReportDatas.clear();
          _weightReportDataSource.updateData(_weightReportDatas);
        });
      }
    });

    eventBus12 = eventBus.on<EventUpdateSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          PublicFunctions.getUIConfTakeOut(myDefScaleInfo.defScaleId!);
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

    eventBus14 = eventBus.on<EventSelWeighingScaleId>().listen((event) {
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

    eventBus15 = eventBus.on<EventRevExportRecs>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody != "") {
          if (mounted && context.mounted) {
            showConfirmationDialog(context, myRespDataFromScale.msgBody);
          }
        }
      }
    });
  }

  void _addDBdataToReport() {
    addDBdataToReport(myWeightReportData, myModeSettingNormal, dateformat);
    setState(() {
      _weightReportDataSource =
          WeightReportDataSource(_weightReportDatas, weighingMode);
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

    startTimer?.cancel();
    innerTimer?.cancel();
    productNameList.clear();
    myGetScaleRecords.weightRecords?.clear();
    myWeightReportData.clear();
    _dataGridController.dispose();
    _weightReportDataSource.dispose();
    _weightReportDatas.clear();
    PublicFunctions.stopWeight(selScaleId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: Container(
            child: pageHeadDefScale(
                context,
                localizedStrings.iTitleWeightCollection,
                localizedStrings.gTipWgtDataCollectionHelp),
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
      body: firstLayout(context, width),
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
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            width: 200,
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
                            width: 200,
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
                            width: 200,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomElevatedButton(
                              btnWidth: 100,
                              btnHeight: 40,
                              icon: Icons.title,
                              text: localizedStrings.gBtnTare,
                              onPressed: () {
                                PublicFunctions.performTare();
                              },
                            ),
                            CustomElevatedButton(
                              btnWidth: 100,
                              btnHeight: 40,
                              icon: Icons.exposure_zero,
                              text: localizedStrings.iBtnZero,
                              onPressed: () {
                                PublicFunctions.performZero();
                              },
                            ),
                            CustomElevatedButton(
                              btnWidth: 100,
                              btnHeight: 40,
                              icon: Icons.save_outlined,
                              text: localizedStrings.gBtnSave,
                              onPressed: _isSaveButtonDisabled
                                  ? null
                                  : _changeSaveButton,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomElevatedButton(
                              btnWidth: 100,
                              btnHeight: 40,
                              icon: Icons.settings_outlined,
                              text: localizedStrings.gBtnSetting,
                              onPressed: () {
                                //跳转页面
                                mySettingParam = myModeSettingNormal;
                                paramSettingDialog(context);
                              },
                            ),
                            CustomElevatedButton(
                                btnWidth: 100,
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
                                        weighingMode,
                                        outputFile);
                                    // await _creatFile(outputFile);
                                    // if (mounted && context.mounted) {
                                    //   showConfirmationDialog(
                                    //       context, errorText);
                                    // }
                                  }
                                }),
                            const SizedBox(
                              width: 160,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            Container(
                height: 40,
                color: Theme.of(context).colorScheme.onPrimary,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth / 10,
                        child: Text(
                          localizedStrings.gPluName,
                          textAlign: TextAlign.end,
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
                      SizedBox(
                        width: 10,
                      ),
                      CustomOutlinedButton(
                        btnWidth: constraints.maxWidth / 10,
                        btnHeight: 40,
                        icon: Icons.settings_applications_rounded,
                        text: localizedStrings.report_set_btn,
                        onPressed: () {
                          reportFieldsSettingDialog(context);
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CustomOutlinedButton(
                        btnWidth: constraints.maxWidth / 10,
                        btnHeight: 40,
                        icon: Icons.delete_forever_outlined,
                        text: localizedStrings.report_delete_btn,
                        onPressed: () {
                          _showConfirmationDialog(context);
                        },
                      ),
                    ],
                  );
                })),
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
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.gBtnConfirm,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(width: 20),
                CustomOutlinedButton(
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.gBtnCancel,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            )
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        PublicFunctions.deleteAllRecords(myDefScaleInfo.defScaleId!);
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

  // void getProductNameList() {
  //   if (myPluInfoList.isEmpty) {
  //     productNameList.clear();
  //     productNameValue = '';
  //     productNameList.add("Please select Plu");
  //     productNameValue = "Please select Plu";
  //     selectedPluData = null;
  //   } else if (myPluInfoList.isNotEmpty) {
  //     String? name;
  //     String? id;

  //     for (var i = 0; i < myPluInfoList.length; i++) {
  //       name = myPluInfoList[i].productName;
  //       id = myPluInfoList[i].plu.toString();
  //       name ??= "";
  //       id ??= "";
  //       productNameList.add(name);
  //     }
  //     if (!productNameList.contains(productNameValue)) {
  //       productNameValue = productNameList[0];
  //       selectedPluData = myPluInfoList[0];
  //       eventBus.fire(EventProductRecInfo(selectedPluData));
  //     } else {
  //       for (var i = 0; i < myPluInfoList.length; i++) {
  //         if (productNameValue == myPluInfoList[i].productName) {
  //           selectedPluData = myPluInfoList[i];
  //           eventBus.fire(EventProductRecInfo(selectedPluData));
  //         }
  //       }
  //     }
  //   }
  // }

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
  //   // Excel excel = Excel.createExcel();
  //   // await creatExcelFile(path, myWeightReportData, excel);
  //   await creatCsvFile(path, myWeightReportData);
  //   try {
  //     // var onValue = excel.encode();
  //     // File(join(path))
  //     //   ..createSync(recursive: true)
  //     //   ..writeAsBytesSync(onValue!);

  //     errorText = "Excel save succeed!";
  //   } catch (ex) {
  //     errorText = "Excel save fail!";
  //   }
  // }

// "ReqData":"{\"ScaleId\": 2, \"Product\": \"Apple\", \"Weight\": \"1.230\", \"Price\": \"3.25\"}"}
  void sendReportDataToDB() {
    sendRptDataToDB(myWeightReportData, weighingMode);
  }

  bool checkWgtValue(String str) {
    if (str.isEmpty) {
      return false;
    }
    // 尝试将字符串转换为 double 类型
    double? numValue = double.tryParse(str);

    if (numValue != null && numValue >= 0.02) {
      return true;
    }

    return false;
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
  }

  List<WeightReportData> getWeightReportData() {
    return myWeightReportData;
  }
}
