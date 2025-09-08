import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/g_data.dart';
import '../functions/methods.dart';
import 'record_data.dart';
import 'scalecmd_data.dart';
import 'settingparam_data.dart';
import 'weight_report_data.dart';

void addDBdataToReport(List<WeightReportData> myWeightReportData,
    SettingParam myModeSetting, int dateformat) {
  List<WeightRecords>? dbRecs = myGetScaleRecords.weightRecords;
  for (var i = 0; i < dbRecs!.length; i++) {
    myWeightReportData.add(WeightReportData(
        (dbRecs[i].id == null) ? "" : dbRecs[i].id!,
        (dbRecs[i].scaleModel == null) ? '' : dbRecs[i].scaleModel!,
        (dbRecs[i].scaleSn == null) ? '' : dbRecs[i].scaleSn!,
        (dbRecs[i].plu == null) ? '' : dbRecs[i].plu!,
        (dbRecs[i].productCode == null) ? '' : dbRecs[i].productCode!,
        (dbRecs[i].itemCode == null) ? '' : dbRecs[i].itemCode!,
        (dbRecs[i].category == null) ? '' : dbRecs[i].category!,
        (dbRecs[i].productName == null) ? '' : dbRecs[i].productName!,
        (dbRecs[i].generalUnit == null) ? '' : dbRecs[i].generalUnit!,
        (dbRecs[i].taxType == null) ? '' : dbRecs[i].taxType!,
        (dbRecs[i].price == null) ? '' : dbRecs[i].price!,
        (dbRecs[i].unitWeight == null) ? '' : dbRecs[i].unitWeight!,
        (dbRecs[i].pretare == null) ? '' : dbRecs[i].pretare!,
        (dbRecs[i].limitHigh == null) ? '' : dbRecs[i].limitHigh!,
        (dbRecs[i].limitLow == null) ? '' : dbRecs[i].limitLow!,
        (dbRecs[i].weight == null) ? '' : dbRecs[i].weight!,
        (dbRecs[i].weightUnit == null) ? '' : dbRecs[i].weightUnit!,
        (dbRecs[i].userNo == null) ? '' : dbRecs[i].userNo!,
        (dbRecs[i].userName == null) ? '' : dbRecs[i].userName!,
        (dbRecs[i].scaleName == null) ? '' : dbRecs[i].scaleName!,
        convertDateTime(
            dbRecs[i].createdAt!, myModeSetting.dateSeparator, dateformat)));
  }
}

String removeFractionalSeconds(String timestamp) {
  int dotIndex = timestamp.indexOf('.');
  int plusIndex = timestamp.indexOf('+');
  String prefix = timestamp.substring(0, dotIndex);
  String suffix = timestamp.substring(plusIndex);
  String newTimestamp = prefix + suffix;
  return newTimestamp;
}

String convertDateTime(String timestamp, String dateSeparator, int dateformat) {
  // 1 yymmdd   2 ddmmyy 3 mmddyy
  if (timestamp.length < 30) {
    return '';
  }
  timestamp = removeFractionalSeconds(timestamp);
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

String getDateTime(String dateSeparator, int dateformat) {
  // 1 yymmdd   2 ddmmyy 3 mmddyy
  var currTime = DateTime.now();
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

// 根据列名获取对应的数据
dynamic getValueForColumn(WeightReportData reportData, String columnName) {
  switch (columnName) {
    case 'Id':
      return reportData.id;
    case 'Date Time':
      return reportData.createdAt;
    case 'PLU':
      return reportData.plu;
    case 'Product Code':
      return reportData.productCode;
    case 'Item Code':
      return reportData.itemCode;
    case 'PLU Name':
      return reportData.productName;
    case 'Price':
      return reportData.price;
    case 'GeneralUnit':
      return reportData.generalUnit;
    case 'TaxType':
      return reportData.taxType;
    case 'UnitWeight':
      return reportData.unitWeight;
    case 'LimitHigh':
      return reportData.limitHigh;
    case 'LimitLow':
      return reportData.limitLow;
    case 'Weight':
      return reportData.weight;
    case 'Weight Unit':
      return reportData.weightUnit;
    case 'Pretare':
      return reportData.pretare;
    case 'User NO.':
      return reportData.userNo;
    case 'User Name':
      return reportData.userName;
    case 'Scale Name':
      return reportData.scaleName;
    // 其他属性的处理类似
    default:
      return '';
  }
}

Future<void> creatCsvFile(
    String path, List<WeightReportData> myWeightReportData) async {
  // 获取选中的字段名称列表
  List<String> selectedShowNameList = myReportFeildsMap.entries
      .where((entry) => entry.value.isSelect)
      .map((entry) => entry.key)
      .toList();

  // 创建CSV文件
  var file = File(path);
  var sink = file.openWrite();

  // 写入标题行
  sink.write(selectedShowNameList
      .map((key) => myReportFeildsMap[key]!.showName)
      .join(','));
  sink.writeln();

  // 写入数据行
  for (var data in myWeightReportData) {
    var row = selectedShowNameList.map((key) {
      switch (key) {
        case 'Id':
          return data.id;
        case 'Date Time':
          return data.createdAt;
        case 'PLU':
          return data.plu;
        case 'Product Code':
          return data.productCode;
        case 'Item Code':
          return data.itemCode;
        case 'PLU Name':
          return data.productName;
        case 'Price':
          return data.price;
        case 'GeneralUnit':
          return data.generalUnit;
        case 'TaxType':
          return data.taxType;
        case 'UnitWeight':
          return data.unitWeight;
        case 'LimitHigh':
          return data.limitHigh;
        case 'LimitLow':
          return data.limitLow;
        case 'Weight':
          return data.weight;
        case 'Weight Unit':
          return data.weightUnit;
        case 'Pretare':
          return data.pretare;
        case 'User NO.':
          return data.userNo;
        case 'User Name':
          return data.userName;
        case 'Scale Name':
          return data.scaleName;
        default:
          return '';
      }
    }).join(',');

    sink.writeln(row);
  }

  // 关闭文件
  await sink.close();
  if (kDebugMode) {
    print('CSV文件已保存到: $path');
  }
}

// /////////////////
// creatExcelFile(
//     String path, List<WeightReportData> myWeightReportData, Excel excel) {
//   // 获取选中的字段名称列表
//   List<String> selectedShowNameList = myReportFeildsMap.entries
//       .where((entry) => entry.value.isSelect)
//       .map((entry) => entry.key)
//       .toList();

//   // 创建标题行
//   Sheet sh = excel['Sheet1'];
//   for (int i = 0; i < selectedShowNameList.length; i++) {
//     sh.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i)).value =
//         TextCellValue(myReportFeildsMap[selectedShowNameList[i]]!.showName);
//   }

//   // 填充数据行
//   for (int row = 1; row <= myWeightReportData.length; row++) {
//     WeightReportData data = myWeightReportData[row - 1];
//     for (int col = 0; col < selectedShowNameList.length; col++) {
//       String key = selectedShowNameList[col];
//       switch (key) {
//         case 'Id':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.id);
//           break;
//         case 'Date Time':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.createdAt);
//           break;
//         case 'PLU':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.plu);
//           break;
//         case 'Product Code':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.productCode);
//           break;
//         case 'Item Code':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.itemCode);
//           break;
//         case 'PLU Name':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.productName);
//           break;
//         case 'Price':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.price);
//           break;
//         case 'GeneralUnit':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.generalUnit);
//           break;
//         case 'TaxType':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.taxType);
//           break;
//         case 'UnitWeight':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.unitWeight);
//           break;
//         case 'LimitHigh':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.limitHigh);
//           break;
//         case 'LimitLow':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.limitLow);
//           break;
//         case 'Weight':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.weight);
//           break;
//         case 'Weight Unit':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.weightUnit);
//           break;
//         case 'Pretare':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.pretare);
//           break;
//         case 'User NO.':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.userNo);
//           break;
//         case 'User Name':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.userName);
//           break;
//         case 'Scale Name':
//           sh
//               .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
//               .value = TextCellValue(data.scaleName);
//           break;
//         default:
//       }
//     }
//   }
// }
/////////////////////

List<GridColumn> getColumns() {
  List<GridColumn> columns = [];
  // List<String> columnNames = myReportFeildsMap.values
  //     .where((ReportShowName reportShowName) => reportShowName.isSelect)
  //     .map((ReportShowName reportShowName) => reportShowName.showName)
  //     .toList();
  List<String> columnNames = myReportFeildsMap.entries
      .where((entry) => entry.value.isSelect)
      .map((entry) => entry.key)
      .toList();

  // columns.add(GridColumn(
  //     columnName: 'NO',
  //     label: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //         alignment: Alignment.center,
  //         child: const Text(
  //           'NO',
  //           overflow: TextOverflow.ellipsis,
  //         ))));

  for (String columnName in columnNames) {
    columns.add(
      GridColumn(
        columnName: columnName,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.center,
          child: Text(
            myReportFeildsMap[columnName]!.showName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
  return columns;
}

void sendRptDataToDB(
    List<WeightReportData> myWeightReportData, String wgtMode, int scaleId) {
  if (myWeightReportData.isEmpty) {
    return;
  }

  var currentData = myWeightReportData[myWeightReportData.length - 1];
  myScaleCmd.cmdMode = "add_rec";
  myAddScaleRecord.scaleId = scaleId;
  myAddScaleRecord.id = currentData.id;
  myAddScaleRecord.scaleModel = currentData.scaleModel;
  myAddScaleRecord.scaleSn = currentData.scaleSn;
  myAddScaleRecord.plu = currentData.plu;
  myAddScaleRecord.productCode = currentData.productCode;
  myAddScaleRecord.itemCode = currentData.itemCode;
  myAddScaleRecord.category = currentData.category;
  myAddScaleRecord.productName = currentData.productName;
  myAddScaleRecord.generalUnit = currentData.generalUnit;
  myAddScaleRecord.taxType = currentData.taxType;
  myAddScaleRecord.price = currentData.price;
  myAddScaleRecord.unitWeight = currentData.unitWeight;
  myAddScaleRecord.pretare = currentData.pretare;
  myAddScaleRecord.limitHigh = currentData.limitHigh;
  myAddScaleRecord.limitLow = currentData.limitLow;
  myAddScaleRecord.weight = currentData.weight;
  myAddScaleRecord.weightUnit = currentData.weightUnit;
  myAddScaleRecord.userNo = mySysUser.userId.toString();
  myAddScaleRecord.userName = mySysUser.nickName;
  myAddScaleRecord.scaleName = currentData.scaleName;
  myAddScaleRecord.scaleMode = wgtMode;

  myScaleCmd.cmdData = jsonEncode(myAddScaleRecord);
  PublicFunctions.sendMsg(scaleId, jsonEncode(myScaleCmd));
}
