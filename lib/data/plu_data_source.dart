import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';

class RestorablePluSelections extends RestorableProperty<Set<int>> {
  Set<int> _dessertSelections = {};

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _dessertSelections.contains(index);

  /// Takes a list of [PluData]s and saves the row indices of selected rows
  /// into a [Set].
  void setDessertSelections(List<PluData> desserts) {
    final updatedSet = <int>{};
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (dessert.selected) {
        updatedSet.add(i);
      }
    }
    _dessertSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _dessertSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _dessertSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _dessertSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _dessertSelections = value;
  }

  @override
  Object toPrimitives() => _dessertSelections.toList();
}

int _idCounter = 0;

/// Domain model entity
class PluData {
  int? recId;
  int? plu;
  int? productCode;
  int? itemCode;
  String? category;
  String? productName;
  int? generalUnit;
  int? taxType;
  double? price;
  double? unitWeight;
  double? pretare;
  double? limitHigh;
  double? limitLow;
  String? creatAt;

  bool selected = false;
  PluData(
    this.recId,
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
    this.creatAt,
  );

  final int id = _idCounter++;
}

/// Data source implementing standard Flutter's DataTableSource abstract class
/// which is part of DataTable and PaginatedDataTable synchronous data fecthin API.
/// This class uses static collection of deserts as a data store, projects it into
/// DataRows, keeps track of selected items, provides sprting capability
class PluInfoDataSource extends DataTableSource {
  PluInfoDataSource.empty(this.context) {
    pluInfoList = [];
    _pluInfos = [];
  }

  PluInfoDataSource(this.context,
      [sortedByCalories = false,
      this.hasRowTaps = false,
      this.hasRowHeightOverrides = false,
      this.hasZebraStripes = false]) {
    pluInfoList = _pluInfos;
    if (sortedByCalories) {
      sort((d) => d.plu!, true);
    }
  }

  final BuildContext context;
  late List<PluData> pluInfoList;
  // Add row tap handlers and show snackbar
  bool hasRowTaps = false;
  // Override height values for certain rows
  bool hasRowHeightOverrides = false;
  // Color each Row by index's parity
  bool hasZebraStripes = false;

  List<String> selectedColumns = [];

  void sort<T>(Comparable<T> Function(PluData d) getField, bool ascending) {
    pluInfoList.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void updateSelectedDesserts(RestorablePluSelections selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < pluInfoList.length; i += 1) {
      var dessert = pluInfoList[i];
      if (selectedRows.isSelected(i)) {
        dessert.selected = true;
        _selectedCount += 1;
      } else {
        dessert.selected = false;
      }
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index, [Color? color]) {
    assert(index >= 0);
    if (index >= pluInfoList.length) throw 'index > _desserts.length';
    final pluInfo = pluInfoList[index];

    List<DataCell> cells = [];

    for (var filedName in selectedColumns) {
      switch (filedName) {
        case 'plu':
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Tooltip(
                  message: "1-99999",
                  child: TextField(
                    controller:
                        TextEditingController(text: pluInfo.plu.toString()),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[1-9]\d{0,4}$')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                      pluInfoList[index].plu = int.tryParse(value) ?? 0;
                    },
                  )),
            )),
          );
          break;
        case "productCode":
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Tooltip(
                  message: "1-9999999999999",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.productCode).toString()),
                    style: const TextStyle(
                        fontSize: 14, overflow: TextOverflow.ellipsis),
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[1-9]\d{0,12}$')),
                      LengthLimitingTextInputFormatter(13),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                      pluInfoList[index].productCode = int.tryParse(value) ?? 0;
                    },
                  )),
            )),
          );

          break;
        case "itemCode":
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Tooltip(
                  message: "1-9999999999999",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.itemCode).toString()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[1-9]\d{0,12}$')),
                      LengthLimitingTextInputFormatter(13),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                      pluInfoList[index].itemCode = int.tryParse(value) ?? 0;
                    },
                  )),
            )),
          );
          break;
        case "category":
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Tooltip(
                  message: "Length:30",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.category).toString()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    minLines: 1,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                      pluInfoList[index].category = value;
                    },
                  )),
            )),
          );
          break;
        case "productName":
          cells.add(
            DataCell(Container(
              // width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Tooltip(
                  message: "Length:30",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.productName).toString()),
                    style: const TextStyle(
                        fontSize: 14, overflow: TextOverflow.ellipsis),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    minLines: 1,
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^[1-9]\d*$')),
                      LengthLimitingTextInputFormatter(30),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      pluInfoList[index].productName = value;
                    },
                  )),
            )),
          );
          break;
        case "generalUnit":
          cells.add(
            DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Tooltip(
                  message:
                      "wgt:0-g,1-kg,2-lb,3-oz,4-lboz,5-tj,6-hj,7-t \r\nprice:0-kg,1-100g,2-pcs",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.generalUnit).toString()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[0-7]$')),
                      LengthLimitingTextInputFormatter(1),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      pluInfoList[index].generalUnit = int.tryParse(value) ?? 0;
                    },
                  ),
                ))),
          );
          break;
        case "taxType":
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Tooltip(
                  message: "0-tax1,1-tax2,2-tax3",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.taxType).toString()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[0-2]$')),
                      LengthLimitingTextInputFormatter(1),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                      pluInfoList[index].taxType = int.tryParse(value) ?? 0;
                    },
                  )),
            )),
          );
          break;
        case "price":
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: TextField(
                controller:
                    TextEditingController(text: (pluInfo.price).toString()),
                style: const TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none, // 去除边框
                  ),
                ),
                onChanged: (value) {
                  // 更新数据
                  // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                  pluInfoList[index].price = double.tryParse(value) ?? 0.0;
                },
              ),
            )),
          );
          break;
        case "unitWeight":
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Tooltip(
                  message: "Unit: g",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.unitWeight).toString()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                      pluInfoList[index].unitWeight =
                          double.tryParse(value) ?? 0;
                    },
                  )),
            )),
          );
          break;
        case "pretare":
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Tooltip(
                  message: "Unit: kg",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.pretare).toString()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                      pluInfoList[index].pretare = double.tryParse(value) ?? 0;
                    },
                  )),
            )),
          );
          break;
        case "limitHigh":
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Tooltip(
                  message: "Same as Weight Unit  Or PCS(when have unit weight)",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.limitHigh).toString()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                      pluInfoList[index].limitHigh =
                          double.tryParse(value) ?? 0;
                    },
                  )),
            )),
          );
          break;
        case "limitLow":
          cells.add(
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Tooltip(
                  message: "Same as Weight Unit  Or PCS(when have unit weight)",
                  child: TextField(
                    controller: TextEditingController(
                        text: (pluInfo.limitLow).toString()),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // 去除边框
                      ),
                    ),
                    onChanged: (value) {
                      // 更新数据
                      // _dessertsDataSource.desserts[index].calories = num.tryParse(value)?? 0;
                      pluInfoList[index].limitLow =
                          double.tryParse(value) ?? 0.0;
                    },
                  )),
            )),
          );
          break;
      }
    }

    return DataRow2.byIndex(
      index: index,
      selected: pluInfo.selected,
      color: color != null
          ? WidgetStateProperty.all(color)
          : (hasZebraStripes && index.isEven
              ? WidgetStateProperty.all(Theme.of(context).highlightColor)
              : null),
      onSelectChanged: (value) {
        if (pluInfo.selected != value) {
          _selectedCount += value! ? 1 : -1;
          assert(_selectedCount >= 0);
          pluInfo.selected = value;
          notifyListeners();
        }
      },
      specificRowHeight:
          hasRowHeightOverrides && pluInfo.generalUnit! >= 25 ? 100 : null,
      cells: cells,
    );
  }

  @override
  int get rowCount => pluInfoList.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void selectAll(bool? checked) {
    for (final dessert in pluInfoList) {
      dessert.selected = checked ?? false;
    }
    _selectedCount = (checked ?? false) ? pluInfoList.length : 0;
    notifyListeners();
  }
}

int _selectedCount = 0;

List<PluData> _pluInfos = <PluData>[];

_showSnackbar(BuildContext context, String text, [Color? color]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: color,
    duration: const Duration(seconds: 1),
    content: Text(text),
  ));
}

const noData = 'No data';
