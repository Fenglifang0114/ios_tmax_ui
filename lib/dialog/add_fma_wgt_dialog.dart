//百分比模式时，需要添加的配方总重量

// 定义新增配方重量弹框组件
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/formula_common.dart';

import 'package:t_max/data/language.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class AddFormulaWgtDialog extends StatefulWidget {
  const AddFormulaWgtDialog({super.key});
  @override
  AddFormulaWgtDialogState createState() => AddFormulaWgtDialogState();
}

class AddFormulaWgtDialogState extends State<AddFormulaWgtDialog> {
  TextEditingController formulaWgtCtl = TextEditingController();
  TextEditingController formulaUnitCtl =
      TextEditingController(text: FormulaWgtUnit.g.name);

  showUnitDropDownButton(List<FormulaWgtUnit> items, String hintText,
      TextEditingController valueCtl) {
    return SizedBox(
        height: 48,
        child: DropdownButtonFormField<FormulaWgtUnit>(
            borderRadius: BorderRadius.circular(0),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant, // 设置边框颜色
                      width: 1.0, // 设置边框宽度
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(0.0))),
                border: OutlineInputBorder()),
            isExpanded: true,
            value: items.firstWhere(
                (mode) => mode.toString().split('.').last == valueCtl.text,
                orElse: () => items[0]),
            hint: Text(hintText), // 设置提示文本

            items: items.map((FormulaWgtUnit item) {
              // 设置下拉列表项
              return DropdownMenuItem<FormulaWgtUnit>(
                value: item,
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (FormulaWgtUnit? newValue) {
              // 处理下拉列表项选择事件
              if (newValue != null) {
                // 在这里处理选择的值
                // print('Selected: ${newValue.toString().split('.').last}');
                setState(() {
                  valueCtl.text = newValue.name; // 更新 valueCtl 的值
                });
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 376,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
                context, localizedStrings.fAddFormulaWeightTitle, true),
            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 90,
                width: 500,
                child: Row(children: [
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        SizedBox(
                          height: 42,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  localizedStrings.fFormulaTotalWeightLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 20),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: formulaWgtCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: localizedStrings
                                          .fInputFormulaTotalWeightHint,
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    // 修改输入过滤器的正则表达式，不允许以小数点开头
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(
                                          r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        SizedBox(
                          height: 42,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  localizedStrings.fWgtUnit,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        showUnitDropDownButton([
                          FormulaWgtUnit.g,
                          FormulaWgtUnit.kg,
                          FormulaWgtUnit.lb
                        ], localizedStrings.fSelectUnitHint, formulaUnitCtl),
                      ])),
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
                      onPressed: formulaWgtCtl.text.isEmpty
                          ? null
                          : () {
                              // 将重量和单位做成map传过去
                              Navigator.pop(context, {
                                'formulaWgt': formulaWgtCtl.text,
                                'formulaUnit': formulaUnitCtl.text,
                              });
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
                        Navigator.pop(context, '');
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
