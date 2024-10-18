import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/widget/custom_button.dart';

import '../data/language.dart';

//设置流水线秤 上下限参数设置

class CheckValueSetDialog extends StatefulWidget {
  final double initialHigh;
  final double initialLow;

  const CheckValueSetDialog(
      {required this.initialHigh, required this.initialLow, super.key});
  @override
  CheckValueSetDialogState createState() => CheckValueSetDialogState();
}

class CheckValueSetDialogState extends State<CheckValueSetDialog> {
  TextEditingController maxValueCtl = TextEditingController(text: '');
  TextEditingController minValueCtl = TextEditingController(text: '');
  TextEditingController errorText = TextEditingController();
  double highValue = 0.0;
  double lowValue = 0.0;

  @override
  void initState() {
    maxValueCtl.text = widget.initialHigh.toString();
    minValueCtl.text = widget.initialLow.toString();
    highValue = widget.initialHigh;
    lowValue = widget.initialLow;

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
              BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
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
                              controller: maxValueCtl,
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
                                setState(() {
                                  if (value.isNotEmpty) {
                                    highValue = double.parse(value);
                                  } else {
                                    highValue = 0.0;
                                  }
                                });
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
                              controller: minValueCtl,
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
                                setState(() {
                                  if (value.isNotEmpty) {
                                    lowValue = double.parse(value);
                                  } else {
                                    lowValue = 0.0;
                                  }
                                });
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
            CustomElevatedButton(
                btnWidth: 120,
                btnHeight: 40,
                icon: Icons.check_circle,
                text: localizedStrings.button_ok,
                onPressed: (lowValue > highValue)
                    ? null
                    : () {
                        Navigator.of(context).pop([highValue, lowValue]);
                      }),
            const SizedBox(width: 20),
            CustomOutlinedButton(
                btnWidth: 120,
                btnHeight: 40,
                icon: Icons.cancel,
                text: localizedStrings.button_cancel,
                onPressed: () {
                  Navigator.of(context)
                      .pop([widget.initialHigh, widget.initialLow]);
                })
          ],
        )
      ],
    );
  }
}
