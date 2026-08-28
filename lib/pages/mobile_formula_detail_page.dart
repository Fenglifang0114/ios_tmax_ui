import 'package:flutter/material.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/mobile_edit_formula_page.dart';
import 'package:t_max/pages/mobile_formula_records_page.dart';
import 'package:t_max/pages/start_fma_pct_page.dart';
import 'package:t_max/pages/start_fma_secret_page.dart';

class MobileFormulaDetailPage extends StatefulWidget {
  final FormulaInfoDb formula;

  const MobileFormulaDetailPage({
    super.key,
    required this.formula,
  });

  @override
  State<MobileFormulaDetailPage> createState() => _MobileFormulaDetailPageState();
}

class _MobileFormulaDetailPageState extends State<MobileFormulaDetailPage> {
  late FormulaInfoDb _currentFormula;
  dynamic _eventbusFormulaList;

  @override
  void initState() {
    super.initState();
    _currentFormula = widget.formula;
    _eventbusFormulaList = eventBus.on<EventRespFormulaList>().listen((event) {
      if (mounted) {
        _refreshFormulaInfo();
      }
    });
  }

  @override
  void dispose() {
    _eventbusFormulaList?.cancel();
    super.dispose();
  }

  void _refreshFormulaInfo() {
    for (var item in formulaDataList) {
      if (item.header?.recId == _currentFormula.header?.recId ||
          item.header?.formulaId == _currentFormula.header?.formulaId) {
        setState(() {
          _currentFormula = item;
        });
        break;
      }
    }
  }

  void _openFormulaRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MobileFormulaRecordsPage(),
      ),
    );
  }

  void _openEditFormulaScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileEditFormulaPage(formulaInfo: _currentFormula),
      ),
    );
    if (result == true || result != null) {
      PublicFunctions.getFormulaList();
      _refreshFormulaInfo();
    }
  }

  void _startWeighing() {
    bool confidential = _currentFormula.header?.isEncrypted ?? false;
    int scaleId = myAllScalesList.isNotEmpty ? myAllScalesList.first.scaleId : 1;
    double totalWgt = _currentFormula.header?.totalWeight ?? 100.0;
    String unit = _currentFormula.header?.formulaUnit ?? 'g';

    if (confidential) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormulaSecretWeighingPage(
            selectFormula: _currentFormula,
            selScaleId: scaleId,
            totalFmaWgt: totalWgt,
            fmaUnit: unit,
            fromDraft: false,
            selectDarftInfo: null,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormulaPctWeighingPage(
            selectFormula: _currentFormula,
            selScaleId: scaleId,
            totalFmaWgt: totalWgt,
            fmaUnit: unit,
            fromDarft: false,
          ),
        ),
      );
    }
  }

  String _getCategoryName() {
    if (_currentFormula.header?.categoryId == null) return '-';
    String cat = getFmaTypeName(_currentFormula.header!.categoryId!);
    return cat.isNotEmpty ? cat : '-';
  }

  @override
  Widget build(BuildContext context) {
    Header? header = _currentFormula.header;
    List<Detail> details = _currentFormula.details ?? [];

    String idStr = header?.formulaId ?? '-';
    String nameStr = header?.formulaName ?? '-';
    String barcodeStr = (header?.formulaBarcode != null && header!.formulaBarcode!.isNotEmpty)
        ? header.formulaBarcode!
        : '-';
    int count = header?.materialCount ?? details.length;
    String totalWeightStr = '${header?.totalWeight ?? 0.0}${header?.formulaUnit ?? 'g'}';
    String categoryStr = _getCategoryName();
    bool isConfidential = header?.isEncrypted ?? false;
    String modeStr = (header?.formulaMode == 'pct') ? 'Percentage' : 'Weight';
    String notesStr = (header?.remark != null && header!.remark!.isNotEmpty)
        ? header.remark!
        : '-';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Formula details',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.article_outlined, color: Colors.black87, size: 24),
            onPressed: _openFormulaRecords,
            tooltip: S.of(context).fRecordTitle,
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_outlined, color: Colors.black87, size: 26),
            onPressed: _openEditFormulaScreen,
            tooltip: 'Edit Formula',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1 Header: formula information
                    const Text(
                      'formula information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildDetailRow('ID', idStr),
                    _buildDetailRow('Name', nameStr),
                    _buildDetailRow('Barcode', barcodeStr),
                    _buildDetailRow('Quantity', count.toString()),
                    _buildDetailRow('Total Weight', totalWeightStr),
                    _buildDetailRow('Category', categoryStr),
                    _buildDetailRow(
                      'Confidential',
                      isConfidential ? 'Confidential' : 'Public',
                      customValueWidget: Text(
                        isConfidential ? 'Confidential' : 'Public',
                        style: TextStyle(
                          fontSize: 14,
                          color: isConfidential ? Colors.red.shade400 : const Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildDetailRow('Mode', modeStr),

                    const SizedBox(height: 12),

                    // Notes Field
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notesStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 16),

                    // Section 2: Ingredients Grid (Name)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Icon(Icons.grid_view_rounded, color: Color(0xFF004884), size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),

                    details.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Text(
                                'No ingredient details available',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.8,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: details.length,
                            itemBuilder: (context, index) {
                              Detail detail = details[index];
                              int seq = detail.sequence ?? (index + 1);
                              String rawName = getRawName(detail.materialId ?? '');
                              if (rawName.isEmpty) rawName = 'Ingredient ${detail.materialId}';
                              String wgtStr = (header?.formulaMode == 'pct')
                                  ? '${detail.materialPercentage ?? 0}%'
                                  : '${detail.materialWeight ?? 0}${header?.formulaUnit ?? 'g'}';

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: index == 0 ? const Color(0xFFEBF5FF) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: index == 0 ? const Color(0xFFBFDBFE) : Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: index == 0 ? const Color(0xFF004884) : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        seq.toString(),
                                        style: TextStyle(
                                          color: index == 0 ? Colors.white : Colors.black87,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        rawName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: index == 0 ? const Color(0xFF004884) : Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      wgtStr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: index == 0 ? const Color(0xFF004884) : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 16),
                    const Text(
                      'Ingredient Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notesStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Button: Start Weighing
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _startWeighing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004884),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Weighing',
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

  Widget _buildDetailRow(String label, String value, {Widget? customValueWidget}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
          customValueWidget ??
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
}
