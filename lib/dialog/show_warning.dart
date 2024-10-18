import 'package:flutter/material.dart';

void showWarningDialog(BuildContext context, void Function(bool) onOKPressed) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned.fill(
              // 将 AlertDialog 浮动在后面的页面上方
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.transparent, // 设置背景颜色为透明，以将点击事件传递给后面的页面
                ),
              ),
            ),
            Center(
              child: AlertDialog(
                title: Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: Row(
                      children: [
                        Text("Warning",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary))
                      ],
                    )),
                content: Container(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceBright),
                  child: const Text(
                    "You cannot switch units during the process, please switch back to the original unit. ",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                          child: const Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop(
                                false); // to go back to screen after submitting
                            onOKPressed(true);
                          }),
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  });
}
