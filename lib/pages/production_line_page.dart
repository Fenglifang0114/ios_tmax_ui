import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/timer_manager.dart';
import '../../data/reqweightdata_data.dart';
import '../../data/weight_data.dart';
import '../../eventbus/eventbus.dart';
import '../data/downloadresponse.dart';

import '../dialog/mult_limit_setting.dart';
import '../functions/methods.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class TableData {
  int index;
  List<String> values;
  TableData(this.index, this.values);
}

class TableDataValided {
  int index;
  List<bool> isOkValues;
  TableDataValided(this.index, this.isOkValues);
}

class HighLowValue {
  double high;
  double low;
  HighLowValue(this.high, this.low);
}

class ScaleSortInfo {
  String scaleName;
  int scaleId;
  int scaleIndex;
  int wgtIndex;

  ScaleSortInfo(this.scaleName, this.scaleId, this.scaleIndex, this.wgtIndex);
}

class ScaleWgt {
  List<String> wgts;
  List<String> units;
  bool isStart;
  bool isStable;
  bool isTiming;
  bool isZero;
  bool isPassZero;
  ScaleWgt(this.wgts, this.units, this.isStart, this.isTiming, this.isZero,
      this.isStable, this.isPassZero);
}

class ProductionLinePage extends StatefulWidget {
  const ProductionLinePage({super.key});
  @override
  State<ProductionLinePage> createState() => ProductionLinePageState();
}

class ProductionLinePageState extends State<ProductionLinePage> {
  final ScrollController _scrollController = ScrollController();

  List<AddScaleInfo> scaleNetItems = [];
  List<TableData> tableDataList = [];
  List<TableDataValided> validGapList = [];
  List<HighLowValue> highLowList = []; //存储差值的上下限
  List<ScaleSortInfo> scaleInfos = []; //存储ID，序号，存储名字,存储重量值
  List<String> addedScales = [];
  List<int> scaleIds = [];

  Map<int, ScaleWgt> scaleWgtMap = {};

  double widthTable = 0.0;
  Timer? timerSetScaleFalse;
  Timer? timerOpenCunt;

  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus5;
  dynamic eventBus6;
  dynamic eventBus7;
  dynamic eventBus8;

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();

    performOpenCunt();
    for (NetScaleInfoLocal netScaleInfo in myNetScaleList) {
      AddScaleInfo addScaleInfo = AddScaleInfo(
          isOnline: netScaleInfo.isOnline,
          scaleModel: netScaleInfo.scaleModel,
          scaleCat: netScaleInfo.scaleCat,
          scaleSn: netScaleInfo.scaleSn,
          scaleId: netScaleInfo.scaleId,
          tMedia: netScaleInfo.tMedia,
          isDefault: netScaleInfo.isDefault,
          ip: netScaleInfo.ip,
          port: netScaleInfo.port,
          scaleName: netScaleInfo.scaleName,
          isAdd: false);
      scaleNetItems.add(addScaleInfo);
      scaleWgtMap[netScaleInfo.scaleId!] =
          ScaleWgt([], [], false, false, false, false, false);
      scaleIds.add(netScaleInfo.scaleId!);
    }

    timerSetScaleFalse = Timer.periodic(const Duration(seconds: 30), (timer) {
      scaleWgtMap.forEach((key, value) {
        value.isStart = false;
      });
    });
    timerOpenCunt = Timer.periodic(const Duration(seconds: 115), (timer) {
      scaleWgtMap.forEach((key, value) {
        if (!value.isStart) {
          PublicFunctions.getWeight(key);
        }
      });
    });

    eventBus2 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        setState(() {
          ReqWeightCountine tempWeight = ReqWeightCountine();
          tempWeight = event.obj;

          if (tempWeight.scaleId == 1) {
            return; //串口来的不处理
          }
          scaleWgtMap[tempWeight.scaleId]!.isStart = true; //成功开启了连续发送
          bool res = isScaleIdSelected(tempWeight.scaleId!);
          if (!res) {
            return; //如果没有被选择，不处理重量数据
          }

          processData(tempWeight);
        });
      }
    });

    eventBus4 = eventBus.on<EventWtData>().listen((event) {
      if (mounted) {
        setState(() {
          myWtData = event.obj;
        });
      }
    });

    eventBus5 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
          setState(() {});
        } else {
          setState(() {});
        }
      }
    });

    eventBus6 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
          setState(() {});
        }
      }
    });
  }

  void processData(ReqWeightCountine data) {
    if (data.msgBody == null) {
      return;
    }

    int scaleId = data.scaleId!;

    ScaleWgt scaleWgt = scaleWgtMap[scaleId]!;

    // 更新零点状态
    if (data.msgBody!.isZero) {
      scaleWgt.isPassZero = true;
    }

    // 稳定且不是零点
    if (data.msgBody!.isStable &&
        !data.msgBody!.isZero &&
        scaleWgt.isPassZero) {
      if (!scaleWgt.isTiming) {
        scaleWgt.isTiming = true;
      }
      scaleWgt.isStable = true;
      Timer(const Duration(seconds: 1), () {
        if (scaleWgt.isTiming && scaleWgt.isStable) {
          double weightValue = double.tryParse(data.msgBody!.weightVal) ?? 0;
          if (weightValue > 0) {
            scaleWgt.wgts.add(data.msgBody!.weightVal);
            scaleWgt.units.add(data.msgBody!.weightUnit);
            scaleWgt.isPassZero = false;

            setState(() {
              tableDataList = [];
              validGapList = [];
              resortScaleWgt();
            });
          }
        }
        scaleWgt.isTiming = false;
        scaleWgt.isStable = false;
      });
    } else {
      scaleWgt.isTiming = false;
      scaleWgt.isStable = false;
    }
  }

  //判断有没有选择

  bool isScaleIdSelected(int scaleId) {
    for (ScaleSortInfo info in scaleInfos) {
      if (info.scaleId == scaleId) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    eventBus2.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    _scrollController.dispose();
    cntScaleTimerMgr.stopPortOffTimer();
    timerSetScaleFalse?.cancel();
    timerOpenCunt?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: pageHeadDesign(
          context,
          // localizedStrings.iTitleWeighting,
          'Production Line', scaleIds,
        ),
      ),
      body: Container(
        width: width,
        height: height,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showScaleList(),
            Container(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  buildButtonRow(),
                  Expanded(
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: Scrollbar(
                                controller: _scrollController,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _scrollController,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    width: widthTable > constraints.maxWidth
                                        ? widthTable
                                        : constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        border: Border.all(
                                            width: 0.2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface)),
                                    child: SizedBox(
                                        width: constraints.maxWidth,
                                        child: Column(
                                          children: [
                                            buildSelScales(),
                                            buildTableData(
                                                constraints.maxHeight - 110),
                                          ],
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTableData(double height) {
    tableDataList.sort((a, b) => b.index - a.index);
    validGapList.sort((a, b) => b.index - a.index);
    return SizedBox(
      height: height,
      child: ListView.builder(
        cacheExtent: 1000,
        itemCount: tableDataList.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 40,
            width: (100 * 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0)
                  Container(
                    height: 1,
                    color: Theme.of(context).colorScheme.primary,
                    // margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                buildTableValues(tableDataList[index].values, index),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: tableDataList[index]
                //       .values
                //       .map((value) => Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: SizedBox(
                //                 width: 100,
                //                 child: Text(
                //                   value,
                //                   style: TextStyle(
                //                       color: Theme.of(context)
                //                           .colorScheme
                //                           .outline),
                //                 )),
                //           ))
                //       .toList(),
                // ),
                if (index < tableDataList.length - 1)
                  Container(
                    height: 1,
                    color: Theme.of(context).colorScheme.primary,
                    // margin: EdgeInsets.symmetric(vertical: 4),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTableValues(List<String> values, int index) {
    List<Widget> widgets = [];

    for (int i = 0; i < values.length; i++) {
      String value = values[i];
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 100,
            child: Text(
              value,
              style: TextStyle(
                  fontWeight: validGapList[index].isOkValues[i]
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: validGapList[index].isOkValues[i]
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widgets,
    );
  }

  Widget buildSelScales() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: addedScales
                      .map((value) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 100,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double a = 0.55;

  Widget buildButtonRow() {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomOutlinedButton(
              btnWidth: 200,
              btnHeight: 50,
              icon: Icons.save,
              text: "Export CSV ",
              onPressed: exportCSV),
          CustomOutlinedButton(
              btnWidth: 200,
              btnHeight: 50,
              icon: Icons.settings,
              text: "Set ∆ Range",
              onPressed: () {
                highLowSettingDialog(context);
              }),
          CustomOutlinedButton(
              btnWidth: 100,
              btnHeight: 50,
              icon: Icons.settings,
              text: "New Cycle",
              onPressed: () {
                addDashesToScaleWgtMap();
                setState(() {
                  tableDataList = [];
                  validGapList = [];
                  resortScaleWgt();
                });
              }),
        ],
      ),
    );
  }

  void toggleScale(String scaleName) {
    if (addedScales.contains(scaleName)) {
      setState(() {
        int index = addedScales.indexOf(scaleName);
        setState(() {
          if (index != 0) {
            addedScales.removeAt(index - 1);
            addedScales.remove(scaleName);
          } else if (index == 0 && addedScales.length > 1) {
            addedScales.remove(scaleName);
            addedScales.removeAt(0);
          } else if (index == 0 && addedScales.length == 1) {
            addedScales.remove(scaleName);
          }
        });
      });
    } else {
      setState(() {
        if (addedScales.isNotEmpty) {
          addedScales.add('∆');
        }
        addedScales.add(scaleName);
      });
    }
  }

  void addDashesToScaleWgtMap() {
    int maxLength = 0;
    scaleWgtMap.forEach((key, value) {
      if (value.wgts.length > maxLength) {
        maxLength = value.wgts.length;
      }
    });
    scaleWgtMap.forEach((key, value) {
      while (value.wgts.length < maxLength) {
        value.wgts.add('-');
        value.units.add('-');
      }
    });
  }

  void resortScaleWgt() {
    // 根据 scaleId 建立映射

    // 找出 wgts 的最大长度
    int maxWgtLength = 0;
    maxWgtLength = getMaxLenth();
    if (maxWgtLength == 0) {
      return;
    }

    // 按 scaleIndex 排序 scaleInfos
    scaleInfos.sort((a, b) => a.scaleIndex - b.scaleIndex);

    int tableIndex = 1;
    for (int i = 0; i < maxWgtLength; i++) {
      List<String> values = [];
      List<bool> isOkValues = [];
      for (int j = 0; j < scaleInfos.length; j++) {
        ScaleWgt? currentScaleWgt = scaleWgtMap[scaleInfos[j].scaleId];
        if (currentScaleWgt != null) {
          if (i < currentScaleWgt.wgts.length) {
            if (j == 0) {
              values.add(currentScaleWgt.wgts[i] + currentScaleWgt.units[i]);
              isOkValues.add(false);
            } else {
              ScaleWgt? previousScaleWgt =
                  scaleWgtMap[scaleInfos[j - 1].scaleId];
              if (previousScaleWgt != null &&
                  i < previousScaleWgt.wgts.length) {
                if (currentScaleWgt.wgts[i] == "-" ||
                    previousScaleWgt.wgts[i] == "-") {
                  values.add("-");
                  isOkValues.add(false);
                } else {
                  try {
                    double diff;
                    if (double.tryParse(currentScaleWgt.wgts[i]) != null &&
                        double.tryParse(previousScaleWgt.wgts[i]) != null) {
                      diff = double.parse(currentScaleWgt.wgts[i]) -
                          double.parse(previousScaleWgt.wgts[i]);
                      // 使用 toStringAsFixed 方法保留三位小数
                      values.add(diff.toStringAsFixed(3));
                      isOkValues.add(getValidGapValue(
                          j, double.parse(diff.toStringAsFixed(3))));
                    } else {
                      // 处理无法转换为 double 的情况，例如可以设为 0 或者其他默认值
                      values.add('-');
                      isOkValues.add(false);
                    }
                  } catch (e) {
                    values.add('-');
                    isOkValues.add(false);
                  }
                }
              } else {
                values.add("-");
                isOkValues.add(false);
              }
              values.add(currentScaleWgt.wgts[i] + currentScaleWgt.units[i]);
              isOkValues.add(false);
            }
          } else {
            // 如果当前 scale 没有数据，则补 '-'
            if (j > 0) {
              ScaleWgt? previousScaleWgt =
                  scaleWgtMap[scaleInfos[j - 1].scaleId];
              if (previousScaleWgt != null &&
                  i < previousScaleWgt.wgts.length) {
                values.add("-");
                values.add("-");
                isOkValues.add(false);
                isOkValues.add(false);
              } else {
                values.add("-");
                values.add("-");
                isOkValues.add(false);
                isOkValues.add(false);
              }
            } else {
              values.add('-');
              isOkValues.add(false);
            }
          }
        }
      }
      tableDataList.add(TableData(tableIndex, values));
      validGapList.add(TableDataValided(tableIndex, isOkValues));
      tableIndex++;
    }

    // 输出结果
    // for (TableData tableData in tableDataList) {
    //   print('Index: ${tableData.index}, Values: ${tableData.values}');
    // }
  }

  bool getValidGapValue(int scaleIndex, double gapValue) {
    if (scaleIndex - 1 >= 0 && scaleIndex - 1 < highLowList.length) {
      if (gapValue >= highLowList[scaleIndex - 1].low &&
          gapValue <= highLowList[scaleIndex - 1].high) {
        return true;
      }
    }
    return false;
  }

  int getMaxLenth() {
    int maxLength = 0;
    for (ScaleSortInfo info in scaleInfos) {
      ScaleWgt? scaleWgt = scaleWgtMap[info.scaleId];
      if (scaleWgt != null && scaleWgt.wgts.length > maxLength) {
        maxLength = scaleWgt.wgts.length;
      }
    }
    return maxLength;
  }

  Future<void> exportCSV() async {
    var directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      dialogTitle: 'Output file:',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      fileName: 'report.csv',
    ));
    if (outputFile == null) {
      return;
    }
    if (!outputFile.contains(".csv")) {
      outputFile = "$outputFile.csv";
    }
    final filePath = outputFile;
    File file = File(filePath);
    try {
      IOSink sink = file.openWrite();
      // 写入 addedScales 作为第一行
      if (addedScales.isNotEmpty) {
        sink.write('${addedScales.join(',')}\n');
      }
      // 写入 tableDataList 中的数据
      for (var tableData in tableDataList) {
        sink.write('${tableData.values.join(',')}\n');
      }
      await sink.close();
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('OK    ${file.path}'),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh),
        );
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Widget showScaleList() {
    return Expanded(
      flex: 2,
      child: ListView.builder(
        itemCount: scaleNetItems.length,
        itemBuilder: (context, index) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceBright,
            height: 60,
            child: Column(
              children: [
                ListTile(
                  // selected: selScaleId == scaleNetItems[index].scaleId,
                  dense: true,
                  title: Tooltip(
                    message:
                        '${scaleNetItems[index].scaleModel!}\r\nSN:${scaleNetItems[index].scaleSn!}\r\nIP:${scaleNetItems[index].ip!}\r\nPort:${scaleNetItems[index].port!}',
                    child: Text(
                      scaleNetItems[index].scaleName!,
                      maxLines: 1, // 设置文本最大行数为1
                      style: TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        color: scaleNetItems[index].isAdd
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    scaleWgtMap[scaleNetItems[index].scaleId]!.isStart
                        ? 'Online'
                        : 'Off-line',
                    style: TextStyle(
                        color: scaleWgtMap[scaleNetItems[index].scaleId]!
                                .isStart
                            ? Theme.of(context).colorScheme.surfaceContainerHigh
                            : Theme.of(context).colorScheme.error),
                  ),

                  selectedTileColor: Theme.of(context).colorScheme.primary,
                  trailing: Tooltip(
                    message: scaleNetItems[index].isAdd
                        ? 'Cancel the selected'
                        : 'Add this Scale',
                    child: IconButton(
                      icon: Icon(
                        !scaleNetItems[index].isAdd ? Icons.add : Icons.remove,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          scaleNetItems[index].isAdd =
                              !scaleNetItems[index].isAdd;
                          tableDataList = [];
                          validGapList = [];
                          if (scaleNetItems[index].isAdd) {
                            ScaleSortInfo scaleTmp = ScaleSortInfo(
                                scaleNetItems[index].scaleName!,
                                scaleNetItems[index].scaleId!,
                                (addedScales.length + 1) ~/ 2,
                                0);
                            scaleInfos.add(scaleTmp);
                          } else {
                            ScaleSortInfo removeScale =
                                ScaleSortInfo('', 0, 0, 0);
                            for (var info in scaleInfos) {
                              if (info.scaleId ==
                                  scaleNetItems[index].scaleId!) {
                                removeScale = info;
                              }
                            }
                            int removedIndex = removeScale.scaleIndex;
                            scaleInfos.remove(removeScale);

                            for (var otherInfo in scaleInfos) {
                              if (otherInfo.scaleIndex > removedIndex) {
                                otherInfo.scaleIndex -= 1;
                              }
                            }
                          }
                          toggleScale(scaleNetItems[index].scaleName!);
                          widthTable = addedScales.length * 150;
                          resortScaleWgt();
                        });
                      },
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      // 更新文本框中的值
                    });
                  },
                ),
                Container(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  height: 2,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  //进来就把所有的秤打开连续发送
  void performOpenCunt() {
    for (NetScaleInfoLocal netScaleInfo in myNetScaleList) {
      PublicFunctions.getWeight(netScaleInfo.scaleId!);
    }
  }

//获取差值有几个
  int getScaleGapNum() {
    int count = 0;
    for (String scale in addedScales) {
      if (scale == "∆") {
        count++;
      }
    }
    return count;
  }

  void highLowSettingDialog(BuildContext context) {
    List<double> highValueList = [];
    List<double> lowValueList = [];
    int count = getScaleGapNum();
    if (count < 1) {
      return;
    }
    if (highValueList.length < count) {
      for (int i = highValueList.length; i < count; i++) {
        if (highLowList.length > i) {
          highValueList.add(highLowList[i].high);
          lowValueList.add(highLowList[i].low);
        } else {
          highValueList.add(0.0);
          lowValueList.add(0.0);
        }
      }
    }
    // var fn = CheckWeightFunc();

    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) => MultLimitSettingDialog(
          initialHighList: highValueList,
          initialLowList: lowValueList,
          numGroups: count),
    ).then((values) {
      if (values != null) {
        highLowList = []; //清空
        highValueList = values[0];
        lowValueList = values[1];
        for (int i = 0; i < highValueList.length; i++) {
          HighLowValue temp = HighLowValue(highValueList[i], lowValueList[i]);
          highLowList.add(temp);
        }
        setState(() {
          tableDataList = [];
          validGapList = [];
          resortScaleWgt();
        });

        // fn.updateHighLow(myCheckWeightSetList, setValueInfo);
      }
    });
  }

  //竖向排列
}

class AddScaleInfo extends NetScaleInfoLocal {
  late bool isAdd;
  AddScaleInfo({
    super.isOnline,
    super.scaleModel,
    super.scaleCat,
    super.scaleSn,
    super.scaleId,
    super.tMedia,
    super.isDefault,
    super.ip,
    super.port,
    super.scaleName,
    this.isAdd = false,
  });
}
