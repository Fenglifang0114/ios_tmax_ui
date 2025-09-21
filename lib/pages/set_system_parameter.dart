import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/scale_list.dart';
import '../data/comscaleinfo_data.dart';
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import 'package:t_max/data/eeprom_info.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';

class SetParameterPage extends StatefulWidget {
  const SetParameterPage({super.key});
  @override
  State<SetParameterPage> createState() => SetParameterPageState();
}

class SetParameterPageState extends State<SetParameterPage> {
  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;

  bool isManaul = false;

  TextEditingController manualTimeCtl = TextEditingController();

  List<EepromInfo> eepromInfoList = [];
  List<EepromInfo> editInfoList = [];

  Map<String, List<EepromInfo>> groupedData = {};

  int selScaleId = -1;
  bool isGettingData = false;

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

    eventBus1 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        // setState(() {
        //   myFactoryInfoFromScale = event.obj;
        //   if (myFactoryInfoFromScale.modelName != '') {
        //     myComScaleInfo.isOnline = true;
        //   } else {
        //     myComScaleInfo.isOnline = false;

        //     myFactoryInfoFromScale.modelName = '';
        //     myFactoryInfoFromScale.scaleSn = '';
        //   }
        // });
      }
    });

    eventBus3 = eventBus.on<EventGetAllEepromDateResp>().listen((event) {
      if (mounted) {
        setState(() {
          isGettingData = false;
          myRespDataFromScale = event.obj;
          groupedData.clear();
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            try {
              eepromInfoList = parseEepromInfoList(myRespDataFromScale.msgBody);
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
          } else {
            myComScaleInfo.isOnline = false;
          }
        });
      }
    });

    eventBus2 = eventBus.on<EventModifyEepromInfoResp>().listen((event) {
      if (mounted) {
        setState(() {
          isGettingData = false;
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            myRespDataFromScale.msgBody.contains('ok')
                ? showTipInfo(localizedStrings.gTipDownloadOk, context)
                : showTipInfo(localizedStrings.gTipDownloadFail, context);
          }
        });
        groupedData.clear();
        cntScaleTimerMgr.stopCntScaleTimer();
        PublicFunctions.getAllEepromInfo(selScaleId);
        isGettingData = true;
      }
    });
    eventBus4 = eventBus.on<EventSelWeighingScaleId>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        int scaleId = event.obj;
        if (scaleId != selScaleId) {
          setState(() {});
        }
      }
    });
    // 在页面构建完成后显示提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (myAllScalesList.isEmpty) {
        showTipInfo(localizedStrings.gTipNoDeviceAddFirst, context);
      } else {
        if (selScaleId == -1) {
          showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
        }
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus2.cancel();
    eventBus3.cancel();

    cntScaleTimerMgr.stopCntScaleTimer();
    super.dispose();
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
    PublicFunctions.modifyEepromInfo(jsonStr, myDefScaleInfo.defScaleId!);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
          width: width,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: scaleListWidth,
                        color: Theme.of(context).colorScheme.surfaceTint,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                height: regularPadding,
                              ),
                              Expanded(
                                child: NewAllScaleListWidget(
                                  listWidth: scaleListWidth, // 列表宽度
                                  selScaleId: selScaleId,
                                  clickScale: (scale) {
                                    if (isGettingData) {
                                      showTipInfo(
                                          localizedStrings
                                              .gTipPerformingOperation,
                                          context);
                                      return;
                                    }

                                    setState(() {
                                      changeScale(scale.scaleId);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant, //  分隔条颜色
                      ),
                      myAllScalesList.isEmpty
                          ? SizedBox()
                          : Expanded(
                              child: Container(
                              padding: const EdgeInsets.all(largePadding),
                              child: Column(
                                children: [
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceDim,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            localizedStrings
                                                .cTipConfigurationName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            localizedStrings.cTipEditable,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            localizedStrings.cTipParameterSize,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            localizedStrings.cTipParameterTyppe,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            localizedStrings.cTipParameterValue,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            localizedStrings.cTipParameterDesp,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: height - 250,
                                    child: ListView.builder(
                                      itemCount: groupedData
                                          .length, // 每个分类一个ExpansionTile
                                      itemBuilder: (context, index) {
                                        String category =
                                            groupedData.keys.toList()[index];
                                        String categoryTitle = category;

                                        return ExpansionTile(
                                          initiallyExpanded: false,
                                          title: Text(
                                            categoryTitle,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                          ),
                                          children: groupedData[category]!
                                              .map((item) {
                                            return Container(
                                                padding: const EdgeInsets.only(
                                                    left: regularPadding),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${((item.comment.toString()).replaceAll('/', '')).replaceAll('*', '')}: ',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .apply(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        (item.permission == 1)
                                                            ? 'No'
                                                            : 'Yes',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .apply(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        (item.size.toString()),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .apply(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        (item.type.toString()),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .apply(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: TextFormField(
                                                        readOnly:
                                                            (item.permission ==
                                                                    1)
                                                                ? true
                                                                : false,
                                                        // 根据数据列表设置初始值
                                                        maxLines: 1,
                                                        decoration:
                                                            InputDecoration(
                                                          border: (item
                                                                      .permission ==
                                                                  1)
                                                              ? InputBorder.none
                                                              : const UnderlineInputBorder(), // 去掉底部线条
                                                        ),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .apply(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),

                                                        initialValue:
                                                            item.currValue,
                                                        // 处理每个文本字段的变化
                                                        onChanged: (value) {
                                                          setState(() {
                                                            item.currValue =
                                                                value;
                                                            item.isChanged =
                                                                true;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        item.description
                                                            .toString(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .apply(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                            )),
                    ]),
              ),
            ],
          )),
      floatingActionButton: myAllScalesList.isEmpty
          ? SizedBox()
          : FloatingActionButton(
              shape: const BeveledRectangleBorder(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                var changedEepromInfos = checkParameter();
                if (changedEepromInfos.isNotEmpty) {
                  String checkStr = checkEepromData(changedEepromInfos);
                  if (checkStr != '') {
                    changedEepromInfos.clear();
                    var title = localizedStrings.cTipCheckValue + '$checkStr!';

                    showDialog(
                      context: context,
                      barrierDismissible: false, // 点击对话框外部不关闭对话框
                      builder: (BuildContext context) {
                        return ShowNormalTipDialog(
                          title: localizedStrings.fTipTitle,
                          msg: title,
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false, // 点击对话框外部不关闭对话框
                      builder: (BuildContext context) {
                        return ShowNormalTipDialog(
                          title: localizedStrings.fTipTitle,
                          msg: localizedStrings.cTipConfirmModified,
                        );
                      },
                    ).then((value) {
                      if (value == null) {
                        return;
                      }
                      if (value) {
                        if (changedEepromInfos.isNotEmpty) {
                          submitParameter(changedEepromInfos);
                        }
                      } else {
                        return;
                      }
                    });
                  }
                } else {
                  showTipInfo(localizedStrings.cTipNotModified, context);
                }
              },
              tooltip: localizedStrings.cBtnCommit,
              child: const Icon(Icons.upload_file_outlined),
            ),
    );
  }

  //切换的时候要修改掉秤的信息
  void changeScale(int scaleId) {
    // PublicFunctions.stopWeight(selScaleId);
    setState(() {
      selScaleId = scaleId;
      PublicFunctions.getAllEepromInfo(selScaleId);
      isGettingData = true;
      groupedData.clear();
    });

    // PublicFunctions.getWeight(scaleId);
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
}
