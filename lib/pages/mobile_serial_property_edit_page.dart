import 'package:flutter/material.dart';
import 'package:t_max/data/custom_serial_protocol_text_dart.dart';
import 'package:t_max/data/language.dart';

class MobileSerialPropertyEditPage extends StatefulWidget {
  final SerialProtocolText item;
  final VoidCallback onDelete;
  final Function(SerialProtocolText updatedItem) onConfirm;

  const MobileSerialPropertyEditPage({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onConfirm,
  });

  @override
  State<MobileSerialPropertyEditPage> createState() =>
      _MobileSerialPropertyEditPageState();
}

class _MobileSerialPropertyEditPageState
    extends State<MobileSerialPropertyEditPage> {
  late TextEditingController contentController;
  late TextEditingController maxLengthController;
  late TextEditingController isTrueController;
  late TextEditingController isFalseController;

  late String selectedAlignment;
  late String selectedFilling;

  final List<String> alignmentOptions = ['left', 'right'];
  final List<String> fillingOptions = ['space', '0'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    contentController = TextEditingController(text: item.content);
    maxLengthController =
        TextEditingController(text: item.maxLength.toString());
    isTrueController = TextEditingController(text: item.isTrue);
    isFalseController = TextEditingController(text: item.isFalse);

    selectedAlignment =
        item.alignment.isNotEmpty ? item.alignment : 'left';
    selectedFilling =
        item.filling.isNotEmpty ? item.filling : 'space';
  }

  @override
  void dispose() {
    contentController.dispose();
    maxLengthController.dispose();
    isTrueController.dispose();
    isFalseController.dispose();
    super.dispose();
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
        );
      },
    );
  }

  void _handleConfirm() {
    final item = widget.item;

    item.content = contentController.text;
    item.maxLength = int.tryParse(maxLengthController.text) ?? item.maxLength;
    item.alignment = selectedAlignment;
    item.filling = selectedFilling;
    item.isTrue = isTrueController.text;
    item.isFalse = isFalseController.text;

    widget.onConfirm(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    String pageTitle = "${item.type} Property";
    if (item.type == 'TEXT') pageTitle = "Text Property";
    if (item.type == 'TEXT_HEX') pageTitle = "Text Hex Property";
    if (item.type == 'String') pageTitle = "String Property";
    if (item.type == 'Float') pageTitle = "Float Property";
    if (item.type == 'Bool') pageTitle = "Bool Property";
    if (item.type == 'Enter') pageTitle = "Enter Property";

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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Read-only
                  _buildPropertyRow(
                    label: "Type",
                    value: item.type,
                    isReadOnly: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // Alignment
                  if (item.type != 'Enter') ...[
                    _buildPropertyRow(
                      label: "Alignment",
                      value: selectedAlignment,
                      onTap: () => _showOptionPicker(
                        "Alignment",
                        alignmentOptions,
                        selectedAlignment,
                        (val) => setState(() => selectedAlignment = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),

                    // Filling
                    _buildPropertyRow(
                      label: "Filling",
                      value: selectedFilling,
                      onTap: () => _showOptionPicker(
                        "Filling",
                        fillingOptions,
                        selectedFilling,
                        (val) => setState(() => selectedFilling = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),

                    // Max Length
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(localizedStrings?.gTipMaxLength ?? "Max Length",
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black87)),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: maxLengthController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],

                  // TEXT / TEXT_HEX content
                  if (item.type == 'TEXT' || item.type == 'TEXT_HEX') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(localizedStrings?.gTipContent ?? "Content",
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black87)),
                          Expanded(
                            child: TextField(
                              controller: contentController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],

                  // String / Float Default Value
                  if (item.type == 'String' || item.type == 'Float') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(localizedStrings?.gTipDefaultValue ?? "Default Value",
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black87)),
                          Expanded(
                            child: TextField(
                              controller: contentController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],

                  // Bool True / False Value
                  if (item.type == 'Bool') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("True Value",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black87)),
                          Expanded(
                            child: TextField(
                              controller: isTrueController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("False Value",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black87)),
                          Expanded(
                            child: TextField(
                              controller: isFalseController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Buttons (Confirm & Delete)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1CB079),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          localizedStrings?.gBtnConfirm ?? "Confirm",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onDelete();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          localizedStrings?.gBtnDelete ?? "Delete",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow({
    required String label,
    required String value,
    bool isReadOnly = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isReadOnly ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isReadOnly ? Colors.grey[400] : Colors.black54,
                  ),
                ),
                if (!isReadOnly) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.black54),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
