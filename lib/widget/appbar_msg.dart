import 'package:flutter/material.dart';

appbarMsg(context) {
  DateTime now = DateTime.now();
  return Row(
    children: [
      SizedBox(
        height: 20,
        child: Row(
          children: [
            Text(
                "当前时间：${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${(now.hour.toString().padLeft(2, '0'))}:${(now.minute.toString().padLeft(2, '0'))}:${(now.second.toString().padLeft(2, '0'))}"),
            const SizedBox(width: 30),
          ],
        ),
      ),
    ],
  );
}
