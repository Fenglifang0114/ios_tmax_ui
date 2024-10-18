import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:t_max/data/license_data.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../data/setting_version_info.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../widget/custom_button.dart';

class LicenseInfoDialog extends StatefulWidget {
  const LicenseInfoDialog({super.key});

  @override
  LicenseInfoDialogState createState() => LicenseInfoDialogState();
}

class LicenseInfoDialogState extends State<LicenseInfoDialog> {
  final TextEditingController pidController = TextEditingController();
  TextEditingController licenseController = TextEditingController();

  String pId = '';
  String dueDate = '';
  bool isPass = false;
  bool licenseKey = false;
  String moduleName = '';
  LicenseInfo newLicInfo = LicenseInfo(false, '', '', '');
  List<String> licList = [];

  dynamic _eventbus1;
  dynamic _eventbus2;
  String systemId = '';
  String errMessage = '';

  @override
  void initState() {
    super.initState();

    pidController.text = systemId;
    licenseController.text = '';
    if (mySystemVersion == 1) {
      //t-config
      if (myTConLicInfo.isValid) {
        isPass = myTConLicInfo.isValid;
        licenseKey = myTConLicInfo.isValid;
        pId = myTConLicInfo.pId;
        dueDate = myTConLicInfo.liceseDate;
      } else {
        pId = myLicenseInfo.pId;
        isPass = myLicenseInfo.isValid;
        licenseKey = myLicenseInfo.isValid;
        pId = myLicenseInfo.pId;
        dueDate = myLicenseInfo.liceseDate;
      }
    } else {
      pId = myLicenseInfo.pId;
      isPass = false;
      licenseKey = false;
      dueDate = '';
    }

    _eventbus1 = eventBus.on<EventCheckLicenseKey>().listen((event) {
      if (mounted) {
        setState(() {
          var jsonStr = event.obj;
          if (jsonStr.isNotEmpty) {
            List<String> strList = jsonStr.split(',');
            if (strList.length == 4) {
              if (strList[1] == 'true') {
                moduleName = strList[0];
                licenseKey = true;
                isPass = true;
                pId = strList[2]; // id
                dueDate = strList[3];
                newLicInfo.pId = pId;
                newLicInfo.liceseDate = dueDate;
                newLicInfo.moduleName = moduleName;
                newLicInfo.isValid = licenseKey;
              } else {
                licenseKey = false;
              }
            }
          }
          if (licenseKey) {
            findLicType(moduleName);
          } else {
            errMessage = 'Invalid license';
            _showConfirmationDialog(context, '${licList[0]}\r\n$errMessage');
          }
        });
      }
    });
    _eventbus2 = eventBus.on<EventRespUpdateLic>().listen((event) {
      if (mounted) {
        setState(() {
          var jsonStr = event.obj;
          if (jsonStr.isNotEmpty) {
            errMessage = jsonStr;
          }
        });

        _showConfirmationDialog(context, '${licList[0]}\r\n$errMessage');
      }
    });

    //初始化
    // WebsocketManager.init();
  }

  void nextLicCheck() {
    if (licList.length >= 2) {
      licList.removeAt(0);
      PublicFunctions.checkLicenseKey(licList[0]);
    } else {
      licList.clear();
    }
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    pidController.dispose();

    licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    systemId = localizedStrings.system_id;
    pidController.text = systemId + pId;
    return AlertDialog(
      title: getDialogTitle(
          context, localizedStrings.license_title, Icons.key, 420),
      content: Container(
        height: 360,
        width: 420,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: ListView(
          children: [
            SizedBox(
              width: 420,
              height: 50,
              child: TextField(
                controller: pidController,
                readOnly: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).colorScheme.primary),
              ),
            ),
             
            (mySystemVersion != 1)
                ? const SizedBox()
                : SizedBox(
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
                (mySystemVersion != 1)
                    ? const SizedBox()
                    : SizedBox(
                        width: 200,
                        child: Text(localizedStrings.expiration_date,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            )),
                      ),
                (mySystemVersion != 1)
                    ? const SizedBox()
                    : SizedBox(
                        width: 200,
                        child: Text(myTConLicInfo.liceseDate,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            )),
                      ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: Text(localizedStrings.new_license_text,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ),
                CustomElevatedButton(
                  btnWidth: 164,
                  btnHeight: 40,
                  icon: Icons.file_open_outlined,
                  text: localizedStrings.btn_add_lic_file,
                  onPressed: () async {
                    String filePath = '';
                    try {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['txt'],
                      );
                      if (result != null && result.files.isNotEmpty) {
                        filePath = result.files.single.path!;
                      }
                      setState(() {
                        if (filePath != '') {
                          licenseController.text = filePath;
                        }
                      });
                    } catch (e) {
                      setState(() {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Open fail',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)), ////此处需要秤回复
                            duration: const Duration(seconds: 5),
                            backgroundColor:
                                Theme.of(context).colorScheme.error));
                      });
                    }

                    // PublicFunctions.checkLicenseKey(licenseController.text);
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 400,
              child: TextField(
                readOnly: true,
                controller: licenseController,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  btnWidth: 360,
                  btnHeight: 40,
                  icon: Icons.add_box_outlined,
                  text: localizedStrings.button_add_license,
                  onPressed: (licenseController.text.isNotEmpty)
                      ? () async {
                          await validLicense();
                          if (licList.isNotEmpty) {
                            PublicFunctions.checkLicenseKey(licList[0]);
                          }
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.exit_to_app,
              text: localizedStrings.button_exit,
              onPressed: () {
                myScreenMgr.isMainScreen = true;
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

  Future validLicense() async {
    String dataStr = licenseController.text;
    if (dataStr.isNotEmpty) {
      try {
        File file = File(dataStr);
        String content = await file.readAsString();
        licList = content.split('\r\n');
        List<String> tmpList = [];
        for (var i = 0; i < licList.length; i++) {
          if (licList[i].length == 74 || licList[i].length == 78) {
            tmpList.add(licList[i]);
          }
        }
        licList = tmpList;
      } catch (e) {
        // print('读取文件时出错: $e');
        return;
      }
    }
  }

  void updateLicenseInfo() {
    PublicFunctions.updateLicense(licList[0]);
  }

  void findLicType(String moduleNameStr) {
    switch (moduleNameStr) {
      case tConfigLic:
        if (myTConLicInfo.isValid) {
          if (isLongerValidityPeriod(myTConLicInfo.liceseDate, dueDate)) {
            myTConLicInfo = newLicInfo;
            updateLicenseInfo();
          } else {
            errMessage = 'The new period is not the latest.';
            _showConfirmationDialog(context, '${licList[0]}\r\n$errMessage');
          }
        } else {
          myTConLicInfo = newLicInfo;
          updateLicenseInfo();
        }

        break;
      case redeLic:
        if (myRedeLicInfo.isValid) {
          if (isLongerValidityPeriod(myRedeLicInfo.liceseDate, dueDate)) {
            myRedeLicInfo = newLicInfo;
            updateLicenseInfo();
          } else {
            errMessage = 'The new period is not the latest.';
            _showConfirmationDialog(context, '${licList[0]}\r\n$errMessage');
          }
        } else {
          myRedeLicInfo = newLicInfo;
          updateLicenseInfo();
        }

        break;
      case wedaLic:
        if (myWedaLicInfo.isValid) {
          if (isLongerValidityPeriod(myWedaLicInfo.liceseDate, dueDate)) {
            myWedaLicInfo = newLicInfo;
            updateLicenseInfo();
          } else {
            errMessage = 'The new period is not the latest.';
            _showConfirmationDialog(context, '${licList[0]}\r\n$errMessage');
          }
        } else {
          myWedaLicInfo = newLicInfo;
          updateLicenseInfo();
        }

        break;
      case chweLic:
        if (myChweLicInfo.isValid) {
          if (isLongerValidityPeriod(myChweLicInfo.liceseDate, dueDate)) {
            myChweLicInfo = newLicInfo;
            updateLicenseInfo();
          } else {
            errMessage = 'The new period is not the latest.';
            _showConfirmationDialog(context, '${licList[0]}\r\n$errMessage');
          }
        } else {
          myChweLicInfo = newLicInfo;
          updateLicenseInfo();
        }

        break;
      case inweLic:
        if (myInWeLicInfo.isValid) {
          if (isLongerValidityPeriod(myInWeLicInfo.liceseDate, dueDate)) {
            myInWeLicInfo = newLicInfo;
            updateLicenseInfo();
          } else {
            errMessage = 'The new period is not the latest.';
            _showConfirmationDialog(context, '${licList[0]}\r\n$errMessage');
          }
        } else {
          myInWeLicInfo = newLicInfo;
          updateLicenseInfo();
        }

        break;
      case taouLic:
        if (myTaouLicInfo.isValid) {
          if (isLongerValidityPeriod(myTaouLicInfo.liceseDate, dueDate)) {
            myTaouLicInfo = newLicInfo;
            updateLicenseInfo();
          } else {
            errMessage = 'The new period is not the latest.';
            _showConfirmationDialog(context, '${licList[0]}\r\n$errMessage');
          }
        } else {
          myTaouLicInfo = newLicInfo;
          updateLicenseInfo();
        }
        break;
      default:
        break;
    }
  }

  void _showConfirmationDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.confirm_title,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(msg),
          actions: <Widget>[
            OutlinedButton(
              child: Text(localizedStrings.confirm_btn),
              onPressed: () {
                Navigator.of(context).pop(true); // 跳转
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        nextLicCheck();
      }
    });
  }
}
