import 'package:flutter/material.dart';
import '../data/language.dart';
import '../data/weight_report_data.dart';
import '../widget/custom_button.dart';

class ReportFeildsSettingDialog extends StatefulWidget {
  const ReportFeildsSettingDialog({super.key});
  @override
  ReportFeildsSettingDialogState createState() =>
      ReportFeildsSettingDialogState();
}

class ReportFeildsSettingDialogState extends State<ReportFeildsSettingDialog> {
  TextEditingController errorText = TextEditingController();
  Map<String, ReportShowName> tempFeildMap = {};
  bool isSelectAll = false;

  @override
  void initState() {
    myReportFeildsMap.forEach((key, value) {
      tempFeildMap[key] = ReportShowName(
          myReportFeildsMap[key]!.showName, myReportFeildsMap[key]!.isSelect);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 全选方法
  void selectAll(bool value) {
    setState(() {
      tempFeildMap.forEach((key, reportShowName) {
        reportShowName.isSelect = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(context, localizedStrings.report_set_btn,
          Icons.settings_applications_rounded, 400),
      content: Container(
          height: 350,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text(
                    localizedStrings.gSelectAll,
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                  ),
                  value: isSelectAll,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isSelectAll = newValue!;
                      selectAll(newValue);
                    });
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary),
                  child: Column(
                    children: tempFeildMap.values
                        .map((ReportShowName reportShowName) {
                      return CheckboxListTile(
                        title: Text(
                          reportShowName.showName,
                          style: TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                        value: reportShowName.isSelect,
                        onChanged: (bool? newValue) {
                          setState(() {
                            for (var key in tempFeildMap.keys) {
                              if (tempFeildMap[key]!.showName ==
                                  reportShowName.showName) {
                                tempFeildMap[key]!.isSelect = newValue!;
                                break;
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          )),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomElevatedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.check_circle,
              text: localizedStrings.gBtnConfirm,
              onPressed: () {
                tempFeildMap.forEach((key, value) {
                  myReportFeildsMap[key]!.isSelect = value.isSelect;
                });
                Navigator.of(context).pop(true);
              },
            ),
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.cancel,
              text: localizedStrings.gBtnCancel,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        )
      ],
    );
  }
}
