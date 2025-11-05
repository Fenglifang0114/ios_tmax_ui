// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:path/path.dart' as p;
// import 'package:t_max/data/barcoderowdata.dart';
// import 'package:t_max/data/home_page_common_data.dart';
// import 'package:t_max/data/icons.dart';
// import 'package:t_max/data/language.dart';
// import 'package:t_max/dialog/custom_dialog_tip.dart';
// import 'package:t_max/widget/common_widget.dart';
// import 'package:t_max/widget/custom_button.dart';
// import 'package:t_max/widget/dialog_head_style.dart';
// import 'package:t_max/widget/rowdatawidget.dart';

// class MyBarCodeDialog extends StatefulWidget {
//   const MyBarCodeDialog({super.key});
//   @override
//   MyBarCodeDialogState createState() => MyBarCodeDialogState();
// }

// class MyBarCodeDialogState extends State<MyBarCodeDialog> {
//   final TextEditingController _searchController = TextEditingController();
//   List<BarCodeRowDataInfo> _displayedData = [];
//   final List<BarCodeRowDataInfo> _originalData = [];
//   final ScrollController _scrollController = ScrollController();

//   // 列宽定义
//   final Map<String, double> _columnWidths = {
//     'barCodeName': 150,
//     'barCodeType': 150,
//     'type': 120,
//     'content': 100,
//     'defaultValue': 118,
//     'alignment': 120,
//     'maxLength': 110,
//     'operations': 170,
//   };

//   double get _totalWidth => _columnWidths.values.reduce((a, b) => a + b);

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   void _initializeData() {
//     _originalData.clear();
//     _originalData.addAll(myBarCodeListList.barCodeListList);
//     _displayedData = List.from(_originalData);
//   }

//   void _handleExpandChanged(int index) {
//     if (index < 0) return;

//     setState(() {
//       if (index < _displayedData.length) {
//         final item = _displayedData[index];
//         item.isExpand = !(item.isExpand ?? false);
//       }
//     });
//   }

//   void _performSearch(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _displayedData = List.from(_originalData);
//       } else {
//         _displayedData = _originalData.where((item) {
//           return item.barCodeName.toLowerCase().contains(query.toLowerCase()) ||
//               item.barCodeType.toLowerCase().contains(query.toLowerCase()) ||
//               _containsInRowData(item, query);
//         }).toList();
//       }
//     });
//   }

//   bool _containsInRowData(BarCodeRowDataInfo item, String query) {
//     return item.barCodeRowDataList.any((rowData) =>
//         rowData.type.toLowerCase().contains(query.toLowerCase()) ||
//         rowData.content.toLowerCase().contains(query.toLowerCase()));
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.all(40),
//       child: Container(
//         width: 1080,
//         height: 680,
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 20,
//               color: Colors.black.withOpacity(0.2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // 头部
//             ...dialogHeadStyle(
//               context,
//               localizedStrings.gBarcodeMgr,
//               true,
//               onClose: () => Navigator.pop(context),
//             ),

//             // 内容区域
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(largePadding),
//                 child: Column(
//                   children: [
//                     // 搜索和操作区域
//                     _buildActionArea(theme, colorScheme),

//                     const SizedBox(height: largePadding),

//                     // 数据表格区域
//                     Expanded(
//                       child: _displayedData.isEmpty
//                           ? _buildEmptyState(theme)
//                           : _buildDataTableWithFixedHeader(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionArea(ThemeData theme, ColorScheme colorScheme) {
//     return Container(
//       height: 68,
//       child: Row(
//         children: [
//           // 搜索框
//           Expanded(
//             child: SizedBox(
//               height: btnHeight,
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: _performSearch,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(
//                     Icons.search,
//                     color: colorScheme.primary,
//                     size: 20,
//                   ),
//                   suffixIcon: _searchController.text.isNotEmpty
//                       ? IconButton(
//                           icon: const Icon(Icons.clear, size: 18),
//                           onPressed: () {
//                             _searchController.clear();
//                             _performSearch('');
//                           },
//                         )
//                       : null,
//                   hintText: "",
//                   hintStyle: theme.textTheme.bodyMedium?.copyWith(
//                     color: colorScheme.onSurface.withOpacity(0.6),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   border: const OutlineInputBorder(
//                     borderRadius: BorderRadius.zero,
//                     borderSide: BorderSide(color: Colors.grey),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.zero,
//                     borderSide:
//                         BorderSide(color: colorScheme.primary, width: 2),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(width: largePadding),

//           // 操作按钮
//           _buildActionButtons(theme, colorScheme),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
//     return Row(
//       children: [
//         // 清空按钮
//         showTextButton(
//           context,
//           btnHeight,
//           localizedStrings.fClearBtn,
//           _showClearConfirmationDialog,
//           colorScheme.onPrimary,
//           colorScheme.error,
//           colorScheme.onError,
//         ),

//         const SizedBox(width: largePadding),

//         // 添加按钮
//         showTextButton(
//           context,
//           btnHeight,
//           localizedStrings.gBtnAdd,
//           _showAddBarCodeDialog,
//           colorScheme.onPrimary,
//           colorScheme.primary,
//           colorScheme.onPrimary,
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState(ThemeData theme) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           getSvgIcon(barcodeSvgIcon(), 80, 60,
//               theme.colorScheme.onSurface.withOpacity(0.3)),
//           const SizedBox(height: 16),
//           Text(
//             "暂无条码数据", //需要翻译

//             style: theme.textTheme.headlineSmall?.copyWith(
//               color: theme.colorScheme.onSurface.withOpacity(0.5),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "点击添加按钮创建新的条码",
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: theme.colorScheme.onSurface.withOpacity(0.4),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _showAddBarCodeDialog,
//             icon: const Icon(Icons.add),
//             label: const Text("添加条码"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDataTableWithFixedHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         border:
//             Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           // 固定表头
//           _buildTableHeader(),

//           // 可滚动的内容区域
//           Expanded(
//             child: SingleChildScrollView(
//               controller: _scrollController,
//               scrollDirection: Axis.vertical,
//               child: Container(
//                 width: _totalWidth,
//                 child: Column(
//                   children: [
//                     for (int index = 0; index < _displayedData.length; index++)
//                       _buildMainDataRow(_displayedData[index], index),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTableHeader() {
//     return Container(
//       height: 48,
//       color: Colors.blue[50],
//       child: Row(
//         children: [
//           _buildHeaderCell(
//               localizedStrings.gBarcodeName, _columnWidths['barCodeName']!),
//           _buildHeaderCell(
//               localizedStrings.gBarcodeType, _columnWidths['barCodeType']!),
//           _buildHeaderCell(
//               localizedStrings.gBarCodeDataType, _columnWidths['type']!),
//           _buildHeaderCell(
//               localizedStrings.gBarCodeContent, _columnWidths['content']!),
//           _buildHeaderCell(localizedStrings.gBarCodeDefValue,
//               _columnWidths['defaultValue']!),
//           _buildHeaderCell(
//               localizedStrings.gBarCodeAlignment, _columnWidths['alignment']!),
//           _buildHeaderCell(
//               localizedStrings.gBarCodeMaxLength, _columnWidths['maxLength']!),
//           _buildHeaderCell(
//               localizedStrings.fTipOperation, _columnWidths['operations']!),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderCell(String text, double width) {
//     return Container(
//       width: width,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//       alignment: Alignment.centerLeft,
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 13,
//         ),
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }

//   Widget _buildMainDataRow(BarCodeRowDataInfo item, int index) {
//     return Column(
//       children: [
//         // 主数据行
//         Container(
//           height: 56,
//           decoration: BoxDecoration(
//             color: index.isEven ? Colors.white : Colors.grey[50],
//             border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
//           ),
//           child: Row(
//             children: [
//               // 条码名称
//               _buildDataCell(item.barCodeName, _columnWidths['barCodeName']!),

//               // 条码类型
//               _buildDataCell(item.barCodeType, _columnWidths['barCodeType']!),

//               _buildDataCell('', _columnWidths['type']!),

//               _buildDataCell('', _columnWidths['content']!),

//               _buildDataCell('', _columnWidths['defaultValue']!),

//               _buildDataCell('', _columnWidths['alignment']!),

//               Container(
//                 width: _columnWidths['maxLength']!,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 alignment: Alignment.center,
//                 child: Text(
//                   '',
//                   style: const TextStyle(fontSize: 13),
//                 ),
//               ),

//               // 展开/收起按钮
//               Container(
//                   width: _columnWidths['operations']!,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   alignment: Alignment.center,
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit_outlined, size: 18),
//                         onPressed: () {
//                           _showEditBarCodeDialog(
//                               item.barCodeName, item.barCodeType);
//                         },
//                         color: Colors.blue,
//                         padding: EdgeInsets.zero,
//                         tooltip: localizedStrings.gBtnEdit,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete_outline, size: 18),
//                         onPressed: () {
//                           showDeleteWidget(item);
//                         },
//                         color: Colors.red,
//                         padding: EdgeInsets.zero,
//                         tooltip: localizedStrings.gBtnDelete,
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           item.isExpand ?? false
//                               ? Icons.expand_less
//                               : Icons.expand_more,
//                           color: Colors.blue[600],
//                           size: 20,
//                         ),
//                         onPressed: () => _handleExpandChanged(index),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(
//                           minWidth: 32,
//                           minHeight: 32,
//                         ),
//                       ),
//                     ],
//                   )),
//             ],
//           ),
//         ),

//         // 展开的明细行
//         if (item.isExpand ?? false) _buildDetailRows(item, index),
//       ],
//     );
//   }

//   dynamic showDeleteWidget(BarCodeRowDataInfo item) {
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return ShowDeleteTipDialog(
//               title: localizedStrings.fTipTitle,
//               msg: localizedStrings.fConfirmDelete);
//         }).then((value) {
//       if (value == true) {
//         // 确认删除，执行删除操作
//         for (int i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
//           if (myBarCodeListList.barCodeListList[i].barCodeName ==
//               item.barCodeName) {
//             myBarCodeListList.barCodeListList.removeAt(i);
//             break;
//           }
//         }
//         setState(() {
//           _initializeData();
//         });
//       }
//     });
//   }

//   Widget _buildDataCell(String text, double width) {
//     return Container(
//       width: width,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       alignment: Alignment.centerLeft,
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 13),
//         overflow: TextOverflow.ellipsis,
//         maxLines: 1,
//       ),
//     );
//   }

//   Widget _buildDetailRows(BarCodeRowDataInfo item, int parentIndex) {
//     if (item.barCodeRowDataList.isEmpty) {
//       return Container(
//         height: 40,
//         color: Colors.grey[100],
//         child: Center(
//           child: Text(
//             "暂无明细数据",
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 13,
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: item.barCodeRowDataList.asMap().entries.map((entry) {
//         final detailIndex = entry.key;
//         final detail = entry.value;

//         return Container(
//           height: 40,
//           decoration: BoxDecoration(
//             color: (parentIndex + detailIndex + 1).isEven
//                 ? Colors.white
//                 : Colors.grey[50],
//             border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
//           ),
//           child: Row(
//             children: [
//               // 条码名称（明细行留空）
//               _buildDetailCell("", _columnWidths['barCodeName']!),

//               // 条码类型（明细行留空）
//               _buildDetailCell("", _columnWidths['barCodeType']!),

//               // 类型
//               _buildDetailCell(detail.type, _columnWidths['type']!),

//               // 内容
//               _buildDetailCell(detail.content, _columnWidths['content']!),

//               // 默认值
//               _buildDetailCell(
//                   detail.defaultvalue, _columnWidths['defaultValue']!),

//               // 对齐方式
//               _buildDetailCell(detail.alignment, _columnWidths['alignment']!),

//               // 最大长度
//               Container(
//                 width: _columnWidths['maxLength']!,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 alignment: Alignment.center,
//                 child: Text(
//                   detail.maxlength.toString(),
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),

//               // 删除按钮
//               Container(
//                 width: _columnWidths['operations']!,
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 alignment: Alignment.center,
//                 child: SizedBox(),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildDetailCell(String text, double width) {
//     return Container(
//       width: width,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       alignment: Alignment.centerLeft,
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 12),
//         overflow: TextOverflow.ellipsis,
//         maxLines: 1,
//       ),
//     );
//   }

//   void _deleteDetailItem(BarCodeRowDataInfo item, int detailIndex) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("确认删除"),
//         content: const Text("确定要删除这条明细数据吗？"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("取消"),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 if (detailIndex < item.barCodeRowDataList.length) {
//                   item.barCodeRowDataList.removeAt(detailIndex);
//                 }
//               });
//               Navigator.pop(context);
//             },
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.red,
//             ),
//             child: const Text("删除"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showClearConfirmationDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("确认清空"),
//         content: const Text("确定要清空所有条码数据吗？此操作不可撤销。"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("取消"),
//           ),
//           TextButton(
//             onPressed: () {
//               _clearAllData();
//               Navigator.pop(context);
//             },
//             style: TextButton.styleFrom(
//               foregroundColor: Theme.of(context).colorScheme.error,
//             ),
//             child: const Text("确定"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _clearAllData() {
//     setState(() {
//       myBarCodeListList.barCodeListList.clear();
//       _originalData.clear();
//       _displayedData.clear();
//       _searchController.clear();
//     });
//   }

//   void _showAddBarCodeDialog() {
//     // TODO: 实现添加条码对话框
//     showDialog(
//       context: context,
//       builder: (context) =>
//           AddBarCodeDialog(selBarcodeName: "111", selBarcodeType: "Code128"),
//     );
//   }

//   void _showEditBarCodeDialog(String barcodeName, String barcodeType) {
//     // TODO: 实现添加条码对话框
//     showDialog(
//       context: context,
//       builder: (context) => AddBarCodeDialog(
//         selBarcodeName: barcodeName,
//         selBarcodeType: barcodeType,
//       ),
//     );
//   }
// }

// class AddBarCodeDialog extends StatefulWidget {
//   const AddBarCodeDialog({
//     super.key,
//     required this.selBarcodeName,
//     required this.selBarcodeType,
//   });
//   final String selBarcodeName;
//   final String selBarcodeType;
//   @override
//   AddBarCodeDialogState createState() => AddBarCodeDialogState();
// }

// class AddBarCodeDialogState extends State<AddBarCodeDialog> {
//   late TextEditingController _errorController;
//   late TextEditingController _barCodeNameController;
//   late TextEditingController _selectBarcode = TextEditingController(text: '--');

//   String _selectedBarcodeName = '--';

//   final List<String> _barCodeTypes = [
//     'Code128',
//     'Code39',
//     'EAN13',
//     'EAN8',
//     'UPC-A',
//     'UPC-E',
//     // 'TTF',
//   ];
//   @override
//   void initState() {
//     _errorController = TextEditingController(text: '');
//     _barCodeNameController = TextEditingController(text: '');
//     _selectBarcode.text = widget.selBarcodeType;
//     _onSuggestionSelected(widget.selBarcodeName);

//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.all(40),
//       child: Container(
//         width: 1080,
//         height: 680,
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 20,
//               color: Colors.black.withOpacity(0.2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // 头部
//             ...dialogHeadStyle(
//               context,
//               localizedStrings.gBarcodeEdit,
//               true,
//               onClose: () => Navigator.pop(context),
//             ),

//             // 内容区域
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(largePadding),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: 40,
//                       width: double.infinity,
//                       child: Row(
//                         children: [
//                           Text(
//                             localizedStrings.gBarcodeType,
//                             style: TextStyle(
//                                 fontSize: 14, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(
//                             width: 20,
//                           ),
//                           Expanded(
//                               child: showDropDownButton(context, '',
//                                   _selectBarcode, _barCodeTypes, (value) {})),
//                           const SizedBox(
//                             width: 20,
//                           ),
//                           SizedBox(
//                             child: Text(
//                               localizedStrings.gBarcodeName,
//                               textAlign: TextAlign.right,
//                               style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   overflow: TextOverflow.ellipsis),
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 20,
//                           ),
//                           Expanded(
//                             child: showInputBox(context, _barCodeNameController,
//                                 '', (value) {}, true),
//                           ),
//                           const SizedBox(
//                             width: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 10),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           const SizedBox(
//                             width: 30,
//                           ),
//                           const SizedBox(
//                             width: 30,
//                           ),
//                           CustomOutlinedButton(
//                               btnWidth: 150,
//                               btnHeight: 40,
//                               icon: Icons.add,
//                               text: localizedStrings.gBtnAdd,
//                               onPressed: _addRowData),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           CustomElevatedButton(
//                               btnWidth: 150,
//                               btnHeight: 40,
//                               icon: Icons.save,
//                               text: localizedStrings.gBtnSave,
//                               onPressed: _saveRowData),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           CustomOutlinedButton(
//                               btnWidth: 150,
//                               btnHeight: 40,
//                               icon: Icons.delete,
//                               text: localizedStrings.gBtnDelete,
//                               onPressed: _deleteRowData),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                         mainAxisSize: MainAxisSize.max,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(localizedStrings.gBarCodeDataType,
//                               style: TextStyle(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold)),
//                           Text(localizedStrings.gBarCodeContent,
//                               style: TextStyle(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold)),
//                           Text(localizedStrings.gBarCodeDefValue,
//                               style: TextStyle(
//                                 color: Theme.of(context).colorScheme.primary,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               )),
//                           Text(localizedStrings.gBarCodeAlignment,
//                               style: TextStyle(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold)),
//                           Text(localizedStrings.gBarCodeMaxLength,
//                               style: TextStyle(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold)),
//                           Text(localizedStrings.gBarCodeDelete,
//                               style: TextStyle(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold)),
//                         ]),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount:
//                             myBarCodeRowDataList.barCodeRowDataList.length,
//                         itemBuilder: (context, index) {
//                           return RowDataWidget(
//                             rowData:
//                                 myBarCodeRowDataList.barCodeRowDataList[index],
//                             rowDataList:
//                                 myBarCodeRowDataList.barCodeRowDataList,
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<String> _getTempBarcodeName() {
//     List<String> tempList = [];
//     tempList.add('--');
//     for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
//       if (myBarCodeListList.barCodeListList[i].barCodeType == _selectBarcode) {
//         tempList.add(myBarCodeListList.barCodeListList[i].barCodeName);
//       }
//     }
//     return tempList;
//   }

//   //获取建议列表
//   Future<List<String>> suggestionsCallback(String pattern) async =>
//       Future<List<String>>.delayed(
//         Duration(milliseconds: 0),
//         () => mySavedBarcodeName.savedBarcodeName.where((option) {
//           final optionLower = option.toLowerCase();
//           final patternLower = pattern.toLowerCase();
//           return optionLower.contains(patternLower) &&
//               _getTempBarcodeName().contains(option);
//         }).toList(),
//       );

// // 选择建议项时的处理
//   void _onSuggestionSelected(String suggestion) {
//     setState(() {
//       _errorController.text = '';
//       _selectedBarcodeName = suggestion;
//       _barCodeNameController.text = suggestion;

//       if (suggestion != '--') {
//         for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
//           var barcode = myBarCodeListList.barCodeListList[i];

//           if (barcode.barCodeName == _selectedBarcodeName &&
//               barcode.barCodeType != 'Qrcode' &&
//               barcode.barCodeType == _selectBarcode.text) {
//             _selectBarcode.text = barcode.barCodeType;
//             _saveDataList(i);

//             break;
//           }
//         }
//       } else {
//         myBarCodeRowDataList.barCodeRowDataList.clear();
//       }
//     });
//   }

//   Future<File> get _localFile async {
//     final directory = p.dirname(Platform.script.toFilePath());
//     return File(p.join(directory, 'barcodedata.json'));
//   }

//   _saveDataList(int i) {
//     String type = '';
//     String content = '';
//     String defaultvalue = '';
//     String alignment = '';
//     int maxlength = 0;
//     List<BarCodeRowData> tempRowDataList = [];
//     for (var j = 0;
//         j < myBarCodeListList.barCodeListList[i].barCodeRowDataList.length;
//         j++) {
//       alignment =
//           myBarCodeListList.barCodeListList[i].barCodeRowDataList[j].alignment;
//       content =
//           myBarCodeListList.barCodeListList[i].barCodeRowDataList[j].content;
//       defaultvalue = myBarCodeListList
//           .barCodeListList[i].barCodeRowDataList[j].defaultvalue;
//       maxlength =
//           myBarCodeListList.barCodeListList[i].barCodeRowDataList[j].maxlength;
//       type = myBarCodeListList.barCodeListList[i].barCodeRowDataList[j].type;

//       tempRowDataList.add(
//           BarCodeRowData(type, content, defaultvalue, alignment, maxlength));
//     }
//     myBarCodeRowDataList.barCodeRowDataList = tempRowDataList;
//   }

//   _saveDataToJson() async {
//     if (myBarCodeListList.barCodeListList.isNotEmpty) {
//       String json = jsonEncode(myBarCodeListList.barCodeListList);
//       if (kDebugMode) {
//         print(json);
//       }
//       final file = await _localFile;
//       // 将字符串写入文件中
//       file.writeAsStringSync(json);

//       // await loadData();   此处已经写好了如何捞回来条码信息
//     }
//   }

//   _saveBarCodeNameToList() {
//     if (myBarCodeListList.barCodeListList.isNotEmpty) {
//       mySavedBarcodeName.savedBarcodeName.clear();
//       for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
//         if (myBarCodeListList.barCodeListList[i].barCodeType != 'Qrcode') {
//           mySavedBarcodeName.savedBarcodeName
//               .add(myBarCodeListList.barCodeListList[i].barCodeName);
//         }
//       }
//       mySavedBarcodeName.savedBarcodeName.add('--');
//     } else {
//       mySavedBarcodeName.savedBarcodeName.clear();
//     }
//   }

//   Future<Map<String, dynamic>?> loadData() async {
//     try {
//       final file = await _localFile;
//       // 从文件中读取字符串
//       String contents = await file.readAsString();
//       // 将字符串解码为JSON数据
//       pasterBarcodeList(contents);
//       // Map<String, dynamic> data = jsonDecode(contents);
//       // return data;
//     } catch (e) {
//       return null;
//     }
//     return null;
//   }

//   Future pasterBarcodeList(String jsonDataString) async {
//     String jsonStrings = jsonDataString;
//     final jsonResponse = json.decode(jsonStrings);
//     myBarCodeListList = BarCodeListList.fromJson(jsonResponse);
//   }

//   void _addRowData() {
//     if (_barCodeNameController.text != '--') {
//       setState(() {
//         myBarCodeRowDataList.barCodeRowDataList
//             .add(BarCodeRowData('TEXT', '', '', 'Left', 7));
//       });
//     } else {
//       _errorController.text =
//           'The barcode name is invalid. Please enter a valid name.';
//     }
//   }

//   bool _judgeData() {
//     bool res = true;

//     if (_barCodeNameController.text.isNotEmpty &&
//         myBarCodeRowDataList.barCodeRowDataList.isNotEmpty) {
//       for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
//         if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
//           if (myBarCodeRowDataList.barCodeRowDataList[i].content.isEmpty) {
//             _errorController.text = 'Content missing.';
//             res = false;
//           }
//         } else {
//           if (myBarCodeRowDataList.barCodeRowDataList[i].alignment == '--' ||
//               myBarCodeRowDataList.barCodeRowDataList[i].maxlength == 0) {
//             _errorController.text =
//                 'Variable alignment cannot be empty or have a length of 0. Please check';
//             res = false;
//           }
//         }
//       }
//     } else {
//       _errorController.text =
//           'Barcode name not entered or content is empty, please check!';
//       res = false;
//     }
//     return res;
//   }

// // 'Code128',
//   // 'Code39',
//   // 'EAN13',
//   // 'EAN8',
//   // 'UPC-A',
//   // 'UPC-E',
//   // 'TTF',
//   bool _barcodeTypeVerification() {
//     bool res = false;

//     switch (_selectBarcode.text) {
//       case 'Code128':
//         res = _code128Verification();
//         break;
//       case 'Code39':
//         res = _code139Verification();
//         break;
//       case 'EAN13':
//         res = _ean13Verification();
//         break;
//       case 'EAN8':
//         res = _ean8Verification();
//         break;
//       case 'UPC-A':
//         res = _upcaVerification();
//         break;
//       case 'UPC-E':
//         res = _upceVerification();
//         break;
//       case 'TTF':
//         break;
//       default:
//     }
//     return res;
//   }

//   bool _code128Verification() {
//     bool res = true;
//     int count = 0;
//     bool isLegal = false;
//     RegExp regex = RegExp(r'^[\x00-\x7F\xC8-\xDD]+$');

//     for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
//       if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
//         isLegal =
//             regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
//         if (!isLegal) {
//           _errorController.text =
//               'The content does not meet barcode requirements!';
//           res = false;
//           break;
//         }
//       } else {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//         if (myBarCodeRowDataList
//             .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
//           isLegal = regex.hasMatch(
//               myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
//           if (!isLegal) {
//             _errorController.text =
//                 'The default value does not meet barcode requirements!';
//             res = false;
//             break;
//           }
//         } else {
//           for (var j = 0;
//               j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//               j++) {
//             myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
//                 myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
//                     j.toString();
//           }
//         }
//       }
//     }
//     if (count > 128) {
//       res = false;
//       _errorController.text = 'The barcode lenth max lenth!';
//     }

//     return res;
//   }

//   bool _code139Verification() {
//     bool res = true;
//     int count = 0;
//     bool isLegal = false;
//     RegExp regex = RegExp(r'^[\x00-\x7F\xC8-\xDD]+$');

//     for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
//       if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
//         isLegal =
//             regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
//         if (!isLegal) {
//           _errorController.text =
//               'The content does not meet barcode requirements!';
//           res = false;
//           break;
//         }
//       } else {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//         if (myBarCodeRowDataList
//             .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
//           isLegal = regex.hasMatch(
//               myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
//           if (!isLegal) {
//             _errorController.text =
//                 'The default value does not meet barcode requirements!';
//             res = false;
//             break;
//           }
//         } else {
//           for (var j = 0;
//               j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//               j++) {
//             myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
//                 myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
//                     j.toString();
//           }
//         }
//       }
//     }
//     if (count > 39) {
//       res = false;
//       _errorController.text = 'The barcode lenth max lenth!';
//     }

//     return res;
//   }

//   bool _ean13Verification() {
//     bool res = true;
//     int count = 0;
//     bool isLegal = false;
//     RegExp regex = RegExp(r'\d{0,12}');

//     for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
//       if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
//         isLegal =
//             regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
//         if (!isLegal) {
//           _errorController.text =
//               'The content does not meet barcode requirements!';
//           res = false;
//           break;
//         }
//       } else {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//         if (myBarCodeRowDataList
//             .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
//           isLegal = regex.hasMatch(
//               myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
//           if (!isLegal) {
//             _errorController.text =
//                 'The default value does not meet barcode requirements!';
//             res = false;
//             break;
//           }
//         } else {
//           for (var j = 0;
//               j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//               j++) {
//             myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
//                 myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
//                     j.toString();
//           }
//         }
//       }
//     }
//     if (count != 12) {
//       res = false;
//       _errorController.text = 'The length of the barcode should be 12.!';
//     }

//     return res;
//   }

//   bool _ean8Verification() {
//     bool res = true;
//     int count = 0;
//     bool isLegal = false;
//     RegExp regex = RegExp(r'\d{0,7}');

//     for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
//       if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
//         isLegal =
//             regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
//         if (!isLegal) {
//           _errorController.text =
//               'The content does not meet barcode requirements!';
//           res = false;
//           break;
//         }
//       } else {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//         if (myBarCodeRowDataList
//             .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
//           isLegal = regex.hasMatch(
//               myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
//           if (!isLegal) {
//             _errorController.text =
//                 'The default value does not meet barcode requirements!';
//             res = false;
//             break;
//           }
//         } else {
//           for (var j = 0;
//               j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//               j++) {
//             myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
//                 myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
//                     j.toString();
//           }
//         }
//       }
//     }
//     if (count != 7) {
//       res = false;
//       _errorController.text = 'The length of the barcode should be 7!';
//     }

//     return res;
//   }

//   bool _upceVerification() {
//     bool res = true;
//     int count = 0;
//     bool isLegal = false;
//     RegExp regex = RegExp(r'\d{0,6}');

//     for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
//       if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
//         count = myBarCodeRowDataList.barCodeRowDataList[i].content.length;
//         isLegal =
//             regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
//         if (!isLegal) {
//           _errorController.text =
//               'The content does not meet barcode requirements!';
//           res = false;
//           break;
//         }
//       } else {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//         if (myBarCodeRowDataList
//             .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
//           isLegal = regex.hasMatch(
//               myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
//           if (!isLegal) {
//             _errorController.text =
//                 'The default value does not meet barcode requirements!';
//             res = false;
//             break;
//           }
//         } else {
//           for (var j = 0;
//               j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//               j++) {
//             myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
//                 myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
//                     j.toString();
//           }
//         }
//       }
//     }
//     if (count != 6) {
//       res = false;
//       _errorController.text = 'The length of the barcode should be 6!';
//     }

//     return res;
//   }

//   bool _upcaVerification() {
//     bool res = true;
//     int count = 0;
//     bool isLegal = false;
//     RegExp regex = RegExp(r'\d{0,11}');

//     for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
//       if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
//         isLegal =
//             regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
//         if (!isLegal) {
//           _errorController.text =
//               'The content does not meet barcode requirements!';
//           res = false;
//           break;
//         }
//       } else {
//         count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//         if (myBarCodeRowDataList
//             .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
//           isLegal = regex.hasMatch(
//               myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
//           if (!isLegal) {
//             _errorController.text =
//                 'The default value does not meet barcode requirements!';
//             res = false;
//             break;
//           }
//         } else {
//           for (var j = 0;
//               j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//               j++) {
//             myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
//                 myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
//                     j.toString();
//           }
//         }
//       }
//     }
//     if (count != 11) {
//       res = false;
//       _errorController.text = 'The length of the barcode should be 6!';
//     }

//     return res;
//   }

//   void _saveRowData() {
//     setState(() {
//       if (!_judgeData()) {
//         return;
//       }
//       if (!_barcodeTypeVerification()) {
//         return;
//       }

//       bool result = true;
//       myBarCodeRowDataList.barCodeName = _barCodeNameController.text;
//       myBarCodeRowDataList.barCodeType = _selectBarcode.text;
//       String tempName = _barCodeNameController.text;

//       if (myBarCodeListList.barCodeListList.isNotEmpty) {
//         for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
//           if (myBarCodeListList.barCodeListList[i].barCodeName ==
//               myBarCodeRowDataList.barCodeName) {
//             myBarCodeListList.barCodeListList.removeAt(i);
//             _savingData(tempName);
//             result = false;
//           }
//         }
//         if (result) {
//           _savingData(tempName);
//         }
//       } else {
//         _savingData(tempName);
//       }
//     });
//   }

//   void _savingData(String tempName) {
//     String type = '';
//     String content = '';
//     String defaultvalue = '';
//     String alignment = '';
//     int maxlength = 0;
//     List<BarCodeRowData> tempRowDataList = [];
//     for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
//       alignment = myBarCodeRowDataList.barCodeRowDataList[i].alignment;
//       content = myBarCodeRowDataList.barCodeRowDataList[i].content;
//       defaultvalue = myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue;
//       maxlength = myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
//       type = myBarCodeRowDataList.barCodeRowDataList[i].type;

//       tempRowDataList.add(
//           BarCodeRowData(type, content, defaultvalue, alignment, maxlength));
//     }
//     myBarCodeListList.barCodeListList.add(BarCodeRowDataInfo(
//       tempRowDataList,
//       _barCodeNameController.text,
//       _selectBarcode.text,
//     ));
//     _errorController.text = 'Barcode  ($tempName) saved successfully!';
//     _saveBarCodeNameToList();
//     _saveDataToJson();
//   }

//   void _deleteRowData() {
//     setState(() {
//       if (_barCodeNameController.text.isNotEmpty) {
//         for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
//           if (myBarCodeListList.barCodeListList[i].barCodeName ==
//                   _barCodeNameController.text &&
//               myBarCodeListList.barCodeListList[i].barCodeType != 'Qrcode') {
//             myBarCodeListList.barCodeListList.removeAt(i);
//           }
//         }
//       }
//       _saveBarCodeNameToList();
//       myBarCodeRowDataList.barCodeRowDataList.clear();
//       // myBarCodeRowDataList.barCodeRowDataList
//       //     .removeWhere((rowData) => rowData.canDelete);
//     });
//   }
// }
