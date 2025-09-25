import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/manager_scale_channel.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/data/formula_from_db_data.dart';

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
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  List<NetScaleInfoLocal> scaleNetItems = [];
  int selScaleId = -1;

  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();

  final List<bool> _isExpanded = [];
  bool _isAllSelected = false;
  late List<bool> _selectedRows;

  // 分页相关状态
  int _currentPage = 1;
  final int _rowsPerPage = 20; // 每页显示20行
  int _totalPages = 1;

  // 排序相关状态
  SortField? _sortField;
  SortDirection _sortDirection = SortDirection.none;

  // 用于分页和排序的数据列表
  List<FmaRecFromDb> _filteredAndSortedList = [];

  void initScaleList() {
    scaleNetItems = myNetScaleList;
    selScaleId = myDefScaleInfo.defScaleId!;
    if (myNetScaleList.isNotEmpty) {
      defNetScaleInfo = NetScaleListMgr.findScaleInfo(
          myNetScaleList, myDefScaleInfo.defScaleId!);
    }

    // 初始化展开状态和选中状态列表
    for (var i = 0; i < fmaRecFromDbList.length; i++) {
      _isExpanded.add(false);
    }
    _selectedRows = List.generate(fmaRecFromDbList.length, (index) => false);

    // 初始化分页和排序
    _updateFilteredAndSortedList();
  }

  @override
  void initState() {
    super.initState();
    initScaleList();
    _tabController = TabController(length: 2, vsync: this);
  }

  // 更新过滤和排序后的列表
  void _updateFilteredAndSortedList() {
    // 复制原始列表
    _filteredAndSortedList = List.from(fmaRecFromDbList);

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
            '${'            当前'} ${_getCurrentPageData().length}${'条'}   ${'   共'} ${_filteredAndSortedList.length} ${'条'}',
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
                                    SizedBox(
                                      width: 60,
                                      child: IconButton(
                                        icon: Icon(
                                          _isExpanded[originalIndex]
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isExpanded[originalIndex] =
                                                !_isExpanded[originalIndex];
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
                                                    SizedBox(
                                                      width: 60,
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
        'Created Time'
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
                : ''
          ];
          csvData.add(headerRow);

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
      showTipInfo(localizedStrings.fSaveSuccess, context);
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

// 重写------------------------------------------------------------------------
// import 'dart:io';

// import 'package:csv/csv.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:t_max/data/comscaleinfo_data.dart';
// import 'package:t_max/data/formula_common.dart';
// import 'package:t_max/data/language.dart';
// import 'package:t_max/data/manager_scale_channel.dart';
// import 'package:t_max/dialog/custom_dialog_tip.dart';
// import 'package:t_max/data/formula_from_db_data.dart';

// // 定义 EncryptedValue 枚举
// enum EncryptedValue {
//   confidential,
//   public,
// }

// // 扩展 EncryptedValue 枚举以添加翻译方法
// extension EncryptedValueExtension on EncryptedValue {
//   String getTranslation(BuildContext context) {
//     switch (this) {
//       case EncryptedValue.confidential:
//         return localizedStrings.fConfidential; // 这里可以替换为翻译函数
//       case EncryptedValue.public:
//         return localizedStrings.fPublic; // 这里可以替换为翻译函数
//     }
//   }
// }

// class AllFmaWgtRecPage extends StatefulWidget {
//   const AllFmaWgtRecPage({super.key});
//   @override
//   State<AllFmaWgtRecPage> createState() => AllFmaWgtRecPageState();
// }

// class AllFmaWgtRecPageState extends State<AllFmaWgtRecPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool sort = false;

//   bool selectAll = false; // 添加全选状态
//   int? clickedRow; // 添加点击行状态
//   // 定义 FocusNode
//   // final FocusNode _searchFocusNode = FocusNode();
//   final TextEditingController encryptedCtl = TextEditingController();
//   final TextEditingController formulaTypeCtl = TextEditingController();
//   final TextEditingController rawTypeCtl = TextEditingController();
//   FormulaInfoDb? selectedFormula; //选中的配方，用于展示原料列表
//   Detail selectedDetail = Detail(); //配方中选中的原料
//   NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal(); //默认秤
//   List<NetScaleInfoLocal> scaleNetItems = []; //秤列表
//   int selScaleId = -1; //选择的秤ID

//   ScrollController scrollController = ScrollController(); //滚动控制器
//   ScrollController scrollController1 = ScrollController(); //滚动控制器

//   final List<bool> _isExpanded = [];
//   bool _isAllSelected = false;
//   late List<bool> _selectedRows;

//   // // 添加一个状态变量，用于跟踪每行的展开状态
//   // List<bool> isRowExpanded = [];

// //初始化秤列表
//   void initScaleList() {
//     scaleNetItems = myNetScaleList;
//     selScaleId = myDefScaleInfo.defScaleId!;
//     if (myNetScaleList.isNotEmpty) {
//       defNetScaleInfo = NetScaleListMgr.findScaleInfo(
//           myNetScaleList, myDefScaleInfo.defScaleId!);
//     }

//     for (var i = 0; i < fmaRecFromDbList.length; i++) {
//       _isExpanded.add(false);
//     }
//     _selectedRows = List.generate(fmaRecFromDbList.length, (index) => false);
//   }
//   //myComScaleInfo

//   @override
//   void initState() {
//     super.initState();
//     initScaleList();

//     _tabController = TabController(length: 2, vsync: this);
//   }

//   void _toggleAllSelection() {
//     setState(() {
//       _isAllSelected = !_isAllSelected;
//       for (int i = 0; i < _selectedRows.length; i++) {
//         _selectedRows[i] = _isAllSelected;
//       }
//     });
//   }

//   void _toggleRowSelection(int index) {
//     setState(() {
//       _selectedRows[index] = !_selectedRows[index];
//       _isAllSelected = _selectedRows.every((element) => element);
//     });
//   }

//   Widget titleText(String data) {
//     return Text(
//       data,
//       style: Theme.of(context).textTheme.bodySmall!.apply(
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//     );
//   }

//   Widget subTitleText(String data) {
//     return Text(
//       data,
//       style: Theme.of(context).textTheme.bodySmall!.apply(
//             color: Theme.of(context).colorScheme.onSurfaceVariant,
//           ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     scrollController.dispose(); // 释放滚动控制器
//     scrollController1.dispose(); // 释放滚动控制器
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final width = MediaQuery.of(context).size.width;
//     return Scaffold(
//         body: Container(
//       color: Theme.of(context).colorScheme.surfaceDim, //对接时修改颜色值
//       child: Padding(
//         padding: const EdgeInsets.all(0.0),
//         child: LayoutBuilder(
//             builder: (BuildContext context, BoxConstraints constraints) {
//           // 获取父容器的可用高度
//           double availableHeight = constraints.maxHeight;

//           // 其他子组件的固定高度
//           double otherChildrenHeight = 54 +
//               1 +
//               70 +
//               14 +
//               65; // 对应 showTitleAndReturn、Divider、showFormulaSearch、Container 的高度

//           // 计算 showFormulaTable 可用的高度
//           double formulaTableHeight = availableHeight - otherChildrenHeight;
//           return Column(
//             children: [
//               showTitleAndReturn(),
//               Divider(
//                 color: Theme.of(context).colorScheme.outline,
//                 thickness: 1,
//                 height: 1,
//               ),
//               showFormulaSearch(),
//               showFormulaTable(formulaTableHeight),
//               Container(
//                 height: 14,
//                 color: Theme.of(context).colorScheme.surface,
//               ),
//             ],
//           );
//         }),
//       ),
//     ));
//   }

//   showFormulaTable(double formulaTableHeight) {
//     return Expanded(
//       flex: 7,
//       child: Scrollbar(
//         controller: scrollController,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           controller: scrollController,
//           child: Container(
//             // padding: const EdgeInsets.all(10),
//             width: 3000,
//             height: formulaTableHeight,
//             decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surfaceBright,
//                 border: Border.all(
//                     width: 0.2,
//                     color: Theme.of(context).colorScheme.onSurface)),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.vertical, // 水平滚动
//               controller: scrollController1,
//               child: //   return Expanded(
//                   Container(
//                 padding: const EdgeInsets.only(left: 20, right: 20),
//                 color: Theme.of(context).colorScheme.surface,
//                 child: Column(
//                   children: [
//                     // 表格头
//                     Container(
//                       width: 3000,
//                       height: 40,
//                       color: Theme.of(context).colorScheme.surfaceDim,
//                       child: Row(
//                         children: [
//                           Checkbox(
//                             value: _isAllSelected,
//                             onChanged: (bool? value) {
//                               _toggleAllSelection();
//                             },
//                           ),
//                           Expanded(
//                             child:
//                                 Text(localizedStrings.fOrderNo ?? "Order No"),
//                           ),
//                           Expanded(
//                               child: titleText(localizedStrings.fFmaIdLabel)),
//                           Expanded(
//                               child: titleText(localizedStrings.fFmaNameLabel)),
//                           Expanded(
//                               child:
//                                   titleText(localizedStrings.fMaterialNameCol)),
//                           Expanded(
//                               child:
//                                   titleText(localizedStrings.fMaterialIdCol)),
//                           Expanded(
//                               child: titleText(localizedStrings.fFmaModeCol)),
//                           Expanded(
//                               child: titleText(localizedStrings.fConfidential)),
//                           Expanded(
//                               child: titleText(
//                                   localizedStrings.fFormulaTotalWeight)),
//                           Expanded(
//                               child: titleText(
//                                   localizedStrings.fActualTotalWeight)),
//                           Expanded(
//                               child: titleText(
//                                   localizedStrings.fMaterialSingleWeight)),
//                           Expanded(
//                               child: titleText(
//                                   localizedStrings.fActualSingleWeight)),
//                           Expanded(
//                               child:
//                                   titleText(localizedStrings.fAllowableError)),
//                           Expanded(
//                               child: titleText(localizedStrings.fActualError)),
//                           Expanded(
//                               child: titleText(
//                                   localizedStrings.fQualificationStatus)),
//                           Expanded(
//                               child: titleText(localizedStrings.gDeviceName)),
//                           Expanded(
//                               child: titleText(localizedStrings.fCreatedAtCol)),
//                           const SizedBox(width: 60, child: Text('')),
//                         ],
//                       ),
//                     ),
//                     Divider(
//                       color: Theme.of(context).colorScheme.outlineVariant,
//                       thickness: 1,
//                       height: 1,
//                     ),
//                     SizedBox(
//                       height: formulaTableHeight,
//                       child: ListView.builder(
//                         itemCount: fmaRecFromDbList.length,
//                         itemBuilder: (context, index) {
//                           final rowData = fmaRecFromDbList[index];
//                           return Column(
//                             children: [
//                               // 主行
//                               Container(
//                                 height: 40,
//                                 color: const Color.fromARGB(255, 247, 247, 247),
//                                 child: Row(
//                                   children: [
//                                     Checkbox(
//                                       value: _selectedRows[index],
//                                       onChanged: (bool? value) {
//                                         _toggleRowSelection(index);
//                                       },
//                                     ),
//                                     Expanded(
//                                         child: titleText(
//                                             rowData.header?.recordId ?? "")),
//                                     Expanded(
//                                         child: titleText(
//                                             rowData.header!.formulaId ?? "")),
//                                     Expanded(
//                                         child: titleText(
//                                             rowData.header!.formulaName ?? "")),
//                                     Expanded(child: Text('')),
//                                     Expanded(child: Text('')),
//                                     Expanded(
//                                         child: titleText(
//                                             rowData.header!.formulaMode! ==
//                                                     'wgt'
//                                                 ? localizedStrings.fWeightMode
//                                                 : localizedStrings.fPctMode)),
//                                     Expanded(
//                                         child: Text(
//                                       " ${rowData.header!.isEncrypted.toString() == "true" ? localizedStrings.fConfidential : localizedStrings.fPublic}",
//                                       style: TextStyle(
//                                           color: rowData.header!.isEncrypted
//                                                       .toString() ==
//                                                   "false"
//                                               ? Theme.of(context)
//                                                   .colorScheme
//                                                   .onTertiaryFixedVariant
//                                               : Theme.of(context)
//                                                   .colorScheme
//                                                   .error),
//                                     )),
//                                     Expanded(
//                                         child: titleText(
//                                             "${rowData.header!.actualFmaTotalWgt!.toStringAsFixed(3)} ${rowData.header!.totalWeightUnit}")),
//                                     Expanded(
//                                         child: titleText(
//                                             "${rowData.header!.actualTotalWeight!.toStringAsFixed(3)} ${rowData.header!.totalWeightUnit}")),
//                                     Expanded(child: Text('')),
//                                     Expanded(child: Text('')),
//                                     Expanded(child: Text('')),
//                                     Expanded(child: Text('')),
//                                     Expanded(
//                                       child: Text(
//                                         rowData.header!.isQualified
//                                                     .toString() ==
//                                                 "yes"
//                                             ? localizedStrings.fQualified
//                                             : localizedStrings.fUnqualified,
//                                         style: TextStyle(
//                                             color: rowData.header!.isQualified
//                                                         .toString() ==
//                                                     "yes"
//                                                 ? Theme.of(context)
//                                                     .colorScheme
//                                                     .onTertiaryFixedVariant
//                                                 : Theme.of(context)
//                                                     .colorScheme
//                                                     .error),
//                                       ),
//                                     ),
//                                     Expanded(child: Text("")),
//                                     Expanded(
//                                         // 格式化日期时间，显示本地时区的年月日时分秒
//                                         child: titleText(rowData
//                                                     .header!.recordSaveTime !=
//                                                 null
//                                             ? DateFormat('yyyy-MM-dd HH:mm:ss')
//                                                 .format(rowData
//                                                     .header!.recordSaveTime!)
//                                             : '')),
//                                     SizedBox(
//                                       width: 60,
//                                       child: IconButton(
//                                         icon: Icon(
//                                           _isExpanded[index]
//                                               ? Icons.expand_less
//                                               : Icons.expand_more,
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             _isExpanded[index] =
//                                                 !_isExpanded[index];
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Divider(
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .outlineVariant,
//                                 thickness: 1,
//                                 height: 1,
//                               ),

//                               // 展开的明细行
//                               Visibility(
//                                 visible: _isExpanded[index],
//                                 child: Column(
//                                   children: rowData.details
//                                           ?.asMap()
//                                           .entries
//                                           .map<Widget>((entry) {
//                                         final detailIndex = entry.key;
//                                         final detail = entry.value;
//                                         return Column(
//                                           children: [
//                                             Container(
//                                               height: 40,
//                                               color: Colors.white,
//                                               child: SizedBox(
//                                                 height: 38,
//                                                 child: Row(
//                                                   children: [
//                                                     const SizedBox(
//                                                         width: 48), // 对齐复选框位置
//                                                     const Expanded(
//                                                         child: Text('')),
//                                                     Expanded(child: Text('')),
//                                                     Expanded(child: Text('')),
//                                                     Expanded(
//                                                       child: subTitleText(
//                                                         detail.sequence == 0
//                                                             ? localizedStrings
//                                                                 .fFmaContainer
//                                                             : detail.materialName ??
//                                                                 "",
//                                                       ),
//                                                     ),
//                                                     Expanded(
//                                                       child: subTitleText(
//                                                           detail.materialId ??
//                                                               ''),
//                                                     ),
//                                                     Expanded(child: Text('')),
//                                                     Expanded(child: Text('')),
//                                                     Expanded(child: Text('')),
//                                                     Expanded(child: Text('')),
//                                                     Expanded(
//                                                         child: subTitleText(detail
//                                                                         .sequence ==
//                                                                     0 ||
//                                                                 rowData.header!
//                                                                         .isEncrypted
//                                                                         .toString() ==
//                                                                     "true"
//                                                             ? '-'
//                                                             : "${detail.targetWgt.toString()} ${rowData.header!.totalWeightUnit!}")),

//                                                     Expanded(
//                                                         child: subTitleText((detail
//                                                                         .sequence ==
//                                                                     0 ||
//                                                                 (rowData.header!
//                                                                         .isEncrypted
//                                                                         .toString() !=
//                                                                     "true"))
//                                                             ? '${detail.actualWeight.toString()} ${rowData.header!.totalWeightUnit!}'
//                                                             : "-")),
//                                                     Expanded(
//                                                       child: subTitleText(detail
//                                                                       .sequence ==
//                                                                   0 ||
//                                                               rowData.header!
//                                                                       .isEncrypted
//                                                                       .toString() ==
//                                                                   "true"
//                                                           ? '-'
//                                                           : rowData.header!
//                                                                       .formulaMode! ==
//                                                                   "pct"
//                                                               ? "${double.parse((detail.allowableError! * rowData.header!.actualFmaTotalWgt! / 100).toStringAsFixed(3)).toString()} ${rowData.header!.totalWeightUnit!}"
//                                                               : "${detail.allowableError!.toString()} ${rowData.header!.totalWeightUnit!}"),
//                                                     ),
//                                                     Expanded(
//                                                         child: subTitleText(detail
//                                                                         .sequence ==
//                                                                     0 ||
//                                                                 rowData.header!
//                                                                         .isEncrypted
//                                                                         .toString() ==
//                                                                     "true"
//                                                             ? '-'
//                                                             : "${detail.actualErrorWgt.toString()} ${rowData.header!.totalWeightUnit!}")),
//                                                     Expanded(
//                                                         child: Text(
//                                                             detail.sequence ==
//                                                                         0 ||
//                                                                     rowData
//                                                                             .header!
//                                                                             .isEncrypted
//                                                                             .toString() ==
//                                                                         "true"
//                                                                 ? '-'
//                                                                 : detail.isQualified
//                                                                             .toString() ==
//                                                                         "ok"
//                                                                     ? localizedStrings
//                                                                         .fQualified
//                                                                     : localizedStrings
//                                                                         .fUnqualified,
//                                                             style: TextStyle(
//                                                                 color: detail
//                                                                             .isQualified
//                                                                             .toString() ==
//                                                                         "ok"
//                                                                     ? Theme.of(
//                                                                             context)
//                                                                         .colorScheme
//                                                                         .onTertiaryFixedVariant
//                                                                     : Theme.of(
//                                                                             context)
//                                                                         .colorScheme
//                                                                         .error))),
//                                                     Expanded(
//                                                         child: Text(
//                                                             detail.scaleName ??
//                                                                 '-')),
//                                                     Expanded(child: Text('')),
//                                                     SizedBox(
//                                                       width: 60,
//                                                       child: Text(''),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                             // 判断是否为最后一个元素，不是则显示分割线
//                                             if (detailIndex <
//                                                 (rowData.details?.length ?? 0) -
//                                                     1)
//                                               Divider(
//                                                 color: Theme.of(context)
//                                                     .colorScheme
//                                                     .outlineVariant,
//                                                 thickness: 1,
//                                                 height: 1,
//                                               )
//                                           ],
//                                         );
//                                       }).toList() ??
//                                       [],
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   showTitleAndReturn() {
//     return Container(
//       height: 54,
//       color: Theme.of(context).colorScheme.surface,
//       child: Row(
//         children: [
//           Expanded(
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.keyboard_double_arrow_left_outlined,
//                     size: 20,
//                     color: Theme.of(context).colorScheme.primary,
//                   ), // 返回图标
//                   onPressed: () {
//                     Navigator.pop(context); // 返回到上一个页面
//                   },
//                 ),
//                 Text(
//                   localizedStrings.fRecordTitle,
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.onSurface,
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ), // 标题文本
//               ],
//             ),
//           ),
//           SizedBox(
//             width: 20,
//           )
//         ],
//       ),
//     );
//   }

//   bool getExportStatus() {
//     //查找是否有选中的行
//     bool hasSelectedRow = _selectedRows.any((element) => element);

//     return hasSelectedRow;
//   }

//   // 导出选中数据到 CSV 文件
//   Future<void> exportSelectedDataToCSV() async {
//     final directory = Directory.current.path;
//     String? outputFile = (await FilePicker.platform.saveFile(
//       initialDirectory: directory,
//       type: FileType.custom,
//       dialogTitle: 'Output file:',
//       allowedExtensions: ["csv"],
//       fileName: 'formulaWgt.csv',
//     ));
//     if (outputFile != null) {
//       if (!outputFile.contains(".csv")) {
//         outputFile = "$outputFile.csv";
//       }
//       exportWgtRecords(outputFile);
//     }
//   }

//   Future<void> exportWgtRecords(String path) async {
//     try {
//       // 准备 CSV 表头
//       final header = [
//         'Order No',
//         'Fma Id',
//         'Fma Name',
//         'Material Name',
//         'Material Id',
//         'Fma Mode',
//         'Confidential',
//         'Formula Total Weight',
//         'Actual Total Weight',
//         'Material Single Weight',
//         'Actual Single Weight',
//         'Allowable Error',
//         'Actual Error',
//         'Qualification Status',
//         'Created At'
//       ];

//       List<List<dynamic>> csvData = [header];

//       // 遍历选中的行
//       for (int i = 0; i < _selectedRows.length; i++) {
//         if (_selectedRows[i]) {
//           final rowData = fmaRecFromDbList[i];
//           final headerData = rowData.header;

//           // 添加表头数据
//           final headerRow = [
//             headerData?.recordId ?? "",
//             headerData?.formulaId ?? "",
//             headerData?.formulaName ?? "",
//             "",
//             "",
//             headerData?.formulaMode == 'wgt'
//                 ? localizedStrings.fWeightMode
//                 : localizedStrings.fPctMode,
//             headerData?.isEncrypted.toString() == "true"
//                 ? localizedStrings.fConfidential
//                 : localizedStrings.fPublic,
//             "${headerData?.actualFmaTotalWgt} ${headerData?.totalWeightUnit}",
//             "${(headerData?.actualTotalWeight)!.toStringAsFixed(3)} ${headerData?.totalWeightUnit}",
//             "",
//             "",
//             "",
//             "",
//             headerData?.isQualified.toString() == "yes"
//                 ? localizedStrings.fQualified
//                 : localizedStrings.fUnqualified,
//             headerData?.recordSaveTime != null
//                 ? DateFormat('yyyy-MM-dd HH:mm:ss')
//                     .format(headerData!.recordSaveTime!)
//                 : ''
//           ];
//           csvData.add(headerRow);

//           // 添加明细数据
//           if (rowData.details != null) {
//             for (final detail in rowData.details!) {
//               final detailRow = [
//                 "",
//                 "",
//                 "",
//                 detail.sequence == 0
//                     ? localizedStrings.fFmaContainer
//                     : detail.materialName ?? "",
//                 detail.materialId ?? "",
//                 "",
//                 "",
//                 "",
//                 "",
//                 detail.sequence == 0 ||
//                         headerData!.isEncrypted.toString() == "true"
//                     ? '-'
//                     : "${detail.targetWgt.toString()} ${headerData.totalWeightUnit!}",
//                 (detail.sequence == 0 ||
//                         headerData!.isEncrypted.toString() != "true")
//                     ? '${detail.actualWeight.toString()} ${headerData!.totalWeightUnit!}'
//                     : "-",
//                 detail.sequence == 0 ||
//                         headerData.isEncrypted.toString() == "true"
//                     ? '-'
//                     : headerData.formulaMode! == "pct"
//                         ? "${double.parse((detail.allowableError! * headerData.actualFmaTotalWgt! / 100).toStringAsFixed(3)).toString()} ${headerData.totalWeightUnit!}"
//                         : "${detail.allowableError!.toString()} ${headerData.totalWeightUnit!}",
//                 detail.sequence == 0 ||
//                         headerData.isEncrypted.toString() == "true"
//                     ? '-'
//                     : "${detail.actualErrorWgt.toString()} ${headerData.totalWeightUnit!}",
//                 detail.sequence == 0 ||
//                         headerData.isEncrypted.toString() == "true"
//                     ? '-'
//                     : detail.isQualified.toString() == "ok"
//                         ? localizedStrings.fQualified
//                         : localizedStrings.fUnqualified,
//                 ""
//               ];
//               csvData.add(detailRow);
//             }
//           }
//         }
//       }

//       // 生成 CSV 内容
//       final csv = const ListToCsvConverter().convert(csvData);
//       final file = File(path);
//       // 将 CSV 内容写入文件
//       await file.writeAsString(csv);
//       // 提示导出成功
//       showTipInfo(localizedStrings.fSaveSuccess, context);
//     } catch (e) {
//       // 提示导出失败
//     }
//   }

//   showFormulaSearch() {
//     return Container(
//       height: 70,
//       color: Theme.of(context).colorScheme.surface,
//       child: Row(children: [
//         Spacer(),
//         SizedBox(
//           width: 200,
//           height: 40,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Theme.of(context).colorScheme.onPrimary,
//               backgroundColor:
//                   Theme.of(context).colorScheme.onTertiaryFixedVariant,
//               fixedSize: const Size(double.infinity, 48),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
//               ),
//             ),
//             onPressed: (!getExportStatus())
//                 ? null
//                 : () {
//                     exportSelectedDataToCSV();
//                   },
//             child: Text(
//               localizedStrings.fExportRecordsBtn,
//               style: Theme.of(context).textTheme.bodySmall!.apply(
//                     color: Theme.of(context).colorScheme.onPrimary,
//                   ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 20,
//         ),
//       ]),
//     );
//   }
// }
