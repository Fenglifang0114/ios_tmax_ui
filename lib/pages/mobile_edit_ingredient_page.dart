import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/mobile_category_management_page.dart';

class MobileEditIngredientPage extends StatefulWidget {
  final RawDataInfo? rawInfo;

  const MobileEditIngredientPage({
    super.key,
    this.rawInfo,
  });

  @override
  State<MobileEditIngredientPage> createState() => _MobileEditIngredientPageState();
}

class _MobileEditIngredientPageState extends State<MobileEditIngredientPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _checkCodeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCategoryName = 'Category';
  int _selectedCategoryId = 0;

  String _selectedDeviceName = 'Select Device';
  int? _selectedScaleId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.rawInfo != null) {
      var raw = widget.rawInfo!;
      _idController.text = raw.materialId ?? '';
      _nameController.text = raw.materialName ?? '';
      _checkCodeController.text = raw.checkCode ?? '';
      _notesController.text = raw.ingredient ?? raw.remark ?? '';

      if (raw.categoryId != null) {
        _selectedCategoryId = raw.categoryId!;
        for (var item in rawTypeList) {
          if (item.categoryId == raw.categoryId) {
            _selectedCategoryName = item.categoryName;
            break;
          }
        }
      }

      if (raw.scaleId != null) {
        _selectedScaleId = raw.scaleId;
        for (var scale in myAllScalesList) {
          if (scale.scaleId == raw.scaleId) {
            _selectedDeviceName = scale.scaleName.isNotEmpty
                ? scale.scaleName
                : 'Device No.${scale.scaleId}';
            break;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _checkCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _openCategorySelectBottomSheet() {
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
              rawTypeList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No category available',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: rawTypeList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        CategoryTypeList item = rawTypeList[index];
                        bool isSelected = _selectedCategoryId == item.categoryId;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = item.categoryId;
                              _selectedCategoryName = item.categoryName;
                            });
                            Navigator.pop(context);
                          },
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
                              item.categoryName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  void _openDeviceSelectBottomSheet() {
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
                    'Select Device',
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
              myAllScalesList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No device available',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: myAllScalesList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        Scale scale = myAllScalesList[index];
                        bool isSelected = _selectedScaleId == scale.scaleId;
                        String name = scale.scaleName.isNotEmpty
                            ? scale.scaleName
                            : 'Device No.${scale.scaleId}';

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedScaleId = scale.scaleId;
                              _selectedDeviceName = name;
                            });
                            Navigator.pop(context);
                          },
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
                              name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  bool _canConfirm() {
    return _idController.text.trim().isNotEmpty &&
        _nameController.text.trim().isNotEmpty;
  }

  void _onConfirm() {
    if (!_canConfirm()) return;

    String id = _idController.text.trim();
    String name = _nameController.text.trim();

    RawDataInfo updatedRaw = RawDataInfo(
      recId: widget.rawInfo?.recId,
      materialId: id,
      materialName: name,
      categoryId: _selectedCategoryId,
      scaleId: _selectedScaleId,
      checkCode: _checkCodeController.text.trim(),
      ingredient: _notesController.text.trim(),
      remark: _notesController.text.trim(),
      createdBy: widget.rawInfo?.createdBy ?? mySysUser.nickName ?? '',
      updatedBy: mySysUser.nickName ?? '',
    );

    if (widget.rawInfo == null) {
      // Check duplicate ID
      for (var item in rawDataList) {
        if (item.materialId == id) {
          showTipInfo(localizedStrings?.fRawIdDuplicate ?? 'Raw ID duplicated', context);
          return;
        }
      }

      AddRawData data = AddRawData(
        materialId: id,
        materialName: name,
        categoryId: _selectedCategoryId,
        ingredient: _notesController.text.trim(),
        createdBy: mySysUser.nickName ?? '',
        updatedBy: mySysUser.nickName ?? '',
        remark: '',
        remark1: '',
        scaleId: _selectedScaleId,
        checkCode: _checkCodeController.text.trim(),
        output: 0,
      );

      PublicFunctions.addRawData(data);
    } else {
      EditRawData data = EditRawData(
        recId: widget.rawInfo!.recId ?? 0,
        materialId: id,
        materialName: name,
        categoryId: _selectedCategoryId,
        ingredient: _notesController.text.trim(),
        createdBy: widget.rawInfo!.createdBy ?? mySysUser.nickName ?? '',
        updatedBy: mySysUser.nickName ?? '',
        remark: widget.rawInfo!.remark ?? '',
        remark1: widget.rawInfo!.remark1 ?? '',
        scaleId: _selectedScaleId,
        checkCode: _checkCodeController.text.trim(),
        output: 0,
      );

      PublicFunctions.editRawData(data);
    }

    Navigator.pop(context, updatedRaw);
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.rawInfo != null ? 'Edit Ingredient' : 'Add Ingredient';

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
                    // Field 1: Ingredient ID
                    _buildFormRow(
                      label: 'Ingredient ID',
                      isRequired: true,
                      child: TextField(
                        controller: _idController,
                        textAlign: TextAlign.right,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Please enter the ingredient ID.',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),

                    // Field 2: Ingredient Name
                    _buildFormRow(
                      label: 'Ingredient Name',
                      isRequired: true,
                      child: TextField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Enter ingredient name',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),

                    // Field 3: Category Field with Add Button
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
                                  _selectedCategoryName,
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
                                  builder: (context) => const MobileCategoryManagementPage(isRawType: true),
                                ),
                              ).then((_) {
                                PublicFunctions.getRawTypeList();
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

                    // Field 4: Select Device
                    _buildFormRow(
                      label: 'Select Device',
                      isRequired: false,
                      child: InkWell(
                        onTap: _openDeviceSelectBottomSheet,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _selectedDeviceName,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    // Field 5: Verification Code
                    _buildFormRow(
                      label: 'Verification code',
                      isRequired: false,
                      child: TextField(
                        controller: _checkCodeController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          hintText: 'Select Device',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Field 6: Ingredient Notes
                    const Text(
                      'Ingredient Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      height: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Please enter',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Confirm Button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _canConfirm() ? _onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004884),
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
              '*',
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
