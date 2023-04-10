import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/data/currentport_data.dart';
import 'package:t_max/data/productlist_data.dart';
import 'package:t_max/data/userinfo_data.dart';
import 'package:t_max/pages/dialog/addproduct_dialog.dart';
import '../../data/report_data.dart';
import '../../data/reqweightdata_data.dart';
import '../../data/scalecmd_data.dart';
import '../../data/settingparam_data.dart';
import '../../main.dart';
import '../addDevice_page.dart';
import '../dialog/adduser_dialog.dart';
import '../dialog/modifyBluetooth_dialog.dart';
import '../../data/weight_data.dart';
import '../../data/device_data.dart';
import '../../eventbus/eventbus.dart';
import '../dialog/modifyComPort_dialog.dart';
import '../dialog/modifyNetwork_dialog.dart';
import '../dialog/setting_dialog.dart';
import '../dialog/showComPort_dialog.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ShowWeightReport extends StatefulWidget {
  const ShowWeightReport({Key? key}) : super(key: key);
  @override
  State<ShowWeightReport> createState() => _ShowWeightReportState();
}

class _ShowWeightReportState extends State<ShowWeightReport> {
  String dialogString = " ";
  List<String> items = [];
  List<DataRow> dataRows = [];
  late ScrollController _reportScrollerController;
  late String lastWeight;
  bool isStart = false;
  String productNameValue = "";
  String userNameValue = "";
  // String userNameValue = "";
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
    checkProductList();
    _weightReportDatas = getWeightReportData();
    _weightReportDataSource = WeightReportDataSource(_weightReportDatas);

    // if (myDevicedata.index == "1") {
    //   // getRecords();
    // }

    eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
          // getWeight();
          // getRecords();
        });
      }
    });
    eventBus.on<EventProductRecList>().listen((event) {
      if (mounted) {
        setState(() {
          myProductRecList = event.obj;
          getProductNameList();
          // getWeight();
          // getRecords();
        });
      }
    });

    eventBus.on<EventReqWeightCountine>().listen((event) {
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

    eventBus.on<EventCurrentPort>().listen((event) {
      if (mounted) {
        setState(() {
          myCurrentPort = event.obj;
        });
      }
    });
    eventBus.on<EventWtData>().listen((event) {
      if (mounted) {
        setState(() {
          myWtData = event.obj;
        });
      }
    });
    eventBus.on<EventReportData>().listen((event) {
      if (mounted) {
        setState(() {
          myReportData = event.obj;
        });
      }
    });
    eventBus.on<EventComInfoList>().listen((event) {
      if (mounted) {
        setState(() {
          myComInfoList = event.obj;
          checkPortList();
        });
      }
    });

    eventBus.on<EventProductRecInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myProductRecInfo = event.obj;
          checkProductList();
        });
      }
    });

    eventBus.on<EventSettingParam>().listen((event) {
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
    eventBus.on<EventUserInfoList>().listen((event) {
      if (mounted) {
        setState(() {
          myUserInfoList = event.obj;
          checkUserList();
        });
      }
    });
  }

  @override
  void dispose() {
    _reportScrollerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AlertDialog dialog = AlertDialog(
      content: Text(
        (dialogString.isEmpty) ? "" : dialogString,
        style: TextStyle(
            fontSize: 18.0,
            color: (dialogString == "Success!")
                ? Colors.green.shade900
                : Colors.red.shade900),
      ),
    );

    final _width = MediaQuery.of(context).size.width;

    return Container(
        width: _width - 220,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                      // width: 250,
                      height: 40,
                      margin: const EdgeInsets.only(left: 5, top: 2),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blue.shade900,
                                offset: const Offset(0.0, 2.0),
                                blurStyle: BlurStyle.solid,
                                blurRadius: 1.0,
                                spreadRadius: 0.0),
                          ]),
                      alignment: Alignment.center, //设置控件内容的位置
                      child: Row(
                        children: [
                          (myDevicedata.type == "Icons.usb")
                              ? Icon(Icons.usb, color: Colors.green.shade900)
                              : (myDevicedata.type == "Icons.usb_off")
                                  ? Icon(Icons.usb, color: Colors.red.shade900)
                                  : (myDevicedata.type ==
                                          "Icons.device_unknown")
                                      ? const Icon(Icons.device_unknown,
                                          color:
                                              Color.fromARGB(255, 240, 133, 0))
                                      : (myDevicedata.type == "Icons.wifi")
                                          ? const Icon(Icons.wifi,
                                              color: Colors.white)
                                          : const Text(
                                              "Please select a device first...",
                                              style: TextStyle(
                                                  color: Color(0xff004a98)),
                                            ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 200,
                            child: Text(myDevicedata.name,
                                maxLines: 1,
                                textWidthBasis: TextWidthBasis.longestLine,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFF004a98),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          // Text(myDevicedata.name,
                          //     style: const TextStyle(
                          //         color: Color(0xFF004a98),
                          //         fontSize: 18,
                          //         fontWeight: FontWeight.bold)),
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
                children: [
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const SizedBox(
                            width: 50,
                            child: Text("Stable"),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            (myReqWeightCountine.msgBody == null)
                                ? ("images/gray.png")
                                : (myReqWeightCountine.msgBody!.isStable ==
                                        true)
                                    ? ("images/green.png")
                                    : ("images/red.png"),
                            width: 25,
                            height: 25,
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const SizedBox(
                            width: 50,
                            child: Text("Net"),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            (myReqWeightCountine.msgBody == null)
                                ? ("images/gray.png")
                                : (myReqWeightCountine.msgBody!.isNet == true)
                                    ? ("images/green.png")
                                    : ("images/red.png"),
                            width: 25,
                            height: 25,
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const SizedBox(
                            width: 50,
                            child: Text("Zero"),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            (myReqWeightCountine.msgBody == null)
                                ? ("images/gray.png")
                                : (((myReqWeightCountine.msgBody!.isStable ==
                                                true) &&
                                            (double.tryParse(myReqWeightCountine
                                                    .msgBody!.weightVal) ==
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
                                    ? ("images/green.png")
                                    : ("images/red.png"),
                            width: 25,
                            height: 25,
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                      width: 300,
                      height: 70,
                      color: (myReqWeightCountine.msgBody == null)
                          ? (Colors.blue.shade900)
                          : (myReqWeightCountine.msgBody!.isStable == true)
                              ? (Colors.green.shade900)
                              : (Colors.red.shade900),
                      // alignment: Alignment.bottomRight, //设置控件内容的位置
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              textAlign: TextAlign.right,
                              (myReqWeightCountine.msgBody == null)
                                  ? ("0.000")
                                  : myReqWeightCountine.msgBody!.weightVal,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 55),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10)
                        ],
                      )),
                  const SizedBox(width: 10),
                  Container(
                    width: 100,
                    height: 70,
                    color: (myReqWeightCountine.msgBody == null)
                        ? (Colors.blue.shade900)
                        : (myReqWeightCountine.msgBody!.isStable == true)
                            ? (Colors.green.shade900)
                            : (Colors.red.shade900),
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

                  const SizedBox(width: 10),
                  Row(
                    children: [
                      IconButton(
                        //开始按钮
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 30,
                        color:
                            (isStart) ? (Colors.grey) : (Colors.blue.shade900),
                        onPressed: () {
                          setState(() {
                            if (!isStart) {
                              if (webchannel1.heartStatus == true) {
                                isStart = true;
                                getWeight();
                              }
                            }
                          });
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          if (isStart) {
                            setState(() {
                              if (webchannel1.heartStatus == true) {
                                isStart = false;
                                stopWeight();
                              }
                            });
                          }
                        },
                        icon: const Icon(Icons.pause),
                        iconSize: 30,
                        color:
                            (!isStart) ? (Colors.grey) : (Colors.blue.shade900),
                      ),
                    ],
                  ),
                  const SizedBox(width: 5),
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      ElevatedButton(
                          onPressed: () {
                            performTare();
                            // MyApp.getSock().send('uicmd', jsonEncode(myUiCmd.tare));
                          },
                          child: const Text("Tare")),
                      const SizedBox(height: 15),
                      ElevatedButton(
                          onPressed: () {
                            performZero();
                            // MyApp.getSock().send('uicmd', jsonEncode(myUiCmd.zero));
                          },
                          child: const Text("Zero")),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      ElevatedButton(
                          onPressed:
                              _isSaveButtonDisabled ? null : _changeSaveButton,
                          child: const Text("Save")),
                      const SizedBox(height: 15),
                      OutlinedButton(
                          onPressed: () {
                            //跳转页面
                            settingDialog(context).then((onvalue) {});

                            // Navigator.of(context).push(MaterialPageRoute(
                            //     //没有传值
                            //     builder: (context) => const ChangeParamPage()));
                          },
                          child: const Text("Setting")),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      ElevatedButton(
                          // elevation: 5.0,
                          child: const Text("Device Edit"),
                          onPressed: () {
                            (myDevicedata.type == "Icons.usb")
                                ? modifyAddComPortDialog(context)
                                    .then((onValue) {})
                                : (myDevicedata.type == "Icons.usb_off")
                                    ? modifyAddComPortDialog(context)
                                        .then((onValue) {})
                                    : (myDevicedata.type == "Icons.wifi")
                                        ? modifyAddNetworkDialog(context)
                                            .then((onValue) {})
                                        : modifyAddBluetoothDialog(context)
                                            .then((onValue) {});
                          }),
                      const SizedBox(height: 15),
                      OutlinedButton(
                          // elevation: 5.0,
                          child: const Text("Export report"),
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
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        counterText: "",
                        focusColor: Colors.red, // hintText: "请输入机种类型，如：ztp",
                        // border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(width: 20),
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
                  TextButton(
                      onPressed: () {}, child: const Text("Product Name:")),
                  Container(
                    child: DropdownButtonFormField<String>(
                      itemHeight: 50.0,
                      isExpanded: true,
                      // decoration: const InputDecoration(border: OutlineInputBorder()),
                      value: productNameValue,
                      onChanged: (String? newPosition) {
                        setState(() {
                          myProductRecInfo.product = newPosition.toString();
                          for (var i = 0;
                              i < myProductRecList.productRecInfo!.length;
                              i++) {
                            if (myProductRecInfo.product ==
                                myProductRecList.productRecInfo![i].product) {
                              myProductRecInfo =
                                  myProductRecList.productRecInfo![i];
                              eventBus
                                  .fire(EventProductRecInfo(myProductRecInfo));
                            }
                          }
                        });
                      },

                      items: productNameList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                            value: value, child: Text(value));
                      }).toList(),
                    ),
                    height: 53,
                    width: 200,
                    padding: const EdgeInsets.all(0),
                  ),
                  const SizedBox(width: 10),
                  MaterialButton(
                      color: Colors.blue.shade900,
                      textColor: Colors.white,
                      elevation: 5.0,
                      child: const Text("PLU Edit"),
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
                  TextButton(onPressed: () {}, child: const Text("User Name:")),
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
                            value: value, child: Text(value));
                      }).toList(),
                    ),
                    height: 53,
                    width: 200,
                    padding: const EdgeInsets.all(0),
                  ),
                  const SizedBox(width: 10),
                  MaterialButton(
                      color: Colors.blue.shade900,
                      textColor: Colors.white,
                      elevation: 5.0,
                      child: const Text("User Edit"),
                      onPressed: () {
                        getUserList();
                        checkUserList();
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
                            getUserList();
                            checkUserList();
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
                // onCellTap: ((details) {
                //   if (details.rowColumnIndex.rowIndex != 0) {
                //     int selectedRowIndex =
                //         details.rowColumnIndex.rowIndex - 1;
                //     var row = _employeeDataSource.effectiveRows
                //         .elementAt(selectedRowIndex);
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) =>
                //                 DetailsPage(dataGridRow: row)));
                //   }
                // }),
              ),
            )
          ],
        ));
  }

  void getWeight() {
    myScaleCmd.cmdMode = "reg_weight_data";
    myScaleCmd.cmdData = "";
    webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  void stopWeight() {
    myScaleCmd.cmdMode = "unreg_weight_data";
    myScaleCmd.cmdData = "";
    webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  void getProductList() {
    myScaleCmd.cmdMode = "get_product_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  void getUserList() {
    myScaleCmd.cmdMode = "get_user_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  void performZero() {
    myScaleCmd.cmdMode = "zero";
    myScaleCmd.cmdData = "";
    webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  void performTare() {
    myScaleCmd.cmdMode = "tare";
    myScaleCmd.cmdData = "";
    webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  void getRecords() {
    myScaleCmd.cmdMode = "get_recs";
    myScaleCmd.cmdData = "";
    webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  void getProductNameList() {
    if (myProductRecList.productRecInfo!.isNotEmpty) {
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
        for (var i = 0; i < myProductRecList.productRecInfo!.length; i++) {
          if (productNameValue == myProductRecList.productRecInfo![i].product) {
            myProductRecInfo = myProductRecList.productRecInfo![i];
            eventBus.fire(EventProductRecInfo(myProductRecInfo));
          }
        }
      }
    } else {
      productNameList.clear();
      productNameValue = '';
    }
  }

  void getUserNameList() {
    if (myUserInfoList.userInfo!.isNotEmpty) {
      String? name;
      userNameList.clear();
      for (var i = 0; i < myUserInfoList.userInfo!.length; i++) {
        name = myUserInfoList.userInfo![i].name;
        name ??= "";
        userNameList.add(name);
      }
      if (!userNameList.contains(userNameValue)) {
        userNameValue = userNameList[0];
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

  void checkProductList() {
    if ((myProductRecList.productRecInfo == null)) {
      productNameList.add("Please select Plu");
      productNameValue = "Please select Plu";
    } else {
      getProductNameList();
      if (!productNameList.contains(productNameValue)) {
        productNameList.add("Please select Plu");
        productNameValue = productNameList[0];
      }
    }
    // getPortList();
  }

  void checkUserList() {
    if ((myUserInfoList.userInfo == null)) {
      userNameList.add("Please select User");
      userNameValue = "Please select User";
    } else {
      getUserNameList();
      if (!userNameList.contains(userNameValue)) {
        userNameList.add("Please select User");
        userNameValue = userNameList[0];
      }
    }
    // getPortList();
  }

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
      'PLU',
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
