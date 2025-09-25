import 'package:flutter/material.dart';
import 'package:t_max/data/formula_from_db_data.dart';

import 'f_fma_table.dart';

class FormulaTab extends StatefulWidget {
  final List<FormulaInfoDb> searchFmaList;

  final Function(FormulaInfoDb? formula) onFormulaSelected;
  final Function(List<FormulaInfoDb> selectedFormulas) onMultipleSelected;

  final Function() onDataChanged;

  const FormulaTab({
    super.key,
    required this.searchFmaList,
    required this.onFormulaSelected,
    required this.onMultipleSelected,
    required this.onDataChanged,
  });

  @override
  State<FormulaTab> createState() => _FormulaTabState();
}

class _FormulaTabState extends State<FormulaTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 表格区域
        Expanded(
          child: FormulaTable(
            searchFmaList: widget.searchFmaList,
            onFormulaSelected: widget.onFormulaSelected,
            onMultipleSelected: widget.onMultipleSelected,
            onDataChanged: widget.onDataChanged,
          ),
        ),
      ],
    );
  }
}
