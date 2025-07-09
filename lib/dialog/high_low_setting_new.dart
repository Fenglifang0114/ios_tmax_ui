import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/high_low_weight.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';

import '../data/language.dart';

// class NewHighLowSettingDialog extends StatefulWidget {
//   final double highValue;
//   final double lowValue;
//   const NewHighLowSettingDialog(
//       {super.key, required this.highValue, required this.lowValue});

//   @override
//   NewHighLowSettingDialogState createState() => NewHighLowSettingDialogState();
// }

// class NewHighLowSettingDialogState extends State<NewHighLowSettingDialog> {
//   TextEditingController maxValueController = TextEditingController();
//   TextEditingController minValueController = TextEditingController();

//   TextEditingController errorText = TextEditingController();

//   @override
//   void initState() {
//     maxValueController.text = widget.highValue.toString();
//     minValueController.text = widget.lowValue.toString();

//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Container(
//           color: Theme.of(context).colorScheme.primary,
//           child: Row(
//             children: [
//               Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
//               Text(localizedStrings.iTitleHLSetting,
//                   style:
//                       TextStyle(color: Theme.of(context).colorScheme.onPrimary))
//             ],
//           )),
//       content: Container(
//           height: 200,
//           decoration:
//               BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.onPrimary),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           const SizedBox(
//                             width: 100,
//                             child: Text(
//                               "High:",
//                               textAlign: TextAlign.right,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 20,
//                           ),
//                           SizedBox(
//                             width: 200,
//                             child: TextField(
//                               textAlignVertical: TextAlignVertical.top,
//                               controller: maxValueController,
//                               maxLength: 10,
//                               maxLengthEnforcement:
//                                   MaxLengthEnforcement.enforced,
//                               maxLines: 1,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp(r'^\d+(\.)?[0-9]{0,7}'))
//                               ], //数字包括小数,

//                               decoration: const InputDecoration(
//                                 counterText: "",
//                                 // hintText: "请输入机种类型，如：ztp",
//                                 // border: OutlineInputBorder(),
//                               ),
//                               onChanged: (value) {
//                                 if (value.isNotEmpty) {
//                                   myHighLowWeight.highValue =
//                                       double.parse(value);
//                                 } else {
//                                   myHighLowWeight.highValue = 0.0;
//                                 }
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           const SizedBox(
//                             width: 100,
//                             child: Text('Low:', textAlign: TextAlign.right),
//                           ),
//                           const SizedBox(
//                             width: 20,
//                           ),
//                           SizedBox(
//                             width: 200,
//                             child: TextField(
//                               controller: minValueController,
//                               maxLength: 10,
//                               maxLengthEnforcement:
//                                   MaxLengthEnforcement.enforced,
//                               maxLines: 1,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp(r'^\d+(\.)?[0-9]{0,7}'))
//                               ], //数字包括小数,
//                               textAlignVertical: TextAlignVertical.top,
//                               decoration: const InputDecoration(
//                                 counterText: "",
//                                 // hintText: "请输入机种类型，如：ztp",
//                                 // border: OutlineInputBorder(),
//                               ),
//                               onChanged: (value) {
//                                 if (value.isNotEmpty) {
//                                   myHighLowWeight.lowValue =
//                                       double.parse(value);
//                                 } else {
//                                   myHighLowWeight.lowValue = 0.0;
//                                 }
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       Text(localizedStrings.iTipHLUnit,
//                           textAlign: TextAlign.right),
//                       const SizedBox(
//                         height: 30,
//                       ),
//                       SizedBox(
//                         width: 400,
//                         height: 36,
//                         child: TextField(
//                           enabled: false,
//                           controller: errorText,
//                           maxLength: 100,
//                           style: TextStyle(
//                               color: Theme.of(context).colorScheme.error),
//                           maxLengthEnforcement: MaxLengthEnforcement.enforced,
//                           maxLines: 1,
//                           textAlignVertical: TextAlignVertical.bottom,
//                           decoration: InputDecoration(
//                             border: const OutlineInputBorder(
//                                 borderSide: BorderSide.none),
//                             counterText: "",
//                             focusColor: Theme.of(context)
//                                 .colorScheme
//                                 .error, // hintText: "请输入机种类型，如：ztp",
//                             // border: OutlineInputBorder(),
//                           ),
//                           onChanged: (value) {},
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           )),
//       actions: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             CustomElevatedButton(
//                 btnWidth: 120,
//                 btnHeight: 40,
//                 icon: Icons.check_circle,
//                 text: localizedStrings.gBtnConfirm,
//                 onPressed: () {
//                   Navigator.of(context).pop(myHighLowWeight);
//                 }),
//             const SizedBox(width: 20),
//             CustomOutlinedButton(
//                 btnWidth: 120,
//                 btnHeight: 40,
//                 icon: Icons.cancel,
//                 text: localizedStrings.gBtnCancel,
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 })
//           ],
//         )
//       ],
//     );
//   }
// }

//// 定义新增原料类型弹框组件
class NewHighLowSettingDialog extends StatefulWidget {
  final double highValue;
  final double lowValue;
  const NewHighLowSettingDialog(
      {super.key, required this.highValue, required this.lowValue});
  @override
  NewHighLowSettingDialogState createState() => NewHighLowSettingDialogState();
}

class NewHighLowSettingDialogState extends State<NewHighLowSettingDialog> {
  TextEditingController maxValueController = TextEditingController();
  TextEditingController minValueController = TextEditingController();

  TextEditingController errorText = TextEditingController();

  @override
  void initState() {
    maxValueController.text = widget.highValue.toString();
    minValueController.text = widget.lowValue.toString();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 430,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            Container(
                height: 54,
                padding: const EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizedStrings.iTitleHLSetting,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ])),
            // 分割线
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                width: 500,
                child: Column(children: [
                  SizedBox(
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 42,
                                width: 430,
                                child: Text(
                                  'high',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                height: 48,
                                width: 430,
                                child: TextField(
                                  textAlignVertical: TextAlignVertical.top,
                                  controller: maxValueController,

                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  maxLines: 1,
                                  maxLength: 9,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+(\.)?[0-9]{0,7}'))
                                  ], //数字包括小数,

                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0.0))),
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface, // 设置提示文本颜色
                                    ),
                                    counterText: "", // 不显示位数倒计时
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
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 42,
                                width: 430,
                                child: Text(
                                  'Low',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 430,
                                child: TextField(
                                  controller: minValueController,

                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  maxLines: 1,
                                  maxLength: 9,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+(\.)?[0-9]{0,7}'))
                                  ], //数字包括小数,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0.0))),
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface, // 设置提示文本颜色
                                    ),
                                    counterText: "", // 不显示位数倒计时
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
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 42,
                                width: 430,
                                child: Text(
                                  localizedStrings.iTipHLUnit,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        if (myHighLowWeight.highValue <
                            myHighLowWeight.lowValue) {
                          showTipInfo(
                              localizedStrings.gTipInvalidInput, context);
                          return;
                        }
                        Navigator.of(context).pop(myHighLowWeight);
                      },
                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        localizedStrings.gBtnCancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
