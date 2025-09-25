//配方导入方法

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/import_fma_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';

//找出配方列表中是否已经存在了此配方
bool isFormulaExist(String formulaId) {
  if (formulaDataList.isEmpty) {
    return false;
  }
  return formulaDataList
      .any((formula) => formula.header!.formulaHeader!.formulaId == formulaId);
}

bool isRawExist(String rawId) {
  if (rawDataList.isEmpty) {
    return false;
  }
  return rawDataList.any((raw) => raw.rawMaterial.materialId == rawId);
}

// 优化后的导入函数：提前校验字段，过滤无效行
Future<ImportFmaResult> importFormulasFromExcel(File file) async {
  ImportFmaResult result = ImportFmaResult(
    isSuccess: false,
    errorMessage: '',
    importFmaInfoList: [],
  );

  final stopwatch = Stopwatch()..start(); // 用于监控导入性能
  try {
    // 1. 读取Excel并解析
    final bytes = await file.readAsBytes();
    final excelData = Excel.decodeBytes(bytes);

    if (excelData.tables.isEmpty) {
      result.errorMessage = localizedStrings.noDataImport;
      return result;
    }

    final sheet = excelData.tables.values.first;
    if (sheet.rows.isEmpty) {
      result.errorMessage = localizedStrings.noDataImport;
      return result;
    }

    //大于1000行 提示用户一次读取1000行
    if (sheet.rows.length > 1001) {
      result.errorMessage = localizedStrings.max1000Rows;
      return result;
    }

    // 2. 解析表头并映射列索引（关键优化：用索引定位列，避免多次查找）
    final Map<String, int> columnIndexMap = {};

    for (var i = 0; i < sheet.rows.first.length; i++) {
      final cell = sheet.rows.first[i];
      if (cell != null && cell.value != null) {
        final header = cell.value.toString().trim();
        columnIndexMap[header] = i;
      }
    }
    //验证表头是否完整
    final missingHeader = _validateHeaders(columnIndexMap.keys.toList());
    if (missingHeader.isNotEmpty) {
      result.errorMessage = localizedStrings.missingHeaders + '：$missingHeader';
      return result;
    }

    final List<Map<String, dynamic>> validRows = [];
    for (int rowIdx = 1; rowIdx < sheet.maxRows; rowIdx++) {
      final row = sheet.rows[rowIdx];
      if (_isRowEmpty(row)) {
        debugPrint('跳过空行: $rowIdx');
        continue;
      }

      final rowData = <String, dynamic>{};

      // 4.1 校验Formula Id（非空+整数）
      final formulaIdCol = columnIndexMap['Formula Id']!;
      final formulaIdValue = _getCellValue(row, formulaIdCol);
      if (formulaIdValue.isEmpty) {
        result.errorMessage = localizedStrings.formulaIdEmpty +
            ',${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (isFormulaExist(formulaIdValue)) {
        result.errorMessage =
            '$formulaIdValue ${localizedStrings.formulaIdExists}, ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['formulaId'] = formulaIdValue;
      }

      // 4.2 校验Formula Name（非空）
      final formulaNameCol = columnIndexMap['Formula Name']!;
      final formulaName = _getCellValue(row, formulaNameCol).trim();
      if (formulaName.isEmpty) {
        result.errorMessage = localizedStrings.formulaNameEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['formulaName'] = formulaName;
      }

      // 4.3 校验Mode（非空+合法值）
      final modeCol = columnIndexMap['Mode']!;
      final mode = _getCellValue(row, modeCol).trim().toLowerCase();
      if (mode.isEmpty) {
        result.errorMessage = localizedStrings.modeEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (!['weight', 'percent'].contains(mode)) {
        result.errorMessage = localizedStrings.modeInvalid +
            '：$mode , ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['mode'] = mode;
        // 当Mode为weight时，校验Weight Unit
        if (mode == 'weight') {
          final weightUnitCol = columnIndexMap['Weight Unit'];
          final weightUnit = weightUnitCol != null
              ? _getCellValue(row, weightUnitCol).trim()
              : '';
          if (weightUnit.isEmpty) {
            result.errorMessage = localizedStrings.weightUnitEmpty +
                ', ${localizedStrings.tipRow}:${rowIdx + 1}';
            return result;
          } else {
            rowData['weightUnit'] = weightUnit;
          }
        }
      }

      // 4.4 校验Ingredient No.（非空+正整数）
      final ingredientNoCol = columnIndexMap['Ingredient No.']!;
      final ingredientNoValue = _getCellValue(row, ingredientNoCol);
      if (ingredientNoValue.isEmpty) {
        result.errorMessage = localizedStrings.ingredientNoEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        final ingredientNo = int.tryParse(ingredientNoValue);
        if (ingredientNo == null || ingredientNo <= 0) {
          result.errorMessage = localizedStrings.ingredientNoInvalid +
              '：$ingredientNoValue , ${localizedStrings.tipRow}:${rowIdx + 1}';
          return result;
        } else {
          rowData['ingredientNo'] = ingredientNo;
        }
      }

      // 4.5 校验Ingredient Id（非空）
      final ingredientIdCol = columnIndexMap['Ingredient Id']!;
      final ingredientId = _getCellValue(row, ingredientIdCol).trim();
      if (ingredientId.isEmpty) {
        result.errorMessage = localizedStrings.ingredientIdEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (!isRawExist(ingredientId)) {
        result.errorMessage = localizedStrings.ingredientIdNotExist +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['ingredientId'] = ingredientId;
      }

      // 4.6 校验Weight/Percent（非空+正数+最多3位小数）
      final weightCol = columnIndexMap['Ingredient Weight/Percent']!;
      final weightValue = _getCellValue(row, weightCol);
      if (weightValue.isEmpty) {
        result.errorMessage = localizedStrings.weightPercentEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (!_isValidDecimal(weightValue,
          maxDecimals: 3, minValue: 0.001)) {
        result.errorMessage = localizedStrings.weightPercentInvalid +
            '：$weightValue , ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['weightOrPercent'] = double.parse(weightValue);
      }

      // 4.7 校验Allow Error（非空+正数+最多3位小数）
      final errorCol = columnIndexMap['Allow Error']!;
      final errorValue = _getCellValue(row, errorCol);
      if (errorValue.isEmpty) {
        result.errorMessage = localizedStrings.allowErrorEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (!_isValidDecimal(errorValue,
          maxDecimals: 3, minValue: 0.001)) {
        result.errorMessage = localizedStrings.allowErrorInvalid +
            '：$errorValue , ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['allowError'] = double.parse(errorValue);
      }

      // 4.8 处理可选字段（无需校验，为空则存null）
      rowData['category'] = columnIndexMap.containsKey('Category')
          ? _getCellValue(row, columnIndexMap['Category']!).trim()
          : "";
      rowData['isConfidential'] = columnIndexMap.containsKey('Confidential')
          ? _getCellValue(row, columnIndexMap['Confidential']!)
                  .trim()
                  .toLowerCase() ==
              'yes'
          : false;
      rowData['needContainer'] = columnIndexMap.containsKey('Need Container')
          ? _getCellValue(row, columnIndexMap['Need Container']!)
                  .trim()
                  .toLowerCase() ==
              'yes'
          : false;
      rowData['ingredientName'] = columnIndexMap.containsKey('Ingredient Name')
          ? _getCellValue(row, columnIndexMap['Ingredient Name']!).trim()
          : '';

      // 4.9 收集行错误或保留有效行

      validRows.add(rowData);
    }

    // 5. 对有效行进行分组和成分顺序校验（数据量已减少，性能提升）
    final formulaGroups = <String, List<Map<String, dynamic>>>{};
    for (final row in validRows) {
      final formulaId = row['formulaId'];
      if (!formulaGroups.containsKey(formulaId)) {
        formulaGroups[formulaId] = [];
      }
      formulaGroups[formulaId]!.add(row);
    }

    // 6. 验证成分编号连续性并构建Formula对象
    final List<ImportFmaInfo> validFormulas = [];
    for (final formulaId in formulaGroups.keys) {
      final groupRows = formulaGroups[formulaId]!;

      // 提取配方基础信息（取第一行的公共字段）
      final firstRow = groupRows.first;
      final formulaName = firstRow['formulaName'] as String;
      final mode = firstRow['mode'] as String;
      final weightUnit =
          mode == 'weight' ? firstRow['weightUnit'] as String : null;
      final category = firstRow['category'] as String?;
      final isConfidential = firstRow['isConfidential'] as bool;
      final needContainer = firstRow['needContainer'] as bool;

      // 排序并验证成分编号连续性
      final ingredients = groupRows
          .map((row) => Ingredient(
                ingredientNo: row['ingredientNo'] as int,
                ingredientId: row['ingredientId'] as String,
                ingredientName: row['ingredientName'] as String,
                weightOrPercent: row['weightOrPercent'] as double,
                allowError: row['allowError'] as double,
              ))
          .toList()
        ..sort((a, b) => a.ingredientNo!.compareTo(b.ingredientNo!));

      final firstFormulaName = firstRow['formulaName'] as String;
      for (final row in groupRows) {
        final currentName = row['formulaName'] as String;
        if (currentName != firstFormulaName) {
          result.errorMessage = localizedStrings.formulaNameInconsistent +
              ', :$currentName  :$firstFormulaName';
          return result; // 找到一个不一致就终止循环，无需继续检查
        }
      }

      // 检查编号是否从1开始连续

      for (int i = 0; i < ingredients.length; i++) {
        if (ingredients[i].ingredientNo != i + 1) {
          result.errorMessage = localizedStrings.sequenceNotContinuous +
              '：${ingredients[i].ingredientNo}';
          return result; // 编号不连续，跳过该配方后续处理
        }
      }

      // 检查2：如果是百分比模式，验证总和是否为100（允许±0.01的浮点数误差）

      if (mode == 'percent') {
        double totalPercent = 0;
        for (var ingredient in ingredients) {
          //只要三位小数计算
          totalPercent +=
              double.parse(ingredient.weightOrPercent!.toStringAsFixed(3));
        }
        totalPercent = double.parse(totalPercent.toStringAsFixed(3));
        // 浮点数比较需用容差，避免精度问题（如99.9999999999或100.0000000001应视为有效）
        if (totalPercent != 100) {
          result.errorMessage = localizedStrings.percentNot100 +
              '${totalPercent.toStringAsFixed(3)}%';
          return result; // 编号不连续，跳过该配方后续处理
        }
      }

      validFormulas.add(ImportFmaInfo(
        formulaId: formulaId,
        formulaName: formulaName,
        mode: mode,
        weightUnit: weightUnit,
        category: category,
        isConfidential: isConfidential,
        needContainer: needContainer,
        ingredients: ingredients,
      ));
    }

    // 7. 输出导入结果和性能数据
    stopwatch.stop();
    final msg =
        '导入完成：成功${validFormulas.length}个配方,耗时${stopwatch.elapsedMilliseconds}ms';
    debugPrint(msg);

    return ImportFmaResult(
        isSuccess: true,
        errorMessage: localizedStrings.tipImporting,
        importFmaInfoList: validFormulas);
  } catch (e) {
    stopwatch.stop();

    return ImportFmaResult(
        isSuccess: false, errorMessage: e.toString(), importFmaInfoList: []);
  }
}

// 辅助函数：获取单元格值（处理空单元格）
String _getCellValue(List<Data?> row, int colIndex) {
  if (colIndex >= row.length) return '';
  final cell = row[colIndex];
  if (cell == null || cell.value == null) return '';
  return cell.value.toString().trim();
}

// 辅助函数：验证数值是否为正数且最多N位小数
bool _isValidDecimal(String value,
    {required int maxDecimals, required double minValue}) {
  // 正则表达式：匹配正数，最多maxDecimals位小数
  final regex =
      RegExp(r'^[0-9]+(\.[0-9]{1,' + maxDecimals.toString() + r'})?$');
  if (!regex.hasMatch(value)) return false;

  // 验证数值大于minValue（避免0或负数）
  final numValue = double.tryParse(value);
  return numValue != null && numValue > minValue;
}

String _validateHeaders(List<String> headers) {
  const requiredHeaders = [
    'Formula Id',
    'Formula Name',
    'Mode',
    'Weight Unit',
    'Category',
    'Confidential',
    'Need Container',
    'Ingredient No.',
    'Ingredient Id',
    'Ingredient Name',
    'Ingredient Weight/Percent',
    'Allow Error'
  ];

  for (final header in requiredHeaders) {
    if (!headers.contains(header)) {
      return header;
    }
  }
  return "";
}

//导入Raw数据
int checkScaleName(String scaleName) {
  for (var scale in myAllScalesList) {
    if (scaleName == scale.scaleName) {
      return scale.scaleId;
    }
  }
  return 0;
}

// 判断一行是否为空的辅助函数
bool _isRowEmpty(List<Data?> row) {
  return row.every((cell) =>
      cell == null ||
      cell.value == null ||
      cell.value.toString().trim().isEmpty);
}

Future<ImportRawResult> importRawFromExcel(File file) async {
  ImportRawResult result =
      ImportRawResult(isSuccess: false, errorMessage: '', importRawList: []);
  try {
    // 1. 读取Excel文件
    final bytes = await file.readAsBytes();
    final excelData = Excel.decodeBytes(bytes);

    if (excelData.tables.isEmpty) {
      result.errorMessage = localizedStrings.noDataImport;
      return result;
    }

    // 获取第一个工作表
    final sheet = excelData.tables.values.first;
    if (sheet.rows.isEmpty) {
      result.errorMessage = localizedStrings.noDataImport;
      return result;
    }
    debugPrint('importRawFromExcel: ${sheet.rows.length}');
    //删除每列都是null的行

    //大于1000行 提示用户一次读取1000行
    if (sheet.rows.length > 5001) {
      result.errorMessage = localizedStrings.max5000Rows;
      return result;
    }

    // 2. 解析表头并验证
    List<String> headers = [];
    for (var cell in sheet.rows[0]) {
      if (cell != null && cell.value != null) {
        headers.add(cell.value.toString());
      }
    }

    String res = _validateRawHeaders(headers);
    if (res != '') {
      result.errorMessage = localizedStrings.missingHeaders + '：$res';
      return result;
    }

    //验证数据，导入所有的ID列，判断不能重复，也不能存在
    List<String> idList = [];
    List<String> nameList = [];
    List<String> scaleIdList = [];
    List<String> typeList = [];
    List<String> notesList = [];
    //找出'Ingredient Id',列,并判断这列的值都不重复，且不为空

    for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      var rowData = sheet.rows[rowIndex];

      // 跳过空行
      if (_isRowEmpty(rowData)) {
        debugPrint('跳过空行: $rowIndex');
        continue;
      }
      for (int col = 0; col < sheet.maxColumns; col++) {
        if (headers[col] == 'Ingredient Name') {
          final cellValue = sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: col, rowIndex: rowIndex))
              .value;
          String name = cellValue != null ? cellValue.toString().trim() : '';
          if (name.isEmpty) {
            result.errorMessage = localizedStrings.tipRow +
                ': ${rowIndex + 1}: ${localizedStrings.ingredientNameEmpty}';
            return result;
          }
          nameList.add(name);
          continue;
        }
        if (headers[col] == 'Device Name') {
          final cellValue = sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: col, rowIndex: rowIndex))
              .value;
          String scale = cellValue != null ? cellValue.toString().trim() : '';
          int scaleId = 0;
          if (scale.isNotEmpty) {
            scaleId = checkScaleName(scale);
            if (scaleId == 0) {
              result.errorMessage = localizedStrings.tipRow +
                  ': ${rowIndex + 1}: ${localizedStrings.deviceNameNotExist}';
              return result;
            }
          }
          scaleIdList.add(scaleId.toString());
          continue;
        }
        if (headers[col] == 'Ingredient Id') {
          final cellValue = sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: col, rowIndex: rowIndex))
              .value;
          String id = cellValue != null ? cellValue.toString().trim() : '';
          if (id.isEmpty) {
            result.errorMessage = localizedStrings.tipRow +
                ': ${rowIndex + 1}: ${localizedStrings.ingredientIdIsEmpty}';

            return result;
          }
          if (idList.contains(id)) {
            result.errorMessage = localizedStrings.tipRow +
                ': ${rowIndex + 1}:  $id ${localizedStrings.fRawIdDuplicate}';
            return result;
          }
          if (checkRawExist(id)) {
            result.errorMessage = localizedStrings.tipRow +
                ': ${rowIndex + 1}:  $id ${localizedStrings.fRawIdDuplicate}';
            return result;
          }
          idList.add(id);
          continue;
        }
        if (headers[col] == 'Category') {
          final cellValue = sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: col, rowIndex: rowIndex))
              .value;
          String type = cellValue != null ? cellValue.toString().trim() : '';
          typeList.add(type);
        }
        if (headers[col] == 'Ingredient Notes') {
          final cellValue = sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: col, rowIndex: rowIndex))
              .value;
          String notes = cellValue != null ? cellValue.toString().trim() : '';
          notesList.add(notes);
          continue;
        }
      }
    }

    List<List<String>> info = [];
    info.add(idList);
    info.add(nameList);
    info.add(scaleIdList);
    info.add(typeList);
    info.add(notesList);

    result.isSuccess = true;
    result.errorMessage = localizedStrings.tipImporting;
    result.importRawList = info;
    return result;
  } catch (e) {
    result.errorMessage = "fail：${e.toString()}";
    return result;
  }
}

// 验证CSV表头是否包含所有必要字段
String _validateRawHeaders(List<String> headers) {
  const requiredHeaders = [
    'Ingredient Id',
    'Ingredient Name',
    'Category',
    'Ingredient Notes',
    'Device Name',
  ];

  for (final header in requiredHeaders) {
    if (!headers.contains(header)) {
      return header;
    }
  }
  return "";
}

bool checkRawExist(String materialId) {
  return rawDataList
      .any((element) => element.rawMaterial.materialId == materialId);
}
