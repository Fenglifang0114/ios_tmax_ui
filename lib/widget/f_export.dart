//配方，原料等导出操作

import 'dart:io';

import 'package:excel/excel.dart' as excel;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';

//原料导出

Future<ExportResult> exportRawListToExcel(
    List<RawDataInfo> rawList, String filePath) async {
  try {
    final exportExcel = excel.Excel.createExcel();
    final sheet = exportExcel['Sheet1'];

    // 写入表头
    sheet.appendRow([
      excel.TextCellValue('Ingredient Id'),
      excel.TextCellValue('Ingredient Name'),
      excel.TextCellValue('Device Name'),
      excel.TextCellValue('Category'),
      excel.TextCellValue('Ingredient Notes'),
      excel.TextCellValue('Create Time'),
      excel.TextCellValue('Update Time'),
    ]);

    // 写入数据行

    for (var rowIndex = 0; rowIndex < rawList.length; rowIndex++) {
      final raw = rawList[rowIndex];
      String scaleName = '';

      // 查找秤的名称
      for (var scale in myAllScalesList) {
        if (scale.scaleId == raw.scaleId) {
          scaleName = scale.scaleName;
          break;
        }
      }
      String type = getRawTypeName(raw.categoryId!);

      sheet.appendRow([
        excel.TextCellValue(rawList[rowIndex].materialId!),
        excel.TextCellValue(rawList[rowIndex].materialName!),
        excel.TextCellValue(scaleName),
        excel.TextCellValue(type == "-" ? "" : type),
        excel.TextCellValue(rawList[rowIndex].ingredient!),
        excel.TextCellValue(DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(rawList[rowIndex].createdAt!)),
        excel.TextCellValue(DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(rawList[rowIndex].updatedAt!)),
      ]);
    }
    final file = File(filePath);
    await file.writeAsBytes(exportExcel.save()!);

    return ExportResult(isSuccess: true);
  } catch (e) {
    String errorMessage = localizedStrings.gTipExportError;
    if (e is FileSystemException) {
      errorMessage = localizedStrings.gTipExportFileError;
    } else if (e is IOException) {
      errorMessage = localizedStrings.gTipExportIOError;
    }

    return ExportResult(isSuccess: false, errorMessage: errorMessage);
  }
}

//配方模版导出
Future<ExportResult> exportFmaTemplate(String filePath) async {
  try {
    File output = File(filePath); // 将文件路径转换为File对象

    // 读取预置的模板文件
    final ByteData bytes =
        await rootBundle.load('assets/template/formula_template.xlsx');
    final buffer = bytes.buffer;
    // 将模板文件保存到指定路径
    await output.writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return ExportResult(isSuccess: true);
  } catch (e) {
    String errorMessage = localizedStrings.gTipExportError;
    if (e is FileSystemException) {
      errorMessage = localizedStrings.gTipExportFileError;
    } else if (e is IOException) {
      errorMessage = localizedStrings.gTipExportIOError;
    }
    return ExportResult(isSuccess: false, errorMessage: errorMessage);
  }
}

//原料模版导出

Future<ExportResult> exportRawTemplate(String filePath) async {
  try {
    File output = File(filePath); // 将文件路径转换为File对象

    // 读取预置的模板文件
    final ByteData bytes =
        await rootBundle.load('assets/template/ingredient_template.xlsx');
    final buffer = bytes.buffer;

    // 将模板文件保存到指定路径

    await output.writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

    return ExportResult(isSuccess: true);
  } catch (e) {
    String errorMessage = localizedStrings.gTipExportError;
    if (e is FileSystemException) {
      errorMessage = localizedStrings.gTipExportFileError;
    } else if (e is IOException) {
      errorMessage = localizedStrings.gTipExportIOError;
    }
    return ExportResult(isSuccess: false, errorMessage: errorMessage);
  }
}

RawDataInfo getRawData(String rawId) {
  for (var item in rawDataList) {
    if (item.materialId == rawId) {
      return item;
    }
  }
  return rawDataList.first;
}

//配方导出

Future<ExportResult> exportFormulaListToExcel(
    List<FormulaInfoDb> formulaList, String filePath) async {
  try {
    final exportExcel = excel.Excel.createExcel();
    final sheet = exportExcel['Sheet1'];

    // 写入表头
    sheet.appendRow([
      excel.TextCellValue('Formula Id'),
      excel.TextCellValue('Formula Name'),
      excel.TextCellValue('Mode'),
      excel.TextCellValue('Weight Unit'),
      excel.TextCellValue('Category'),
      excel.TextCellValue('Confidential'),
      excel.TextCellValue('Need Container'),
      excel.TextCellValue('Notes'),
      excel.TextCellValue('Ingredient No.'),
      excel.TextCellValue('Ingredient Id'),
      excel.TextCellValue('Ingredient Name'),
      excel.TextCellValue('Ingredient Weight/Percent'),
      excel.TextCellValue('Allow Error'),
    ]);

    // 写入数据行

    for (var rowIndex = 0; rowIndex < formulaList.length; rowIndex++) {
      FormulaInfoDb? fma = formulaList[rowIndex];
      List<Detail>? rawList = fma.details;
      String fmaTypeName = getFmaTypeName(fma.header!.categoryId!);
      for (var i = 0; i < rawList!.length; i++) {
        Detail? raw = rawList[i];
        RawDataInfo rawDataInfo = getRawData(raw.materialId!);
        String rawTypeName = getRawTypeName(rawDataInfo.categoryId!);
        sheet.appendRow([
          excel.TextCellValue(fma.header!.formulaId ?? ""),
          excel.TextCellValue(fma.header!.formulaName ?? ""),
          excel.TextCellValue(
              fma.header!.formulaMode == "wgt" ? "weight" : "percent"),
          excel.TextCellValue(fma.header!.formulaUnit ?? ""),
          excel.TextCellValue(fmaTypeName == "-" ? "" : fmaTypeName),
          excel.TextCellValue(fma.header!.isEncrypted! ? "yes" : "no"),
          excel.TextCellValue(fma.header!.needContainer! ? "yes" : "no"),
          excel.TextCellValue(fma.header!.remark ?? ""),
          excel.TextCellValue((raw.sequence!).toString()),
          excel.TextCellValue(raw.materialId ?? ""),
          excel.TextCellValue(rawTypeName),
          excel.TextCellValue(raw.materialWeight.toString()),
          excel.TextCellValue(raw.allowableError.toString()),
        ]);
      }
    }
    final file = File(filePath);
    await file.writeAsBytes(exportExcel.save()!);

    return ExportResult(isSuccess: true);
  } catch (e) {
    String errorMessage = localizedStrings.gTipExportError;
    if (e is FileSystemException) {
      errorMessage = localizedStrings.gTipExportFileError;
    } else if (e is IOException) {
      errorMessage = localizedStrings.gTipExportIOError;
    }

    return ExportResult(isSuccess: false, errorMessage: errorMessage);
  }
}
