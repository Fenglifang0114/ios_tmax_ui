//配方，原料等导出操作

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';

// 辅助方法：生成 CSV
Future<void> _writeCsv(String filePath, List<List<dynamic>> rows) async {
  final file = File(filePath);
  String csvData = const ListToCsvConverter().convert(rows);
  // 确保字符串开头没有 BOM 字符，防止重复添加或误写
  if (csvData.startsWith('\uFEFF')) {
    csvData = csvData.replaceFirst('\uFEFF', '');
  }
  final bytes = utf8.encode(csvData);
  await file.writeAsBytes(bytes);
}

//原料导出
Future<ExportResult> exportRawListToCsv(
    List<RawDataInfo> rawList, String filePath) async {
  try {
    List<List<dynamic>> rows = [];

    // 写入表头
    rows.add([
      localizedStrings.fMaterialIdCol,
      localizedStrings.fMaterialNameCol,
      localizedStrings.fMaterialCodeCol,
      localizedStrings.gDeviceName,
      localizedStrings.fFmaCategoryCol,
      localizedStrings.fIngredientRemark,
      localizedStrings.fCreatedAtCol,
      localizedStrings.fUpdatedAtCol,
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
      String type = getRawTypeName(raw.categoryId ?? 0);

      rows.add([
        rawList[rowIndex].materialId ?? "",
        rawList[rowIndex].materialName ?? "",
        rawList[rowIndex].checkCode ?? "",
        scaleName,
        type == "-" ? "" : type,
        rawList[rowIndex].ingredient ?? "",
        rawList[rowIndex].createdAt != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(rawList[rowIndex].createdAt!)
            : "",
        rawList[rowIndex].updatedAt != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(rawList[rowIndex].updatedAt!)
            : "",
      ]);
    }

    await _writeCsv(filePath, rows);

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
    List<List<dynamic>> rows = [];
    rows.add([
      localizedStrings.fFmaIdLabel,
      localizedStrings.fFmaNameLabel,
      localizedStrings.fFmaBarcode,
      localizedStrings.fFmaModeCol,
      localizedStrings.gTipWeightUnit,
      localizedStrings.fFmaCategoryCol,
      localizedStrings.fConfidential, 
      localizedStrings.fFmaContainer,
      localizedStrings.fFmaRemark,
      localizedStrings.fIngredientOrder,
      localizedStrings.fMaterialIdCol,
      localizedStrings.fMaterialNameCol,
      localizedStrings.fMaterialSingleWeight,
      localizedStrings.fAllowableError,
    ]);

    await _writeCsv(filePath, rows);

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
    List<List<dynamic>> rows = [];
    rows.add([
      localizedStrings.fMaterialIdCol,
      localizedStrings.fMaterialNameCol,
      localizedStrings.fMaterialCodeCol,
      localizedStrings.gDeviceName,
      localizedStrings.fFmaCategoryCol,
      localizedStrings.fIngredientRemark,
    ]);

    await _writeCsv(filePath, rows);

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

RawDataInfo? getRawData(String rawId) {
  if (rawDataList.isEmpty) return null;
  for (var item in rawDataList) {
    if (item.materialId == rawId) {
      return item;
    }
  }
  return null;
}

//配方导出
Future<ExportResult> exportFormulaListToCsv(
    List<FormulaInfoDb> formulaList, String filePath) async {
  try {
    List<List<dynamic>> rows = [];

    // 写入表头
    rows.add([
      localizedStrings.fFmaIdLabel,
      localizedStrings.fFmaNameLabel,
      localizedStrings.fFmaBarcode,
      localizedStrings.fFmaModeCol,
      localizedStrings.gTipWeightUnit,
      localizedStrings.fFmaCategoryCol,
      localizedStrings.fConfidential,
      localizedStrings.fFmaContainer,
      localizedStrings.fFmaRemark,
      localizedStrings.fIngredientOrder,
      localizedStrings.fMaterialIdCol,
      localizedStrings.fMaterialNameCol,
      localizedStrings.fMaterialSingleWeight,
      localizedStrings.fAllowableError,
    ]);

    // 写入数据行
    for (var rowIndex = 0; rowIndex < formulaList.length; rowIndex++) {
      FormulaInfoDb fma = formulaList[rowIndex];
      if (fma.header == null) continue;
      
      List<Detail>? rawList = fma.details;
      if (rawList == null) continue;
      
      String fmaTypeName = getFmaTypeName(fma.header!.categoryId ?? 0);
      for (var i = 0; i < rawList.length; i++) {
        Detail raw = rawList[i];
        
        RawDataInfo? rawDataInfo = getRawData(raw.materialId ?? "");
        rows.add([
          fma.header!.formulaId ?? "",
          fma.header!.formulaName ?? "",
          fma.header!.formulaBarcode ?? "",
          fma.header!.formulaMode == "wgt" ? "weight" : "percent",
          fma.header!.formulaUnit ?? "",
          fmaTypeName == "-" ? "" : fmaTypeName,
          (fma.header!.isEncrypted ?? false) ? "yes" : "no",
          (fma.header!.needContainer ?? false) ? "yes" : "no",
          fma.header!.remark ?? "",
          (raw.sequence ?? 0).toString(),
          raw.materialId ?? "",
          rawDataInfo?.materialName ?? "",
          raw.materialWeight?.toString() ?? "0",
          raw.allowableError?.toString() ?? "0",
        ]);
      }
    }

    await _writeCsv(filePath, rows);

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
