import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/add_fma_wgt_dialog.dart';
import 'package:t_max/dialog/add_raw_info_dialog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/show_fma_detail_dialog.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/add_formula_page.dart';
import 'package:t_max/pages/all_fma_wgt_rec_page.dart';
import 'package:t_max/pages/edit_darft_fma_page.dart';
import 'package:t_max/pages/edit_formula_page.dart';
import 'package:t_max/pages/fma_wgt_rec_page.dart';
import 'package:t_max/pages/start_darft_fma_pct_page.dart';
import 'package:t_max/pages/start_fma_pct_page.dart';
import 'package:t_max/pages/start_fma_secret_page.dart';
import 'package:t_max/widget/formula_widget.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/widget/page_head.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/sticky_table.dart';
import '../data/language.dart';

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
        return localizedStrings.fConfidential; // 这里可以替换为翻译函数
      case EncryptedValue.public:
        return localizedStrings.fPublic; // 这里可以替换为翻译函数
    }
  }
}

class FormulationScalePage extends StatefulWidget {
  const FormulationScalePage({super.key});
  @override
  State<FormulationScalePage> createState() => FormulationScalePageState();
}

class FormulationScalePageState extends State<FormulationScalePage>
    with SingleTickerProviderStateMixin {
  // bool _showBottomSection = false;
  int _selectedTabIndex = 0;
  late TabController _tabController;
  bool sort = false;
  final ScrollController _scrollController =
      ScrollController(); // 添加 ScrollController

  Set<int> selectedRows = {};
  Set<int> selectedFmaRows = {};
  Set<int> selectedDarftRows = {}; // 添加选中行的集合
  bool selectAll = false; // 添加全选状态
  bool selectFmaAll = false; // 添加全选状态
  bool selectDraftFmaAll = false; // 添加全选状态
  int? clickedRow; // 添加点击行状态
  int? clickedFmaRow; // 添加点击行状态
  int? clickedDarftRow; // 添加点击行状态
  int? _selectedRawIndex; // 新增状态，用于记录当前被点击的原料 index
  int? _selectedFmaIndex; // 新增状态，用于记录当前被点击的配方 index
  // int? _selectedDarftIndex; // 新增状态，用于记录当前被点击的配方 index
  // 定义 FocusNode
  // final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchFmaIdCtl = TextEditingController();
  final TextEditingController searchFmaEncryptedCtl = TextEditingController();
  final TextEditingController isFmaEncryptedCtl = TextEditingController();
  final TextEditingController searchFmaTypeCtl = TextEditingController();
  final TextEditingController rawTypeCtl = TextEditingController();
  final TextEditingController _searchRawIdCtl = TextEditingController();
  final TextEditingController _searchDarftIdCtl = TextEditingController();

  FormulaInfoDb? selectedFormula; //选中的配方，用于展示原料列表
  Detail selectedDetail = Detail(); //配方中选中的原料

  int selScaleId = -1; //选择的秤ID
  List<FormulaInfoDb> rawFormulaList = []; //原料和配方的关系表
  // 存储搜索结果
  List<FormulaInfoDb> searchFmaList = [];
  // 存储搜索结果
  List<RawDataInfo> searchRawList = [];

  List<DarfFmaInfo> searchDarfFmaInfoList = []; //暂存的配方称重记录和配方明细
  DarfFmaInfo? selectedDarfFma; //选中的配方称重记录和配方明细

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;
  dynamic _eventbus10;
  dynamic _eventbus11;
  dynamic _eventbus12;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            rawTypeList = [];
          });
        }
      }
    });
    _eventbus2 = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            formulaTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            formulaTypeList = [];
          });
        }
      }
    });
    _eventbus3 = eventBus.on<EventRespGetRawDataList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            _selectedRawIndex = -1; // 重置选中的原料 index
            clickedRow = null; // 重置点击行状态
            rawFormulaList = [];

            rawDataList = rawDataInfoFromJson(dataStr);
            searchRawList = List.from(rawDataList);
          });
        } else {
          setState(() {
            _selectedRawIndex = -1; // 重置选中的原料 index
            clickedRow = null; // 重置点击行状态
            rawFormulaList = [];

            rawDataList = [];
            searchRawList = [];
          });
        }
      }
    });
    _eventbus4 = eventBus.on<EventRespAddRawData>().listen((event) {
      if (mounted) {
        PublicFunctions.getRawList();
        showTipInfo(localizedStrings.fSuccessMsg, context);
      }
    });
    _eventbus5 = eventBus.on<EventRespAddFormulaType>().listen((event) {
      if (mounted) {
        PublicFunctions.getFormulaTypeList();
      }
    });

    _eventbus6 = eventBus.on<EventRespFormulaList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            _selectedFmaIndex = -1; // 重置选中的原料 index
            selectedFormula = null; // 重置选中的配方
            selectedDetail.rawMaterialTypeName = null; // 重置选中的原料类型名称
            selectedDetail = Detail(); // 重置选中的原料
            clickedFmaRow = null; // 重置点击行状态

            formulaDataList = formulaInfoDbFromJson(dataStr);
            searchFmaList = List.from(formulaDataList);
          });
        } else {
          setState(() {
            _selectedFmaIndex = -1; // 重置选中的原料 index
            selectedFormula = null; // 重置选中的配方
            selectedDetail.rawMaterialTypeName = null; // 重置选中的原料类型名称
            selectedDetail = Detail(); // 重置选中的原料
            formulaDataList = [];
            searchFmaList = [];
            clickedFmaRow = null; // 重置点击行状态
          });
        }
      }
    });

    _eventbus7 = eventBus.on<EventRespAddFormula>().listen((event) {
      if (mounted) {
        PublicFunctions.getFormulaList();
      }
    });

    _eventbus8 = eventBus.on<EventRespFormulaRecList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          fmaRecFromDbList = fmaRecFromDbFromJson(dataStr);
        } else {
          fmaRecFromDbList = [];
        }
      }
    });
    _eventbus9 = eventBus.on<EventRespFormulaRecAdd>().listen((event) {
      if (mounted) {
        PublicFunctions.getFormulaRecList();
      }
    });

    _eventbus10 = eventBus.on<EventRespEditRawData>().listen((event) {
      if (mounted) {
        showTipInfo(localizedStrings.fSuccessMsg, context);
        PublicFunctions.getRawList();
        PublicFunctions.getFormulaList();
      }
    });

    _eventbus11 = eventBus.on<EventRespGetDraftFmaWgtRecList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          List<DarfFmaInfoListFromDb> darfFmaInfoListFromDbList =
              darfFmaInfoListFromDbFromJson(dataStr);
          darfFmaInfoList = []; //暂存的配方记录
          for (var item in darfFmaInfoListFromDbList) {
            //在fmaRecFromDbList中查找对应的配方
            DarfFmaInfo tempDarfFma = DarfFmaInfo();
            for (var fmaRec in formulaDataList) {
              if (fmaRec.header!.formulaHeader!.formulaId ==
                  item.header!.formulaId) {
                tempDarfFma.fmaRec = item;
                tempDarfFma.fmaInfo = fmaRec;
                break;
              }
            }

            darfFmaInfoList.add(tempDarfFma);
          }

          setState(() {
            searchDarfFmaInfoList = List.from(darfFmaInfoList);
            clickedDarftRow = null; // 重置点击行状态
            selectedDarfFma = null; // 重置选中的配方称重记录和配方明细
          });

          print(darfFmaInfoList.length);
        } else {
          setState(() {
            darfFmaInfoList = []; //暂存的配方记录
            searchDarfFmaInfoList = []; //暂存的配方记录
            clickedDarftRow = null; // 重置点击行状态
            selectedDarfFma = null; // 重置选中的配方称重记录和配方明细
          });
        }
      }
    });

    _eventbus12 = eventBus.on<EventRespDelDraftFmaWgtRecList>().listen((event) {
      if (mounted) {
        showTipInfo(localizedStrings.fSuccessMsg, context);

        PublicFunctions.getDraftRecords();
      }
    });

    //初始化完成再做一次数据加载

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 在这里调用数据加载的方法
      PublicFunctions.getRawTypeList();
      PublicFunctions.getFormulaTypeList();
      PublicFunctions.getRawList();

      Future.delayed(const Duration(milliseconds: 500), () {
        PublicFunctions.getFormulaList();
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        PublicFunctions.getFormulaRecList();
      });
      //等1秒再获取配方称重记录
      Future.delayed(const Duration(milliseconds: 2000), () {
        PublicFunctions.getDraftRecords();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _tabController.dispose();
    _searchFmaIdCtl.dispose();
    searchFmaEncryptedCtl.dispose();
    searchFmaTypeCtl.dispose();
    _searchRawIdCtl.dispose();
    rawTypeCtl.dispose();
    isFmaEncryptedCtl.dispose();

    _scrollController.dispose();

    rawTypeList.clear();
    formulaTypeList.clear();
    rawDataList.clear();
    formulaDataList.clear();
    fmaRecFromDbList.clear();
    darfFmaInfoList.clear();

    searchFmaList.clear();
    searchRawList.clear();
    searchDarfFmaInfoList.clear();

    selectedDetail = Detail(); // 重置选中的原料

    _eventbus1?.cancel();
    _eventbus2?.cancel();
    _eventbus3?.cancel();
    _eventbus4?.cancel();
    _eventbus5?.cancel();
    _eventbus6?.cancel();
    _eventbus7?.cancel();
    _eventbus8?.cancel();
    _eventbus9?.cancel();
    _eventbus10?.cancel();
    _eventbus11?.cancel();
    _eventbus12?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
            color: colorScheme.surfaceDim, //对接时修改颜色值

            child: Column(
              children: [
                pageHeadInfo(
                    context,
                    width - headWidthPadding,
                    localizedStrings.menuFormula,
                    localizedStrings.gTipFmaPageHelp),
                Container(
                  height: regularPadding,
                  color: colorScheme.surfaceDim,
                ),
                Expanded(
                  child: Row(
                    children: [
                      showScaleList(),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: [
                            showTabBar(),
                            Divider(
                              color: colorScheme.outline,
                              thickness: 1,
                              height: 1,
                            ),
                            if (_selectedTabIndex == 0) showFormulaSearch(),
                            if (_selectedTabIndex == 1) showRawSearch(),
                            if (_selectedTabIndex == 2) showDarftFmaSearch(),
                            // if (_selectedTabIndex == 2) showDarftFmaSearch(),
                            if (_selectedTabIndex == 0) showFormulaTable(),
                            if (_selectedTabIndex == 1) showRawTable(),
                            if (_selectedTabIndex == 2) showDarftFmaTable(),
                            SizedBox(height: 14),
                            // _showBottomSection
                            //     ?
                            if (_selectedTabIndex == 0) showFormulaBottom(),
                            if (_selectedTabIndex == 1) showRawBottom(),
                            if (_selectedTabIndex == 2) showDarftFmaBottom(),

                            Container(
                              height: 14,
                              color: colorScheme.surface,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )

            // ),
            ));
  }

  // 搜索方法
  void performFmaSearch() {
    final String keyword = _searchFmaIdCtl.text.trim();
    final String formulaTypeFilter = searchFmaTypeCtl.text.trim();
    final String encryptedFilter = searchFmaEncryptedCtl.text.trim();

    setState(() {
      searchFmaList = formulaDataList.where((formula) {
        final formulaId = formula.header!.formulaHeader!.formulaId!;
        final formulaName = formula.header!.formulaHeader!.formulaName!;
        return formulaId.contains(keyword) || formulaName.contains(keyword);
      }).where((element) {
        final formulaType = element.header!.formulaCategoryName!;
        final formulaEncrypted = element.header!.formulaHeader!.isEncrypted!;

        // 处理配方类别筛选
        bool typeMatch = formulaTypeFilter.isEmpty ||
            formulaType.contains(formulaTypeFilter);

        // 处理保密状态筛选
        bool encryptedMatch = true;
        if (encryptedFilter.isNotEmpty) {
          bool isEncrypted = encryptedFilter == localizedStrings.fConfidential;
          encryptedMatch = formulaEncrypted == isEncrypted;
        }

        return typeMatch && encryptedMatch;
      }).toList();
    });
  }

  // 搜索方法
  void performRawSearch() {
    final String keyword = _searchRawIdCtl.text.trim();
    final String rawTypeFilter = rawTypeCtl.text.trim();

    setState(() {
      searchRawList = rawDataList.where((raw) {
        final rawId = raw.rawMaterial.materialId;
        final rawName = raw.rawMaterial.materialName;
        return rawId.contains(keyword) || rawName.contains(keyword);
      }).where((element) {
        final rawType = element.rawCategoryName;

        // 处理配方类别筛选
        bool typeMatch =
            rawTypeFilter.isEmpty || rawType.contains(rawTypeFilter);

        return typeMatch;
      }).toList();
    });
  }

  // 切换全选状态
  void toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        selectedRows =
            Set<int>.from(List.generate(rawDataList.length, (index) => index));
      } else {
        selectedRows.clear();
      }
    });
  }

  // 切换选择状态
  void toggleSelection(int index) {
    setState(() {
      if (selectedRows.contains(index)) {
        selectedRows.remove(index);
      } else {
        selectedRows.add(index);
      }
    });
  }

  // 切换全选状态
  void toggleDarftFmaSelectAll(bool? value) {
    setState(() {
      selectDraftFmaAll = value ?? false;
      if (selectDraftFmaAll) {
        selectedDarftRows = Set<int>.from(
            List.generate(darfFmaInfoList.length, (index) => index));
      } else {
        selectedDarftRows.clear();
      }
    });
  }

  // 切换选择状态
  void toggleDarftFmaSelection(int index) {
    setState(() {
      if (selectedDarftRows.contains(index)) {
        selectedDarftRows.remove(index);
      } else {
        selectedDarftRows.add(index);
      }
    });
  }

  // 切换全选状态
  void toggleFmaSelectAll(bool? value) {
    setState(() {
      selectFmaAll = value ?? false;
      if (selectFmaAll) {
        selectedFmaRows = Set<int>.from(
            List.generate(formulaDataList.length, (index) => index));
      } else {
        selectedFmaRows.clear();
      }
    });
  }

  // 切换选择状态
  void toggleFmaSelection(int index) {
    setState(() {
      if (selectedFmaRows.contains(index)) {
        selectedFmaRows.remove(index);
      } else {
        selectedFmaRows.add(index);
      }
    });
  }

  //原料顺序部分
  showDarftRawOrder() {
    return Expanded(
      flex: 6,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          ShowRawTitleWidget(
            text: localizedStrings.fIngredientOrder,
          ),
          showDarftRawOrderDetail(),
        ]),
      ),
    );
  }

  //原料顺序部分
  showRawOrder() {
    return Expanded(
      flex: 6,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          ShowRawTitleWidget(
            text: localizedStrings.fIngredientOrder,
          ),
          showRawOrderDetail(),
        ]),
      ),
    );
  }

  Widget showDarftRawWgtAndUnit(int index, Color? textColor) {
    // ... existing code ...
    final formulaHeader = selectedDarfFma?.fmaInfo!.header?.formulaHeader;
    final formulaDetail =
        selectedDarfFma?.fmaInfo!.details?[index].formulaDetail;

    if (formulaHeader != null && formulaDetail != null) {
      final weight = formulaDetail.materialWeight;
      final unit = formulaHeader.formulaMode == "pct"
          ? pctStrShow
          : formulaHeader.formulaUnit;
      final displayText = '$weight $unit';

      return Text(
        displayText,
        style: TextStyle(
          color: textColor,
        ),
      );
    } else {
      // 处理数据为空的情况
      return Text(
        '',
        style: TextStyle(
          color: textColor,
        ),
      );
    }
  }

  Widget showRawWgtAndUnit(int index, Color? textColor) {
    // ... existing code ...
    final formulaHeader = selectedFormula?.header?.formulaHeader;
    final formulaDetail = selectedFormula?.details?[index].formulaDetail;

    if (formulaHeader != null && formulaDetail != null) {
      final weight = formulaDetail.materialWeight;
      final unit = formulaHeader.formulaMode == "pct"
          ? pctStrShow
          : formulaHeader.formulaUnit;
      final displayText = '$weight $unit';

      return Text(
        displayText,
        style: TextStyle(
          color: textColor,
        ),
      );
    } else {
      // 处理数据为空的情况
      return Text(
        '',
        style: TextStyle(
          color: textColor,
        ),
      );
    }
  }

  showDarftRawOrderDetail() {
    return Expanded(
      child: ListView.separated(
        // 修改 itemCount
        itemCount: selectedDarfFma?.fmaInfo!.details!.length ?? 0,
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedRawIndex = index; // 更新选中的 index
                selectedDetail = selectedDarfFma!.fmaInfo!.details![index];
              });
              // 这里添加点击事件的处理逻辑
              // print('点击了第 $index 项');
            },
            child: () {
              bool isSelected = _selectedRawIndex == index;
              Color backgroundColor = isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerLow;
              Color innerContainerColor =
                  isSelected ? colorScheme.primary : colorScheme.surface;
              Color textColor = isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant;
              Color numberTextColor = isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant;

              return Container(
                height: 32,
                color: backgroundColor,
                child: Row(children: [
                  SizedBox(
                    width: 2,
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    color: innerContainerColor,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: textTheme.bodySmall!.copyWith(
                          color: numberTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      // 修改显示内容
                      selectedDarfFma
                              ?.fmaInfo!
                              .details![index]
                              .rawMaterialTypeName!
                              .rawMaterial!
                              .materialName! ??
                          '',

                      style: textTheme.bodySmall!.copyWith(
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 修改显示内容
                  selectedDarfFma
                              ?.fmaInfo!.header!.formulaHeader!.isEncrypted ==
                          true
                      ? SizedBox()
                      : showDarftRawWgtAndUnit(index, textColor),
                  SizedBox(
                    width: 10,
                  ),
                ]),
              );
            }(),
          );
        },
      ),
    );
  }

  showRawOrderDetail() {
    return Expanded(
      child: ListView.separated(
        // 修改 itemCount
        itemCount: selectedFormula?.details!.length ?? 0,
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedRawIndex = index; // 更新选中的 index
                selectedDetail = selectedFormula!.details![index];
              });
              // 这里添加点击事件的处理逻辑
              // print('点击了第 $index 项');
            },
            child: () {
              bool isSelected = _selectedRawIndex == index;
              Color backgroundColor = isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerLow;
              Color innerContainerColor =
                  isSelected ? colorScheme.primary : colorScheme.surface;
              Color textColor = isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant;
              Color numberTextColor = isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant;

              return Container(
                height: 32,
                color: backgroundColor,
                child: Row(children: [
                  SizedBox(
                    width: 2,
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    color: innerContainerColor,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: textTheme.bodySmall!.copyWith(
                          color: numberTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      // 修改显示内容
                      selectedFormula?.details![index].rawMaterialTypeName!
                              .rawMaterial!.materialName! ??
                          '',

                      style: textTheme.bodySmall!.copyWith(
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 修改显示内容
                  selectedFormula?.header!.formulaHeader!.isEncrypted == true
                      ? SizedBox()
                      : showRawWgtAndUnit(index, textColor),
                  SizedBox(
                    width: 10,
                  ),
                ]),
              );
            }(),
          );
        },
      ),
    );
  }

  bool checkRawDelete(Object? data) {
    if (data == null || data is! RawDataInfo) {
      return false;
    }
    final targetMaterialId = data.rawMaterial.materialId;
    return formulaDataList.every((formula) {
      return formula.details?.every((detail) {
            return detail.rawMaterialTypeName!.rawMaterial!.materialId !=
                targetMaterialId;
          }) ??
          true;
    });
  }

  showRawTable() {
    return Expanded(
      flex: 8,
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        color: colorScheme.surface,
        child: StickyTable(
          controller: _scrollController, // 传递 ScrollController
          // data: List.generate(50, (index) => sort ? 50 - index : index),
          data: searchRawList.isEmpty
              ? []
              : sort
                  ? searchRawList.reversed.toList()
                  : searchRawList,
          defaultColumnWidth: const FixedColumnWidth(130),
          titleHeight: 48,
          cellHeight: 44,
          clickedRow: clickedRow,
          onRowClick: (row) {
            setState(() {
              clickedRow = row;
              //选择原料后，找出所有的配方
              rawFormulaList = [];
              for (var formula in formulaDataList) {
                for (var detail in formula.details!) {
                  if (detail.rawMaterialTypeName!.rawMaterial!.materialId ==
                      searchRawList[row].rawMaterial.materialId) {
                    rawFormulaList.add(formula);
                    break;
                  }
                }
              }
            });
          },

          cellDecoration: (context, column, data, row, columnIndex) {
            // 添加点击行背景色
            if (row == clickedRow) {
              return BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: colorScheme.primary, width: 1),
                ),
              );
            }
            return BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            );
          },
          columns: [
            StickyTableColumn(
              "",
              fixedStart: true,
              columnWidth: const FixedColumnWidth(80),
              renderTitle: (context, title) {
                // 添加全选复选框
                return Checkbox(value: selectAll, onChanged: toggleSelectAll);
              },
              renderCell: (context, title, data, row, column) {
                return Checkbox(
                  value: selectedRows.contains(row),
                  onChanged: (value) {
                    toggleSelection(row);
                  },
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fMaterialIdCol,
              fixedStart: true,
              showSort: true,
              sort: sort,
              columnWidth: const FixedColumnWidth(120),
              alignment: Alignment.centerLeft,
              onTitleClick: (context, title) {
                // setState(() {
                //   sort = !(title.sort ?? false);
                // });
              },
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                    (data as RawDataInfo).rawMaterial.materialId);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fMaterialNameCol,
              showSort: true,
              columnWidth: const FixedColumnWidth(300),
              alignment: Alignment.centerLeft,
              sort: false,
              renderCell: (context, title, data, row, column) {
                // 显示 materialId 字段
                return showRenderCellText(
                    (data as RawDataInfo).rawMaterial.materialName);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fRawMaterialTypeNameCol,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              columnWidth: const FixedColumnWidth(200),
              renderCell: (context, title, data, row, column) {
                // 显示 materialId 字段
                return showRenderCellText(
                    (data as RawDataInfo).rawCategoryName);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fCreatedAtCol,
              columnWidth: const FixedColumnWidth(200),
              showSort: true,
              alignment: Alignment.centerLeft,
              sort: false,
              renderCell: (context, title, data, row, column) {
                // 显示 createdAt 字段
                return showRenderCellText(
                  DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format((data as RawDataInfo).rawMaterial.createdAt),
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fUpdatedAtCol,
              columnWidth: const FixedColumnWidth(200),
              alignment: Alignment.centerLeft,
              showSort: true,
              sort: false,
              renderCell: (context, title, data, row, column) {
                // 显示 updatedAt 字段
                return showRenderCellText(DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format((data as RawDataInfo).rawMaterial.updatedAt));
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fIngredientRemark,
              alignment: Alignment.centerLeft,
              columnWidth: const FixedColumnWidth(400),
              showSort: true,
              sort: false,
              renderCell: (context, title, data, row, column) {
                // 显示 ingredient 字段
                return showRenderCellText(
                    (data as RawDataInfo).rawMaterial.ingredient);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fEditBtn,
              fixedEnd: true,
              columnWidth: const FixedColumnWidth(80),
              renderCell: (context, title, data, row, column) {
                return MaterialButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false, // 点击对话框外部不关闭对话框
                      builder: (BuildContext context) {
                        return EditRawDialog(
                          rawData: data as RawDataInfo, // 传递当前行的数据
                        );
                      },
                    ).then((value) {
                      // 对话框关闭后可以执行一些操作，比如刷新数据
                      setState(() {});
                    });
                  },
                  // color: Colors.red,
                  minWidth: 0,
                  child: Center(
                      child: Icon(
                    size: 20,
                    Icons.edit_outlined,
                    color: colorScheme.primary,
                  )),
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.gBtnDelete,
              fixedEnd: true,
              columnWidth: const FixedColumnWidth(80),
              renderCell: (context, title, data, row, column) {
                return MaterialButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    //需要先验证是否有配方使用才能删除。
                    bool res = checkRawDelete(data);
                    if (!res) {
                      showTipInfo(localizedStrings.fFormulaInUseDeleteErrorMsg,
                          context);
                      return;
                    }
                    showDialog(
                      context: context,
                      barrierDismissible: false, // 点击对话框外部不关闭对话框
                      builder: (BuildContext context) {
                        return ShowNormalTipDialog(
                          title: localizedStrings.fTipTitle,
                          msg: localizedStrings.fConfirmDelete,
                        );
                      },
                    ).then((value) {
                      if (value) {
                        PublicFunctions.deleteRawData(
                            (data as RawDataInfo).rawMaterial.recId);

                        setState(() {
                          selectAll = false;
                          selectedRows.clear();
                        });
                      } else {
                        return;
                      }
                    });
                  },
                  // color: Colors.red,
                  minWidth: 0,
                  child: Center(
                      child: Icon(
                    size: 20,
                    Icons.delete_forever_outlined,
                    color: colorScheme.error,
                  )),
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  showDarftFmaTable() {
    return Expanded(
      flex: 7,
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        color: colorScheme.surface,
        child: StickyTable(
          controller: _scrollController, // 传递 ScrollController
          // 修改 data 属性
          data: searchDarfFmaInfoList.isEmpty
              ? []
              : sort
                  ? searchDarfFmaInfoList.reversed.toList()
                  : searchDarfFmaInfoList,
          defaultColumnWidth: const FixedColumnWidth(130),
          titleHeight: 48,
          cellHeight: 44,
          clickedRow: clickedDarftRow,
          onRowClick: (row) {
            setState(() {
              clickedDarftRow = row;
              selectedDarfFma = searchDarfFmaInfoList[row];
              // if (selectedFormula!.details!.isEmpty) {
              //   selectedDetail = Detail();
              //   _selectedFmaIndex = -1;
              // } else {
              //   selectedDetail = selectedFormula!.details![0];
              //   _selectedFmaIndex = 0;
              // }
            });
          },

          cellDecoration: (context, column, data, row, columnIndex) {
            // 添加点击行背景色
            if (row == clickedDarftRow) {
              return BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: colorScheme.primary, width: 1),
                ),
              );
            }
            return BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            );
          },
          columns: [
            StickyTableColumn(
              "",
              fixedStart: true,
              columnWidth: const FixedColumnWidth(80),
              renderTitle: (context, title) {
                // 添加全选复选框
                return Checkbox(
                    value: selectDraftFmaAll,
                    onChanged: toggleDarftFmaSelectAll);
              },
              renderCell: (context, title, data, row, column) {
                return Checkbox(
                  value: selectedDarftRows.contains(row),
                  onChanged: (value) {
                    toggleDarftFmaSelection(row);
                  },
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fFmaIdLabel,
              fixedStart: true,
              showSort: true,
              sort: sort,
              columnWidth: const FixedColumnWidth(150),
              alignment: Alignment.centerLeft,
              onTitleClick: (context, title) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText((data as DarfFmaInfo)
                    .fmaInfo!
                    .header!
                    .formulaHeader!
                    .formulaId!);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fFmaNameLabel,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              columnWidth: const FixedColumnWidth(200),
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                  (data as DarfFmaInfo)
                      .fmaInfo!
                      .header!
                      .formulaHeader!
                      .formulaName!,
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fOrderNo,
              showSort: true,
              sort: false,
              columnWidth: FixedColumnWidth(200),
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                    (data as DarfFmaInfo).fmaRec!.header!.orderId!);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            // StickyTableColumn(
            //   localizedStrings.fFmaCategoryCol,
            //   showSort: true,
            //   sort: false,
            //   alignment: Alignment.centerLeft,
            //   onCellClick: (context, title, data, row, column) {},
            //   // 修改 renderCell 方法
            //   renderCell: (context, title, data, row, column) {
            //     return Text(
            //         (data as DarfFmaInfo).fmaInfo!.header!.formulaCategoryName!,
            //         style: textTheme.bodySmall!.copyWith(
            //               color: colorScheme.onSurfaceVariant,
            //             ));
            //   },
            //   renderTitle: (context, title) {
            //     return Text(
            //       title.title,
            //       style: textTheme.bodySmall!.copyWith(
            //             color: colorScheme.onSurface,
            //           ),
            //     );
            //   },
            // ),
            StickyTableColumn(
              localizedStrings.fConfidential,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                  (data as DarfFmaInfo)
                          .fmaInfo!
                          .header!
                          .formulaHeader!
                          .isEncrypted!
                      ? localizedStrings.fConfidential
                      : localizedStrings.fPublic,
                  color: data.fmaInfo!.header!.formulaHeader!.isEncrypted!
                      ? colorScheme.error
                      : colorScheme.onTertiaryFixedVariant,
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fFmaModeCol,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                  (data as DarfFmaInfo)
                              .fmaInfo!
                              .header!
                              .formulaHeader!
                              .formulaMode! ==
                          'pct'
                      ? localizedStrings.fPctMode
                      : localizedStrings.fWeightMode,
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fIngredientCountLabel,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {
                // ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText((data as DarfFmaInfo)
                    .fmaInfo!
                    .header!
                    .formulaHeader!
                    .materialCount!
                    .toString());
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),

            StickyTableColumn(
              localizedStrings.fCreatedAtCol,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              columnWidth: FixedColumnWidth(200),
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format((data as DarfFmaInfo).fmaRec!.header!.createdAt!));
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),

            StickyTableColumn(
              localizedStrings.fRemarkCol,
              showSort: true,
              sort: false,
              columnWidth: const FixedColumnWidth(500),
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                  (data as DarfFmaInfo).fmaInfo!.header!.formulaHeader!.remark!,
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.gBtnDelete,
              fixedEnd: true,
              columnWidth: const FixedColumnWidth(80),
              renderCell: (context, title, data, row, column) {
                return MaterialButton(
                  onPressed: () {
                    //删除之前先询问是否确定删除
                    showDialog(
                      context: context,
                      barrierDismissible: false, // 点击对话框外部不关闭对话框
                      builder: (BuildContext context) {
                        return ShowNormalTipDialog(
                          title: localizedStrings.fTipTitle,
                          msg: localizedStrings.fConfirmDelete,
                        );
                      },
                    ).then((value) {
                      if (value) {
                        PublicFunctions.deleteDraftRecord(
                            (data as DarfFmaInfo).fmaRec!.header!.orderId!);
                        setState(() {
                          selectedDarftRows.clear();
                          selectDraftFmaAll = false;
                        });
                      } else {
                        return;
                      }
                    });
                  },
                  // color: Colors.red,
                  minWidth: 0,
                  child: Center(
                      child: Icon(
                    size: 20,
                    Icons.delete_forever_outlined,
                    color: colorScheme.error,
                  )),
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  showFormulaTable() {
    return Expanded(
      flex: 7,
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        color: colorScheme.surface,
        child: StickyTable(
          controller: _scrollController, // 传递 ScrollController
          // 修改 data 属性
          data: searchFmaList.isEmpty
              ? []
              : sort
                  ? searchFmaList.reversed.toList()
                  : searchFmaList,
          defaultColumnWidth: const FixedColumnWidth(130),
          titleHeight: 48,
          cellHeight: 44,
          clickedRow: clickedFmaRow,
          onRowClick: (row) {
            setState(() {
              clickedFmaRow = row;
              selectedFormula = searchFmaList[row];
              if (selectedFormula!.details!.isEmpty) {
                selectedDetail = Detail();
                _selectedFmaIndex = -1;
              } else {
                selectedDetail = selectedFormula!.details![0];
                _selectedFmaIndex = 0;
              }
            });
          },

          cellDecoration: (context, column, data, row, columnIndex) {
            // 添加点击行背景色
            if (row == clickedFmaRow) {
              return BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: colorScheme.primary, width: 1),
                ),
              );
            }
            return BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            );
          },
          columns: [
            StickyTableColumn(
              "",
              fixedStart: true,
              columnWidth: const FixedColumnWidth(80),
              renderTitle: (context, title) {
                // 添加全选复选框
                return Checkbox(
                    value: selectFmaAll, onChanged: toggleFmaSelectAll);
              },
              renderCell: (context, title, data, row, column) {
                return Checkbox(
                  value: selectedFmaRows.contains(row),
                  onChanged: (value) {
                    toggleFmaSelection(row);
                  },
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fFmaIdLabel,
              fixedStart: true,
              showSort: true,
              sort: sort,
              columnWidth: const FixedColumnWidth(80),
              alignment: Alignment.centerLeft,
              onTitleClick: (context, title) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                  (data as FormulaInfoDb).header!.formulaHeader!.formulaId!,
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fFmaNameLabel,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText((data as FormulaInfoDb)
                    .header!
                    .formulaHeader!
                    .formulaName!);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fFmaCategoryCol,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                    (data as FormulaInfoDb).header!.formulaCategoryName!);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fConfidential,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                  (data as FormulaInfoDb).header!.formulaHeader!.isEncrypted!
                      ? localizedStrings.fConfidential
                      : localizedStrings.fPublic,
                  color: data.header!.formulaHeader!.isEncrypted!
                      ? colorScheme.error
                      : colorScheme.onTertiaryFixedVariant,
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fFmaModeCol,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText((data as FormulaInfoDb)
                            .header!
                            .formulaHeader!
                            .formulaMode! ==
                        'pct'
                    ? localizedStrings.fPctMode
                    : localizedStrings.fWeightMode);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fIngredientCountLabel,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {
                // ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText((data as FormulaInfoDb)
                    .header!
                    .formulaHeader!
                    .materialCount!
                    .toString());
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fCreatedAtCol,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              columnWidth: FixedColumnWidth(200),
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format((data as FormulaInfoDb)
                        .header!
                        .formulaHeader!
                        .createdAt!));
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fUpdatedAtCol,
              showSort: true,
              sort: false,
              alignment: Alignment.centerLeft,
              columnWidth: FixedColumnWidth(200),
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format((data as FormulaInfoDb)
                        .header!
                        .formulaHeader!
                        .updatedAt!));
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fRemarkCol,
              showSort: true,
              sort: false,
              columnWidth: const FixedColumnWidth(500),
              alignment: Alignment.centerLeft,
              onCellClick: (context, title, data, row, column) {},
              // 修改 renderCell 方法
              renderCell: (context, title, data, row, column) {
                return showRenderCellText(
                    (data as FormulaInfoDb).header!.formulaHeader!.remark!);
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fHistoricalWeighingRecordsBtn,
              fixedEnd: true,
              columnWidth: const FixedColumnWidth(80),
              renderCell: (context, title, data, row, column) {
                return MaterialButton(
                  onPressed: () {
                    //检查该配方是否有历史称量记录

                    final formulaKey = (data as FormulaInfoDb)
                        .header!
                        .formulaHeader!
                        .formulaKey!;

                    // final formulaName =
                    //     (data).header!.formulaHeader!.formulaName!;

                    final hasHistory = fmaRecFromDbList.any(
                        (record) => record.header?.formulaKey == formulaKey);

                    if (!hasHistory) {
                      showTipInfo(localizedStrings.fNoRecordTip, context);
                      return;
                    } else {
                      //有历史记录，找出所有的该配方的历史记录列表，跳转到历史记录页面
                      final List<FmaRecFromDb> formulaHistoryRecords =
                          fmaRecFromDbList
                              .where((record) =>
                                  record.header?.formulaKey == formulaKey)
                              .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OneFmaWgtRecPage(
                            oneFmaRecList: formulaHistoryRecords,
                          ),
                        ),
                      );
                    }
                  },
                  // color: Colors.red,
                  minWidth: 0,
                  child: Center(
                      child: Icon(Icons.receipt_long_sharp,
                          size: 20, color: colorScheme.primary)),
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.fEditBtn,
              fixedEnd: true,
              columnWidth: const FixedColumnWidth(80),
              renderCell: (context, title, data, row, column) {
                return MaterialButton(
                  onPressed: () {
                    FormulaInfoDb? editFormulaInfo = searchFmaList[row];
                    //先查看暂存的配方是否有未保存的草稿
                    bool existDraft = false;
                    for (var fma in darfFmaInfoList) {
                      if (fma.fmaInfo!.header!.formulaHeader!.formulaId ==
                          editFormulaInfo.header!.formulaHeader!.formulaId) {
                        existDraft = true;
                        break;
                      }
                    }

                    if (existDraft) {
                      //跳转到编辑草稿页面，限制编辑条件
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditDarftFmaPage(
                                    editFormulaInfo: editFormulaInfo,
                                  ))).then((value) {
                        setState(() {});
                      });
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditFormulaPage(
                                    editFormulaInfo: editFormulaInfo,
                                  ))).then((value) {
                        setState(() {});
                      });
                    }
                  },
                  // color: Colors.red,
                  minWidth: 0,
                  child: Center(
                      child: Icon(
                    size: 20,
                    Icons.edit_outlined,
                    color: colorScheme.primary,
                  )),
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
            StickyTableColumn(
              localizedStrings.gBtnDelete,
              fixedEnd: true,
              columnWidth: const FixedColumnWidth(80),
              renderCell: (context, title, data, row, column) {
                return MaterialButton(
                  onPressed: () {
                    //删除之前先询问是否确定删除
                    //延迟2秒
                    Future.delayed(const Duration(seconds: 1), () {
                      for (var fma in darfFmaInfoList) {
                        if (fma.fmaInfo!.header!.formulaHeader!.formulaId ==
                            (data as FormulaInfoDb)
                                .header!
                                .formulaHeader!
                                .formulaId) {
                          showTipInfo(
                              localizedStrings.formulaDeleteError, context);

                          return;
                        }
                      }
                      showDialog(
                        context: context,
                        barrierDismissible: false, // 点击对话框外部不关闭对话框
                        builder: (BuildContext context) {
                          return ShowNormalTipDialog(
                            title: localizedStrings.fTipTitle,
                            msg: localizedStrings.fConfirmDelete,
                          );
                        },
                      ).then((value) {
                        if (value) {
                          //需要先验证是否有配方使用才能删除。

                          PublicFunctions.deleteFormulaData(
                              (data as FormulaInfoDb)
                                  .header!
                                  .formulaHeader!
                                  .recId!);
                          setState(() {
                            selectedFmaRows.clear();
                            selectFmaAll = false;
                          });
                          if (mounted) {
                            showTipInfo(
                                localizedStrings.fDeleteSuccessMsg, context);
                          }
                        } else {
                          return;
                        }
                      });
                    });
                  },
                  // color: Colors.red,
                  minWidth: 0,
                  child: Center(
                      child: Icon(
                    size: 20,
                    Icons.delete_forever_outlined,
                    color: colorScheme.error,
                  )),
                );
              },
              renderTitle: (context, title) {
                return showRenderTitleText(
                  title.title,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  showFormulaBottom() {
    return Expanded(
      flex: 4,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Container(
              height: 48,
              color: colorScheme.surface,
              child: Row(children: [
                const SizedBox(
                  width: 20,
                ),
                Text(
                  localizedStrings.fFmaNameLabel + "：",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方名称内容
                Expanded(
                  flex: 3,
                  child: Text(
                    selectedFormula?.header?.formulaHeader?.formulaName ?? "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // 显示配方编号标签
                Text(
                  localizedStrings.fFmaIdLabel + ": ",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedFormula?.header?.formulaHeader?.formulaId ?? "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(
                  localizedStrings.fIngredientCountLabel + ": ",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedFormula?.header?.formulaHeader?.materialCount
                            .toString() ??
                        "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                selectedFormula?.header?.formulaHeader?.formulaMode != "pct"
                    ? Text(
                        "  ${localizedStrings.fTotalWeightLabel}: ",
                        style: getTextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )
                    : SizedBox(),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedFormula?.header?.formulaHeader?.formulaMode == "pct"
                        ? ""
                        : selectedFormula?.header?.formulaHeader?.totalWeight !=
                                    null &&
                                selectedFormula
                                        ?.header?.formulaHeader?.formulaUnit !=
                                    null
                            ? " ${selectedFormula!.header!.formulaHeader!.totalWeight} ${selectedFormula!.header!.formulaHeader!.formulaUnit}"
                            : " ",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 200,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.onTertiaryFixedVariant,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                      ),
                    ),
                    onPressed: (selectedFormula == null || selScaleId == -1)
                        ? null
                        : () {
                            startWeighting();
                          },
                    child: Text(
                      localizedStrings.fStartWeighingBtn,
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ])),
          Divider(
            color: colorScheme.outline,
            thickness: 1,
            height: 1,
          ),
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: 17,
              ),
              showRawOrder(),
              SizedBox(
                width: 16,
              ),
              Expanded(
                flex: 11,
                child: Column(children: [
                  ShowRawTitleWidget(
                    text: localizedStrings.fIngredientRemark,
                  ),
                  RawRemarkTextWidget(
                    text: selectedDetail.rawMaterialTypeName == null
                        ? ""
                        : selectedDetail
                            .rawMaterialTypeName!.rawMaterial!.ingredient!,
                  )
                ]),
              ),
              SizedBox(
                width: 26,
              ),
              VerticalDivider(
                color: colorScheme.outline,
                width: 1,
              ),
              SizedBox(
                width: 26,
              ),
              Expanded(
                flex: 9,
                child: Column(children: [
                  ShowRawTitleWidget(
                    text: localizedStrings.fFmaRemark,
                  ),
                  RawRemarkTextWidget(
                    text: selectedFormula?.header?.formulaHeader?.remark ?? "",
                  )
                ]),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ))
        ]),
      ),
    );
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  TextStyle getTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodySmall!.apply(
      color: color,
    );
  }

  TextStyle getTitleTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodyMedium!.apply(
      color: color,
    );
  }

  showRenderCellText(String context, {Color? color}) {
    color ??= colorScheme.onSurfaceVariant;
    return Text(context,
        style: getTextStyle(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }

  showRenderTitleText(String title) {
    return Text(title,
        style: getTextStyle(color: colorScheme.onSurface),
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }

  showDarftFmaBottom() {
    return Expanded(
      flex: 4,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Container(
              height: 48,
              color: colorScheme.surface,
              child: Row(children: [
                const SizedBox(
                  width: 20,
                ),
                Text(
                  localizedStrings.fFmaNameLabel + "：",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方名称内容
                Expanded(
                  flex: 3,
                  child: Text(
                    selectedDarfFma
                            ?.fmaInfo!.header!.formulaHeader?.formulaName ??
                        "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // 显示配方编号标签
                Text(
                  localizedStrings.fFmaIdLabel + ": ",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedDarfFma
                            ?.fmaInfo!.header!.formulaHeader?.formulaId ??
                        "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(
                  localizedStrings.fIngredientCountLabel + ": ",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedDarfFma
                            ?.fmaInfo!.header!.formulaHeader?.materialCount
                            .toString() ??
                        "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                selectedDarfFma?.fmaInfo!.header!.formulaHeader?.formulaMode !=
                        "pct"
                    ? Text(
                        "  ${localizedStrings.fTotalWeightLabel}: ",
                        style: getTextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )
                    : SizedBox(),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedDarfFma
                                ?.fmaInfo!.header!.formulaHeader?.formulaMode ==
                            "pct"
                        ? ""
                        : selectedDarfFma?.fmaInfo!.header!.formulaHeader
                                        ?.totalWeight !=
                                    null &&
                                selectedDarfFma?.fmaInfo!.header!.formulaHeader
                                        ?.formulaUnit !=
                                    null
                            ? " ${selectedDarfFma!.fmaInfo!.header!.formulaHeader!.totalWeight} ${selectedDarfFma!.fmaInfo!.header!.formulaHeader!.formulaUnit}"
                            : " ",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 200,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.onTertiaryFixedVariant,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                      ),
                    ),
                    onPressed: (selectedDarfFma == null || selScaleId == -1)
                        ? null
                        : () {
                            startDarftWeighting();
                          },
                    child: Text(
                      localizedStrings.btnContinueWeighing,
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ])),
          Divider(
            color: colorScheme.outline,
            thickness: 1,
            height: 1,
          ),
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: 17,
              ),
              showDarftRawOrder(),
              SizedBox(
                width: 16,
              ),
              Expanded(
                flex: 11,
                child: Column(children: [
                  ShowRawTitleWidget(
                    text: localizedStrings.fIngredientRemark,
                  ),
                  RawRemarkTextWidget(
                    text: selectedDetail.rawMaterialTypeName == null
                        ? ""
                        : selectedDetail
                            .rawMaterialTypeName!.rawMaterial!.ingredient!,
                  )
                ]),
              ),
              SizedBox(
                width: 26,
              ),
              VerticalDivider(
                color: colorScheme.outline,
                width: 1,
              ),
              SizedBox(
                width: 26,
              ),
              Expanded(
                flex: 9,
                child: Column(children: [
                  ShowRawTitleWidget(
                    text: localizedStrings.fFmaRemark,
                  ),
                  RawRemarkTextWidget(
                    text: selectedDarfFma
                            ?.fmaInfo!.header!.formulaHeader?.remark ??
                        "",
                  )
                ]),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ))
        ]),
      ),
    );
  }

  void startWeighting() {
    //检查配方是保密的，还是公开的
    if (selectedFormula == null) {
      return;
    }
    if (selectedFormula?.header?.formulaHeader?.isEncrypted == false) {
      //检查配方是重量模式还是百分比模式
      if (selectedFormula?.header?.formulaHeader?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            // 先判断这个总重是个数
            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulaPctWeighingPage(
                    selectFormula: selectedFormula!,
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDarft: false,
                  ),
                ),
              );
            }
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormulaPctWeighingPage(
              selectFormula: selectedFormula!,
              selScaleId: selScaleId,
              totalFmaWgt: selectedFormula!.header!.formulaHeader!.totalWeight!,
              fmaUnit: selectedFormula!.header!.formulaHeader!.formulaUnit!,
              fromDarft: false,
            ),
          ),
        );
      }
    } else {
      //检查配方是重量模式还是百分比模式
      if (selectedFormula?.header?.formulaHeader?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            // 先判断这个总重是个数
            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulaSecretWeighingPage(
                    selectFormula: selectedFormula!,
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDraft: false,
                    selectDarftInfo: null // 这里传入null，因为不是草稿配方称重，所以不需要草稿信息
                    ,
                  ),
                ),
              );
            }
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormulaSecretWeighingPage(
                selectFormula: selectedFormula!,
                selScaleId: selScaleId,
                totalFmaWgt:
                    selectedFormula!.header!.formulaHeader!.totalWeight!,
                fmaUnit: selectedFormula!.header!.formulaHeader!.formulaUnit!,
                fromDraft: false,
                selectDarftInfo: null // 这里传入null，因为不是草稿配方称重，所以不需要草稿信息
                ),
          ),
        );
      }
    }
  }

  void startDarftWeighting() {
    //检查配方是保密的，还是公开的
    if (selectedDarfFma == null) {
      return;
    }
    if (selectedDarfFma?.fmaInfo?.header?.formulaHeader?.isEncrypted == false) {
      //检查配方是重量模式还是百分比模式
      if (selectedDarfFma?.fmaInfo?.header?.formulaHeader?.formulaMode ==
          "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            // 先判断这个总重是个数
            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DarftFmaPctWgtPage(
                    selectFormula: selectedDarfFma!.fmaInfo!,
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDarft: false,
                    selectDarftInfo: selectedDarfFma!.fmaRec,
                  ),
                ),
              );
            }
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DarftFmaPctWgtPage(
              selectFormula: selectedDarfFma!.fmaInfo!,
              selScaleId: selScaleId,
              totalFmaWgt:
                  selectedDarfFma!.fmaInfo!.header!.formulaHeader!.totalWeight!,
              fmaUnit:
                  selectedDarfFma!.fmaInfo!.header!.formulaHeader!.formulaUnit!,
              fromDarft: false,
              selectDarftInfo: selectedDarfFma!.fmaRec,
            ),
          ),
        );
      }
    } else {
      //检查配方是重量模式还是百分比模式
      if (selectedDarfFma?.fmaInfo?.header?.formulaHeader?.formulaMode ==
          "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            // 先判断这个总重是个数
            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulaSecretWeighingPage(
                    selectFormula: selectedDarfFma!.fmaInfo!,
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDraft: true,
                    selectDarftInfo: selectedDarfFma!.fmaRec,
                  ),
                ),
              );
            }
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormulaSecretWeighingPage(
              selectFormula: selectedDarfFma!.fmaInfo!,
              selScaleId: selScaleId,
              totalFmaWgt:
                  selectedDarfFma!.fmaInfo!.header!.formulaHeader!.totalWeight!,
              fmaUnit:
                  selectedDarfFma!.fmaInfo!.header!.formulaHeader!.formulaUnit!,
              fromDraft: true,
              selectDarftInfo: selectedDarfFma!.fmaRec,
            ),
          ),
        );
      }
    }
  }

//原料列表底部
  showRawBottom() {
    return Expanded(
      flex: 2,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: 17,
              ),
              Expanded(
                flex: 11,
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 3,
                      height: 14,
                      color: colorScheme.onSurface,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: ShowRawTitleWidget(
                        text: localizedStrings.fInvolvedFmas,
                      ),
                    )
                  ]),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 30,
                          runSpacing: 10,
                          children: [
                            // 遍历 rawFormulaList 展示配方名字并添加点击功能
                            for (var formula in rawFormulaList)
                              InkWell(
                                onTap: () {
                                  //跳出配方详情
                                  if (selScaleId == -1) {
                                    showTipInfo(
                                        localizedStrings.gTipSelectDeviceFirst,
                                        context);
                                    return;
                                  }

                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ShowFormulaDetailDialog(
                                          selectFormula: formula,
                                          selectScaleId: selScaleId,
                                        );
                                      }).then((value) {
                                    if (value) {
                                      selectedFormula = formula;

                                      startWeighting();
                                    }
                                  });
                                },
                                child: IntrinsicWidth(
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    height: 40,
                                    constraints: BoxConstraints(
                                      maxWidth: 300,
                                      minWidth: 100,
                                    ),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    child: Center(
                                      child: Text(
                                        formula.header?.formulaHeader
                                                ?.formulaName ??
                                            "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                ]),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ))
        ]),
      ),
    );
  }

  showScaleList() {
    return AnimatedContainer(
      color: colorScheme.surface,
      width: 234,
      duration: Duration(milliseconds: 300),
      child: Column(
        children: [
          SizedBox(height: regularPadding),
          Expanded(
            child: NewAllScaleListWidget(
              listWidth: scaleListWidth, // 列表宽度
              selScaleId: selScaleId,
              clickScale: (scale) {
                setState(() {
                  selScaleId = scale.scaleId;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  showTabBar() {
    return Container(
      height: 54,
      color: colorScheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                  if (index == 2) {
                    PublicFunctions.getDraftRecords();
                  }
                });
              },
              // 自定义 indicator 样式，添加分隔线
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: localizedStrings.fFmaListTab),
                Tab(text: localizedStrings.fRawMaterialListTab),
                Tab(text: localizedStrings.tipTemporarySaveFormulaRecord),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showAddRawInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AddRawDialog();
      },
    ).then((value) {
      setState(() {});
    });
  }

  showRawSearch() {
    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        SizedBox(
          width: 20,
        ),
        SizedBox(
            width: 260,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                style: textTheme.bodySmall!.copyWith(
                  color: colorScheme.onSurface,
                ),
                controller: _searchRawIdCtl,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.clear,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchRawIdCtl.clear();
                        performRawSearch(); // 调用搜索方法
                      });
                    },
                  ),
                  hintText: localizedStrings.fSearchHint,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  hintStyle: textTheme.bodySmall!.copyWith(
                    // 设置提示文本样式
                    fontSize: 12,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    performRawSearch();
                  });
                },
              ),
            )),
        SizedBox(
          width: 14,
        ),
        Container(
            width: 260,
            height: 40,
            padding: const EdgeInsets.only(left: 16, right: 20),
            decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: colorScheme.outline,
                  width: 1,
                )),
            child: DropdownButton(
                underline: SizedBox(),
                isExpanded: true,
                value: rawTypeCtl.text == "" ? null : rawTypeCtl.text,
                items: rawTypeList.isEmpty
                    ? [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            localizedStrings.fPleaseSelectCategory,
                            style: textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ]
                    : [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            localizedStrings.fPleaseSelectCategory,
                            style: textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...rawTypeList.map((CategoryTypeList item) {
                          return DropdownMenuItem<String>(
                            value: item.categoryName,
                            child: Text(
                              item.categoryName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                      ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    rawTypeCtl.text = value.toString();
                    performRawSearch();
                  });
                },
                style: textTheme.bodySmall!.copyWith(
                  // 设置提示文本样式

                  color: colorScheme.onSurface,
                ))),
        SizedBox(
          width: 14,
        ),
        Tooltip(
            message: localizedStrings.fClearSearchConditionBtn, // 提示信息
            child: IconButton(
              icon: Icon(
                Icons.cleaning_services_outlined,
                color: colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _searchRawIdCtl.clear();
                  rawTypeCtl.clear();
                  performRawSearch(); // 调用搜索方法
                });
              },
              iconSize: 24,
            )),
        Spacer(),
        //新增原料按钮
        IconButton(
          iconSize: 24,
          color: colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              // 设置为矩形形状
              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
            ),
            fixedSize: const Size(40, 40), // 设置固定大小
          ),
          onPressed: () {
            showAddRawInfoDialog();
          },
          icon: Icon(Icons.add_box_outlined),
        ),
        SizedBox(
          width: 12,
        ),

        IconButton(
          iconSize: 24,
          color: colorScheme.onPrimary,
          focusColor: colorScheme.outline,
          hoverColor: colorScheme.outline,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              // 设置为矩形形状
              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
            ),
            fixedSize: const Size(40, 40), // 设置固定大小
          ),
          onPressed: () {
            exportRaw();
          },
          icon: Icon(
            Icons.file_upload_outlined,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ]),
    );
  }

  showAddFormulaIconBtn(String tip, IconData icon, Function() onPressed) {
    return Tooltip(
        message: tip, // 提示信息
        child: IconButton(
          iconSize: 24,
          color: colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              // 设置为矩形形状
              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
            ),
            fixedSize: const Size(40, 40), // 设置固定大小
          ),
          onPressed: onPressed,
          icon: Icon(icon),
        ));
  }

  showIconButton(String tip, IconData icon, Function() onPressed) {
    return Tooltip(
      message: tip, // 提示信息
      child: IconButton(
        iconSize: 24,
        color: colorScheme.onPrimary,
        focusColor: colorScheme.outline,
        hoverColor: colorScheme.outline,
        style: IconButton.styleFrom(
          backgroundColor: Color(0xFFF3F3F3),
          shape: RoundedRectangleBorder(
            // 设置为矩形形状
            borderRadius: BorderRadius.zero, // 没有圆角，即正方形
          ),
          fixedSize: const Size(40, 40), // 设置固定大小
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  //导出原料的json文件，只要导出勾选的原料
  exportRaw() async {
    if (selectedRows.isEmpty) {
      showTipInfo(localizedStrings.gTipNoDataSelected, context);
      return;
    }
    List<RawDataInfo> exportRawList = [];
    for (var row in selectedRows) {
      exportRawList.add(searchRawList[row]);
    }
    String jsonString = rawDataInfoToJson(exportRawList);

    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["json"],
      fileName: 'components.json',
    ));
    if (outputFile != null) {
      if (!outputFile.contains(".json")) {
        outputFile = "$outputFile.json";
      }
      String filePath = outputFile;

      // 将 CSV 数据写入文件
      try {
        // 尝试将数据转换为 CSV 格式
        String csv = jsonString;
        File file = File(filePath);
        await file.writeAsString(csv);
        // 显示导出成功提示
        if (mounted) {
          showTipInfo(localizedStrings.fSaveSuccess, context);
        }
      } catch (e) {
        // 处理写入文件时可能出现的异常，并显示错误提示
        if (mounted) {
          showTipInfo('$e', context);
        }
      }
    }
  }

//导出配方的json文件，只要导出勾选的配方
  exportFormula() async {
    if (selectedFmaRows.isEmpty) {
      showTipInfo(localizedStrings.gTipNoDataSelected, context);
      return;
    }
    List<FormulaInfoDb> exportFormulaList = [];
    for (var row in selectedFmaRows) {
      exportFormulaList.add(searchFmaList[row]);
    }
    String jsonString = formulaInfoDbToJson(exportFormulaList);

    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["json"],
      fileName: 'formulas.json',
    ));
    if (outputFile != null) {
      if (!outputFile.contains(".json")) {
        outputFile = "$outputFile.json";
      }
      String filePath = outputFile;

      // 将 CSV 数据写入文件
      try {
        // 尝试将数据转换为 CSV 格式
        String csv = jsonString;
        File file = File(filePath);
        await file.writeAsString(csv);
        // 显示导出成功提示
        if (mounted) {
          showTipInfo(localizedStrings.fSaveSuccess, context);
        }
      } catch (e) {
        // 处理写入文件时可能出现的异常，并显示错误提示
        if (mounted) {
          showTipInfo('$e', context);
        }
      }
    }
  }

  showFormulaSearch() {
    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        SizedBox(
          width: 20,
        ),
        SizedBox(
            width: 245,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  controller: _searchFmaIdCtl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchFmaIdCtl.clear();
                          performFmaSearch();
                        });
                      },
                    ),
                    hintText: localizedStrings.fSearchHint,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintStyle: textTheme.bodySmall!.copyWith(
                      // 设置提示文本样式
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // 这里可以添加搜索逻辑
                      performFmaSearch();
                    });
                  }),
            )),
        SizedBox(
          width: 14,
        ),
        Container(
          width: 245,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              )),
          child: DropdownButton(
            underline: SizedBox(),
            isExpanded: true,
            value: searchFmaTypeCtl.text == "" ? null : searchFmaTypeCtl.text,
            items: formulaTypeList.isEmpty
                ? [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        localizedStrings.fPleaseSelectCategory,
                        style: textTheme.bodySmall!.copyWith(
                          // 设置提示文本样式
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                    )
                  ]
                : [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(localizedStrings.fPleaseSelectCategory,
                          style: textTheme.bodySmall!.copyWith(
                            // 设置提示文本样式
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          )),
                    ),
                    ...formulaTypeList.map((CategoryTypeList item) {
                      return DropdownMenuItem<String>(
                        value: item.categoryName,
                        child: Text(
                          item.categoryName,
                          style: textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      );
                    })
                  ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                searchFmaTypeCtl.text = value.toString();
                performFmaSearch();
              });
            },
            style: textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          width: 14,
        ),
        Container(
          width: 245,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              )),
          child: DropdownButton<EncryptedValue>(
            underline: SizedBox(),
            isExpanded: true,
            value: searchFmaEncryptedCtl.text == ""
                ? null
                : EncryptedValue.values.firstWhere((element) =>
                    element.getTranslation(context) ==
                    searchFmaEncryptedCtl.text),
            // 修改 items 部分，添加空状态提示
            items: [
              DropdownMenuItem<EncryptedValue>(
                value: null,
                child: Text(localizedStrings.fSelectConfidentialityStatusMsg,
                    style: textTheme.bodySmall!.copyWith(
                      // 设置提示文本样式
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    )),
              ),
              ...EncryptedValue.values.map((value) {
                return DropdownMenuItem<EncryptedValue>(
                  value: value,
                  child: Text(
                    value.getTranslation(context),
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }),
            ],

            onChanged: (value) {
              if (value == null) return;
              setState(() {
                searchFmaEncryptedCtl.text = value.getTranslation(context);
                isFmaEncryptedCtl.text = value.toString();
                performFmaSearch();
              });
            },

            style: textTheme.bodySmall!.copyWith(
              // 设置提示文本样式

              color: colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          width: 14,
        ),
        Tooltip(
            message: localizedStrings.fClearSearchConditionBtn, // 提示信息
            child: IconButton(
              icon: Icon(
                Icons.cleaning_services_outlined,
                color: colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _searchFmaIdCtl.clear();
                  searchFmaTypeCtl.clear();
                  searchFmaEncryptedCtl.clear();
                  isFmaEncryptedCtl.clear();
                  performFmaSearch(); // 调用搜索方法
                });
              },
              iconSize: 24,
            )),
        Spacer(),
        showAddFormulaIconBtn(
            localizedStrings.fAddFmaBtn, Icons.add_box_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddFormulaPage()));
        }),
        SizedBox(
          width: 12,
        ),
        //配方称重记录
        showIconButton(localizedStrings.fHistoricalWeighingRecordsBtn,
            Icons.library_books_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AllFmaWgtRecPage()));
        }),
        SizedBox(
          width: 12,
        ),
        //导入配方
        // showIconButton(localizedStrings.fImportFmaBtn,
        // //     Icons.file_download_outlined, () {}),
        // SizedBox(
        //   width: 12,
        // ),
        //导出配方
        showIconButton(
            localizedStrings.fExportFmaBtn, Icons.file_upload_outlined, () {
          //导出配方
          exportFormula();
        }),
        SizedBox(
          width: 20,
        ),
      ]),
    );
  }

  showDarftFmaSearch() {
    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        SizedBox(
          width: 20,
        ),
        SizedBox(
            width: 245,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  controller: _searchDarftIdCtl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchDarftIdCtl.clear();
                          perforDarftSearch();
                        });
                      },
                    ),
                    hintText: localizedStrings.fSearchHint,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintStyle: textTheme.bodySmall!.copyWith(
                      // 设置提示文本样式
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // 这里可以添加搜索逻辑
                      perforDarftSearch();
                    });
                  }),
            )),
      ]),
    );
  }

  void perforDarftSearch() {
    final String keyword = _searchDarftIdCtl.text.trim();

    setState(() {
      searchDarfFmaInfoList = darfFmaInfoList.where((item) {
        final formulaId = item.fmaInfo!.header!.formulaHeader!.formulaId!;
        final formulaName = item.fmaInfo!.header!.formulaHeader!.formulaName!;

        return formulaId.contains(keyword) || formulaName.contains(keyword);
      }).toList();
    });
  }
}
