import 'package:flutter/material.dart';

import '../data/language.dart';
import '../widget/custom_button.dart';

void showConfirmationDialog(BuildContext context, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          localizedStrings.confirm_title,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(message),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomOutlinedButton(
                btnWidth: 120,
                btnHeight: 40,
                icon: Icons.check_circle,
                text: localizedStrings.button_ok,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      );
    },
  );
}
