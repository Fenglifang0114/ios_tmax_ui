import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/weight_report_data.dart';
import 'package:t_max/data/weight_rpt.dart';
import 'package:t_max/functions/methods.dart';

String sortColumnName = 'Id';
DataGridSortDirection sortDirectValue = DataGridSortDirection.descending;

class WeightReportDataSource extends DataGridSource {
  List<WeightReportData> weightReportData = [];
  final String wgtMode;
  WeightReportDataSource(this.weightReportData, this.wgtMode) {
    buildDataGridRow();
  }

  int pageIndex = 1;
  final int _pageSize = 20; // 每页 100 条数据
  bool _isLoading = false;

  void loadPage(int page) {
    if (_isLoading) return;
    _isLoading = true;

    // 清空当前数据
    weightReportData.clear();
    notifyListeners();

    // 通过接口获取新一页数据，同时传递排序信息
    PublicFunctions.newGetRecords(
      int.parse(wgtMode),
      page,
      _pageSize,
      sortColumnName.toString(),
      sortDirectValue.name,
    );

    // 更新页码
    pageIndex = page;
  }

  void updateData(List<WeightReportData> newReportData) {
    weightReportData = newReportData; // 更新数据
    buildDataGridRow(); // 重新构建 DataGridRow
    notifyListeners(); // 通知表格更新
    _isLoading = false;
  }

  void sortDataGrid(String columnName, DataGridSortDirection sortDirection,
      {int scaleId = 1}) {
    sortColumnName = columnName;
    sortDirectValue = sortDirection;
    loadPage(1); // 排序后重新加载第一页数据
    notifyListeners(); // 通知表格更新
  }

  bool isColumnSorted(String columnName) {
    return sortColumnName == columnName;
  }

  DataGridSortDirection sortDirectionForColumn(String columnName) {
    if (sortColumnName == columnName) {
      return sortDirectValue;
    }
    // 这里可以根据具体情况返回一个默认值，比如 ascending
    return DataGridSortDirection.ascending;
  }

  List<DataGridRow> dataGridRow = <DataGridRow>[];
  void buildDataGridRow() {
    List<GridColumn> columns = getColumns();
    dataGridRow = weightReportData.map<DataGridRow>((reportData) {
      List<DataGridCell<dynamic>> cells = [];
      for (GridColumn column in columns) {
        String columnName = column.columnName;
        cells.add(DataGridCell<String>(
          columnName: getRptTitleName(columnName),
          value: getValueForColumn(reportData, columnName),
        ));
      }
      return DataGridRow(cells: cells);
    }).toList();
  }

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
