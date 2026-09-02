import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/widget/mobile_log_bottom_sheets.dart';

class MobileLogFilterHeader extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final TextEditingController operatorCtl;
  final VoidCallback onSearch;
  final String currentRole;
  final Function(String) onRoleChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeChanged;

  const MobileLogFilterHeader({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.operatorCtl,
    required this.onSearch,
    required this.currentRole,
    required this.onRoleChanged,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
  });

  String _getDateRangeString() {
    if (startDate == null && endDate == null) return "";
    String s = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : "";
    String e = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : "";
    return "$s - $e";
  }

  String _getRoleLabel(String val) {
    if (val == "1") return localizedStrings?.superAdmin ?? "Super Admin";
    if (val == "2") return localizedStrings?.admin ?? "Admin";
    if (val == "3") return localizedStrings?.operator ?? "Operator";
    return "all";
  }

  @override
  Widget build(BuildContext context) {
    final tabNames = [
      localizedStrings?.calibrationRecords ?? "Calibration Records",
      localizedStrings?.systemRecords ?? "System Records",
      localizedStrings?.weighingRecords ?? "Weighing Records",
    ];

    String dateText = _getDateRangeString();

    return Column(
      children: [
        // Dropdown + Search Row
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => showLogTypeBottomSheet(context, currentIndex, (idx) {
                    onTabChanged(idx);
                  }),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.transparent, width: 2), // Remove red border, or keep it? The image doesn't have red border, it was drawn by user.
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 0.0), // No padding to match image alignment
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            tabNames[currentIndex],
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: operatorCtl,
                    onSubmitted: (_) => onSearch(), // Search triggers here
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: localizedStrings?.gTipPleaseInputKeyWord ?? "Please enter",
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Filter Row
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
          child: Row(
            children: [
              // Role Filter
              GestureDetector(
                onTap: () => showRoleBottomSheet(context, currentRole, (val) {
                  onRoleChanged(val);
                  onSearch(); // Search immediately after role change
                }),
                child: Row(
                  children: [
                    Text(localizedStrings?.userRole ?? "Role", style: const TextStyle(color: Colors.black54, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(_getRoleLabel(currentRole), style: const TextStyle(color: Colors.black87, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 20),
                  ],
                ),
              ),
              const Spacer(),
              // Date Filter
              GestureDetector(
                onTap: () => showDateRangeBottomSheet(context, startDate, endDate, (start, end) {
                  onDateRangeChanged(start, end);
                  onSearch(); // Search immediately after date change
                }),
                child: Row(
                  children: [
                    Text(dateText, style: const TextStyle(color: Colors.black87, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
