//配方导入方法

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/import_fma_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';

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
Future<List<ImportFmaInfo>> importFormulasFromExcel(
    File file, BuildContext context) async {
  final stopwatch = Stopwatch()..start(); // 用于监控导入性能
  try {
    // 1. 读取Excel并解析
    final bytes = await file.readAsBytes();
    final excelData = Excel.decodeBytes(bytes);

    if (excelData.tables.isEmpty) {
      showTipInfo('没有数据导入：Excel文件中未找到工作表', context);
      return [];
    }

    final sheet = excelData.tables.values.first;
    if (sheet.rows.isEmpty) {
      showTipInfo('没有数据导入：工作表为空', context);
      return [];
    }

    //大于1000行 提示用户一次读取1000行
    if (sheet.rows.length > 1000) {
      showTipInfo('请一次最多导入1000行数据', context);
      return [];
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
      showTipInfo('导入失败：缺少必要的表头字段：$missingHeader', context);
      return [];
    }

    final List<Map<String, dynamic>> validRows = [];
    for (int rowIdx = 1; rowIdx < sheet.rows.length; rowIdx++) {
      final row = sheet.rows[rowIdx];
      final rowData = <String, dynamic>{};

      // 4.1 校验Formula Id（非空+整数）
      final formulaIdCol = columnIndexMap['Formula Id']!;
      final formulaIdValue = _getCellValue(row, formulaIdCol);
      if (formulaIdValue.isEmpty) {
        showTipInfo('Formula Id为空, 第${rowIdx + 1}行', context);
        return [];
      } else if (isFormulaExist(formulaIdValue)) {
        showTipInfo('Formula Id已存在, 第${rowIdx + 1}行', context);
        return [];
      } else {
        rowData['formulaId'] = formulaIdValue;
      }

      // 4.2 校验Formula Name（非空）
      final formulaNameCol = columnIndexMap['Formula Name']!;
      final formulaName = _getCellValue(row, formulaNameCol).trim();
      if (formulaName.isEmpty) {
        showTipInfo('Formula Name为空, 第${rowIdx + 1}行', context);
        return [];
      } else {
        rowData['formulaName'] = formulaName;
      }

      // 4.3 校验Mode（非空+合法值）
      final modeCol = columnIndexMap['Mode']!;
      final mode = _getCellValue(row, modeCol).trim().toLowerCase();
      if (mode.isEmpty) {
        showTipInfo('Mode为空, 第${rowIdx + 1}行', context);
        return [];
      } else if (!['weight', 'percent'].contains(mode)) {
        showTipInfo('Mode必须是weight或percent（值：$mode）', context);
        return [];
      } else {
        rowData['mode'] = mode;
        // 当Mode为weight时，校验Weight Unit
        if (mode == 'weight') {
          final weightUnitCol = columnIndexMap['Weight Unit'];
          final weightUnit = weightUnitCol != null
              ? _getCellValue(row, weightUnitCol).trim()
              : '';
          if (weightUnit.isEmpty) {
            showTipInfo(
                'Mode为weight时，Weight Unit不能为空, 第${rowIdx + 1}行', context);
            return [];
          } else {
            rowData['weightUnit'] = weightUnit;
          }
        }
      }

      // 4.4 校验Ingredient No.（非空+正整数）
      final ingredientNoCol = columnIndexMap['Ingredient No.']!;
      final ingredientNoValue = _getCellValue(row, ingredientNoCol);
      if (ingredientNoValue.isEmpty) {
        showTipInfo('Ingredient No.为空, 第${rowIdx + 1}行', context);
        return [];
      } else {
        final ingredientNo = int.tryParse(ingredientNoValue);
        if (ingredientNo == null || ingredientNo <= 0) {
          showTipInfo('Ingredient No.必须是正整数（值：$ingredientNoValue）', context);
          return [];
        } else {
          rowData['ingredientNo'] = ingredientNo;
        }
      }

      // 4.5 校验Ingredient Id（非空）
      final ingredientIdCol = columnIndexMap['Ingredient Id']!;
      final ingredientId = _getCellValue(row, ingredientIdCol).trim();
      if (ingredientId.isEmpty) {
        showTipInfo('Ingredient Id为空, 第${rowIdx + 1}行', context);
        return [];
      } else if (!isRawExist(ingredientId)) {
        showTipInfo(
            'Ingredient Id 不存在, 第${rowIdx + 1}行，请先导入Ingredient', context);
        return [];
      } else {
        rowData['ingredientId'] = ingredientId;
      }

      // 4.6 校验Weight/Percent（非空+正数+最多3位小数）
      final weightCol = columnIndexMap['Ingredient Weight/Percent']!;
      final weightValue = _getCellValue(row, weightCol);
      if (weightValue.isEmpty) {
        showTipInfo('Ingredient Weight/Percent为空, 第${rowIdx + 1}行', context);
        return [];
      } else if (!_isValidDecimal(weightValue,
          maxDecimals: 3, minValue: 0.001)) {
        showTipInfo('Weight/Percent应> 0 且最多3位小数（值：$weightValue）', context);
        return [];
      } else {
        rowData['weightOrPercent'] = double.parse(weightValue);
      }

      // 4.7 校验Allow Error（非空+正数+最多3位小数）
      final errorCol = columnIndexMap['Allow Error']!;
      final errorValue = _getCellValue(row, errorCol);
      if (errorValue.isEmpty) {
        showTipInfo('Allow Error为空, 第${rowIdx + 1}行', context);
        return [];
      } else if (!_isValidDecimal(errorValue,
          maxDecimals: 3, minValue: 0.001)) {
        showTipInfo('Allow Error必须是正数且最多3位小数（值：$errorValue）', context);
        return [];
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
          showTipInfo('$formulaId 配方名称不一致"', context);

          return []; // 找到一个不一致就终止循环，无需继续检查
        }
      }

      // 检查编号是否从1开始连续

      for (int i = 0; i < ingredients.length; i++) {
        if (ingredients[i].ingredientNo != i + 1) {
          showTipInfo(' $formulaId  成分编号不连续"', context);

          return []; // 编号不连续，跳过该配方后续处理
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
          showTipInfo(
              '$formulaId 总和为${totalPercent.toStringAsFixed(3)}%，不等于100%',
              context);

          return []; // 编号不连续，跳过该配方后续处理
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

    showTipInfo(msg, context);

    return validFormulas;
  } catch (e) {
    stopwatch.stop();
    showTipInfo(
        '导入失败：${e.toString()}，耗时${stopwatch.elapsedMilliseconds}ms', context);
    return [];
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

// 工具方法：快速提取字符串（减少空值判断冗余）
String? _getString(List<Data?> row, int? colIndex) {
  if (colIndex == null || colIndex >= row.length) return null;
  final value = row[colIndex]?.value;
  return value?.toString()?.trim();
}

// 工具方法：快速解析整数（减少重复代码）
int? _parseInt(List<Data?> row, int? colIndex) {
  final str = _getString(row, colIndex);
  return str == null ? null : int.tryParse(str);
}

// 工具方法：快速解析小数（减少重复代码）
double? _parseDouble(List<Data?> row, int? colIndex) {
  final str = _getString(row, colIndex);
  return str == null ? null : double.tryParse(str);
}

// 工具方法：验证小数是否有效（纯内存计算）
bool _isValidDecimalValue(double? value, int maxDecimals, double minValue) {
  if (value == null || value <= minValue) return false;
  // 计算小数位数（比正则更快）
  final str = value.toStringAsFixed(maxDecimals);
  final dotIndex = str.indexOf('.');
  if (dotIndex == -1) return true;
  final decimals = str.substring(dotIndex + 1).replaceAll(RegExp(r'0+$'), '');
  return decimals.length <= maxDecimals;
}

// 统一UI提示（减少UI交互次数）
void _showError(String msg, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, maxLines: 3, overflow: TextOverflow.ellipsis),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    ),
  );
}

void _showSuccess(String msg, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    ),
  );
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
