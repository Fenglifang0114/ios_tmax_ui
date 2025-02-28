import 'package:flutter/material.dart';
import '../data/language.dart';
import '../data/plu_field_status_data.dart';
import '../widget/custom_button.dart';

class MultiSelectDialog extends StatefulWidget {
  final Map<String, FieldNameStatus> options;

  const MultiSelectDialog(
      {required this.options, super.key, required BuildContext context});

  @override
  MultiSelectDialogState createState() => MultiSelectDialogState();
}

class MultiSelectDialogState extends State<MultiSelectDialog> {
  final List<String> _selectedOptions = [];

  bool closeButtonEnabled = true;
  bool isSelectAll = false;

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        if (option != 'plu' && option != 'productName') {
          _selectedOptions.remove(option);
        }
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  void _closeDialog() {
    Navigator.of(context).pop(_selectedOptions);
  }

  @override
  void initState() {
    super.initState();
    // 在初始化时将options的所有键添加到_selectedOptions中

    for (var entry in widget.options.entries) {
      if (entry.value.isSelected) {
        _selectedOptions.add(entry.key);
      }
    }
  }

  // 全选方法
  void selectAll(bool value) {
    setState(() {
      _selectedOptions.clear();
      if (!value) {
        _selectedOptions.add('plu');
        _selectedOptions.add('productName');
      }

      for (var entry in widget.options.entries) {
        if (value) {
          _selectedOptions.add(entry.key);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(
          context, localizedStrings.gPluField, Icons.edit_note_outlined, 300),
      content: SizedBox(
        height: 400,
        child: SingleChildScrollView(
            child: Column(
          children: [
            CheckboxListTile(
              title: Text(
                localizedStrings.gSelectAll,
                style: TextStyle(overflow: TextOverflow.ellipsis),
              ),
              value: isSelectAll,
              onChanged: (bool? newValue) {
                setState(() {
                  isSelectAll = newValue!;
                  selectAll(newValue);
                });
              },
            ),
            Column(
              children: widget.options.entries.map((entry) {
                return CheckboxListTile(
                  title: SizedBox(
                    width: 300,
                    child: Text(
                      entry.value.field,
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  value: _selectedOptions.contains(entry.key),
                  onChanged: closeButtonEnabled
                      ? (value) => _toggleOption(entry.key)
                      : null,
                );
              }).toList(),
            ),
          ],
        )),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomOutlinedButton(
              btnWidth: 130,
              btnHeight: 40,
              icon: Icons.exit_to_app,
              text: localizedStrings.gBtnExit,
              onPressed: closeButtonEnabled ? _closeDialog : null,
            ),
          ],
        ),
      ],
    );
  }
}
