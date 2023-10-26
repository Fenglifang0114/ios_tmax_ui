import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:t_max/data/license_data.dart';

import '../../generated/l10n.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';

class LicenseInfoDialog extends StatefulWidget {
  const LicenseInfoDialog({super.key});

  @override
  _LicenseInfoDialogState createState() => _LicenseInfoDialogState();
}

class _LicenseInfoDialogState extends State<LicenseInfoDialog> {
  final TextEditingController pidController = TextEditingController();
  TextEditingController licenseController = TextEditingController();

  String pId = '';
  String dueDate = '';
  bool isPass = false;
  bool licenseKey = false;

  dynamic localizedStrings;
  dynamic _eventbus1;
  String systemId = '';
  String errMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void initState() {
    super.initState();

    pidController.text = systemId;
    licenseController.text = '';
    if (myLicenseInfo.isValid) {
      isPass = myLicenseInfo.isValid;
      licenseKey = myLicenseInfo.isValid;
      pId = myLicenseInfo.pId;
      dueDate = myLicenseInfo.liceseDate;
    } else {
      pId = myLicenseInfo.pId;
    }

    _eventbus1 = eventBus.on<EventCheckLicenseKey>().listen((event) {
      if (mounted) {
        setState(() {
          myLicenseData = event.obj;
          if (myLicenseData.data.isNotEmpty) {
            List<String> strList = myLicenseData.data.split(',');

            if (strList[0] == 'true') {
              licenseKey = true;
              isPass = true;
              pId = strList[1]; // id
              dueDate = strList[2];
            } else {
              licenseKey = false;
            }
            pidController.text = systemId + pId;
          }
          if (licenseKey) {
            if (myLicenseInfo.isValid) {
              if (isLongerValidityPeriod(myLicenseInfo.liceseDate, dueDate)) {
                //要更新最新的日期的license
                updateLicenseInfo();
              } else {
                errMessage = 'The new period is not the latest.';
              }
            } else {
              updateLicenseInfo();
            }
          } else {
            errMessage = 'Invalid license';
          }
        });
      }
    });

    //初始化
    // WebsocketManager.init();
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    pidController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    systemId = localizedStrings.system_id;
    pidController.text = systemId + pId;
    return AlertDialog(
      title: Container(
        color: Theme.of(context).colorScheme.primary,
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
        height: 360,
        width: 400,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
        child: Column(
          children: [
            SizedBox(
              width: 400,
              height: 66,
              child: TextField(
                controller: pidController,
                readOnly: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              child: Text(
                  (isPass)
                      ? localizedStrings.passed_message
                      : localizedStrings.passed_fail_message,
                  style: TextStyle(
                      fontSize: 16,
                      color: (isPass)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error)),
            ),
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(localizedStrings.expiration_date,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ),
                SizedBox(
                  width: 200,
                  child: Text(myLicenseInfo.liceseDate,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.outline,
                      )),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(localizedStrings.new_license_text,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ),
              ],
            ),
            SizedBox(
              width: 400,
              child: TextField(
                controller: licenseController,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 2,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(74),
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-Z0-9\-]+$')), // 允许输入数字和点
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    errMessage = '';
                    isValidLicense();
                  });
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 400,
                  child: ElevatedButton(
                      onPressed: (isValidLicense())
                          ? () {
                              PublicFunctions.checkLicenseKey(
                                  licenseController.text);
                            }
                          : null,
                      child: Text(localizedStrings.button_add_license)),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            errMessage.isNotEmpty
                ? SizedBox(
                    height: 30,
                    child: Text(errMessage,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.error)),
                  )
                : const Text(''),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 20),
            OutlinedButton(
              child: Text(localizedStrings.button_exit),
              onPressed: () {
                myCheckSerialPortOnOFF.isCheck = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

//验证新日期是否可用，true 可用，直接更新，false 询问是否更新
  bool isLongerValidityPeriod(String oldLicenseDate, String newLicenseDate) {
    bool res = false;
    DateTime dateTimeOld = DateTime.parse(oldLicenseDate);
    DateTime dateTimeNew = DateTime.parse(newLicenseDate);

    if (dateTimeOld.isBefore(dateTimeNew)) {
      res = true;
    }
    return res;
  }

  bool isValidLicense() {
    bool res = false;
    String dataStr = licenseController.text;
    if (dataStr.isNotEmpty && utf8.encode(dataStr).length == 74) {
      res = true;
    }
    return res;
  }

  void updateLicenseInfo() {
    myLicenseInfo.isValid = licenseKey;
    myLicenseInfo.pId = pId;
    myLicenseInfo.liceseDate = dueDate;
    PublicFunctions.updateLicense(licenseController.text);
  }
}
