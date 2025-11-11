import 'package:flutter/material.dart';

Widget buildDropdownButton({
  required BuildContext context,
  required String? value,
  required List items,
  required String hintText,
  required void Function(String) onSelect,
}) {
  if (items.isEmpty) {
    return Container();
  }
  if (!items.contains(value)) {
    value = items.first.toString();
  }

  return DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant), // 边框颜色
        borderRadius: BorderRadius.circular(0), // 圆角
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant), // 未选中时的边框
        borderRadius: BorderRadius.circular(0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.primary), // 选中时的边框
        borderRadius: BorderRadius.circular(0),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    ),
    style: Theme.of(context).textTheme.bodySmall,
    hint: Text(hintText, style: Theme.of(context).textTheme.bodySmall),
    items: items
        .map(
          (entry) => DropdownMenuItem<String>(
            value: entry.toString(),
            child: Text(entry.toString()),
          ),
        )
        .toList(),
    onChanged: (String? newValue) {
      if (newValue != null) {
        onSelect(newValue);
      }
    },
  );
}
