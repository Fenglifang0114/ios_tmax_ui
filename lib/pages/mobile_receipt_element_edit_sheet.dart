import 'package:flutter/material.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: MobileReceiptElementEditSheet(
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
  late TextEditingController _fontSizeCtl;
  late TextEditingController _xPosCtl;
  late TextEditingController _yPosCtl;
  late int _alignment;

  @override
  void initState() {
    super.initState();
    _contentCtl = TextEditingController(text: widget.item.content);
    _fontSizeCtl = TextEditingController(text: widget.item.fontSize.toString());
    _xPosCtl = TextEditingController(text: widget.item.xPos.toString());
    _yPosCtl = TextEditingController(text: widget.item.yPos.toString());
    _alignment = widget.item.alignment;
  }

  @override
  void dispose() {
    _contentCtl.dispose();
    _fontSizeCtl.dispose();
    _xPosCtl.dispose();
    _yPosCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Property (${widget.item.type})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (widget.item.type == 'TEXT') ...[
                const Text("Content",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: _contentCtl,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("X Pos (mm)",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _xPosCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Y Pos (row)",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _yPosCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Font Size",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _fontSizeCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Alignment",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _alignment,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 1, child: Text("Left")),
                                DropdownMenuItem(
                                    value: 2, child: Text("Center")),
                                DropdownMenuItem(
                                    value: 3, child: Text("Right")),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _alignment = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          widget.onDelete();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                        child: const Text("Delete"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.item.content = _contentCtl.text;
                          widget.item.fontSize =
                              int.tryParse(_fontSizeCtl.text) ?? widget.item.fontSize;
                          widget.item.xPos =
                              int.tryParse(_xPosCtl.text) ?? widget.item.xPos;
                          widget.item.yPos =
                              int.tryParse(_yPosCtl.text) ?? widget.item.yPos;
                          widget.item.alignment = _alignment;

                          widget.onConfirm(widget.item);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005696),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Confirm"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
