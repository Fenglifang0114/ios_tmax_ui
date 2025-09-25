//配方，原料等导出操作

import 'dart:io';

import 'package:excel/excel.dart' as excel;
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
        if (scale.scaleId == raw.rawMaterial.scaleId) {
          scaleName = scale.scaleName;
          break;
        }
      }

      sheet.appendRow([
        excel.TextCellValue(rawList[rowIndex].rawMaterial.materialId),
        excel.TextCellValue(rawList[rowIndex].rawMaterial.materialName),
        excel.TextCellValue(scaleName),
        excel.TextCellValue(rawList[rowIndex].rawCategoryName == "-"
            ? ""
            : rawList[rowIndex].rawCategoryName),
        excel.TextCellValue(rawList[rowIndex].rawMaterial.ingredient),
        excel.TextCellValue(DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(rawList[rowIndex].rawMaterial.createdAt)),
        excel.TextCellValue(DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(rawList[rowIndex].rawMaterial.updatedAt)),
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
    final tempExcel = excel.Excel.createExcel();
    final sheet = tempExcel['Sheet1'];

    // 写入表头
    sheet.appendRow([
      excel.TextCellValue('Formula Id'),
      excel.TextCellValue('Formula Name'),
      excel.TextCellValue('Mode'),
      excel.TextCellValue('Weight Unit'),
      excel.TextCellValue('Category'),
      excel.TextCellValue('Confidential'),
      excel.TextCellValue('Need Container'),
      excel.TextCellValue('Ingredient No.'),
      excel.TextCellValue('Ingredient Id'),
      excel.TextCellValue('Ingredient Name'),
      excel.TextCellValue('Ingredient Weight/Percent'),
      excel.TextCellValue('Allow Error'),
    ]);

    // 写入数据行

    sheet.appendRow([
      excel.TextCellValue('1001'),
      excel.TextCellValue('F1001'),
      excel.TextCellValue('weight'),
      excel.TextCellValue('kg'),
      excel.TextCellValue('mixed'),
      excel.TextCellValue('yes'),
      excel.TextCellValue('yes'),
      excel.TextCellValue('1'),
      excel.TextCellValue('TS-1001'),
      excel.TextCellValue('Water'),
      excel.TextCellValue('8.88'),
      excel.TextCellValue('0.1'),
    ]);
    sheet.appendRow([
      excel.TextCellValue('1001'),
      excel.TextCellValue('F1001'),
      excel.TextCellValue('weight'),
      excel.TextCellValue('kg'),
      excel.TextCellValue('mixed'),
      excel.TextCellValue('yes'),
      excel.TextCellValue('yes'),
      excel.TextCellValue('2'),
      excel.TextCellValue('TS-1002'),
      excel.TextCellValue(''),
      excel.TextCellValue('1.88'),
      excel.TextCellValue('0.05'),
    ]);
    sheet.appendRow([
      excel.TextCellValue('1001'),
      excel.TextCellValue('F1001'),
      excel.TextCellValue('weight'),
      excel.TextCellValue('kg'),
      excel.TextCellValue('mixed'),
      excel.TextCellValue('yes'),
      excel.TextCellValue('yes'),
      excel.TextCellValue('3'),
      excel.TextCellValue('TS-1003'),
      excel.TextCellValue(''),
      excel.TextCellValue('2.88'),
      excel.TextCellValue('0.08'),
    ]);
    /////////////////
    sheet.appendRow([
      excel.TextCellValue('1002'),
      excel.TextCellValue('F1002'),
      excel.TextCellValue('percent'),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
      excel.TextCellValue('no'),
      excel.TextCellValue('no'),
      excel.TextCellValue('1'),
      excel.TextCellValue('TS-1001'),
      excel.TextCellValue('Water'),
      excel.TextCellValue('30'),
      excel.TextCellValue('2'),
    ]);
    sheet.appendRow([
      excel.TextCellValue('1002'),
      excel.TextCellValue('F1002'),
      excel.TextCellValue('percent'),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
      excel.TextCellValue('no'),
      excel.TextCellValue('no'),
      excel.TextCellValue('2'),
      excel.TextCellValue('TS-1002'),
      excel.TextCellValue(''),
      excel.TextCellValue('50'),
      excel.TextCellValue('1.5'),
    ]);
    sheet.appendRow([
      excel.TextCellValue('1002'),
      excel.TextCellValue('F1002'),
      excel.TextCellValue('percent'),
      excel.TextCellValue(''),
      excel.TextCellValue(''),
      excel.TextCellValue('no'),
      excel.TextCellValue('no'),
      excel.TextCellValue('3'),
      excel.TextCellValue('TS-1003'),
      excel.TextCellValue(''),
      excel.TextCellValue('20'),
      excel.TextCellValue('0.5'),
    ]);

    sheet.appendRow([
      excel.TextCellValue('This field is required and cannot be duplicated'),
      excel.TextCellValue('This field is required'),
      excel.TextCellValue('This field is required'),
      excel.TextCellValue('This field is required when mode is weight'),
      excel.TextCellValue('This field is not required'),
      excel.TextCellValue('This field is required'),
      excel.TextCellValue('This field is required  yes/no'),
      excel.TextCellValue('This field is required'),
      excel.TextCellValue('This field is required'),
      excel.TextCellValue('This field is not required'),
      excel.TextCellValue(
          'This field is required > 0 and decimal format less than 3'),
      excel.TextCellValue(
          'This field is required > 0 and decimal format less than 3'),
    ]);

    final file = File(filePath);

    // 将Excel数据保存到文件
    await file.writeAsBytes(tempExcel.save()!);

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
    final tempExcel = excel.Excel.createExcel();
    final sheet = tempExcel['Sheet1'];

    // 写入表头
    sheet.appendRow([
      excel.TextCellValue('Ingredient Id'),
      excel.TextCellValue('Ingredient Name'),
      excel.TextCellValue('Device Name'),
      excel.TextCellValue('Category'),
      excel.TextCellValue('Ingredient Notes'),
    ]);

    // 写入数据行

    sheet.appendRow([
      excel.TextCellValue('TS-1001'),
      excel.TextCellValue('Water'),
      excel.TextCellValue('XD-101'),
      excel.TextCellValue('Liquid'),
      excel.TextCellValue('Slowly pour in while stirring.'),
    ]);

    sheet.appendRow([
      excel.TextCellValue('This field is required and cannot be duplicated'),
      excel.TextCellValue('This field is required'),
      excel.TextCellValue('This field is not required'),
      excel.TextCellValue('This field is not required'),
      excel.TextCellValue('This field is not required'),
    ]);

    final file = File(filePath);

    // 将Excel数据保存到文件
    await file.writeAsBytes(tempExcel.save()!);

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
      for (var i = 0; i < rawList!.length; i++) {
        Detail? raw = rawList[i];
        sheet.appendRow([
          excel.TextCellValue(fma.header!.formulaHeader!.formulaId ?? ""),
          excel.TextCellValue(fma.header!.formulaHeader!.formulaName ?? ""),
          excel.TextCellValue(fma.header!.formulaHeader!.formulaMode == "wgt"
              ? "weight"
              : "percent"),
          excel.TextCellValue(fma.header!.formulaHeader!.formulaUnit ?? ""),
          excel.TextCellValue(fma.header!.formulaCategoryName == "-"
              ? ""
              : fma.header!.formulaCategoryName ?? ""),
          excel.TextCellValue(
              fma.header!.formulaHeader!.isEncrypted! ? "yes" : "no"),
          excel.TextCellValue(
              fma.header!.formulaHeader!.needContainer! ? "yes" : "no"),
          excel.TextCellValue(fma.header!.formulaHeader!.remark ?? ""),
          excel.TextCellValue((raw.formulaDetail!.sequence!).toString()),
          excel.TextCellValue(raw.formulaDetail!.materialId ?? ""),
          excel.TextCellValue(raw.rawMaterialTypeName!.rawCategoryName ?? ""),
          excel.TextCellValue(raw.formulaDetail!.materialWeight.toString()),
          excel.TextCellValue(raw.formulaDetail!.allowableError.toString()),
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
