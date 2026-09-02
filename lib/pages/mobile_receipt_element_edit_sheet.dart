import 'package:flutter/material.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/receipt_item.dart';

class MobileReceiptElementEditSheet extends StatefulWidget {
  final ReceiptItemData item;
  final VoidCallback onDelete;
  final Function(ReceiptItemData updatedItem) onConfirm;

  const MobileReceiptElementEditSheet({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onConfirm,
  });

  static void show(
    BuildContext context,
    ReceiptItemData item,
    VoidCallback onDelete,
    Function(ReceiptItemData updatedItem) onConfirm,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MobileReceiptElementEditSheet(
          item: item,
          onDelete: onDelete,
          onConfirm: onConfirm,
        ),
      ),
    );
  }

  @override
  State<MobileReceiptElementEditSheet> createState() =>
      _MobileReceiptElementEditSheetState();
}

class _MobileReceiptElementEditSheetState
    extends State<MobileReceiptElementEditSheet> {
  late TextEditingController _contentCtl;
  late TextEditingController _maxLengthCtl;
  late TextEditingController _xPosCtl;
  late TextEditingController _yPosCtl;

  late String selectedFontSize;
  late String selectedAlignment;
  late String selectedRotation;
  late String selectedFontBold;
  late String selectedFontReverse;

  final List<String> fontSizes = ['24', '20', '21', '23', '46', '69', '95', '115'];
  final List<String> alignments = ['Left', 'Center', 'Right'];
  final List<String> rotations = ['0', '90', '180', '270'];
  final List<String> fontBoldOptions = ['true', 'false'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _contentCtl = TextEditingController(text: item.content);
    _maxLengthCtl = TextEditingController(text: (item.maxLength ?? 10).toString());
    _xPosCtl = TextEditingController(text: item.xPos.toString());
    _yPosCtl = TextEditingController(text: item.yPos.toString());

    selectedFontSize = item.fontSize.toString();
    selectedRotation = (item.rotation ?? 0).toString();
    selectedFontBold = (item.fontBold?.isNotEmpty == true) ? item.fontBold : "false";
    selectedFontReverse = (item.fontReverse?.isNotEmpty == true) ? item.fontReverse : "false";

    if (item.alignment == 2) {
      selectedAlignment = 'Center';
    } else if (item.alignment == 3) {
      selectedAlignment = 'Right';
    } else {
      selectedAlignment = 'Left';
    }
  }

  @override
  void dispose() {
    _contentCtl.dispose();
    _maxLengthCtl.dispose();
    _xPosCtl.dispose();
    _yPosCtl.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final item = widget.item;

    item.content = _contentCtl.text;
    item.fontSize = int.tryParse(selectedFontSize) ?? item.fontSize;
    item.maxLength = int.tryParse(_maxLengthCtl.text) ?? item.maxLength;
    item.rotation = int.tryParse(selectedRotation) ?? item.rotation;
    item.fontBold = selectedFontBold;
    item.fontReverse = selectedFontReverse;

    if (selectedAlignment == 'Center') {
      item.alignment = 2;
    } else if (selectedAlignment == 'Right') {
      item.alignment = 3;
    } else {
      item.alignment = 1;
    }

    item.xPos = int.tryParse(_xPosCtl.text) ?? item.xPos;
    item.yPos = int.tryParse(_yPosCtl.text) ?? item.yPos;

    widget.onConfirm(item);
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
    final type = widget.item.type.toUpperCase();
    String pageTitle = "Element Properties";

    if (type == 'TEXT') pageTitle = "Text Properties";
    if (type == 'DATA') pageTitle = "Variable Properties";
    if (type == 'LINE') pageTitle = "Line Properties";

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
                  // Type Display
                  _buildPropertyTile(
                    label: "Element Type",
                    value: type,
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // --- TEXT SPECIFIC FIELDS ---
                  if (type == 'TEXT') ...[
                    const SizedBox(height: 12),
                    Text(localizedStrings?.gTipContent ?? "Content",
                        style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    TextField(
                      controller: _contentCtl,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // --- VARIABLE (DATA) SPECIFIC FIELDS ---
                  if (type == 'DATA') ...[
                    const SizedBox(height: 12),
                    _buildPropertyTile(
                      label: "Variable Name",
                      value: widget.item.varName.isNotEmpty == true
                          ? widget.item.varName
                          : widget.item.content,
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 8),
                    Text(localizedStrings?.gTipMaxLength ?? "Max Length",
                        style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    TextField(
                      controller: _maxLengthCtl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // --- COMMON TEXT / VARIABLE FIELDS ---
                  if (type == 'TEXT' || type == 'DATA') ...[
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
                  ],

                  // --- POSITION FIELDS (X / Y) ---
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("X Pos (dots/mm)",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                            TextField(
                              controller: _xPosCtl,
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
                            const Text("Y Pos (row)",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                            TextField(
                              controller: _yPosCtl,
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

          // Bottom Confirm Button
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
