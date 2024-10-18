import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_max/functions/methods.dart';
import '../../eventbus/eventbus.dart';
import '../data/comscaleinfo_data.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';

import '../data/screen_mgr.dart';
import '../widget/custom_button.dart';

int normalSend = 1; //正常的发送数据
int sendServerIp = 2; //正常的发送数据
int sendOnline = 3; //仅仅在线发送（无串口）

class ScaleDownRes {
  int scaleId;
  String res;
  double process;
  ScaleDownRes(this.scaleId, this.res, this.process);
}

class SelectScalesPage extends StatefulWidget {
  final int funcNo;
  final String sendMsgStr;
  const SelectScalesPage({
    required this.funcNo,
    required this.sendMsgStr,
    super.key,
  });

  @override
  SelectScalesPageState createState() => SelectScalesPageState();
}

class SelectScalesPageState extends State<SelectScalesPage> {
  final TextEditingController _deviceNameController = TextEditingController();

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;

  List<bool> checkboxStates = [];
  List<NetScaleInfoLocal> scaleNetItems = [];
  int scaleNum = 0;
  Map<int, ScaleDownRes> scaleResMap = {};
  Map<int, Timer?> scaleTimerMap = {};

  bool isDownloading = false;
  bool isSelectCom = false;
  ComScaleInfo comScale = myComScaleInfo;

  @override
  void initState() {
    super.initState();

    scaleNum = (myNetScaleList.length);
    if (scaleNum > 0) {
      checkboxStates = List.filled(scaleNum, false);
    }

    _deviceNameController.text = '';
    scaleNetItems = myNetScaleList;
    _eventbus1 = eventBus.on<EventDownPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus2 = eventBus.on<EventDownDefPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus3 = eventBus.on<EventRespDownPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus4 = eventBus.on<EventRespInsertPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus5 = eventBus.on<EventModifyVarValueResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus6 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        // setState(() {
        //   myFactoryInfoFromScale = event.obj;
        // });
      }
    });

    _eventbus7 = eventBus.on<EventSetServerIPResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });
    _eventbus8 = eventBus.on<EventUpdateFirmWareNetResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });
  }

//根据收到的结果处理
  void parseRecInfo(int scaleId) {
    if (scaleResMap.containsKey(scaleId)) {
      scaleTimerMap[scaleId]!.cancel();
      if (myRespDataFromScale.msgBody.contains('ok')) {
        scaleResMap[scaleId]!.process = 1;
      }

      scaleResMap[scaleId]!.res = myRespDataFromScale.msgBody;
    }
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    if (scaleTimerMap.isNotEmpty) {
      scaleTimerMap.forEach((int key, Timer? timer) {
        timer!.cancel();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(
          context, localizedStrings.download, Icons.download, 800),
      contentPadding: const EdgeInsets.fromLTRB(24, 5, 24, 5),
      content: Container(
          height: 500,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
          child: Column(
            children: [
              widget.funcNo != sendOnline
                  ? buildComScaleInfo()
                  : const SizedBox(),
              widget.funcNo != sendOnline
                  ? Container(
                      height: 2,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const SizedBox(),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: buildNetScaleInfo(),
                ),
              ),
            ],
          )),
      actions: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.check_circle,
              text: localizedStrings.button_ok,
              onPressed: !isDownloading && checkSelect()
                  ? () {
                      setState(() {
                        isDownloading = true;
                        scaleResMap.clear();
                      });
                      if (checkSelect()) {
                        performSend();
                      }
                    }
                  : null,
            ),
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.cancel,
              text: localizedStrings.button_cancel,
              onPressed: isDownloading
                  ? null
                  : () {
                      myScreenMgr.isMainScreen = true;
                      Navigator.of(context).pop();
                    },
            ),
            const SizedBox(width: 16),
          ],
        )
      ],
    );
  }

  Widget buildComScaleInfo() {
    return DataTable(
      headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface),
      columns: const [
        DataColumn(label: Text('Select')),
        // DataColumn(label: Text('Status')),
        DataColumn(
            label: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('ModelName'),
            Text('Sn'),
          ],
        )),
        DataColumn(label: Text('COM')),
        DataColumn(label: Text('Progress')),
        DataColumn(label: Text('Result')),
      ],
      rows: List.generate(
        1,
        (index) => DataRow(
          color: WidgetStateProperty.all(getResBackColor(comScale.scaleId)),
          cells: [
            DataCell(Checkbox(
              value: isSelectCom,
              onChanged: isDownloading
                  ? null
                  : (value) {
                      setState(() {
                        isSelectCom = value!;
                        scaleResMap.clear();
                        if (scaleNum > 0 && isSelectCom) {
                          checkboxStates = List.filled(scaleNum, false);
                        }
                      });
                    },
            )),
            // DataCell(
            //   SizedBox(
            //     width: 50,
            //     child: Text('online',
            //         maxLines: 2,
            //         style: TextStyle(
            //             color: getResTextColor(comScale.scaleId),
            //             overflow: TextOverflow.ellipsis)),
            //   ),
            // ),
            DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildDataCellInfo(150, comScale.scaleModel,
                      getResTextColor(comScale.scaleId)),
                  buildDataCellInfo(
                      150, comScale.scaleSn, getResTextColor(comScale.scaleId)),
                ])),
            DataCell(
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildDataCellInfo(150, comScale.portName,
                        getResTextColor(comScale.scaleId)),
                    buildDataCellInfo(150, comScale.baudRate.toString(),
                        getResTextColor(comScale.scaleId))
                  ]),
            ),
            DataCell(
              SizedBox(
                width: 150,
                child: buildProgess(comScale.scaleId),
              ),
            ),
            DataCell(
              buildDataCellInfo(300, getResStr(comScale.scaleId),
                  getResTextColor(comScale.scaleId)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDataCellInfo(double width, String text, Color textColor) {
    return SizedBox(
        width: width,
        child: Text(text,
            maxLines: 2,
            style:
                TextStyle(color: textColor, overflow: TextOverflow.ellipsis)));
  }

  Widget buildNetScaleInfo() {
    return DataTable(
      headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface),
      columns: const [
        DataColumn(label: Text('Select')),
        // DataColumn(label: Text('Status')),
        DataColumn(
            label: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('ModelName'),
            Text('Sn'),
          ],
        )),
        DataColumn(label: Text('Ip')),
        DataColumn(label: Text('Progress')),
        DataColumn(label: Text('Result')),
      ],
      rows: List.generate(
        scaleNum,
        (index) => DataRow(
          color: WidgetStateProperty.all(
              getResBackColor(scaleNetItems[index].scaleId!)),
          cells: [
            DataCell(Checkbox(
              value: checkboxStates[index],
              onChanged: isDownloading
                  ? null
                  : (value) {
                      setState(() {
                        checkboxStates[index] = value!;
                        isSelectCom = false;
                        scaleResMap.clear();
                      });
                    },
            )),
            // DataCell(
            //   SizedBox(
            //     width: 50,
            //     child: Text('online',
            //         maxLines: 2,
            //         style: TextStyle(
            //             color: getResTextColor(scaleNetItems[index].scaleId!),
            //             overflow: TextOverflow.ellipsis)),
            //   ),
            // ),
            DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 150,
                      child: Text(
                          scaleNetItems[index].scaleModel! == "TMax"
                              ? ""
                              : scaleNetItems[index].scaleModel!,
                          style: TextStyle(
                              color: getResTextColor(
                                  scaleNetItems[index].scaleId!)))),
                  SizedBox(
                      width: 150,
                      child: Text(
                          scaleNetItems[index].scaleModel! == "TMax"
                              ? ""
                              : scaleNetItems[index].scaleSn!,
                          style: TextStyle(
                              color: getResTextColor(
                                  scaleNetItems[index].scaleId!)))),
                ])),
            DataCell(
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 150,
                        child: Text(scaleNetItems[index].ip!,
                            style: TextStyle(
                                color: getResTextColor(
                                    scaleNetItems[index].scaleId!)))),
                    SizedBox(
                        width: 150,
                        child: Text(scaleNetItems[index].port!.toString(),
                            style: TextStyle(
                                color: getResTextColor(
                                    scaleNetItems[index].scaleId!))))
                  ]),
            ),
            DataCell(
              SizedBox(
                width: 150,
                child: buildProgess(scaleNetItems[index].scaleId!),
              ),
            ),
            DataCell(
              SizedBox(
                width: 300,
                child: Text(getResStr(scaleNetItems[index].scaleId!),
                    maxLines: 2,
                    style: TextStyle(
                        color: getResTextColor(scaleNetItems[index].scaleId!),
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool checkAllNotEmpty() {
    for (var value in scaleResMap.values) {
      if (value.res.isEmpty) {
        return false;
      }
    }
    return true;
  }

//根据结果显示整个行的颜色
  Color getResBackColor(int id) {
    return getResStr(id).contains('ok')
        ? Theme.of(context).colorScheme.surfaceContainerHigh
        : Theme.of(context).colorScheme.surfaceTint;
  }

  double getProcessValue(int id) {
    if (scaleResMap.containsKey(id)) {
      return scaleResMap[id]!.process;
    }
    return 0.0;
  }

  Widget buildProgess(int scaleId) {
    double progessValue = getProcessValue(scaleId);
    return LinearProgressIndicator(
      value: progessValue,
      backgroundColor: Theme.of(context).colorScheme.outline,
    );
  }

  void buildProcessTimer(int downTime) {
    scaleResMap.forEach((int id, ScaleDownRes value) {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (scaleResMap[id]!.res != "") {
          // setState(() {
          scaleResMap[id]!.process = 1;
          // });
          timer.cancel();
        } else if (scaleResMap[id]!.process < 0.9) {
          setState(() {
            scaleResMap[id]!.process += 0.9 / downTime;
          });
        }
      });

      scaleTimerMap[id] = timer;
    });
  }

  Color getResTextColor(int id) {
    return getResStr(id).contains('ok')
        ? Theme.of(context).colorScheme.onPrimary
        : getResStr(id) != ""
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurface;
  }

//获取下发的结果
  String getResStr(int id) {
    if (scaleResMap.containsKey(id)) {
      if (scaleResMap[id] != null) {
        return scaleResMap[id]!.res;
      } else {
        return "";
      }
    }

    return "";
  }

  bool checkSelect() {
    scaleResMap.clear();
    if (isSelectCom) {
      int id = comScale.scaleId;
      ScaleDownRes newMap = ScaleDownRes(id, '', 0.0);
      scaleResMap[id] = newMap;
      return true;
    }
    if (checkboxStates.isEmpty) {
      return false;
    }
    for (int i = 0; i < checkboxStates.length; i++) {
      if (checkboxStates[i]) {
        int id = scaleNetItems[i].scaleId!;
        ScaleDownRes newMap = ScaleDownRes(id, '', 0.0);
        scaleResMap[id] = newMap;
      }
    }
    if (scaleResMap.isEmpty) {
      return false;
    }

    return true;
  }

  void performSend() {
    scaleResMap.forEach((key, value) {
      sendMessage(key);
    });
    buildProcessTimer(240);
  }

  void sendMessage(int scaleId) {
    if (widget.funcNo == normalSend) {
      PublicFunctions.sendMsg(scaleId, widget.sendMsgStr);
    } else if (widget.funcNo == sendServerIp) {
      PublicFunctions.sendServerIpToScale(widget.sendMsgStr, scaleId);
    } else if (widget.funcNo == sendOnline) {
      PublicFunctions.updateFirmWareOnline(widget.sendMsgStr, scaleId);
    }
  }
}
