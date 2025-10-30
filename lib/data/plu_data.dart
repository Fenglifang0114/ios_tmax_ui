// PLU data
// 0-kg 1-100g 2-amount 3-lb 4-g 5-oz 6-lboz 7-tj 8-hj 9-t
// 0-tax1 1-tax2  2-tax3

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/plu_data_source.dart';

Map<int, String> pluUnit = {
  0: "kg",
  1: "100g",
  2: "pcs",
  3: "lb",
  4: "g",
  5: "oz",
  6: "lboz",
  7: "tj",
  8: "hj",
  9: "t",
};
Map<int, String> pluTax = {
  0: "tax1",
  1: "tax2",
  2: "tax3",
};

String? getPluUnit(int unit) {
  if (!pluUnit.containsKey(unit)) {
    return "-";
  }
  return pluUnit[unit];
}

String getPluTax(int tax) {
  if (!pluTax.containsKey(tax)) {
    return "-";
  }
  return pluTax[tax]!;
}

// 根据列名返回显示名称
String getColumnName(String columnName) {
  switch (columnName) {
    case 'plu':
      return localizedStrings.gPluPlu;
    case 'productName':
      return localizedStrings.gPluPluName;
    case 'category':
      return localizedStrings.gPluCategory;
    case 'price':
      return localizedStrings.gPluPrice;
    case 'generalUnit':
      return localizedStrings.gPluWgtUnit;
    case 'taxType':
      return localizedStrings.gPluTaxType;
    case 'unitWeight':
      return localizedStrings.gPluUnitWgt;
    case 'pretare':
      return localizedStrings.gPluPretare;
    case 'limitHigh':
      return localizedStrings.gPluLimitHigh;
    case 'limitLow':
      return localizedStrings.gPluLimitLow;
    case 'productCode':
      return localizedStrings.gPluPluCode;
    case 'itemCode':
      return localizedStrings.gPluItemCode;
    default:
      return columnName;
  }
}

Map<String, String> getTranslationMap() {
  return {
    'plu': getColumnName('plu'),
    'productName': getColumnName('productName'),
    'category': getColumnName('category'),
    'price': getColumnName('price'),
    'generalUnit': getColumnName('generalUnit'),
    'taxType': getColumnName('taxType'),
    'unitWeight': getColumnName('unitWeight'),
    'pretare': getColumnName('pretare'),
    'limitHigh': getColumnName('limitHigh'),
    'limitLow': getColumnName('limitLow'),
    'productCode': getColumnName('productCode'),
    'itemCode': getColumnName('itemCode'),
  };
}

class PluDataSource extends DataGridSource {
  PluDataSource({
    required List<PluDataModel> dataModels,
    required this.allSelectedNotifier,
    required this.updateAllSelectedStatus,
    required this.onEnabled,
    required this.orderField,
    required TextTheme textScheme,
    required ColorScheme colorScheme,
    required this.canSelect,
    required this.enableTitle,
    required this.disableTitle,
  }) {
    _dataModels = dataModels.map<DataGridRow>((e) {
      final cells = <DataGridCell>[];
      // 固定列 'select' 始终添加
      if (canSelect) {
        cells.add(
          DataGridCell<bool>(columnName: 'select', value: e.isSelected),
        );
      }

      // 根据列可见性动态添加其他列
      for (final key in orderField) {
        switch (key) {
          case 'plu':
            cells.add(
              DataGridCell<int>(columnName: 'plu', value: e.pluData.plu),
            );
            break;
          case 'productName':
            cells.add(
              DataGridCell<String>(
                columnName: 'productName',
                value: e.pluData.productName,
              ),
            );
            break;
          case 'category':
            cells.add(
              DataGridCell<String>(
                columnName: 'category',
                value: e.pluData.category,
              ),
            );
            break;
          case 'price':
            cells.add(
              DataGridCell<String>(
                  columnName: 'price', value: e.pluData.price.toString()),
            );
            break;

          case 'generalUnit':
            cells.add(
              DataGridCell<String>(
                columnName: 'generalUnit',
                value: getPluUnit(e.pluData.generalUnit!),
              ),
            );
            break;
          case 'taxType':
            cells.add(
              DataGridCell<String>(
                columnName: 'taxType',
                value: getPluTax(e.pluData.taxType!),
              ),
            );
            break;
          case 'unitWeight':
            cells.add(
              DataGridCell<double>(
                columnName: 'unitWeight',
                value: e.pluData.unitWeight,
              ),
            );
            break;
          case 'pretare':
            cells.add(
              DataGridCell<double>(
                columnName: 'pretare',
                value: e.pluData.pretare,
              ),
            );
            break;
          case 'limitHigh':
            cells.add(
              DataGridCell<double>(
                columnName: 'limitHigh',
                value: e.pluData.limitHigh,
              ),
            );
            break;
          case 'limitLow':
            cells.add(
              DataGridCell<double>(
                columnName: 'limitLow',
                value: e.pluData.limitLow,
              ),
            );
            break;

          case 'productCode':
            cells.add(
              DataGridCell<int>(
                columnName: 'productCode',
                value: e.pluData.productCode,
              ),
            );
            break;
          case 'itemCode':
            cells.add(
              DataGridCell<int>(
                columnName: 'itemCode',
                value: e.pluData.itemCode,
              ),
            );
            break;
        }
      }

      cells.add(
        DataGridCell<String>(
            columnName: 'enable',
            value: e.pluData.enabled == null
                ? enableTitle
                : e.pluData.enabled!
                    ? enableTitle
                    : disableTitle),
      );
      return DataGridRow(cells: cells);
    }).toList();
    _originalDataModels = dataModels;
    myTextScheme = textScheme;
    _colorScheme = colorScheme;
  }

  late List<PluDataModel> _originalDataModels;
  final ValueNotifier<bool> allSelectedNotifier;
  final VoidCallback updateAllSelectedStatus;
  final List<String> orderField;

  final Function(PluDataModel) onEnabled; // 删除回调
  final bool canSelect;
  final String enableTitle;
  final String disableTitle;

  List<DataGridRow> _dataModels = [];
  late TextTheme myTextScheme;
  late ColorScheme _colorScheme;

  @override
  List<DataGridRow> get rows => _dataModels;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final index = _dataModels.indexOf(row);

    final dataModel = _originalDataModels[index];
    var colorScheme = _colorScheme;

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'select' && canSelect) {
          return Checkbox(
            value: dataModel.isSelected,
            onChanged: (bool? newValue) {
              setState(() {
                dataModel.isSelected = newValue ?? false;
                updateAllSelectedStatus();
              });
            },
          );
        } else if (dataGridCell.columnName == 'enable') {
          return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  onEnabled(dataModel);
                },
                child: Text(
                  dataGridCell.value.toString(),
                  style: TextStyle(
                    fontFamily: "alibaba",
                    color: dataModel.pluData.enabled == null
                        ? colorScheme.onTertiaryFixedVariant
                        : dataModel.pluData.enabled!
                            ? colorScheme.onTertiaryFixedVariant
                            : colorScheme.error,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ));
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click, // 手型光标
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              dataGridCell.value.toString(),
              style: TextStyle(
                fontFamily: "alibaba",
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        );
      }).toList(),
    );
  }

  void setState(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}

// 数据模型

class PluDataModel {
  final PluData pluData;
  bool isSelected;

  PluDataModel({
    required this.pluData,
    this.isSelected = false,
  });

  // 复制方法，用于编辑时创建新对象

  PluDataModel copyWith({
    PluData? pluData,
    bool? isSelected,
  }) {
    return PluDataModel(
      pluData: pluData ?? this.pluData,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

Excel performExportTemplate(Map<String, bool> columnVisibility) {
  final excel = Excel.createExcel();
  final sheet = excel['Sheet1'];

  List<String> selectedColumns = [];
  for (var element in columnVisibility.keys) {
    if (columnVisibility[element] == true) {
      selectedColumns.add(element);
    }
  }

  // 写入表头
  sheet.appendRow([
    if (selectedColumns.contains('plu')) TextCellValue('PLU'),
    if (selectedColumns.contains('productCode')) TextCellValue('ProductCode'),
    if (selectedColumns.contains('itemCode')) TextCellValue('ItemCode'),
    if (selectedColumns.contains('productName')) TextCellValue('ProductName'),
    if (selectedColumns.contains('generalUnit')) TextCellValue('GeneralUnit'),
    if (selectedColumns.contains('taxType')) TextCellValue('TaxType'),
    if (selectedColumns.contains('price')) TextCellValue('Price'),
    if (selectedColumns.contains('unitWeight')) TextCellValue('UnitWeight'),
    if (selectedColumns.contains('pretare')) TextCellValue('PreTare'),
    if (selectedColumns.contains('limitHigh')) TextCellValue('LimitHigh'),
    if (selectedColumns.contains('limitLow')) TextCellValue('LimitLow'),
    if (selectedColumns.contains('category')) TextCellValue('Category'),
  ]);

  // 写入数据行

  sheet.appendRow([
    if (selectedColumns.contains('plu')) TextCellValue("1"),
    if (selectedColumns.contains('productCode')) TextCellValue('1'),
    if (selectedColumns.contains('itemCode')) TextCellValue('1'),
    if (selectedColumns.contains('productName')) TextCellValue('Apple'),
    if (selectedColumns.contains('generalUnit')) TextCellValue('kg'),
    if (selectedColumns.contains('taxType')) TextCellValue('tax1'),
    if (selectedColumns.contains('price')) TextCellValue('8.88'),
    if (selectedColumns.contains('unitWeight')) TextCellValue('8'),
    if (selectedColumns.contains('pretare')) TextCellValue('0.88'),
    if (selectedColumns.contains('limitHigh')) TextCellValue('10'),
    if (selectedColumns.contains('limitLow')) TextCellValue('2'),
    if (selectedColumns.contains('category')) TextCellValue('Fruits'),
  ]);

  sheet.appendRow([
    if (selectedColumns.contains('plu')) TextCellValue("1-99999"),
    if (selectedColumns.contains('productCode'))
      TextCellValue('Not in use yet'),
    if (selectedColumns.contains('itemCode')) TextCellValue('Not in use yet'),
    if (selectedColumns.contains('productName'))
      TextCellValue(
          'The length is 30. Characters need scale support for display and only printer support for printing.'),
    if (selectedColumns.contains('generalUnit'))
      TextCellValue('kg,100g,pcs,lb,g,oz,lboz,tj,hj,t'),
    if (selectedColumns.contains('taxType')) TextCellValue('tax1 tax2 tax3'),
    if (selectedColumns.contains('price')) TextCellValue('unit Price'),
    if (selectedColumns.contains('unitWeight')) TextCellValue('Unit: g'),
    if (selectedColumns.contains('pretare')) TextCellValue('Unit: Kg'),
    if (selectedColumns.contains('limitHigh'))
      TextCellValue(
          'With unit weight, upper & lower limit units are pcs and must be integers; without, they are the same as GeneralUnit.'),
    if (selectedColumns.contains('limitLow'))
      TextCellValue(
          'With unit weight, upper & lower limit units are pcs and must be integers; without, they are the same as GeneralUnit.'),
  ]);

  return excel;
}
