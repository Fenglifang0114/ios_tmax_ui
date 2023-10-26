import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/high_low_weight.dart';
import '../../generated/l10n.dart';

class ReportFeildsSettingDialog extends StatefulWidget {
  const ReportFeildsSettingDialog({super.key});
  @override
  _ReportFeildsSettingDialogState createState() =>
      _ReportFeildsSettingDialogState();
}

class _ReportFeildsSettingDialogState extends State<ReportFeildsSettingDialog> {
  late bool? _isPluNoChecked = true;
  late bool? _isPluNameChecked = true;
  late bool? _isPluRemarksChecked = true;
  late bool? _isPretareChecked = true;
  late bool? _isDateTimeChecked = true;
  late bool? _isWeightChecked = true;
  late bool? _isWeightUnitChecked = true;
  late bool? _isUserNoChecked = true;
  late bool? _isUserNameChecked = true;
  late bool? _isUserRemarksChecked = true;
  late bool? _isScaleNameChecked = true;

  TextEditingController errorText = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  var localizedStrings;
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
                      checkBoxSetting('PLU NO.', _isPluNoChecked, (value) {
                        setState(() {
                          _isPluNoChecked = value!;
                        });
                      }),
                      checkBoxSetting('PLU Name', _isPluNameChecked, (value) {
                        setState(() {
                          _isPluNameChecked = value!;
                        });
                      }),
                      checkBoxSetting('PLU Remarks.', _isPluRemarksChecked,
                          (value) {
                        setState(() {
                          _isPluRemarksChecked = value!;
                        });
                      }),
                      checkBoxSetting('User NO.', _isUserNameChecked, (value) {
                        setState(() {
                          _isUserNameChecked = value!;
                        });
                      }),
                      checkBoxSetting('User Name', _isUserNoChecked, (value) {
                        setState(() {
                          _isUserNoChecked = value!;
                        });
                      }),
                      checkBoxSetting('User Remarks', _isUserRemarksChecked,
                          (value) {
                        setState(() {
                          _isUserRemarksChecked = value!;
                        });
                      }),
                      checkBoxSetting('DateTime', _isDateTimeChecked, (value) {
                        setState(() {
                          _isDateTimeChecked = value!;
                        });
                      }),
                      checkBoxSetting('Weight', _isWeightChecked, (value) {
                        setState(() {
                          _isWeightChecked = value!;
                        });
                      }),
                      checkBoxSetting('Weight Unit', _isWeightUnitChecked,
                          (value) {
                        setState(() {
                          _isWeightUnitChecked = value!;
                        });
                      }),
                      checkBoxSetting('Pretare', _isPretareChecked, (value) {
                        setState(() {
                          _isPretareChecked = value!;
                        });
                      }),
                      checkBoxSetting('Scale Name', _isScaleNameChecked,
                          (value) {
                        setState(() {
                          _isScaleNameChecked = value!;
                        });
                      }),
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
                  Navigator.of(context).pop();
                }),
            const SizedBox(width: 20),
            OutlinedButton(
                child: Text(localizedStrings.button_cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        )
      ],
    );
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
        SizedBox(
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
