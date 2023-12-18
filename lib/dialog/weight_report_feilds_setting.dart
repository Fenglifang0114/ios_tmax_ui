import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generated/l10n.dart';
import '../data/weight_report_data.dart';

class ReportFeildsSettingDialog extends StatefulWidget {
  const ReportFeildsSettingDialog({super.key});
  @override
  _ReportFeildsSettingDialogState createState() =>
      _ReportFeildsSettingDialogState();
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
  'Scale Name'
];

class _ReportFeildsSettingDialogState extends State<ReportFeildsSettingDialog> {
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

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
          color: Theme.of(context).colorScheme.primary,
          child: const Row(
            children: [
              Icon(Icons.description, color: Colors.white),
              Text('Report Fields Setting',
                  style: TextStyle(color: Colors.white))
            ],
          )),
      content: Container(
          height: 350,
          decoration:
              const BoxDecoration(color: Color.fromARGB(255, 233, 232, 232)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
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
            MaterialButton(
                textColor: Theme.of(context).colorScheme.onPrimary,
                color: Theme.of(context).colorScheme.primary,
                child: Text(localizedStrings.button_ok),
                onPressed: () {
                  creatFieldList();
                  Navigator.of(context).pop(true);
                }),
            const SizedBox(width: 20),
            OutlinedButton(
                child: Text(localizedStrings.button_cancel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                })
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
    str = str + ':';
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
