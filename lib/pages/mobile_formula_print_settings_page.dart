import 'package:flutter/material.dart';

class MobileFormulaPrintSettingsPage extends StatefulWidget {
  const MobileFormulaPrintSettingsPage({super.key});

  @override
  State<MobileFormulaPrintSettingsPage> createState() =>
      _MobileFormulaPrintSettingsPageState();
}

class _MobileFormulaPrintSettingsPageState
    extends State<MobileFormulaPrintSettingsPage> {
  // Map of checkbox states for 2 columns
  final Map<String, bool> _printFields = {
    // Left column
    'Actual Error': true,
    'Operator': true,
    'Barcode': true,
    'Pass': true,
    'Name': true,
    'NO.': true,
    'Id': true,

    // Right column
    'Create Time': true,
    'Ingredient ID': true,
    'Ingredient Name': true,
    'Device name High': true,
    'Actual Total Weight': true,
    'Formula Total Weight': true,
    'Actual Ingredient Weight': true,
  };

  bool _selectAll = true;

  final List<String> _leftFields = [
    'Actual Error',
    'Operator',
    'Barcode',
    'Pass',
    'Name',
    'NO.',
    'Id',
  ];

  final List<String> _rightFields = [
    'Create Time',
    'Ingredient ID',
    'Ingredient Name',
    'Device name High',
    'Actual Total Weight',
    'Formula Total Weight',
    'Actual Ingredient Weight',
  ];

  void _toggleSelectAll(bool? value) {
    bool val = value ?? false;
    setState(() {
      _selectAll = val;
      for (var key in _printFields.keys) {
        _printFields[key] = val;
      }
    });
  }

  void _onFieldChanged(String field, bool? value) {
    setState(() {
      _printFields[field] = value ?? false;
      _selectAll = _printFields.values.every((v) => v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Print Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // 7 Rows of 2 Columns
                    for (int i = 0; i < 7; i++) ...[
                      Row(
                        children: [
                          // Left Column Item
                          Expanded(
                            child: CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                _leftFields[i],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              value: _printFields[_leftFields[i]] ?? false,
                              activeColor: const Color(0xFF004884),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (val) =>
                                  _onFieldChanged(_leftFields[i], val),
                            ),
                          ),

                          // Right Column Item
                          Expanded(
                            child: CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                _rightFields[i],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              value: _printFields[_rightFields[i]] ?? false,
                              activeColor: const Color(0xFF004884),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (val) =>
                                  _onFieldChanged(_rightFields[i], val),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 1, thickness: 0.5),
                    ],

                    // Row 8: Select all checkbox (Left)
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Select all',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: _selectAll,
                            activeColor: const Color(0xFF004884),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: _toggleSelectAll,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Green Confirm Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
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
            ),
          ],
        ),
      ),
    );
  }
}
