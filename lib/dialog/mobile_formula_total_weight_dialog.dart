import 'package:flutter/material.dart';

class MobileFormulaTotalWeightDialog extends StatefulWidget {
  final double? initialWeight;
  final String? initialUnit;

  const MobileFormulaTotalWeightDialog({
    super.key,
    this.initialWeight,
    this.initialUnit,
  });

  @override
  State<MobileFormulaTotalWeightDialog> createState() =>
      _MobileFormulaTotalWeightDialogState();
}

class _MobileFormulaTotalWeightDialogState
    extends State<MobileFormulaTotalWeightDialog> {
  late TextEditingController _weightController;
  late String _selectedUnit;

  final List<String> _units = ['kg', 'g', 'lb'];

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.initialWeight != null && widget.initialWeight! > 0
          ? (widget.initialWeight! % 1 == 0
              ? widget.initialWeight!.toInt().toString()
              : widget.initialWeight!.toString())
          : '10',
    );
    _selectedUnit = (widget.initialUnit != null && widget.initialUnit!.isNotEmpty)
        ? widget.initialUnit!
        : 'kg';
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    String text = _weightController.text.trim();
    double? wgt = double.tryParse(text);
    if (wgt == null || wgt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight')),
      );
      return;
    }
    Navigator.of(context).pop({
      'totalWgt': wgt,
      'fmaUnit': _selectedUnit,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Formula Total Weight',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weight Input Box with Unit Selector
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter total weight',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _units.contains(_selectedUnit) ? _selectedUnit : _units.first,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        onChanged: (String? val) {
                          if (val != null) {
                            setState(() {
                              _selectedUnit = val;
                            });
                          }
                        },
                        items: _units.map<DropdownMenuItem<String>>((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6), // Green accent color from design screenshot
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
