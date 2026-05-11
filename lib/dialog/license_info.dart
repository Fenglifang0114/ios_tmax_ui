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
  final TextEditingController pidCtl = TextEditingController();
  TextEditingController licCtl = TextEditingController();
  TextEditingController resCtl = TextEditingController();

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

    pidCtl.text = systemId;
    licCtl.text = '';
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
            updateResCtl();
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
        updateResCtl();
      }
    });
  }

  void updateResCtl() {
    resCtl.text = '${resCtl.text}${licList[0]}\r\n$errMessage\r\n';
    nextLicCheck();
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
    pidCtl.dispose();
    licCtl.dispose();
    resCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    systemId = (localizedStrings?.gSystemId ?? "gSystemId");
    pidCtl.text = systemId + pId;
    return AlertDialog(
      title: getDialogTitle(
          context, (localizedStrings?.gTitleLicense ?? "gTitleLicense"), Icons.key, 420),
      content: Container(
        height: 400,
        width: 300,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: ListView(
          children: [
            SizedBox(
              width: 300,
              height: 40,
              child: TextField(
                controller: pidCtl,
                readOnly: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 18,
                ),
                (mySystemVersion != 1)
                    ? const SizedBox()
                    : SizedBox(
                        width: 200,
                        child: Text((localizedStrings?.gExpirationDate ?? "gExpirationDate"),
                            textAlign: TextAlign.left,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryFixedVariant,
                            )),
                      ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomElevatedButton(
              btnWidth: 200,
              btnHeight: 40,
              icon: Icons.file_open_outlined,
              text: (localizedStrings?.btn_add_lic_file ?? "btn_add_lic_file"),
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
                      licCtl.text = filePath;
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
                        backgroundColor: Theme.of(context).colorScheme.error));
                  });
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CustomElevatedButton(
              btnWidth: 200,
              btnHeight: 40,
              icon: Icons.add_box_outlined,
              text: (localizedStrings?.button_add_license ?? "button_add_license"),
              onPressed: (licCtl.text.isNotEmpty)
                  ? () async {
                      resCtl.text = "";
                      await validLicense();
                      if (licList.isNotEmpty) {
                        PublicFunctions.checkLicenseKey(licList[0]);
                      }
                    }
                  : null,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 400,
              child: TextField(
                readOnly: true,
                controller: licCtl,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 2,
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
            SizedBox(
              width: 200,
              child: Text((localizedStrings?.gTipResult ?? "gTipResult"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            ),
            SizedBox(
              width: 400,
              child: TextField(
                readOnly: true,
                controller: resCtl,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
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
              text: (localizedStrings?.gBtnExit ?? "gBtnExit"),
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
    String dataStr = licCtl.text;
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

            updateResCtl();
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

            updateResCtl();
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

            updateResCtl();
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

            updateResCtl();
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

            updateResCtl();
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

            updateResCtl();
          }
        } else {
          myTaouLicInfo = newLicInfo;
          updateLicenseInfo();
        }

        break;
      case faspLic:
        if (myFaSpInfo.isValid) {
          if (isLongerValidityPeriod(myFaSpInfo.liceseDate, dueDate)) {
            myFaSpInfo = newLicInfo;
            updateLicenseInfo();
          } else {
            errMessage = 'The new period is not the latest.';

            updateResCtl();
          }
        } else {
          myFaSpInfo = newLicInfo;
          updateLicenseInfo();
        }
        break;
      case foscLic:
        if (myFoScLicInfo.isValid) {
          if (isLongerValidityPeriod(myFoScLicInfo.liceseDate, dueDate)) {
            myFoScLicInfo = newLicInfo;
            updateLicenseInfo();
          } else {
            errMessage = 'The new period is not the latest.';

            updateResCtl();
          }
        } else {
          myFoScLicInfo = newLicInfo;
          updateLicenseInfo();
        }
        break;
      case ladeLic:
        if (myLadeLicInfo.isValid) {
          if (isLongerValidityPeriod(myLadeLicInfo.liceseDate, dueDate)) {
            myLadeLicInfo = newLicInfo;
            updateLicenseInfo();
          } else {
            errMessage = 'The new period is not the latest.';

            updateResCtl();
          }
        } else {
          myLadeLicInfo = newLicInfo;
          updateLicenseInfo();
        }
        break;
      default:
        break;
    }
  }
}
