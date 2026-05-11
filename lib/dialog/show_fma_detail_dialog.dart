// 展示配方详情弹框组件
import 'package:flutter/material.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class ShowFormulaDetailDialog extends StatefulWidget {
  const ShowFormulaDetailDialog(
      {super.key, required this.selectFormula, required this.selectScaleId});
  final FormulaInfoDb selectFormula;
  final int selectScaleId;
  @override
  ShowFormulaDetailDialogState createState() => ShowFormulaDetailDialogState();
}

class ShowFormulaDetailDialogState extends State<ShowFormulaDetailDialog> {
  TextEditingController formulaWgtCtl = TextEditingController();
  TextEditingController formulaUnitCtl = TextEditingController();
  List<Detail>? detailsList = [];
  Detail? selectDetail; //选择的详情
  int selectDetailIndex = 0; //选择的详情的索引

  // 创建一个映射表，将枚举值与翻译关联起来
  Map<FormulaMode, String> formulaModeTranslation = {
    FormulaMode.wgt: (localizedStrings?.fWeightMode ?? "fWeightMode"),
    FormulaMode.pct: (localizedStrings?.fPctMode ?? "fPctMode"),
  };

  @override
  void initState() {
    super.initState();

    detailsList = widget.selectFormula.details;
    selectDetail = detailsList![selectDetailIndex];
  }

  showUnitDropDownButton(List<FormulaWgtUnit> items, String hintText,
      TextEditingController valueCtl) {
    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton<FormulaWgtUnit>(
            isExpanded: true,
            value: items.firstWhere(
                (mode) => mode.toString().split('.').last == valueCtl.text,
                orElse: () => items[0]),
            hint: Text(hintText), // 设置提示文本
            underline: SizedBox.shrink(), // 移除下划线
            items: items.map((FormulaWgtUnit item) {
              // 设置下拉列表项
              return DropdownMenuItem<FormulaWgtUnit>(
                value: item,
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color:
                            Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
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
  Widget build(BuildContext ctx) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 716,
        height: 561,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              (localizedStrings?.fFormulaDetailsTitle ?? "fFormulaDetailsTitle"),
              true,
              onClose: () {
                Navigator.pop(context, false);
              },
            ),

            // 中部
            Expanded(
                child: Column(children: [
              SizedBox(
                height: 42,
                width: 674,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 42,
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: (localizedStrings?.fFmaIdLabel ?? "fFmaIdLabel") + ': ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        overflow: TextOverflow.ellipsis),
                              ),
                              TextSpan(
                                text: widget.selectFormula.header!.formulaId!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 42,
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: (localizedStrings?.fFmaNameLabel ?? "fFmaNameLabel") + ': ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          overflow: TextOverflow.ellipsis),
                                ),
                                TextSpan(
                                  text:
                                      widget.selectFormula.header!.formulaName!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ]),
              ),
              SizedBox(
                height: 42,
                width: 674,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 42,
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: (localizedStrings?.fIngredientCountLabel ?? "fIngredientCountLabel") +
                                    ': ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        overflow: TextOverflow.ellipsis),
                              ),
                              TextSpan(
                                text: widget
                                    .selectFormula.header!.materialCount!
                                    .toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 42,
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: (localizedStrings?.fFmaBarcode ?? "fFmaBarcode") + ': ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        overflow: TextOverflow.ellipsis),
                              ),
                              TextSpan(
                                text: widget
                                    .selectFormula.header!.formulaBarcode!
                                    .toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ),
                      widget.selectFormula.header!.formulaMode == "wgt" &&
                              widget.selectFormula.header!.isEncrypted == false
                          ? Container(
                              height: 42,
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: (localizedStrings?.fTotalWeightLabel ?? "fTotalWeightLabel") +
                                          ': ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              overflow: TextOverflow.ellipsis),
                                    ),
                                    TextSpan(
                                      text:
                                          '${widget.selectFormula.header!.totalWeight!.toString()}  ${widget.selectFormula.header!.formulaUnit!}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                    ]),
              ),
              //原料列表
              SizedBox(
                height: 109,
                width: 674,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate((detailsList!.length / 2).ceil(),
                        (rowIndex) {
                      final startIndex = rowIndex * 2;
                      final endIndex =
                          (startIndex + 2).clamp(0, detailsList!.length);
                      final rowChildren = <Widget>[];
                      detailsList!
                          .sublist(startIndex, endIndex)
                          .asMap()
                          .forEach((subIndex, material) {
                        // 计算全局索引
                        final globalIndex = startIndex + subIndex;
                        rowChildren.add(
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectDetail = material;
                                // 使用全局索引
                                selectDetailIndex = globalIndex;
                              });
                            },
                            child: Container(
                              height: 32,
                              width: 320,
                              color: selectDetailIndex == globalIndex
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1)
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLow,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    color: selectDetailIndex == globalIndex
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surface,
                                    child: Center(
                                      child: Text(
                                        material.sequence.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .apply(
                                              color: selectDetailIndex ==
                                                      globalIndex
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                            ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  SizedBox(
                                    width: widget.selectFormula.header!
                                                .isEncrypted ==
                                            false
                                        ? 170
                                        : 250,
                                    child: Text(
                                      getRawName(material.materialId!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  widget.selectFormula.header!.isEncrypted ==
                                          false
                                      ? Container(
                                          // 设置最大宽度为 100
                                          constraints: const BoxConstraints(
                                              maxWidth: 100),
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            widget.selectFormula.header!
                                                        .formulaMode ==
                                                    'wgt'
                                                ? '${material.materialWeight.toString()} ${widget.selectFormula.header!.formulaUnit!}'
                                                : '${material.materialWeight.toString()} %',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                          ),
                                        )
                                      : SizedBox(),
                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        );
                        // 除了最后一个元素，每个元素后面添加横向间隔
                        if (subIndex <
                            detailsList!.sublist(startIndex, endIndex).length -
                                1) {
                          rowChildren.add(SizedBox(width: 20));
                        }
                      });
                      final row = Row(
                        children: rowChildren,
                      );
                      // 返回包含行和纵向间隔的列表
                      return [
                        row,
                        if (rowIndex < (detailsList!.length / 2).ceil() - 1)
                          SizedBox(height: 5)
                      ].expand((widget) => [widget]).toList();
                    }).expand((widgets) => widgets).toList(),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 72,
                width: 674,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 72,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline, // 设置边框颜色
                              width: 1, // 设置边框宽度
                            ),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                          ),
                          alignment: Alignment.topLeft,
                          child: SelectableText(
                            getRawRemark(selectDetail!.materialId!),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    ]),
              ),
              SizedBox(
                  height: 140,
                  width: 674,
                  child: Column(children: [
                    Container(
                      height: 42,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        (localizedStrings?.fRemarkCol ?? "fRemarkCol"),
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                            color: Theme.of(context).colorScheme.onSurface,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Row(children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 90,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline, // 设置边框颜色
                              width: 1, // 设置边框宽度
                            ),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                          ),
                          alignment: Alignment.topLeft,
                          child: SelectableText(
                            widget.selectFormula.header!.remark!,
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                color: Theme.of(context).colorScheme.onSurface,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    ]),
                  ])),
            ])),

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
                        Navigator.pop(ctx, true);
                      },
                      child: Text(
                        (localizedStrings?.fStartWeighingBtn ?? "fStartWeighingBtn"),
                        style: Theme.of(context).textTheme.bodySmall!.apply(
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
                        Navigator.pop(ctx, false);
                      },
                      child: Text(
                        (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                        style: Theme.of(context).textTheme.bodySmall!.apply(
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

  @override
  void dispose() {
    formulaWgtCtl.dispose();
    formulaUnitCtl.dispose();
    super.dispose();
  }
}
