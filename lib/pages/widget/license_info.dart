import 'package:flutter/material.dart';

import 'package:t_max/data/license_data.dart';

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

  @override
  void initState() {
    super.initState();
    pidController.text = '';

    if (myLicenseData.data.isNotEmpty) {
      List<String> strList = myLicenseData.data.split(',');
      pId = strList[1]; // id
      dueDate = strList[2];
      if (strList[0] == 'true') {
        isPass = true;
      }
      pidController.text = 'System Unique ID: $pId';
    }
  }

  @override
  void dispose() {
    pidController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        color: Colors.blue.shade900,
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            Text(
              "License information",
              style: TextStyle(color: Colors.white),
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
                                ? ''
                                : " No authentication. \r\n\r\n  Please send the system unique ID to us.\r\n\r\nEmail:sales@taiwanscale.com",
                            style: TextStyle(
                                fontSize: 16,
                                color: (isPass)
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.red.shade900)),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Text((dueDate.isEmpty) ? '' : "Expiration date: $dueDate",
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
              child: const Text("OK"),
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
