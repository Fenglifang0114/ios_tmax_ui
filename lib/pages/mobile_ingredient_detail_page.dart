import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/mobile_edit_ingredient_page.dart';

import 'package:t_max/eventbus/eventbus.dart';

class MobileIngredientDetailPage extends StatefulWidget {
  final RawDataInfo rawInfo;

  const MobileIngredientDetailPage({
    super.key,
    required this.rawInfo,
  });

  @override
  State<MobileIngredientDetailPage> createState() => _MobileIngredientDetailPageState();
}

class _MobileIngredientDetailPageState extends State<MobileIngredientDetailPage> {
  late RawDataInfo _currentRaw;
  dynamic _eventbusRawList;

  @override
  void initState() {
    super.initState();
    _currentRaw = widget.rawInfo;
    _eventbusRawList = eventBus.on<EventRespGetRawDataList>().listen((event) {
      if (mounted) {
        _refreshRawInfo();
      }
    });
  }

  @override
  void dispose() {
    _eventbusRawList?.cancel();
    super.dispose();
  }

  void _refreshRawInfo() {
    for (var item in rawDataList) {
      if (item.recId == _currentRaw.recId) {
        setState(() {
          _currentRaw = item;
        });
        break;
      }
    }
  }

  void _openEditIngredientScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileEditIngredientPage(rawInfo: _currentRaw),
      ),
    );
    if (result != null && result is RawDataInfo) {
      setState(() {
        _currentRaw = result;
      });
      PublicFunctions.getRawList();
    } else if (result == true) {
      PublicFunctions.getRawList();
      _refreshRawInfo();
    }
  }

  void _onDeleteIngredient() {
    // Check if raw is used in formulas
    for (var fma in formulaDataList) {
      if (fma.details != null) {
        for (var detail in fma.details!) {
          if (detail.materialId == _currentRaw.materialId) {
            showTipInfo(
              localizedStrings?.fRawInUseDeleteErrorMsg ?? 'Ingredient is in use and cannot be deleted.',
              context,
            );
            return;
          }
        }
      }
    }

    showDialog(
      context: context,
      builder: (_) => const ShowDeleteTipDialog(
        title: 'Tip',
        msg: 'Are you sure you want to delete this ingredient?',
      ),
    ).then((confirmed) {
      if (confirmed == true && _currentRaw.recId != null) {
        int recId = _currentRaw.recId!;
        rawDataList.removeWhere((item) => item.recId == recId);
        PublicFunctions.deleteRawData(recId);
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    });
  }

  List<FormulaInfoDb> _getInvolvedFormulas() {
    List<FormulaInfoDb> list = [];
    if (_currentRaw.materialId == null || _currentRaw.materialId!.isEmpty) return list;

    for (var fma in formulaDataList) {
      if (fma.details != null) {
        for (var detail in fma.details!) {
          if (detail.materialId == _currentRaw.materialId) {
            list.add(fma);
            break;
          }
        }
      }
    }
    return list;
  }

  String _getDeviceName() {
    if (_currentRaw.scaleId == null) return '-';
    for (var scale in myAllScalesList) {
      if (scale.scaleId == _currentRaw.scaleId) {
        return scale.scaleName.isNotEmpty ? scale.scaleName : 'Device No.${scale.scaleId}';
      }
    }
    return '-';
  }

  String _getCategoryName() {
    if (_currentRaw.categoryId == null) return '-';
    String cat = getRawTypeName(_currentRaw.categoryId!);
    return cat.isNotEmpty ? cat : '-';
  }

  @override
  Widget build(BuildContext context) {
    List<FormulaInfoDb> involvedFormulas = _getInvolvedFormulas();

    String idStr = _currentRaw.materialId ?? '01';
    String nameStr = _currentRaw.materialName ?? '02';
    String checkCodeStr = (_currentRaw.checkCode != null && _currentRaw.checkCode!.isNotEmpty)
        ? _currentRaw.checkCode!
        : '02';
    String deviceStr = _getDeviceName();
    String categoryStr = _getCategoryName();
    String notesStr = (_currentRaw.ingredient != null && _currentRaw.ingredient!.isNotEmpty)
        ? _currentRaw.ingredient!
        : (_currentRaw.remark ?? 'Environmentally friendly, pure natural, and pollution-free rice');

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
        title: const Text(
          'Ingredient Detail',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined, color: Colors.black87, size: 26),
            onPressed: _openEditIngredientScreen,
            tooltip: 'Edit Ingredient',
          ),
        ],
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
                    // Detail Rows
                    _buildDetailRow('Ingredient ID', idStr),
                    _buildDetailRow('Ingredient Name', nameStr),
                    _buildDetailRow('Verification code', checkCodeStr),
                    _buildDetailRow('Device name', deviceStr),
                    _buildDetailRow('Category', categoryStr),
                    _buildDetailRow('Create Time', '2026-06-26 10:22:48'),
                    _buildDetailRow('Update Time', '2026-06-26 10:22:48'),

                    const SizedBox(height: 16),

                    // Ingredient Notes Section
                    const Text(
                      'Ingredient Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notesStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Involved Formulas Section
                    const Text(
                      'Involved Formulas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    involvedFormulas.isEmpty
                        ? Row(
                            children: [
                              _buildFormulaBadge('01'),
                              const SizedBox(width: 12),
                              _buildFormulaBadge('02'),
                              const SizedBox(width: 12),
                              _buildFormulaBadge('03'),
                            ],
                          )
                        : Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: involvedFormulas.map((fma) {
                              String fId = fma.header?.formulaId ?? '01';
                              return _buildFormulaBadge(fId);
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),

            // Bottom Red Delete Button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _onDeleteIngredient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Delete',
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

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaBadge(String formulaId) {
    return Container(
      width: 90,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        formulaId,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
