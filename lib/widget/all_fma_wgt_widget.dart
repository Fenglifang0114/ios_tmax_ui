// 包装类，用于在DataGrid中显示
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/language.dart';

class OrderData {
  OrderData({
    required this.header,
    this.details,
    required this.isHeader,
  });

  final HeaderRec? header;
  final DetailRec? details;

  final bool isHeader;
}

class SortableHeader extends StatelessWidget {
  final String columnName;
  final String currentSortColumn;
  final bool sortAscending;
  final VoidCallback onSort;
  final Widget child;
  final double? width;

  const SortableHeader({
    super.key,
    required this.columnName,
    required this.currentSortColumn,
    required this.sortAscending,
    required this.onSort,
    required this.child,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSort,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,
            const SizedBox(width: 4),
            if (currentSortColumn == columnName)
              Icon(
                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// DataGrid数据源
class OrderDataSource extends DataGridSource {
  OrderDataSource({
    required List<OrderData> orderDataList,
    required Function(String) onExpandPressed,
    required Map<String, bool> expandedOrders,
    required Function(String) onPrintPressed,
    required Map<String, bool> selectedOrders,
    required Function(String) onSelectionChanged,
    required Map<String, Color> colorsInfo,
  }) {
    _orderDataList = orderDataList;
    _onExpandPressed = onExpandPressed;
    _expandedOrders = expandedOrders;
    _selectedOrders = selectedOrders;
    _onPrintPressed = onPrintPressed;
    _colorsInfo = colorsInfo;
    _onSelectionChanged = onSelectionChanged;
    buildDataGridRows();
  }

  late List<OrderData> _orderDataList;
  late Function(String) _onExpandPressed;
  late Function(String) _onPrintPressed;
  late Map<String, bool> _expandedOrders;
  late Function(String) _onSelectionChanged;
  late Map<String, Color> _colorsInfo;
  late Map<String, bool> _selectedOrders;

  List<DataGridRow> _dataGridRows = [];

  void buildDataGridRows() {
    _dataGridRows = _orderDataList.map<DataGridRow>((orderData) {
      final header = orderData.header;
      final detail = orderData.details;
      final isExpanded = _expandedOrders[header!.recordId] ?? false;
      final isSelected = _selectedOrders[header.recordId] ?? false;

      return DataGridRow(
        cells: [
// 复选框列（只对头行显示）
          DataGridCell<Widget>(
            columnName: 'checkbox',
            value: orderData.isHeader
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) => _onSelectionChanged(header.recordId!),
                  )
                : SizedBox(
                    width: 40,
                    height: 40,
                  ), // 明细行留空
          ),
          // 订单号
          DataGridCell<String>(
            columnName: 'orderId',
            value: orderData.isHeader ? header.recordId : '',
          ),

          // 客户名称
          DataGridCell<String>(
            columnName: 'fmaId',
            value: orderData.isHeader ? header.formulaId : '',
          ),
          // 客户名称
          DataGridCell<String>(
            columnName: 'fmaName',
            value: orderData.isHeader ? header.formulaName : '',
          ),
          // 客户名称
          DataGridCell<String>(
            columnName: 'barcode',
            value: orderData.isHeader ? header.formulaBarcode : '',
          ),

          // 产品名称（明细行显示，头行显示总订单）
          DataGridCell<String>(
            columnName: 'rawName',
            value: orderData.isHeader ? '' : detail!.materialName,
          ),

          // 数量
          DataGridCell<String>(
            columnName: 'rawId',
            value: orderData.isHeader ? "" : detail!.materialId,
          ),

          // 单价
          DataGridCell<String>(
            columnName: 'mode',
            value: orderData.isHeader
                ? header.formulaMode! == 'wgt'
                    ? (localizedStrings?.fWeightMode ?? "fWeightMode")
                    : (localizedStrings?.fPctMode ?? "fPctMode")
                : '',
          ),

          // 保密
          DataGridCell<String>(
            columnName: 'confidential ',
            value: orderData.isHeader
                ? header.isEncrypted!
                    ? (localizedStrings?.fConfidential ?? "fConfidential")
                    : (localizedStrings?.fPublic ?? "fPublic")
                : '',
          ),

          // 订单日期
          DataGridCell<String>(
            columnName: 'fmaTotalWeight',
            value: orderData.isHeader
                ? "${header.actualFmaTotalWgt!.toStringAsFixed(3)} ${header.totalWeightUnit}"
                : '',
          ),

          // 总金额
          DataGridCell<String>(
            columnName: 'actualTotalWeight',
            value: orderData.isHeader
                ? "${header.actualTotalWeight!.toStringAsFixed(3)} ${header.totalWeightUnit}"
                : '',
          ),
          DataGridCell<String>(
            columnName: 'rawWgt',
            value: orderData.isHeader
                ? ""
                : detail!.sequence! == 0 ||
                        header.isEncrypted.toString() == "true"
                    ? '-'
                    : "${detail.targetWgt!.toStringAsFixed(3)} ${header.totalWeightUnit}",
          ),
          DataGridCell<String>(
            columnName: 'actualRawWgt',
            value: orderData.isHeader
                ? ""
                : detail!.sequence! == 0 ||
                        header.isEncrypted.toString() == "true"
                    ? '-'
                    : "${detail.actualWeight!.toStringAsFixed(3)} ${header.totalWeightUnit}",
          ),
          DataGridCell<String>(
            columnName: 'allowableError',
            value: orderData.isHeader
                ? ""
                : detail!.sequence! == 0 ||
                        header.isEncrypted.toString() == "true"
                    ? '-'
                    : "${detail.allowableError!.toStringAsFixed(3)} ${header.totalWeightUnit}",
          ),
          DataGridCell<String>(
            columnName: 'actualAllowableError',
            value: orderData.isHeader
                ? ""
                : detail!.sequence! == 0 ||
                        header.isEncrypted.toString() == "true"
                    ? '-'
                    : "${detail.actualErrorWgt!.toStringAsFixed(3)} ${header.totalWeightUnit}",
          ),
          DataGridCell<String>(
            columnName: 'pass',
            value: orderData.isHeader
                ? header.isQualified.toString() == "yes"
                    ? (localizedStrings?.fQualified ?? "fQualified")
                    : (localizedStrings?.fUnqualified ?? "fUnqualified")
                : detail!.sequence! == 0 ||
                        header.isEncrypted.toString() == "true"
                    ? '-'
                    : detail.isQualified.toString() == "ok"
                        ? (localizedStrings?.fQualified ?? "fQualified")
                        : (localizedStrings?.fUnqualified ?? "fUnqualified"),
          ),
          DataGridCell<String>(
            columnName: 'device',
            value: orderData.isHeader ? "" : detail!.scaleName!,
          ),

          DataGridCell<String>(
            columnName: 'time',
            value: orderData.isHeader
                ? header.recordSaveTime != null
                    ? DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(header.recordSaveTime!)
                    : ''
                : "",
          ),
          DataGridCell<String>(
            columnName: 'operator',
            value: orderData.isHeader ? header.headerOperator : "",
          ),

          // 扩展按钮列
          DataGridCell<Widget>(
            columnName: 'expand',
            value: orderData.isHeader
                ? Row(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.print,
                            color: orderData.header!.isEncrypted!
                                ? Colors.grey
                                : _colorsInfo['primary']!,
                          ),
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          onPressed: () {
                            if (orderData.header!.isEncrypted!) {
                              return;
                            }
                            _onPrintPressed(orderData.header!.recordId!);
                          }),
                      IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: _colorsInfo['primary']!,
                        ),
                        onPressed: () => _onExpandPressed(header.recordId!),
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                      )
                    ],
                  )
                : Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_left,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ), // 明细行显示右箭头
          ),
        ],
      );
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = rows.indexOf(row);
    final orderData = _orderDataList[rowIndex];

    // 根据行类型设置不同的背景色和样式
    Color backgroundColor = orderData.isHeader
        ? Color(0xFFF5F5F5) // 头行背景色 - 浅蓝色
        : Colors.grey[50]!; // 明细行背景色 - 浅灰色

    Border? border;
    if (orderData.isHeader) {
      border =
          const Border(bottom: BorderSide(color: Color(0xFFD0D0D0), width: 1));
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells: row.getCells().map<Widget>((dataGridCell) {
        final cellValue = dataGridCell.value;
        final columnName = dataGridCell.columnName;

        // 如果是Widget类型，直接返回
        if (cellValue is Widget) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(border: border),
            child: cellValue,
          );
        }

        // 文本类型
        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: _getAlignment(columnName),
          child: Text(
            cellValue?.toString() ?? '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'HarmonyOS',
                fontWeight:
                    orderData.isHeader ? FontWeight.w600 : FontWeight.normal,
                color: () {
                  // 如果是表头

                  if (cellValue == (localizedStrings?.fUnqualified ?? "fUnqualified")) {
                    return _colorsInfo['error']!; // 保密显示红色
                  } else if (cellValue == (localizedStrings?.fQualified ?? "fQualified")) {
                    return _colorsInfo['success']!; // 公开显示绿色
                  }

                  if (orderData.isHeader) {
                    if (cellValue == (localizedStrings?.fConfidential ?? "fConfidential")) {
                      return _colorsInfo['error']!; // 保密显示红色
                    } else if (cellValue == (localizedStrings?.fPublic ?? "fPublic")) {
                      return _colorsInfo['success']!; // 公开显示绿色
                    }

                    return Color(0xFF171A1D);
                  }

                  // 默认情况：黑色
                  return Color(0xFF555759);
                }(),
                fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  Alignment _getAlignment(String columnName) {
    switch (columnName) {
      case 'quantity':
      case 'unitPrice':
      case 'subtotal':
      case 'totalAmount':
        return Alignment.centerRight;
      case 'expand':
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }

  // 更新数据
  void updateData(List<OrderData> newData, Map<String, bool> expandedOrders,
      Map<String, bool> selectedOrders, bool selectAll) {
    _orderDataList = newData;
    _expandedOrders = expandedOrders;
    _selectedOrders = selectedOrders;

    // 如果selectAll为true，更新所有头行的选中状态
    if (selectAll) {
      for (var key in _selectedOrders.keys) {
        _selectedOrders[key] = true;
      }
    }

    buildDataGridRows();
    notifyListeners();
  }
}
