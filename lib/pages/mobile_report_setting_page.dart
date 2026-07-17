import 'package:flutter/material.dart';
import 'package:t_max/data/language.dart';

class MobileReportSettingPage extends StatefulWidget {
  final Map<String, String> options;
  final List<String> initialSelectedOptions;

  const MobileReportSettingPage({
    Key? key,
    required this.options,
    required this.initialSelectedOptions,
  }) : super(key: key);

  @override
  State<MobileReportSettingPage> createState() => _MobileReportSettingPageState();
}

class _MobileReportSettingPageState extends State<MobileReportSettingPage> {
  late List<String> _selectedOptions;
  late bool _isSelectAll;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.from(widget.initialSelectedOptions);
    _checkSelectAll();
  }

  void _checkSelectAll() {
    _isSelectAll = widget.options.keys.every((key) => _selectedOptions.contains(key));
  }

  void _toggleOption(String key, bool? value) {
    setState(() {
      if (value == true) {
        if (!_selectedOptions.contains(key)) {
          _selectedOptions.add(key);
        }
      } else {
        if (key != 'plu' && key != 'productName') {
          _selectedOptions.remove(key);
        }
      }
      _checkSelectAll();
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _isSelectAll = value ?? false;
      if (_isSelectAll) {
        _selectedOptions = widget.options.keys.toList();
      } else {
        _selectedOptions = ['plu', 'productName'];
      }
    });
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF2E7D32),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> keys = widget.options.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizedStrings?.gBtnReportSetting ?? 'Report Setting',
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: (keys.length / 2).ceil() + 1,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                if (index == (keys.length / 2).ceil()) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildCheckbox(
                          localizedStrings?.gSelectAll ?? "select all",
                          _isSelectAll,
                          _toggleSelectAll,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  );
                }

                int firstIndex = index * 2;
                int secondIndex = index * 2 + 1;

                String firstKey = keys[firstIndex];
                String? secondKey = secondIndex < keys.length ? keys[secondIndex] : null;

                return Row(
                  children: [
                    Expanded(
                      child: _buildCheckbox(
                        widget.options[firstKey] ?? '',
                        _selectedOptions.contains(firstKey),
                        (val) => _toggleOption(firstKey, val),
                      ),
                    ),
                    Expanded(
                      child: secondKey != null
                          ? _buildCheckbox(
                              widget.options[secondKey] ?? '',
                              _selectedOptions.contains(secondKey),
                              (val) => _toggleOption(secondKey, val),
                            )
                          : const SizedBox(),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedOptions);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28B47C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  localizedStrings?.gBtnConfirm ?? "Confirm",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
