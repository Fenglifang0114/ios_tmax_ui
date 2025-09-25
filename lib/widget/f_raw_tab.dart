import 'package:flutter/material.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/widget/f_raw_table.dart';

class RawMaterialTab extends StatefulWidget {
  final List<RawDataInfo> rawDataList;
  final List<RawDataInfo> searchRawList;

  final Function(RawDataInfo? raw) onRawSelected;
  final Function(List<RawDataInfo> selectedRaws) onMultipleSelected;

  final Function() onDataChanged;

  const RawMaterialTab({
    super.key,
    required this.rawDataList,
    required this.searchRawList,
    required this.onRawSelected,
    required this.onMultipleSelected,
    required this.onDataChanged,
  });

  @override
  State<RawMaterialTab> createState() => _RawMaterialTabState();
}

class _RawMaterialTabState extends State<RawMaterialTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 表格区域
        Expanded(
          child: RawMaterialTable(
            searchRawList: widget.searchRawList,
            onRawSelected: widget.onRawSelected,
            onMultipleSelected: widget.onMultipleSelected,
            onDataChanged: widget.onDataChanged,
          ),
        ),
      ],
    );
  }
}
