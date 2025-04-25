//流速测试页面
import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/flow_data_from_db.dart';
import 'package:t_max/data/flow_rate_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/manager_scale_channel.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/timer_manager.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/sticky_table.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import '../data/language.dart';

// 定义一个新的类来保存重量值、序号和时间戳
class WeightRecord {
  int id;
  double weight;
  DateTime timestamp;

  WeightRecord(
      {required this.id, required this.weight, required this.timestamp});
}

class RateDataInfo {
  int? id;
  double? totalWgt; //总重量
  double? minSpeed; //最小速度
  double? maxSpeed; //最大速度
  double? avgSpeed; //平均速度
  double? totalTime; //时间
  String? unit; //单位

  RateDataInfo(
      {this.id,
      this.totalWgt,
      this.minSpeed,
      this.maxSpeed,
      this.avgSpeed,
      this.totalTime,
      this.unit});
}

//重量数据
class WgtDataInfo {
  int? id;
  double? time; //时间
  double? wgt; //重量
  WgtDataInfo({this.id, this.time, this.wgt});
}

//速率
class RateInfo {
  int? id; //id
  double? rate; //速率
  double? time; //时间
  RateInfo({this.id, this.rate, this.time});
}

class FlowRatePage extends StatefulWidget {
  const FlowRatePage({super.key});
  @override
  State<FlowRatePage> createState() => FlowRatePageState();
}

class FlowRatePageState extends State<FlowRatePage>
    with SingleTickerProviderStateMixin {
  bool showDataTable = false; //是否显示数据表格
  bool hasStartedRecording = false; // 标记是否开始真正记录数据
  bool isWgtStart = false; //是否有重量
  bool enableSelRaw = true; //是否允许选择原料
  bool isStart = false; //是否开始
  bool _isLeftPanelExpanded = true;
  bool sort = false; //是否倒序

  List<FlowRateFromDb> processWgtList = []; //流速数据列表来自数据库
  List<NetScaleInfoLocal> scaleNetItems = []; //秤列表
  List<WgtDataInfo> wgtDataList = []; //重量数据列表
  List<RateInfo> rateDataList = [];

  final ScrollController _scrollController =
      ScrollController(); // 添加 ScrollController
  final ScrollController _folwDataScrollCtl =
      ScrollController(); // 添加 ScrollController

  FlowRateFromDb selectedProcessWgt = FlowRateFromDb(); //选中的流速数据
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal(); //默认秤

  Timer? weightCollectionTimer; // 声明定时器
  Timer? setWgtStartFalseTimer; // 用于每3秒将isWgtStart设置为false的定时器
  Timer? checkWgtStartTimer; // 用于每5秒检查isWgtStart的定时器

  int _selectedScaleIndex = -1; // 用于跟踪选中的秤
  int clickedRow = -1; //点击的行
  int selScaleId = -1; //选择的秤ID
  int weightCollectionInterval = 1; // 重量采集间隔（秒）

  double currentWgt = 0.0; //当前重量
  double? initialWeight; // 记录初始重量

  // 添加 ValueNotifier
  final ValueNotifier<double> currentWgtNotifier = ValueNotifier(0.0);
  final ValueNotifier<String> currentWgtStrNotifier = ValueNotifier('----');
  final ValueNotifier<String> currentUnitNotifier = ValueNotifier('');
  final ValueNotifier<List<WgtDataInfo>> wgtDataListNotifier =
      ValueNotifier([]);

  RateDataInfo currRateHeader = RateDataInfo(); //需要保存的流速数据

  dynamic eventbus1;
  dynamic eventbus2;
  dynamic eventbus8;

  // 用于存储重量记录的列表
  // List<WeightRecord> weightRecords = [];

  // 定义函数将每次的重量值、序号和时间戳保存起来
  // void saveWeightRecord(double weight) {
  //   int newId = weightRecords.length;
  //   DateTime now = DateTime.now();
  //   WeightRecord record = WeightRecord(
  //     id: newId,
  //     weight: weight,
  //     timestamp: now,
  //   );
  //   weightRecords.add(record);
  // }

  void getScaleInfo() {
    PublicFunctions.getWeight(selScaleId);
    DefScaleInfo.getDefScaleInfo(selScaleId);
  }

  // 每3秒钟将isWgtStart设置为false
  void startSetWgtStartFalseTimer() {
    setWgtStartFalseTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          isWgtStart = false;
        });
      }
    });
  }

  // 每5秒判断一下isWgtStart是不是false，是false的话，就重新发送请求开启连续发送
  void startCheckWgtStartTimer() {
    checkWgtStartTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isWgtStart == false) {
        // 重新发送请求开启连续发送
        PublicFunctions.getWeight(selScaleId);
      }
    });
  }

  //切换的时候要修改掉秤的信息和停止重量
  void changeScale(int scaleId) {
    PublicFunctions.stopWeight(selScaleId);
    setState(() {
      selScaleId = scaleId;
    });
    DefScaleInfo.getDefScaleInfo(scaleId);
    PublicFunctions.getWeight(scaleId);
  }

//初始化秤列表
  void initScaleList() {
    scaleNetItems = myNetScaleList;
    selScaleId = myDefScaleInfo.defScaleId!;
    if (myNetScaleList.isNotEmpty) {
      defNetScaleInfo = NetScaleListMgr.findScaleInfo(
          myNetScaleList, myDefScaleInfo.defScaleId!);
    }
  }
  //myComScaleInfo

  @override
  void initState() {
    super.initState();
    initScaleList();
    getScaleInfo();
    PublicFunctions.getFlowRateData();
    cntScaleTimerMgr.startCntAliveTimer(10);
    startSetWgtStartFalseTimer();
    startCheckWgtStartTimer();

    eventbus1 = eventBus.on<EventRespFlowRateAdd>().listen((event) {
      if (mounted) {
        PublicFunctions.getFlowRateData();
        showTipInfo(localizedStrings.fSaveSuccess, context);
      }
    });

    eventbus2 = eventBus.on<EventRespFlowRateList>().listen((event) {
      if (mounted) {
        String jsonData = event.obj;
        if (jsonData != '' && jsonData != 'null') {
          setState(() {
            processWgtList = flowRateFromDbFromJson(jsonData);
            //如果processWgtList不为空，倒序排序
            if (processWgtList.isNotEmpty) {
              processWgtList.sort((a, b) =>
                  b.flowRateHeader!.recId!.compareTo(a.flowRateHeader!.recId!));
            }
            if (processWgtList.isNotEmpty) {
              selectedProcessWgt = processWgtList[0];
              rateDataList = [];
              clickedRow = 0;
              for (var item in selectedProcessWgt.flowRateDetail!) {
                rateDataList.add(RateInfo(
                  id: item.id,
                  rate: item.rate,
                  time: item.time,
                ));
              }
            }
          });
        } else {
          setState(() {
            processWgtList = [];
          });
        }
      }
    });
    eventbus8 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        ReqWeightCountine tempWeight = ReqWeightCountine();
        tempWeight = event.obj;
        if (tempWeight.scaleId == myDefScaleInfo.defScaleId!) {
          myReqWeightCountine = tempWeight;
          if (tempWeight.scaleId == 1) {
            myComScaleInfo.isOnline = true;
          }
          isWgtStart = true;

          if (myReqWeightCountine.msgBody != null) {
            try {
              currentWgtStrNotifier.value =
                  myReqWeightCountine.msgBody!.weightVal;

              double newWgt =
                  double.parse(myReqWeightCountine.msgBody!.weightVal);
              newWgt = double.parse(newWgt.toStringAsFixed(3));
              // 添加日志，查看每次接收到的重量数据
              // 调用保存函数
              // saveWeightRecord(newWgt);
              // 更新当前重量的 ValueNotifier
              currentWgtNotifier.value = newWgt;
              currentUnitNotifier.value =
                  myReqWeightCountine.msgBody!.weightUnit;

              // 用于记录重量未变化的时间
              int noChangeDuration = 0;
              Timer? noChangeTimer;

              // 启动或停止定时器
              if (isStart) {
                if (weightCollectionTimer == null) {
                  // 重置初始状态
                  initialWeight = null;
                  hasStartedRecording = false;
                  wgtDataListNotifier.value = []; // 清空列表

                  weightCollectionTimer = Timer.periodic(
                      const Duration(milliseconds: 500), (timer) {
                    if (!hasStartedRecording) {
                      if (initialWeight == null) {
                        initialWeight = currentWgtNotifier.value; // 记录初始重量
                        List<WgtDataInfo> newList =
                            List.from(wgtDataListNotifier.value);
                        newList.add(WgtDataInfo(
                          id: newList.length,
                          time: newList.length * 0.5,
                          wgt: currentWgtNotifier.value,
                        ));
                        // 更新重量数据列表的 ValueNotifier
                        wgtDataListNotifier.value = newList;
                      } else if (currentWgtNotifier.value != initialWeight) {
                        hasStartedRecording = true; // 重量变化，开始记录
                      } else {
                        // 添加日志，查看相等情况
                      }
                    }

                    if (hasStartedRecording) {
                      List<WgtDataInfo> newList =
                          List.from(wgtDataListNotifier.value);
                      newList.add(WgtDataInfo(
                        id: newList.length,
                        time: newList.length * 0.5,
                        wgt: currentWgtNotifier.value,
                      ));
                      // 更新重量数据列表的 ValueNotifier
                      wgtDataListNotifier.value = newList;

                      // 检查重量是否变化
                      if (newList.length > 1 &&
                          newList[newList.length - 1].wgt ==
                              newList[newList.length - 2].wgt) {
                        if (noChangeTimer == null) {
                          noChangeDuration = 0;
                          noChangeTimer = Timer.periodic(
                              const Duration(seconds: 1), (timer) {
                            noChangeDuration += 1;
                            if (noChangeDuration >= 3) {
                              // 3 秒未变化，结束记录
                              if (isStart) {
                                timer.cancel();
                                noChangeTimer = null;
                                setState(() {
                                  isStart = false;
                                });
                                weightCollectionTimer!.cancel();
                                weightCollectionTimer = null;
                                // 重置状态
                                initialWeight = null;
                                hasStartedRecording = false;
                                calculateRate();
                              }
                            }
                          });
                        }
                      } else {
                        // 重量变化，重置计时器
                        noChangeTimer?.cancel();
                        noChangeTimer = null;
                        noChangeDuration = 0;
                      }
                    }
                  });
                }
              } else if (weightCollectionTimer != null) {
                weightCollectionTimer!.cancel();
                weightCollectionTimer = null;
                // 重置状态
                initialWeight = null;
                hasStartedRecording = false;
                noChangeTimer = null;
              }
            } catch (e) {
              // 处理转换失败的情况
              // print('Failed to parse weight value: $e');
              currentWgtNotifier.value = 0.0;
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    eventbus8?.cancel();
    cntScaleTimerMgr.stopCntAliveTimer();
    PublicFunctions.stopWeight(selScaleId);
    eventbus1?.cancel();
    eventbus2?.cancel();
    if (weightCollectionTimer != null) {
      weightCollectionTimer!.cancel();
    }
    // 取消定时器
    setWgtStartFalseTimer?.cancel();
    checkWgtStartTimer?.cancel();

    processWgtList.clear();
    wgtDataList.clear();
    rateDataList.clear();
    currentWgtNotifier.dispose();
    currentUnitNotifier.dispose();
    wgtDataListNotifier.dispose();
    _scrollController.dispose(); // 释放 ScrollController
    _folwDataScrollCtl.dispose(); // 释放 ScrollController
    super.dispose();
  }

  List<FlowRateFromDb> sortWgtList(bool sort) {
    if (processWgtList.isNotEmpty) {
      if (sort) {
        // sort 为 true 时正序排序
        processWgtList.sort((a, b) =>
            a.flowRateHeader!.recId!.compareTo(b.flowRateHeader!.recId!));
      } else {
        // sort 为 false 时倒序排序
        processWgtList.sort((a, b) =>
            b.flowRateHeader!.recId!.compareTo(a.flowRateHeader!.recId!));
      }
    }
    return processWgtList;
  }

  showWgtTable() {
    return Expanded(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // 获取表格的最大宽度
      double maxWidth = constraints.maxWidth;
      // 计算表格的实际宽度，减去左侧和右侧的边距
      int columnCount = 5; // 列数

      double tableWidth = maxWidth - 80;
      //80 序号
      double columnWidth = tableWidth / columnCount;
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: StickyTable(
          controller: _scrollController, // 传递 ScrollController
          // 修改 data 属性
          data: processWgtList.isEmpty
              ? []
              // : sort
              //     ? processWgtList.reversed.toList()
              : processWgtList,
          defaultColumnWidth: const FixedColumnWidth(130),
          titleHeight: 40,
          cellHeight: 40,
          clickedRow: clickedRow,
          onRowClick: (row) {
            if (enableSelRaw) {
              setState(() {
                clickedRow = row;
                selectedProcessWgt = processWgtList[row];
                rateDataList = [];
                for (var item in selectedProcessWgt.flowRateDetail!) {
                  rateDataList.add(RateInfo(
                    id: item.id,
                    rate: item.rate,
                    time: item.time,
                  ));
                }
              });
            }
          },

          cellDecoration: (context, column, data, row, columnIndex) {
            // 添加点击行背景色
            if (row == clickedRow) {
              return BoxDecoration(
                color: clickColor,
                border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 1),
                ),
              );
            }
            return BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: lineColor, width: 1),
              ),
            );
          },
          columns: [
            StickyTableColumn(
              localizedStrings.fNo,
              fixedStart: true,
              showSort: true,
              sort: sort,
              columnWidth: FixedColumnWidth(80),
              alignment: Alignment.centerLeft,
              onTitleClick: (context, title) {
                setState(() {
                  sort = !sort; // 切换排序顺序
                  sortWgtList(sort);
                  clickedRow = -1;
                  selectedProcessWgt = FlowRateFromDb();
                  rateDataList = [];
                });
              },
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return Text(
                    (data as FlowRateFromDb).flowRateHeader!.recId.toString());
              },
              renderTitle: (context, title) {
                return SizedBox(
                  width: 80 - 20,
                  child: Text(
                    title.title,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fTotalWeight,
              showSort: true,
              sort: false,
              columnWidth: FixedColumnWidth(columnWidth),
              alignment: Alignment.topLeft,
              onCellClick: (context, title, data, row, column) {
                // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // ScaffoldMessenger.of(
                //   context,
                // ).showSnackBar(SnackBar(content: Text("年龄$data")));
              },
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return Text((data as FlowRateFromDb)
                        .flowRateHeader!
                        .totalWeight!
                        .toString() +
                    data.flowRateHeader!.wgtUnit!);
              },
            ),
            StickyTableColumn(
              localizedStrings.fTotalTime,
              columnWidth: FixedColumnWidth(columnWidth),
              showSort: true,
              sort: false,
              alignment: Alignment.topLeft,
              onCellClick: (context, title, data, row, column) {
                // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // ScaffoldMessenger.of(
                //   context,
                // ).showSnackBar(SnackBar(content: Text("年龄$data")));
              },
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return Text(
                    //修改了此处
                    '${(data as FlowRateFromDb).flowRateHeader!.totalTime}s');
              },
            ),
            StickyTableColumn(
              localizedStrings.fAverageSpeed,
              columnWidth: FixedColumnWidth(columnWidth),
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {
                // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // ScaffoldMessenger.of(
                //   context,
                // ).showSnackBar(SnackBar(content: Text("年龄$data")));
              },
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return Text(
                    '${(data as FlowRateFromDb).flowRateHeader!.averageFlowRate}${data.flowRateHeader!.wgtUnit!}/s');
              },
            ),
            StickyTableColumn(
              localizedStrings.fMaxSpeed,
              showSort: true,
              sort: false,
              columnWidth: FixedColumnWidth(columnWidth),
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {
                // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // ScaffoldMessenger.of(
                //   context,
                // ).showSnackBar(SnackBar(content: Text("年龄$data")));
              },
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return Text(
                    //修改了此处
                    '${(data as FlowRateFromDb).flowRateHeader!.maxFlowRate}${data.flowRateHeader!.wgtUnit!}/s');
              },
            ),
            StickyTableColumn(
              localizedStrings.fMinSpeed,
              showSort: true,
              sort: false,
              columnWidth: FixedColumnWidth(columnWidth),
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {
                // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // ScaffoldMessenger.of(
                //   context,
                // ).showSnackBar(SnackBar(content: Text("年龄$data")));
              },
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return Text(
                    //修改了此处
                    '${(data as FlowRateFromDb).flowRateHeader!.minFlowRate}${data.flowRateHeader!.wgtUnit!}/s');
              },
            ),
          ],
        ),
      );
    }));
  }

  showRateInfoTable() {
    return Expanded(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // 获取表格的最大宽度
      double maxWidth = constraints.maxWidth;
      // 计算表格的实际宽度，减去左侧和右侧的边距
      int columnCount = 3; // 列数

      double tableWidth = maxWidth;
      //80 序号
      double columnWidth = tableWidth / columnCount;
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: StickyTable(
          controller: _folwDataScrollCtl, // 传递 ScrollController
          // 修改 data 属性
          data: rateDataList.isEmpty
              ? []
              // : sort
              //     ? rateDataList.reversed.toList()
              : rateDataList,
          defaultColumnWidth: const FixedColumnWidth(130),
          titleHeight: 36,
          cellHeight: 36,
          clickedRow: -1, // clickedRow,
          onRowClick: (row) {
            // if (enableSelRaw) {
            //   setState(() {
            //     clickedRow = row;
            //     selectedProcessWgt = rateDataList[row];
            //     rateDataList = [];
            //     for (var item in selectedProcessWgt.flowRateDetail!) {
            //       rateDataList.add(RateInfo(
            //         id: item.id,
            //         rate: item.rate,
            //         time: item.time,
            //       ));
            //     }
            //   });
            // }
          },

          cellDecoration: (context, column, data, row, columnIndex) {
            // 添加点击行背景色
            if (row == -1) {
              return BoxDecoration(
                color: clickColor,
                border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 1),
                ),
              );
            }
            return BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: lineColor, width: 1),
              ),
            );
          },
          columns: [
            StickyTableColumn(
              localizedStrings.fNo,
              fixedStart: true,
              showSort: true,
              sort: sort,
              columnWidth: FixedColumnWidth(columnWidth),
              alignment: Alignment.centerLeft,
              onTitleClick: (context, title) {
                setState(() {
                  // sort = !sort; // 切换排序顺序
                });
              },
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return Text((data as RateInfo).id.toString());
              },
              renderTitle: (context, title) {
                return SizedBox(
                  width: columnWidth - 20,
                  child: Text(
                    title.title,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fTime,
              showSort: true,
              sort: false,
              columnWidth: FixedColumnWidth(columnWidth),
              alignment: Alignment.topLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return Text((data as RateInfo).time.toString());
              },
            ),
            StickyTableColumn(
              localizedStrings.fSpeed,
              columnWidth: FixedColumnWidth(columnWidth),
              showSort: true,
              sort: false,
              alignment: Alignment.topLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return Text((data as RateInfo).rate.toString());
              },
            ),
          ],
        ),
      );
    }));
  }

  void saveBtn() {
    ReqFlowRate addFlowRateData = ReqFlowRate();
    addFlowRateData.recDetail = [];
    addFlowRateData.recHeader = RecHeader(
        totalWeight: currRateHeader.totalWgt,
        totalTime: currRateHeader.totalTime,
        averageFlowRate: currRateHeader.avgSpeed,
        minFlowRate: currRateHeader.minSpeed,
        maxFlowRate: currRateHeader.maxSpeed,
        wgtUnit: currRateHeader.unit);

    if (rateDataList.isNotEmpty) {
      //将rateDataList中的数据保存到数据库中
      for (var item in rateDataList) {
        RecDetail temp = RecDetail(
          id: item.id,
          time: item.time,
          rate: item.rate,
        );
        addFlowRateData.recDetail!.add(temp);
      }
    }

    PublicFunctions.addFlowRateData(reqFlowRateToJson(addFlowRateData));
  }

  showTotalWeight(String title, String weight, String unit) {
    return Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.all(5),
          color: bgColor,
          child: Column(children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // 获取可用的最大宽度
                double maxWidth = constraints.maxWidth;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      // 使用可用的最大宽度
                      width: maxWidth,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                );
              },
            ),
            Expanded(
                child: Row(children: [
              Expanded(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown, // 仅在空间不足时缩小
                    alignment: Alignment.centerLeft,
                    child: Text(
                      weight.toString(),
                      style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  )),
              Text(unit),
            ])),
          ]),
        ));
  }

  //计算速率
  calculateRate() {
    if (!isStart) {
      // 结束了，将数据的值计算出来
      final List<WgtDataInfo> wgtDataList = wgtDataListNotifier.value;
      // for (var item in wgtDataList) {
      //   print('ID: ${item.id}, 时间: ${item.time}, 重量: ${item.wgt}');
      // }
      if (wgtDataList.isNotEmpty) {
        rateDataList.clear(); // 清空速率数据列表
        for (int i = 0; i < wgtDataList.length; i++) {
          double rate;
          double time = i * 0.5;
          if (i == 0) {
            rate = 0; // 第一个速率为 0
          } else {
            double prevWeight = wgtDataList[i - 1].wgt!;
            double currentWeight = wgtDataList[i].wgt!;
            rate = (currentWeight - prevWeight) / 0.5; // 计算速率
            if (rate < 0) {
              rate = 0;
            }
            rate = double.parse(rate.toStringAsFixed(3));
          }
          rateDataList.add(RateInfo(
            id: i,
            rate: rate,
            time: time,
          ));
        }
      }
      //判断rateDataList中后半段的数据是否都是0，是0的话则删除掉，最多留两个0
      int zeroCount = 0;
      for (int i = rateDataList.length - 1; i >= 0; i--) {
        if (rateDataList[i].rate == 0) {
          zeroCount++;
        }
      }
      if (zeroCount > 0) {
        rateDataList.removeRange(
            rateDataList.length - zeroCount, rateDataList.length);
      }
      //计算速率的最大值和最小值，总重量，时间，平均速度
      double maxRate = 0;
      double minRate = 1000000;
      double totalWgt = 0;
      double totalTime = 0;
      double avgSpeed = 0;
      //数据太少就返回
      if (rateDataList.length < 3) {
        rateDataList.clear();
        showTipInfo(localizedStrings.fDataTooLittle, context);
        return;
      }

      //平均速度是所有的速度加起来除以次数
      if (rateDataList.isNotEmpty) {
        for (var item in rateDataList) {
          avgSpeed += item.rate!;
          if (item.rate! > maxRate) {
            maxRate = item.rate!;
          }
          if (item.rate! < minRate && item.rate != 0) {
            minRate = item.rate!;
          }
        }
        avgSpeed = avgSpeed / (rateDataList.length - 1);
        avgSpeed = double.parse(avgSpeed.toStringAsFixed(3));
        maxRate = double.parse(maxRate.toStringAsFixed(3));
        minRate = double.parse(minRate.toStringAsFixed(3));
      }
      if (rateDataList.isNotEmpty) {
        totalTime = rateDataList[rateDataList.length - 1].time!;
        // 修改总重量计算逻辑
        if (wgtDataList.length >= 2) {
          totalWgt =
              wgtDataList[wgtDataList.length - 1].wgt! - wgtDataList[0].wgt!;
        } else if (wgtDataList.length == 1) {
          totalWgt = wgtDataList[0].wgt!;
        }
        totalWgt = double.parse(totalWgt.toStringAsFixed(3));
      }
      //添加到processWgtList中
      currRateHeader = RateDataInfo(
        id: processWgtList.length,
        totalWgt: totalWgt,
        minSpeed: minRate,
        maxSpeed: maxRate,
        avgSpeed: avgSpeed,
        totalTime: totalTime,
        unit: currentUnitNotifier.value,
      );
      setState(() {
        saveBtn();
      });
//打印出      weightRecords

      // for (var record in weightRecords) {
      //   print(
      //       'ID: ${record.id}, Weight: ${record.weight}, Timestamp: ${record.timestamp}');
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      color: bgColor, //对接时修改颜色值
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            showScaleList(),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  showTitleBar(),
                  Divider(
                    color: Theme.of(context).colorScheme.outline,
                    thickness: 1,
                    height: 1,
                  ),
                  Expanded(
                      flex: 9,
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Row(children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                  padding: EdgeInsets.all(50),

                                  //此处显示一张图片
                                  child: Image.asset(
                                    'assets/images/halfContainer.png',
                                    fit: BoxFit.contain,
                                  ))),
                          Expanded(
                              flex: 3,
                              child: Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Column(children: [
                                  SizedBox(
                                    height: 14,
                                  ),
                                  Expanded(
                                      flex: 7,
                                      child: Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        child: Row(children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              color: wgtBgColor,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 30,
                                                    padding: EdgeInsets.only(
                                                        left: 10),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      localizedStrings
                                                          .fCurrentWeightLabel,
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Container(
                                                          child: Row(children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          // 使用 ValueListenableBuilder 监听当前重量的变化
                                                          child:
                                                              ValueListenableBuilder<
                                                                  String>(
                                                            valueListenable:
                                                                currentWgtStrNotifier,
                                                            builder: (context,
                                                                value, child) {
                                                              return FittedBox(
                                                                fit: BoxFit
                                                                    .scaleDown, // 仅在空间不足时缩小
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  value
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          80,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .primary),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  bottom: 10),
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child:
                                                              ValueListenableBuilder<
                                                                  String>(
                                                            valueListenable:
                                                                currentUnitNotifier,
                                                            builder: (context,
                                                                value, child) {
                                                              return FittedBox(
                                                                fit: BoxFit
                                                                    .scaleDown, // 仅在空间不足时缩小
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  value
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          24,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .primary),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ))
                                                  ])))
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                                child: Row(children: [
                                              isStart
                                                  ? Expanded(
                                                      flex: 1,
                                                      child: SizedBox(),
                                                    )
                                                  : Expanded(
                                                      flex: 1,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .surface,
                                                          fixedSize: const Size(
                                                              double.infinity,
                                                              48),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .zero, // 可以根据需要调整圆角
                                                                  side:
                                                                      BorderSide(
                                                                    color: isStart
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .outline
                                                                        : Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                  )),
                                                        ),
                                                        onPressed: isStart
                                                            ? null
                                                            : () {
                                                                PublicFunctions
                                                                    .performZero();
                                                              },
                                                        child: Text(
                                                          localizedStrings
                                                              .iBtnZero,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      )),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              isStart
                                                  ? Expanded(
                                                      flex: 1,
                                                      child: SizedBox(),
                                                    )
                                                  : Expanded(
                                                      flex: 1,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .surface,
                                                          fixedSize: const Size(
                                                              double.infinity,
                                                              48),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .zero, // 可以根据需要调整圆角
                                                                  side:
                                                                      BorderSide(
                                                                    color: isStart
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .outline
                                                                        : Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                  )),
                                                        ),
                                                        onPressed: isStart
                                                            ? null
                                                            : () {
                                                                PublicFunctions
                                                                    .performTare();
                                                              },
                                                        child: Text(
                                                          localizedStrings
                                                              .gBtnTare,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      )),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                  flex: 1,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      fixedSize: const Size(
                                                          double.infinity, 48),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius: BorderRadius
                                                            .zero, // 可以根据需要调整圆角
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        isStart = !isStart;
                                                        if (isStart) {
                                                          wgtDataList
                                                              .clear(); // 清空重量数据列表
                                                          selectedProcessWgt =
                                                              FlowRateFromDb();
                                                          rateDataList = [];
                                                          clickedRow = -1;
                                                        } else {
                                                          calculateRate();
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      //下一步  修改了此处
                                                      isStart
                                                          ? localizedStrings
                                                              .gBtnEnd
                                                          : localizedStrings
                                                              .gBtnStart,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  )),
                                            ])),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ]),
                                      )),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Expanded(
                                      flex: 6,
                                      child: Container(
                                          child: Row(children: [
                                        showTotalWeight(
                                            localizedStrings.fTotalWeight,
                                            selectedProcessWgt.flowRateHeader ==
                                                    null
                                                ? ""
                                                : selectedProcessWgt
                                                    .flowRateHeader!.totalWeight
                                                    .toString(),
                                            selectedProcessWgt.flowRateHeader ==
                                                    null
                                                ? ""
                                                : selectedProcessWgt
                                                    .flowRateHeader!.wgtUnit!),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        showTotalWeight(
                                            localizedStrings.fTotalTime,
                                            selectedProcessWgt.flowRateHeader ==
                                                    null
                                                ? ""
                                                : selectedProcessWgt
                                                    .flowRateHeader!.totalTime
                                                    .toString(),
                                            's'),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        showTotalWeight(
                                            localizedStrings.fAverageSpeed,
                                            selectedProcessWgt.flowRateHeader ==
                                                    null
                                                ? ""
                                                : selectedProcessWgt
                                                    .flowRateHeader!
                                                    .averageFlowRate
                                                    .toString(),
                                            selectedProcessWgt.flowRateHeader ==
                                                    null
                                                ? ""
                                                : '${selectedProcessWgt.flowRateHeader!.wgtUnit!}/s'),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        showTotalWeight(
                                            localizedStrings.fMaxSpeed,
                                            selectedProcessWgt.flowRateHeader ==
                                                    null
                                                ? ""
                                                : selectedProcessWgt
                                                    .flowRateHeader!.maxFlowRate
                                                    .toString(),
                                            selectedProcessWgt.flowRateHeader ==
                                                    null
                                                ? ""
                                                : '${selectedProcessWgt.flowRateHeader!.wgtUnit!}/s'),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        showTotalWeight(
                                            localizedStrings.fMinSpeed,
                                            selectedProcessWgt.flowRateHeader ==
                                                    null
                                                ? ""
                                                : selectedProcessWgt
                                                    .flowRateHeader!.minFlowRate
                                                    .toString(),
                                            selectedProcessWgt.flowRateHeader ==
                                                    null
                                                ? ""
                                                : '${selectedProcessWgt.flowRateHeader!.wgtUnit!}/s'),
                                      ]))),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Expanded(
                                      flex: 18,
                                      child: Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        child: Column(children: [
                                          SizedBox(
                                              height: 36,
                                              child: Row(children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  child: Text(localizedStrings
                                                      .fHistoricalWeighingRecordsBtn),
                                                )),
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(children: [
                                                    Spacer(),
                                                    SizedBox(
                                                      width: 150,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fixedSize: const Size(
                                                              double.infinity,
                                                              48),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero, // 可以根据需要调整圆角
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          // 选择文件保存位置
                                                          final directory =
                                                              Directory
                                                                  .current.path;
                                                          String? outputFile =
                                                              (await FilePicker
                                                                  .platform
                                                                  .saveFile(
                                                            initialDirectory:
                                                                directory,
                                                            type:
                                                                FileType.custom,
                                                            dialogTitle:
                                                                'Output file:',
                                                            allowedExtensions: [
                                                              "csv"
                                                            ],
                                                            fileName:
                                                                'records.csv',
                                                          ));
                                                          if (outputFile !=
                                                              null) {
                                                            if (!outputFile
                                                                .contains(
                                                                    ".csv")) {
                                                              outputFile =
                                                                  "$outputFile.csv";
                                                            }
                                                            String filePath =
                                                                outputFile;
                                                            // 生成 CSV 数据
                                                            List<List<dynamic>>
                                                                csvData = [];

                                                            for (var headerData
                                                                in processWgtList) {
                                                              // 添加头数据

                                                              // 添加明细数据头
                                                              csvData.add([
                                                                'Rec ID',
                                                                'Total Weight',
                                                                'Total Time',
                                                                'Average Speed',
                                                                'Max Speed',
                                                                'Min Speed',
                                                                'ID',
                                                                'Time',
                                                                'Rate'
                                                              ]);
                                                              // 添加明细数据
                                                              for (var detail
                                                                  in headerData
                                                                      .flowRateDetail!) {
                                                                csvData.add([
                                                                  headerData
                                                                      .flowRateHeader!
                                                                      .recId,
                                                                  headerData
                                                                      .flowRateHeader!
                                                                      .totalWeight,
                                                                  headerData
                                                                      .flowRateHeader!
                                                                      .totalTime,
                                                                  headerData
                                                                      .flowRateHeader!
                                                                      .averageFlowRate,
                                                                  headerData
                                                                      .flowRateHeader!
                                                                      .maxFlowRate,
                                                                  headerData
                                                                      .flowRateHeader!
                                                                      .minFlowRate,
                                                                  detail.id,
                                                                  detail.time,
                                                                  detail.rate
                                                                ]);
                                                              }
                                                            }
                                                            // 将 CSV 数据写入文件
                                                            try {
                                                              // 尝试将数据转换为 CSV 格式
                                                              String csv =
                                                                  const ListToCsvConverter()
                                                                      .convert(
                                                                          csvData);
                                                              // 创建文件对象
                                                              File file = File(
                                                                  filePath);
                                                              // 尝试将 CSV 数据写入文件
                                                              await file
                                                                  .writeAsString(
                                                                      csv);
                                                              // 显示导出成功提示
                                                              showTipInfo(
                                                                  localizedStrings
                                                                      .fSaveSuccess,
                                                                  context);
                                                            } catch (e) {
                                                              // 处理写入文件时可能出现的异常，并显示错误提示
                                                              showTipInfo(' $e',
                                                                  context);
                                                            }
                                                          }
                                                        },
                                                        child: Text(
                                                          localizedStrings
                                                              .gBtnExport,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ]),
                                                ),
                                              ])),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Expanded(
                                              child: Row(
                                                  children: [showWgtTable()]))
                                        ]),
                                      )),
                                ]),
                              ))
                        ]),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 30,
                    color: Theme.of(context).colorScheme.surface,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              localizedStrings.fFlowRate,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 5,
                            ),
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  fixedSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.zero, // 可以根据需要调整圆角
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    showDataTable = !showDataTable;
                                  });
                                },
                                child: Text(
                                  showDataTable
                                      ? localizedStrings.fShowCurveChart
                                      : localizedStrings.fShowDataTable,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 6,
                      child: Container(
                          padding: EdgeInsets.only(top: 5),
                          color: Theme.of(context).colorScheme.surface,
                          child: Row(children: [
                            showDataTable
                                ? Expanded(
                                    child: Row(children: [showRateInfoTable()]))
                                : Expanded(
                                    child: LineChartSample5(
                                      rateDataList: rateDataList,
                                      unit: selectedProcessWgt.flowRateHeader ==
                                              null
                                          ? " "
                                          : selectedProcessWgt
                                              .flowRateHeader!.wgtUnit!,
                                    ),
                                  )
                          ]))),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  showComScale() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () {
                setState(() {
                  // selScaleId = 1;
                  _selectedScaleIndex = -1;
                  //串口秤
                });
                changeScale(1);
              },
              child: Container(
                height: 62,
                color: (selScaleId != 1)
                    ? Color(0xFFECF0F3)
                    : Theme.of(context).colorScheme.primary,
                child: Row(
                  children: [
                    Container(
                        width: 62,
                        height: 62,
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: (selScaleId != 1)
                                ? Color(0xFFD5D8DB)
                                : Color.fromRGBO(255, 255, 255, 0.1),
                          ),
                          width: 38,
                          height: 38,
                          child: Icon(
                            size: 20,
                            Icons.cable_sharp,
                            color: (selScaleId != 1)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                        )),
                    if (_isLeftPanelExpanded)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              myComScaleInfo.scaleName,
                              style: TextStyle(
                                  color: (selScaleId != 1)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 14),
                            ),
                            Text(
                              myComScaleInfo.isOnline
                                  ? localizedStrings.gOnlineTip
                                  : localizedStrings.gOfflineTip,
                              style: TextStyle(
                                  color: (selScaleId == 1)
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : myComScaleInfo.isOnline
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onTertiaryFixedVariant
                                          : Theme.of(context).colorScheme.error,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ))),
    );
  }

  showScaleListTitle() {
    return SizedBox(
        height: 54,
        width: _isLeftPanelExpanded ? 226 : 62,
        child: Row(children: [
          _isLeftPanelExpanded
              ? Expanded(
                  child: Text(
                  localizedStrings.fScaleList,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16),
                ))
              : SizedBox(
                  width: 0,
                ),
          Center(
            child: IconButton(
              iconSize: 24,
              onPressed: () {
                setState(() {
                  _isLeftPanelExpanded = !_isLeftPanelExpanded;
                });
              },
              icon: Icon(_isLeftPanelExpanded
                  ? Icons.format_indent_decrease_outlined
                  : Icons.format_indent_increase_outlined),
            ),
          ),
        ]));
  }

  showScaleList() {
    return AnimatedContainer(
      color: Theme.of(context).colorScheme.surface,
      width: _isLeftPanelExpanded ? 254 : 90,
      duration: Duration(milliseconds: 300),
      child: Column(
        children: [
          showScaleListTitle(),
          // 分割线
          Divider(
            color: Theme.of(context).colorScheme.outline,
            thickness: 1,
            height: 1,
          ),
          SizedBox(height: 14),
          showComScale(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ListView.separated(
                itemCount: scaleNetItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final scale = scaleNetItems[index];
                  bool isSelect = (selScaleId == scale.scaleId!);
                  return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedScaleIndex = index;
                              // selScaleId = scale.scaleId!;
                            });
                            changeScale(scale.scaleId!);
                          },
                          child: Container(
                            height: 62,
                            color: !isSelect
                                ? Color(0xFFECF0F3)
                                : Theme.of(context).colorScheme.primary,
                            child: Row(
                              children: [
                                Container(
                                    width: 62,
                                    height: 62,
                                    alignment: Alignment.center,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        color: !isSelect
                                            ? Color(0xFFD5D8DB)
                                            : Color.fromRGBO(
                                                255, 255, 255, 0.1),
                                      ),
                                      width: 38,
                                      height: 38,
                                      child: Icon(
                                        size: 20,
                                        Icons.wifi,
                                        color: !isSelect
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                      ),
                                    )),
                                if (_isLeftPanelExpanded)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          scale.scaleName ?? '',
                                          style: TextStyle(
                                              color: !isSelect
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          scale.isOnline!
                                              ? localizedStrings.gOnlineTip
                                              : localizedStrings.gOfflineTip,
                                          style: TextStyle(
                                              color: isSelect
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                  : scale.isOnline!
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .onTertiaryFixedVariant
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          )));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  showTitleBar() {
    return Container(
      height: 54,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_circle_left_outlined,
                  size: 28, color: Theme.of(context).colorScheme.primary)),
          Expanded(child: Text(localizedStrings.fFlowRate)),
          Icon(
            Icons.help,
            color: Color(0xFFF4B837),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }
}

class LineChartSample5 extends StatefulWidget {
  const LineChartSample5({
    super.key,
    required this.rateDataList,
    required this.unit,
    Color? gradientColor1,
    Color? gradientColor2,
    Color? gradientColor3,
    Color? indicatorStrokeColor,
  })  : gradientColor1 =
            gradientColor1 ?? const Color.fromARGB(255, 212, 68, 68),
        gradientColor2 =
            gradientColor2 ?? const Color.fromARGB(255, 173, 78, 110),
        gradientColor3 =
            gradientColor3 ?? const Color.fromARGB(255, 233, 45, 107),
        indicatorStrokeColor =
            indicatorStrokeColor ?? const Color.fromARGB(255, 53, 228, 225);

  final List<RateInfo> rateDataList; //速率数据列表
  final String unit; //单位
  final Color gradientColor1;
  final Color gradientColor2;
  final Color gradientColor3;
  final Color indicatorStrokeColor;

  @override
  State<LineChartSample5> createState() => _LineChartSample5State();
}

class _LineChartSample5State extends State<LineChartSample5> {
  // List<int> showingTooltipOnSpots = [1, 3, 5];  默认显示3个点
  List<int> showingTooltipOnSpots = [];
  List<RateInfo> previousRateDataList = [];

  List<FlSpot> allSpots = [];

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
      fontFamily: 'Digital',
      fontSize: 12,
    );
    String text = (value * 0.5).toString();

    // 获取最后一个点的索引
    final lastIndex =
        widget.rateDataList.isEmpty ? 0 : widget.rateDataList.length - 1;
    // 获取最后一个点对应的 value
    final lastValue = lastIndex.toDouble();

    // 判断当前 value 是否为最后一个刻度
    if (value == lastValue) {
      text += '(s)';
    }

    return Text(text, style: style);
  }

  initSpots() {
    allSpots = []; // 清空之前的点

    for (var i = 0; i < widget.rateDataList.length; i++) {
      allSpots.add(
        FlSpot(
          widget.rateDataList[i].id!.toDouble(),
          widget.rateDataList[i].rate!.toDouble(),
        ),
      );
    }
  }

  @override
  void initState() {
    showingTooltipOnSpots = [];
    previousRateDataList = widget.rateDataList;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant LineChartSample5 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rateDataList != oldWidget.rateDataList) {
      // 图像切换，清空 showingTooltipOnSpots
      setState(() {
        showingTooltipOnSpots = [];
      });
      previousRateDataList = widget.rateDataList;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rateDataList.isEmpty) {
      return Container();
    }
    initSpots();

    double maxYValue = widget.rateDataList
        .map((e) => e.rate)
        .reduce((a, b) => a! > b! ? a : b)!;
    maxYValue = double.parse(maxYValue.toStringAsFixed(3));
    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: true,
        barWidth: 1,
        // shadow: const Shadow(blurRadius: 8),阴影
        // belowBarData: BarAreaData(
        //   show: true,
        //   gradient: LinearGradient(
        //     colors: [
        //       widget.gradientColor1.withValues(alpha: 0.4),
        //       widget.gradientColor2.withValues(alpha: 0.4),
        //       widget.gradientColor3.withValues(alpha: 0.4),
        //     ],
        //   ),
        // ),
        dotData: const FlDotData(show: false),
        // gradient: LinearGradient(
        //   colors: [
        //     widget.gradientColor1,
        //     widget.gradientColor2,
        //     widget.gradientColor3,
        //   ],
        //   stops: const [0.1, 0.4, 0.9],
        // ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    double yInterval = (maxYValue / 6);
    if (yInterval < 0.005) {
      yInterval = 0.005;
    } else if (yInterval < 0.01) {
      yInterval = 0.01;
    } else if (yInterval < 0.05) {
      yInterval = 0.05;
    } else if (yInterval < 1) {
      yInterval = 1;
    } else if (yInterval < 2) {
      yInterval = 2;
    } else if (yInterval < 4) {
      yInterval = 4;
    } else if (yInterval < 5) {
      yInterval = 5;
    } else if (yInterval < 10) {
      yInterval = 10;
    } else if (yInterval < 15) {
      yInterval = 15;
    } else if (yInterval < 20) {
      yInterval = 20;
    } else if (yInterval < 30) {
      yInterval = 30;
    } else if (yInterval < 40) {
      yInterval = 40;
    } else if (yInterval < 50) {
      yInterval = 50;
    } else if (yInterval < 100) {
      yInterval = 100;
    } else {
      yInterval = (maxYValue / 6).ceilToDouble();
    }
    print(yInterval);
    maxYValue = yInterval * (maxYValue / yInterval).ceilToDouble();
//最多保留三位小数
    maxYValue = double.parse(maxYValue.toStringAsFixed(2));
    print(maxYValue);

    double xInterval = max(
      1,
      (allSpots.length / 15 + 1).toInt().toDouble(),
    );

    // 计算实际最大的横轴值
// 计算实际最大的横轴值
    double actualMaxX = allSpots.isEmpty
        ? 0
        : allSpots.map((spot) => spot.x).reduce((a, b) => a > b ? a : b);
    // 将最大横轴值向上取整为 xInterval 的整数倍
    double maxXValue = xInterval * (actualMaxX / xInterval).ceilToDouble();

    return AspectRatio(
      aspectRatio: 2.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return LineChart(
              LineChartData(
                showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                  return ShowingTooltipIndicators([
                    LineBarSpot(
                      tooltipsOnBar,
                      lineBarsData.indexOf(tooltipsOnBar),
                      tooltipsOnBar.spots[index],
                    ),
                  ]);
                }).toList(),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback: (
                    FlTouchEvent event,
                    LineTouchResponse? response,
                  ) {
                    if (response == null || response.lineBarSpots == null) {
                      return;
                    }
                    if (event is FlTapUpEvent) {
                      final spotIndex = response.lineBarSpots!.first.spotIndex;
                      setState(() {
                        if (showingTooltipOnSpots.contains(spotIndex)) {
                          showingTooltipOnSpots.remove(spotIndex);
                        } else {
                          showingTooltipOnSpots.add(spotIndex);
                        }
                      });
                    }
                  },
                  mouseCursorResolver: (
                    FlTouchEvent event,
                    LineTouchResponse? response,
                  ) {
                    if (response == null || response.lineBarSpots == null) {
                      return SystemMouseCursors.basic;
                    }
                    return SystemMouseCursors.click;
                  },
                  getTouchedSpotIndicator: (
                    LineChartBarData barData,
                    List<int> spotIndexes,
                  ) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(color: Theme.of(context).colorScheme.primary),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 4,
                            color: barData.gradient != null
                                ? lerpGradient(
                                    barData.gradient!.colors,
                                    barData.gradient!.stops!,
                                    percent / 100,
                                  )
                                : Theme.of(context)
                                    .colorScheme
                                    .primary, // 提供一个默认颜色
                            strokeWidth: 2,
                            strokeColor: widget.indicatorStrokeColor,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        Theme.of(context).colorScheme.primary,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                      return lineBarsSpot.map((lineBarSpot) {
                        return LineTooltipItem(
                          lineBarSpot.y.toString(),
                          TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: lineBarsData,
                minY: 0,
                maxY: maxYValue == 0.03 ? 0.025 : maxYValue,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: RotatedBox(
                      quarterTurns: 1, // 逆时针旋转 90 度
                      child: Text('${widget.unit}/s'),
                    ),
                    axisNameSize: 40,
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      'Time (s)',
                      textAlign: TextAlign.left,
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: xInterval,
                      getTitlesWidget: (value, meta) {
                        return bottomTitleWidgets(
                          value,
                          meta,
                          constraints.maxWidth,
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    axisNameWidget: Text('',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey,
                        )),
                    sideTitles: SideTitles(showTitles: true, reservedSize: 0),
                  ),
                  topTitles: const AxisTitles(
                    axisNameWidget: Text(
                      '',
                      textAlign: TextAlign.left,
                    ),
                    axisNameSize: 24,
                    sideTitles: SideTitles(showTitles: true, reservedSize: 0),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                    bottom: BorderSide(color: Colors.grey),
                  ),
                ),
                maxX: maxXValue,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Lerps between a [LinearGradient] colors, based on [t]
Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  if (colors.isEmpty) {
    throw ArgumentError('"colors" is empty.');
  } else if (colors.length == 1) {
    return colors[0];
  }

  if (stops.length != colors.length) {
    stops = [];

    /// provided gradientColorStops is invalid and we calculate it here
    colors.asMap().forEach((index, color) {
      final percent = 1.0 / (colors.length - 1);
      stops.add(percent * index);
    });
  }

  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s];
    final rightStop = stops[s + 1];
    final leftColor = colors[s];
    final rightColor = colors[s + 1];
    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}
