import 'package:flutter/material.dart';

class MobileReceiptVarSheet extends StatefulWidget {
  final Function(String varCategory, String varName) onSelectVariable;

  const MobileReceiptVarSheet({
    super.key,
    required this.onSelectVariable,
  });

  static void show(
    BuildContext context,
    Function(String varCategory, String varName) onSelectVariable,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => MobileReceiptVarSheet(
        onSelectVariable: onSelectVariable,
      ),
    );
  }

  @override
  State<MobileReceiptVarSheet> createState() => _MobileReceiptVarSheetState();
}

class _MobileReceiptVarSheetState extends State<MobileReceiptVarSheet> {
  String selectedCategory = 'Free Text';
  String selectedVarName = 'Text';

  final List<Map<String, String>> weightVars = [
    {"display": "NO.", "name": "NO."},
    {"display": "Gross", "name": "Gross"},
    {"display": "Tare", "name": "Tare"},
    {"display": "Net", "name": "Net"},
    {"display": "PCS", "name": "PCS"},
    {"display": "WeightUnit", "name": "WeightUnit"},
    {"display": "Date", "name": "DATE"},
    {"display": "Time", "name": "TIME"},
    {"display": "U.WGT", "name": "U.WGT"},
    {"display": "U.WU", "name": "U.WU"},
    {"display": "UnitWeight", "name": "UnitWeight"},
    {"display": "Percent", "name": "Percent"},
    {"display": "TotalWeight", "name": "TotalWeight"},
    {"display": "TotalCount", "name": "TotalCount"},
  ];

  final List<Map<String, String>> priceVars = [
    {"display": "NO.", "name": "NO._P"},
    {"display": "Header1", "name": "Header1_P"},
    {"display": "Header2", "name": "Header2_P"},
    {"display": "Header3", "name": "Header3_P"},
    {"display": "Footer1", "name": "Footer1_P"},
    {"display": "Footer2", "name": "Footer2_P"},
    {"display": "Footer3", "name": "Footer3_P"},
    {"display": "PLU_ID", "name": "PLU_ID_P"},
    {"display": "PLU_Name", "name": "PLU_Name_P"},
    {"display": "Order Number", "name": "OrderNumber_P"},
    {"display": "Unit Price", "name": "UnitPrice_P"},
    {"display": "Price Unit", "name": "PriceUnit_P"},
    {"display": "Price", "name": "Price_P"},
    {"display": "Weight Pcs", "name": "Weight_Pcs_P"},
    {"display": "Tare", "name": "Tare_P"},
    {"display": "Unit", "name": "Unit_P"},
    {"display": "Date", "name": "DATE"},
    {"display": "Time", "name": "TIME"},
    {"display": "Tax Type1", "name": "TaxType1_P"},
    {"display": "Tax Type2", "name": "TaxType2_P"},
    {"display": "Tax Type3", "name": "TaxType3_P"},
    {"display": "Tax Amount1", "name": "TaxAmount1_P"},
    {"display": "Tax Amount2", "name": "TaxAmount2_P"},
    {"display": "Tax Amount3", "name": "TaxAmount3_P"},
    {"display": "Tax Model", "name": "TaxModel_P"},
    {"display": "Total Tax Amount", "name": "TotalTaxAmount_P"},
    {"display": "Payment Amount", "name": "PaymentAmount_P"},
    {"display": "Change Amount", "name": "ChangeAmount_P"},
    {"display": "Subtotal", "name": "Subtotal_P"},
    {"display": "Currency", "name": "Currency_P"},
    {"display": "Copy Times", "name": "CopyTimes_P"},
    {"display": "Model Name", "name": "ModelName_P"},
    {"display": "Scale Name", "name": "ScaleName_P"},
    {"display": "Tax Name", "name": "TaxName_P"},
    {"display": "Settle Account Times", "name": "SettleAccountTimes_P"},
    {"display": "PLU Tax", "name": "PLU_Tax_P"},
    {"display": "Total No Tax", "name": "TotalNoTax_P"},
  ];

  void _handleConfirm() {
    widget.onSelectVariable(selectedCategory, selectedVarName);
    Navigator.pop(context);
  }

  Widget _buildVarButton(
      String category, String varName, String labelText, {double ratio = 2.4}) {
    final isSelected =
        selectedCategory == category && selectedVarName == varName;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
          selectedVarName = varName;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF005696) : const Color(0xFFF6F6F6),
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        labelText,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Header with Title Style and Close Icon
            Row(
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
                  icon: const Icon(Icons.cancel_outlined,
                      color: Colors.black54, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Free Text & Dividing Line
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Free Text",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF005696),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 38,
                                width: double.infinity,
                                child: _buildVarButton(
                                    'Free Text', 'Text', 'Text'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Dividing Line",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF005696),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 38,
                                width: double.infinity,
                                child: _buildVarButton(
                                    'Dividing Line', 'Line', 'Line'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Section 2: Weight Variable (Free Text section title matching mockup)
                    const Text(
                      "Free Text",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005696),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.4,
                      ),
                      itemCount: weightVars.length,
                      itemBuilder: (ctx, idx) {
                        final item = weightVars[idx];
                        return _buildVarButton(
                          'Weight Variable',
                          item['name']!,
                          item['display']!,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Section 3: Price Variable (Free Text section title matching mockup)
                    const Text(
                      "Free Text",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005696),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.4,
                      ),
                      itemCount: priceVars.length,
                      itemBuilder: (ctx, idx) {
                        final item = priceVars[idx];
                        return _buildVarButton(
                          'Price Variable',
                          item['name']!,
                          item['display']!,
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom Action Button: Confirm (Green #1CB079)
            Container(
              padding: const EdgeInsets.only(top: 8),
              width: double.infinity,
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1CB079), // Green Confirm button
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
