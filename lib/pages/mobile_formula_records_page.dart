import 'package:flutter/material.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/pages/mobile_formula_auto_sync_page.dart';
import 'package:t_max/pages/mobile_formula_print_settings_page.dart';

class MobileFormulaRecordsPage extends StatefulWidget {
  const MobileFormulaRecordsPage({super.key});

  @override
  State<MobileFormulaRecordsPage> createState() =>
      _MobileFormulaRecordsPageState();
}

class _MobileFormulaRecordsPageState extends State<MobileFormulaRecordsPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedRecordIds = {};
  final Set<String> _expandedRecordIds = {'F-20260623130909'};

  // Mock records data matching the design mockup for Formula Records
  final List<Map<String, dynamic>> _recordsList = [
    {
      'recordId': 'F-20260623130909',
      'id': '01',
      'name': '02',
      'barcode': '02',
      'mode': 'Weight',
      'confidential': 'Public',
      'formulaTotalWeight': '10.000 kg',
      'actualTotalWeight': '9.850 kg',
      'pass': true,
      'createTime': '2026-06-23 13:09:55',
      'operator': 'Margaret',
      'ingredients': [
        {
          'ingredientName': '01',
          'ingredientId': '01',
          'ingredientWeight': '10.000 kg',
          'actualIngredientWeight': '10.000 kg',
          'allowableError': '10.000 kg',
          'actualError': '310.000 kg',
          'pass': true,
          'deviceName': 'Scale1',
        },
        {
          'ingredientName': '01',
          'ingredientId': '01',
          'ingredientWeight': '10.000 kg',
          'actualIngredientWeight': '10.000 kg',
          'allowableError': '10.000 kg',
          'actualError': '310.000 kg',
          'pass': true,
          'deviceName': 'Scale1',
        },
      ],
    },
    {
      'recordId': 'F-20260623130908',
      'id': '02',
      'name': 'Beef Mix',
      'barcode': '03',
      'mode': 'Weight',
      'confidential': 'Public',
      'formulaTotalWeight': '5.000 kg',
      'actualTotalWeight': '5.010 kg',
      'pass': true,
      'createTime': '2026-06-23 12:45:10',
      'operator': 'John',
      'ingredients': [
        {
          'ingredientName': 'Salt',
          'ingredientId': '05',
          'ingredientWeight': '0.500 kg',
          'actualIngredientWeight': '0.502 kg',
          'allowableError': '0.010 kg',
          'actualError': '0.002 kg',
          'pass': true,
          'deviceName': 'Scale1',
        },
      ],
    },
    {
      'recordId': 'F-20260623130907',
      'id': '03',
      'name': 'Pork Secret',
      'barcode': '04',
      'mode': 'Weight',
      'confidential': 'Confidential',
      'formulaTotalWeight': '20.000 kg',
      'actualTotalWeight': '19.980 kg',
      'pass': true,
      'createTime': '2026-06-23 11:20:00',
      'operator': 'Alice',
      'ingredients': [],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpand(String recordId) {
    setState(() {
      if (_expandedRecordIds.contains(recordId)) {
        _expandedRecordIds.remove(recordId);
      } else {
        _expandedRecordIds.add(recordId);
      }
    });
  }

  void _openPrintSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MobileFormulaPrintSettingsPage(),
      ),
    );
  }

  void _openAutoSync() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MobileFormulaAutoSyncPage(),
      ),
    );
  }

  Widget _buildKeyValuePair(String label, String value, {Widget? extraValueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          extraValueWidget ??
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildVerticalField(String label, String value, {Widget? customChild, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        customChild ??
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
      ],
    );
  }

  Widget _buildIngredientCard(Map<String, dynamic> ing) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildVerticalField(
                  'Ingredient Name',
                  ing['ingredientName'] ?? '',
                  valueColor: const Color(0xFF004884),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVerticalField(
                  'Ingredient ID',
                  ing['ingredientId'] ?? '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVerticalField(
                  'Ingredient Weight',
                  ing['ingredientWeight'] ?? '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVerticalField(
                  'Actual Ingredient Weight',
                  ing['actualIngredientWeight'] ?? '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVerticalField(
                  'Allowable Error',
                  ing['allowableError'] ?? '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVerticalField(
                  'Actual Error',
                  ing['actualError'] ?? '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVerticalField(
                  'Pass',
                  '',
                  customChild: ing['pass'] == true
                      ? const Icon(Icons.check, color: Color(0xFF004884), size: 20)
                      : const Icon(Icons.close, color: Colors.red, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVerticalField(
                  'Device name',
                  ing['deviceName'] ?? 'Scale1',
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        title: Text(
          S.of(context).fRecordTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Please enter',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon:
                        Icon(Icons.search, size: 18, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            // Records Accordion List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _recordsList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  var rec = _recordsList[index];
                  String recId = rec['recordId'];
                  bool isExpanded = _expandedRecordIds.contains(recId);
                  bool isChecked = _selectedRecordIds.contains(recId);
                  List ingredients = rec['ingredients'] ?? [];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        // Card Header Row
                        InkWell(
                          onTap: () => _toggleExpand(recId),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  activeColor: const Color(0xFF004884),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedRecordIds.add(recId);
                                      } else {
                                        _selectedRecordIds.remove(recId);
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  recId,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004884),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.print_outlined,
                                      color: Colors.black54, size: 20),
                                  onPressed: () {},
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expanded Content
                        if (isExpanded) ...[
                          const Divider(height: 1, thickness: 0.5),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                // Formula Summary Info
                                _buildKeyValuePair('ID', rec['id'] ?? ''),
                                _buildKeyValuePair('Name', rec['name'] ?? ''),
                                _buildKeyValuePair(
                                    'Barcode', rec['barcode'] ?? ''),
                                _buildKeyValuePair('Mode', rec['mode'] ?? ''),
                                _buildKeyValuePair(
                                    'Confidential', rec['confidential'] ?? ''),
                                _buildKeyValuePair('Formula Total Weight',
                                    rec['formulaTotalWeight'] ?? ''),
                                _buildKeyValuePair('Actual Total Weight',
                                    rec['actualTotalWeight'] ?? ''),
                                _buildKeyValuePair(
                                  'Pass',
                                  '',
                                  extraValueWidget: rec['pass'] == true
                                      ? const Icon(Icons.check,
                                          color: Color(0xFF004884), size: 18)
                                      : const Icon(Icons.close,
                                          color: Colors.red, size: 18),
                                ),
                                _buildKeyValuePair(
                                    'Create Time', rec['createTime'] ?? ''),
                                _buildKeyValuePair(
                                    'Operator', rec['operator'] ?? ''),

                                // Ingredient Details Section
                                if (ingredients.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  for (var ing in ingredients)
                                    _buildIngredientCard(ing),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _openPrintSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004884),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Print Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _openAutoSync,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004884),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Auto Sync',
                          style: TextStyle(
                            fontSize: 14,
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
          ],
        ),
      ),
    );
  }
}
