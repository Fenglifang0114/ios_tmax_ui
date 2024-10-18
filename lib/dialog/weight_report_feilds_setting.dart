import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/language.dart';
import '../data/weight_report_data.dart';
import '../widget/custom_button.dart';

class ReportFeildsSettingDialog extends StatefulWidget {
  const ReportFeildsSettingDialog({super.key});
  @override
  ReportFeildsSettingDialogState createState() =>
      ReportFeildsSettingDialogState();
}

List<String> allFieldSList = [
  'Date Time',
  'PLU NO.',
  'PLU Name',
  'PLU Remarks',
  'Weight',
  'Weight Unit',
  'Pretare',
  'User NO.',
  'User Name',
  'User Remarks',
  'Scale Model'
];

class ReportFeildsSettingDialogState extends State<ReportFeildsSettingDialog> {
  List<bool?> checkboxList = [
    false, // _isDateTimeChecked
    false, // _isPluNoChecked
    false, // _isPluNameChecked
    false, // _isPluRemarksChecked
    false, // _isWeightChecked
    false, // _isWeightUnitChecked
    false, // _isPretareChecked
    false, // _isUserNoChecked
    false, // _isUserNameChecked
    false, //  _isUserRemarksChecked
    false, // _isScaleNameChecked
  ];

  TextEditingController errorText = TextEditingController();

  @override
  void initState() {
    super.initState();
    fieldsInit();
  }

  @override
  void dispose() {
    super.dispose();
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
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary),
                  child: Column(
                    children: [
                      buildCheckBox(0),
                      buildCheckBox(1),
                      buildCheckBox(2),
                      buildCheckBox(3),
                      buildCheckBox(4),
                      buildCheckBox(5),
                      buildCheckBox(6),
                      buildCheckBox(7),
                      buildCheckBox(8),
                      buildCheckBox(9),
                      buildCheckBox(10),
                      SizedBox(
                        width: 400,
                        height: 36,
                        child: TextField(
                          enabled: false,
                          controller: errorText,
                          maxLength: 100,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                            counterText: "",
                            focusColor: Theme.of(context)
                                .colorScheme
                                .error, // hintText: "请输入机种类型，如：ztp",
                            // border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ],
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
              text: localizedStrings.button_ok,
              onPressed: () {
                creatFieldList();
                Navigator.of(context).pop(true);
              },
            ),
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.cancel,
              text: localizedStrings.button_cancel,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        )
      ],
    );
  }

  Widget buildCheckBox(int i) {
    return checkBoxSetting(allFieldSList[i], checkboxList[i], (value) {
      setState(() {
        checkboxList[i] = value!;
      });
    });
  }

  void fieldsInit() {
    for (int i = 0; i < 11; i++) {
      if (myReportFields.filedsList.contains(allFieldSList[i])) {
        checkboxList[i] = true;
      }
    }
  }

  void creatFieldList() {
    myReportFields.filedsList.clear();
    for (int i = 0; i < 11; i++) {
      if (checkboxList[i]!) {
        myReportFields.filedsList.add(allFieldSList[i]);
      }
    }
  }

  Widget checkBoxSetting(
      String str, bool? isChecked, Function(bool?) onChanged) {
    str = '$str:';
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            str,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        Checkbox(
          value: isChecked,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
