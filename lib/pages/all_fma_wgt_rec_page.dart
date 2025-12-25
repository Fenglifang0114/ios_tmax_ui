import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/plu_field_status_data.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/dialog/fma_rpt_print_setting.dart';
import 'package:t_max/dialog/fma_server_setting.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/fma_report_print.dart';
import 'package:t_max/widget/f_open_file.dart';

// 定义 EncryptedValue 枚举
enum EncryptedValue {
  confidential,
  public,
}

// 扩展 EncryptedValue 枚举以添加翻译方法
extension EncryptedValueExtension on EncryptedValue {
  String getTranslation(BuildContext context) {
    switch (this) {
      case EncryptedValue.confidential:
        return localizedStrings.fConfidential;
      case EncryptedValue.public:
        return localizedStrings.fPublic;
    }
  }
}

// 定义排序字段枚举
enum SortField {
  orderNo,
  fmaId,
  fmaName,
  totalWeight,
  actualWeight,
  createdAt,
  fmaBarcode,
}

// 定义排序方向枚举
enum SortDirection {
  ascending,
  descending,
  none,
}

class AllFmaWgtRecPage extends StatefulWidget {
  const AllFmaWgtRecPage({super.key});

  @override
  State<AllFmaWgtRecPage> createState() => AllFmaWgtRecPageState();
}

class AllFmaWgtRecPageState extends State<AllFmaWgtRecPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool selectAll = false;
  int? clickedRow;
  final TextEditingController encryptedCtl = TextEditingController();
  final TextEditingController formulaTypeCtl = TextEditingController();
  final TextEditingController rawTypeCtl = TextEditingController();
  FormulaInfoDb? selectedFormula;
  Detail selectedDetail = Detail();

  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();

  final List<bool> _isExpanded = [];
  bool _isAllSelected = false;
  late List<bool> _selectedRows;

  // 分页相关状态
  int _currentPage = 1;
  int _totalPages = 1;
  final int _rowsPerPage = 20; // 每页显示20行

  // 排序相关状态
  SortField? _sortField;
  SortDirection _sortDirection = SortDirection.none;

  // 用于分页和排序的数据列表
  List<FmaRecFromDb> _filteredAndSortedList = [];
  UploadServerInfo uploadServerInfo = UploadServerInfo();
  List<FmaRecFromDb> newFmaRecDbList = [];

  dynamic _eventBus1;
  dynamic _eventbus2;

  void initRecsList() {
    // 初始化展开状态和选中状态列表
    for (var i = 0; i < newFmaRecDbList.length; i++) {
      _isExpanded.add(false);
    }
    _selectedRows = List.generate(newFmaRecDbList.length, (index) => false);

    // 初始化分页和排序
    _updateFilteredAndSortedList();
  }

  @override
  void initState() {
    super.initState();
    PublicFunctions.getFormulaRecList();
    initRecsList();
    _tabController = TabController(length: 2, vsync: this);
    PublicFunctions.getUploadServerConfig();
    _eventBus1 = eventBus.on<EventRespUploadServerGet>().listen((event) {
      if (mounted) {
        String jsonStr = event.obj;
        if (jsonStr != "" && jsonStr != "fail") {
          try {
            uploadServerInfo = UploadServerInfo.fromJson(jsonDecode(jsonStr));
          } catch (e) {
            uploadServerInfo = UploadServerInfo();
          }
        }
      }
    });
    _eventbus2 = eventBus.on<EventRespFormulaRecList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            List<FmaRecFromDb> tempFmaRecList = fmaRecFromDbFromJson(dataStr);
            newFmaRecDbList.addAll(tempFmaRecList);
            initRecsList();
          });
        } else {
          newFmaRecDbList = [];
        }
      }
    });
  }

  Map<String, FieldNameStatus> getrptFields() {
    Map<String, FieldNameStatus> rptFields = {
      "formulaId": FieldNameStatus(
          localizedStrings.fFmaIdLabel, rptPrintSetting.formulaId ?? true),
      "formulaName": FieldNameStatus(
          localizedStrings.fFmaNameLabel, rptPrintSetting.formulaName ?? true),
      "formulaBarcode": FieldNameStatus(
          localizedStrings.fFmaBarcode, rptPrintSetting.formulaBarcode ?? true),
      "orderId": FieldNameStatus("NO.", rptPrintSetting.orderId ?? true),
      "saveTime": FieldNameStatus(
          localizedStrings.fCreatedAtCol, rptPrintSetting.saveTime ?? true),
      "operator": FieldNameStatus(
          localizedStrings.operator, rptPrintSetting.operator ?? true),
      "rawId": FieldNameStatus(
          localizedStrings.fMaterialIdCol, rptPrintSetting.rawId ?? true),
      "rawName": FieldNameStatus(
          localizedStrings.fMaterialNameCol, rptPrintSetting.rawName ?? true),
      "pass": FieldNameStatus(
          localizedStrings.fQualificationStatus, rptPrintSetting.pass ?? true),
      "fmaTotalWgt": FieldNameStatus(localizedStrings.fFormulaTotalWeight,
          rptPrintSetting.fmaTotalWgt ?? true),
      "actualTotalWgt": FieldNameStatus(localizedStrings.fActualTotalWeight,
          rptPrintSetting.actualTotalWgt ?? true),
      "deviceName": FieldNameStatus(
          localizedStrings.gDeviceName, rptPrintSetting.deviceName ?? true),
      "rawActualErr": FieldNameStatus(
          localizedStrings.fActualError, rptPrintSetting.rawActualErr ?? true),
      "rawActualWgt": FieldNameStatus(localizedStrings.fActualSingleWeight,
          rptPrintSetting.rawActualWgt ?? true),
    };

    return rptFields;
  }

  // 更新过滤和排序后的列表
  void _updateFilteredAndSortedList() {
    // 复制原始列表
    _filteredAndSortedList = List.from(newFmaRecDbList);

    // 应用排序
    if (_sortField != null && _sortDirection != SortDirection.none) {
      _filteredAndSortedList.sort((a, b) {
        int comparisonResult = 0;

        switch (_sortField!) {
          case SortField.orderNo:
            comparisonResult =
                (a.header?.recordId ?? "").compareTo(b.header?.recordId ?? "");
            break;
          case SortField.fmaId:
            comparisonResult = (a.header?.formulaId ?? "")
                .compareTo(b.header?.formulaId ?? "");
            break;
          case SortField.fmaName:
            comparisonResult = (a.header?.formulaName ?? "")
                .compareTo(b.header?.formulaName ?? "");
            break;
          case SortField.fmaBarcode:
            comparisonResult = (a.header?.formulaBarcode ?? "")
                .compareTo(b.header?.formulaBarcode ?? "");
            break;
          case SortField.totalWeight:
            comparisonResult = (a.header?.actualFmaTotalWgt ?? 0)
                .compareTo(b.header?.actualFmaTotalWgt ?? 0);
            break;
          case SortField.actualWeight:
            comparisonResult = (a.header?.actualTotalWeight ?? 0)
                .compareTo(b.header?.actualTotalWeight ?? 0);
            break;
          case SortField.createdAt:
            comparisonResult = (a.header?.recordSaveTime ?? DateTime.now())
                .compareTo(b.header?.recordSaveTime ?? DateTime.now());
            break;
        }

        // 如果是降序，反转比较结果
        return _sortDirection == SortDirection.descending
            ? -comparisonResult
            : comparisonResult;
      });
    }

    // 计算总页数
    _totalPages = (_filteredAndSortedList.length / _rowsPerPage).ceil();
    if (_totalPages < 1) _totalPages = 1;

    // 确保当前页在有效范围内
    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
    }

    // 重置选中状态
    _resetSelectionState();
  }

  // 重置选中状态
  void _resetSelectionState() {
    setState(() {
      _isAllSelected = false;
      _selectedRows =
          List.generate(_filteredAndSortedList.length, (index) => false);
    });
  }

  // 切换排序
  void _toggleSort(SortField field) {
    setState(() {
      // 如果点击的是当前排序字段，则切换方向
      if (_sortField == field) {
        switch (_sortDirection) {
          case SortDirection.ascending:
            _sortDirection = SortDirection.descending;
            break;
          case SortDirection.descending:
            _sortDirection = SortDirection.none;
            _sortField = null;
            break;
          case SortDirection.none:
            _sortDirection = SortDirection.ascending;
            break;
        }
      } else {
        // 如果点击的是新的字段，则设置为升序
        _sortField = field;
        _sortDirection = SortDirection.ascending;
      }

      // 重置到第一页
      _currentPage = 1;

      // 更新列表
      _updateFilteredAndSortedList();
    });
  }

  // 获取当前页的数据
  List<FmaRecFromDb> _getCurrentPageData() {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;

    if (startIndex >= _filteredAndSortedList.length) {
      return [];
    }

    return _filteredAndSortedList.sublist(
      startIndex,
      endIndex > _filteredAndSortedList.length
          ? _filteredAndSortedList.length
          : endIndex,
    );
  }

  // 切换到指定页
  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;

    setState(() {
      _currentPage = page;
      // 重置展开状态
      for (var i = 0; i < _isExpanded.length; i++) {
        _isExpanded[i] = false;
      }
    });
  }

  // void _toggleAllSelection() {
  //   setState(() {
  //     _isAllSelected = !_isAllSelected;
  //     final currentData = _getCurrentPageData();
  //     final startIndex = (_currentPage - 1) * _rowsPerPage;

  //     for (int i = 0; i < currentData.length; i++) {
  //       _selectedRows[startIndex + i] = _isAllSelected;
  //     }
  //   });
  // }

  void _toggleAllSelection() {
    setState(() {
      _isAllSelected = !_isAllSelected;

      // 选中或取消选中所有行，而不仅仅是当前页面
      for (int i = 0; i < _selectedRows.length; i++) {
        _selectedRows[i] = _isAllSelected;
      }
    });
  }

  void _toggleRowSelection(int index) {
    setState(() {
      final startIndex = (_currentPage - 1) * _rowsPerPage;
      // 使用原始索引而不是页面索引
      final originalIndex = startIndex + index;
      _selectedRows[originalIndex] = !_selectedRows[originalIndex];

      // 检查是否所有行都被选中
      _isAllSelected = _selectedRows.every((selected) => selected);
    });
  }

  // void _toggleRowSelection(int index) {
  //   setState(() {
  //     final startIndex = (_currentPage - 1) * _rowsPerPage;
  //     _selectedRows[startIndex + index] = !_selectedRows[startIndex + index];

  //     // 检查是否所有行都被选中
  //     final currentData = _getCurrentPageData();
  //     _isAllSelected = currentData.asMap().entries.every(
  //           (entry) => _selectedRows[startIndex + entry.key] == true,
  //         );
  //   });
  // }

  Widget titleText(String data) {
    return Text(
      data,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Widget subTitleText(String data) {
    return Text(
      data,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollController.dispose();
    scrollController1.dispose();
    _eventBus1?.cancel();
    _eventbus2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Theme.of(context).colorScheme.surfaceDim,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          double availableHeight = constraints.maxHeight;
          double otherChildrenHeight = 54 + 1 + 70 + 14 + 65 + 50; // 增加分页控件高度
          double formulaTableHeight = availableHeight - otherChildrenHeight;

          return Column(
            children: [
              showTitleAndReturn(),
              Divider(
                color: Theme.of(context).colorScheme.outline,
                thickness: 1,
                height: 1,
              ),
              showFormulaSearch(),
              showFormulaTable(formulaTableHeight),
              _buildPaginationControls(),
              Container(
                height: 14,
                color: Theme.of(context).colorScheme.surface,
              ),
            ],
          );
        }),
      ),
    ));
  }

  // 构建分页控制器
  Widget _buildPaginationControls() {
    return Container(
      height: 50,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage == 1 ? null : () => _goToPage(1),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
              ),
              Text(
                '$_currentPage / $_totalPages',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages
                    ? () => _goToPage(_currentPage + 1)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage == _totalPages
                    ? null
                    : () => _goToPage(_totalPages),
              ),
            ],
          ),
          Text(
            '${'            Current'} ${_getCurrentPageData().length}${'  Item'}   ${'   Total'} ${_filteredAndSortedList.length} ${'Item'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // 构建可点击的表头，支持排序
  Widget _buildSortableHeader(String title, SortField field) {
    Widget sortIcon;

    if (_sortField == field) {
      switch (_sortDirection) {
        case SortDirection.ascending:
          sortIcon = const Icon(Icons.arrow_upward, size: 16);
          break;
        case SortDirection.descending:
          sortIcon = const Icon(Icons.arrow_downward, size: 16);
          break;
        case SortDirection.none:
          sortIcon = const SizedBox.shrink();
          break;
      }
    } else {
      sortIcon = const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => _toggleSort(field),
      child: Row(
        children: [
          Expanded(child: titleText(title)),
          sortIcon,
        ],
      ),
    );
  }

  showFormulaTable(double formulaTableHeight) {
    final currentData = _getCurrentPageData();

    return Expanded(
      flex: 7,
      child: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          child: Container(
            width: 3000,
            height: formulaTableHeight,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                border: Border.all(
                    width: 0.2,
                    color: Theme.of(context).colorScheme.onSurface)),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: scrollController1,
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    // 表格头
                    Container(
                      width: 3000,
                      height: 40,
                      color: Theme.of(context).colorScheme.surfaceDim,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isAllSelected,
                            onChanged: (bool? value) {
                              _toggleAllSelection();
                            },
                          ),
                          Expanded(
                            child: _buildSortableHeader(
                              localizedStrings.fOrderNo ?? "Order No",
                              SortField.orderNo,
                            ),
                          ),
                          Expanded(
                            child: _buildSortableHeader(
                              localizedStrings.fFmaIdLabel,
                              SortField.fmaId,
                            ),
                          ),
                          Expanded(
                            child: _buildSortableHeader(
                              localizedStrings.fFmaNameLabel,
                              SortField.fmaName,
                            ),
                          ),
                          Expanded(
                            child: _buildSortableHeader(
                              localizedStrings.fFmaBarcode,
                              SortField.fmaBarcode,
                            ),
                          ),
                          Expanded(
                              child:
                                  titleText(localizedStrings.fMaterialNameCol)),
                          Expanded(
                              child:
                                  titleText(localizedStrings.fMaterialIdCol)),
                          Expanded(
                              child: titleText(localizedStrings.fFmaModeCol)),
                          Expanded(
                              child: titleText(localizedStrings.fConfidential)),
                          Expanded(
                            child: _buildSortableHeader(
                              localizedStrings.fFormulaTotalWeight,
                              SortField.totalWeight,
                            ),
                          ),
                          Expanded(
                            child: _buildSortableHeader(
                              localizedStrings.fActualTotalWeight,
                              SortField.actualWeight,
                            ),
                          ),
                          Expanded(
                              child: titleText(
                                  localizedStrings.fMaterialSingleWeight)),
                          Expanded(
                              child: titleText(
                                  localizedStrings.fActualSingleWeight)),
                          Expanded(
                              child:
                                  titleText(localizedStrings.fAllowableError)),
                          Expanded(
                              child: titleText(localizedStrings.fActualError)),
                          Expanded(
                              child: titleText(
                                  localizedStrings.fQualificationStatus)),
                          Expanded(
                              child: titleText(localizedStrings.gDeviceName)),
                          Expanded(
                            child: _buildSortableHeader(
                              localizedStrings.fCreatedAtCol,
                              SortField.createdAt,
                            ),
                          ),
                          Expanded(child: titleText(localizedStrings.operator)),
                          const SizedBox(width: 100, child: Text('')),
                        ],
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),
                    SizedBox(
                      height: formulaTableHeight,
                      child: ListView.builder(
                        itemCount: currentData.length,
                        itemBuilder: (context, index) {
                          final rowData = currentData[index];
                          final originalIndex =
                              _filteredAndSortedList.indexOf(rowData);

                          // 确保展开状态列表有足够的长度
                          while (_isExpanded.length <= originalIndex) {
                            _isExpanded.add(false);
                          }

                          return Column(
                            children: [
                              // 主行
                              Container(
                                height: 40,
                                color: const Color.fromARGB(255, 247, 247, 247),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _selectedRows[originalIndex],
                                      onChanged: (bool? value) {
                                        _toggleRowSelection(index);
                                      },
                                    ),
                                    Expanded(
                                        child: titleText(
                                            rowData.header?.recordId ?? "")),
                                    Expanded(
                                        child: titleText(
                                            rowData.header!.formulaId ?? "")),
                                    Expanded(
                                        child: titleText(
                                            rowData.header!.formulaName ?? "")),
                                    Expanded(
                                        child: titleText(
                                            rowData.header!.formulaBarcode ??
                                                "")),
                                    Expanded(child: Text('')),
                                    Expanded(child: Text('')),
                                    Expanded(
                                        child: titleText(
                                            rowData.header!.formulaMode! ==
                                                    'wgt'
                                                ? localizedStrings.fWeightMode
                                                : localizedStrings.fPctMode)),
                                    Expanded(
                                        child: Text(
                                      " ${rowData.header!.isEncrypted.toString() == "true" ? localizedStrings.fConfidential : localizedStrings.fPublic}",
                                      style: TextStyle(
                                          color: rowData.header!.isEncrypted
                                                      .toString() ==
                                                  "false"
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onTertiaryFixedVariant
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .error),
                                    )),
                                    Expanded(
                                        child: titleText(
                                            "${rowData.header!.actualFmaTotalWgt!.toStringAsFixed(3)} ${rowData.header!.totalWeightUnit}")),
                                    Expanded(
                                        child: titleText(
                                            "${rowData.header!.actualTotalWeight!.toStringAsFixed(3)} ${rowData.header!.totalWeightUnit}")),
                                    Expanded(child: Text('')),
                                    Expanded(child: Text('')),
                                    Expanded(child: Text('')),
                                    Expanded(child: Text('')),
                                    Expanded(
                                      child: Text(
                                        rowData.header!.isQualified
                                                    .toString() ==
                                                "yes"
                                            ? localizedStrings.fQualified
                                            : localizedStrings.fUnqualified,
                                        style: TextStyle(
                                            color: rowData.header!.isQualified
                                                        .toString() ==
                                                    "yes"
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onTertiaryFixedVariant
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                      ),
                                    ),
                                    Expanded(child: Text("")),
                                    Expanded(
                                        child: titleText(rowData
                                                    .header!.recordSaveTime !=
                                                null
                                            ? DateFormat('yyyy-MM-dd HH:mm:ss')
                                                .format(rowData
                                                    .header!.recordSaveTime!)
                                            : '')),
                                    Expanded(
                                        child: titleText(rowData
                                                    .header!.headerOperator !=
                                                null
                                            ? rowData.header!.headerOperator!
                                            : '')),
                                    SizedBox(
                                        width: 100,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                  icon: Icon(
                                                    Icons.print,
                                                    color: rowData.header!
                                                            .isEncrypted!
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .outline
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                  ),
                                                  onPressed: () {
                                                    if (rowData
                                                        .header!.isEncrypted!) {
                                                      return;
                                                    }
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          FormulaReportPrint(
                                                              fmaData: rowData),
                                                    );
                                                  }),
                                              IconButton(
                                                icon: Icon(
                                                  _isExpanded[originalIndex]
                                                      ? Icons.expand_less
                                                      : Icons.expand_more,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _isExpanded[originalIndex] =
                                                        !_isExpanded[
                                                            originalIndex];
                                                  });
                                                },
                                              ),
                                            ])),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                                thickness: 1,
                                height: 1,
                              ),

                              // 展开的明细行
                              Visibility(
                                visible: _isExpanded[originalIndex],
                                child: Column(
                                  children: rowData.details
                                          ?.asMap()
                                          .entries
                                          .map<Widget>((entry) {
                                        final detailIndex = entry.key;
                                        final detail = entry.value;
                                        return Column(
                                          children: [
                                            Container(
                                              height: 40,
                                              color: Colors.white,
                                              child: SizedBox(
                                                height: 38,
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 48), // 对齐复选框位置
                                                    const Expanded(
                                                        child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(
                                                      child: subTitleText(
                                                        detail.sequence == 0
                                                            ? localizedStrings
                                                                .fFmaContainer
                                                            : detail.materialName ??
                                                                "",
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: subTitleText(
                                                          detail.materialId ??
                                                              ''),
                                                    ),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(
                                                        child: subTitleText(detail
                                                                        .sequence ==
                                                                    0 ||
                                                                rowData.header!
                                                                        .isEncrypted
                                                                        .toString() ==
                                                                    "true"
                                                            ? '-'
                                                            : "${detail.targetWgt.toString()} ${rowData.header!.totalWeightUnit!}")),

                                                    Expanded(
                                                        child: subTitleText((detail
                                                                        .sequence ==
                                                                    0 ||
                                                                (rowData.header!
                                                                        .isEncrypted
                                                                        .toString() !=
                                                                    "true"))
                                                            ? '${detail.actualWeight.toString()} ${rowData.header!.totalWeightUnit!}'
                                                            : "-")),
                                                    Expanded(
                                                      child: subTitleText(detail
                                                                      .sequence ==
                                                                  0 ||
                                                              rowData.header!
                                                                      .isEncrypted
                                                                      .toString() ==
                                                                  "true"
                                                          ? '-'
                                                          : rowData.header!
                                                                      .formulaMode! ==
                                                                  "pct"
                                                              ? "${double.parse((detail.allowableError! * rowData.header!.actualFmaTotalWgt! / 100).toStringAsFixed(3)).toString()} ${rowData.header!.totalWeightUnit!}"
                                                              : "${detail.allowableError!.toString()} ${rowData.header!.totalWeightUnit!}"),
                                                    ),
                                                    Expanded(
                                                        child: subTitleText(detail
                                                                        .sequence ==
                                                                    0 ||
                                                                rowData.header!
                                                                        .isEncrypted
                                                                        .toString() ==
                                                                    "true"
                                                            ? '-'
                                                            : "${detail.actualErrorWgt.toString()} ${rowData.header!.totalWeightUnit!}")),
                                                    Expanded(
                                                        child: Text(
                                                            detail.sequence ==
                                                                        0 ||
                                                                    rowData
                                                                            .header!
                                                                            .isEncrypted
                                                                            .toString() ==
                                                                        "true"
                                                                ? '-'
                                                                : detail.isQualified
                                                                            .toString() ==
                                                                        "ok"
                                                                    ? localizedStrings
                                                                        .fQualified
                                                                    : localizedStrings
                                                                        .fUnqualified,
                                                            style: TextStyle(
                                                                color: detail
                                                                            .isQualified
                                                                            .toString() ==
                                                                        "ok"
                                                                    ? Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onTertiaryFixedVariant
                                                                    : Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .error))),
                                                    Expanded(
                                                        child: Text(
                                                            detail.scaleName ??
                                                                '-')),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(''),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (detailIndex <
                                                (rowData.details?.length ?? 0) -
                                                    1)
                                              Divider(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outlineVariant,
                                                thickness: 1,
                                                height: 1,
                                              )
                                          ],
                                        );
                                      }).toList() ??
                                      [],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  showTitleAndReturn() {
    return Container(
      height: 54,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.keyboard_double_arrow_left_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  localizedStrings.fRecordTitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20)
        ],
      ),
    );
  }

  bool getExportStatus() {
    return _selectedRows.any((element) => element);
  }

  Future<void> exportSelectedDataToCSV() async {
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'formulaWgt.csv',
    ));
    if (outputFile != null) {
      if (!outputFile.contains(".csv")) {
        outputFile = "$outputFile.csv";
      }
      exportWgtRecords(outputFile);
    }
  }

  Future<void> exportWgtRecords(String path) async {
    try {
      final header = [
        'No.',
        localizedStrings.fFmaIdLabel,
        localizedStrings.fFmaNameLabel,
        localizedStrings.fFmaBarcode,
        localizedStrings.fMaterialNameCol,
        localizedStrings.fMaterialIdCol,
        localizedStrings.fFmaModeCol,
        localizedStrings.fConfidential,
        localizedStrings.fFormulaTotalWeight,
        localizedStrings.fActualTotalWeight,
        localizedStrings.fMaterialSingleWeight,
        localizedStrings.fActualSingleWeight,
        localizedStrings.fAllowableError,
        localizedStrings.fActualError,
        localizedStrings.fQualificationStatus,
        localizedStrings.fCreatedAtCol,
        localizedStrings.operator,
      ];

      List<List<dynamic>> csvData = [header];

      // 遍历所有选中的行
      for (int i = 0; i < _selectedRows.length; i++) {
        if (_selectedRows[i] && i < _filteredAndSortedList.length) {
          final rowData = _filteredAndSortedList[i];
          final headerData = rowData.header;

          final headerRow = [
            headerData?.recordId ?? "",
            headerData?.formulaId ?? "",
            headerData?.formulaName ?? "",
            headerData?.formulaBarcode ?? "",
            "",
            "",
            headerData?.formulaMode == 'wgt'
                ? localizedStrings.fWeightMode
                : localizedStrings.fPctMode,
            headerData?.isEncrypted.toString() == "true"
                ? localizedStrings.fConfidential
                : localizedStrings.fPublic,
            "${headerData?.actualFmaTotalWgt} ${headerData?.totalWeightUnit}",
            "${(headerData?.actualTotalWeight)!.toStringAsFixed(3)} ${headerData?.totalWeightUnit}",
            "",
            "",
            "",
            "",
            headerData?.isQualified.toString() == "yes" ? "Pass" : "Fail",
            headerData?.recordSaveTime != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format(headerData!.recordSaveTime!)
                : '',
            headerData?.headerOperator ?? ''
          ];
          csvData.add(headerRow);

          if (rowData.details != null) {
            for (final detail in rowData.details!) {
              final detailRow = [
                "",
                "",
                "",
                "",
                detail.sequence == 0
                    ? localizedStrings.fFmaContainer
                    : detail.materialName ?? "",
                detail.materialId ?? "",
                "",
                "",
                "",
                "",
                detail.sequence == 0 ||
                        headerData!.isEncrypted.toString() == "true"
                    ? '-'
                    : "${detail.targetWgt.toString()} ${headerData.totalWeightUnit!}",
                (detail.sequence == 0 ||
                        headerData!.isEncrypted.toString() != "true")
                    ? '${detail.actualWeight.toString()} ${headerData!.totalWeightUnit!}'
                    : "-",
                detail.sequence == 0 ||
                        headerData.isEncrypted.toString() == "true"
                    ? '-'
                    : headerData.formulaMode! == "pct"
                        ? "${double.parse((detail.allowableError! * headerData.actualFmaTotalWgt! / 100).toStringAsFixed(3)).toString()} ${headerData.totalWeightUnit!}"
                        : "${detail.allowableError!.toString()} ${headerData.totalWeightUnit!}",
                detail.sequence == 0 ||
                        headerData.isEncrypted.toString() == "true"
                    ? '-'
                    : "${detail.actualErrorWgt.toString()} ${headerData.totalWeightUnit!}",
                detail.sequence == 0 ||
                        headerData.isEncrypted.toString() == "true"
                    ? '-'
                    : detail.isQualified.toString() == "ok"
                        ? "Pass"
                        : "Fail",
                ""
              ];
              csvData.add(detailRow);
            }
          }
        }
      }

      final csv = const ListToCsvConverter().convert(csvData);
      final file = File(path);
      await file.writeAsString(csv);
      if (!mounted) return;
      showExportDialog(path, context);
    } catch (e) {
      // 处理导出错误
    }
  }

  showFormulaSearch() {
    return Container(
      height: 70,
      color: Theme.of(context).colorScheme.surface,
      child: Row(children: [
        const Spacer(),
        SizedBox(
          width: 160,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              fixedSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: () {
              Map<String, FieldNameStatus> rptFields = getrptFields();
              List<String> selectedFields = [];

              for (String fieldName in rptFields.keys) {
                if (rptFields[fieldName]!.isSelected) {
                  selectedFields.add(fieldName);
                }
              }

              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => PrintRptSelectDialog(
                        options: rptFields,
                        selectedOptions: selectedFields,
                        context: context,
                      )).then((value) {
                if (value != null) {
                  uploadServerInfo = value;
                }
              });
            },
            child: Text(
              localizedStrings.printSettings,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 160,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              fixedSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: () {
              showDialog(
                      context: context,
                      builder: (context) =>
                          FmaServerSettingDialog(info: uploadServerInfo))
                  .then((value) {
                if (value != null) {
                  uploadServerInfo = value;
                }
              });
            },
            child: Text(
              localizedStrings.autoSync, //Sync Settings
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 200,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor:
                  Theme.of(context).colorScheme.onTertiaryFixedVariant,
              fixedSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: (!getExportStatus())
                ? null
                : () {
                    exportSelectedDataToCSV();
                  },
            child: Text(
              localizedStrings.fExportRecordsBtn,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 20),
      ]),
    );
  }
}
