import 'dart:io';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/widget/common_widget.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: Text(
        titleText,
        style: Theme.of(context).textTheme.bodyLarge!.apply(),
      ),
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
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            children: [
              // 头部
              Container(
                  height: dialogTitleheight,
                  padding: const EdgeInsets.only(
                      left: largePadding, right: largePadding),
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          confirmMsg,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ])),
              // 分割线
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        left: largePadding,
                        right: largePadding,
                        top: 0,
                        bottom: 0),
                    child: Text(
                      tipStr,
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  )
                ],
              )),
              showTextButton(context, 36, 'Exit', () {
                exit(0);
              },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.onSurface),
              SizedBox(
                height: regularPadding,
              )
            ],
          ),
        ),
      );
    },
  );
}
