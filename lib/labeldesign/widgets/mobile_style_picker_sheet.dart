import 'package:flutter/material.dart';

class MobileStylePickerSheet extends StatefulWidget {
  final Function(String category, String elementName) onSelectElement;

  const MobileStylePickerSheet({
    super.key,
    required this.onSelectElement,
  });

  @override
  State<MobileStylePickerSheet> createState() => _MobileStylePickerSheetState();
}

class _MobileStylePickerSheetState extends State<MobileStylePickerSheet> {
  // Accordion expanded states
  bool isFreeTextExpanded = true;
  bool isBarcodeVarExpanded = true;
  bool isQrcodeVarExpanded = true;
  bool isShapeExpanded = true;
  bool isVariableExpanded = true;

  // Variables list matching PC
  final List<String> variableList = [
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Style",
                  style: TextStyle(
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
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          // Accordion Content List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 1. Free Text Category
                  _buildAccordionHeader(
                    title: "Free Text",
                    isExpanded: isFreeTextExpanded,
                    onToggle: () => setState(() => isFreeTextExpanded = !isFreeTextExpanded),
                  ),
                  if (isFreeTextExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: _buildActionButton(
                        label: "Text",
                        isPrimary: true,
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelectElement("Free Text", "Text");
                        },
                      ),
                    ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 8),

                  // 2. BarCode Variable Category
                  _buildAccordionHeader(
                    title: "BarCode Variable",
                    isExpanded: isBarcodeVarExpanded,
                    onToggle: () => setState(() => isBarcodeVarExpanded = !isBarcodeVarExpanded),
                  ),
                  if (isBarcodeVarExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: _buildActionButton(
                        label: "BarCode",
                        isPrimary: false,
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelectElement("BarCode Variable", "BarCode");
                        },
                      ),
                    ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 8),

                  // 3. Qrcode Variable Category
                  _buildAccordionHeader(
                    title: "Qrcode Variable",
                    isExpanded: isQrcodeVarExpanded,
                    onToggle: () => setState(() => isQrcodeVarExpanded = !isQrcodeVarExpanded),
                  ),
                  if (isQrcodeVarExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: _buildActionButton(
                        label: "Qrcode",
                        isPrimary: false,
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelectElement("Qrcode Variable", "Qrcode");
                        },
                      ),
                    ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 8),

                  // 4. Shape Category
                  _buildAccordionHeader(
                    title: "Shape",
                    isExpanded: isShapeExpanded,
                    onToggle: () => setState(() => isShapeExpanded = !isShapeExpanded),
                  ),
                  if (isShapeExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: _buildActionButton(
                        label: "Line",
                        isPrimary: false,
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelectElement("Shape", "Line");
                        },
                      ),
                    ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 8),

                  // 5. Variable Category (Separate from Free Text)
                  _buildAccordionHeader(
                    title: "Variable",
                    isExpanded: isVariableExpanded,
                    onToggle: () => setState(() => isVariableExpanded = !isVariableExpanded),
                  ),
                  if (isVariableExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: variableList.length,
                        itemBuilder: (context, index) {
                          final varName = variableList[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSelectElement("Variable", varName);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F6F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                varName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
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

  Widget _buildAccordionHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF005696),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFF005696),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF005696) : const Color(0xFFF6F6F6),
          foregroundColor: isPrimary ? Colors.white : Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
