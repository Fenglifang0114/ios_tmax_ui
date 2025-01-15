import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String titleText;
  final VoidCallback onNoPressed;
  final VoidCallback onYesPressed;

  const CustomAlertDialog({
    super.key,
    required this.titleText,
    required this.onNoPressed,
    required this.onYesPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // 使用Dialog作为基础组件来构建自定义对话框外观
      title: Text(titleText),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onNoPressed,
              child: Text('No'),
            ),
            TextButton(
              onPressed: onYesPressed,
              child: Text('Yes'),
            ),
          ],
        ),
      ],
    );
  }
}

void showServiceErrorDialog(
    BuildContext context, String tipStr, String confirmMsg) {
  showDialog(
    context: context,
    barrierDismissible: false, // 允许点击空白处关闭对话框
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(
          confirmMsg,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: SizedBox(
          width: 300,
          height: 70,
          child: Text(
            tipStr,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: <Widget>[],
      );
    },
  );
}
