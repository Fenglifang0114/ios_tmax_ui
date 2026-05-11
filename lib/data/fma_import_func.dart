// //配方导入方法

// import 'dart:io';
// import 'package:excel/excel.dart';
// import 'package:flutter/foundation.dart';
// import 'package:t_max/data/formula_common.dart';
// import 'package:t_max/data/import_fma_data.dart';
// import 'package:t_max/data/language.dart';
// import 'package:t_max/data/scale_info_from_db.dart';

// //找出配方列表中是否已经存在了此配方
// bool isFormulaExist(String formulaId) {
//   if (formulaDataList.isEmpty) {
//     return false;
//   }
//   return formulaDataList
//       .any((formula) => formula.header!.formulaId == formulaId);
// }

// bool isRawExist(String rawId) {
//   if (rawDataList.isEmpty) {
//     return false;
//   }
//   return rawDataList.any((raw) => raw.materialId == rawId);
// }

// // 优化后的导入函数：提前校验字段，过滤无效行
// Future<ImportFmaResult> importFormulasFromExcel(File file) async {
//   ImportFmaResult result = ImportFmaResult(
//     isSuccess: false,
//     errorMessage: '',
//     importFmaInfoList: [],
//   );

//   final stopwatch = Stopwatch()..start(); // 用于监控导入性能
//   try {
//     // 1. 读取Excel并解析
//     final bytes = await file.readAsBytes();
//     final excelData = Excel.decodeBytes(bytes);

//     if (excelData.tables.isEmpty) {
//       result.errorMessage = (localizedStrings?.noDataImport ?? "noDataImport");
//       return result;
//     }

//     final sheet = excelData.tables.values.first;
//     if (sheet.rows.isEmpty) {
//       result.errorMessage = (localizedStrings?.noDataImport ?? "noDataImport");
//       return result;
//     }

//     //大于1000行 提示用户一次读取1000行
//     if (sheet.rows.length > 1001) {
//       result.errorMessage = (localizedStrings?.max1000Rows ?? "max1000Rows");
//       return result;
//     }

//     // 2. 解析表头并映射列索引（关键优化：用索引定位列，避免多次查找）
//     final Map<String, int> columnIndexMap = {};

//     for (var i = 0; i < sheet.rows.first.length; i++) {
//       final cell = sheet.rows.first[i];
//       if (cell != null && cell.value != null) {
//         String header = cell.value.toString().trim();
//         String head = header.replaceAll(" ", "");
//         head = head.replaceAll("*", "");
//         head = head.toLowerCase();
//         if (importFmaHeaders.containsKey(head)) {
//           if (columnIndexMap.containsKey(head)) {
//             result.errorMessage =
//                 (localizedStrings?.duplicateHeaders ?? "duplicateHeaders") + '：$header  ';
//             return result;
//           }
//           columnIndexMap[head] = i;
//         }
//       }
//     }
//     //验证表头是否完整
//     final missingHeader = _validateHeaders(columnIndexMap.keys.toList());
//     if (missingHeader.isNotEmpty) {
//       result.errorMessage = (localizedStrings?.missingHeaders ?? "missingHeaders") + '：$missingHeader';
//       return result;
//     }

//     int count = 1; //计算序号

//     final List<Map<String, dynamic>> validRows = [];
//     for (int rowIdx = 1; rowIdx < sheet.maxRows; rowIdx++) {
//       final row = sheet.rows[rowIdx];
//       if (_isRowEmpty(row)) {
//         debugPrint('跳过空行: $rowIdx');
//         continue;
//       }

//       final rowData = <String, dynamic>{};

//       // 4.1 校验Formula Id（非空+整数）
//       final formulaIdCol = columnIndexMap['formulaid']!;
//       final formulaIdValue = _getCellValue(row, formulaIdCol);
//       if (formulaIdValue.isEmpty) {
//         result.errorMessage = (localizedStrings?.formulaIdEmpty ?? "formulaIdEmpty") +
//             ',${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else if (isFormulaExist(formulaIdValue)) {
//         result.errorMessage =
//             '$formulaIdValue ${(localizedStrings?.formulaIdExists ?? "formulaIdExists")}, ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else {
//         rowData['formulaid'] = formulaIdValue;
//         rowData["no"] = count;
//         count++;
//       }

//       // 4.2 校验Formula Name（非空）
//       final formulaNameCol = columnIndexMap['formulaname']!;
//       final formulaName = _getCellValue(row, formulaNameCol).trim();
//       if (formulaName.isEmpty) {
//         result.errorMessage = (localizedStrings?.formulaNameEmpty ?? "formulaNameEmpty") +
//             ', ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else {
//         rowData['formulaname'] = formulaName;
//       }

//       // 4.3 校验Mode（非空+合法值）
//       final modeCol = columnIndexMap['mode']!;
//       final mode = _getCellValue(row, modeCol).trim().toLowerCase();
//       if (mode.isEmpty) {
//         result.errorMessage = (localizedStrings?.modeEmpty ?? "modeEmpty") +
//             ', ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else if (!['weight', 'percent', "percentage"].contains(mode)) {
//         result.errorMessage = (localizedStrings?.modeInvalid ?? "modeInvalid") +
//             '：$mode , ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else {
//         rowData['mode'] = mode;
//         // 当Mode为weight时，校验Weight Unit
//         if (mode == 'weight') {
//           final weightUnitCol = columnIndexMap['weightunit']!;
//           final weightUnit = _getCellValue(row, weightUnitCol).trim();
//           if (weightUnit.isEmpty) {
//             result.errorMessage = (localizedStrings?.weightUnitEmpty ?? "weightUnitEmpty") +
//                 ', ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//             return result;
//           } else {
//             rowData['weightunit'] = weightUnit;
//           }
//         }
//       }

//       // 4.5 校验Ingredient Id（非空）
//       final ingredientIdCol = columnIndexMap['ingredientid']!;
//       final ingredientId = _getCellValue(row, ingredientIdCol).trim();
//       if (ingredientId.isEmpty) {
//         result.errorMessage = (localizedStrings?.ingredientIdEmpty ?? "ingredientIdEmpty") +
//             ', ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else if (!isRawExist(ingredientId)) {
//         result.errorMessage = (localizedStrings?.ingredientIdNotExist ?? "ingredientIdNotExist") +
//             ', ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else {
//         rowData['ingredientid'] = ingredientId;
//       }

//       // 4.6 校验Weight/Percent（非空+正数+最多3位小数）
//       final weightCol = columnIndexMap['ingredientweight/percentage']!;
//       final weightValue = _getCellValue(row, weightCol);
//       if (weightValue.isEmpty) {
//         result.errorMessage = (localizedStrings?.weightPercentEmpty ?? "weightPercentEmpty") +
//             ', ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else if (!_isValidDecimal(weightValue,
//           maxDecimals: 3, minValue: 0.001)) {
//         result.errorMessage = (localizedStrings?.weightPercentInvalid ?? "weightPercentInvalid") +
//             '：$weightValue , ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else {
//         rowData['ingredientweight/percentage'] = double.parse(weightValue);
//       }

//       // 4.7 校验Allow Error（非空+正数+最多3位小数）
//       final errorCol = columnIndexMap['allowableerror']!;
//       final errorValue = _getCellValue(row, errorCol);
//       if (errorValue.isEmpty) {
//         result.errorMessage = (localizedStrings?.allowErrorEmpty ?? "allowErrorEmpty") +
//             ', ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else if (!_isValidDecimal(errorValue,
//           maxDecimals: 3, minValue: 0.001)) {
//         result.errorMessage = (localizedStrings?.allowErrorInvalid ?? "allowErrorInvalid") +
//             '：$errorValue , ${(localizedStrings?.tipRow ?? "tipRow")}:${rowIdx + 1}';
//         return result;
//       } else {
//         rowData['allowableerror'] = double.parse(errorValue);
//       }

//       // 4.8 处理可选字段（无需校验，为空则存null）
//       rowData['category'] = columnIndexMap.containsKey('category')
//           ? _getCellValue(row, columnIndexMap['category']!).trim()
//           : "";
//       rowData['isconfidential'] = columnIndexMap.containsKey('confidential')
//           ? _getCellValue(row, columnIndexMap['confidential']!)
//                   .trim()
//                   .toLowerCase() ==
//               'yes'
//           : false;
//       rowData['needcontainer'] = columnIndexMap.containsKey('needcontainer')
//           ? _getCellValue(row, columnIndexMap['needcontainer']!)
//                   .trim()
//                   .toLowerCase() ==
//               'yes'
//           : false;
//       rowData['notes'] = columnIndexMap.containsKey('notes')
//           ? _getCellValue(row, columnIndexMap['notes']!).trim()
//           : "";

//       // 4.9 收集行错误或保留有效行

//       validRows.add(rowData);
//     }

//     // 5. 对有效行进行分组和成分顺序校验（数据量已减少，性能提升）
//     final formulaGroups = <String, List<Map<String, dynamic>>>{};
//     for (final row in validRows) {
//       final formulaId = row['formulaid'];
//       if (!formulaGroups.containsKey(formulaId)) {
//         formulaGroups[formulaId] = [];
//       }
//       formulaGroups[formulaId]!.add(row);
//     }

//     // 6. 验证成分编号连续性并构建Formula对象
//     final List<ImportFmaInfo> validFormulas = [];
//     for (final formulaId in formulaGroups.keys) {
//       final groupRows = formulaGroups[formulaId]!;

//       // 提取配方基础信息（取第一行的公共字段）
//       final firstRow = groupRows.first;
//       final formulaName = firstRow['formulaname'] as String;
//       final mode = firstRow['mode'] as String;
//       final weightUnit =
//           mode == 'weight' ? firstRow['weightunit'] as String : null;
//       final category = firstRow['category'] as String?;
//       final isConfidential = firstRow['isconfidential'] as bool;
//       final needContainer = firstRow['needcontainer'] as bool;
//       final notes = firstRow['notes'] as String;

//       // 排序并验证成分编号连续性
//       final ingredients = groupRows
//           .map((row) => Ingredient(
//                 ingredientNo: row['no'] as int,
//                 ingredientId: row['ingredientid'] as String,
//                 weightOrPercent: row['ingredientweight/percentage'] as double,
//                 allowError: row['allowableerror'] as double,
//               ))
//           .toList()
//         ..sort((a, b) => a.ingredientNo!.compareTo(b.ingredientNo!));

//       final firstFormulaName = firstRow['formulaname'] as String;
//       for (final row in groupRows) {
//         final currentName = row['formulaname'] as String;
//         if (currentName != firstFormulaName) {
//           result.errorMessage = (localizedStrings?.formulaNameInconsistent ?? "formulaNameInconsistent") +
//               ', :$currentName  :$firstFormulaName';
//           return result; // 找到一个不一致就终止循环，无需继续检查
//         }
//       }

//       // 重写成分编号从1开始连续
//       for (int i = 0; i < ingredients.length; i++) {
//         ingredients[i].ingredientNo = i + 1;
//       }

//       // 检查2：如果是百分比模式，验证总和是否为100（允许±0.01的浮点数误差）

//       if (mode == 'percent' || mode == 'percentage') {
//         double totalPercent = 0;
//         for (var ingredient in ingredients) {
//           //只要三位小数计算
//           totalPercent +=
//               double.parse(ingredient.weightOrPercent!.toStringAsFixed(3));
//         }
//         totalPercent = double.parse(totalPercent.toStringAsFixed(3));
//         // 浮点数比较需用容差，避免精度问题（如99.9999999999或100.0000000001应视为有效）
//         if (totalPercent != 100) {
//           result.errorMessage = (localizedStrings?.percentNot100 ?? "percentNot100") +
//               '${totalPercent.toStringAsFixed(3)}%';
//           return result;
//         }
//       }

//       validFormulas.add(ImportFmaInfo(
//         formulaId: formulaId,
//         formulaName: formulaName,
//         mode: mode,
//         weightUnit: weightUnit,
//         category: category,
//         isConfidential: isConfidential,
//         needContainer: needContainer,
//         ingredients: ingredients,
//         notes: notes,
//       ));
//     }

//     // 7. 输出导入结果和性能数据
//     stopwatch.stop();
//     final msg =
//         '导入完成：成功${validFormulas.length}个配方,耗时${stopwatch.elapsedMilliseconds}ms';
//     debugPrint(msg);

//     return ImportFmaResult(
//         isSuccess: true,
//         errorMessage: (localizedStrings?.tipImporting ?? "tipImporting"),
//         importFmaInfoList: validFormulas);
//   } catch (e) {
//     stopwatch.stop();
//     return ImportFmaResult(
//         isSuccess: false, errorMessage: e.toString(), importFmaInfoList: []);
//   }
// }

// // 辅助函数：获取单元格值（处理空单元格）
// String _getCellValue(List<Data?> row, int colIndex) {
//   if (colIndex >= row.length) return '';
//   final cell = row[colIndex];
//   if (cell == null || cell.value == null) return '';
//   return cell.value.toString().trim();
// }

// // 辅助函数：验证数值是否为正数且最多N位小数
// bool _isValidDecimal(String value,
//     {required int maxDecimals, required double minValue}) {
//   // 正则表达式：匹配正数，最多maxDecimals位小数
//   final regex =
//       RegExp(r'^[0-9]+(\.[0-9]{1,' + maxDecimals.toString() + r'})?$');
//   if (!regex.hasMatch(value)) return false;

//   // 验证数值大于minValue（避免0或负数）
//   final numValue = double.tryParse(value);
//   return numValue != null && numValue > minValue;
// }

// String _validateHeaders(List<String> headers) {
//   for (final header in importFmaHeaders.keys) {
//     if (!headers.contains(header)) {
//       return importFmaHeaders[header]!;
//     }
//   }
//   return "";
// }

// const Map<String, String> importFmaHeaders = {
//   'formulaid': "Formula Id",
//   'formulaname': "Formula Name",
//   'mode': "Mode",
//   'weightunit': "Weight Unit",
//   'category': "Category",
//   'confidential': "Confidential",
//   'needcontainer': "Need Container",
//   'ingredientid': "Ingredient Id",
//   'ingredientweight/percentage': "Ingredient Weight/Percentage",
//   'allowableerror': "Allowable Error",
//   'notes': "Notes",
// };

// const fmaHeaders = [
//   'Formula Id',
//   'Formula Name',
//   'Mode',
//   'Weight Unit',
//   'Category',
//   'Confidential',
//   'Need Container',
//   'Ingredient Id',
//   'Ingredient Weight/Percentage',
//   'Allowable Error',
//   'Notes'
// ];

// //导入Raw数据
// int checkScaleName(String scaleName) {
//   for (var scale in myAllScalesList) {
//     if (scaleName == scale.scaleName) {
//       return scale.scaleId;
//     }
//   }
//   return 0;
// }

// // 判断一行是否为空的辅助函数
// bool _isRowEmpty(List<Data?> row) {
//   return row.every((cell) =>
//       cell == null ||
//       cell.value == null ||
//       cell.value.toString().trim().isEmpty);
// }

// const Map<String, String> importRawHeaders = {
//   'ingredientid': "Ingredient Id",
//   'ingredientname': "Ingredient Name",
// };

// const List<String> rawHeaders = [
//   'ingredientid',
//   'ingredientname',
//   "verificationcode",
//   'category',
//   'ingredientnotes',
//   'devicename'
// ];

// Map<String, String> getScaleNameList() {
//   Map<String, String> scaleIdNameMap = {};
//   for (var i = 0; i < myAllScalesList.length; i++) {
//     var scaleId = myAllScalesList[i].scaleId.toString();
//     var scaleName = myAllScalesList[i].scaleName;
//     scaleIdNameMap[scaleId] = scaleName;
//   }
//   return scaleIdNameMap;
// }

// Future<ImportRawResult> importRawFromExcel(File file) async {
//   Map<String, String> scaleNameList = getScaleNameList();
//   try {
//     return await _parseExcel(file);
//   } catch (e) {
//     return ImportRawResult(
//       isSuccess: false,
//       errorMessage: "fail：${e.toString()}",
//       importRawList: [],
//     );
//   }
// }

// // 在后台isolate中执行的解析函数
// Future<ImportRawResult> _parseExcel(File file) async {
//   // 手动转换为 Map<String, String>
//   final Map<String, String> importRawHeaders = {
//     'ingredientid': "Ingredient Id",
//     'ingredientname': "Ingredient Name",
//   };
//   importRawHeaders.forEach((key, value) {
//     importRawHeaders[key] = value.toString();
//   });

//   final List<String> rawHeaders = [
//     'ingredientid',
//     'ingredientname',
//     "verificationcode",
//     'category',
//     'ingredientnotes',
//     'devicename'
//   ];

//   final Map<String, String> scaleNameList = getScaleNameList();

//   final bytes = file.readAsBytesSync();
//   final excelData = Excel.decodeBytes(bytes);

//   if (excelData.tables.isEmpty) {
//     return ImportRawResult(
//       isSuccess: false,
//       errorMessage: 'noDataImport',
//       importRawList: [],
//     );
//   }

//   final sheet = excelData.tables.values.first;
//   if (sheet.rows.isEmpty) {
//     return ImportRawResult(
//       isSuccess: false,
//       errorMessage: 'noDataImport',
//       importRawList: [],
//     );
//   }

//   // 行数检查
//   if (sheet.rows.length > 5001) {
//     return ImportRawResult(
//       isSuccess: false,
//       errorMessage: 'max5000Rows',
//       importRawList: [],
//     );
//   }

//   // 解析表头
//   List<String> headers = [];
//   List<int> headerIndexList = [];
//   for (int i = 0; i < sheet.rows[0].length; i++) {
//     Data? cell = sheet.rows[0][i];
//     if (cell != null && cell.value != null) {
//       String headStr = cell.value.toString();
//       String head =
//           headStr.replaceAll(" ", "").replaceAll("*", "").toLowerCase();
//       if (rawHeaders.contains(head)) {
//         if (headers.contains(head)) {
//           return ImportRawResult(
//             isSuccess: false,
//             errorMessage: 'duplicateHeaders: $headStr',
//             importRawList: [],
//           );
//         }
//         headers.add(head);
//         headerIndexList.add(i);
//       }
//     }
//   }

//   // 验证表头
//   String headerError = _validateRawHeadersStatic(headers, importRawHeaders);
//   if (headerError != '') {
//     return ImportRawResult(
//       isSuccess: false,
//       errorMessage: 'missingHeaders: $headerError',
//       importRawList: [],
//     );
//   }

//   // 解析数据行
//   List<String> idList = [];
//   List<String> nameList = [];
//   List<String> scaleIdList = [];
//   List<String> typeList = [];
//   List<String> notesList = [];
//   List<String> codeList = [];

//   for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
//     var rowData = sheet.rows[rowIndex];

//     // 跳过空行
//     if (_isRowEmptyStatic(rowData)) continue;

//     String? id, name, type, notes, code;
//     int scaleId = 0;
//     for (int col = 0; col < sheet.maxColumns; col++) {
//       final cellValue = sheet
//           .cell(
//               CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
//           .value;
//       final value = cellValue?.toString().trim() ?? '';
//       int headerIndex = 0;
//       if (!headerIndexList.contains(col)) {
//         continue;
//       } else {
//         headerIndex = headerIndexList.indexOf(col);
//       }
//       switch (headers[headerIndex]) {
//         case 'ingredientid':
//           id = value;
//           if (id.isEmpty) {
//             return ImportRawResult(
//               isSuccess: false,
//               errorMessage: 'tipRow: ${rowIndex + 1}: ${'ingredientIdIsEmpty'}',
//               importRawList: [],
//             );
//           }
//           if (idList.contains(id)) {
//             return ImportRawResult(
//               isSuccess: false,
//               errorMessage: 'tipRow: ${rowIndex + 1}: $id ${'fRawIdDuplicate'}',
//               importRawList: [],
//             );
//           }
//           break;
//         case 'ingredientname':
//           name = value;
//           if (name.isEmpty) {
//             return ImportRawResult(
//               isSuccess: false,
//               errorMessage: 'tipRow: ${rowIndex + 1}: ${'ingredientNameEmpty'}',
//               importRawList: [],
//             );
//           }
//           break;
//         case 'verificationcode':
//           code = value;
//           break;
//         case 'category':
//           type = value;
//           break;
//         case 'ingredientnotes':
//           notes = value;
//           break;
//         case 'devicename':
//           if (value.isNotEmpty) {
//             scaleId = _checkScaleNameStatic(scaleNameList, value);
//             if (scaleId == 0) {
//               return ImportRawResult(
//                 isSuccess: false,
//                 errorMessage:
//                     'tipRow: ${rowIndex + 1}: ${'deviceNameNotExist'}',
//                 importRawList: [],
//               );
//             }
//           }
//           break;
//       }
//     }

//     idList.add(id!);
//     nameList.add(name!);
//     scaleIdList.add(scaleId.toString());
//     typeList.add(type ?? '');
//     notesList.add(notes ?? '');
//     codeList.add(code ?? "");
//   }

//   List<List<String>> info = [
//     idList,
//     nameList,
//     scaleIdList,
//     typeList,
//     notesList,
//     codeList
//   ];

//   return ImportRawResult(
//     isSuccess: true,
//     errorMessage: 'tipImporting',
//     importRawList: info,
//   );
// }

// // 静态辅助函数（可在isolate中使用）
// bool _isRowEmptyStatic(List<Data?> row) {
//   return row.every((cell) =>
//       cell == null ||
//       cell.value == null ||
//       cell.value.toString().trim().isEmpty);
// }

// String _validateRawHeadersStatic(
//     List<String> headers, Map<String, String> importRawHeaders) {
//   for (final header in importRawHeaders.keys) {
//     if (!headers.contains(header)) {
//       return importRawHeaders[header]!;
//     }
//   }
//   return "";
// }

// int _checkScaleNameStatic(Map<String, String> scaleNameList, String scaleName) {
//   for (final scaleId in scaleNameList.keys) {
//     if (scaleName == scaleNameList[scaleId]) {
//       return int.parse(scaleId);
//     }
//   }

//   return 0; // 示例实现
// }

// bool checkRawExist(List<String> rawIdList, String materialId) {
//   return rawIdList.any((element) => element == materialId);
// }
