import 'package:flutter/material.dart';

import 'TimerWidget.dart';

appbarMsg(context) {
  DateTime now = DateTime.now();
  return Row(
    children: [
      SizedBox(
        height: 20,
        child: Row(
          children: [
            SizedBox(
              child: TimerWidget(),
            ),

            Text(
                "当前时间：${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${(now.hour.toString().padLeft(2, '0'))}:${(now.minute.toString().padLeft(2, '0'))}:${(now.second.toString().padLeft(2, '0'))}"),
            const SizedBox(width: 30),
            // Text("Current device:" + myDevicedata.name + "  "),
            // const SizedBox(width: 30),
            // Text("Current user:" + myUserData.userName + "  "),
          ],
        ),
      ),
      // const SizedBox(width: 30),
      // TextButton(
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //     child: const Text(
      //       "返回",
      //       style: TextStyle(color: Colors.white),
      //     ))
    ],
  );
}
