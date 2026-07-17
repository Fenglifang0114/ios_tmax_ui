import 'package:flutter/material.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/data/g_data.dart';

class MobilePluDetailPage extends StatefulWidget {
  final int type; // 0 for Add, 1 for Edit
  final List<String> selField;
  final List<int> pluList;
  final PluData pluInfo;
  final Function(PluData) onSave;

  const MobilePluDetailPage({
    super.key,
    required this.type,
    required this.selField,
    required this.pluList,
    required this.pluInfo,
    required this.onSave,
  });

  @override
  State<MobilePluDetailPage> createState() => _MobilePluDetailPageState();
}

class _MobilePluDetailPageState extends State<MobilePluDetailPage> {
  late TextEditingController pluCtl;
  late TextEditingController pluNameCtl;
  late TextEditingController priceCtl;
  late TextEditingController unitWgtCtl;
  late TextEditingController pretareCtl;
  late TextEditingController limitHighCtl;
  late TextEditingController limitLowCtl;
  late TextEditingController categoryCtl;
  late TextEditingController pluCodeCtl;
  late TextEditingController itemCodeCtl;

  int _selectedUnit = 0;
  int _selectedTax = 0;

  final Map<int, String> pluWgtUnit = {
    0: 'kg',
    1: 'g',
    2: 'lb',
    3: 'oz',
    4: 'pcs',
  };

  final Map<int, String> pluTax = {
    0: 'tax1',
    1: 'tax2',
    2: 'tax3',
    3: 'tax4',
    4: 'tax5',
    5: 'tax6',
  };

  @override
  void initState() {
    super.initState();
    pluCtl = TextEditingController(text: widget.type == 0 ? '' : widget.pluInfo.plu.toString());
    pluNameCtl = TextEditingController(text: widget.pluInfo.productName ?? '');
    priceCtl = TextEditingController(text: widget.type == 0 ? '' : widget.pluInfo.price.toString());
    unitWgtCtl = TextEditingController(text: widget.type == 0 ? '' : widget.pluInfo.unitWeight.toString());
    pretareCtl = TextEditingController(text: widget.type == 0 ? '' : widget.pluInfo.pretare.toString());
    limitHighCtl = TextEditingController(text: widget.type == 0 ? '' : widget.pluInfo.limitHigh.toString());
    limitLowCtl = TextEditingController(text: widget.type == 0 ? '' : widget.pluInfo.limitLow.toString());
    categoryCtl = TextEditingController(text: widget.type == 0 || widget.pluInfo.category == '-' ? '' : widget.pluInfo.category);
    pluCodeCtl = TextEditingController(text: widget.type == 0 ? '' : widget.pluInfo.productCode.toString());
    itemCodeCtl = TextEditingController(text: widget.type == 0 ? '' : widget.pluInfo.itemCode.toString());

    _selectedUnit = widget.pluInfo.generalUnit ?? 0;
    _selectedTax = widget.pluInfo.taxType ?? 0;
  }

  @override
  void dispose() {
    pluCtl.dispose();
    pluNameCtl.dispose();
    priceCtl.dispose();
    unitWgtCtl.dispose();
    pretareCtl.dispose();
    limitHighCtl.dispose();
    limitLowCtl.dispose();
    categoryCtl.dispose();
    pluCodeCtl.dispose();
    itemCodeCtl.dispose();
    super.dispose();
  }

  bool checkOk() {
    if (pluCtl.text.isEmpty || pluNameCtl.text.isEmpty) {
      return false;
    }
    return true;
  }

  void _save() {
    if (!checkOk()) {
      showTipInfo(localizedStrings?.fInputDataIncomplete ?? "Incomplete data", context);
      return;
    }
    int currentPlu = int.parse(pluCtl.text);
    if (widget.type == 0 && widget.pluList.contains(currentPlu)) {
      showTipInfo(localizedStrings?.fPluExist ?? "PLU exists", context);
      return;
    }
    if (widget.type == 1 && widget.pluList.contains(currentPlu) && currentPlu != widget.pluInfo.plu) {
      showTipInfo(localizedStrings?.fPluExist ?? "PLU exists", context);
      return;
    }

    PluData newPlu = PluData(
      widget.type == 0 ? 0 : widget.pluInfo.recId,
      currentPlu,
      int.tryParse(pluCodeCtl.text) ?? 0,
      int.tryParse(itemCodeCtl.text) ?? 0,
      categoryCtl.text.isEmpty ? '-' : categoryCtl.text,
      pluNameCtl.text,
      _selectedUnit,
      _selectedTax,
      double.tryParse(priceCtl.text) ?? 0,
      double.tryParse(unitWgtCtl.text) ?? 0,
      double.tryParse(pretareCtl.text) ?? 0,
      double.tryParse(limitHighCtl.text) ?? 0,
      double.tryParse(limitLowCtl.text) ?? 0,
      widget.type == 0 ? '' : widget.pluInfo.creatAt,
      widget.type == 0 ? true : widget.pluInfo.enabled,
      DateTime.now().toIso8601String(),
      widget.type == 0 ? null : widget.pluInfo.createBy,
      mySysUser.userId as int?,
      '',
      ''
    );

    widget.onSave(newPlu);
    Navigator.pop(context);
  }

  Widget _buildTextFieldRow(String title, TextEditingController ctl, String hint, {bool isRequired = false, bool isNumber = false, bool isEnabled = true}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Row(
              children: [
                if (isRequired) const Text('* ', style: TextStyle(color: Colors.red, fontSize: 16)),
                Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: ctl,
              enabled: isEnabled,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black38),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String title, int value, Map<int, String> items, Function(int) onChanged) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView(
              shrinkWrap: true,
              children: items.entries.map((e) => ListTile(
                title: Text(e.value, textAlign: TextAlign.center),
                onTap: () {
                  onChanged(e.key);
                  Navigator.pop(context);
                },
              )).toList(),
            );
          }
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            Row(
              children: [
                Text(items[value] ?? '', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String titleStr = widget.type == 0 ? (localizedStrings?.gBtnAdd ?? "Add") : (localizedStrings?.gBtnEdit ?? "Edit");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        title: Text(titleStr, style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (widget.selField.contains('plu'))
                  _buildTextFieldRow(localizedStrings?.gPluPlu ?? "PLU", pluCtl, "0-99999", isNumber: true, isRequired: true, isEnabled: widget.type == 0),
                if (widget.selField.contains('productName'))
                  _buildTextFieldRow(localizedStrings?.gPluPluName ?? "Product Name", pluNameCtl, "0-30 characters", isRequired: true),
                if (widget.selField.contains('price'))
                  _buildTextFieldRow(localizedStrings?.gPluPrice ?? "Price", priceCtl, "0-9999999", isNumber: true),
                if (widget.selField.contains('generalUnit'))
                  _buildDropdownRow(localizedStrings?.gPluWgtUnit ?? "Unit", _selectedUnit, pluWgtUnit, (v) => setState(() => _selectedUnit = v)),
                if (widget.selField.contains('taxType'))
                  _buildDropdownRow(localizedStrings?.gPluTaxType ?? "Tax Type", _selectedTax, pluTax, (v) => setState(() => _selectedTax = v)),
                if (widget.selField.contains('unitWeight'))
                  _buildTextFieldRow(localizedStrings?.gPluUnitWgt ?? "Unit Weight(g)", unitWgtCtl, "", isNumber: true),
                if (widget.selField.contains('pretare'))
                  _buildTextFieldRow(localizedStrings?.gPluPretare ?? "Pretare(kg)", pretareCtl, "", isNumber: true),
                if (widget.selField.contains('limitHigh'))
                  _buildTextFieldRow(localizedStrings?.gPluLimitHigh ?? "Limit High", limitHighCtl, "", isNumber: true),
                if (widget.selField.contains('limitLow'))
                  _buildTextFieldRow(localizedStrings?.gPluLimitLow ?? "Limit Low", limitLowCtl, "", isNumber: true),
                if (widget.selField.contains('category'))
                  _buildTextFieldRow(localizedStrings?.gPluCategory ?? "Category", categoryCtl, ""),
                if (widget.selField.contains('productCode'))
                  _buildTextFieldRow(localizedStrings?.gPluPluCode ?? "Product Code", pluCodeCtl, "", isNumber: true),
                if (widget.selField.contains('itemCode'))
                  _buildTextFieldRow(localizedStrings?.gPluItemCode ?? "Item Code", itemCodeCtl, "", isNumber: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD5D5D5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  localizedStrings?.gBtnConfirm ?? "Confirm",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
