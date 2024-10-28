import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
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
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import '../data/language.dart';
import '../data/record_data.dart';
import '../data/scalelist_data.dart';
import '../data/weight_report_data.dart';
import '../data/weight_rpt.dart';
import '../data/wgt_rpt_data_source.dart';
import '../dialog/addproduct_dialog.dart';
import '../dialog/adduser_dialog.dart';
import '../dialog/conform_dialog.dart';
import '../dialog/setting_dialog.dart';
import 'package:path/path.dart';
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
  List<String> items = [];
  late ScrollController _reportScrollerController;
  late String lastWeight;
  bool isStart = false;
  String productNameValue = "";
  String userNameValue = "";
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
  bool isCnting = false;

  Timer? startTimer;
  Timer? innerTimer;

  late WeightReportDataSource _weightReportDataSource;
  List<WeightReportData> _weightReportDatas = <WeightReportData>[];
  List<WeightReportData> myWeightReportData = [];
  final DataGridController _dataGridController = DataGridController();

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

  @override
  void initState() {
    super.initState();
    _reportScrollerController = ScrollController();
    lastWeight = "*";
    dateformat = 1;
    zeroRange = 0;

    PublicFunctions.getWeight(myDefScaleInfo.defScaleId!);
    if (myModeSettingNormal.recMode == "manual") {
      weightMode = 1;
      _isSaveButtonDisabled = false;
    } else {
      _isSaveButtonDisabled = true;
      weightMode = 2;
    }
    _isStableStatusJudge = false;
    getProductNameList();
    _weightReportDatas = getWeightReportData();
    _weightReportDataSource = WeightReportDataSource(_weightReportDatas);
    PublicFunctions.getUserList();
    PublicFunctions.getProductList();
    PublicFunctions.getRecords(myDefScaleInfo.defScaleId!, weighingMode);

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
          ReqWeightCountine tempWeight = ReqWeightCountine();
          tempWeight = event.obj;
          if (tempWeight.scaleId == myDefScaleInfo.defScaleId!) {
            myReqWeightCountine = tempWeight;
            isStart = true;
            myComScaleInfo.isOnline = true;
            isCnting = true;

            switch (weightMode) {
              case 1:
                if (myReqWeightCountine.msgBody!.weightVal == "0" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.0" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.00" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.000" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.0000" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.00000") {
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
                if (myReqWeightCountine.msgBody!.weightVal == "0" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.0" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.00" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.000" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.0000" ||
                    myReqWeightCountine.msgBody!.weightVal == "0.00000") {
                  _isZero = true;
                  _isPassZero = true;
                } else {
                  _isZero = false;
                }
                _saveWeight(myReqWeightCountine.msgBody!.isStable);

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
          myProductRecInfo = event.obj;
          // checkProductList();
        });
      }
    });

    eventBus8 = eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          myModeSettingNormal = event.obj;
          weightMode = (myModeSettingNormal.recMode == "manual")
              ? 1
              : (myModeSettingNormal.recMode == "auto")
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
          PublicFunctions.getRecords(myDefScaleInfo.defScaleId!, weighingMode);
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
        if (myRespDataFromScale.msgBody.contains('ok')) {
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
    addDBdataToReport(myWeightReportData, myModeSettingNormal, dateformat);
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

    startTimer?.cancel();
    innerTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: pageHeadDefScale(
          context,
          localizedStrings.weight_collection_title,
        ),
      ),
      body: firstLayout(context, width),
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
                              text: localizedStrings.button_tare,
                              onPressed: () {
                                PublicFunctions.performTare();
                              },
                            ),
                            CustomElevatedButton(
                              btnWidth: 100,
                              btnHeight: 40,
                              icon: Icons.exposure_zero,
                              text: localizedStrings.button_zero,
                              onPressed: () {
                                PublicFunctions.performZero();
                              },
                            ),
                            CustomElevatedButton(
                              btnWidth: 100,
                              btnHeight: 40,
                              icon: Icons.save_outlined,
                              text: localizedStrings.button_save,
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
                              text: localizedStrings.button_setting,
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
                                text: localizedStrings.button_export_report,
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
                                    if (mounted && context.mounted) {
                                      showConfirmationDialog(
                                          context, errorText);
                                    }
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
                        height: 53,
                        width: constraints.maxWidth / 10,
                        padding: const EdgeInsets.all(0),
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
                                    myProductRecList
                                        .productRecInfo![i].product) {
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
                                child: Text(value,
                                    overflow: TextOverflow.ellipsis));
                          }).toList(),
                        ),
                      ),
                      CustomElevatedButton(
                        btnWidth: constraints.maxWidth / 10 - 30,
                        btnHeight: 40,
                        icon: Icons.edit_note_outlined,
                        text: localizedStrings.plu_edit,
                        onPressed: () {
                          PublicFunctions.getProductList();
                          addProductDialog(context).then((onvalue) {
                            if (!productNameList.contains(productNameValue)) {
                              myProductRecInfo.product = "";
                              productNameValue = "";
                              myProductRecInfo.id = "";
                              myProductRecInfo.withPretare = false;
                              myProductRecInfo.remarks = "";
                            }
                          });
                        },
                      ),
                      SizedBox(
                        width: constraints.maxWidth / 10,
                        child: TextButton(
                            onPressed: () {},
                            child: Text(localizedStrings.user_name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal))),
                      ),
                      Container(
                        height: 53,
                        width: constraints.maxWidth / 10,
                        padding: const EdgeInsets.all(0),
                        child: DropdownButtonFormField<String>(
                          itemHeight: 50.0,
                          isExpanded: true,
                          // decoration: const InputDecoration(border: OutlineInputBorder()),
                          value: userNameValue,
                          onChanged: (String? newPosition) {
                            setState(() {
                              userNameValue = newPosition.toString();
                              for (var i = 0;
                                  i < myUserInfoList.userInfo!.length;
                                  i++) {
                                if (userNameValue ==
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
                                child: Text(value,
                                    overflow: TextOverflow.ellipsis));
                          }).toList(),
                        ),
                      ),
                      CustomElevatedButton(
                        btnWidth: constraints.maxWidth / 10 - 30,
                        btnHeight: 40,
                        icon: Icons.edit_note_outlined,
                        text: localizedStrings.user_edit,
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
                        },
                      ),
                      CustomOutlinedButton(
                        btnWidth: constraints.maxWidth / 10 - 30,
                        btnHeight: 40,
                        icon: Icons.settings_applications_rounded,
                        text: localizedStrings.report_set_btn,
                        onPressed: () {
                          reportFieldsSettingDialog(context);
                        },
                      ),
                      CustomOutlinedButton(
                        btnWidth: constraints.maxWidth / 10 - 30,
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
                columns: getColumns(),
                columnWidthMode: ColumnWidthMode.fill,
                frozenRowsCount: 0,
                controller: _dataGridController,
                allowSorting: true,
              ),
            ))
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
                  text: localizedStrings.confirm_btn,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(width: 20),
                CustomOutlinedButton(
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.button_cancel,
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

  _creatFile(String path) {
    Excel excel = Excel.createExcel();
    creatExcelFile(path, myWeightReportData, excel);
    try {
      var onValue = excel.encode();
      File(join(path))
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue!);

      errorText = "Excel save succeed!";
    } catch (ex) {
      errorText = "Excel save fail!";
    }
  }

// "ReqData":"{\"ScaleId\": 2, \"Product\": \"Apple\", \"Weight\": \"1.230\", \"Price\": \"3.25\"}"}
  void sendReportDataToDB() {
    sendRptDataToDB(myWeightReportData, weighingMode);
  }

  void _addWeightToReport() {
    myWeightReportData.add(WeightReportData(
      (myWeightReportData.length + 1).toString(),
      getDateTime(myModeSettingNormal.dateSeparator, dateformat),
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
      myDefScaleInfo.defScaleName == null
          ? ''
          : myDefScaleInfo.defScaleName!, //此处应该是秤机种名
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
