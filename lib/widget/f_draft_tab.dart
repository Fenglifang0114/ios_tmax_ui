import 'package:flutter/material.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/widget/f_darft_table.dart';

class DraftFormulaTab extends StatefulWidget {
  final List<DarfFmaInfo> searchDarfFmaInfoList;

  final Function(DarfFmaInfo? darfFma) onDarfFmaSelected;
  final Function(List<DarfFmaInfo> selectedDarfFmas) onMultipleSelected;

  final Function() onDataChanged;

  const DraftFormulaTab({
    super.key,
    required this.searchDarfFmaInfoList,
    required this.onDarfFmaSelected,
    required this.onMultipleSelected,
    required this.onDataChanged,
  });

  @override
  State<DraftFormulaTab> createState() => _DraftFormulaTabState();
}

class _DraftFormulaTabState extends State<DraftFormulaTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 表格区域
        Expanded(
          child: DarftFmaTable(
            searchDarfFmaInfoList: widget.searchDarfFmaInfoList,
            onDarfFmaSelected: widget.onDarfFmaSelected,
            onMultipleSelected: widget.onMultipleSelected,
            onDataChanged: widget.onDataChanged,
          ),
        ),
      ],
    );
  }
}
