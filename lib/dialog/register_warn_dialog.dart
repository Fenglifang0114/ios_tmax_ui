import 'package:flutter/material.dart';

registerWarnDialog(BuildContext context) {
  return showDialog(
      barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            // insetPadding: const EdgeInsets.all(15.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            titlePadding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
            title: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                width: 200,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),
                    Icon(
                      Icons.message,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "提示信息！",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      maxLines: 3,
                    ),
                  ],
                )),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            content: const SizedBox(
              width: 200,
              height: 80,
              child: Text("您输入的许可ID不正确，请检查后重新输入！"),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                      child: const Text("关闭"),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // to go back to screen after submitting
                      })
                ],
              )
            ],
          );
        }));
      });
}
