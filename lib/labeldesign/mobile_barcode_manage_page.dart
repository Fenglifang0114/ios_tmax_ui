import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:t_max/data/barcoderowdata.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/labeldesign/mobile_barcode_edit_page.dart';
import 'package:t_max/dialog/mobile_page_help_dialog.dart';

class MobileBarcodeManagePage extends StatefulWidget {
  final bool isQrcode;
  final List<BarCodeRowDataInfo> barcodeList;
  final Function(List<BarCodeRowDataInfo> updatedList) onUpdateList;

  const MobileBarcodeManagePage({
    super.key,
    required this.isQrcode,
    required this.barcodeList,
    required this.onUpdateList,
  });

  @override
  State<MobileBarcodeManagePage> createState() =>
      _MobileBarcodeManagePageState();
}

class _MobileBarcodeManagePageState extends State<MobileBarcodeManagePage> {
  late List<BarCodeRowDataInfo> items;
  TextEditingController searchController = TextEditingController();
  String filterText = "";

  @override
  void initState() {
    super.initState();
    items = List.from(widget.barcodeList);
    _loadBarcodeDataFromFile();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<File> _getBarcodeFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'barcodedata.json'));
  }

  BarCodeListList _parseBarcodeJson(dynamic decodedJson) {
    List<BarCodeRowDataInfo> list = [];
    if (decodedJson is List) {
      list = decodedJson
          .whereType<Map<String, dynamic>>()
          .map((i) => BarCodeRowDataInfo.fromJson(i))
          .toList();
    } else if (decodedJson is Map) {
      if (decodedJson.containsKey('BarCodeListList') &&
          decodedJson['BarCodeListList'] is List) {
        final rawList = decodedJson['BarCodeListList'] as List;
        list = rawList
            .whereType<Map<String, dynamic>>()
            .map((i) => BarCodeRowDataInfo.fromJson(i))
            .toList();
      }
    }
    return BarCodeListList(list);
  }

  Future<void> _loadBarcodeDataFromFile() async {
    try {
      final file = await _getBarcodeFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          final listObj = _parseBarcodeJson(decoded);
          setState(() {
            items = listObj.barCodeListList.where((item) {
              if (widget.isQrcode) {
                return item.barCodeType == "Qrcode";
              } else {
                return item.barCodeType != "Qrcode";
              }
            }).toList();
          });
          widget.onUpdateList(items);
        }
      }
    } catch (_) {}
  }

  Future<void> _saveBarcodeDataToFile() async {
    try {
      final file = await _getBarcodeFile();

      // Load all existing items first to merge barcode and qrcode types
      BarCodeListList fullList = BarCodeListList([]);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          fullList = _parseBarcodeJson(decoded);
        }
      }

      // Remove existing items of current type
      fullList.barCodeListList.removeWhere((item) {
        if (widget.isQrcode) {
          return item.barCodeType == "Qrcode";
        } else {
          return item.barCodeType != "Qrcode";
        }
      });

      // Add current updated items
      fullList.barCodeListList.addAll(items);

      // Save as JSON List format for standard compatibility
      final jsonList = fullList.barCodeListList.map((v) => v.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));

      widget.onUpdateList(items);
    } catch (e) {
      if (mounted) {
        showTipInfo("Save failed: $e", context);
      }
    }
  }

  void _handleDeleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    _saveBarcodeDataToFile();
  }

  void _handleSaveItem(BarCodeRowDataInfo newItem, int? editIndex) {
    setState(() {
      if (editIndex != null) {
        items[editIndex] = newItem;
      } else {
        items.add(newItem);
      }
    });
    _saveBarcodeDataToFile();
  }

  @override
  Widget build(BuildContext context) {
    final titleText =
        widget.isQrcode ? "QRcode Management" : "Barcode Management";

    final filteredItems = items.where((item) {
      if (filterText.isEmpty) return true;
      return item.barCodeName.toLowerCase().contains(filterText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          titleText,
          style: const TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.black87, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => MobileBarcodeEditPage(
                    isQrcode: widget.isQrcode,
                    barcodeItem: null,
                    onSave: (savedItem) => _handleSaveItem(savedItem, null),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                setState(() {
                  filterText = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Name",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Items List
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      "No Data",
                      style: TextStyle(color: Colors.black38, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredItems.length,
                    itemBuilder: (ctx, idx) {
                      final item = filteredItems[idx];
                      final realIndex = items.indexOf(item);
                      final isExpanded = item.isExpand == true;
                      final typeLabel = widget.isQrcode ? "QrCode Type" : "BarCode Type";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Title & Actions
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.barCodeName,
                                    style: const TextStyle(
                                      color: Color(0xFF0D558E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.edit_outlined,
                                      color: Color(0xFF0D558E), size: 20),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => MobileBarcodeEditPage(
                                          isQrcode: widget.isQrcode,
                                          barcodeItem: item,
                                          onSave: (savedItem) =>
                                              _handleSaveItem(savedItem, realIndex),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete_outline,
                                      color: Color(0xFFE53935), size: 20),
                                  onPressed: () => _handleDeleteItem(realIndex),
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      item.isExpand = !isExpanded;
                                    });
                                  },
                                  child: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.black54,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Sub-header Row: BarCode Type
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  typeLabel,
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                                Text(
                                  item.barCodeType.isEmpty ? "Code128" : item.barCodeType,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),

                            // Expanded Details Section
                            if (isExpanded) ...[
                              const SizedBox(height: 12),
                              if (item.barCodeRowDataList.isEmpty)
                                const Text(
                                  "No segment detail",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                )
                              else
                                ...item.barCodeRowDataList.map((row) {
                                  return Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9F9),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFF0F0F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Row 1 Header
                                        Row(
                                          children: const [
                                            Expanded(
                                                child: Text("DATATYPE",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12))),
                                            Expanded(
                                                child: Text("Content",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12))),
                                            Expanded(
                                                child: Text("Default Value",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12))),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        // Row 1 Values
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                                    row.type.isEmpty ? "-" : row.type,
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 13))),
                                            Expanded(
                                                child: Text(
                                                    row.content.isEmpty ? "-" : row.content,
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 13))),
                                            Expanded(
                                                child: Text(
                                                    row.defaultvalue.isEmpty
                                                        ? "-"
                                                        : row.defaultvalue,
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 13))),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Row 2 Header
                                        Row(
                                          children: const [
                                            Expanded(
                                                child: Text("Alignment",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12))),
                                            Expanded(
                                                child: Text("Max Length",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12))),
                                            Expanded(child: SizedBox()),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        // Row 2 Values
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                                    row.alignment.isEmpty
                                                        ? "-"
                                                        : row.alignment,
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 13))),
                                            Expanded(
                                                child: Text("${row.maxlength}",
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 13))),
                                            const Expanded(child: SizedBox()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
