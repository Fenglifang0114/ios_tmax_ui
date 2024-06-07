import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/eeprom_info.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';

import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/scale_info_from_scale.dart';
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
  dynamic eventBus2;
  dynamic eventBus3;

  bool isManaul = false;

  TextEditingController manualTimeCtl = TextEditingController();

  Timer? _timer;
  List<EepromInfo> eepromInfoList = [];
  List<EepromInfo> editInfoList = [];

  Map<String, List<EepromInfo>> groupedData = {};

  void generateCategoryList(List<EepromInfo> dataList) {
    setState(() {
      for (var item in dataList) {
        String cate = item.category!;
        if (!groupedData.containsKey(cate)) {
          groupedData[cate] = [];
        }
        item.isChanged = false;
        item.oldValue = item.currValue;
        groupedData[cate]!.add(item);
      }
    });
  }

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
          myFactoryInfoFromScale = event.obj;
          if (myFactoryInfoFromScale.modelName != '') {
            myScreenMgr.serialPortST = true;
          } else {
            myScreenMgr.serialPortST = false;

            myFactoryInfoFromScale.modelName = '';
            myFactoryInfoFromScale.scaleSn = '';
          }
        });
      }
    });

    eventBus3 = eventBus.on<EventGetAllEepromDateResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespGetAllEepromData = event.obj;
          groupedData.clear();
          if (myRespGetAllEepromData.msgBody.isNotEmpty) {
            try {
              eepromInfoList =
                  parseEepromInfoList(myRespGetAllEepromData.msgBody);
              var filteredList = eepromInfoList
                  .where((item) =>
                      (item.permission != 0 && item.permission != null))
                  .toList();
              generateCategoryList(filteredList);
              editInfoList.addAll(filteredList);
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
            cntScaleTimerMgr.startCntScaleTimer(1);
          } else {
            myScreenMgr.serialPortST = false;
          }
        });
      }
    });

    eventBus2 = eventBus.on<EventModifyEepromInfoResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespModifyEepromInfo = event.obj;
          if (myRespModifyEepromInfo.msgBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myRespModifyEepromInfo.msgBody.contains('ok'))
                        ? localizedStrings.download_result_ok
                        : myRespModifyEepromInfo.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (myRespModifyEepromInfo.msgBody.contains('ok'))
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.error));
          }
        });
        groupedData.clear();
        cntScaleTimerMgr.stopCntScaleTimer();
        PublicFunctions.getAllEepromInfo();
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus2.cancel();
    eventBus3.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {}

  void stopTimer() {
    setState(() {
      _timer?.cancel();
    });
  }

  List<EepromInfo> checkParameter() {
    List<EepromInfo> changedEepromInfos = groupedData.values
        .expand((infoList) => infoList)
        .where((eepromInfo) =>
            eepromInfo.isChanged! &&
            eepromInfo.currValue != eepromInfo.oldValue)
        .toList();

    return changedEepromInfos;
  }

  void submitParameter(List<EepromInfo> changedEepromInfos) {
    cntScaleTimerMgr.stopCntScaleTimer();
    var jsonStr = jsonEncode(changedEepromInfos);
    PublicFunctions.modifyEepromInfo(jsonStr);
  }

  @override
  Widget build(BuildContext context) {
    // final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: pageHead(context, localizedStrings.parameter_set_title,
            localizedStrings.serial_port_status),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.scrim,
              border: Border(
                bottom:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Configuration name',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Editable',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Value',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: _height - 100,
            child: ListView.builder(
              itemCount: groupedData.length, // 每个分类一个ExpansionTile
              itemBuilder: (context, index) {
                String category = groupedData.keys.toList()[index];
                String categoryTitle = category;

                return ExpansionTile(
                  initiallyExpanded: false,
                  title: Text(categoryTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: groupedData[category]!.map((item) {
                    return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          // border: Border(
                          //   bottom: BorderSide(color: Theme.of(context).colorScheme.background),
                          // ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                ((item.comment.toString()).replaceAll('/', ''))
                                        .replaceAll('*', '') +
                                    ': ',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                (item.permission == 1) ? 'No' : 'Yes',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                (item.size.toString()),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                (item.type.toString()),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                readOnly: (item.permission == 1) ? true : false,
                                // 根据数据列表设置初始值
                                maxLines: 1,
                                decoration: InputDecoration(
                                  border: (item.permission == 1)
                                      ? InputBorder.none
                                      : const UnderlineInputBorder(), // 去掉底部线条
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis),
                                initialValue: item.currValue,
                                // 处理每个文本字段的变化
                                onChanged: (value) {
                                  setState(() {
                                    item.currValue = value;
                                    item.isChanged = true;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.description.toString(),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ));
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var changedEepromInfos = checkParameter();
          if (changedEepromInfos.isNotEmpty) {
            String checkStr = checkEepromData(changedEepromInfos);
            if (checkStr != '') {
              changedEepromInfos.clear();
              var title = '''Please check $checkStr!''';
              _showConfirmationDialog(context, changedEepromInfos, title);
            } else {
              var title =
                  '''Please make sure the values are correct, continue?''';
              _showConfirmationDialog(context, changedEepromInfos, title);
            }
          } else {
            var title = '''No parameters have been modified!''';
            _showConfirmationDialog(context, changedEepromInfos, title);
          }
        },
        tooltip: 'Click to submit',
        child: const Icon(Icons.upload_file_outlined),
      ),
    );
  }

  String checkEepromData(List<EepromInfo> dataList) {
    for (var i = 0; i < dataList.length; i++) {
      if (dataList[i].type == 'int' && dataList[i].size == 1) {
        if (dataList[i].currValue == null ||
            !isNumberInRange1(dataList[i].currValue!)) {
          return '${dataList[i].comment}';
        }
      } else if (dataList[i].type == 'int' && dataList[i].size == 2) {
        if (dataList[i].currValue == null ||
            !isNumberInRange2(dataList[i].currValue!)) {
          return '${dataList[i].comment}';
        }
      } else if (dataList[i].type == 'int' &&
          dataList[i].size == 4 &&
          dataList[i].subType != 'ip') {
        if (dataList[i].currValue == null ||
            !isValidInteger3(dataList[i].currValue!)) {
          return '${dataList[i].comment}';
        }
      } else if (dataList[i].type == 'double') {
        if (dataList[i].currValue == null ||
            !isValidNumber(dataList[i].currValue!)) {
          return '${dataList[i].comment}';
        }
      }
    }

    return '';
  }

  bool isValidNumber(String value) {
    RegExp regex = RegExp(r'^\d*\.?\d+$'); // 匹配整数或小数的正则表达式
    return regex.hasMatch(value);
  }

  bool isValidValue(String value) {
    return value.isNotEmpty && value.length <= 20;
  }

  void _showConfirmationDialog(
      BuildContext context, List<EepromInfo> changedEepromInfos, String title) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.confirm_title,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(title),
          actions: <Widget>[
            changedEepromInfos.length > 0
                ? OutlinedButton(
                    child: Text(localizedStrings.button_cancel),
                    onPressed: () {
                      Navigator.of(context).pop(false); // 不跳转
                    },
                  )
                : const SizedBox(),
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
        if (changedEepromInfos.length > 0) {
          submitParameter(changedEepromInfos);
        }
      }
    });
  }

  bool isNumberInRange1(String input) {
    final regExp = RegExp(r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return regExp.hasMatch(input);
  }

  bool isNumberInRange2(String input) {
    final regExp = RegExp(
        r'^(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5]?\d{1,4})$');
    return regExp.hasMatch(input);
  }

  bool isValidInteger3(String value) {
    RegExp regex = RegExp(r'^(?!0\d)\d{1,10}$'); // 匹配1到10位数字的正则表达式
    return regex.hasMatch(value);
  }

  Widget btnStyle(String head) {
    return SizedBox(
        width: 200,
        child: Text(
          head,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ));
  }

  void showConfirmationDialog(BuildContext context) {
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
