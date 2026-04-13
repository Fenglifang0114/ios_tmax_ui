import 'package:flutter/material.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class FmaParameterSettingDialog extends StatefulWidget {
  final bool autoTare;
  final bool autoNextStep;
  final int stableTime;
  final bool checkCode;

  const FmaParameterSettingDialog(
      {super.key,
      required this.autoTare,
      required this.autoNextStep,
      required this.stableTime,
      required this.checkCode});

  @override
  State<FmaParameterSettingDialog> createState() =>
      _FmaParameterSettingDialogState();
}

class _FmaParameterSettingDialogState extends State<FmaParameterSettingDialog> {
  bool checkCode = false;
  bool autoTare = false;
  bool autoNextStep = false;
  int stableTime = 1;
  final stableTimeCtl = TextEditingController();
  final _stableTimeOptions = [
    "1",
    "2",
    "5",
    "10",
  ];

  TextStyle getTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= Theme.of(context).colorScheme.onSurface;
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color,
        );
  }

  @override
  void initState() {
    super.initState();
    autoTare = widget.autoTare;
    autoNextStep = widget.autoNextStep;
    stableTime = widget.stableTime;
    checkCode = widget.checkCode;
    stableTimeCtl.text = stableTime.toString();
  }

  @override
  void dispose() {
    stableTimeCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 430,
        height: 350,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              localizedStrings.gParameterSettingsTitle,
              true,
            ),

            // 中部
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(
                        left: regularPadding,
                        right: regularPadding,
                        top: largePadding),
                    child: Column(children: [
                      Row(
                        children: [
                          // 文本部分 - 右对齐
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                localizedStrings.ingredientVerification + ":",
                                style: getTextStyle(),
                              ),
                            ),
                          ),

                          // 间距
                          SizedBox(width: largePadding),

                          // 切换按钮部分
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (mySysUser.roleId ==
                                              superAdminRoleId ||
                                          mySysUser.roleId == adminRoleId) {
                                        checkCode = !checkCode;
                                      } else {
                                        showTipInfo(
                                            localizedStrings.noPermission,
                                            context);
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    checkCode
                                        ? Icons.toggle_on_outlined
                                        : Icons.toggle_off_outlined,
                                    color: checkCode
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onTertiaryFixedVariant
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // 文本部分 - 右对齐
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${localizedStrings.gTipAutoTare}:",
                                style: getTextStyle(),
                              ),
                            ),
                          ),

                          // 间距
                          SizedBox(width: largePadding),

                          // 切换按钮部分
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      autoTare = !autoTare;
                                    });
                                  },
                                  icon: Icon(
                                    autoTare
                                        ? Icons.toggle_on_outlined
                                        : Icons.toggle_off_outlined,
                                    color: autoTare
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onTertiaryFixedVariant
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // 文本部分 - 右对齐
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${localizedStrings.gTipAutoNextStep}:",
                                style: getTextStyle(),
                              ),
                            ),
                          ),

                          // 间距
                          SizedBox(width: largePadding),

                          // 切换按钮部分
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      autoNextStep = !autoNextStep;
                                      if (autoNextStep) {
                                        stableTimeCtl.text =
                                            stableTime.toString();
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    autoNextStep
                                        ? Icons.toggle_on_outlined
                                        : Icons.toggle_off_outlined,
                                    color: autoNextStep
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onTertiaryFixedVariant
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  )),
                            ),
                          ),
                        ],
                      ),
                      if (autoNextStep)
                        Row(
                          children: [
                            // 文本部分 - 右对齐
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "${localizedStrings.gTipStableTime}:",
                                  style: getTextStyle(),
                                ),
                              ),
                            ),

                            // 间距
                            SizedBox(width: largePadding),

                            // 切换按钮部分
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 80,
                                  height: 30,
                                  margin: EdgeInsets.only(left: smallPadding),
                                  child: DropdownButtonFormField<String>(
                                    borderRadius: BorderRadius.circular(0),
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5,
                                                horizontal: 10), // 调整垂直和水平内边距
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant, // 设置边框颜色
                                              width: 1.0, // 设置边框宽度
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0.0))),
                                        border: OutlineInputBorder()),
                                    isExpanded: true,
                                    value: stableTimeCtl.text == ""
                                        ? null
                                        : stableTimeCtl.text,
                                    items: [
                                      ..._stableTimeOptions.map((String item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: getTextStyle(),
                                          ),
                                        );
                                      })
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        stableTimeCtl.text = value!;
                                        stableTime =
                                            int.tryParse(stableTimeCtl.text) ??
                                                1;
                                        // setAutoNext();
                                      });
                                    },
                                    style: getTextStyle(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ]))),

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
                        Navigator.pop(
                            context,
                            FmaSettingInfo(
                                autoNextStep, autoTare, stableTime, checkCode));
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
                        Navigator.pop(context, false);
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

class FmaSettingInfo {
  bool autoNextStep;
  bool autoTare;
  int stableTime;
  bool checkCode;
  FmaSettingInfo(
      this.autoNextStep, this.autoTare, this.stableTime, this.checkCode);
}
