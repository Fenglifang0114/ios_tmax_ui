import 'package:flutter/material.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/dialog/mobile_formula_total_weight_dialog.dart';
import 'package:t_max/pages/start_darft_fma_pct_page.dart';
import 'package:t_max/pages/start_fma_secret_page.dart';
import 'package:t_max/functions/methods.dart';

class MobileFormulaRecordDetailPage extends StatefulWidget {
  final DarfFmaInfo darftFma;
  final int selScaleId;

  const MobileFormulaRecordDetailPage({
    super.key,
    required this.darftFma,
    this.selScaleId = 1,
  });

  @override
  State<MobileFormulaRecordDetailPage> createState() =>
      _MobileFormulaRecordDetailPageState();
}

class _MobileFormulaRecordDetailPageState
    extends State<MobileFormulaRecordDetailPage> {

  void _onDeleteRecord() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this temporary storage record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              String orderId = widget.darftFma.fmaRec?.header?.orderId ?? '';
              if (orderId.isNotEmpty) {
                PublicFunctions.deleteDraftRecord(orderId);
              }
              Navigator.pop(context, true);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onContinueWeighing() {
    DarfFmaInfo darftFma = widget.darftFma;
    FormulaInfoDb? formula = darftFma.fmaInfo;
    if (formula == null || formula.details == null || formula.details!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formula details are empty, cannot weigh.')),
      );
      return;
    }

    String mode = formula.header?.formulaMode?.toLowerCase() ?? 'wgt';
    bool isEncrypted = formula.header?.isEncrypted ?? false;

    if (mode == 'pct' || mode == 'percentage') {
      // Open total weight & unit input dialog (Screenshot 3)
      showDialog(
        context: context,
        builder: (context) => MobileFormulaTotalWeightDialog(
          initialWeight: formula.header?.totalWeight,
          initialUnit: formula.header?.formulaUnit,
        ),
      ).then((result) {
        if (result != null && result is Map<String, dynamic>) {
          double totalWgt = result['totalWgt'] as double;
          String fmaUnit = result['fmaUnit'] as String;

          _startWeighing(
            formula: formula,
            isEncrypted: isEncrypted,
            totalWgt: totalWgt,
            fmaUnit: fmaUnit,
            darftRec: darftFma.fmaRec,
          );
        }
      });
    } else {
      // Weight mode: directly start weighing
      double totalWgt = formula.header?.totalWeight ?? 1000.0;
      String fmaUnit = formula.header?.formulaUnit ?? 'g';

      _startWeighing(
        formula: formula,
        isEncrypted: isEncrypted,
        totalWgt: totalWgt,
        fmaUnit: fmaUnit,
        darftRec: darftFma.fmaRec,
      );
    }
  }

  void _startWeighing({
    required FormulaInfoDb formula,
    required bool isEncrypted,
    required double totalWgt,
    required String fmaUnit,
    required DarfFmaInfoListFromDb? darftRec,
  }) {
    if (isEncrypted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormulaSecretWeighingPage(
            selectFormula: formula,
            selScaleId: widget.selScaleId,
            totalFmaWgt: totalWgt,
            fmaUnit: fmaUnit,
            fromDraft: true,
            selectDarftInfo: darftRec,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DarftFmaPctWgtPage(
            selectFormula: formula,
            selScaleId: widget.selScaleId,
            totalFmaWgt: totalWgt,
            fmaUnit: fmaUnit,
            fromDarft: true,
            selectDarftInfo: darftRec,
          ),
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, FontWeight? valueFontWeight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: valueFontWeight ?? FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FormulaInfoDb? formula = widget.darftFma.fmaInfo;
    DarfFmaInfoListFromDb? rec = widget.darftFma.fmaRec;

    String idStr = formula?.header?.formulaId ?? '-';
    String nameStr = formula?.header?.formulaName ?? '-';
    String orderNoStr = rec?.header?.orderId ?? '-';
    bool isConfidential = formula?.header?.isEncrypted ?? false;
    String modeStr = formula?.header?.formulaMode ?? 'weight';
    int materialCount = formula?.header?.materialCount ?? formula?.details?.length ?? 0;
    String createTimeStr = rec?.header?.createdAt != null
        ? rec!.header!.createdAt.toString().split('.').first
        : '-';
    String notesStr = formula?.header?.remark ?? '-';
    String ingredientNotesStr = formula?.header?.remark ?? '-';

    List detailsList = formula?.details ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context).fRecordTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _onDeleteRecord,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Key-Value Pairs Section
                    _buildInfoRow('ID', idStr),
                    _buildInfoRow('Name', nameStr),
                    _buildInfoRow('NO.', orderNoStr),
                    _buildInfoRow(
                      'Confidential',
                      isConfidential ? 'Confidential' : 'Public',
                      valueColor: isConfidential ? Colors.red.shade600 : Colors.green.shade600,
                      valueFontWeight: FontWeight.bold,
                    ),
                    _buildInfoRow('Mode', modeStr),
                    _buildInfoRow('Quantity', materialCount.toString()),
                    _buildInfoRow('Create Time', createTimeStr),

                    const SizedBox(height: 8),
                    // Notes Row
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notesStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 16),

                    // Section Title: Name (Ingredients Grid)
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Ingredients Items Grid (2 Columns)
                    if (detailsList.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: detailsList.length,
                        itemBuilder: (context, index) {
                          var detail = detailsList[index];
                          int seq = detail.sequence ?? (index + 1);
                          String ingName = getRawName(detail.materialId ?? '');
                          if (ingName.isEmpty || ingName == '-') {
                            ingName = 'Diced mango';
                          }
                          String weightStr = modeStr == 'pct'
                              ? '${detail.materialPercentage ?? 5}%'
                              : '${detail.materialWeight ?? 5}g';

                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF004884),
                                    borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$seq',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ingName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    weightStr,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF004884),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'No ingredient details available',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Section Title: Ingredient Notes
                    const Text(
                      'Ingredient Notes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ingredientNotesStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Button: Continue Weighing
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _onContinueWeighing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004884),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue Weighing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
