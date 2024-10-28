import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../functions/methods.dart';
import 'manager_scale_channel.dart';
import 'productlist_data.dart';
import 'record_data.dart';
import 'scalecmd_data.dart';
import 'settingparam_data.dart';
import 'weight_report_data.dart';

void addDBdataToReport(List<WeightReportData> myWeightReportData,
    SettingParam myModeSetting, int dateformat) {
  List<WeightRecords>? dbRecs = myGetScaleRecords.weightRecords;
  for (var i = 0; i < dbRecs!.length; i++) {
    myWeightReportData.add(WeightReportData(
      (dbRecs[i].recId).toString(),
      convertDateTime(
          dbRecs[i].createdAt!, myModeSetting.dateSeparator, dateformat),
      (dbRecs[i].weight == null) ? '' : dbRecs[i].weight!,
      (dbRecs[i].weightUnit == null) ? '' : dbRecs[i].weightUnit!, //重量单位
      (myProductRecInfo.id == null) ? "" : myProductRecInfo.id.toString(),
      (dbRecs[i].product == null) ? '' : dbRecs[i].product!,
      (dbRecs[i].pluRemarks == null) ? '' : dbRecs[i].pluRemarks!,
      (dbRecs[i].pretare == null) ? '' : dbRecs[i].pretare!,
      (dbRecs[i].userName == null) ? '' : dbRecs[i].userName!,
      (dbRecs[i].userNo == null) ? '' : dbRecs[i].userNo!,
      (dbRecs[i].userRemarks == null)
          ? ''
          : dbRecs[i].userRemarks!, //userremarks
      (dbRecs[i].scaleName == null) ? '' : dbRecs[i].scaleName!,
    ));
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
    case 'NO':
      return reportData.id;
    case 'Date Time':
      return reportData.dateTime;
    case 'Weight':
      return reportData.weight;
    case 'Weight Unit':
      return reportData.weightUnit;
    case 'PLU NO.':
      return reportData.plu;
    case 'PLU Name':
      return reportData.pluName;
    case 'PLU Remarks':
      return reportData.pluRemarks;
    case 'Pretare':
      return reportData.pretare;
    case 'User NO.':
      return reportData.userNo;
    case 'User Name':
      return reportData.userName;
    case 'User Remarks':
      return reportData.userRemarks;
    case 'Scale Name':
      return reportData.scaleName;
    // 其他属性的处理类似
    default:
      return '';
  }
}

creatExcelFile(
    String path, List<WeightReportData> myWeightReportData, Excel excel) {
  List<String> title = [];
  title.add('RecId');
  title.addAll(myReportFields.filedsList);
  Sheet sh = excel['Sheet1'];
  for (var i = 0; i < title.length; i++) {
    sh.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i)).value =
        TextCellValue(title[i]);
  }

  for (int row = 1; row <= myWeightReportData.length; row++) {
    for (int col = 0; col < title.length; col++) {
      switch (title[col]) {
        case 'RecId':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].id);
          break;
        case 'Date Time':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].dateTime);
          break;
        case 'Weight':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].weight);
          break;
        case 'Weight Unit':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].weightUnit);
          break;
        case 'PLU NO.':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].plu);
          break;
        case 'PLU Name':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].pluName);
          break;
        case 'PLU Remarks':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].pluRemarks);
          break;
        case 'Pretare':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].pretare);
          break;
        case 'User Name':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].userName);
          break;
        case 'User Remarks':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].userRemarks);
          break;
        case 'User NO.':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].userNo);
          break;
        case 'Scale Name':
          sh
              .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
              .value = TextCellValue(myWeightReportData[row - 1].scaleName);
          break;

        default:
      }

      //'value ${row}_$col';
    }
  }
}

List<GridColumn> getColumns() {
  List<GridColumn> columns = [];
  List<String> columnNames = myReportFields.filedsList;
  columns.add(GridColumn(
      columnName: 'NO',
      label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.center,
          child: const Text(
            'NO',
            overflow: TextOverflow.ellipsis,
          ))));

  for (String columnName in columnNames) {
    columns.add(
      GridColumn(
        columnName: columnName,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.center,
          child: Text(
            columnName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
  return columns;
}

void sendRptDataToDB(
    List<WeightReportData> myWeightReportData, String wgtMode) {
  var currentData = myWeightReportData[myWeightReportData.length - 1];
  myScaleCmd.cmdMode = "add_rec";
  myAddScaleRecord.scaleId = myDefScaleInfo.defScaleId!;
  myAddScaleRecord.price = '0.0';
  myAddScaleRecord.scaleMode = weighingTakeInMode;
  myAddScaleRecord.scaleModel = myDefScaleInfo.defScaleModel;
  myAddScaleRecord.scaleSn = myDefScaleInfo.defScaleSn;
  myAddScaleRecord.scaleName = myDefScaleInfo.defScaleName;
  myAddScaleRecord.product = currentData.pluName;
  myAddScaleRecord.weight = currentData.weight.toString();
  myAddScaleRecord.pluNo = currentData.plu;
  myAddScaleRecord.pluRemarks = currentData.pluRemarks;
  myAddScaleRecord.weightUnit = currentData.weightUnit;
  myAddScaleRecord.pretare = currentData.pretare;
  myAddScaleRecord.userNo = currentData.userNo;
  myAddScaleRecord.userName = currentData.userName;
  myAddScaleRecord.userRemarks = currentData.userRemarks;
  myScaleCmd.cmdData = jsonEncode(myAddScaleRecord);
  PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
}
