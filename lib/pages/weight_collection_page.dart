//重量收集页面 20250522

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/new_get_recs.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/record_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/settingparam_data.dart';
import 'package:t_max/data/weight_report_data.dart';
import 'package:t_max/data/wgt_rpt_data_source.dart';
import 'package:t_max/dialog/setting_dialog.dart';
import 'package:t_max/dialog/weight_report_feilds_setting.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/page_info.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/wgt_value_with_list_widget.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/comscaleinfo_data.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../widget/page_head.dart';

class WeightDataCollectionPage extends StatefulWidget {
  const WeightDataCollectionPage({super.key});
  @override
  State<WeightDataCollectionPage> createState() =>
      WeightDataCollectionPageState();
}

class WeightDataCollectionPageState extends State<WeightDataCollectionPage> {
  List<NetScaleInfoLocal> scaleNetItems = [];

  List<int> mySelScaleIdList = [];

  Map<int, ReceiveWgtInfo> myScaleWgtMap = {};
  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus5;
  dynamic eventBus4;
  dynamic eventBus6;
  dynamic eventBus7;

  GetScaleRecords currGetScaleRecords = GetScaleRecords(weightRecords: []);

  bool firstGetRec = true;
  int maxRecId = 0;
  int dateformat = 1;
  List<ScaleRecInfo> allWgtRecList = [];
  bool sort = false;
  int clickedRow = -1;

  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();

  late TableState _tableState;

  @override
  void initState() {
    super.initState();

    // 初始化 TableState
    _tableState = TableState();
    _tableState.loadPage(1);

    PublicFunctions.getUIConfNormal();
    eventBus1 = eventBus.on<EventUpdateSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          PublicFunctions.getUIConfNormal();
        });
      }
    });

    eventBus2 = eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          myModeSettingNormal = event.obj;
        });
      }
    });

    eventBus3 = eventBus.on<EventRevAddRec>().listen((event) {
      if (mounted) {
        _tableState.loadPage(1);
      }
    });

    eventBus4 = eventBus.on<EventRespGetAllWgtRecs>().listen((event) {
      if (mounted) {
        setState(() {
          String jsonString = event.obj;

          RevAllWgtRecs getAllWgtInfo = revAllWgtRecsFromJson(jsonString);
          if (getAllWgtInfo.totalCount! > 0) {
            List<ScaleRecInfo>? scaleRecInfos = getAllWgtInfo.scaleRecInfos;

            allWgtRecList.clear();

            allWgtRecList = List<ScaleRecInfo>.from(scaleRecInfos!);

            _tableState.addData(allWgtRecList);
            _tableState.setTotalCount(getAllWgtInfo.totalCount!);
            // _tableState.loadPage(1);
          } else {
            allWgtRecList.clear();
            // wgtRptDataList.clear();
            // updateTableData(getWeightReportData());
          }
        });
      }
    });

    eventBus5 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
        } else {}
      }
    });

    eventBus6 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {}
      }
    });

    eventBus7 = eventBus.on<EventDelAllWgtRecs>().listen((event) {
      if (mounted) {
        _tableState.loadPage(1);
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus2.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    eventBus7.cancel();

    for (var item in mySelScaleIdList) {
      PublicFunctions.stopWeight(item);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          width: width,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myPageHeadInfo(
                    context,
                    width - headWidthPadding,
                    localizedStrings.menuWeighingDataCollection,
                    localizedStrings.gTipWgtDataCollectionHelp),
                Container(
                  height: regularPadding,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                Expanded(
                    child: Container(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: Row(
                    children: [
                      Container(
                        width: appScaleListWidth,
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
                                child: NewMutiScaleListWidget(
                                  listWidth: appScaleListWidth, // 列表宽度
                                  selScaleList: mySelScaleIdList,
                                  clickScale: (scale) {
                                    setState(() {
                                      addOrRemoveSelScale(scale.scaleId);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: regularPadding,
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                      ),
                      showScaleWgt(context, 351),
                      Container(
                        width: regularPadding,
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                      ),
                      showWgtTable(context) // width - 591 - 36)
                    ],
                  ),
                )),
              ])),
    );
  }

  void addOrRemoveSelScale(int scaleId) {
    if (mySelScaleIdList.contains(scaleId)) {
      mySelScaleIdList.remove(scaleId);
      PublicFunctions.stopWeight(scaleId);
    } else {
      mySelScaleIdList.add(scaleId);
      PublicFunctions.getWeight(scaleId);
    }
    setState(() {}); // 强制刷新界面
  }

  String getScaleName(int scaleId) {
    String scaleName = "";

    for (var item in myAllScalesList) {
      if (item.scaleId == scaleId) {
        scaleName = item.scaleName;
        return scaleName;
      }
    }

    return scaleName;
  }

  Widget showScaleWgt(BuildContext context, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(bottom: regularPadding),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListView.builder(
        itemCount: mySelScaleIdList.length,
        itemBuilder: (context, index) {
          final scaleId = mySelScaleIdList[index];
          // 无论设备 ID 是否已创建，都返回 ScaleItemWithListWidget
          return ScaleWgtWidget(
            key: ValueKey(scaleId), // 使用 ValueKey 确保状态正确更新
            scaleId: scaleId,
            scaleName: getScaleName(scaleId),
          );
        },
      ),
    );
  }

  showWgtTable(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(
                      left: regularPadding, right: regularPadding),
                  height: 68,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      showTextButton(
                          context,
                          32,
                          localizedStrings.gBtnExport,
                          () {},
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary),
                      SizedBox(
                        width: regularPadding,
                      ),
                      showTextButton(context, 32, localizedStrings.gBtnSetting,
                          () {
                        reportFieldsSettingDialog(context);
                      },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary),
                      SizedBox(
                        width: regularPadding,
                      ),
                      showTextButton(context, 32, 'parameter Setting', () {
                        paramSettingDialog(context);
                      },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary),
                      SizedBox(
                        width: regularPadding,
                      ),
                      showTextButton(context, 32, localizedStrings.gBtnDelete,
                          () {
                        PublicFunctions.newDeleteAllRecords(0);
                      },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary)
                    ],
                  )),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.surfaceDim,
              ),
              SizedBox(
                height: regularPadding,
              ),
              ChangeNotifierProvider<TableState>.value(
                value: _tableState,
                child: DataTableDemo(),
              ),
            ],
          )),
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
          print(111);
          for (var item in myReportFeildsMap.keys) {
            _tableState._visibleColumns[item]!.isSelect =
                myReportFeildsMap[item]!.isSelect;
          }
        });
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

  Widget myPageHeadInfo(
      dynamic context, double maxWidth, String pageTitle, String helpInfo) {
    return Container(
        height: pageTopTitleHeight,
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                subTitle(context, maxWidth, pageTitle),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                    child: Text(
                      mySettingParam.wgtMode == 0
                          ? localizedStrings.gTipStandaloneMode
                          : localizedStrings.gTipWeightSummationMode,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .apply(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(
                    width: largePadding,
                  ),
                  PageInfoButton(helpInfo: helpInfo, onRefresh: () {}),
                  const SizedBox(
                    width: largePadding,
                  ),
                ])
              ],
            ),
          ),
          Divider(
            color:
                Theme.of(context).colorScheme.surfaceContainerLow, // 设置分割线的颜色
            height: 1, // 设置分割线的高度
            thickness: 1, // 设置分割线的粗细
          ),
        ]));
  }
}

//显示表格

class DataTableDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tableState = Provider.of<TableState>(context);
    ScrollController scrollController = ScrollController();
    ScrollController _horizontalScrollController = ScrollController();

    // 延迟初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tableState.allData.isEmpty) {
        // tableState.initializeData(100);
      }
    });

    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints builder) {
          final double width = builder.maxWidth; // 获取当前可用宽度
          final double height = builder.maxHeight;
          double minWidth = width;
          int count = getItemNum(tableState);
          if (count * 200 > width) {
            minWidth = count * 200;
          }
          return SizedBox(
            height: height,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                        left: regularPadding, right: regularPadding),
                    child: Scrollbar(
                      controller:
                          _horizontalScrollController, // 将 ScrollController 传递给 Scrollbar
                      thumbVisibility: true, // 始终显示滚动条
                      trackVisibility: true, // 始终显示滚动条轨道
                      interactive: true, // 允许用户直接与滚动条交互
                      child: SingleChildScrollView(
                        controller:
                            _horizontalScrollController, // 将 ScrollController 传递给 SingleChildScrollView
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: minWidth,
                          child: Column(
                            children: [
                              // 表头放在水平滚动组件内，垂直滚动组件外
                              Container(
                                height: 36,
                                width: minWidth,
                                color: Theme.of(context).colorScheme.surfaceDim,
                                child: DataTable(
                                    columns: _buildColumns(context, tableState),
                                    rows: [],
                                    showCheckboxColumn: false,
                                    headingRowHeight: 36,
                                    columnSpacing: 5,
                                    horizontalMargin: 10),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  controller: scrollController,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: tableState.currentPageData.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        tableState.currentPageData[index];
                                    return Column(
                                      children: [
                                        Container(
                                          width: minWidth,
                                          color: item.isExpanded
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .surfaceDim
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                          child: DataTable(
                                              columns: _buildColumns(
                                                  context, tableState),
                                              rows: [
                                                DataRow(
                                                  cells: _buildDataCells(
                                                      context,
                                                      tableState,
                                                      item),
                                                  onSelectChanged: (_) =>
                                                      tableState.toggleExpanded(
                                                          item.id),
                                                ),
                                              ],
                                              headingRowHeight: 0, // 隐藏主行的表头
                                              showCheckboxColumn:
                                                  false, // 隐藏主行的复选框
                                              columnSpacing: 5,
                                              horizontalMargin: 10),
                                        ),
                                        // 明细行
                                        if (item.isExpanded)
                                          ...item.scaleRec.details!.map(
                                            (detail) => SizedBox(
                                              width: minWidth,
                                              // color: Colors.grey[100],
                                              child: DataTable(
                                                  columns: _buildColumns(
                                                      context, tableState),
                                                  rows: [
                                                    DataRow(
                                                      cells:
                                                          _buildDetailDataCells(
                                                        context,
                                                        tableState,
                                                        detail,
                                                      ),
                                                    ),
                                                  ],
                                                  headingRowHeight:
                                                      0, // 隐藏明细行的表头
                                                  columnSpacing: 5,
                                                  horizontalMargin: 10),
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
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.first_page),
                        onPressed: () => tableState.goToPage(1),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: tableState.previousPage,
                      ),
                      Text(
                        '第 ${tableState.currentPage} 页 / 共 ${(tableState._totalCount / tableState._itemsPerPage).ceil()} 页  ',
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: tableState.nextPage,
                      ),
                      IconButton(
                        icon: Icon(Icons.last_page),
                        onPressed: () => tableState.goToPage(
                          (tableState._totalCount / tableState._itemsPerPage)
                              .ceil(),
                        ),
                      ),
                      Text(
                        '${tableState._itemsPerPage}/页   共${tableState._totalCount}  ',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int getItemNum(TableState tableState) {
    int itemNum = 0;
    for (var item in tableState.visibleColumns.values) {
      if (item.isSelect) {
        itemNum += 1;
      }
    }
    return itemNum;
  }

  // 构建表格列
  List<DataColumn> _buildColumns(BuildContext context, TableState tableState) {
    return [
      if (tableState.visibleColumns['Id']!.isSelect)
        getDataColumn(context, tableState.visibleColumns['Id']!.showName,
            width: 60),
      if (tableState.visibleColumns['Date Time']!.isSelect)
        getDataColumn(
            context, tableState.visibleColumns['Date Time']!.showName),
      if (tableState.visibleColumns['PLU']!.isSelect)
        getDataColumn(context, tableState.visibleColumns['PLU']!.showName),
      if (tableState.visibleColumns['Product Code']!.isSelect)
        getDataColumn(
            context, tableState.visibleColumns['Product Code']!.showName),
      if (tableState.visibleColumns['Item Code']!.isSelect)
        getDataColumn(
            context, tableState.visibleColumns['Item Code']!.showName),
      if (tableState.visibleColumns['PLU Name']!.isSelect)
        getDataColumn(context, tableState.visibleColumns['PLU Name']!.showName),
      if (tableState.visibleColumns['Price']!.isSelect)
        getDataColumn(context, tableState.visibleColumns['Price']!.showName),
      if (tableState.visibleColumns['GeneralUnit']!.isSelect)
        getDataColumn(
            context, tableState.visibleColumns['GeneralUnit']!.showName),
      if (tableState.visibleColumns['TaxType']!.isSelect)
        getDataColumn(context, tableState.visibleColumns['TaxType']!.showName),
      if (tableState.visibleColumns['UnitWeight']!.isSelect)
        getDataColumn(
            context, tableState.visibleColumns['UnitWeight']!.showName),
      if (tableState.visibleColumns['LimitHigh']!.isSelect)
        getDataColumn(
            context, tableState.visibleColumns['LimitHigh']!.showName),
      if (tableState.visibleColumns['LimitLow']!.isSelect)
        getDataColumn(context, tableState.visibleColumns['LimitLow']!.showName),
      if (tableState.visibleColumns['Weight']!.isSelect)
        getDataColumn(context, tableState.visibleColumns['Weight']!.showName),
      if (tableState.visibleColumns['Weight Unit']!.isSelect)
        getDataColumn(
            context, tableState.visibleColumns['Weight Unit']!.showName),
      if (tableState.visibleColumns['Pretare']!.isSelect)
        getDataColumn(context, tableState.visibleColumns['Pretare']!.showName),
      if (tableState.visibleColumns['Scale Name']!.isSelect)
        getDataColumn(
            context, tableState.visibleColumns['Scale Name']!.showName),
      DataColumn(
          label: Container(
        width: 100,
      )),
    ];
  }

  DataColumn getDataColumn(BuildContext context, String title,
      {double? width}) {
    width ??= 200;
    return DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: SizedBox(
          width: width,
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        ));
  }

  // 构建主行数据单元格
  List<DataCell> _buildDataCells(
      BuildContext context, TableState tableState, DataItem item) {
    final cells = <DataCell>[];

    if (tableState.visibleColumns['Id']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.recId.toString(),
        width: 60,
      ));
    }
    if (tableState.visibleColumns['Date Time']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.createdAt!.toIso8601String(),
      ));
    }
    if (tableState.visibleColumns['PLU']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.plu.toString(),
      ));
    }
    if (tableState.visibleColumns['Product Code']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.productCode.toString(),
      ));
    }
    if (tableState.visibleColumns['Item Code']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.itemCode.toString(),
      ));
    }
    if (tableState.visibleColumns['PLU Name']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.productName.toString(),
      ));
    }
    if (tableState.visibleColumns['Price']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.price.toString(),
      ));
    }
    if (tableState.visibleColumns['GeneralUnit']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.generalUnit.toString(),
      ));
    }
    if (tableState.visibleColumns['TaxType']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.taxType.toString(),
      ));
    }
    if (tableState.visibleColumns['UnitWeight']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.unitWeight.toString(),
      ));
    }
    if (tableState.visibleColumns['LimitHigh']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.limitHigh.toString(),
      ));
    }
    if (tableState.visibleColumns['LimitLow']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.limitLow.toString(),
      ));
    }
    if (tableState.visibleColumns['Weight']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.weight.toString(),
      ));
    }
    if (tableState.visibleColumns['Weight Unit']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.weightUnit.toString(),
      ));
    }
    if (tableState.visibleColumns['Pretare']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.pretare.toString(),
      ));
    }
    if (tableState.visibleColumns['Scale Name']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.scaleName.toString(),
      ));
    }
    cells.add(
      DataCell(
        item.scaleRec.details == null || item.scaleRec.details!.isEmpty
            ? SizedBox(
                // width: 100,
                )
            : SizedBox(
                // width: 100,
                child: IconButton(
                  alignment: Alignment.center,
                  icon: Icon(
                      item.isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => tableState.toggleExpanded(item.id),
                ),
              ),
      ),
    );
    return cells;
  }

  DataCell getDataCell(BuildContext context, String title, {double? width}) {
    width ??= 200;
    return DataCell(SizedBox(
      width: width,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .apply(color: Theme.of(context).colorScheme.onSurface),
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }

  // 构建明细行数据单元格
  List<DataCell> _buildDetailDataCells(
    BuildContext context,
    TableState tableState,
    Detail detail,
  ) {
    final cells = <DataCell>[];

    if (tableState.visibleColumns['Id']!.isSelect) {
      cells.add(getDataCell(context, '', width: 60));
    }
    if (tableState.visibleColumns['Date Time']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['PLU']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['Product Code']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['Item Code']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['PLU Name']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['Price']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['GeneralUnit']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['TaxType']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['UnitWeight']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['LimitHigh']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['LimitLow']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['Weight']!.isSelect) {
      cells.add(getDataCell(
        context,
        detail.weight.toString(),
      ));
    }
    if (tableState.visibleColumns['Weight Unit']!.isSelect) {
      cells.add(getDataCell(
        context,
        detail.weightUnit.toString(),
      ));
    }
    if (tableState.visibleColumns['Pretare']!.isSelect) {
      cells.add(getDataCell(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['Scale Name']!.isSelect) {
      cells.add(getDataCell(
        context,
        detail.scaleName!,
      ));
    }
    cells.add(DataCell(SizedBox()));
    return cells;
  }
}

class DataItem {
  int id;
  ScaleRecInfo scaleRec;
  bool isExpanded;

  DataItem({
    required this.id,
    required this.scaleRec,
    this.isExpanded = false,
  });
}

// 表格状态管理
class TableState with ChangeNotifier {
  // 可显示的列配置
  final Map<String, ReportShowName> _visibleColumns = {
    'Id': ReportShowName('Id', true),
    'Date Time': ReportShowName(localizedStrings.gRptDateTime, true),
    'PLU': ReportShowName('PLU', true),
    'Product Code': ReportShowName(localizedStrings.gPluPluCode, false),
    'Item Code': ReportShowName(localizedStrings.gPluItemCode, false),
    'PLU Name': ReportShowName(localizedStrings.gPluPluName, true),
    'Price': ReportShowName(localizedStrings.gPluPrice, false),
    'GeneralUnit': ReportShowName(localizedStrings.gPluWgtUnit, false),
    'TaxType': ReportShowName(localizedStrings.gPluTaxType, false),
    'UnitWeight': ReportShowName(localizedStrings.gPluUnitWgt, false),
    'LimitHigh': ReportShowName(localizedStrings.gPluLimitHigh, false),
    'LimitLow': ReportShowName(localizedStrings.gPluLimitLow, false),
    'Weight': ReportShowName(localizedStrings.gRptWeight, true),
    'Weight Unit': ReportShowName(localizedStrings.gRptWeightUnit, true),
    'Pretare': ReportShowName(localizedStrings.gPluPretare, false),
    // 'User NO.': ReportShowName('User NO.', false),
    // 'User Name': ReportShowName('User Name', true),
    'Scale Name': ReportShowName(localizedStrings.gScaleName, true),
  };
  Map<String, ReportShowName> get visibleColumns => _visibleColumns;

  // 分页状态
  int _currentPage = 1;
  int get currentPage => _currentPage;
  final int _itemsPerPage = 100;
  int _totalCount = 0; // 总数据条数

  // 模拟数据
  final List<DataItem> _allData = [];
  List<DataItem> get allData => _allData;

  // 获取当前页数据
  List<DataItem> get currentPageData {
    final startIndex = (1 - 1) * _itemsPerPage;
    final endIndex = min(startIndex + _itemsPerPage, _allData.length);
    return _allData.sublist(startIndex, endIndex);
  }

  // 假设这是请求数据的方法，需要根据实际情况实现
  void fetchData(int page, int pageSize) {
    PublicFunctions.newGetRecords(
      0,
      page,
      pageSize,
      sortColumnName.toString(),
      sortDirectValue.name,
    );
    return;
  }

  // 设置总数据条数
  void setTotalCount(int totalCount) {
    _totalCount = totalCount;
    notifyListeners();
  }

  // 加载指定页的数据
  Future<void> loadPage(int page) async {
    if (page >= 1 && page <= (_totalCount / _itemsPerPage).ceil()) {
      _currentPage = page;
      _allData.clear();
    }
    fetchData(page, _itemsPerPage);
  }

  void addData(List<ScaleRecInfo> newData) {
    _allData.clear();
    for (var item in newData) {
      _allData.add(DataItem(id: item.header!.recId!, scaleRec: item));
    }
    notifyListeners();
  }

  // 切换行展开状态
  void toggleExpanded(int id) {
    final index = _allData.indexWhere((item) => item.id == id);
    if (index != -1) {
      _allData[index].isExpanded = !_allData[index].isExpanded;
      notifyListeners();
    }
  }

  // 切换列显示状态
  void toggleColumnVisibility(String columnKey) {
    if (_visibleColumns.containsKey(columnKey)) {
      _visibleColumns[columnKey]!.isSelect =
          !_visibleColumns[columnKey]!.isSelect;
      notifyListeners();
    }
  }

  //分页控制方法
  Future<void> previousPage() async {
    if (_currentPage > 1) {
      await loadPage(_currentPage - 1);
    }
  }

  Future<void> nextPage() async {
    if (_currentPage < (_totalCount / _itemsPerPage).ceil()) {
      await loadPage(_currentPage + 1);
    }
  }

  Future<void> goToPage(int page) async {
    await loadPage(page);
  }
}
