import 'package:flutter/material.dart';
import 'package:t_max/pages/add_formula_page.dart';

class MobileModifyIngredientPage extends StatefulWidget {
  final AddFormulaRawWgtInfo rawInfo;
  final String unit;

  const MobileModifyIngredientPage({
    super.key,
    required this.rawInfo,
    this.unit = 'kg',
  });

  @override
  State<MobileModifyIngredientPage> createState() => _MobileModifyIngredientPageState();
}

class _MobileModifyIngredientPageState extends State<MobileModifyIngredientPage> {
  late TextEditingController _weightController;
  late TextEditingController _errorController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.rawInfo.wgt > 0 ? widget.rawInfo.wgt.toString() : '',
    );
    _errorController = TextEditingController(
      text: widget.rawInfo.error > 0 ? widget.rawInfo.error.toString() : '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  bool _canConfirm() {
    double? wgt = double.tryParse(_weightController.text.trim());
    double? err = double.tryParse(_errorController.text.trim());
    return wgt != null && wgt > 0 && err != null && err >= 0;
  }

  void _onConfirm() {
    double wgt = double.parse(_weightController.text.trim());
    double err = double.parse(_errorController.text.trim());

    // Update values
    widget.rawInfo.wgt = wgt;
    widget.rawInfo.error = err;

    Navigator.pop(context, widget.rawInfo);
  }

  @override
  Widget build(BuildContext context) {
    String matId = widget.rawInfo.rawDataInfo.materialId ?? '';
    String matName = widget.rawInfo.rawDataInfo.materialName ?? '';
    String ingredientDisplay = matId.isNotEmpty ? matId : matName;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Modify',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Field 1: Select Ingredient (Read-only / Displayed)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '* ',
                            style: TextStyle(color: Colors.red, fontSize: 15),
                          ),
                          const Text(
                            'Select Ingredient',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            ingredientDisplay,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Field 2: Weight
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '* ',
                            style: TextStyle(color: Colors.red, fontSize: 15),
                          ),
                          const Text(
                            'Weight',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _weightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Weight',
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.unit,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Field 3: Allowable Error
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '* ',
                            style: TextStyle(color: Colors.red, fontSize: 15),
                          ),
                          const Text(
                            'Allowable Error',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _errorController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Error',
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '±',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Confirm Button (Green #10B981)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _canConfirm() ? _onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
