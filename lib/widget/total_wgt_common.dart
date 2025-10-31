//汇总称重之后共用的widget
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/new_get_recs.dart';

import 'package:t_max/data/settingparam_data.dart';
import 'package:t_max/data/weight_report_data.dart';
import 'package:t_max/data/wgt_rpt_data_source.dart';
import 'package:t_max/functions/methods.dart';

//显示表格

Map<String, String> pluUnitSwitch = {
  '0': "kg",
  '1': "100g",
  '2': "pcs",
  '3': "lb",
  '4': "g",
  '5': "oz",
  '6': "lboz",
  '7': "tj",
  '8': "hj",
  '9': "t",
};
Map<String, String> pluTaxSwitch = {
  '0': "tax1",
  '1': "tax2",
  '2': "tax3",
};

class WgtDataTable extends StatelessWidget {
  const WgtDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    final tableState = Provider.of<TableState>(context);
    ScrollController scrollController = ScrollController();
    ScrollController horizontalScrollController = ScrollController();

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
          if (count * 150 > width) {
            minWidth = count * 150 + 50;
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
                          horizontalScrollController, // 将 ScrollController 传递给 Scrollbar
                      thumbVisibility: true, // 始终显示滚动条
                      trackVisibility: true, // 始终显示滚动条轨道
                      interactive: true, // 允许用户直接与滚动条交互
                      child: SingleChildScrollView(
                        controller:
                            horizontalScrollController, // 将 ScrollController 传递给 SingleChildScrollView
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
                                              columns: _buildDataColumns(
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
                                                      context, tableState,
                                                      isShowSort: false),
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
                        '${localizedStrings.tipPageSequnce} ${tableState.currentPage}   /  ${(tableState._totalCount / tableState._itemsPerPage).ceil()} ${localizedStrings.tipPage}  ',
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
                        '  ${localizedStrings.tipPageTotal} ${tableState._totalCount}  ',
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

  // 新增一个用于数据行的列构建方法（无排序功能）
  List<DataColumn> _buildDataColumns(
      BuildContext context, TableState tableState) {
    return [
      if (tableState.visibleColumns['Id']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['Id']!.showName,
          width: 60,
        ),
      if (tableState.visibleColumns['Date Time']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['Date Time']!.showName,
        ),
      if (tableState.visibleColumns['PLU']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['PLU']!.showName,
        ),
      if (tableState.visibleColumns['Product Code']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['Product Code']!.showName,
        ),
      if (tableState.visibleColumns['Item Code']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['Item Code']!.showName,
        ),
      if (tableState.visibleColumns['PLU Name']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['PLU Name']!.showName,
        ),
      if (tableState.visibleColumns['Price']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['Price']!.showName,
        ),
      if (tableState.visibleColumns['GeneralUnit']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['GeneralUnit']!.showName,
        ),
      if (tableState.visibleColumns['TaxType']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['TaxType']!.showName,
        ),
      if (tableState.visibleColumns['UnitWeight']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['UnitWeight']!.showName,
        ),
      if (tableState.visibleColumns['LimitHigh']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['LimitHigh']!.showName,
        ),
      if (tableState.visibleColumns['LimitLow']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['LimitLow']!.showName,
        ),
      if (tableState.visibleColumns['Weight']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['Weight']!.showName,
        ),
      if (tableState.visibleColumns['Weight Unit']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['Weight Unit']!.showName,
        ),
      if (tableState.visibleColumns['Pretare']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['Pretare']!.showName,
        ),
      if (tableState.visibleColumns['User Name']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['User Name']!.showName,
        ),
      if (tableState.visibleColumns['Scale Name']!.isSelect)
        _getDataColumnWithoutSort(
          context,
          tableState.visibleColumns['Scale Name']!.showName,
        ),
      DataColumn(label: Container(width: 90)),
    ];
  }

// 新增一个不带排序功能的列构建方法
  DataColumn _getDataColumnWithoutSort(BuildContext context, String title,
      {double? width}) {
    width ??= 150;
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
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context, TableState tableState,
      {bool? isShowSort = true}) {
    return [
      if (tableState.visibleColumns['Id']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['Id']!.showName,
          width: 60,
          columnKey: 'Id',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['Date Time']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['Date Time']!.showName,
          columnKey: 'Date Time',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['PLU']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['PLU']!.showName,
          columnKey: 'PLU',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['Product Code']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['Product Code']!.showName,
          columnKey: 'Product Code',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['Item Code']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['Item Code']!.showName,
          columnKey: 'Item Code',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['PLU Name']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['PLU Name']!.showName,
          columnKey: 'PLU Name',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['Price']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['Price']!.showName,
          columnKey: 'Price',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['GeneralUnit']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['GeneralUnit']!.showName,
          columnKey: 'GeneralUnit',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['TaxType']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['TaxType']!.showName,
          columnKey: 'TaxType',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['UnitWeight']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['UnitWeight']!.showName,
          columnKey: 'UnitWeight',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['LimitHigh']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['LimitHigh']!.showName,
          columnKey: 'LimitHigh',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['LimitLow']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['LimitLow']!.showName,
          columnKey: 'LimitLow',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['Weight']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['Weight']!.showName,
          columnKey: 'Weight',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['Weight Unit']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['Weight Unit']!.showName,
          columnKey: 'Weight Unit',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['Pretare']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['Pretare']!.showName,
          columnKey: 'Pretare',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['User Name']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['User Name']!.showName,
          columnKey: 'User Name',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      if (tableState.visibleColumns['Scale Name']!.isSelect)
        getDataColumn(
          context,
          tableState.visibleColumns['Scale Name']!.showName,
          columnKey: 'Scale Name',
          tableState: tableState,
          isShowSort: isShowSort,
        ),
      DataColumn(label: Container(width: 90)),
    ];
  }

  DataColumn getDataColumn(BuildContext context, String title,
      {double? width,
      String? columnKey,
      required TableState tableState,
      bool? isShowSort = true}) {
    width ??= 150;
    final isSorted = sortColumnName == columnKey;
    return DataColumn(
      headingRowAlignment: MainAxisAlignment.start,
      label: InkWell(
        onTap: () {
          if (sortColumnName == columnKey!) {
            if (sortDirectValue == DataGridSortDirection.ascending) {
              sortDirectValue = DataGridSortDirection.descending;
            } else {
              sortDirectValue = DataGridSortDirection.ascending;
            }
          } else {
            sortDirectValue = DataGridSortDirection.ascending;
          }
          sortColumnName = columnKey;

          tableState.loadPage(1);
        },
        child: SizedBox(
          width: width,
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .apply(color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSorted && isShowSort!)
                Icon(
                  sortDirectValue == DataGridSortDirection.ascending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            ],
          ),
        ),
      ),
    );
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
        convertDateTimeFormDb(
            item.scaleRec.header!.createdAt!.toIso8601String(),
            mySettingParam.dateSeparator,
            int.parse(mySettingParam.dateFormat == ""
                ? "1"
                : mySettingParam.dateFormat)),
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
      if (pluUnitSwitch
          .containsKey(item.scaleRec.header!.generalUnit.toString())) {
        cells.add(getDataCell(
          context,
          pluUnitSwitch[item.scaleRec.header!.generalUnit.toString()]
              .toString(),
        ));
      } else {
        cells.add(getDataCell(
          context,
          item.scaleRec.header!.generalUnit.toString(),
        ));
      }
    }

    if (tableState.visibleColumns['TaxType']!.isSelect) {
      if (pluTaxSwitch.containsKey(item.scaleRec.header!.taxType.toString())) {
        cells.add(getDataCell(
          context,
          pluTaxSwitch[item.scaleRec.header!.taxType.toString()].toString(),
        ));
      } else {
        cells.add(getDataCell(
          context,
          item.scaleRec.header!.taxType.toString(),
        ));
      }
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
    if (tableState.visibleColumns['User Name']!.isSelect) {
      cells.add(getDataCell(
        context,
        item.scaleRec.header!.userName.toString(),
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
    width ??= 150;
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

  DataCell getDataCellDetail(BuildContext context, String title,
      {double? width}) {
    width ??= 150;
    return DataCell(SizedBox(
      width: width,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .apply(color: Theme.of(context).colorScheme.onSurfaceVariant),
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }

  // 构建明细行数据单元格
  List<DataCell> _buildDetailDataCells(
    BuildContext context,
    TableState tableState,
    NewWgtDetail detail,
  ) {
    final cells = <DataCell>[];

    if (tableState.visibleColumns['Id']!.isSelect) {
      cells.add(getDataCellDetail(context, '', width: 60));
    }
    if (tableState.visibleColumns['Date Time']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['PLU']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['Product Code']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['Item Code']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['PLU Name']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['Price']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['GeneralUnit']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['TaxType']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['UnitWeight']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['LimitHigh']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['LimitLow']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['Weight']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        detail.weight.toString(),
      ));
    }
    if (tableState.visibleColumns['Weight Unit']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        detail.weightUnit.toString(),
      ));
    }
    if (tableState.visibleColumns['Pretare']!.isSelect) {
      cells.add(getDataCellDetail(
        context,
        '',
      ));
    }
    if (tableState.visibleColumns['User Name']!.isSelect) {
      cells.add(getDataCell(
        context,
        "",
      ));
    }

    if (tableState.visibleColumns['Scale Name']!.isSelect) {
      cells.add(getDataCellDetail(
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
    'Id': ReportShowName('NO.', true),
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
    'User Name': ReportShowName(localizedStrings.operator, true),
    'Scale Name': ReportShowName(localizedStrings.gScaleName, true),
  };
  Map<String, ReportShowName> get visibleColumns => _visibleColumns;

  // 分页状态
  int _currentPage = 1;
  int get currentPage => _currentPage;
  final int _itemsPerPage = 20;
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
      mySettingParam.scaleMode,
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

String convertDateTimeFormDb(
    String timestamp, String dateSeparator, int dateformat) {
  // 1 yymmdd   2 ddmmyy 3 mmddyy

  DateTime currTime = DateTime.parse(timestamp).toLocal();
  String format = '';
  if (dateformat == 1) {
    format =
        "${currTime.year}$dateSeparator${pad0(currTime.month)}$dateSeparator${pad0(currTime.day)} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
  } else if (dateformat == 2) {
    format =
        "${pad0(currTime.day)}$dateSeparator${pad0(currTime.month)}$dateSeparator${currTime.year} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
  } else if (dateformat == 3) {
    format =
        "${pad0(currTime.month)}$dateSeparator${pad0(currTime.day)}$dateSeparator${currTime.year} ${pad0(currTime.hour)}:${pad0(currTime.minute)}:${pad0(currTime.second)}";
  }
  return format;
}

String pad0(int num) {
  if (num < 10) {
    return '0${num.toString()}';
  }
  return num.toString();
}
