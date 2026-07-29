import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/receipt_item.dart';
import 'package:t_max/pages/mobile_receipt_canvas_page.dart';
import 'package:t_max/pages/mobile_receipt_variable_setting_page.dart';
import 'package:t_max/pages/mobile_sel_scales_page.dart';
import 'package:t_max/pages/update_firmware_page.dart';

class MobileReceiptDesignPage extends StatefulWidget {
  const MobileReceiptDesignPage({super.key});

  @override
  State<MobileReceiptDesignPage> createState() => _MobileReceiptDesignPageState();
}

class _MobileReceiptDesignPageState extends State<MobileReceiptDesignPage> {
  List<ReceiptItemData> receiptItemList = [];
  String selectedProtocol = 'EPM205';
  String selectedDirection = 'Forward';
  TextEditingController widthCtl = TextEditingController(text: '55.0');
  TextEditingController heightCtl = TextEditingController(text: '55.0');

  final List<String> protocols = ['ESC/POS', 'EPM205', 'LP50', 'ZEBRA'];
  final List<String> directions = ['Forward', 'Backward'];

  @override
  void initState() {
    super.initState();
    _loadDefaultTemplate();
  }

  void _loadDefaultTemplate() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/template/receipt.json');
      final jsonString = utf8.decode(bytes.buffer.asUint8List());
      List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        receiptItemList = jsonList.map((e) => ReceiptItemData.fromJson(e)).toList();
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void _showAddFormatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined,
                          color: Colors.black54, size: 24),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleNewFormat();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005696),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      "New Format",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChoiceProtocolSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Printer Protocol",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...protocols.map((protocol) {
                  final isSelected = protocol == selectedProtocol;

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedProtocol = protocol;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF005696)
                            : const Color(0xFFF6F6F6),
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        protocol,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChoiceDirectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Direction",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...directions.map((dir) {
                  final isSelected = dir == selectedDirection;

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedDirection = dir;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF005696)
                            : const Color(0xFFF6F6F6),
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        dir,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCanvasEditor() async {
    final updatedList = await Navigator.push<List<ReceiptItemData>>(
      context,
      MaterialPageRoute(
        builder: (ctx) => MobileReceiptCanvasPage(
          initialItemList: receiptItemList,
          receiptWidthMm: double.tryParse(widthCtl.text) ?? 55.0,
          receiptHeightMm: double.tryParse(heightCtl.text) ?? 55.0,
        ),
      ),
    );

    if (updatedList != null) {
      setState(() {
        receiptItemList = updatedList;
      });
    }
  }

  void _openVariableSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const MobileReceiptVariableSettingPage(),
      ),
    );
  }

  void _handleOpenJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.isNotEmpty) {
        String filePath = result.files.single.path!;
        File file = File(filePath);
        String contents = await file.readAsString();
        List<dynamic> jsonList = jsonDecode(contents);
        setState(() {
          receiptItemList =
              jsonList.map((e) => ReceiptItemData.fromJson(e)).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Format JSON loaded successfully!")),
        );
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void _handleSaveFormat() async {
    try {
      String jsonStr =
          jsonEncode(receiptItemList.map((e) => e.toJson()).toList());
      if (kDebugMode) print(jsonStr);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receipt format saved successfully!")),
      );
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void _handleNewFormat() {
    setState(() {
      receiptItemList.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Canvas cleared for new format!")),
    );
  }

  Widget _buildRealPreview(double canvasWidth, double canvasHeight) {
    if (receiptItemList.isEmpty) {
      return Container(
        width: canvasWidth,
        height: canvasHeight,
        alignment: Alignment.center,
        color: Colors.white,
        child: const Text(
          "Empty Canvas",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    double maxMm = double.tryParse(widthCtl.text) ?? 55.0;
    double scale = canvasWidth / (maxMm * 8.0 > 0 ? maxMm * 8.0 : 440.0);

    return Container(
      width: canvasWidth,
      height: canvasHeight,
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: receiptItemList.map((item) {
          return Positioned(
            left: item.xPos * scale,
            top: item.yPos * scale,
            child: item.type == 'Line'
                ? SizedBox(
                    width: canvasWidth - 16,
                    child: Divider(
                      color: Colors.black87,
                      thickness: item.lineWidth,
                    ),
                  )
                : Text(
                    item.content.isNotEmpty ? item.content : item.varName,
                    style: TextStyle(
                      fontSize: (item.fontSize > 0 ? item.fontSize : 14) * 0.4,
                      color: Colors.black87,
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Receipt Design",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Receipt Design Help"),
                  content: Text(localizedStrings?.gTipReceiptDesignPageHelp ??
                      "Configure custom receipt formats and printer protocols for scale."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
            onPressed: _showAddFormatSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Printer Protocol Selector
                  GestureDetector(
                    onTap: _showChoiceProtocolSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Printer Protocol",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                selectedProtocol,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: Colors.black45, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Direction Selector
                  GestureDetector(
                    onTap: _showChoiceDirectionSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Direction",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                selectedDirection,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: Colors.black45, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Width(mm) and Height(mm) Inputs
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Width(mm)",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: widthCtl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Height(mm)",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: heightCtl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. Receipt Sample Header & Real Preview Box
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Receipt Sample",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.black87,
                        ),
                        onPressed: _openCanvasEditor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Real Format Preview Container (Green Border Box matching design mockup)
                  GestureDetector(
                    onTap: _openCanvasEditor,
                    child: Container(
                      width: double.infinity,
                      height: 320,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1CB079), // Green border matching mockup
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: LayoutBuilder(
                        builder: (ctx, constraints) {
                          return _buildRealPreview(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 5. Bottom 3 Action Buttons (Variable Value Setting, Open Json, Save Format)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Full-width "Variable Value Setting" button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _openVariableSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005696),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        "Variable Value Setting",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Row with "Open Json" and "Save Format"
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _handleOpenJson,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005696),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              "Open Json",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _handleSaveFormat,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1CB079),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              "Save Format",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
