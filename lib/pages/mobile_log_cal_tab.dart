import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/log_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/mobile_log_detail_page.dart';
import 'package:t_max/widget/mobile_log_filter_header.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';

class MobileLogCalTab extends StatefulWidget {
  final String contentType;
  final int currentIndex;
  final Function(int) onTabChanged;

  const MobileLogCalTab({
    super.key,
    required this.contentType,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  State<MobileLogCalTab> createState() => _MobileLogCalTabState();
}

class _MobileLogCalTabState extends State<MobileLogCalTab> {
  TextEditingController operatorCtl = TextEditingController();
  TextEditingController roleIdCtl = TextEditingController();

  final int _pageSize = 20;
  int _currentPage = 1;
  int _totalPages = 1;
  int totalCount = 0;

  Set<int> allSelectedRecIds = <int>{};
  bool _selectAll = false;
  List<CalLog> _allCalLogs = [];

  dynamic _eventbus1;
  dynamic _eventbus3;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void dispose() {
    operatorCtl.dispose();
    roleIdCtl.dispose();
    _eventbus1?.cancel();
    _eventbus3?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    CalLogTranslator.updateLanguageMap();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) getCurrentPageLogs();
    });
  }

  @override
  void initState() {
    super.initState();
    _eventbus1 = eventBus.on<EventRespGetCalLogList>().listen((event) {
      if (mounted) {
        try {
          CalLogFormDb calLogFormDb = calLogFormDbFromJson(event.obj);
          if (calLogFormDb.logs != null) {
            setState(() {
              _allCalLogs = calLogFormDb.logs!;
              totalCount = calLogFormDb.total ?? 0;
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

    _eventbus3 = eventBus.on<EventRespExportCalLog>().listen((event) {
      if (mounted) {
        String josnData = event.obj;
        try {
          if (josnData.isEmpty) {
            showTipInfo(
                (localizedStrings?.gTipExportFail ?? "Export failed"), context);
            return;
          }
          if (josnData.contains('ok')) {
            showTipInfo(
                (localizedStrings?.gTipExportSuccess ?? "Export succeeded"),
                context);
          }
        } catch (e) {
          return;
        }
      }
    });
  }

  void getCurrentPageLogs() {
    int? roleId = int.tryParse(roleIdCtl.text);
    String dateStart =
        startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : "";
    String dateEnd =
        endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : "";

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
    PublicFunctions.getCalLogList(reqGetLogToJson(reqGetLog));
  }

  void _toggleSelectAll(bool? value) {
    bool selectAll = value ?? false;
    setState(() {
      _selectAll = selectAll;
      if (selectAll) {
        allSelectedRecIds.addAll(_allCalLogs.map((e) => e.recId!));
      } else {
        allSelectedRecIds.clear();
      }
    });
  }

  void _export() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Output Folder',
    );

    if (selectedDirectory == null) {
      return;
    }

    String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    String outputFile = p.join(selectedDirectory, 'cal_log_$timestamp.csv');

    int? roleId = int.tryParse(roleIdCtl.text);
    String dateStart =
        startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : "";
    String dateEnd =
        endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : "";

    ReqExportLog exportLog = ReqExportLog(
      filePath: outputFile,
      fieldName: 'rec_id',
      direction: "desc",
      search: Search(
        searchOperator: operatorCtl.text.isNotEmpty ? operatorCtl.text : null,
        module: null,
        roleId: roleId,
        startTime: dateStart.isNotEmpty ? dateStart : null,
        endTime: dateEnd.isNotEmpty ? dateEnd : null,
      ),
      translation: CalLogTranslator.getLanguageMap(),
      headers: [
        'ID',
        (localizedStrings?.operator ?? "operator"),
        (localizedStrings?.userRole ?? "userRole"),
        (localizedStrings?.calibrationType ?? "calibrationType"),
        (localizedStrings?.operationResult ?? "operationResult"),
        (localizedStrings?.fCreatedAtCol ?? "fCreatedAtCol"),
      ],
    );

    String jsonStr = jsonEncode(exportLog.toJson());
    PublicFunctions.exportCalLog(jsonStr);
  }

  @override
  Widget build(BuildContext context) {
    CalLogTranslator.updateLanguageMap();

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
            itemCount: _allCalLogs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final log = _allCalLogs[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              MobileLogDetailPage(log: log, logType: 'cal')));
                },
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(
                      left: 4, right: 16, top: 12, bottom: 12),
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
                          Text(log.recId?.toString() ?? "",
                              style: const TextStyle(color: Colors.blue)),
                          const Spacer(),
                          Text(
                              log.createTime != null
                                  ? DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format(log.createTime!)
                                  : "",
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13)),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right,
                              color: Colors.black26),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 48.0, top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(localizedStrings?.operator ?? "Operator",
                                    style: const TextStyle(
                                        color: Colors.black45, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(log.operator ?? "",
                                    style:
                                        const TextStyle(color: Colors.black87)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    localizedStrings?.calibrationType ??
                                        "Calibration Type",
                                    style: const TextStyle(
                                        color: Colors.black45, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(getCalLogTrans(log.type ?? ""),
                                    style:
                                        const TextStyle(color: Colors.black87)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(localizedStrings?.gTipResult ?? "Result",
                                    style: const TextStyle(
                                        color: Colors.black45, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(getCalLogTrans(log.calResult ?? ""),
                                    style: const TextStyle(color: Colors.blue)),
                              ],
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
        // Export button
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _export,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A), // Teal color
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text("Export",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}
