import 'package:flutter/material.dart';

waitingBuildDialog(BuildContext context) {
  return showDialog(
      barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            content: Row(
              children: [
                Text("Coming soon!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20))
              ],
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // to go back to screen after submitting
                      }),
                  const SizedBox(width: 20),
                ],
              )
            ],
          );
        }));
      });
}
