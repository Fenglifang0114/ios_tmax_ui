import 'package:flutter/material.dart';

Widget buildDropdownButton({
  required String? value,
  required List items,
  required String hintText,
  required void Function(String) onSelect,
}) {
  return DropdownButton<String>(
    value: value,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    hint: Text(
      hintText,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
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
