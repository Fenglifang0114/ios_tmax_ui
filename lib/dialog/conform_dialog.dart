import 'package:flutter/material.dart';

confirmDialog(BuildContext context, String message) {
  return showDialog(
    barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Row(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); // 退出当前页面
                },
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                child: const Text("Confirm"),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
