import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import '../data/language.dart';
import '../data/plu_field_status_data.dart';

class PrintRptSelectDialog extends StatefulWidget {
  final Map<String, FieldNameStatus> options;
  final List<String> selectedOptions;

  const PrintRptSelectDialog(
      {required this.options,
      required this.selectedOptions,
      super.key,
      required BuildContext context});

  @override
  PrintRptSelectDialogState createState() => PrintRptSelectDialogState();
}

class PrintRptSelectDialogState extends State<PrintRptSelectDialog> {
  List<String> _selectedOptions = [];

  bool closeButtonEnabled = true;
  bool isSelectAll = false;

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        if (option != 'plu' && option != 'productName') {
          _selectedOptions.remove(option);
        }
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // 在初始化时将options的所有键添加到_selectedOptions中

    _selectedOptions = widget.selectedOptions;
  }

  // 全选方法
  void selectAll(bool value) {
    setState(() {
      _selectedOptions.clear();
      if (!value) {
        _selectedOptions.add('plu');
        _selectedOptions.add('productName');
      }

      for (var entry in widget.options.entries) {
        if (value) {
          _selectedOptions.add(entry.key);
        }
      }
    });
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  TextStyle getTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodySmall!.apply(
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
          width: 840,
          height: 480,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            children: [
              // 头部
              ...dialogHeadStyle(
                  context, (localizedStrings?.printSettings ?? "printSettings"), false),

              // 中部
              Expanded(
                  child: Container(
                      padding: EdgeInsets.all(regularPadding),
                      child: Column(children: [
                        CheckboxListTile(
                          title: Text(
                            (localizedStrings?.gSelectAll ?? "gSelectAll"),
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
                        GridView.count(
                          shrinkWrap: true, // 使 GridView 适应内容高度
                          physics: const NeverScrollableScrollPhysics(), // 禁止滚动
                          crossAxisCount: 3, // 设置列数为 3
                          crossAxisSpacing: 5.0, // 水平间距
                          mainAxisSpacing: 0, // 适当减小垂直间距
                          childAspectRatio: 7, // 设置子组件宽高比，可按需调整
                          children: widget.options.entries.map((entry) {
                            return CheckboxListTile(
                              title: Text(
                                entry.value.field,
                                style: getTextStyle(),
                                overflow: TextOverflow.ellipsis,
                              ),
                              value: _selectedOptions.contains(entry.key),
                              onChanged: closeButtonEnabled
                                  ? (value) => _toggleOption(entry.key)
                                  : null,
                            );
                          }).toList(),
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          fixedSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: () {
                          setRptSetting();
                          for (var item in _selectedOptions) {
                            switch (item) {
                              case "formulaId":
                                rptPrintSetting.formulaId = true;
                                break;
                              case "formulaName":
                                rptPrintSetting.formulaName = true;
                                break;
                              case "formulaBarcode":
                                rptPrintSetting.formulaBarcode = true;
                                break;
                              case "orderId":
                                rptPrintSetting.orderId = true;
                                break;
                              case "saveTime":
                                rptPrintSetting.saveTime = true;
                                break;
                              case "operator":
                                rptPrintSetting.operator = true;
                                break;
                              case "rawId":
                                rptPrintSetting.rawId = true;
                                break;
                              case "rawName":
                                rptPrintSetting.rawName = true;
                                break;
                              case "pass":
                                rptPrintSetting.pass = true;
                                break;
                              case "fmaTotalWgt":
                                rptPrintSetting.fmaTotalWgt = true;
                                break;
                              case "actualTotalWgt":
                                rptPrintSetting.actualTotalWgt = true;
                                break;
                              case "deviceName":
                                rptPrintSetting.deviceName = true;
                                break;
                              case "rawActualErr":
                                rptPrintSetting.rawActualErr = true;
                                break;
                              case "rawActualWgt":
                                rptPrintSetting.rawActualWgt = true;
                                break;
                            }
                          }
                          String jsonStr =
                              rptPrintSettingToJson(rptPrintSetting);
                          PublicFunctions.updateReportPrintSetting(jsonStr);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                          style: getTextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                          (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                          style: getTextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  void setRptSetting() {
    rptPrintSetting.recId = 1;
    rptPrintSetting.formulaId = false;
    rptPrintSetting.formulaName = false;
    rptPrintSetting.formulaBarcode = false;
    rptPrintSetting.orderId = false;
    rptPrintSetting.saveTime = false;
    rptPrintSetting.operator = false;
    rptPrintSetting.rawId = false;
    rptPrintSetting.rawName = false;
    rptPrintSetting.pass = false;
    rptPrintSetting.fmaTotalWgt = false;
    rptPrintSetting.actualTotalWgt = false;
    rptPrintSetting.deviceName = false;
    rptPrintSetting.rawActualErr = false;
    rptPrintSetting.rawActualWgt = false;
  }
}
