import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/high_low_weight.dart';

import '../data/language.dart';

class HighLowSettingDialog extends StatefulWidget {
  const HighLowSettingDialog({super.key});
  @override
  _HighLowSettingDialogState createState() => _HighLowSettingDialogState();
}

class _HighLowSettingDialogState extends State<HighLowSettingDialog> {
  TextEditingController maxValueController = TextEditingController();
  TextEditingController minValueController = TextEditingController();

  TextEditingController errorText = TextEditingController();

  @override
  void initState() {
    maxValueController.text = myHighLowWeight.highValue.toString();
    minValueController.text = myHighLowWeight.lowValue.toString();

    super.initState();
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
          child: Row(
            children: [
              Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
              Text('High/Low Setting',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary))
            ],
          )),
      content: Container(
          height: 200,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Text(
                              "High:",
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 200,
                            child: TextField(
                              textAlignVertical: TextAlignVertical.top,
                              controller: maxValueController,
                              maxLength: 10,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              maxLines: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+(\.)?[0-9]{0,7}'))
                              ], //数字包括小数,

                              decoration: const InputDecoration(
                                counterText: "",
                                // hintText: "请输入机种类型，如：ztp",
                                // border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  myHighLowWeight.highValue =
                                      double.parse(value);
                                } else {
                                  myHighLowWeight.highValue = 0.0;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Text('Low:', textAlign: TextAlign.right),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: minValueController,
                              maxLength: 10,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              maxLines: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+(\.)?[0-9]{0,7}'))
                              ], //数字包括小数,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                counterText: "",
                                // hintText: "请输入机种类型，如：ztp",
                                // border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  myHighLowWeight.lowValue =
                                      double.parse(value);
                                } else {
                                  myHighLowWeight.lowValue = 0.0;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 60,
                      ),
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
}
