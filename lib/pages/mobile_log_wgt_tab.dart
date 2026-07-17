import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/log_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/mobile_log_detail_page.dart';
import 'package:t_max/widget/mobile_log_filter_header.dart';

class MobileLogWgtTab extends StatefulWidget {
  final String contentType;
  final int currentIndex;
  final Function(int) onTabChanged;

  const MobileLogWgtTab({
    super.key,
    required this.contentType,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  State<MobileLogWgtTab> createState() => _MobileLogWgtTabState();
}

class _MobileLogWgtTabState extends State<MobileLogWgtTab> {
  TextEditingController operatorCtl = TextEditingController();
  TextEditingController roleIdCtl = TextEditingController();

  final int _pageSize = 20;
  int _currentPage = 1;
  int _totalPages = 1;
  int totalCount = 0;

  Set<int> allSelectedRecIds = <int>{};
  bool _selectAll = false;
  List<ScaleWgtInfo> _allWgtLogs = [];

  dynamic _eventbus1;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void dispose() {
    operatorCtl.dispose();
    roleIdCtl.dispose();
    _eventbus1?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WgtLogTranslator.updateLanguageMap();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) getCurrentPageLogs();
    });
  }

  @override
  void initState() {
    super.initState();
    _eventbus1 = eventBus.on<EventRespGetWgtLogList>().listen((event) {
      if (mounted) {
        try {
          WgtLogFormDb wgtLogFormDb = wgtLogFormDbFromJson(event.obj);
          if (wgtLogFormDb.logs != null) {
            setState(() {
              _allWgtLogs = wgtLogFormDb.logs!;
              totalCount = wgtLogFormDb.total ?? 0;
              _totalPages = (totalCount / _pageSize).ceil();
              if (_totalPages == 0) _totalPages = 1;
              if (_currentPage > _totalPages) _currentPage = _totalPages;
            });
          }
        } catch (e) {
          // ignore
        }
      }
    });
  }

  void getCurrentPageLogs() {
    int? roleId = int.tryParse(roleIdCtl.text);
    String dateStart = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : "";
    String dateEnd = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : "";

    ReqGetLog reqGetLog = ReqGetLog(
      page: _currentPage,
      pageSize: _pageSize,
      fieldName: 'rec_id',
      direction: "desc",
      search: Search(
        searchOperator: operatorCtl.text,
        module: "",
        roleId: roleId,
        startTime: dateStart,
        endTime: dateEnd,
      ),
    );
    PublicFunctions.getWgtLogList(reqGetLogToJson(reqGetLog));
  }

  void _toggleSelectAll(bool? value) {
    bool selectAll = value ?? false;
    setState(() {
      _selectAll = selectAll;
      if (selectAll) {
        allSelectedRecIds.addAll(_allWgtLogs.map((e) => e.recId!));
      } else {
        allSelectedRecIds.clear();
      }
    });
  }

  void _export() {
    // Mobile export logic
  }

  void _clearLogs() {
    // Mobile clear logic
    if (allSelectedRecIds.isEmpty) return;
    showDeleteDialog(() {
      ReqDelLogs reqDelLogs = ReqDelLogs(recId: allSelectedRecIds.toList());
      PublicFunctions.deleteWgtLog(reqDelLogsToJson(reqDelLogs));
    }, localizedStrings?.tipDelLogs ?? "Confirm deletion?", context);
  }

  @override
  Widget build(BuildContext context) {
    WgtLogTranslator.updateLanguageMap();

    return Column(
      children: [
        MobileLogFilterHeader(
          currentIndex: widget.currentIndex,
          onTabChanged: widget.onTabChanged,
          operatorCtl: operatorCtl,
          onSearch: getCurrentPageLogs,
          currentRole: roleIdCtl.text,
          onRoleChanged: (val) {
            setState(() {
              roleIdCtl.text = val;
            });
          },
          startDate: startDate,
          endDate: endDate,
          onDateRangeChanged: (start, end) {
            setState(() {
              startDate = start;
              endDate = end;
            });
          },
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        // List Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 4.0, right: 16.0),
          child: Row(
            children: [
              Checkbox(
                value: _selectAll,
                onChanged: _toggleSelectAll,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        // List View
        Expanded(
          child: ListView.separated(
            itemCount: _allWgtLogs.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final log = _allWgtLogs[index];
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MobileLogDetailPage(log: log, logType: 'wgt')));
                },
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 4, right: 16, top: 12, bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: allSelectedRecIds.contains(log.recId),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  allSelectedRecIds.add(log.recId!);
                                } else {
                                  allSelectedRecIds.remove(log.recId!);
                                }
                              });
                            },
                          ),
                          Text(log.recId?.toString() ?? "", style: const TextStyle(color: Colors.blue)),
                          const Spacer(),
                          Text(log.createTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createTime!) : "", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.black26),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 48.0, top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(localizedStrings?.operator ?? "Operator", style: const TextStyle(color: Colors.black45, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(log.operator ?? "", style: const TextStyle(color: Colors.black87)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(localizedStrings?.module ?? "Module", style: const TextStyle(color: Colors.black45, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(getWgtLogTrans(log.module ?? ""), style: const TextStyle(color: Colors.black87)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Action buttons
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearLogs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350), // Red color
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text("Clear", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _export,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A), // Teal color
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text("Export", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
