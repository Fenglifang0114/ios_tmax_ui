//单个配方的所有称重记录

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/data/formula_from_db_data.dart';

// 定义排序字段枚举
enum SortField {
  orderNo,
  fmaId,
  fmaName,
  totalWeight,
  actualWeight,
  createdAt,
}

// 定义排序方向枚举
enum SortDirection {
  ascending,
  descending,
  none,
}

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

class OneFmaWgtRecPage extends StatefulWidget {
  const OneFmaWgtRecPage({super.key, required this.oneFmaRecList});
  final List<FmaRecFromDb> oneFmaRecList;

  @override
  State<OneFmaWgtRecPage> createState() => OneFmaWgtRecPageState();
}

class OneFmaWgtRecPageState extends State<OneFmaWgtRecPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 排序相关状态
  SortField? _currentSortField;
  SortDirection _currentSortDirection = SortDirection.none;

  // 选择相关状态
  bool _isAllSelected = false;
  bool _isAllPagesSelected = false;
  late List<bool> _selectedRows = [];

  // 分页相关状态
  int _currentPage = 1;
  final int _rowsPerPage = 20;
  int _totalPages = 1;

  // 搜索和控制器
  final TextEditingController _searchCtl = TextEditingController();
  final TextEditingController encryptedCtl = TextEditingController();
  final TextEditingController formulaTypeCtl = TextEditingController();
  final TextEditingController rawTypeCtl = TextEditingController();

  // 数据和其他状态
  FormulaInfoDb? selectedFormula;
  Detail selectedDetail = Detail();
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  List<NetScaleInfoLocal> scaleNetItems = [];

  List<FmaRecFromDb> fmaRecList = [];
  List<FmaRecFromDb> _filteredList = [];
  List<FmaRecFromDb> _currentPageList = [];
  final List<bool> _isExpanded = [];

  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();

  @override
  void initState() {
    super.initState();

    fmaRecList = widget.oneFmaRecList;
    _filteredList = List.from(fmaRecList);
    _calculateTotalPages();
    _updateCurrentPageList();

    for (var i = 0; i < _currentPageList.length; i++) {
      _isExpanded.add(false);
    }
    _selectedRows = List.generate(_currentPageList.length, (index) => false);

    _tabController = TabController(length: 2, vsync: this);

    // 监听搜索框变化
    _searchCtl.addListener(_onSearchTextChanged);
  }

  // 计算总页数
  void _calculateTotalPages() {
    _totalPages = (_filteredList.length / _rowsPerPage).ceil();
    if (_totalPages < 1) _totalPages = 1;
    if (_currentPage > _totalPages) _currentPage = _totalPages;
  }

  // 更新当前页数据
  void _updateCurrentPageList() {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    if (endIndex > _filteredList.length) {
      endIndex = _filteredList.length;
    }

    setState(() {
      _currentPageList = _filteredList.sublist(startIndex, endIndex);
      _isExpanded.clear();
      for (var i = 0; i < _currentPageList.length; i++) {
        _isExpanded.add(false);
      }
    });
  }

  // 搜索文本变化处理
  void _onSearchTextChanged() {
    final searchText = _searchCtl.text.toLowerCase();

    setState(() {
      if (searchText.isEmpty) {
        _filteredList = List.from(fmaRecList);
      } else {
        _filteredList = fmaRecList.where((item) {
          return (item.header?.recordId?.toLowerCase().contains(searchText) ??
                  false) ||
              (item.header?.formulaId?.toLowerCase().contains(searchText) ??
                  false) ||
              (item.header?.formulaName?.toLowerCase().contains(searchText) ??
                  false);
        }).toList();
      }

      _currentPage = 1;
      _calculateTotalPages();
      _updateCurrentPageList();
      _sortData(); // 保持排序状态
    });
  }

  // 排序数据
  void _sortData() {
    if (_currentSortField == null ||
        _currentSortDirection == SortDirection.none) {
      return;
    }

    setState(() {
      _filteredList.sort((a, b) {
        int comparisonResult = 0;

        switch (_currentSortField!) {
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
          case SortField.totalWeight:
            comparisonResult = (a.header?.actualFmaTotalWgt ?? 0)
                .compareTo(b.header?.actualFmaTotalWgt ?? 0);
            break;
          case SortField.actualWeight:
            comparisonResult = (a.header?.actualTotalWeight ?? 0)
                .compareTo(b.header?.actualTotalWeight ?? 0);
            break;
          case SortField.createdAt:
            comparisonResult = (a.header?.recordSaveTime ?? DateTime(0))
                .compareTo(b.header?.recordSaveTime ?? DateTime(0));
            break;
        }

        return _currentSortDirection == SortDirection.ascending
            ? comparisonResult
            : -comparisonResult;
      });

      _updateCurrentPageList();
    });
  }

  // 切换排序字段和方向
  void _toggleSort(SortField field) {
    setState(() {
      if (_currentSortField == field) {
        // 切换排序方向
        switch (_currentSortDirection) {
          case SortDirection.ascending:
            _currentSortDirection = SortDirection.descending;
            break;
          case SortDirection.descending:
            _currentSortDirection = SortDirection.none;
            _currentSortField = null;
            break;
          case SortDirection.none:
            _currentSortDirection = SortDirection.ascending;
            _currentSortField = field;
            break;
        }
      } else {
        // 新的排序字段，默认升序
        _currentSortField = field;
        _currentSortDirection = SortDirection.ascending;
      }
      _sortData();
    });
  }

  // 获取排序图标
  Widget? _getSortIcon(SortField field) {
    if (_currentSortField != field) {
      return null;
    }

    switch (_currentSortDirection) {
      case SortDirection.ascending:
        return const Icon(Icons.arrow_upward, size: 16);
      case SortDirection.descending:
        return const Icon(Icons.arrow_downward, size: 16);
      case SortDirection.none:
        return null;
    }
  }

  // 全选当前页
  void _toggleAllPageSelection() {
    setState(() {
      _isAllSelected = !_isAllSelected;
      for (int i = 0; i < _selectedRows.length; i++) {
        _selectedRows[i] = _isAllSelected;
      }
    });
  }

  // 切换单行选择
  void _toggleRowSelection(int index) {
    setState(() {
      _selectedRows[index] = !_selectedRows[index];
      _isAllSelected = _selectedRows.every((element) => element);
      _isAllPagesSelected = false; // 取消全选所有页状态
    });
  }

  // 切换到指定页
  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;

    setState(() {
      _currentPage = page;
      _updateCurrentPageList();
    });
  }

  // 上一页
  void _prevPage() {
    _goToPage(_currentPage - 1);
  }

  // 下一页
  void _nextPage() {
    _goToPage(_currentPage + 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollController.dispose();
    scrollController1.dispose();
    _searchCtl.dispose();
    encryptedCtl.dispose();
    formulaTypeCtl.dispose();
    rawTypeCtl.dispose();
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

  // 构建分页控件
  Widget _buildPaginationControls() {
    return Container(
      height: 50,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage == 1 ? null : () => _goToPage(1),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _currentPage == 1 ? null : _prevPage,
          ),
          Text(
            '$_currentPage / $_totalPages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _currentPage == _totalPages ? null : _nextPage,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage == _totalPages
                ? null
                : () => _goToPage(_totalPages),
          ),
          Text(
            ' ${localizedStrings.tipPageTotal} ${_filteredList.length} ${localizedStrings.tipPageItems}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget showFormulaTable(double formulaTableHeight) {
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
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Row(
                        children: [
                          // 全选复选框
                          Checkbox(
                            value: _isAllSelected,
                            tristate: true,
                            onChanged: (bool? value) {
                              _toggleAllPageSelection();
                            },
                          ),
                          // 订单号（可排序）
                          Expanded(
                            child: InkWell(
                              onTap: () => _toggleSort(SortField.orderNo),
                              child: Row(
                                children: [
                                  Text(
                                    localizedStrings.fOrderNo ?? "Order No",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                  ),
                                  if (_getSortIcon(SortField.orderNo) != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: _getSortIcon(SortField.orderNo),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // 配方ID（可排序）
                          Expanded(
                            child: InkWell(
                              onTap: () => _toggleSort(SortField.fmaId),
                              child: Row(
                                children: [
                                  Text(
                                    localizedStrings.fFmaIdLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                  ),
                                  if (_getSortIcon(SortField.fmaId) != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: _getSortIcon(SortField.fmaId),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // 配方名称（可排序）
                          Expanded(
                            child: InkWell(
                              onTap: () => _toggleSort(SortField.fmaName),
                              child: Row(
                                children: [
                                  Text(
                                    localizedStrings.fFmaNameLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                  ),
                                  if (_getSortIcon(SortField.fmaName) != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: _getSortIcon(SortField.fmaName),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: titleText(localizedStrings.fMaterialNameCol),
                          ),
                          Expanded(
                              child:
                                  titleText(localizedStrings.fMaterialIdCol)),
                          Expanded(
                              child: titleText(localizedStrings.fFmaModeCol)),
                          Expanded(
                            child: titleText(localizedStrings.fConfidential),
                          ),

                          // 配方总重量（可排序）
                          Expanded(
                            child: InkWell(
                              onTap: () => _toggleSort(SortField.totalWeight),
                              child: Row(
                                children: [
                                  titleText(
                                      localizedStrings.fFormulaTotalWeight),
                                  if (_getSortIcon(SortField.totalWeight) !=
                                      null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child:
                                          _getSortIcon(SortField.totalWeight),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // 实际总重量（可排序）
                          Expanded(
                            child: InkWell(
                              onTap: () => _toggleSort(SortField.actualWeight),
                              child: Row(
                                children: [
                                  titleText(
                                      localizedStrings.fActualTotalWeight),
                                  if (_getSortIcon(SortField.actualWeight) !=
                                      null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child:
                                          _getSortIcon(SortField.actualWeight),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: titleText(
                                localizedStrings.fMaterialSingleWeight),
                          ),
                          Expanded(
                            child:
                                titleText(localizedStrings.fActualSingleWeight),
                          ),
                          Expanded(
                            child: titleText(localizedStrings.fAllowableError),
                          ),
                          Expanded(
                              child: titleText(localizedStrings.fActualError)),
                          Expanded(
                              child: titleText(
                                  localizedStrings.fQualificationStatus)),
                          Expanded(
                              child: titleText(localizedStrings.gDeviceName)),

                          // 创建时间（可排序）
                          Expanded(
                            child: InkWell(
                              onTap: () => _toggleSort(SortField.createdAt),
                              child: Row(
                                children: [
                                  titleText(localizedStrings.fCreatedAtCol),
                                  if (_getSortIcon(SortField.createdAt) != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: _getSortIcon(SortField.createdAt),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(child: titleText(localizedStrings.operator)),
                          const SizedBox(width: 60, child: Text('')),
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
                      child: _currentPageList.isEmpty
                          ? Center(
                              child: Text(localizedStrings.fNoDataAvailable),
                            )
                          : ListView.builder(
                              itemCount: _currentPageList.length,
                              itemBuilder: (context, index) {
                                final rowData = _currentPageList[index];
                                return Column(
                                  children: [
                                    // 主行
                                    Container(
                                      height: 40,
                                      color: const Color.fromARGB(
                                          255, 247, 247, 247),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: _selectedRows[index],
                                            onChanged: (bool? value) {
                                              _toggleRowSelection(index);
                                            },
                                          ),
                                          Expanded(
                                            child: titleText(
                                                rowData.header?.recordId ?? ""),
                                          ),
                                          Expanded(
                                            child: titleText(
                                                rowData.header!.formulaId ??
                                                    ""),
                                          ),
                                          Expanded(
                                            child: titleText(
                                                rowData.header!.formulaName ??
                                                    ""),
                                          ),
                                          Expanded(child: Text('')),
                                          Expanded(child: Text('')),
                                          Expanded(
                                            child: titleText(rowData
                                                        .header!.formulaMode! ==
                                                    'wgt'
                                                ? localizedStrings.fWeightMode
                                                : localizedStrings.fPctMode),
                                          ),
                                          Expanded(
                                              child: Text(
                                            " ${rowData.header!.isEncrypted.toString() == "true" ? localizedStrings.fConfidential : localizedStrings.fPublic}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                    color: rowData.header!
                                                                .isEncrypted
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
                                              "${rowData.header!.actualFmaTotalWgt!.toStringAsFixed(3)} ${rowData.header!.totalWeightUnit}",
                                            ),
                                          ),
                                          Expanded(
                                            child: titleText(
                                              "${rowData.header!.actualTotalWeight!.toStringAsFixed(3)} ${rowData.header!.totalWeightUnit}",
                                            ),
                                          ),
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
                                                  : localizedStrings
                                                      .fUnqualified,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .apply(
                                                      color: rowData.header!
                                                                  .isQualified
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
                                          Expanded(
                                              child: Text(
                                            '',
                                          )),
                                          Expanded(
                                            child: titleText(
                                              rowData.header!.recordSaveTime !=
                                                      null
                                                  ? DateFormat(
                                                          'yyyy-MM-dd HH:mm:ss')
                                                      .format(rowData.header!
                                                          .recordSaveTime!)
                                                  : '',
                                            ),
                                          ),
                                          Expanded(
                                              child: titleText(rowData.header!
                                                          .headerOperator !=
                                                      null
                                                  ? rowData
                                                      .header!.headerOperator!
                                                  : '')),
                                          SizedBox(
                                            width: 60,
                                            child: IconButton(
                                              icon: Icon(
                                                _isExpanded[index]
                                                    ? Icons.expand_less
                                                    : Icons.expand_more,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isExpanded[index] =
                                                      !_isExpanded[index];
                                                });
                                              },
                                            ),
                                          ),
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
                                      visible: _isExpanded[index],
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
                                                              width:
                                                                  48), // 对齐复选框位置
                                                          const Expanded(
                                                              child: Text('')),
                                                          Expanded(
                                                              child: Text('')),
                                                          Expanded(
                                                              child: Text('')),
                                                          Expanded(
                                                            child: subTitleText(
                                                              detail.sequence ==
                                                                      0
                                                                  ? localizedStrings
                                                                      .fFmaContainer
                                                                  : detail.materialName ??
                                                                      "",
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: subTitleText(
                                                              detail.materialId ??
                                                                  '',
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child: Text('')),
                                                          Expanded(
                                                              child: Text('')),
                                                          Expanded(
                                                              child: Text('')),
                                                          Expanded(
                                                              child: Text('')),
                                                          Expanded(
                                                              child:
                                                                  subTitleText(
                                                            detail.sequence ==
                                                                        0 ||
                                                                    rowData.header!
                                                                            .isEncrypted
                                                                            .toString() ==
                                                                        "true"
                                                                ? '-'
                                                                : "${detail.targetWgt.toString()} ${rowData.header!.totalWeightUnit!}",
                                                          )),

                                                          Expanded(
                                                              child:
                                                                  subTitleText(
                                                            (detail.sequence ==
                                                                        0 ||
                                                                    rowData.header!
                                                                            .isEncrypted
                                                                            .toString() !=
                                                                        "true")
                                                                ? '${detail.actualWeight.toString()} ${rowData.header!.totalWeightUnit!}'
                                                                : "-",
                                                          )),
                                                          Expanded(
                                                            child: subTitleText(
                                                              detail.sequence ==
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
                                                                      : "${detail.allowableError!.toString()} ${rowData.header!.totalWeightUnit!}",
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child:
                                                                  subTitleText(
                                                            detail.sequence ==
                                                                        0 ||
                                                                    rowData.header!
                                                                            .isEncrypted
                                                                            .toString() ==
                                                                        "true"
                                                                ? '-'
                                                                : "${detail.actualErrorWgt.toString()} ${rowData.header!.totalWeightUnit!}",
                                                          )),
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
                                                            style: Theme.of(context).textTheme.bodySmall!.apply(
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
                                                                        .error),
                                                          )),
                                                          Expanded(
                                                              child:
                                                                  subTitleText(
                                                            detail.scaleName ??
                                                                '-',
                                                          )),
                                                          Expanded(
                                                              child: Text('')),
                                                          Expanded(
                                                              child: Text('')),
                                                          SizedBox(
                                                            width: 60,
                                                            child: Text(''),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // 判断是否为最后一个元素，不是则显示分割线
                                                  if (detailIndex <
                                                      (rowData.details
                                                                  ?.length ??
                                                              0) -
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

  Widget showTitleAndReturn() {
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
                  widget.oneFmaRecList.isNotEmpty
                      ? '${widget.oneFmaRecList[0].header?.formulaName} ${localizedStrings.fRecordTitle}'
                      : localizedStrings.fRecordTitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  bool getExportStatus() {
    // 检查当前页是否有选中的行
    bool hasSelectedRow = _selectedRows.any((element) => element);

    // 如果是全选所有页，也视为有选中行
    return hasSelectedRow || _isAllPagesSelected;
  }

  // 导出选中数据到 CSV 文件
  Future<void> exportSelectedDataToCSV() async {
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'formulaRecs.csv',
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
      // 准备 CSV 表头
      final header = [
        'No.',
        'Formula Id',
        'Formula Name',
        'Ingredient Name',
        'Ingredient Id',
        'Mode',
        'Confidential',
        'Formula Total Weight',
        'Actual Total Weight',
        'Ingredient Weight',
        'Actual Ingredient Weight',
        'Allowable Error',
        'Actual Error',
        'Pass',
        'Created Time',
        'Operator',
      ];

      List<List<dynamic>> csvData = [header];
      List<FmaRecFromDb> exportList = [];

      // 确定需要导出的数据
      if (_isAllPagesSelected) {
        // 导出所有数据
        exportList = List.from(_filteredList);
      } else {
        // 只导出当前页选中的数据
        for (int i = 0; i < _selectedRows.length; i++) {
          if (_selectedRows[i]) {
            exportList.add(_currentPageList[i]);
          }
        }
      }

      // 遍历需要导出的数据
      for (final rowData in exportList) {
        final headerData = rowData.header;

        // 添加表头数据
        final headerRow = [
          headerData?.recordId ?? "",
          headerData?.formulaId ?? "",
          headerData?.formulaName ?? "",
          "",
          "",
          headerData?.formulaMode == 'wgt'
              ? localizedStrings.fWeightMode
              : localizedStrings.fPctMode,
          headerData?.isEncrypted.toString() == "true"
              ? localizedStrings.fConfidential
              : localizedStrings.fPublic,
          "${headerData?.actualFmaTotalWgt} ${headerData?.totalWeightUnit}",
          "${(headerData?.actualTotalWeight ?? 0.0).toStringAsFixed(3)} ${headerData?.totalWeightUnit}",
          "",
          "",
          "",
          "",
          headerData?.isQualified.toString() == "yes" ? "Pass" : "Fail",
          headerData?.recordSaveTime != null
              ? DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(headerData!.recordSaveTime!)
              : '',
          headerData?.headerOperator != null ? headerData!.headerOperator! : '',
        ];
        csvData.add(headerRow);

        // 添加明细数据
        if (rowData.details != null) {
          for (final detail in rowData.details!) {
            final detailRow = [
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
                  ? '${(detail.actualWeight ?? 0.0).toStringAsFixed(3)} ${headerData!.totalWeightUnit!}'
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

      final csv = const ListToCsvConverter().convert(csvData);
      final file = File(path);
      await file.writeAsString(csv);
      if (mounted) {
        showTipInfo(localizedStrings.fSaveSuccess, context);
      }
    } catch (e) {
      if (mounted) {
        showTipInfo('${localizedStrings.gTipExportFail}: $e', context);
      }
    }
  }

  Widget showFormulaSearch() {
    return Container(
      height: 70,
      color: Theme.of(context).colorScheme.surface,
      child: Row(children: [
        const SizedBox(width: 20),
        // 添加搜索框
        SizedBox(
          width: 300,
          height: 40,
          child: TextField(
            controller: _searchCtl,
            decoration: InputDecoration(
              // hintText: 'localizedStrings.fSearchByOrderNoFmaIdOrName',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Spacer(),
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
