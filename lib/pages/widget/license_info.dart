import 'package:flutter/material.dart';

import 'package:t_max/data/license_data.dart';

import '../../generated/l10n.dart';

class LicenseInfoDialog extends StatefulWidget {
  const LicenseInfoDialog({super.key});

  @override
  _LicenseInfoDialogState createState() => _LicenseInfoDialogState();
}

class _LicenseInfoDialogState extends State<LicenseInfoDialog> {
  final TextEditingController pidController = TextEditingController();
  String pId = '';
  String dueDate = '';
  bool isPass = false;

  dynamic localizedStrings;
  String systemId = '';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void initState() {
    super.initState();
    pidController.text = systemId;
  }

  @override
  void dispose() {
    pidController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);
    systemId = localizedStrings.system_id;
    if (myLicenseData.data.isNotEmpty) {
      List<String> strList = myLicenseData.data.split(',');
      pId = strList[1]; // id
      dueDate = strList[2];
      if (strList[0] == 'true') {
        isPass = true;
      }
      pidController.text = systemId + pId;
    }
    return AlertDialog(
      title: Container(
        color: Colors.blue.shade900,
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            Text(
              localizedStrings.license_title,
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
      content: Container(
        height: 300,
        width: 400,
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 233, 232, 232)),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: pidController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 100,
                        child: Text(
                            (isPass)
                                ? localizedStrings.passed_message
                                : localizedStrings.passed_fail_message,
                            style: TextStyle(
                                fontSize: 16,
                                color: (isPass)
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.red.shade900)),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                          (dueDate.isEmpty)
                              ? ''
                              : localizedStrings.expiration_date + dueDate,
                          style: TextStyle(
                              fontSize: 16,
                              color: (isPass)
                                  ? Colors.green.shade900
                                  : Colors.red.shade900)),
                      const SizedBox(
                        height: 60,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 20),
            OutlinedButton(
              child: Text(localizedStrings.button_ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }
}
