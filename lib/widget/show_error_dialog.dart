import 'package:flutter/material.dart';

import '../data/language.dart';

void showErrorDialog(BuildContext context, String tipStr) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(
          localizedStrings.gTitleConfirm,
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
        actions: <Widget>[
          SizedBox(
            height: 30,
            child: OutlinedButton(
              child: Text(localizedStrings.gBtnConfirm),
              onPressed: () {
                Navigator.of(context).pop(true); // 跳转
              },
            ),
          )
        ],
      );
    },
  ).then((confirmed) {
    if (confirmed) {}
  });
}
