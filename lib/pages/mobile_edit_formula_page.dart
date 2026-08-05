import 'package:flutter/material.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/add_formula_page.dart';
import 'package:t_max/pages/mobile_category_management_page.dart';
import 'package:t_max/pages/mobile_modify_ingredient_page.dart';
import 'package:t_max/pages/mobile_select_ingredient_page.dart';

class MobileEditFormulaPage extends StatefulWidget {
  final FormulaInfoDb? formulaInfo;

  const MobileEditFormulaPage({
    super.key,
    this.formulaInfo,
  });

  @override
  State<MobileEditFormulaPage> createState() => _MobileEditFormulaPageState();
}

class _MobileEditFormulaPageState extends State<MobileEditFormulaPage> {
  // Formula Header Controllers & States
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  String _selectedMode = 'Weight';
  String _selectedUnit = 'kg';
  bool _isConfidential = false;
  bool _needContainer = false;
  String _selectedCategory = 'Category';

  // Top Form ("Set Ingredient") State & Controllers
  RawDataInfo? _topSelectedRaw;
  final TextEditingController _topWeightController = TextEditingController();
  final TextEditingController _topErrorController = TextEditingController();
  final TextEditingController _topNotesController = TextEditingController();

  // Order List State
  final List<AddFormulaRawWgtInfo> _addedIngredientList = [];
  double _totalWeight = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.formulaInfo != null) {
      var header = widget.formulaInfo!.header;
      if (header != null) {
        _idController.text = header.formulaId ?? '';
        _nameController.text = header.formulaName ?? '';
        _barcodeController.text = header.formulaBarcode ?? '';
        _selectedMode = header.formulaMode == 'pct' ? 'Percentage' : 'Weight';
        _selectedUnit = header.formulaUnit ?? 'kg';
        _isConfidential = header.isEncrypted ?? false;
        _needContainer = header.needContainer ?? false;
        if (header.categoryId != null) {
          _selectedCategory = getFmaTypeName(header.categoryId!);
        }
      }

      if (widget.formulaInfo!.details != null) {
        for (var rawInfo in widget.formulaInfo!.details!) {
          String matId = rawInfo.materialId ?? '';
          RawDataInfo thisRaw = getRawData(matId);
          _addedIngredientList.add(
            AddFormulaRawWgtInfo(
              sequence: rawInfo.sequence ?? (_addedIngredientList.length + 1),
              wgt: rawInfo.materialPercentage?.toDouble() ?? 0.0,
              error: rawInfo.allowableError?.toDouble() ?? 0.0,
              isSelected: false,
              rawDataInfo: RawDataInfo(
                recId: rawInfo.recId ?? 0,
                materialId: matId,
                materialName: getRawName(matId),
                categoryId: thisRaw.categoryId ?? 0,
                ingredient: rawInfo.remark ?? thisRaw.ingredient ?? '',
                createdBy: thisRaw.createdBy,
                updatedBy: thisRaw.updatedBy,
                remark: thisRaw.remark,
                createdAt: thisRaw.createdAt,
                updatedAt: thisRaw.updatedAt,
                remark1: rawInfo.remark1 ?? '',
              ),
            ),
          );
        }
      }
      _calculateTotalWeight();
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _barcodeController.dispose();
    _topWeightController.dispose();
    _topErrorController.dispose();
    _topNotesController.dispose();
    super.dispose();
  }

  void _calculateTotalWeight() {
    double sum = 0.0;
    for (var item in _addedIngredientList) {
      sum += item.wgt;
    }
    setState(() {
      _totalWeight = double.parse(sum.toStringAsFixed(2));
    });
  }

  // ---------------------------------------------------------------------------
  // DIALOGS & BOTTOM SHEETS
  // ---------------------------------------------------------------------------
  void _openModeSelectBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSelectionCard(
                title: 'Weight',
                isSelected: _selectedMode == 'Weight',
                onTap: () {
                  setState(() => _selectedMode = 'Weight');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _buildSelectionCard(
                title: 'Percentage',
                isSelected: _selectedMode == 'Percentage',
                onTap: () {
                  setState(() => _selectedMode = 'Percentage');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _openUnitSelectBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weight Unit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...['g', 'kg', 'lb'].map((unit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: _buildSelectionCard(
                    title: unit,
                    isSelected: _selectedUnit == unit,
                    onTap: () {
                      setState(() => _selectedUnit = unit);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openCategorySelectBottomSheet() {
    List<String> categories = formulaTypeList.map((e) => e.categoryName).where((name) => name.isNotEmpty).toList();
    if (categories.isEmpty) {
      categories = ['Powder', 'Liquid', 'Solid'];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: _buildSelectionCard(
                    title: cat,
                    isSelected: _selectedCategory == cat,
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004884) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INGREDIENT ACTIONS (Set Ingredient & Order)
  // ---------------------------------------------------------------------------
  void _openSelectIngredientScreen() async {
    final RawDataInfo? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileSelectIngredientPage(
          initialSelected: _topSelectedRaw,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _topSelectedRaw = selected;
        if (selected.ingredient != null && selected.ingredient!.isNotEmpty) {
          _topNotesController.text = selected.ingredient!;
        }
      });
    }
  }

  bool _canAddTopIngredient() {
    if (_topSelectedRaw == null) return false;
    double? wgt = double.tryParse(_topWeightController.text.trim());
    double? err = double.tryParse(_topErrorController.text.trim());
    return wgt != null && wgt > 0 && err != null && err >= 0;
  }

  void _onAddTopIngredient() {
    if (!_canAddTopIngredient()) return;

    double wgt = double.parse(_topWeightController.text.trim());
    double err = double.parse(_topErrorController.text.trim());

    setState(() {
      _addedIngredientList.add(
        AddFormulaRawWgtInfo(
          sequence: _addedIngredientList.length + 1,
          wgt: wgt,
          error: err,
          isSelected: false,
          rawDataInfo: _topSelectedRaw!,
        ),
      );

      // Reset Top Form
      _topSelectedRaw = null;
      _topWeightController.clear();
      _topErrorController.clear();
      _topNotesController.clear();
    });

    _calculateTotalWeight();
  }

  void _openModifyIngredientScreen(int index) async {
    AddFormulaRawWgtInfo current = _addedIngredientList[index];
    final AddFormulaRawWgtInfo? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileModifyIngredientPage(
          rawInfo: current,
          unit: _selectedUnit,
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        _addedIngredientList[index] = updated;
      });
      _calculateTotalWeight();
    }
  }

  void _deleteIngredient(int index) {
    setState(() {
      _addedIngredientList.removeAt(index);
      for (int i = 0; i < _addedIngredientList.length; i++) {
        _addedIngredientList[i].sequence = i + 1;
      }
    });
    _calculateTotalWeight();
  }

  void _clearAllIngredients() {
    if (_addedIngredientList.isEmpty) return;
    setState(() {
      _addedIngredientList.clear();
      _totalWeight = 0.0;
    });
  }

  bool _canConfirmFormula() {
    return _idController.text.trim().isNotEmpty &&
        _nameController.text.trim().isNotEmpty &&
        _addedIngredientList.isNotEmpty;
  }

  void _onConfirmFormula() {
    if (!_canConfirmFormula()) return;

    int categoryId = 0;
    for (var item in formulaTypeList) {
      if (item.categoryName == _selectedCategory) {
        categoryId = item.categoryId;
        break;
      }
    }

    ReqFormulaHeader tempHeader = ReqFormulaHeader(
      recId: widget.formulaInfo?.header?.recId,
      formulaId: _idController.text.trim(),
      formulaKey: widget.formulaInfo?.header?.formulaKey,
      formulaName: _nameController.text.trim(),
      categoryId: categoryId,
      formulaMode: _selectedMode == 'Percentage' ? 'pct' : 'wgt',
      formulaUnit: _selectedUnit,
      totalWeight: _totalWeight,
      materialCount: _addedIngredientList.length,
      isEncrypted: _isConfidential,
      needContainer: _needContainer,
      createdBy: widget.formulaInfo?.header?.createdBy ?? mySysUser.nickName ?? '',
      updatedBy: mySysUser.nickName ?? '',
      remark: '',
      formulaBarcode: _barcodeController.text.trim(),
    );

    ReqFormulaAddInfo tempReqAddF = ReqFormulaAddInfo(
      header: tempHeader,
      detail: [],
    );

    int no = 1;
    for (var item in _addedIngredientList) {
      ReqFormulaDetail tempDetail = ReqFormulaDetail();
      tempDetail.formulaId = _idController.text.trim();
      tempDetail.materialId = item.rawDataInfo.materialId ?? '';
      tempDetail.materialWeight = item.wgt;
      tempDetail.materialPercentage = item.wgt;
      tempDetail.sequence = no++;
      tempDetail.allowableError = item.error;
      tempDetail.remark = item.rawDataInfo.ingredient ?? '';
      tempReqAddF.detail!.add(tempDetail);
    }

    String jsonStr = formulaAddInfoToJson(tempReqAddF);
    if (widget.formulaInfo != null) {
      PublicFunctions.editFormulaData(jsonStr);
    } else {
      PublicFunctions.addFormulaData(jsonStr);
    }

    Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // BUILD METHOD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    String titleText = widget.formulaInfo != null ? 'Edit Formula' : 'Add Formula';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          titleText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------------------------
                    // SECTION 1: FORMULA HEADER FORM
                    // ---------------------------------------------------------

                    // ID Field
                    _buildFormRow(
                      label: 'ID',
                      isRequired: true,
                      child: TextField(
                        controller: _idController,
                        textAlign: TextAlign.right,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Please enter the formula ID.',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),

                    // Name Field
                    _buildFormRow(
                      label: 'Name',
                      isRequired: true,
                      child: TextField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Please enter the formula name.',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),

                    // Mode Dropdown Field
                    _buildFormRow(
                      label: 'Mode',
                      isRequired: true,
                      child: InkWell(
                        onTap: _openModeSelectBottomSheet,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _selectedMode,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    // Weight Unit Dropdown Field
                    _buildFormRow(
                      label: 'Weight Unit',
                      isRequired: true,
                      child: InkWell(
                        onTap: _openUnitSelectBottomSheet,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _selectedUnit,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    // Barcode Field
                    _buildFormRow(
                      label: 'Barcode',
                      isRequired: false,
                      child: TextField(
                        controller: _barcodeController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          hintText: 'Barcode',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),

                    // Checkbox Row (Confidential & Need Container)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _isConfidential,
                                  activeColor: const Color(0xFF004884),
                                  onChanged: (val) => setState(() => _isConfidential = val ?? false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Confidential',
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _needContainer,
                                  activeColor: const Color(0xFF004884),
                                  onChanged: (val) => setState(() => _needContainer = val ?? false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Need Container',
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Category Field with Add Button
                    _buildFormRow(
                      label: 'Category',
                      isRequired: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: _openCategorySelectBottomSheet,
                            child: Row(
                              children: [
                                Text(
                                  _selectedCategory,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MobileCategoryManagementPage(),
                                ),
                              ).then((_) {
                                PublicFunctions.getFormulaTypeList();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 12),

                    // ---------------------------------------------------------
                    // SECTION 2: SET INGREDIENT FORM (ONLY FOR ADDING)
                    // ---------------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Set Ingredient',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _topSelectedRaw = null;
                              _topWeightController.clear();
                              _topErrorController.clear();
                              _topNotesController.clear();
                            });
                          },
                          child: const Text(
                            'Add Ingredient',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF004884),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Select Ingredient Input Box
                    _buildFormRow(
                      label: 'Select Ingredient',
                      isRequired: true,
                      child: InkWell(
                        onTap: _openSelectIngredientScreen,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _topSelectedRaw != null
                                  ? ((_topSelectedRaw!.materialId != null && _topSelectedRaw!.materialId!.isNotEmpty)
                                      ? _topSelectedRaw!.materialId!
                                      : (_topSelectedRaw!.materialName ?? ''))
                                  : 'Select Ingredient',
                              style: TextStyle(
                                fontSize: 14,
                                color: _topSelectedRaw != null ? Colors.black87 : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    // Weight Input Box
                    _buildFormRow(
                      label: 'Weight',
                      isRequired: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _topWeightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Please enter the weight.',
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedUnit,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),

                    // Allowable Error Input Box
                    _buildFormRow(
                      label: 'Allowable Error',
                      isRequired: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _topErrorController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Please enter the error.',
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '±',
                            style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Notes Text Area Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextField(
                        controller: _topNotesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Ingredient Notes...',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dark Blue Add Button (Only Adds to Order List)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _canAddTopIngredient() ? _onAddTopIngredient : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004884),
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 12),

                    // ---------------------------------------------------------
                    // SECTION 3: ORDER LIST (ADDED INGREDIENTS)
                    // ---------------------------------------------------------
                    Row(
                      children: [
                        const Text(
                          'Order',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total Weight : $_totalWeight $_selectedUnit',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: _clearAllIngredients,
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Cards List
                    _addedIngredientList.isEmpty
                        ? Container(
                            height: 80,
                            alignment: Alignment.center,
                            child: Text(
                              'No ingredients added yet',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _addedIngredientList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              AddFormulaRawWgtInfo item = _addedIngredientList[index];
                              String matId = item.rawDataInfo.materialId ?? '';
                              String matName = item.rawDataInfo.materialName ?? '';
                              String nameDisplay = matId.isNotEmpty ? matId : matName;
                              String notes = item.rawDataInfo.ingredient ?? '';

                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Number Badge + Action Icons (Edit & Delete)
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF004884),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Edit Button (Pencil Icon) -> Pops Modify Screen
                                        InkWell(
                                          onTap: () => _openModifyIngredientScreen(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade400),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Delete Button (Trash Icon)
                                        InkWell(
                                          onTap: () => _deleteIngredient(index),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Row 2: 3 Columns Grid (Name, Weight, Allowable Error)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Name',
                                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                nameDisplay,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Weight',
                                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${item.wgt}',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Allowable Error',
                                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${item.error}',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Row 3: Ingredient Notes (if any)
                                    if (notes.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        'Ingredient Notes',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        notes,
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Confirm Button (Green #10B981)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _canConfirmFormula() ? _onConfirmFormula : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormRow({
    required String label,
    required bool isRequired,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          if (isRequired)
            const Text(
              '* ',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
