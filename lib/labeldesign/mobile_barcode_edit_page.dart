import 'package:flutter/material.dart';
import 'package:t_max/data/barcoderowdata.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/mobile_page_help_dialog.dart';

class MobileBarcodeEditPage extends StatefulWidget {
  final bool isQrcode;
  final BarCodeRowDataInfo? barcodeItem;
  final Function(BarCodeRowDataInfo savedItem) onSave;

  const MobileBarcodeEditPage({
    super.key,
    required this.isQrcode,
    required this.barcodeItem,
    required this.onSave,
  });

  @override
  State<MobileBarcodeEditPage> createState() => _MobileBarcodeEditPageState();
}

class _MobileBarcodeEditPageState extends State<MobileBarcodeEditPage> {
  late TextEditingController nameController;
  late String selectedBarcodeType;
  List<BarCodeRowData> segments = [];

  final List<String> barcodeTypes = [
    "Code128",
    "Code39",
    "EAN8",
    "EAN13",
    "UPC-A",
    "UPC-E",
  ];

  // Full PC Variables List
  final List<String> dataTypeOptions = [
    "TEXT",
    "NO.",
    "Gross",
    "Tare",
    "Net",
    "PCS",
    "WeightUnit",
    "Date",
    "Time",
    "U.WGT",
    "U.WU",
    "UnitWeight",
    "Percent",
    "TotalWeight",
    "TotalCount",
    "TotalPcs",
  ];

  final List<String> alignmentOptions = ["--", "Left", "Center", "Right"];

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.barcodeItem?.barCodeName ?? "");
    selectedBarcodeType = widget.barcodeItem?.barCodeType ??
        (widget.isQrcode ? "Qrcode" : "Code128");

    if (widget.barcodeItem != null &&
        widget.barcodeItem!.barCodeRowDataList.isNotEmpty) {
      segments = widget.barcodeItem!.barCodeRowDataList
          .map((item) => BarCodeRowData(
                item.type,
                item.content,
                item.defaultvalue,
                item.alignment,
                item.maxlength,
              ))
          .toList();
    } else {
      segments = [
        BarCodeRowData(
          "TEXT",
          "",
          "",
          "--",
          10,
        ),
      ];
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _addSegment() {
    setState(() {
      segments.add(BarCodeRowData(
        "TEXT",
        "",
        "",
        "--",
        10,
      ));
    });
  }

  void _removeSegment(int index) {
    if (segments.length <= 1) {
      showTipInfo("At least one data segment required", context);
      return;
    }
    setState(() {
      segments.removeAt(index);
    });
  }

  void _handleSave() {
    final nameStr = nameController.text.trim();
    if (nameStr.isEmpty) {
      showTipInfo("Name cannot be empty", context);
      return;
    }

    final item = BarCodeRowDataInfo(
      segments,
      nameStr,
      widget.isQrcode ? "Qrcode" : selectedBarcodeType,
    );

    widget.onSave(item);
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
    final titleText = widget.isQrcode ? "Qrcode Edit" : "BarCode Edit";

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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BarCode Type (Only if Barcode, hidden for QRCode)
                  if (!widget.isQrcode) ...[
                    _buildPropertyTile(
                      label: "BarCode Type",
                      value: selectedBarcodeType,
                      enabled: true,
                      onTap: () => _showOptionPicker(
                        "BarCode Type",
                        barcodeTypes,
                        selectedBarcodeType,
                        (val) => setState(() => selectedBarcodeType = val),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],

                  // BarCode/Qrcode Name Input
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isQrcode ? "Qrcode Name" : "BarCode Name",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Segments Header + Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Data Segments",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005696),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Color(0xFF005696), size: 24),
                        onPressed: _addSegment,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Data Segments List Cards
                  ...List.generate(segments.length, (idx) {
                    final seg = segments[idx];
                    final isTextType = seg.type == "TEXT";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Data ${idx + 1}",
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              if (segments.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () => _removeSegment(idx),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Data Type Selector
                          _buildPropertyTile(
                            label: "Data type",
                            value: seg.type,
                            enabled: true,
                            onTap: () => _showOptionPicker(
                              "Data type",
                              dataTypeOptions,
                              seg.type,
                              (val) {
                                setState(() {
                                  seg.type = val;
                                  if (val != "TEXT") {
                                    seg.content = val;
                                  }
                                });
                              },
                            ),
                          ),

                          // Content Input (Enabled only when Data Type is TEXT)
                          if (isTextType) ...[
                            const SizedBox(height: 8),
                            const Text("Content",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                            TextFormField(
                              initialValue: seg.content,
                              onChanged: (val) => seg.content = val,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          // Default Value Input (Disabled when Data Type is TEXT)
                          Text(
                            "Default Value",
                            style: TextStyle(
                              fontSize: 13,
                              color: isTextType ? Colors.black38 : Colors.black54,
                            ),
                          ),
                          TextFormField(
                            enabled: !isTextType,
                            initialValue: isTextType ? "" : seg.defaultvalue,
                            onChanged: (val) => seg.defaultvalue = val,
                            decoration: InputDecoration(
                              isDense: true,
                              border: const UnderlineInputBorder(),
                              fillColor: isTextType ? const Color(0xFFEEEEEE) : null,
                            ),
                            style: TextStyle(
                              color: isTextType ? Colors.black38 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Alignment & Max Length (Disabled when Data Type is TEXT)
                          Row(
                            children: [
                              Expanded(
                                child: _buildPropertyTile(
                                  label: "Alignment",
                                  value: isTextType ? "--" : seg.alignment,
                                  enabled: !isTextType,
                                  onTap: isTextType
                                      ? null
                                      : () => _showOptionPicker(
                                            "Alignment",
                                            alignmentOptions,
                                            seg.alignment,
                                            (val) => setState(
                                                () => seg.alignment = val),
                                          ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Max Length",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isTextType
                                            ? Colors.black38
                                            : Colors.black54,
                                      ),
                                    ),
                                    TextFormField(
                                      enabled: !isTextType,
                                      initialValue: isTextType
                                          ? ""
                                          : seg.maxlength.toString(),
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) => seg.maxlength =
                                          int.tryParse(val) ?? 10,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: const UnderlineInputBorder(),
                                        fillColor: isTextType
                                            ? const Color(0xFFEEEEEE)
                                            : null,
                                      ),
                                      style: TextStyle(
                                        color: isTextType
                                            ? Colors.black38
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Save Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1CB079),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
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
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: enabled ? Colors.black87 : Colors.black38,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: enabled ? Colors.black54 : Colors.black38,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: enabled ? Colors.black54 : Colors.black26,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
