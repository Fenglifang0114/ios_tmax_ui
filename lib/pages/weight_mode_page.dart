import 'dart:async';
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
import '../data/license_data.dart';
import '../dialog/addproduct_dialog.dart';
import '../dialog/adduser_dialog.dart';
import '../dialog/setting_dialog.dart';
import 'package:path/path.dart';

class WeightModePage extends StatefulWidget {
  const WeightModePage({Key? key}) : super(key: key);
  @override
  State<WeightModePage> createState() => _WeightModePageState();
}

class _WeightModePageState extends State<WeightModePage> {
  String dialogString = " ";
  List<String> items = [];
  List<DataRow> dataRows = [];
  late ScrollController _reportScrollerController;
  late String lastWeight;
  bool isStart = false;
  String productNameValue = "";
  String userNameValue = "";
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
  late WeightReportDataSource _weightReportDataSource;
  List<WeightReportData> _weightReportDatas = <WeightReportData>[];
  List<WeightReportData> myWeightReportData = [];
  final DataGridController _dataGridController = DataGridController();

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

  @override
  void initState() {
    super.initState();
    _reportScrollerController = ScrollController();
    dataRows.clear();
    weightMode = 2;
    lastWeight = "*";
    dateformat = 1;
    zeroRange = 0;
    _isSaveButtonDisabled = false;
    _isStableStatusJudge = false;
    getProductNameList();
    _weightReportDatas = getWeightReportData();
    _weightReportDataSource = WeightReportDataSource(_weightReportDatas);

    PublicFunctions.getUserList();
    PublicFunctions.getProductList();

    // if (myDevicedata.index == "1") {
    //   // getRecords();
    // }

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
          //  getWeight();
          switch (weightMode) {
            case 1:
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
          mySettingParam = event.obj;
          weightMode = (mySettingParam.recMode == "manual")
              ? 1
              : (mySettingParam.recMode == "auto")
                  ? 2
                  : 1;
          dateformat = int.parse(mySettingParam.dateFormat);
          zeroRange = double.tryParse(mySettingParam.zeroRange)!;
          String timeString = (mySettingParam.stableTimeToRec == "")
              ? "0"
              : mySettingParam.stableTimeToRec.toString();
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
      body: Container(
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
                        // decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(0),
                        //     boxShadow: [
                        //       BoxShadow(
                        //           color: Theme.of(context).colorScheme.primary,
                        //           offset: const Offset(0.0, 2.0),
                        //           blurStyle: BlurStyle.solid,
                        //           blurRadius: 1.0,
                        //           spreadRadius: 0.0),
                        //     ]),
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                            // SizedBox(
                            //   width: 50,
                            // ),
                            // SizedBox(
                            //   width: 200,
                            //   child: Text(myDevicedata.name,
                            //       maxLines: 1,
                            //       textWidthBasis: TextWidthBasis.longestLine,
                            //       overflow: TextOverflow.ellipsis,
                            //       style: const TextStyle(
                            //           color: Color(0xFF004a98),
                            //           fontSize: 16,
                            //           fontWeight: FontWeight.normal)),
                            // ),
                          ],
                        )),
                  ],
                ),
              ),
              //////////////////////////////////
              const SizedBox(height: 5),
              Container(
                height: 100,
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
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              (myReqWeightCountine.msgBody == null)
                                  ? ("assets/images/gray.png")
                                  : (myReqWeightCountine.msgBody!.isStable ==
                                          true)
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
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              (myReqWeightCountine.msgBody == null)
                                  ? ("assets/images/gray.png")
                                  : (myReqWeightCountine.msgBody!.isNet == true)
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
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              (myReqWeightCountine.msgBody == null)
                                  ? ("assets/images/gray.png")
                                  : (((myReqWeightCountine.msgBody!.isStable ==
                                                  true) &&
                                              (double.tryParse(
                                                      myReqWeightCountine
                                                          .msgBody!
                                                          .weightVal) ==
                                                  0)) ||
                                          ((myReqWeightCountine
                                                      .msgBody!.isStable ==
                                                  true) &&
                                              (((double.tryParse(
                                                              myReqWeightCountine
                                                                  .msgBody!
                                                                  .weightVal) ==
                                                          null)
                                                      ? 0
                                                      : double.tryParse(
                                                          myReqWeightCountine
                                                              .msgBody!
                                                              .weightVal))! <=
                                                  zeroRange)))
                                      ? ("assets/images/blue.png")
                                      : ("assets/images/gray.png"),
                              width: 25,
                              height: 25,
                            )
                          ],
                        ),
                      ],
                    ),
                    // const SizedBox(width: 10),
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
                                        ? ("0.000")
                                        : myReqWeightCountine
                                            .msgBody!.weightVal,
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
                        const SizedBox(
                          width: 5,
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
                        )
                      ],
                    ),
                    const SizedBox(width: 5),
                    Column(
                      children: [
                        const SizedBox(height: 15),
                        ElevatedButton(
                            onPressed: () {
                              PublicFunctions.performTare();
                            },
                            child: Text(localizedStrings.button_tare,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal))),
                        const SizedBox(height: 15),
                        ElevatedButton(
                            onPressed: () {
                              PublicFunctions.performZero();
                            },
                            child: Text(localizedStrings.button_zero,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal))),
                      ],
                    ),
                    // const SizedBox(width: 10),
                    Column(
                      children: [
                        const SizedBox(height: 15),
                        ElevatedButton(
                            onPressed: _isSaveButtonDisabled
                                ? null
                                : _changeSaveButton,
                            child: Text(localizedStrings.button_save,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal))),
                        const SizedBox(height: 15),
                        OutlinedButton(
                            onPressed: () {
                              //跳转页面
                              paramSettingDialog(context);
                            },
                            child: Text(localizedStrings.button_setting,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal))),
                      ],
                    ),
                    // const SizedBox(width: 10),
                    Column(
                      children: [
                        const SizedBox(height: 15),
                        OutlinedButton(
                            // elevation: 5.0,
                            child: Text(localizedStrings.button_export_report,
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

                              setState(() {
                                _errorText.text = "success";
                              });
                            }),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                      height: 30,
                      child: TextField(
                        enabled: false,
                        controller: _errorText, //报错信息
                        maxLength: 100,
                        style: const TextStyle(color: Colors.red),
                        maxLines: 3,
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: const InputDecoration(
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          counterText: "",
                          focusColor: Colors.red, // hintText: "请输入机种类型，如：ztp",
                          // border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {},
                      ),
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
              Container(
                height: 40,
                color: Colors.white,
                child: Row(
                  children: [
                    Text(localizedStrings.plu_name),
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
                      height: 53,
                      width: 200,
                      padding: const EdgeInsets.all(0),
                    ),
                    const SizedBox(width: 10),
                    MaterialButton(
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
                    const SizedBox(width: 50),
                    TextButton(
                        onPressed: () {},
                        child: Text(localizedStrings.user_name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal))),
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
                      width: 200,
                      padding: const EdgeInsets.all(0),
                    ),
                    // const SizedBox(width: 10),
                    MaterialButton(
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
                  ],
                ),
              ),
              Expanded(
                child: SfDataGrid(
                  source: _weightReportDataSource,
                  columns: getColumns,
                  columnWidthMode: ColumnWidthMode.fill,
                  frozenRowsCount: 0,
                  controller: _dataGridController,
                ),
              )
            ],
          )),
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

  String getDateTime() {
    // 1 yymmdd   2 ddmmyy 3 mmddyy
    var currTime = DateTime.now();
    String format = '';
    if (dateformat == 1) {
      format =
          "${currTime.year}-${pad0(currTime.month)}-${pad0(currTime.day)} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
    } else if (dateformat == 2) {
      format =
          "${pad0(currTime.day)}-${pad0(currTime.month)}-${currTime.year} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
    } else if (dateformat == 3) {
      format =
          "${pad0(currTime.month)}-${pad0(currTime.day)}-${currTime.year} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
    }
    return format;
  }

  _creatFile(String path) {
    List<String> title = [
      'RecId',
      'DateTime',
      'Weight',
      'Weight Unit',
      'PLU No.',
      'PLU Name',
      'PLU Remarks',
      'Pretare',
      'User Name',
      'User Remarks',
      'ScaleName',
    ];

    Excel excel = Excel.createExcel();
    Sheet sh = excel['Sheet1'];
    for (var i = 0; i < title.length; i++) {
      sh.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i)).value =
          title[i];
    }

    for (int row = 1; row <= myWeightReportData.length; row++) {
      for (int col = 0; col < 11; col++) {
        switch (col) {
          case 0:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].id;
            break;
          case 1:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].dateTime;
            break;
          case 2:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].weight;
            break;
          case 3:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].weightUnit;
            break;
          case 4:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].pLU;
            break;
          case 5:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].pluName;
            break;
          case 6:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].pluRemarks;
            break;
          case 7:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].pretare;
            break;
          case 8:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].userName;
            break;
          case 9:
            sh
                .cell(
                    CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                .value = myWeightReportData[row - 1].userRemarks;
            break;
          case 10:
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
      _errorText.text = "Excel save succeed!";
    } catch (ex) {
      _errorText.text = ex.toString();
    }
  }

  _addWeightToReport() {
    myWeightReportData.add(WeightReportData(
      (myWeightReportData.length + 1).toString(),
      getDateTime(),
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
      (myUserInfo.remarks == null) ? "" : myUserInfo.remarks.toString(),
      myDevicedata.name,
    ));
    setState(() {
      _weightReportDataSource = WeightReportDataSource(_weightReportDatas);
      Future.delayed(const Duration(milliseconds: 100), () {
        _dataGridController
            .scrollToRow(_weightReportDataSource.rows.length - 0);
      });
      // _dataGridController.scrollToRow(_weightReportDataSource.rows.length - 1);
    });
  }

  List<WeightReportData> getWeightReportData() {
    return myWeightReportData;
  }
}

List<GridColumn> get getColumns {
  return [
    GridColumn(
        columnName: 'id',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text(
              'ID',
              overflow: TextOverflow.ellipsis,
            ))),
    GridColumn(
        columnName: 'dateTime',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('DateTime', overflow: TextOverflow.ellipsis))),
    GridColumn(
        columnName: 'weight',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('Weight', overflow: TextOverflow.ellipsis))),
    GridColumn(
        columnName: 'weightUnit',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('WeightUnit', overflow: TextOverflow.ellipsis))),
    GridColumn(
        columnName: 'pLU',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('PLU', overflow: TextOverflow.ellipsis))),
    GridColumn(
        columnName: 'pluName',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('PluName', overflow: TextOverflow.ellipsis))),
    GridColumn(
        columnName: 'pluRemarks',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('PluRemarks', overflow: TextOverflow.ellipsis))),
    GridColumn(
        columnName: 'pretare',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('Pretare', overflow: TextOverflow.ellipsis))),
    GridColumn(
        columnName: 'userName',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('UserName', overflow: TextOverflow.ellipsis))),
    GridColumn(
        columnName: 'userRemarks',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('UserRemarks', overflow: TextOverflow.ellipsis))),
    GridColumn(
        columnName: 'scaleName',
        label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: const Text('ScaleName', overflow: TextOverflow.ellipsis))),
  ];
}

class WeightReportDataSource extends DataGridSource {
  WeightReportDataSource(List<WeightReportData> weightReportDatas) {
    buildDataGridRow(weightReportDatas);
  }
  void buildDataGridRow(List<WeightReportData> weightReportData) {
    dataGridRow = weightReportData.map<DataGridRow>((reportData) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'id', value: reportData.id),
        DataGridCell<String>(
            columnName: 'dateTime', value: reportData.dateTime),
        DataGridCell<String>(columnName: 'weight', value: reportData.weight),
        DataGridCell<String>(
            columnName: 'weightUnit', value: reportData.weightUnit),
        DataGridCell<String>(columnName: 'pLU', value: reportData.pLU),
        DataGridCell<String>(columnName: 'pluName', value: reportData.pluName),
        DataGridCell<String>(
            columnName: 'pluRemarks', value: reportData.pluRemarks),
        DataGridCell<String>(columnName: 'pretare', value: reportData.pretare),
        DataGridCell<String>(
            columnName: 'userName', value: reportData.userName),
        DataGridCell<String>(
            columnName: 'userRemarks', value: reportData.userRemarks),
        DataGridCell<String>(
            columnName: 'scaleName', value: reportData.scaleName),
      ]);
    }).toList();
  }

  List<DataGridRow> dataGridRow = <DataGridRow>[];
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

class WeightReportData {
  WeightReportData(
    this.id,
    this.dateTime,
    this.weight,
    this.weightUnit,
    this.pLU,
    this.pluName,
    this.pluRemarks,
    this.pretare,
    this.userName,
    this.userRemarks,
    this.scaleName,
  );
  final String id;
  final String dateTime;
  final String weight;
  final String weightUnit;
  final String pLU;
  final String pluName;
  final String pluRemarks;
  final String pretare;
  final String scaleName;
  final String userName;
  final String userRemarks;
}
