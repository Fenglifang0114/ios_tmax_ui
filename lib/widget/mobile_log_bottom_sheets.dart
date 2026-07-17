import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/language.dart';

void showLogTypeBottomSheet(BuildContext context, int currentIndex, Function(int) onSelected) {
  final tabNames = [
    localizedStrings?.calibrationRecords ?? "Calibration Records",
    localizedStrings?.systemRecords ?? "System Records",
    localizedStrings?.weighingRecords ?? "Weighing Records",
  ];
  // Map index: 0=Cal, 1=Sys, 2=Wgt. Wait, the screenshot shows System, Calibration, Weighing.
  // In our tabs: 0=Cal, 1=Sys, 2=Wgt.
  // The screenshot shows: System, Calibration, Weighing.
  // Let's display them in the order: System(1), Calibration(0), Weighing(2).
  final displayOrder = [1, 0, 2];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select type", // Or localized?
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.cancel_outlined, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...displayOrder.map((index) {
              bool isSelected = currentIndex == index;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onSelected(index);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00539C) : const Color(0xFFF5F5F5), // Blue if selected, light gray if not
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tabNames[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    },
  );
}

void showRoleBottomSheet(BuildContext context, String currentRole, Function(String) onSelected) {
  final roles = [
    {"value": "", "label": "all"},
    {"value": "1", "label": localizedStrings?.superAdmin ?? "Super Admin"},
    {"value": "2", "label": localizedStrings?.admin ?? "Admin"},
    {"value": "3", "label": localizedStrings?.operator ?? "Operator"},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizedStrings?.userRole ?? "Role",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.cancel_outlined, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...roles.map((role) {
              bool isSelected = currentRole == role["value"];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onSelected(role["value"]!);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00539C) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role["label"]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    },
  );
}

class DateRangeBottomSheet extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final Function(DateTime?, DateTime?) onConfirm;

  const DateRangeBottomSheet({
    super.key,
    this.initialStart,
    this.initialEnd,
    required this.onConfirm,
  });

  @override
  State<DateRangeBottomSheet> createState() => _DateRangeBottomSheetState();
}

class _DateRangeBottomSheetState extends State<DateRangeBottomSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isSelectingStart = true;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart ?? DateTime.now();
    _endDate = widget.initialEnd ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select Date",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.cancel_outlined, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isSelectingStart = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isSelectingStart ? Colors.white : const Color(0xFFF5F5F5),
                      border: Border.all(
                        color: _isSelectingStart ? const Color(0xFF00539C) : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_startDate),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isSelectingStart ? const Color(0xFF00539C) : Colors.black87,
                        fontSize: 16,
                        fontWeight: _isSelectingStart ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isSelectingStart = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isSelectingStart ? Colors.white : const Color(0xFFF5F5F5),
                      border: Border.all(
                        color: !_isSelectingStart ? const Color(0xFF00539C) : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_endDate),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_isSelectingStart ? const Color(0xFF00539C) : Colors.black87,
                        fontSize: 16,
                        fontWeight: !_isSelectingStart ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _isSelectingStart ? _startDate : _endDate,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  if (_isSelectingStart) {
                    _startDate = newDate;
                  } else {
                    _endDate = newDate;
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Make sure start is before end if both selected
                    DateTime finalStart = _startDate;
                    DateTime finalEnd = _endDate;
                    if (finalStart.isAfter(finalEnd)) {
                      finalStart = _endDate;
                      finalEnd = _startDate;
                    }
                    Navigator.pop(context);
                    widget.onConfirm(finalStart, finalEnd);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A), // Teal color
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onConfirm(null, null); // Clear filters
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350), // Red color
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text("Clear Filter", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showDateRangeBottomSheet(BuildContext context, DateTime? initialStart, DateTime? initialEnd, Function(DateTime?, DateTime?) onConfirm) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return DateRangeBottomSheet(
        initialStart: initialStart,
        initialEnd: initialEnd,
        onConfirm: onConfirm,
      );
    },
  );
}
