import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class AddPluInfoDialog extends StatefulWidget {
  const AddPluInfoDialog(
      {super.key,
      required this.type,
      required this.pluList,
      required this.pluInfo,
      required this.onSave});
  final int type; // 0:添加 1:编辑
  final List<int> pluList; //PLU的列表
  final PluData pluInfo;
  final Function(PluData) onSave;
  @override
  AddPluInfoDialogState createState() => AddPluInfoDialogState();
}

class AddPluInfoDialogState extends State<AddPluInfoDialog> {
  TextEditingController pluCtl = TextEditingController();
  TextEditingController pluNameCtl = TextEditingController();
  TextEditingController priceCtl = TextEditingController();
  TextEditingController wgtUnitCtl = TextEditingController();
  TextEditingController taxTypeCtl = TextEditingController();
  TextEditingController unitWgtCtl = TextEditingController();
  TextEditingController pretareCtl = TextEditingController();
  TextEditingController limitHighCtl = TextEditingController();
  TextEditingController limitLowCtl = TextEditingController();
  TextEditingController categoryCtl = TextEditingController();
  TextEditingController pluCodeCtl = TextEditingController();
  TextEditingController itemCodeCtl = TextEditingController();

  @override
  void initState() {
    if (widget.type == 1) {
      // 编辑
      pluCtl.text = widget.pluInfo.plu.toString();
      pluNameCtl.text = widget.pluInfo.productName!;
      priceCtl.text = widget.pluInfo.price.toString();
      wgtUnitCtl.text = widget.pluInfo.generalUnit.toString();
      taxTypeCtl.text = widget.pluInfo.taxType.toString();
      unitWgtCtl.text = widget.pluInfo.unitWeight.toString();
      pretareCtl.text = widget.pluInfo.pretare.toString();
      limitHighCtl.text = widget.pluInfo.limitHigh.toString();
      limitLowCtl.text = widget.pluInfo.limitLow.toString();
      categoryCtl.text = widget.pluInfo.category!;
      pluCodeCtl.text = widget.pluInfo.productCode.toString();
      itemCodeCtl.text = widget.pluInfo.itemCode.toString();
    } else {
      // 添加
      pluCtl.text = '';
      pluNameCtl.text = '';
      priceCtl.text = '';
      wgtUnitCtl.text = '';
      taxTypeCtl.text = '';
      unitWgtCtl.text = '0';
      pretareCtl.text = '0';
      limitHighCtl.text = '0';
      limitLowCtl.text = '0';
      categoryCtl.text = '';
      pluCodeCtl.text = '0';
      itemCodeCtl.text = '0';
    }
    super.initState();
  }

//

  @override
  void dispose() {
    pluCtl.dispose();
    pluNameCtl.dispose();
    priceCtl.dispose();
    wgtUnitCtl.dispose();
    taxTypeCtl.dispose();
    unitWgtCtl.dispose();
    pretareCtl.dispose();
    limitHighCtl.dispose();
    limitLowCtl.dispose();
    categoryCtl.dispose();
    pluCodeCtl.dispose();
    itemCodeCtl.dispose();

    super.dispose();
  }

  Widget customTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget showTitleName(String title) {
    return SizedBox(
      height: 42,
      child: Row(children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: customTitle(title),
          ),
        ),
      ]),
    );
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  Widget showPluInput() {
    return TextField(
      controller: pluCtl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0))),
        hintText: '0-99999',
        hintStyle: getTextStyle(
          color: colorScheme.surfaceContainerHighest,
        ),
        suffixIconConstraints: BoxConstraints.tight(Size(40, 40)),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
        // 使用正则表达式验证输入格式
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          final regExp = RegExp(r'^0$|^[1-9]\d{0,4}$');
          if (regExp.hasMatch(newValue.text)) {
            return newValue;
          }
          return oldValue;
        }),
      ],
      keyboardType: TextInputType.number,
      onChanged: (value) {},
      style: getTextStyle(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget showCodeInput(TextEditingController ctl) {
    return TextField(
      controller: ctl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0))),
        hintText: '0-9999999999',
        hintStyle: getTextStyle(
          color: colorScheme.surfaceContainerHighest,
        ),
        suffixIconConstraints: BoxConstraints.tight(Size(40, 40)),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
        // 使用正则表达式验证输入格式
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          final regExp = RegExp(r'^0$|^[1-9]\d{0,9}$');
          if (regExp.hasMatch(newValue.text)) {
            return newValue;
          }
          return oldValue;
        }),
      ],
      keyboardType: TextInputType.number,
      onChanged: (value) {},
      style: getTextStyle(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget showPluNameInput() {
    return TextField(
      controller: pluNameCtl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0))),
        hintText: '0-30 characters',
        hintStyle: getTextStyle(
          color: colorScheme.surfaceContainerHighest,
        ),
        suffixIconConstraints: BoxConstraints.tight(Size(40, 40)),
      ),
      maxLines: 1,
      inputFormatters: [
        LengthLimitingTextInputFormatter(30),
      ],
      onChanged: (value) {},
      style: getTextStyle(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget showCategoryInput() {
    return TextField(
      controller: categoryCtl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0))),
        hintText: '0-30 characters',
        hintStyle: getTextStyle(
          color: colorScheme.surfaceContainerHighest,
        ),
        suffixIconConstraints: BoxConstraints.tight(Size(40, 40)),
      ),
      maxLines: 1,
      inputFormatters: [
        LengthLimitingTextInputFormatter(30),
      ],
      onChanged: (value) {},
      style: getTextStyle(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget showDecimalInput(TextEditingController ctl) {
    return TextField(
      controller: ctl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0))),
        hintText: '0-9999999',
        hintStyle: getTextStyle(
          color: colorScheme.surfaceContainerHighest,
        ),
        suffixIconConstraints: BoxConstraints.tight(Size(40, 40)),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(11), // 最大长度：9999999.999(11个字符)
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;

          // 1. 不能有多个小数点
          if (newValue.text.split('.').length > 2) {
            return oldValue;
          }

          // 2. 正则匹配优化：允许临时输入状态（如"123."）
          // 最终验证会确保正确格式，但允许中间状态
          final regExp = RegExp(
            r'^0$|^0\.$|^[1-9]\d{0,6}$|^[1-9]\d{0,6}\.$|'
            r'^0\.\d{1,3}$|^[1-9]\d{0,6}\.\d{1,3}$',
          );

          if (!regExp.hasMatch(newValue.text)) {
            return oldValue;
          }

          // 3. 数值范围验证(0-9999999)
          // 处理带小数点的临时状态（如"9999999."）
          final String valueToCheck = newValue.text.endsWith('.')
              ? newValue.text.substring(0, newValue.text.length - 1)
              : newValue.text;

          final number = double.tryParse(valueToCheck);
          if (number != null && number > 9999999) {
            return oldValue;
          }

          return newValue;
        }),
      ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {},
      style: getTextStyle(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget showWgtUnitInput() {
    return TextField(
      controller: wgtUnitCtl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0))),
        hintText:
            'wgt:0-g,1-kg,2-lb,3-oz,4-lboz,5-tj,6-hj,7-t \r\nprice:0-kg,1-100g,2-pcs',
        hintStyle: getTextStyle(
          color: colorScheme.surfaceContainerHighest,
        ),
        suffixIconConstraints: BoxConstraints.tight(Size(40, 40)),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1),
        // 使用正则表达式验证输入格式
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          final regExp = RegExp(r'^[0-7]');
          if (regExp.hasMatch(newValue.text)) {
            return newValue;
          }
          return oldValue;
        }),
      ],
      keyboardType: TextInputType.number,
      onChanged: (value) {},
      style: getTextStyle(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget showTaxTypeInput() {
    return TextField(
      controller: taxTypeCtl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0))),
        hintText: '0-tax1,1-tax2,2-tax3',
        hintStyle: getTextStyle(
          color: colorScheme.surfaceContainerHighest,
        ),
        suffixIconConstraints: BoxConstraints.tight(Size(40, 40)),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1),
        // 使用正则表达式验证输入格式
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          final regExp = RegExp(r'^[0-2]');
          if (regExp.hasMatch(newValue.text)) {
            return newValue;
          }
          return oldValue;
        }),
      ],
      keyboardType: TextInputType.number,
      onChanged: (value) {},
      style: getTextStyle(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget showFirstRow() {
    return SizedBox(
      height: 90,
      child: Row(children: [
        Expanded(
            flex: 1,
            child: Column(children: [showTitleName('Plu'), showPluInput()])),
        SizedBox(
          width: 20,
        ),
        Expanded(
            flex: 1,
            child: Column(
                children: [showTitleName('Plu Name'), showPluNameInput()])),
        SizedBox(
          width: 20,
        ),
        Expanded(
            flex: 1,
            child: Column(children: [
              showTitleName('Price'),
              showDecimalInput(priceCtl)
            ])),
      ]),
    );
  }

  Widget showSecondRow() {
    return SizedBox(
      height: 90,
      child: Row(children: [
        Expanded(
            flex: 1,
            child: Column(
                children: [showTitleName('General Unit'), showWgtUnitInput()])),
        SizedBox(
          width: 20,
        ),
        Expanded(
            flex: 1,
            child: Column(
                children: [showTitleName('Tax Type'), showTaxTypeInput()])),
        SizedBox(
          width: 20,
        ),
        Expanded(
            flex: 1,
            child: Column(children: [
              showTitleName('Unit Weight (g)'),
              showDecimalInput(unitWgtCtl)
            ])),
      ]),
    );
  }

  Widget showThirdRow() {
    return SizedBox(
      height: 90,
      child: Row(children: [
        Expanded(
            flex: 1,
            child: Column(children: [
              showTitleName('pretare (kg)'),
              showDecimalInput(pretareCtl)
            ])),
        SizedBox(
          width: 20,
        ),
        Expanded(
            flex: 1,
            child: Column(children: [
              showTitleName('Limit High'),
              showDecimalInput(limitHighCtl)
            ])),
        SizedBox(
          width: 20,
        ),
        Expanded(
            flex: 1,
            child: Column(children: [
              showTitleName('Limit Low'),
              showDecimalInput(limitLowCtl)
            ])),
      ]),
    );
  }

  Widget showFourthRow() {
    return SizedBox(
      height: 90,
      child: Row(children: [
        Expanded(
            flex: 1,
            child: Column(
                children: [showTitleName('Category'), showCategoryInput()])),
        SizedBox(
          width: 20,
        ),
        Expanded(
            flex: 1,
            child: Column(children: [
              showTitleName('Product Code'),
              showCodeInput(pluCodeCtl)
            ])),
        SizedBox(
          width: 20,
        ),
        Expanded(
            flex: 1,
            child: Column(children: [
              showTitleName('Item Code'),
              showCodeInput(itemCodeCtl)
            ])),
      ]),
    );
  }

  bool checkOk() {
    if (pluCtl.text.isEmpty ||
        pluNameCtl.text.isEmpty ||
        wgtUnitCtl.text.isEmpty ||
        priceCtl.text.isEmpty ||
        taxTypeCtl.text.isEmpty ||
        unitWgtCtl.text.isEmpty) {
      return false;
    }
    return true;
  }

  bool checkPluExist() {
    if (widget.type == 0) {
      if (widget.pluList.contains(int.parse(pluCtl.text))) {
        return true;
      } else {
        return false;
      }
    }

    if (widget.type == 1) {
      if (widget.pluList.contains(int.parse(pluCtl.text)) &&
          int.parse(pluCtl.text) != widget.pluInfo.plu) {
        return true;
      } else {
        return false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
          width: 810,
          height: 595,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            children: [
              // 头部
              ...dialogHeadStyle(
                  context,
                  widget.type == 0
                      ? localizedStrings.gBtnAdd
                      : localizedStrings.gBtnEdit,
                  true),

              // 中部
              Expanded(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(children: [
                        showFirstRow(),
                        showSecondRow(),
                        showThirdRow(),
                        showFourthRow(),
                        Container(
                          height: 44,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localizedStrings.gPluWgtUnit +
                                ":          weight:0-g,1-kg,2-lb,3-oz,4-lboz,5-tj,6-hj,7-t   price:0-kg,1-100g,2-pcs",
                            style: getTextStyle(color: colorScheme.primary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
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
                          if (!checkOk()) {
                            showTipInfo(
                                localizedStrings.fInputDataIncomplete, context);
                            return;
                          }
                          if (checkPluExist()) {
                            showTipInfo(localizedStrings.fPluExist, context);
                            return;
                          }

                          if (pretareCtl.text.isEmpty) {
                            pretareCtl.text = '0';
                          }
                          if (limitHighCtl.text.isEmpty) {
                            limitHighCtl.text = '0';
                          }
                          if (limitLowCtl.text.isEmpty) {
                            limitLowCtl.text = '0';
                          }
                          if (categoryCtl.text.isEmpty) {
                            categoryCtl.text = '-';
                          }
                          if (pluCodeCtl.text.isEmpty) {
                            pluCodeCtl.text = '0';
                          }
                          if (itemCodeCtl.text.isEmpty) {
                            itemCodeCtl.text = '0';
                          }
                          PluData newPlu = PluData(0, 0, 0, 0, '', '', 0, 0, 0,
                              0, 0, 0, 0, '', true, '', 0, 0);

                          if (widget.type == 0) {
                            newPlu = PluData(
                                0,
                                int.parse(pluCtl.text),
                                int.parse(pluCodeCtl.text),
                                int.parse(itemCodeCtl.text),
                                categoryCtl.text,
                                pluNameCtl.text,
                                int.parse(wgtUnitCtl.text),
                                int.parse(taxTypeCtl.text),
                                double.parse(priceCtl.text),
                                double.parse(unitWgtCtl.text),
                                double.parse(pretareCtl.text),
                                double.parse(limitHighCtl.text),
                                double.parse(limitLowCtl.text),
                                '',
                                true,
                                '',
                                0,
                                0);
                          } else {
                            newPlu = PluData(
                                widget.pluInfo.recId,
                                int.parse(pluCtl.text),
                                int.parse(pluCodeCtl.text),
                                int.parse(itemCodeCtl.text),
                                categoryCtl.text,
                                pluNameCtl.text,
                                int.parse(wgtUnitCtl.text),
                                int.parse(taxTypeCtl.text),
                                double.parse(priceCtl.text),
                                double.parse(unitWgtCtl.text),
                                double.parse(pretareCtl.text),
                                double.parse(limitHighCtl.text),
                                double.parse(limitLowCtl.text),
                                widget.pluInfo.creatAt,
                                widget.pluInfo.enabled,
                                DateTime.now().toIso8601String(),
                                widget.pluInfo.createBy,
                                mySysUser.userId);
                          }

                          widget.onSave(newPlu);
                          Navigator.pop(context);
                        },
                        child: Text(
                          localizedStrings.gBtnConfirm,
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
                          localizedStrings.gBtnCancel,
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
}

// 提取输入框部分为单独的组件
class _InputSection extends StatelessWidget {
  final InputDecoration inputDecoration;
  final TextEditingController rawRemarkCtl;

  const _InputSection(
      {required this.inputDecoration, required this.rawRemarkCtl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: rawRemarkCtl,
            decoration: inputDecoration.copyWith(
              hintText: localizedStrings.fInputIngredientDescHint,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            maxLines: 4,
            style: Theme.of(context).textTheme.bodySmall!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}
