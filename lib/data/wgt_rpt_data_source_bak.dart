// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'weight_report_data.dart';
// import 'weight_rpt.dart';

// // 工业中报表的源  共用
// class WeightReportDataSource extends DataGridSource {
//   List<WeightReportData> weightReportData;
//   WeightReportDataSource(this.weightReportData) {
//     buildDataGridRow();
//   }
//   void updateData(List<WeightReportData> newReportData) {
//     weightReportData = newReportData;
//     buildDataGridRow();
//     notifyListeners();
//   }

//   void sortData(String columnName) {
//     weightReportData.sort((WeightReportData a, WeightReportData b) {
//       if (columnName == 'Date Time') {
//         return a.createdAt.compareTo(b.createdAt);
//       }
//       // 如果有其他需要比较的字段，请在这里添加适当的逻辑
//       return 0;
//     });
//   }

//   void sortDataGrid(String columnName, DataGridSortDirection sortDirection) {
//     sortData(columnName);
//     if (sortDirection == DataGridSortDirection.descending) {
//       reverseData();
//     }
//   }

//   void reverseData() {
//     weightReportData = weightReportData.reversed.toList();
//   }

//   List<DataGridRow> dataGridRow = <DataGridRow>[];
//   void buildDataGridRow() {
//     List<GridColumn> columns = getColumns();
//     dataGridRow = weightReportData.map<DataGridRow>((reportData) {
//       List<DataGridCell<dynamic>> cells = [];
//       for (GridColumn column in columns) {
//         String columnName = column.columnName;
//         cells.add(DataGridCell<String>(
//           columnName: myReportFeildsMap[columnName]!.showName,
//           value: getValueForColumn(reportData, columnName),
//         ));
//       }
//       return DataGridRow(cells: cells);
//     }).toList();
//   }

//   @override
//   List<DataGridRow> get rows => dataGridRow.isEmpty ? [] : dataGridRow;

//   @override
//   DataGridRowAdapter? buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((dataGridCell) {
//       return Container(
//         alignment: Alignment.center,
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: Text(dataGridCell.value.toString()),
//       );
//     }).toList());
//   }
// }
