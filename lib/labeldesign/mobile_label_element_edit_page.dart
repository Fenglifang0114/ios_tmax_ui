import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:t_max/data/language.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:t_max/data/barcoderowdata.dart';
import 'package:t_max/labeldesign/label_element.dart';

class MobileLabelElementEditPage extends StatefulWidget {
  final DraggableElement element;
  final VoidCallback onDelete;
  final Function(DraggableElement updatedElement) onConfirm;

  const MobileLabelElementEditPage({
    super.key,
    required this.element,
    required this.onDelete,
    required this.onConfirm,
  });

  @override
  State<MobileLabelElementEditPage> createState() =>
      _MobileLabelElementEditPageState();
}

class _MobileLabelElementEditPageState
    extends State<MobileLabelElementEditPage> {
  late TextEditingController contentController;
  late TextEditingController widthController;
  late TextEditingController heightController;
  late TextEditingController maxLengthController;

  late String selectedFontSize;
  late String selectedRotation;
  late String selectedFontBold;
  late String selectedFontReverse;
  late String selectedAlignment;
  late String selectedHRAlignment;
  late String selectedQrWidth;
  late String selectedBarcodeName;
  late String selectedQrcodeName;
  late String selectedLineWidth;

  List<String> savedBarcodeNames = ['--'];
  List<String> savedQrcodeNames = ['--'];

  final List<String> fontSizes = [
    '20',
    '21',
    '23',
    '46',
    '69',
    '95',
    '115',
    '137',
    '165',
    '170',
  ];

  final List<String> rotations = ['0', '90', '180', '270'];
  final List<String> fontBoldOptions = ['true', 'false'];
  final List<String> alignments = ['Left', 'Center', 'Right'];
  final List<String> hralignments = ['None', 'Bottom'];
  final List<String> qrWidths = ['3', '4', '5', '6', '7', '8', '9', '10'];
  final List<String> lineThicknesses = ['1.0', '2.0', '3.0', '4.0', '5.0'];

  @override
  void initState() {
    super.initState();
    final el = widget.element;

    contentController = TextEditingController(text: el.content ?? "");
    widthController =
        TextEditingController(text: el.size.width.toStringAsFixed(1));
    heightController =
        TextEditingController(text: el.size.height.toStringAsFixed(1));
    maxLengthController =
        TextEditingController(text: (el.maxLength ?? 10).toString());

    selectedFontSize = el.fontSize ?? "23";
    selectedRotation = (el.rotation ?? 0).toString();
    selectedFontBold = el.fontBold ?? "false";
    selectedFontReverse = el.fontReverse ?? "false";
    selectedAlignment = el.alignment ?? "Left";
    selectedHRAlignment =
        (el.hralignment?.isNotEmpty == true) ? el.hralignment! : "Bottom";
    selectedQrWidth = el.qrWidth ?? "3";
    selectedBarcodeName =
        (el.barcodeName?.isNotEmpty == true) ? el.barcodeName! : "--";
    selectedQrcodeName =
        (el.qrcodeName?.isNotEmpty == true) ? el.qrcodeName! : "--";
    selectedLineWidth = (el.lineWidth ?? 1.0).toStringAsFixed(1);

    _loadSavedBarcodeAndQrcodeNames();
  }

  @override
  void dispose() {
    contentController.dispose();
    widthController.dispose();
    heightController.dispose();
    maxLengthController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedBarcodeAndQrcodeNames() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'barcodedata.json'));
      if (await file.exists()) {
        final str = await file.readAsString();
        if (str.isNotEmpty) {
          final decoded = jsonDecode(str);
          List<BarCodeRowDataInfo> list = [];
          if (decoded is List) {
            list = decoded
                .whereType<Map<String, dynamic>>()
                .map((i) => BarCodeRowDataInfo.fromJson(i))
                .toList();
          } else if (decoded is Map &&
              decoded.containsKey('BarCodeListList') &&
              decoded['BarCodeListList'] is List) {
            final rawList = decoded['BarCodeListList'] as List;
            list = rawList
                .whereType<Map<String, dynamic>>()
                .map((i) => BarCodeRowDataInfo.fromJson(i))
                .toList();
          }

          final bcNames = <String>{'--'};
          final qrNames = <String>{'--'};

          for (var item in list) {
            if (item.barCodeType == 'Qrcode') {
              qrNames.add(item.barCodeName);
            } else {
              bcNames.add(item.barCodeName);
            }
          }

          setState(() {
            savedBarcodeNames = bcNames.toList();
            savedQrcodeNames = qrNames.toList();

            if (!savedBarcodeNames.contains(selectedBarcodeName)) {
              selectedBarcodeName = '--';
            }
            if (!savedQrcodeNames.contains(selectedQrcodeName)) {
              selectedQrcodeName = '--';
            }
          });
        }
      }
    } catch (_) {}
  }

  void _handleConfirm() {
    final el = widget.element;

    el.content = contentController.text;
    el.fontSize = selectedFontSize;
    el.rotation = int.tryParse(selectedRotation) ?? 0;
    el.fontBold = selectedFontBold;
    el.fontReverse = selectedFontReverse;
    el.alignment = selectedAlignment;
    el.hralignment = selectedHRAlignment;
    el.qrWidth = selectedQrWidth;
    el.barcodeName = selectedBarcodeName;
    el.qrcodeName = selectedQrcodeName;
    el.lineWidth = double.tryParse(selectedLineWidth) ?? 1.0;
    el.maxLength = int.tryParse(maxLengthController.text) ?? 10;

    double w = double.tryParse(widthController.text) ?? el.size.width;
    double h = double.tryParse(heightController.text) ?? el.size.height;
    el.size = Size(w, h);

    widget.onConfirm(el);
    Navigator.pop(context);
  }

  void _showOptionPicker(
    String title,
    List<String> options,
    String currentValue,
    Function(String selected) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...options.map((opt) {
                  final isSelected = opt == currentValue;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        onSelect(opt);
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
                      child: Text(opt, style: const TextStyle(fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    final type = widget.element.type;
    String pageTitle = "Element Properties";

    if (type == ElementType.text) pageTitle = "Text Properties";
    if (type == ElementType.data) pageTitle = "Variable Properties";
    if (type == ElementType.barcode) pageTitle = "Barcode Properties";
    if (type == ElementType.qrcode) pageTitle = "QRCode Properties";
    if (type == ElementType.line || type == ElementType.lineDiagonal) {
      pageTitle = "Line Properties";
    }

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
          pageTitle,
          style: const TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type display
                  _buildPropertyTile(
                    label: "Element Type",
                    value: type.name.toUpperCase(),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // --- TEXT SPECIFIC FIELDS ---
                  if (type == ElementType.text) ...[
                    const SizedBox(height: 12),
                    Text(localizedStrings?.gTipContent ?? "Content",
                        style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPropertyTile(
                      label: "Font Size",
                      value: selectedFontSize,
                      onTap: () => _showOptionPicker(
                        "Font Size",
                        fontSizes,
                        selectedFontSize,
                        (val) => setState(() => selectedFontSize = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildPropertyTile(
                      label: "Font Bold",
                      value: selectedFontBold,
                      onTap: () => _showOptionPicker(
                        "Font Bold",
                        fontBoldOptions,
                        selectedFontBold,
                        (val) => setState(() => selectedFontBold = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildPropertyTile(
                      label: "Font Reverse",
                      value: selectedFontReverse,
                      onTap: () => _showOptionPicker(
                        "Font Reverse",
                        fontBoldOptions,
                        selectedFontReverse,
                        (val) => setState(() => selectedFontReverse = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],

                  // --- VARIABLE (DATA) SPECIFIC FIELDS ---
                  if (type == ElementType.data) ...[
                    const SizedBox(height: 12),
                    _buildPropertyTile(
                      label: "Variable Name",
                      value: widget.element.varName ?? "Variable",
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 8),
                    Text(localizedStrings?.gTipMaxLength ?? "Max Length",
                        style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    TextField(
                      controller: maxLengthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPropertyTile(
                      label: "Alignment",
                      value: selectedAlignment,
                      onTap: () => _showOptionPicker(
                        "Alignment",
                        alignments,
                        selectedAlignment,
                        (val) => setState(() => selectedAlignment = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildPropertyTile(
                      label: "Font Size",
                      value: selectedFontSize,
                      onTap: () => _showOptionPicker(
                        "Font Size",
                        fontSizes,
                        selectedFontSize,
                        (val) => setState(() => selectedFontSize = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildPropertyTile(
                      label: "Font Bold",
                      value: selectedFontBold,
                      onTap: () => _showOptionPicker(
                        "Font Bold",
                        fontBoldOptions,
                        selectedFontBold,
                        (val) => setState(() => selectedFontBold = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildPropertyTile(
                      label: "Font Reverse",
                      value: selectedFontReverse,
                      onTap: () => _showOptionPicker(
                        "Font Reverse",
                        fontBoldOptions,
                        selectedFontReverse,
                        (val) => setState(() => selectedFontReverse = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],

                  // --- BARCODE SPECIFIC FIELDS ---
                  if (type == ElementType.barcode) ...[
                    const SizedBox(height: 12),
                    _buildPropertyTile(
                      label: "BarCode Name",
                      value: selectedBarcodeName,
                      onTap: () => _showOptionPicker(
                        "BarCode Name",
                        savedBarcodeNames,
                        selectedBarcodeName,
                        (val) => setState(() => selectedBarcodeName = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildPropertyTile(
                      label: "HRI Alignment",
                      value: selectedHRAlignment,
                      onTap: () => _showOptionPicker(
                        "HRI Alignment",
                        hralignments,
                        selectedHRAlignment,
                        (val) => setState(() => selectedHRAlignment = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],

                  // --- QRCODE SPECIFIC FIELDS ---
                  if (type == ElementType.qrcode) ...[
                    const SizedBox(height: 12),
                    _buildPropertyTile(
                      label: "QrCode Name",
                      value: selectedQrcodeName,
                      onTap: () => _showOptionPicker(
                        "QrCode Name",
                        savedQrcodeNames,
                        selectedQrcodeName,
                        (val) => setState(() => selectedQrcodeName = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildPropertyTile(
                      label: "QrCode Width / Grade",
                      value: selectedQrWidth,
                      onTap: () => _showOptionPicker(
                        "QrCode Width",
                        qrWidths,
                        selectedQrWidth,
                        (val) => setState(() => selectedQrWidth = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],

                  // --- LINE SPECIFIC FIELDS ---
                  if (type == ElementType.line ||
                      type == ElementType.lineDiagonal) ...[
                    const SizedBox(height: 12),
                    _buildPropertyTile(
                      label: "Line Thickness",
                      value: selectedLineWidth,
                      onTap: () => _showOptionPicker(
                        "Line Thickness",
                        lineThicknesses,
                        selectedLineWidth,
                        (val) => setState(() => selectedLineWidth = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],

                  // --- COMMON FIELDS: ROTATION & DIMENSIONS ---
                  _buildPropertyTile(
                    label: "Rotation",
                    value: selectedRotation,
                    onTap: () => _showOptionPicker(
                      "Rotation",
                      rotations,
                      selectedRotation,
                      (val) => setState(() => selectedRotation = val),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(localizedStrings?.gTipWidthMm ?? "Width(mm)",
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                            TextField(
                              controller: widthController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(localizedStrings?.gTipHeightMm ?? "Height(mm)",
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                            TextField(
                              controller: heightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Confirm Save Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1CB079),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    localizedStrings?.gBtnConfirm ?? "Confirm",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            Row(
              children: [
                Text(value,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
