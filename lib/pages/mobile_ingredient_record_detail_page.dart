import 'package:flutter/material.dart';
import 'package:t_max/data/formula_wgt_process_data.dart';
import 'package:t_max/data/language.dart';

class MobileIngredientRecordDetailPage extends StatelessWidget {
  final List<FormulaWgtProcessData> processWgtList;
  final String fmaUnit;

  const MobileIngredientRecordDetailPage({
    super.key,
    required this.processWgtList,
    required this.fmaUnit,
  });

  Widget _buildFieldCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildRecordCard(BuildContext context, FormulaWgtProcessData item) {
    String rawName = item.no == 0
        ? (localizedStrings?.fFmaContainer ?? "Container")
        : (item.rawName ?? "");
    String rawIdStr = item.no == 0 ? "-" : (item.rawId ?? "-");
    String targetStr = item.no == 0 ? "-" : "${item.targetWgt}";
    String currentStr = "${item.currentWgt ?? 0.0}";
    String errorStr = item.no == 0 ? "-" : "±${item.errorWgt}";
    String currentErrorStr = item.no == 0 ? "-" : "${item.currentErrorWgt ?? 0.0}";

    Widget passWidget;
    if (item.isOK == "ok") {
      passWidget = const Icon(Icons.check, color: Color(0xFF00B074), size: 22);
    } else if (item.isOK == "high") {
      passWidget = const Icon(Icons.close, color: Colors.red, size: 22);
    } else {
      passWidget = const Text(
        'Incomplete',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF004884),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Row
          Row(
            children: [
              // Blue Badge Order Number
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF004884),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${item.no}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Ingredient Name
              Expanded(
                child: Text(
                  rawName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Pass Status Indicator
              passWidget,
            ],
          ),
          const SizedBox(height: 16),

          // Details Grid Row 1
          Row(
            children: [
              Expanded(
                child: _buildFieldCell('Ingredient ID', rawIdStr),
              ),
              Expanded(
                child: _buildFieldCell('Target Weight', targetStr),
              ),
              Expanded(
                child: _buildFieldCell('Current Weight', currentStr),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Details Grid Row 2
          Row(
            children: [
              Expanded(
                child: _buildFieldCell('Allowable Error', errorStr),
              ),
              Expanded(
                child: _buildFieldCell('Current Error', currentErrorStr),
              ),
              const Expanded(
                child: SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Record',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: processWgtList.isEmpty
            ? Center(
                child: Text(
                  'No records available',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: processWgtList.length,
                itemBuilder: (context, index) {
                  return _buildRecordCard(context, processWgtList[index]);
                },
              ),
      ),
    );
  }
}
