import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import '../data/language.dart';
import '../data/weight_report_data.dart';

class ReportSettingDialog extends StatefulWidget {
  const ReportSettingDialog({super.key});
  @override
  ReportSettingDialogState createState() => ReportSettingDialogState();
}

class ReportSettingDialogState extends State<ReportSettingDialog> {
  TextEditingController errorText = TextEditingController();
  Map<String, ReportShowName> tempFeildMap = {};
  bool isSelectAll = false;

  @override
  void initState() {
    myReportFeildsMap.forEach((key, value) {
      tempFeildMap[key] =
          ReportShowName(getRptTitleName(key), myReportFeildsMap[key]!);
    });

    isSelectAll = tempFeildMap.values.every((element) => element.isSelect);

    super.initState();
  }

  @override
  void dispose() {
    errorText.dispose();
    super.dispose();
  }

  // 全选方法
  void selectAll(bool value) {
    setState(() {
      tempFeildMap.forEach((key, reportShowName) {
        reportShowName.isSelect = value;
      });
    });
    tempFeildMap['Id']!.isSelect = true;
    tempFeildMap['Weight']!.isSelect = true;
    tempFeildMap['Weight Unit']!.isSelect = true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 630,
        height: 530,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
                context, (localizedStrings?.gBtnReportSetting ?? "gBtnReportSetting"), true, onClose: () {
              Navigator.of(context).pop(false);
            }),

            // 中部

            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: regularPadding,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: regularPadding,
                      ),
                      Checkbox(
                        value: isSelectAll,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isSelectAll = newValue!;
                            selectAll(newValue);
                          });
                        },
                      ),
                      Flexible(
                        child: Text(
                          (localizedStrings?.gSelectAll ?? "gSelectAll"),
                          style: TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: regularPadding,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          // spacing: 14, // 列间距
                          runSpacing: 14, // 行间距
                          children: tempFeildMap.values
                              .map((ReportShowName reportShowName) {
                            return SizedBox(
                              width: 200, // 每行 3 个元素
                              child: Row(
                                // mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: reportShowName.isSelect,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        for (var key in tempFeildMap.keys) {
                                          if (tempFeildMap[key]!.showName ==
                                              reportShowName.showName) {
                                            tempFeildMap[key]!.isSelect =
                                                newValue!;
                                            break;
                                          }
                                        }
                                        tempFeildMap['Id']!.isSelect = true;
                                        tempFeildMap['Weight']!.isSelect = true;
                                        tempFeildMap['Weight Unit']!.isSelect =
                                            true;
                                        // 检查是否全选
                                        isSelectAll = tempFeildMap.values.every(
                                            (element) => element.isSelect);
                                      });
                                    },
                                  ),
                                  Flexible(
                                    child: Text(
                                      reportShowName.showName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
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
                        tempFeildMap.forEach((key, value) {
                          myReportFeildsMap[key] = value.isSelect;
                        });
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
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
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
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
