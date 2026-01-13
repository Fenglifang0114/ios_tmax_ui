import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/log_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';

import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/f_open_file.dart';
import 'package:t_max/widget/log_show_details.dart';

class ScaleCalLogTabPage extends StatefulWidget {
  final String contentType;

  const ScaleCalLogTabPage({super.key, required this.contentType});

  @override
  State<ScaleCalLogTabPage> createState() => _ScaleCalLogTabPageState();
}

class _ScaleCalLogTabPageState extends State<ScaleCalLogTabPage> {
  TextEditingController operatorCtl = TextEditingController();
  TextEditingController roleIdCtl = TextEditingController();
  TextEditingController dateStartCtl = TextEditingController();
  TextEditingController dateEndCtl = TextEditingController();
  TextEditingController dateCtl = TextEditingController();

  late CalLogDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();

  final int _pageSize = 20;
  int _currentPage = 1;
  int _totalPages = 1;
  int totalCount = 0;

  Set<int> allSelectedRecIds = <int>{}; // 改为记录选中的recId
  String _sortField = ''; // 当前排序列名

  bool _sortAscending = true; // 排序方向
  bool _selectAll = false;

  List<CalLog> _allCalLogs = [];

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;

  @override
  dispose() {
    super.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _dataGridController.dispose();
    operatorCtl.dispose();
  }

  @override
  void didChangeDependencies() {
    CalLogTranslator.updateLanguageMap();
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        getCurrentPageLogs();
      }
    });

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    _loadCalLogData();

    _eventbus1 = eventBus.on<EventRespGetCalLogList>().listen((event) {
      if (mounted) {
        String josnData = event.obj;

        try {
          CalLogFormDb calLogFormDb = calLogFormDbFromJson(josnData);
          if (calLogFormDb.logs != null) {
            setState(() {
              _allCalLogs = calLogFormDb.logs!;
              totalCount = calLogFormDb.total ?? 0;
            });
          }
        } catch (e) {
          return;
        }
        _loadCalLogData();
      }
    });

    _eventbus2 = eventBus.on<EventRespDelCalLog>().listen((event) {
      if (mounted) {
        _currentPage = 1;
        _clearSelection();
        getCurrentPageLogs();
      }
    });
    _eventbus3 = eventBus.on<EventRespExportCalLog>().listen((event) {
      if (mounted) {
        String josnData = event.obj;
        try {
          if (josnData.isEmpty) {
            showTipInfo(localizedStrings.gTipExportFail, context);
            return;
          }
          if (josnData.contains('ok')) {
            String filepath = "";
            if (josnData.contains(',')) {
              List<String> parts = josnData.split(',');
              if (parts.length >= 2) {
                filepath = parts[1];
                showExportDialog(filepath, context);
              }
            }
          }
        } catch (e) {
          return;
        }
        getCurrentPageLogs();
      }
    });
  }

  void getCurrentPageLogs() {
    String sortFieldRename = _sortField;
    if (_sortField.isNotEmpty) {
      switch (_sortField) {
        case 'recId':
          sortFieldRename = 'rec_id';
          break;
        case 'roleId':
          sortFieldRename = 'role_id';
          break;
        case 'scaleName':
          sortFieldRename = 'scale_name';
          break;
        case 'modelName':
          sortFieldRename = 'model_name';
          break;
        case 'createTime':
          sortFieldRename = 'create_time';
          break;
      }
    }

    int? roleId = int.tryParse(roleIdCtl.text);
    String dateStart = "";
    if (dateStartCtl.text.isNotEmpty) {
      dateStart = DateFormat('yyyy-MM-dd').parse(dateStartCtl.text).toString();
    }
    String dateEnd = "";
    if (dateEndCtl.text.isNotEmpty) {
      dateEnd = DateFormat('yyyy-MM-dd').parse(dateEndCtl.text).toString();
    }

    ReqGetLog reqGetLog = ReqGetLog(
      page: _currentPage,
      pageSize: _pageSize,
      fieldName: sortFieldRename,
      direction: _sortAscending ? "asc" : "desc",
      search: Search(
        searchOperator: operatorCtl.text,
        module: "",
        roleId: roleId,
        startTime: dateStart,
        endTime: dateEnd,
      ),
    );
    String jsonStr = reqGetLogToJson(reqGetLog);
    PublicFunctions.getCalLogList(jsonStr);
  }

  void _loadCalLogData() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    _dataSource = CalLogDataSource(
      context: context,
      allCalLogData: _allCalLogs,
      onMultipleSelectionChanged: _updateMultipleSelection,
    );
    _calculateTotalPages();
  }

  void _calculateTotalPages() {
    _totalPages = (totalCount / _pageSize).ceil();
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
    }
    _dataSource.updateCurrentPage(_currentPage, _pageSize);
  }

  void _updateMultipleSelection(Set<int> selectedIndexes) {
    // 获取当前页的数据
    final pageStartIndex = 0;
    final currentPageData = _allCalLogs.sublist(
      pageStartIndex,
      pageStartIndex + _pageSize > _allCalLogs.length
          ? _allCalLogs.length
          : pageStartIndex + _pageSize,
    );

    // 根据选中的索引获取对应的recId
    final selectedRecIds = <int>{};
    for (var index in selectedIndexes) {
      if (index < currentPageData.length) {
        final syslog = currentPageData[index];
        selectedRecIds.add(syslog.recId!);
      }
    }

    // 更新全局选中的recId集合
    setState(() {
      for (var syslog in currentPageData) {
        allSelectedRecIds.remove(syslog.recId);
      }
      allSelectedRecIds.addAll(selectedRecIds);
      _selectAll = selectedIndexes.length == currentPageData.length &&
          currentPageData.isNotEmpty;
    });

    // 更新数据源的选中状态
    _dataSource.updateSelection(selectedIndexes);
  }

  void _toggleSelectAll(bool? value) {
    final selectAll = value ?? false;

    // 获取当前页数据
    final pageStartIndex =
        0; //(_currentPage - 1) * _pageSize; 一共只有一页的数据，因此都是从0开始的
    final currentPageData = _allCalLogs.sublist(
      pageStartIndex,
      pageStartIndex + _pageSize > _allCalLogs.length
          ? _allCalLogs.length
          : pageStartIndex + _pageSize,
    );

    if (selectAll) {
      // 选中当前页所有项目 - 记录recId
      allSelectedRecIds.clear();
      for (var syslog in currentPageData) {
        allSelectedRecIds.add(syslog.recId!);
      }
    } else {
      allSelectedRecIds.clear();
    }

    // 更新数据源的选中状态
    final currentPageSelectedIndexes = selectAll
        ? Set<int>.from(List.generate(currentPageData.length, (index) => index))
        : <int>{};

    _dataSource.updateSelection(currentPageSelectedIndexes);

    setState(() {
      _selectAll = selectAll;
    });
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _currentPage = page;
      _dataSource.updateSelection(<int>{});
      allSelectedRecIds.clear();
      // 只重置当前页的全选状态
      _selectAll = false;

      getCurrentPageLogs();
    }
  }

  void _goToFirstPage() => _goToPage(1);
  void _goToPreviousPage() => _goToPage(_currentPage - 1);
  void _goToNextPage() => _goToPage(_currentPage + 1);
  void _goToLastPage() => _goToPage(_totalPages);

  Widget _buildPaginationControls() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.first_page, size: 20),
                onPressed: _currentPage > 1 ? _goToFirstPage : null,
                color: _currentPage > 1
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              IconButton(
                icon: Icon(Icons.chevron_left, size: 20),
                onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                color: _currentPage > 1
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: textTheme.bodySmall,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 20),
                onPressed: _currentPage < _totalPages ? _goToNextPage : null,
                color: _currentPage < _totalPages
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              IconButton(
                icon: Icon(Icons.last_page, size: 20),
                onPressed: _currentPage < _totalPages ? _goToLastPage : null,
                color: _currentPage < _totalPages
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              SizedBox(width: 16),
              Text(
                localizedStrings.tipJumpPage,
                style: textTheme.bodySmall,
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 60,
                height: 32,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final page = int.tryParse(value);
                    if (page != null) {
                      _goToPage(page);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            width: regularPadding,
          ),
          Text(
            '${localizedStrings.tipPageTotal} $totalCount ${localizedStrings.tipPageItems}',
            style: textTheme.bodySmall,
          ),
          SizedBox(width: 16),
          // 显示选中的记录数量
          Text(
            '${localizedStrings.selected} ${allSelectedRecIds.length} ${localizedStrings.tipPageItems}',
            style: textTheme.bodySmall!.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectAll = false;
      allSelectedRecIds.clear();
    });
    _dataSource.updateSelection({});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    CalLogTranslator.updateLanguageMap();

    return Column(
      children: [
        showSearchBox(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(
                left: regularPadding, right: regularPadding),
            color: colorScheme.surface,
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              return SfDataGrid(
                controller: _dataGridController,
                source: _dataSource,
                headerRowHeight: 48.0,
                frozenColumnsCount: 2,
                // footerFrozenColumnsCount: 1,
                columnWidthMode: ColumnWidthMode.fill,
                gridLinesVisibility: GridLinesVisibility.horizontal,
                headerGridLinesVisibility: GridLinesVisibility.none,
                selectionMode: SelectionMode.none,
                columnResizeMode: ColumnResizeMode.onResize,
                allowSorting: false,
                rowHeight: 44,
                columns: _buildColumns(textTheme, colorScheme, width),
                onCellTap: (details) {
                  if (details.rowColumnIndex.rowIndex - 1 >= 0) {
                    if (_dataSource.allCalLogData.length <=
                        details.rowColumnIndex.rowIndex - 1) {
                      return;
                    }
                    final CalLog log = _dataSource
                        .allCalLogData[details.rowColumnIndex.rowIndex - 1];

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CalLogDetailDialog(log: log);
                        });
                  }
                },
              );
            }),
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  GridColumn getColumnWidget(double width, String columnName, String title,
      TextTheme textTheme, ColorScheme colorScheme) {
    return GridColumn(
      width: width,
      allowSorting: true,
      columnName: columnName,
      label: InkWell(
        onTap: () {
          setState(() {
            if (_sortField == columnName) {
              _sortAscending = !_sortAscending;
            } else {
              // 否则设置为新的排序字段，默认升序
              _sortField = columnName;
              _sortAscending = true;
            }
            //执行排序
            getCurrentPageLogs();
          });
        },
        child: Container(
          color: colorScheme.surfaceDim,
          padding: EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      textTheme.bodyMedium!.apply(color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (_sortField == columnName)
                Icon(
                    _sortAscending
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    size: 22),
            ],
          ),
        ),
      ),
    );
  }

  GridColumn getColumnWidgetNoSort(double width, String columnName,
      String title, TextTheme textTheme, ColorScheme colorScheme) {
    return GridColumn(
      width: width,
      allowSorting: false,
      columnName: columnName,
      label: Container(
        color: colorScheme.surfaceDim,
        padding: EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style:
                    textTheme.bodyMedium!.apply(color: colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<GridColumn> _buildColumns(
      TextTheme textTheme, ColorScheme colorScheme, double width) {
    double columnWidth = (width - 40 - 80 - 200 - 120 - 200) / 11;
    if (columnWidth < 200) {
      columnWidth = 200;
    }

    return [
      GridColumn(
        width: 40,
        allowSorting: false,
        columnName: 'select',
        label: Container(
          color: colorScheme.surfaceDim,
          alignment: Alignment.center,
          child: Checkbox(
            value: _selectAll,
            onChanged: _toggleSelectAll,
          ),
        ),
      ),
      getColumnWidget(80, 'recId', 'ID', textTheme, colorScheme),
      getColumnWidget(columnWidth, 'operator', localizedStrings.operator,
          textTheme, colorScheme),
      getColumnWidget(columnWidth, 'roleId', localizedStrings.userRole,
          textTheme, colorScheme),
      getColumnWidget(200, 'calType', localizedStrings.calibrationType,
          textTheme, colorScheme),
      getColumnWidget(columnWidth, 'calMode', localizedStrings.calibrationMode,
          textTheme, colorScheme),
      getColumnWidget(columnWidth, 'unit', localizedStrings.gTipWeightUnit,
          textTheme, colorScheme),
      getColumnWidget(columnWidth, 'calValue',
          localizedStrings.calibrationValue, textTheme, colorScheme),
      getColumnWidget(200, 'calBefore',
          localizedStrings.weightBeforeCalibration, textTheme, colorScheme),
      getColumnWidget(columnWidth, 'calAfter',
          localizedStrings.weightAfterCalibration, textTheme, colorScheme),
      getColumnWidget(columnWidth, 'calError',
          localizedStrings.calibrationError, textTheme, colorScheme),
      getColumnWidget(columnWidth, 'result', localizedStrings.gTipResult,
          textTheme, colorScheme),
      getColumnWidget(columnWidth, 'scaleName', localizedStrings.gDeviceName,
          textTheme, colorScheme),
      getColumnWidget(columnWidth, 'modelName', localizedStrings.gModelName,
          textTheme, colorScheme),
      getColumnWidget(
          columnWidth, 'sn', localizedStrings.gScaleSn, textTheme, colorScheme),
      getColumnWidget(200, 'createTime', localizedStrings.fCreatedAtCol,
          textTheme, colorScheme),
      // getColumnWidgetNoSort(120, 'operate', localizedStrings.fTipOperation,
      //     textTheme, colorScheme),
    ];
  }

  showSearchBox() {
    return Container(
      height: 68,
      color: Theme.of(context).colorScheme.surface,
      child: Row(children: [
        SizedBox(
          width: regularPadding,
        ),
        SizedBox(
            width: 180,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: operatorCtl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          operatorCtl.clear();
                        });
                      },
                    ),
                    hintText: localizedStrings.operator,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          // 设置提示文本样式
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // 这里可以添加搜索逻辑
                    });
                  }),
            )),
        SizedBox(
          width: 14,
        ),
        Container(
          width: 180,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            underline: SizedBox(),
            isExpanded: true,
            value: roleIdCtl.text == "" ? null : roleIdCtl.text,
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  localizedStrings.userRole,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                ),
              ),
              DropdownMenuItem<String>(
                value: "1",
                child: Text(
                  localizedStrings.superAdmin,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              DropdownMenuItem<String>(
                value: "2",
                child: Text(
                  localizedStrings.admin,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              DropdownMenuItem<String>(
                value: "3",
                child: Text(
                  localizedStrings.operator,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                roleIdCtl.text = value ?? "";
              });
            },
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
        SizedBox(
          width: 14,
        ),
        Container(
          width: 300,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: dateCtl,
            readOnly: true,
            decoration: InputDecoration(
              hintText: localizedStrings.gBtnSelectDate,
              hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 12,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  _selectDate(context);
                },
              ),
            ),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            onTap: () {
              _selectDate(context);
            },
          ),
        ),
        SizedBox(
          width: 14,
        ),
        Tooltip(
            message: localizedStrings.search, // 翻译
            child: IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  getCurrentPageLogs();
                });
              },
              iconSize: 24,
            )),
        SizedBox(
          width: 14,
        ),
        Tooltip(
            message: localizedStrings.fClearSearchConditionBtn, // 提示信息
            child: IconButton(
              icon: Icon(
                Icons.cleaning_services_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  operatorCtl.clear();
                  roleIdCtl.clear();
                  dateCtl.clear();
                  dateStartCtl.clear();
                  dateEndCtl.clear();
                  getCurrentPageLogs();
                });
              },
              iconSize: 24,
            )),
        Spacer(),
        SizedBox(
          width: 12,
        ),
        showTextButton(
            context,
            btnHeight,
            localizedStrings.gBtnExport,
            _allCalLogs.isEmpty
                ? null
                : () async {
                    final directory = Directory.current.path;
                    String? outputFile = (await FilePicker.platform.saveFile(
                      initialDirectory: directory,
                      type: FileType.custom,
                      dialogTitle: 'Output file:',
                      allowedExtensions: ["csv"],
                      fileName: 'cal_log.csv',
                    ));
                    if (outputFile == null) {
                      return;
                    }

                    if (!outputFile.contains(".csv")) {
                      outputFile = "$outputFile.csv";
                    }

                    ReqExportLog exportLog = ReqExportLog(
                      filePath: outputFile,
                      fieldName: _sortField,
                      direction: _sortAscending ? "asc" : "desc",
                      search: Search(
                        searchOperator: operatorCtl.text.isNotEmpty
                            ? operatorCtl.text
                            : null,
                        module: null,
                        roleId: roleIdCtl.text.isNotEmpty
                            ? int.tryParse(roleIdCtl.text)
                            : null,
                        startTime: dateStartCtl.text.isNotEmpty
                            ? dateStartCtl.text
                            : null,
                        endTime:
                            dateEndCtl.text.isNotEmpty ? dateEndCtl.text : null,
                      ),
                      translation: CalLogTranslator.getLanguageMap(),
                    );
                    String jsonStr = json.encode(exportLog.toJson());

                    PublicFunctions.exportCalLog(jsonStr);
                  },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.onPrimary),
        // SizedBox(
        //   width: 12,
        // ),
        // showTextButton(
        //     context,
        //     btnHeight,
        //     localizedStrings.fClearBtn,
        //     _allCalLogs.isEmpty
        //         ? null
        //         : () {
        //             _clearSelection();
        //             showDeleteDialog(() {
        //               PublicFunctions.deleteAllCalLog();
        //             }, localizedStrings.data_delete_confirm, context);
        //           },
        //     Theme.of(context).colorScheme.onPrimary,
        //     Theme.of(context).colorScheme.error,
        //     Theme.of(context).colorScheme.onPrimary),
        // SizedBox(
        //   width: regularPadding,
        // ),
        // showTextButton(
        //     context,
        //     btnHeight,
        //     localizedStrings.gBtnDelete,
        //     allSelectedRecIds.isEmpty
        //         ? null
        //         : () {
        //             List<int> selRecIds = allSelectedRecIds.toList();

        //             String jsonStr =
        //                 reqDelLogsToJson(ReqDelLogs(recId: selRecIds));

        //             showDeleteDialog(() {
        //               PublicFunctions.deleteCalLog(jsonStr);
        //             }, localizedStrings.fConfirmDelete, context);
        //           },
        //     Theme.of(context).colorScheme.onPrimary,
        //     Theme.of(context).colorScheme.error,
        //     Theme.of(context).colorScheme.onPrimary),
        SizedBox(
          width: 20,
        ),
      ]),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    //获取当前的语言
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600, maxHeight: 550),
              child: child,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateCtl.text =
            '${picked.start.toIso8601String().substring(0, 10)} - ${picked.end.toIso8601String().substring(0, 10)}';
        dateStartCtl.text = picked.start.toIso8601String().substring(0, 10);
        dateEndCtl.text = picked.end.toIso8601String().substring(0, 10);
      });
    }
  }
}

class CalLogDataSource extends DataGridSource {
  final BuildContext context;
  final List<CalLog> allCalLogData;
  final ValueChanged<Set<int>> onMultipleSelectionChanged;

  List<CalLog> currentPageData = [];
  List<DataGridRow> _dataGridRows = [];
  Set<int> _selectedRowIndexes = {};

  CalLogDataSource({
    required this.context,
    required this.allCalLogData,
    required this.onMultipleSelectionChanged,
  }) {
    updateCurrentPage(1, 20);
  }

  void updateData(List<CalLog> newData) {
    allCalLogData.clear();
    allCalLogData.addAll(newData);
    updateCurrentPage(1, 20);
  }

  void updateCurrentPage(int currentPage, int pageSize) {
    final startIndex = 0;
    final endIndex = startIndex + pageSize;

    currentPageData = allCalLogData.sublist(
      startIndex.clamp(0, allCalLogData.length),
      endIndex.clamp(0, allCalLogData.length),
    );

    buildDataGridRows();
    notifyListeners();
  }

  void updateSelection(Set<int> selectedIndexes) {
    _selectedRowIndexes = selectedIndexes;
    notifyListeners();
  }

  void buildDataGridRows() {
    _dataGridRows = currentPageData.map<DataGridRow>((syslog) {
      return DataGridRow(cells: [
        DataGridCell<bool>(columnName: 'select', value: false),
        DataGridCell<int>(
          columnName: 'recId',
          value: syslog.recId,
        ),
        DataGridCell<String>(
          columnName: 'operator',
          value: syslog.operator,
        ),
        DataGridCell<String>(
          columnName: 'roleId',
          value: getCalLogTrans(syslog.roleId.toString()),
        ),
        DataGridCell<String>(
          columnName: 'calType',
          value: syslog.type == null ? '' : getCalLogTrans(syslog.type!),
        ),
        DataGridCell<String>(
          columnName: 'calMode',
          value: syslog.mode,
        ),
        DataGridCell<String>(
          columnName: 'unit',
          value: syslog.unit,
        ),
        DataGridCell<String>(
          columnName: 'calValue',
          value: syslog.calValue,
        ),
        DataGridCell<String>(
          columnName: 'calBefore',
          value: syslog.before,
        ),
        DataGridCell<String>(
          columnName: 'calAfter',
          value: syslog.after,
        ),
        DataGridCell<String>(
          columnName: 'calError',
          value: syslog.calError,
        ),
        DataGridCell<String>(
          columnName: 'result',
          value: getCalLogTrans(syslog.calResult ?? ''),
        ),
        DataGridCell<String>(
          columnName: 'scaleName',
          value: syslog.scaleName,
        ),
        DataGridCell<String>(
          columnName: 'modelName',
          value: syslog.modelName,
        ),
        DataGridCell<String>(
          columnName: 'sn',
          value: syslog.sn,
        ),
        DataGridCell<String>(
          columnName: 'createTime',
          value: DateFormat('yyyy-MM-dd HH:mm:ss').format(syslog.createTime!),
        ),
        // DataGridCell<String>(
        //   columnName: 'operate',
        //   value: ('Delete'),
        // ),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final int rowIndex = _dataGridRows.indexOf(row);
    final CalLog syslog = currentPageData[rowIndex];
    final colorScheme = Theme.of(context).colorScheme;

    final bool isSelected = _selectedRowIndexes.contains(rowIndex);

    return DataGridRowAdapter(
      color:
          isSelected ? colorScheme.primary.withAlpha(20) : colorScheme.surface,
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          alignment: dataGridCell.columnName == 'select'
              ? Alignment.center
              : Alignment.centerLeft,
          child: _buildCellContent(dataGridCell, syslog, rowIndex, isSelected),
        );
      }).toList(),
    );
  }

  Widget _buildCellContent(
      DataGridCell dataGridCell, CalLog syslog, int rowIndex, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (dataGridCell.columnName) {
      case 'select':
        return Checkbox(
          value: isSelected,
          onChanged: (value) {
            final newSelectedIndexes = Set<int>.from(_selectedRowIndexes);
            if (value ?? false) {
              newSelectedIndexes.add(rowIndex);
            } else {
              newSelectedIndexes.remove(rowIndex);
            }
            onMultipleSelectionChanged(newSelectedIndexes);
            updateSelection(newSelectedIndexes);
          },
        );
      // case 'operate':
      //   return IconButton(
      //     icon: Icon(
      //       Icons.delete_outline_outlined,
      //       color: colorScheme.error,
      //     ),
      //     onPressed: () {
      //       // 处理删除操作 - 现在可以直接使用syslog.recId

      //       String jsonStr =
      //           reqDelLogsToJson(ReqDelLogs(recId: [syslog.recId!]));
      //       showDeleteDialog(() {
      //         PublicFunctions.deleteCalLog(jsonStr);
      //       }, localizedStrings.fConfirmDelete, context);
      //     },
      //   );

      default:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            dataGridCell.value.toString(),
            style: textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        );
    }
  }

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    return null;
  }
}
