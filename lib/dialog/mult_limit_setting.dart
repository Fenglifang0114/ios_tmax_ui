import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widget/custom_button.dart';

class MultLimitSettingDialog extends StatefulWidget {
  final List<double> initialHighList;
  final List<double> initialLowList;
  final int numGroups;

  const MultLimitSettingDialog(
      {required this.initialHighList,
      required this.initialLowList,
      required this.numGroups,
      super.key});

  @override
  _MultLimitSettingDialogState createState() => _MultLimitSettingDialogState();
}

class _MultLimitSettingDialogState extends State<MultLimitSettingDialog> {
  // 存储每组的最大最小值控制器
  List<TextEditingController> maxValueCtlList = [];
  List<TextEditingController> minValueCtlList = [];
  // 存储每组的高低值
  List<double> highValueList = [];
  List<double> lowValueList = [];

  @override
  void initState() {
    for (int i = 0; i < widget.numGroups; i++) {
      maxValueCtlList.add(
          TextEditingController(text: widget.initialHighList[i].toString()));
      minValueCtlList.add(
          TextEditingController(text: widget.initialLowList[i].toString()));
      highValueList.add(widget.initialHighList[i]);
      lowValueList.add(widget.initialLowList[i]);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.numGroups; i++) {
      maxValueCtlList[i].dispose();
      minValueCtlList[i].dispose();
    }
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
          height: 400,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(widget.numGroups, (index) {
                return Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary),
                  child: Row(
                    children: [
                      Center(
                        child: Text('Δ ${index + 1}'),
                      ),
                      Column(
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
                                  controller: maxValueCtlList[index],
                                  maxLength: 10,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  maxLines: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+(\.)?[0-9]{0,7}'))
                                  ],
                                  decoration: const InputDecoration(
                                    counterText: "",
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.isNotEmpty) {
                                        highValueList[index] =
                                            double.parse(value);
                                      } else {
                                        highValueList[index] = 0.0;
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
                                  controller: minValueCtlList[index],
                                  maxLength: 10,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  maxLines: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+(\.)?[0-9]{0,7}'))
                                  ],
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.isNotEmpty) {
                                        lowValueList[index] =
                                            double.parse(value);
                                      } else {
                                        lowValueList[index] = 0.0;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
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
                text: 'OK',
                onPressed: checkValueOk()
                    ? () {
                        Navigator.of(context)
                            .pop([highValueList, lowValueList]);
                      }
                    : null),
            const SizedBox(width: 20),
            CustomOutlinedButton(
                btnWidth: 120,
                btnHeight: 40,
                icon: Icons.cancel,
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context)
                      .pop([widget.initialHighList, widget.initialLowList]);
                })
          ],
        )
      ],
    );
  }

  bool checkValueOk() {
    bool res = false;
    for (int i = 0; i < highValueList.length; i++) {
      if (highValueList[i] < lowValueList[i]) {
        return res;
      }
    }
    return true;
  }
}
