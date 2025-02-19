import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

// 定义 Restorable 属性类，用于保存选中行的信息
class RestorableWgtSelections extends RestorableProperty<Set<int>> {
  Set<int> _wgtSelections = {};

  // 判断指定索引的行是否被选中
  bool isSelected(int index) => _wgtSelections.contains(index);

  // 根据 WeightReportData 列表更新选中行的索引集合
  void setWgtSelections(List<WeightRptData> wgts) {
    final updatedSet = <int>{};
    for (var i = 0; i < wgts.length; i += 1) {
      var wgt = wgts[i];
      if (wgt.selected) {
        updatedSet.add(i);
      }
    }
    _wgtSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _wgtSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _wgtSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _wgtSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _wgtSelections = value;
  }

  @override
  Object toPrimitives() => _wgtSelections.toList();
}

// 定义 WeightReportData 类，用于存储报表数据
class WeightRptData {
  WeightRptData(
    this.id,
    this.scaleModel,
    this.scaleSn,
    this.plu,
    this.productCode,
    this.itemCode,
    this.category,
    this.productName,
    this.generalUnit,
    this.taxType,
    this.price,
    this.unitWeight,
    this.pretare,
    this.limitHigh,
    this.limitLow,
    this.weight,
    this.weightUnit,
    this.userNo,
    this.userName,
    this.scaleName,
    this.createdAt,
  );

  final String id;
  final String scaleModel;
  final String scaleSn;
  final String plu;
  final String productCode;
  final String itemCode;
  final String category;
  final String productName;
  final String generalUnit;
  final String taxType;
  final String price;
  final String unitWeight;
  final String pretare;
  final String limitHigh;
  final String limitLow;
  final String weight;
  final String weightUnit;
  final String userNo;
  final String userName;
  final String scaleName;
  final String createdAt;

  bool selected = false;
}

List<WeightRptData> wgtInfos = <WeightRptData>[];

// 定义数据源类，继承自 DataTableSource
class WgtInfoDataSource extends DataTableSource {
  WgtInfoDataSource.empty(this.context) {
    wgtInfoList = [];
    wgtInfos = [];
  }

  WgtInfoDataSource(this.context,
      [sortedByCalories = false,
      this.hasRowTaps = false,
      this.hasRowHeightOverrides = false,
      this.hasZebraStripes = false]) {
    wgtInfoList = wgtInfos;
    if (sortedByCalories) {
      sort((d) => d.plu, true);
    }
  }

  final BuildContext context;
  late List<WeightRptData> wgtInfoList;
  // 是否有行点击处理
  bool hasRowTaps = false;
  // 是否覆盖某些行的高度
  bool hasRowHeightOverrides = false;
  // 是否使用斑马线样式
  bool hasZebraStripes = false;

  List<String> selectedColumns = [];

  // 对数据进行排序
  void sort<T>(
      Comparable<T> Function(WeightRptData d) getField, bool ascending) {
    wgtInfoList.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  // 更新选中的行信息
  void updateSelectedWgts(RestorableWgtSelections selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < wgtInfoList.length; i += 1) {
      var wgt = wgtInfoList[i];
      if (selectedRows.isSelected(i)) {
        wgt.selected = true;
        _selectedCount += 1;
      } else {
        wgt.selected = false;
      }
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index, [Color? color]) {
    assert(index >= 0);
    if (index >= wgtInfoList.length) throw 'index > _wgts.length';
    final wgtInfo = wgtInfoList[index];

    List<DataCell> cells = [];

    for (var filedName in selectedColumns) {
      switch (filedName) {
        case 'Id':
          cells.add(DataCell(Text(wgtInfo.id)));
          break;
        case 'ScaleModel':
          cells.add(DataCell(Text(wgtInfo.scaleModel)));
          break;
        case 'ScaleSn':
          cells.add(DataCell(Text(wgtInfo.scaleSn)));
          break;
        case 'PLU':
          cells.add(DataCell(Text(wgtInfo.plu)));
          break;
        case 'Product Code':
          cells.add(DataCell(Text(wgtInfo.productCode)));
          break;
        case 'Item Code':
          cells.add(DataCell(Text(wgtInfo.itemCode)));
          break;
        case 'Category':
          cells.add(DataCell(Text(wgtInfo.category)));
          break;
        case 'PLU Name':
          cells.add(DataCell(Text(wgtInfo.productName)));
          break;
        case 'GeneralUnit':
          cells.add(DataCell(Text(wgtInfo.generalUnit)));
          break;
        case 'TaxType':
          cells.add(DataCell(Text(wgtInfo.taxType)));
          break;
        case 'Price':
          cells.add(DataCell(Text(wgtInfo.price)));
          break;
        case 'UnitWeight':
          cells.add(DataCell(Text(wgtInfo.unitWeight)));
          break;
        case 'Pretare':
          cells.add(DataCell(Text(wgtInfo.pretare)));
          break;
        case 'LimitHigh':
          cells.add(DataCell(Text(wgtInfo.limitHigh)));
          break;
        case 'LimitLow':
          cells.add(DataCell(Text(wgtInfo.limitLow)));
          break;
        case 'Weight':
          cells.add(DataCell(Text(wgtInfo.weight)));
          break;
        case 'Weight Unit':
          cells.add(DataCell(Text(wgtInfo.weightUnit)));
          break;
        case 'User NO.':
          cells.add(DataCell(Text(wgtInfo.userNo)));
          break;
        case 'User Name':
          cells.add(DataCell(Text(wgtInfo.userName)));
          break;
        case 'Scale Name':
          cells.add(DataCell(Text(wgtInfo.scaleName)));
          break;
        case 'Date Time':
          cells.add(DataCell(Text(wgtInfo.createdAt)));
          break;
      }
    }

    print('Cell count for row $index: ${cells.length}'); // 输出单元格数量

    return DataRow2.byIndex(
      index: index,
      selected: wgtInfo.selected,
      color: color != null
          ? WidgetStateProperty.all(color)
          : (hasZebraStripes && index.isEven
              ? WidgetStateProperty.all(Theme.of(context).highlightColor)
              : null),
      specificRowHeight:
          hasRowHeightOverrides && int.tryParse(wgtInfo.generalUnit)! >= 25
              ? 100
              : null,
      cells: cells,
    );
  }

  @override
  int get rowCount => wgtInfoList.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void selectAll(bool? checked) {
    for (final wgt in wgtInfoList) {
      wgt.selected = checked ?? false;
    }
    _selectedCount = (checked ?? false) ? wgtInfoList.length : 0;
    notifyListeners();
  }
}

int _selectedCount = 0;

// 显示 Snackbar
_showSnackbar(BuildContext context, String text, [Color? color]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: color,
    duration: const Duration(seconds: 1),
    content: Text(text),
  ));
}

const noData = 'No data';
