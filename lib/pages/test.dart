// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter DataGrid Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const HeaderDetailDataGridPage(),
//     );
//   }
// }

// // 主数据模型 - 订单头信息
// class OrderHeader {
//   OrderHeader({
//     required this.orderId,
//     required this.customerName,
//     required this.customerName1,
//     required this.customerName2,
//     required this.orderDate,
//     required this.totalAmount,
//     required this.status,
//   });

//   final String orderId;
//   final String customerName;
//   final String customerName1;
//   final String customerName2;
//   final DateTime orderDate;
//   final double totalAmount;
//   final String status;
//   List<OrderDetail> details = []; // 明细列表
// }

// // 明细数据模型
// class OrderDetail {
//   OrderDetail({
//     required this.productName,
//     required this.quantity,
//     required this.unitPrice,
//     required this.subtotal,
//   });

//   final String productName;
//   final int quantity;
//   final double unitPrice;
//   final double subtotal;
// }

// // 包装类，用于在DataGrid中显示
// class OrderData {
//   OrderData({
//     required this.orderHeader,
//     this.orderDetail,
//     required this.isHeader,
//     this.isSelected = false,
//   });

//   final OrderHeader orderHeader;
//   final OrderDetail? orderDetail;
//   final bool isHeader;
//   bool isSelected;
// }

// class HeaderDetailDataGridPage extends StatefulWidget {
//   const HeaderDetailDataGridPage({super.key});

//   @override
//   State<HeaderDetailDataGridPage> createState() =>
//       _HeaderDetailDataGridPageState();
// }

// class _HeaderDetailDataGridPageState extends State<HeaderDetailDataGridPage> {
//   // 主数据列表
//   final List<OrderHeader> _orderHeaders = [];

//   // 用于DataGrid显示的数据
//   List<OrderData> _orderDataList = [];

//   // DataGrid控制器
//   late DataGridController _dataGridController;

//   // 分页相关
//   int _currentPage = 1;
//   final int _pageSize = 10;
//   int _totalItems = 0;

//   // 排序相关
//   String _sortColumn = 'orderId';
//   bool _sortAscending = true;

//   // 展开/收起状态
//   final Map<String, bool> _expandedOrders = {};

//   // 全选状态
//   bool _selectAll = false;

//   @override
//   void initState() {
//     super.initState();
//     _dataGridController = DataGridController();
//     _initializeData();
//     _updateDisplayData();
//   }

//   // 初始化模拟数据
//   void _initializeData() {
//     _orderHeaders.clear();

//     // 创建50个订单，每个订单有3-5个明细
//     for (int i = 1; i <= 50; i++) {
//       final order = OrderHeader(
//         orderId: 'ORD${i.toString().padLeft(5, '0')}',
//         customerName: 'Customer ${i % 10 + 1}',
//         customerName1: 'Customer ${i % 10 + 1}_1',
//         customerName2: 'Customer ${i % 10 + 1}_2',
//         orderDate: DateTime.now().subtract(Duration(days: i % 30)),
//         totalAmount: 1000.0 + (i * 100.0),
//         status: i % 3 == 0 ? 'Pending' : (i % 3 == 1 ? 'Shipped' : 'Delivered'),
//       );

//       // 添加明细数据
//       final detailCount = 3 + (i % 3);
//       for (int j = 1; j <= detailCount; j++) {
//         order.details.add(
//           OrderDetail(
//             productName: 'Product ${((i * 10) + j) % 20 + 1}',
//             quantity: 1 + (j % 5),
//             unitPrice: 50.0 + (j * 10.0),
//             subtotal: (1 + (j % 5)) * (50.0 + (j * 10.0)),
//           ),
//         );
//       }

//       _orderHeaders.add(order);
//       _expandedOrders[order.orderId] = false;
//     }

//     _totalItems = _orderHeaders.length;
//   }

//   // 更新显示数据（包括分页、排序、展开状态）
//   void _updateDisplayData() {
//     // 1. 对头行进行排序
//     List<OrderHeader> sortedHeaders = List.from(_orderHeaders);

//     sortedHeaders.sort((a, b) {
//       int comparison = 0;
//       switch (_sortColumn) {
//         case 'orderId':
//           comparison = a.orderId.compareTo(b.orderId);
//           break;
//         case 'customerName':
//           comparison = a.customerName.compareTo(b.customerName);
//           break;
//         case 'customerName1':
//           comparison = a.customerName1.compareTo(b.customerName1);
//           break;
//         case 'customerName2':
//           comparison = a.customerName2.compareTo(b.customerName2);
//           break;
//         case 'orderDate':
//           comparison = a.orderDate.compareTo(b.orderDate);
//           break;
//         case 'totalAmount':
//           comparison = a.totalAmount.compareTo(b.totalAmount);
//           break;
//         case 'status':
//           comparison = a.status.compareTo(b.status);
//           break;
//       }

//       return _sortAscending ? comparison : -comparison;
//     });

//     // 2. 应用分页（只对头行分页）
//     final startIndex = (_currentPage - 1) * _pageSize;
//     final endIndex = startIndex + _pageSize;
//     final paginatedHeaders = sortedHeaders.sublist(
//       startIndex.clamp(0, sortedHeaders.length),
//       endIndex.clamp(0, sortedHeaders.length),
//     );

//     // 3. 构建显示数据（明细始终跟随头行）
//     _orderDataList = [];

//     for (final header in paginatedHeaders) {
//       // 添加头行
//       _orderDataList.add(OrderData(orderHeader: header, isHeader: true));

//       // 如果展开，添加明细行
//       if (_expandedOrders[header.orderId] == true) {
//         for (final detail in header.details) {
//           _orderDataList.add(
//             OrderData(
//               orderHeader: header,
//               orderDetail: detail,
//               isHeader: false,
//             ),
//           );
//         }
//       }
//     }

//     // 4. 更新数据源
//     _dataSource?.updateData(_orderDataList, _expandedOrders, _selectAll);
//     setState(() {});
//   }

//   // 切换订单展开状态
//   void _toggleOrderExpansion(String orderId) {
//     setState(() {
//       _expandedOrders[orderId] = !(_expandedOrders[orderId] ?? false);
//       _updateDisplayData();
//     });
//   }

//   // 处理排序 - 只排序头行
//   void _handleSort(String columnName) {
//     setState(() {
//       if (_sortColumn == columnName) {
//         _sortAscending = !_sortAscending;
//       } else {
//         _sortColumn = columnName;
//         _sortAscending = true;
//       }
//       _currentPage = 1; // 排序后回到第一页
//       _updateDisplayData();
//     });
//   }

//   // 切换页码
//   void _goToPage(int page) {
//     setState(() {
//       _currentPage = page.clamp(1, _totalPages);
//       _updateDisplayData();
//     });
//   }

//   // 计算总页数（基于头行数量）
//   int get _totalPages => (_orderHeaders.length / _pageSize).ceil();

//   // 数据源实例
//   OrderDataSource? _dataSource;

//   // 处理全选/全不选
//   void _handleSelectAll(bool? value) {
//     setState(() {
//       _selectAll = value ?? false;

//       // 更新当前页所有头行的选中状态
//       for (var orderData in _orderDataList) {
//         if (orderData.isHeader) {
//           orderData.isSelected = _selectAll;
//         }
//       }

//       _dataSource?.updateData(_orderDataList, _expandedOrders, _selectAll);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('订单管理 - 主子表示例'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {
//                 _sortColumn = 'orderId';
//                 _sortAscending = true;
//                 _currentPage = 1;
//                 _updateDisplayData();
//               });
//             },
//             tooltip: '重置排序',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // 分页控件
//           _buildPaginationControls(),

//           // 全选复选框和表格容器
//           Expanded(
//             child: Column(
//               children: [
//                 // 全选复选框行
//                 Container(
//                   height: 50,
//                   color: Colors.grey[100],
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       Checkbox(
//                         value: _selectAll,
//                         onChanged: _handleSelectAll,
//                       ),
//                       const SizedBox(width: 8),
//                       const Text(
//                         '全选',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Text(
//                         '已选择: ${_getSelectedCount()} 项',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       const Spacer(),
//                       _buildActionButtons(),
//                     ],
//                   ),
//                 ),
//                 const Divider(height: 1),

//                 // 数据表格
//                 Expanded(
//                   child: SfDataGrid(
//                     source: _dataSource ??= OrderDataSource(
//                       orderDataList: _orderDataList,
//                       onExpandPressed: _toggleOrderExpansion,
//                       expandedOrders: _expandedOrders,
//                       onSelectionChanged: (orderData) {
//                         // 处理行选中状态变化
//                         _updateSelectAllState();
//                       },
//                     ),
//                     controller: _dataGridController,
//                     columns: _buildColumns(),
//                     columnWidthMode: ColumnWidthMode.fill,
//                     gridLinesVisibility: GridLinesVisibility.both,
//                     headerGridLinesVisibility: GridLinesVisibility.both,
//                     allowSorting: false, // 禁用DataGrid内置排序
//                     allowMultiColumnSorting: false,
//                     onCellTap: (details) {
//                       // 处理点击事件
//                       final rowIndex = details.rowColumnIndex.rowIndex - 1;
//                       if (rowIndex >= 0 && rowIndex < _orderDataList.length) {
//                         final orderData = _orderDataList[rowIndex];

//                         // 如果是扩展按钮列
//                         if (details.rowColumnIndex.columnIndex == 0 &&
//                             orderData.isHeader) {
//                           _toggleOrderExpansion(orderData.orderHeader.orderId);
//                         }
//                         // 如果是复选框列
//                         else if (details.rowColumnIndex.columnIndex == 1 &&
//                             orderData.isHeader) {
//                           // 切换选中状态
//                           setState(() {
//                             orderData.isSelected = !orderData.isSelected;
//                             _updateSelectAllState();
//                             _dataSource?.notifyListeners();
//                           });
//                         }
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // 底部信息
//           Container(
//             padding: const EdgeInsets.all(8.0),
//             color: Colors.grey[100],
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('总计: ${_orderHeaders.length} 个订单'),
//                 Text(
//                   '当前显示: ${_orderDataList.where((item) => item.isHeader).length} 个头行',
//                 ),
//                 Chip(
//                   label: Text(
//                     '排序: $_sortColumn ${_sortAscending ? '↑' : '↓'}',
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                   backgroundColor: Colors.blue[50],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 获取选中数量
//   int _getSelectedCount() {
//     return _orderDataList
//         .where((item) => item.isHeader && item.isSelected)
//         .length;
//   }

//   // 更新全选状态
//   void _updateSelectAllState() {
//     final headerItems = _orderDataList.where((item) => item.isHeader).toList();
//     if (headerItems.isEmpty) {
//       setState(() {
//         _selectAll = false;
//       });
//       return;
//     }

//     final allSelected = headerItems.every((item) => item.isSelected);
//     final anySelected = headerItems.any((item) => item.isSelected);

//     setState(() {
//       _selectAll = allSelected;
//     });
//   }

//   // 构建操作按钮
//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         ElevatedButton.icon(
//           onPressed: _getSelectedCount() > 0
//               ? () {
//                   // 导出选中项
//                   _exportSelected();
//                 }
//               : null,
//           icon: const Icon(Icons.download, size: 18),
//           label: const Text('导出选中'),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//         ),
//         const SizedBox(width: 12),
//         ElevatedButton.icon(
//           onPressed: _getSelectedCount() > 0
//               ? () {
//                   // 批量操作
//                   _batchOperation();
//                 }
//               : null,
//           icon: const Icon(Icons.playlist_add_check, size: 18),
//           label: const Text('批量处理'),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//         ),
//       ],
//     );
//   }

//   void _exportSelected() {
//     // 导出选中的数据
//     final selectedItems = _orderDataList
//         .where((item) => item.isHeader && item.isSelected)
//         .toList();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('导出确认'),
//         content: Text('确定要导出 ${selectedItems.length} 个选中的订单吗？'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               // 执行导出操作
//               Navigator.pop(context);
//               _performExport(selectedItems);
//             },
//             child: const Text('确定'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _batchOperation() {
//     // 批量操作
//     final selectedItems = _orderDataList
//         .where((item) => item.isHeader && item.isSelected)
//         .toList();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('批量操作'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('已选择 ${selectedItems.length} 个订单'),
//             const SizedBox(height: 16),
//             const Text('请选择要执行的操作：'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               // 批量标记为已发货
//               _markAsShipped(selectedItems);
//               Navigator.pop(context);
//             },
//             child: const Text('标记为已发货'),
//           ),
//           TextButton(
//             onPressed: () {
//               // 批量删除
//               _batchDelete(selectedItems);
//               Navigator.pop(context);
//             },
//             child: const Text('批量删除'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _performExport(List<OrderData> selectedItems) {
//     // 这里实现导出逻辑
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('成功导出 ${selectedItems.length} 个订单'),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _markAsShipped(List<OrderData> selectedItems) {
//     // 标记为已发货
//     for (var orderData in selectedItems) {
//       orderData.orderHeader.status = 'Shipped';
//     }
//     _updateDisplayData();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('已标记 ${selectedItems.length} 个订单为已发货'),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _batchDelete(List<OrderData> selectedItems) {
//     // 批量删除
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('确认删除'),
//         content: Text('确定要删除 ${selectedItems.length} 个选中的订单吗？此操作不可恢复。'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               // 执行删除操作
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('已删除 ${selectedItems.length} 个订单'),
//                   duration: const Duration(seconds: 2),
//                 ),
//               );
//             },
//             child: const Text('删除', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   // 构建列定义
//   List<GridColumn> _buildColumns() {
//     return [
//       GridColumn(
//         columnName: 'expand',
//         width: 60,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: const Text(
//             '操作',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'checkbox',
//         width: 60,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: const Text(
//             '选择',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'orderId',
//         width: 120,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: InkWell(
//             onTap: () => _handleSort('orderId'),
//             child: Row(
//               children: [
//                 const Text(
//                   '订单号',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 4),
//                 if (_sortColumn == 'orderId')
//                   Icon(
//                     _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                     size: 16,
//                     color: Colors.blue,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'customerName',
//         width: 150,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: InkWell(
//             onTap: () => _handleSort('customerName'),
//             child: Row(
//               children: [
//                 const Text(
//                   '客户名称',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 4),
//                 if (_sortColumn == 'customerName')
//                   Icon(
//                     _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                     size: 16,
//                     color: Colors.blue,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'customerName1',
//         width: 150,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: InkWell(
//             onTap: () => _handleSort('customerName1'),
//             child: Row(
//               children: [
//                 const Text(
//                   '客户名称1',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 4),
//                 if (_sortColumn == 'customerName1')
//                   Icon(
//                     _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                     size: 16,
//                     color: Colors.blue,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'customerName2',
//         width: 150,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: InkWell(
//             onTap: () => _handleSort('customerName2'),
//             child: Row(
//               children: [
//                 const Text(
//                   '客户名称2',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 4),
//                 if (_sortColumn == 'customerName2')
//                   Icon(
//                     _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                     size: 16,
//                     color: Colors.blue,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'productName',
//         width: 180,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: const Text(
//             '产品名称',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'quantity',
//         width: 80,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: const Text(
//             '数量',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'unitPrice',
//         width: 100,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: const Text(
//             '单价',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'subtotal',
//         width: 100,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: const Text(
//             '小计',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'orderDate',
//         width: 120,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: InkWell(
//             onTap: () => _handleSort('orderDate'),
//             child: Row(
//               children: [
//                 const Text(
//                   '订单日期',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 4),
//                 if (_sortColumn == 'orderDate')
//                   Icon(
//                     _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                     size: 16,
//                     color: Colors.blue,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'totalAmount',
//         width: 120,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: InkWell(
//             onTap: () => _handleSort('totalAmount'),
//             child: Row(
//               children: [
//                 const Text(
//                   '总金额',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 4),
//                 if (_sortColumn == 'totalAmount')
//                   Icon(
//                     _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                     size: 16,
//                     color: Colors.blue,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       GridColumn(
//         columnName: 'status',
//         width: 100,
//         label: Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: Alignment.center,
//           child: InkWell(
//             onTap: () => _handleSort('status'),
//             child: Row(
//               children: [
//                 const Text('状态', style: TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 4),
//                 if (_sortColumn == 'status')
//                   Icon(
//                     _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                     size: 16,
//                     color: Colors.blue,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ];
//   }

//   // 构建分页控件
//   Widget _buildPaginationControls() {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       color: Colors.grey[50],
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.first_page),
//             onPressed: _currentPage == 1 ? null : () => _goToPage(1),
//             tooltip: '第一页',
//           ),
//           IconButton(
//             icon: const Icon(Icons.chevron_left),
//             onPressed:
//                 _currentPage == 1 ? null : () => _goToPage(_currentPage - 1),
//             tooltip: '上一页',
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               '第 $_currentPage 页 / 共 $_totalPages 页',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.chevron_right),
//             onPressed: _currentPage == _totalPages
//                 ? null
//                 : () => _goToPage(_currentPage + 1),
//             tooltip: '下一页',
//           ),
//           IconButton(
//             icon: const Icon(Icons.last_page),
//             onPressed: _currentPage == _totalPages
//                 ? null
//                 : () => _goToPage(_totalPages),
//             tooltip: '最后一页',
//           ),
//           const SizedBox(width: 20),
//           Text(
//             '每页 $_pageSize 条头行，共 ${_orderHeaders.length} 个订单',
//             style: const TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // DataGrid数据源
// class OrderDataSource extends DataGridSource {
//   OrderDataSource({
//     required List<OrderData> orderDataList,
//     required Function(String) onExpandPressed,
//     required Map<String, bool> expandedOrders,
//     this.onSelectionChanged,
//   }) {
//     _orderDataList = orderDataList;
//     _onExpandPressed = onExpandPressed;
//     _expandedOrders = expandedOrders;
//     buildDataGridRows();
//   }

//   late List<OrderData> _orderDataList;
//   late Function(String) _onExpandPressed;
//   late Map<String, bool> _expandedOrders;
//   final Function(OrderData)? onSelectionChanged;

//   List<DataGridRow> _dataGridRows = [];

//   void buildDataGridRows() {
//     _dataGridRows = _orderDataList.map<DataGridRow>((orderData) {
//       final header = orderData.orderHeader;
//       final detail = orderData.orderDetail;
//       final isExpanded = _expandedOrders[header.orderId] ?? false;

//       return DataGridRow(
//         cells: [
//           // 扩展按钮列
//           DataGridCell<Widget>(
//             columnName: 'expand',
//             value: orderData.isHeader
//                 ? IconButton(
//                     icon: Icon(
//                       isExpanded ? Icons.expand_less : Icons.expand_more,
//                       color: Colors.blue,
//                     ),
//                     onPressed: () => _onExpandPressed(header.orderId),
//                     padding: EdgeInsets.zero,
//                     iconSize: 20,
//                   )
//                 : Container(
//                     width: 40,
//                     height: 40,
//                     alignment: Alignment.center,
//                     child: const Icon(
//                       Icons.arrow_right,
//                       size: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//           ),

//           // 复选框列（只对头行显示）
//           DataGridCell<Widget>(
//             columnName: 'checkbox',
//             value: orderData.isHeader
//                 ? Checkbox(
//                     value: orderData.isSelected,
//                     onChanged: (bool? value) {
//                       orderData.isSelected = value ?? false;
//                       onSelectionChanged?.call(orderData);
//                       notifyListeners();
//                     },
//                   )
//                 : Container(
//                     width: 40,
//                     height: 40,
//                   ), // 明细行留空
//           ),

//           // 订单号
//           DataGridCell<String>(
//             columnName: 'orderId',
//             value: orderData.isHeader ? header.orderId : '',
//           ),

//           // 客户名称
//           DataGridCell<String>(
//             columnName: 'customerName',
//             value: orderData.isHeader ? header.customerName : '',
//           ),

//           // 客户名称1
//           DataGridCell<String>(
//             columnName: 'customerName1',
//             value: orderData.isHeader ? header.customerName1 : '',
//           ),

//           // 客户名称2
//           DataGridCell<String>(
//             columnName: 'customerName2',
//             value: orderData.isHeader ? header.customerName2 : '',
//           ),

//           // 产品名称
//           DataGridCell<String>(
//             columnName: 'productName',
//             value: orderData.isHeader
//                 ? '订单总计 (${header.details.length} 个产品)'
//                 : detail!.productName,
//           ),

//           // 数量
//           DataGridCell<String>(
//             columnName: 'quantity',
//             value: orderData.isHeader
//                 ? header.details
//                     .fold(0, (sum, item) => sum + item.quantity)
//                     .toString()
//                 : detail!.quantity.toString(),
//           ),

//           // 单价
//           DataGridCell<String>(
//             columnName: 'unitPrice',
//             value: orderData.isHeader
//                 ? ''
//                 : '\$${detail!.unitPrice.toStringAsFixed(2)}',
//           ),

//           // 小计
//           DataGridCell<String>(
//             columnName: 'subtotal',
//             value: orderData.isHeader
//                 ? ''
//                 : '\$${detail!.subtotal.toStringAsFixed(2)}',
//           ),

//           // 订单日期
//           DataGridCell<String>(
//             columnName: 'orderDate',
//             value: orderData.isHeader
//                 ? DateFormat('yyyy-MM-dd').format(header.orderDate)
//                 : '',
//           ),

//           // 总金额
//           DataGridCell<String>(
//             columnName: 'totalAmount',
//             value: orderData.isHeader
//                 ? '\$${header.totalAmount.toStringAsFixed(2)}'
//                 : '',
//           ),

//           // 状态
//           DataGridCell<Widget>(
//             columnName: 'status',
//             value: orderData.isHeader
//                 ? Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(header.status),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       header.status,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   )
//                 : Container(),
//           ),
//         ],
//       );
//     }).toList();
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.orange;
//       case 'shipped':
//         return Colors.blue;
//       case 'delivered':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   List<DataGridRow> get rows => _dataGridRows;

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     final rowIndex = rows.indexOf(row);
//     final orderData = _orderDataList[rowIndex];

//     Color backgroundColor = orderData.isHeader
//         ? orderData.isSelected
//             ? Colors.blue[100]!
//             : Colors.blue[50]!
//         : Colors.grey[50]!;

//     Border? border;
//     if (orderData.isHeader) {
//       border = Border(
//         bottom: BorderSide(
//           color: orderData.isSelected ? Colors.blue : Colors.blue,
//           width: 1,
//         ),
//       );
//     }

//     return DataGridRowAdapter(
//       color: backgroundColor,
//       cells: row.getCells().map<Widget>((dataGridCell) {
//         final cellValue = dataGridCell.value;
//         final columnName = dataGridCell.columnName;

//         if (cellValue is Widget) {
//           return Container(
//             padding: const EdgeInsets.all(8.0),
//             alignment: Alignment.center,
//             decoration: BoxDecoration(border: border),
//             child: cellValue,
//           );
//         }

//         return Container(
//           padding: const EdgeInsets.all(8.0),
//           alignment: _getAlignment(columnName),
//           decoration: BoxDecoration(border: border),
//           child: Text(
//             cellValue?.toString() ?? '',
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontWeight:
//                   orderData.isHeader ? FontWeight.bold : FontWeight.normal,
//               color: orderData.isHeader ? Colors.blue[800] : Colors.grey[700],
//               fontSize: orderData.isHeader ? 13 : 12,
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Alignment _getAlignment(String columnName) {
//     switch (columnName) {
//       case 'quantity':
//       case 'unitPrice':
//       case 'subtotal':
//       case 'totalAmount':
//         return Alignment.centerRight;
//       case 'expand':
//       case 'checkbox':
//         return Alignment.center;
//       default:
//         return Alignment.centerLeft;
//     }
//   }

//   // 更新数据
//   void updateData(List<OrderData> newData, Map<String, bool> expandedOrders,
//       bool selectAll) {
//     _orderDataList = newData;
//     _expandedOrders = expandedOrders;

//     // 如果selectAll为true，更新所有头行的选中状态
//     if (selectAll) {
//       for (var orderData in _orderDataList) {
//         if (orderData.isHeader) {
//           orderData.isSelected = true;
//         }
//       }
//     }

//     buildDataGridRows();
//     notifyListeners();
//   }
// }
