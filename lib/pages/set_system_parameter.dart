import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/eeprom_info.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../../generated/l10n.dart';
import '../data/downloadresponse.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../widget/page_head.dart';

class SetParameterPage extends StatefulWidget {
  const SetParameterPage({Key? key}) : super(key: key);
  @override
  State<SetParameterPage> createState() => SetParameterPageState();
}

class SetParameterPageState extends State<SetParameterPage> {
  dynamic eventBus1;
  dynamic eventBus3;

  bool isManaul = false;

  TextEditingController manualTimeCtl = TextEditingController();

  Timer? _timer;
  List<EepromInfo> eepromInfoList = [];
  List<EepromInfo> editInfoList = [];

  List<EepromInfo> parseEepromInfoList(String jsonString) {
    final parsedList = json.decode(jsonString) as List<dynamic>;

    return parsedList.map((json) => EepromInfo.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();
    PublicFunctions.getAllEepromInfo();

    eventBus1 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        setState(() {
          myRespGetAllEepromData = event.obj;
          if (myRespCheckSerialPort.msgBody == 'ok') {
            myScreenMgr.serialPortST = true;
          } else {
            myScreenMgr.serialPortST = false;
          }
        });
      }
    });

    eventBus3 = eventBus.on<EventGetAllEepromDateResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespGetAllEepromData = event.obj;
          if (myRespGetAllEepromData.msgBody.isNotEmpty) {
            try {
              eepromInfoList =
                  parseEepromInfoList(myRespGetAllEepromData.msgBody);
              editInfoList = eepromInfoList;
              // var filteredList =
              //     eepromInfoList.where((item) => item.permission != 0).toList();
              // editInfoList.addAll(filteredList);
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          } else {
            myScreenMgr.serialPortST = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();

    eventBus3.cancel();
    _timer?.cancel();
    super.dispose();
  }

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void startTimer() {}

  void stopTimer() {
    setState(() {
      _timer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(body: firstLayout(context, _width, _height));
  }

  Widget firstLayout(context, _width, _height) {
    return Container(
        width: _width,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHead(context, localizedStrings.parameter_set_title,
                localizedStrings.serial_port_status),
            const SizedBox(height: 5),
            Expanded(
              child: Container(
                height: _height - 50,
                width: _width,
                color: Theme.of(context).colorScheme.onPrimary,
                child: (editInfoList.isNotEmpty)
                    ? ListView.builder(
                        itemCount: editInfoList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 300,
                                child: Text(
                                  ((editInfoList[index].comment.toString())
                                              .replaceAll('/', ''))
                                          .replaceAll('*', '') +
                                      ': ',
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  (editInfoList[index].permission == 0 ||
                                          editInfoList[index].permission == 1)
                                      ? 'Read Only: Yes'
                                      : 'Edit: Yes',
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  'Size: ' +
                                      (editInfoList[index].size.toString()),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'Type: ' +
                                      (editInfoList[index].type.toString()),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: TextFormField(
                                  readOnly: (editInfoList[index].permission ==
                                              0 ||
                                          editInfoList[index].permission == 1)
                                      ? true
                                      : false,
                                  // 根据数据列表设置初始值
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  initialValue: editInfoList[index].currValue,
                                  // 处理每个文本字段的变化
                                  onChanged: (value) {
                                    // 更新数据列表中的值
                                    editInfoList[index].currValue = value;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: Text(
                                  editInfoList[index].description.toString(),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    :
                    // 空列表时的处理
                    const Text('Empty list, please wait a moment.'),
              ),
            ),
          ],
        ));
  }

  Widget btnStyle(String head) {
    return SizedBox(
        width: 200,
        child: Text(
          head,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.blue),
        ));
  }

  void showConfirmationDialog(BuildContext context) {
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
}
