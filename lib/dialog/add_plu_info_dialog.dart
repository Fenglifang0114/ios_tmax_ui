import 'package:flutter/material.dart';
import 'package:t_max/widget/t_max_dialog.dart';

import 'package:flutter/services.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/plu_data.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class AddPluInfoDialog extends StatefulWidget {
  const AddPluInfoDialog(
      {super.key,
      required this.type,
      required this.selField,
      required this.pluList,
      required this.pluInfo,
      required this.onSave});
  final int type; // 0:添加 1:编辑
  final List<String> selField;
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
  List<Widget> showFields = [];

  dynamic _eventbus1;

  @override
  void initState() {
    if (widget.type == 1) {
      // 编辑
      pluCtl.text = widget.pluInfo.plu.toString();
      pluNameCtl.text = widget.pluInfo.productName!;
      priceCtl.text = widget.pluInfo.price.toString();
      wgtUnitCtl.text = widget.pluInfo.generalUnit.toString();
      if (!pluUnit.containsKey(widget.pluInfo.generalUnit)) {
        wgtUnitCtl.text = '0';
      }

      taxTypeCtl.text = widget.pluInfo.taxType.toString();
      if (!pluTax.containsKey(widget.pluInfo.taxType)) {
        taxTypeCtl.text = '0';
      }
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
      wgtUnitCtl.text = '0';
      taxTypeCtl.text = '0';
      unitWgtCtl.text = '0';
      pretareCtl.text = '0';
      limitHighCtl.text = '0';
      limitLowCtl.text = '0';
      categoryCtl.text = '';
      pluCodeCtl.text = '0';
      itemCodeCtl.text = '0';
    }

    _eventbus1 = eventBus.on<EventRespExistPlu>().listen((event) {
      if (mounted) {
        String res = event.obj;
        setState(() {
          if (res == 'true') {
            showTipInfo((localizedStrings?.fPluExist ?? "fPluExist"), context);
            return;
          } else {
            savePluInfo();
          }
        });
      }
    });

    super.initState();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    _buildDynamicFields();
  }

  @override
  void dispose() {
    _eventbus1.cancel();
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

//
// 构建动态字段列表
  _buildDynamicFields() {
    List<String> selField = widget.selField;

    if (selField.contains('plu')) {
      showFields.add(_buildFieldItem(getColumnName('plu'), showPluInput()));
    }
    if (selField.contains('productName')) {
      showFields.add(
          _buildFieldItem(getColumnName('productName'), showPluNameInput()));
    }
    if (selField.contains('price')) {
      showFields.add(
          _buildFieldItem(getColumnName('price'), showDecimalInput(priceCtl)));
    }
    if (selField.contains('generalUnit')) {
      showFields.add(
          _buildFieldItem(getColumnName('generalUnit'), showWgtUnitInput()));
    }
    if (selField.contains('taxType')) {
      showFields
          .add(_buildFieldItem(getColumnName('taxType'), showTaxTypeInput()));
    }
    if (selField.contains('unitWeight')) {
      showFields.add(_buildFieldItem(
          '${getColumnName('unitWeight')}(g)', showDecimalInput(unitWgtCtl)));
    }
    if (selField.contains('pretare')) {
      showFields.add(_buildFieldItem(
          '${getColumnName('pretare')}(kg)', showDecimalInput(pretareCtl)));
    }
    if (selField.contains('limitHigh')) {
      showFields.add(_buildFieldItem(
          getColumnName('limitHigh'), showDecimalInput(limitHighCtl)));
    }
    if (selField.contains('limitLow')) {
      showFields.add(_buildFieldItem(
          getColumnName('limitLow'), showDecimalInput(limitLowCtl)));
    }
    if (selField.contains('category')) {
      showFields
          .add(_buildFieldItem(getColumnName('category'), showCategoryInput()));
    }
    if (selField.contains('productCode')) {
      showFields.add(_buildFieldItem(
          getColumnName('productCode'), showCodeInput(pluCodeCtl)));
    }
    if (selField.contains('itemCode')) {
      showFields.add(_buildFieldItem(
          getColumnName('itemCode'), showCodeInput(itemCodeCtl)));
    }
  }

  Widget _buildFieldItem(String title, Widget inputWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showTitleName(title),
        inputWidget,
      ],
    );
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
        if (title == getColumnName('plu') ||
            title == getColumnName('productName'))
          SizedBox(
            width: 8,
            child: Text(
              "*",
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.error,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
    return DropdownButtonFormField<int>(
      value: wgtUnitCtl.text.isNotEmpty ? int.tryParse(wgtUnitCtl.text) : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0.0)),
        ),
        hintText: '',
        hintStyle: getTextStyle(
          color: colorScheme.surfaceContainerHighest,
        ),
      ),
      items: [
        for (var entry in pluUnit.entries)
          DropdownMenuItem<int>(
            value: entry.key,
            child: Text(
              entry.value,
              style: getTextStyle(color: colorScheme.onSurface),
            ),
          ),
      ],
      onChanged: (int? newValue) {
        if (newValue != null) {
          wgtUnitCtl.text = newValue.toString();
        }
      },
      style: getTextStyle(color: colorScheme.onSurface),
    );
  }

  Widget showTaxTypeInput() {
    return DropdownButtonFormField<int>(
      value: taxTypeCtl.text.isNotEmpty ? int.tryParse(taxTypeCtl.text) : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0.0)),
        ),
        hintText: '',
        hintStyle: getTextStyle(
          color: colorScheme.surfaceContainerHighest,
        ),
      ),
      items: [
        for (var entry in pluTax.entries)
          DropdownMenuItem<int>(
            value: entry.key,
            child: Text(
              entry.value,
              style: getTextStyle(color: colorScheme.onSurface),
            ),
          ),
      ],
      onChanged: (int? newValue) {
        if (newValue != null) {
          taxTypeCtl.text = newValue.toString();
        }
      },
      style: getTextStyle(color: colorScheme.onSurface),
    );
  }

  bool checkOk() {
    if (pluCtl.text.isEmpty || pluNameCtl.text.isEmpty) {
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

  void savePluInfo() {
    if (priceCtl.text.isEmpty) {
      priceCtl.text = '0';
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
    PluData newPlu = PluData(
        0, 0, 0, 0, '', '', 0, 0, 0, 0, 0, 0, 0, '', true, '', 0, 0, '', '');

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
          0,
          '',
          '');
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
          mySysUser.userId,
          '',
          '');
    }

    widget.onSave(newPlu);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return TMaxDialog(
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
                      ? (localizedStrings?.gBtnAdd ?? "gBtnAdd")
                      : (localizedStrings?.gBtnEdit ?? "gBtnEdit"),
                  true),

              // 中部
              Expanded(
                child: GridView.count(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  crossAxisCount: 3, // 每行3个
                  crossAxisSpacing: 20, // 水平间距
                  mainAxisSpacing: 10, // 垂直间距
                  childAspectRatio: 2.7, // 宽高比
                  children: showFields,
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
                                (localizedStrings?.fInputDataIncomplete ?? "fInputDataIncomplete"), context);
                            return;
                          }
                          if (checkPluExist()) {
                            showTipInfo((localizedStrings?.fPluExist ?? "fPluExist"), context);
                            return;
                          }
                          if (widget.type == 0) {
                            PublicFunctions.checkPluExist(0, pluCtl.text);
                          } else {
                            PublicFunctions.checkPluExist(
                                widget.pluInfo.recId!, pluCtl.text);
                          }
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
}
