import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/fma_import_func.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/import_fma_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
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
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import 'package:t_max/widget/formula_widget.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/widget/page_head.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/sticky_table.dart';
import 'package:url_launcher/url_launcher.dart';
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
  int? selectedFmaIndex; // 新增状态，用于记录当前被点击的配方 index

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
  Timer? _onlineTimer;

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
  dynamic _eventbus13;
  dynamic _eventbus14;
  dynamic _eventbus15;

  @override
  void initState() {
    super.initState();
    startTestScaleOnline();

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
            // rawFormulaList = [];

            List<RawDataInfo> temp = rawDataInfoFromJson(dataStr);

            rawDataList.addAll(temp);
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
            selectedFmaIndex = -1; // 重置选中的原料 index
            selectedFormula = null; // 重置选中的配方
            selectedDetail.rawMaterialTypeName = null; // 重置选中的原料类型名称
            selectedDetail = Detail(); // 重置选中的原料
            clickedFmaRow = null; // 重置点击行状态

            List<FormulaInfoDb> tempFmaDataList =
                formulaInfoDbFromJson(dataStr);
            formulaDataList.addAll(tempFmaDataList);
            searchFmaList = List.from(formulaDataList);
          });
        } else {
          setState(() {
            selectedFmaIndex = -1; // 重置选中的原料 index
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
    _eventbus13 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    _eventbus14 = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    _eventbus15 = eventBus.on<EventPLuDataSavedOK>().listen((event) {
      if (mounted) {
        // PublicFunctions.getRawList();
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
    stopTestScaleOnline();

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
    _eventbus13?.cancel();
    _eventbus14?.cancel();
    _eventbus15?.cancel();
  }

  void startTestScaleOnline() {
    _onlineTimer?.cancel();

    _onlineTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      for (var scale in myAllScalesList) {
        if (scale.tMedia == comScaleType) {
          PublicFunctions.checkSerialPort(scale.scaleId);
        }
      }
    });
  }

  void stopTestScaleOnline() {
    // 停止发送在线状态
    _onlineTimer?.cancel();
    _onlineTimer = null;
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
                            if (_selectedTabIndex == 0) showFormulaTable(),
                            if (_selectedTabIndex == 1) showRawTable(),
                            if (_selectedTabIndex == 2) showDarftFmaTable(),
                            SizedBox(height: 14),
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
              localizedStrings.gDeviceName,
              showSort: true,
              columnWidth: const FixedColumnWidth(130),
              alignment: Alignment.centerLeft,
              sort: false,
              renderCell: (context, title, data, row, column) {
                // 显示 materialId 字段
                String scaleName = '-';
                for (var scale in myAllScalesList) {
                  if (scale.scaleId ==
                      (data as RawDataInfo).rawMaterial.scaleId) {
                    scaleName = scale.scaleName;
                    break;
                  }
                }
                return showRenderCellText(scaleName);
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
                      if (value == null) {
                        return;
                      }
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
                      if (value == null) {
                        return;
                      }
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
                selectedFmaIndex = -1;
              } else {
                selectedDetail = selectedFormula!.details![0];
                selectedFmaIndex = 0;
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
                        if (value == null) {
                          return;
                        }
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

  bool checkScaleOnline(FormulaInfoDb? selectedFormula) {
    if (selectedFormula == null) {
      return false;
    }
    if (selScaleId == -1 &&
        (selectedFormula.header!.formulaHeader!.isEncrypted! ||
            selectedFormula.header!.formulaHeader!.needContainer!)) {
      showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
      return false;
    }

    if (selectedFormula.header!.formulaHeader!.isEncrypted! ||
        selectedFormula.header!.formulaHeader!.needContainer!) {
      if (!checkOnline(selScaleId)) {
        return false;
      }
    }

    if (selectedFormula.header!.formulaHeader!.isEncrypted!) {
      return true;
    }

    List<Detail>? details = selectedFormula.details;

    for (var detail in details!) {
      int scaleId = findScaleIdFromRaw(detail.formulaDetail!.materialId!);

      if (scaleId == 0 && selScaleId == -1) {
        showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
        return false;
      }
      if (scaleId == 0) {
        scaleId = selScaleId;
      }
      if (!checkOnline(scaleId)) {
        return false;
      }
    }
    return true;
  }

  bool checkOnline(int scaleId) {
    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        if (!scale.isOnline) {
          showTipInfo(
              "${scale.scaleName} ${localizedStrings.gTipOffline}", context);
          return false;
        } else {
          return true;
        }
      }
    }
    return false;
  }

  bool checkDarftScaleOnline(DarfFmaInfo? darftFma) {
    if (darftFma == null) {
      return false;
    }
    if (selScaleId == -1 &&
        (darftFma.fmaInfo!.header!.formulaHeader!.isEncrypted! ||
            darftFma.fmaInfo!.header!.formulaHeader!.needContainer!)) {
      showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
      return false;
    }

    if (darftFma.fmaInfo!.header!.formulaHeader!.isEncrypted! ||
        darftFma.fmaInfo!.header!.formulaHeader!.needContainer!) {
      if (!checkOnline(selScaleId)) {
        return false;
      }
    }

    if (darftFma.fmaInfo!.header!.formulaHeader!.isEncrypted!) {
      return true;
    }

    List<Detail>? details = darftFma.fmaInfo!.details;

    for (var detail in details!) {
      int scaleId = findScaleIdFromRaw(detail.formulaDetail!.materialId!);

      if (scaleId == 0 && selScaleId == -1) {
        showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
        return false;
      }

      if (scaleId == 0) {
        scaleId = selScaleId;
      }

      if (!checkOnline(scaleId)) {
        return false;
      }
    }
    return true;
  }

  int findScaleIdFromRaw(String materialId) {
    for (var raw in rawDataList) {
      if (raw.rawMaterial.materialId == materialId) {
        return raw.rawMaterial.scaleId ?? 0;
      }
    }

    return 0;
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
                    onPressed: (selectedFormula == null)
                        ? null
                        : () {
                            bool isOk = checkScaleOnline(selectedFormula);
                            if (!isOk) {
                              return;
                            }
                            stopTestScaleOnline();
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
                    onPressed: (selectedDarfFma == null)
                        ? null
                        : () {
                            bool isOk = checkDarftScaleOnline(selectedDarfFma);
                            if (!isOk) {
                              return;
                            }
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
              ).then((value) {
                startTestScaleOnline();
              });
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
        ).then((value) {
          startTestScaleOnline();
        });
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
              ).then((value) {
                startTestScaleOnline();
              });
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
        ).then((value) {
          startTestScaleOnline();
        });
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
                                      //判断秤是否在线
                                      bool isOk =
                                          checkScaleOnline(selectedFormula);
                                      if (!isOk) {
                                        return;
                                      }
                                      stopTestScaleOnline();
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
          width: regularPadding,
        ),
        buildIconBtn(localizedStrings.gBtnExport, exportSvgIcon(), exportRaw),
        SizedBox(
          width: regularPadding,
        ),
        buildIconBtn(localizedStrings.gBtnImport, importSvgIcon(), importRaw),
        SizedBox(
          width: regularPadding,
        ),
        buildIconBtn(localizedStrings.fGetRawTemplateBtn, rawTemplateSvgIcon(),
            getRawTemplate),
        SizedBox(
          width: 20,
        ),
      ]),
    );
  }

  Widget buildIconBtn(String tip, String iconPath, Function() onPressed) {
    return Tooltip(
      message: tip,
      child: IconButton(
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
          onPressed();
        },
        icon: getSvgIcon(iconPath, 24, 24, colorScheme.primary),
      ),
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

  void getRawTemplate() async {
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["xlsx"],
      fileName: 'Ingredient_template.xlsx',
    ));
    if (outputFile == null) return;

    if (!outputFile.contains(".xlsx")) {
      outputFile = "$outputFile.xlsx";
    }
    String filePath = outputFile;
    ExportResult result = await exportRawTemplate(filePath);
    if (result.isSuccess) {
      showExportDialog(filePath);
    } else {
      if (context.mounted) {
        showTipInfo(result.errorMessage!, context);
      }
    }
  }

  Future<ExportResult> exportRawTemplate(String filePath) async {
    try {
      final tempExcel = excel.Excel.createExcel();
      final sheet = tempExcel['Sheet1'];

      // 写入表头
      sheet.appendRow([
        excel.TextCellValue('Ingredient Id'),
        excel.TextCellValue('Ingredient Name'),
        excel.TextCellValue('Device Name'),
        excel.TextCellValue('Category'),
        excel.TextCellValue('Ingredient Notes'),
      ]);

      // 写入数据行

      sheet.appendRow([
        excel.TextCellValue('TS-1001'),
        excel.TextCellValue('Water'),
        excel.TextCellValue('XD-101'),
        excel.TextCellValue('Liquid'),
        excel.TextCellValue('Slowly pour in while stirring.'),
      ]);

      sheet.appendRow([
        excel.TextCellValue('This field is required and cannot be duplicated'),
        excel.TextCellValue('This field is required'),
        excel.TextCellValue('This field is not required'),
        excel.TextCellValue('This field is not required'),
        excel.TextCellValue('This field is not required'),
      ]);

      final file = File(filePath);

      // 将Excel数据保存到文件
      await file.writeAsBytes(tempExcel.save()!);

      return ExportResult(isSuccess: true);
    } catch (e) {
      String errorMessage = localizedStrings.gTipExportError;
      if (e is FileSystemException) {
        errorMessage = localizedStrings.gTipExportFileError;
      } else if (e is IOException) {
        errorMessage = localizedStrings.gTipExportIOError;
      } else if (e is PathNotFoundException) {
        errorMessage = localizedStrings.gTipExportPathError;
      }
      return ExportResult(isSuccess: false, errorMessage: errorMessage);
    }
  }

  void getFmaTemplate() async {
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["xlsx"],
      fileName: 'Formula_template.xlsx',
    ));
    if (outputFile == null) return;

    if (!outputFile.contains(".xlsx")) {
      outputFile = "$outputFile.xlsx";
    }
    String filePath = outputFile;
    ExportResult result = await exportFmaTemplate(filePath);
    if (result.isSuccess) {
      showExportDialog(filePath);
    } else {
      if (context.mounted) {
        showTipInfo(result.errorMessage!, context);
      }
    }
  }

  Future<ExportResult> exportFmaTemplate(String filePath) async {
    try {
      final tempExcel = excel.Excel.createExcel();
      final sheet = tempExcel['Sheet1'];

      // 写入表头
      sheet.appendRow([
        excel.TextCellValue('Formula Id'),
        excel.TextCellValue('Formula Name'),
        excel.TextCellValue('Mode'),
        excel.TextCellValue('Weight Unit'),
        excel.TextCellValue('Category'),
        excel.TextCellValue('Confidential'),
        excel.TextCellValue('Need Container'),
        excel.TextCellValue('Ingredient No.'),
        excel.TextCellValue('Ingredient Id'),
        excel.TextCellValue('Ingredient Name'),
        excel.TextCellValue('Ingredient Weight/Percent'),
        excel.TextCellValue('Allow Error'),
      ]);

      // 写入数据行

      sheet.appendRow([
        excel.TextCellValue('1001'),
        excel.TextCellValue('F1001'),
        excel.TextCellValue('weight'),
        excel.TextCellValue('kg'),
        excel.TextCellValue('mixed'),
        excel.TextCellValue('yes'),
        excel.TextCellValue('yes'),
        excel.TextCellValue('1'),
        excel.TextCellValue('TS-1001'),
        excel.TextCellValue('Water'),
        excel.TextCellValue('8.88'),
        excel.TextCellValue('0.1'),
      ]);
      sheet.appendRow([
        excel.TextCellValue('1001'),
        excel.TextCellValue('F1001'),
        excel.TextCellValue('weight'),
        excel.TextCellValue('kg'),
        excel.TextCellValue('mixed'),
        excel.TextCellValue('yes'),
        excel.TextCellValue('yes'),
        excel.TextCellValue('2'),
        excel.TextCellValue('TS-1002'),
        excel.TextCellValue(''),
        excel.TextCellValue('1.88'),
        excel.TextCellValue('0.05'),
      ]);
      sheet.appendRow([
        excel.TextCellValue('1001'),
        excel.TextCellValue('F1001'),
        excel.TextCellValue('weight'),
        excel.TextCellValue('kg'),
        excel.TextCellValue('mixed'),
        excel.TextCellValue('yes'),
        excel.TextCellValue('yes'),
        excel.TextCellValue('3'),
        excel.TextCellValue('TS-1003'),
        excel.TextCellValue(''),
        excel.TextCellValue('2.88'),
        excel.TextCellValue('0.08'),
      ]);
      /////////////////
      sheet.appendRow([
        excel.TextCellValue('1002'),
        excel.TextCellValue('F1002'),
        excel.TextCellValue('percent'),
        excel.TextCellValue(''),
        excel.TextCellValue(''),
        excel.TextCellValue('no'),
        excel.TextCellValue('no'),
        excel.TextCellValue('1'),
        excel.TextCellValue('TS-1001'),
        excel.TextCellValue('Water'),
        excel.TextCellValue('30'),
        excel.TextCellValue('2'),
      ]);
      sheet.appendRow([
        excel.TextCellValue('1002'),
        excel.TextCellValue('F1002'),
        excel.TextCellValue('percent'),
        excel.TextCellValue(''),
        excel.TextCellValue(''),
        excel.TextCellValue('no'),
        excel.TextCellValue('no'),
        excel.TextCellValue('2'),
        excel.TextCellValue('TS-1002'),
        excel.TextCellValue(''),
        excel.TextCellValue('50'),
        excel.TextCellValue('1.5'),
      ]);
      sheet.appendRow([
        excel.TextCellValue('1002'),
        excel.TextCellValue('F1002'),
        excel.TextCellValue('percent'),
        excel.TextCellValue(''),
        excel.TextCellValue(''),
        excel.TextCellValue('no'),
        excel.TextCellValue('no'),
        excel.TextCellValue('3'),
        excel.TextCellValue('TS-1003'),
        excel.TextCellValue(''),
        excel.TextCellValue('20'),
        excel.TextCellValue('0.5'),
      ]);

      sheet.appendRow([
        excel.TextCellValue('This field is required and cannot be duplicated'),
        excel.TextCellValue('This field is required'),
        excel.TextCellValue('This field is required'),
        excel.TextCellValue('This field is required when mode is weight'),
        excel.TextCellValue('This field is not required'),
        excel.TextCellValue('This field is required'),
        excel.TextCellValue('This field is required  yes/no'),
        excel.TextCellValue('This field is required'),
        excel.TextCellValue('This field is required'),
        excel.TextCellValue('This field is not required'),
        excel.TextCellValue(
            'This field is required > 0 and decimal format less than 3'),
        excel.TextCellValue(
            'This field is required > 0 and decimal format less than 3'),
      ]);

      final file = File(filePath);

      // 将Excel数据保存到文件
      await file.writeAsBytes(tempExcel.save()!);

      return ExportResult(isSuccess: true);
    } catch (e) {
      String errorMessage = localizedStrings.gTipExportError;
      if (e is FileSystemException) {
        errorMessage = localizedStrings.gTipExportFileError;
      } else if (e is IOException) {
        errorMessage = localizedStrings.gTipExportIOError;
      } else if (e is PathNotFoundException) {
        errorMessage = localizedStrings.gTipExportPathError;
      }
      return ExportResult(isSuccess: false, errorMessage: errorMessage);
    }
  }

  void importRaw() async {
    //选择一个csv文件
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);
    //读取csv文件
    List<List<String>> dataList = await importRawFromExcel(file);
    if (dataList.isEmpty) {
      return;
    }
    sendRawListInBatches(dataList);
  }

  void sendRawListInBatches(List<List<String>> dataList) {
    const batchSize = 100;
    int totalItems = dataList[0].length;

    // 创建一个定时器的流控制器
    final StreamController<Timer> timerController = StreamController<Timer>();

    // 创建一个定时器，每隔4秒向流中添加一个新的定时器实例
    var timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      timerController.add(t);
    });

    // 创建一个索引，用于跟踪当前发送到哪个批次了
    int currentIndex = 0;

    // 监听定时器流，当有新的定时器实例时，发送下一批数据
    timerController.stream.listen((Timer timer) {
      debugPrint('Sending batch ${currentIndex + 1}...');
      if (currentIndex < totalItems) {
        int endIndex = currentIndex + batchSize;
        endIndex = endIndex < totalItems ? endIndex : totalItems;
        List<RawInfo> batch = [];

        for (int i = currentIndex; i < endIndex; i++) {
          RawInfo rawInfo = RawInfo(
            materialId: dataList[0][i],
            materialName: dataList[1][i],
            scaleId: int.tryParse(dataList[2][i]) ?? 0,
            categoryName: dataList[3][i],
            ingredient: dataList[4][i],
          );
          batch.add(rawInfo);
        }

        ImportRawList importRawList = ImportRawList(
          rawInfo: batch,
          createdBy: mySysUser.nickName!,
        );

        String jsonStr = importRawListToJson(importRawList);
        PublicFunctions.importRawList(jsonStr);

        currentIndex += batchSize;
      } else {
        // 所有数据发送完毕，关闭定时器流控制器
        timerController.close();
        timer.cancel();
        eventBus.fire(EventPLuDataSavedOK(''));
      }
    });
  }

  bool checkRawExist(String materialId) {
    return rawDataList
        .any((element) => element.rawMaterial.materialId == materialId);
  }

  bool checkScaleExist(String scaleName) {
    return myAllScalesList.any((element) => element.scaleName == scaleName);
  }

  void importFormula() async {
    //选择一个xlsx文件
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);
    //读取xlsx文件
    List<ImportFmaInfo> dataList = await importFormulasFromExcel(file, context);
    if (dataList.isEmpty) {
      return;
    }
    sendFmaListInBatches(dataList);
  }

  void sendFmaListInBatches(List<ImportFmaInfo> dataList) {
    const batchSize = 100;
    int totalItems = dataList.length;

    // 创建一个定时器的流控制器
    final StreamController<Timer> timerController = StreamController<Timer>();

    // 创建一个定时器，每隔4秒向流中添加一个新的定时器实例
    var timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      timerController.add(t);
    });

    // 创建一个索引，用于跟踪当前发送到哪个批次了
    int currentIndex = 0;

    // 监听定时器流，当有新的定时器实例时，发送下一批数据
    timerController.stream.listen((Timer timer) {
      debugPrint('Sending batch ${currentIndex + 1}...');
      if (currentIndex < totalItems) {
        int endIndex = currentIndex + batchSize;
        endIndex = endIndex < totalItems ? endIndex : totalItems;
        List<ImportFmaInfo> batch = [];

        for (int i = currentIndex; i < endIndex; i++) {
          batch.add(dataList[i]);
        }

        FmaImportFmt importFmaList = FmaImportFmt(
          fmaInfo: batch,
          createBy: mySysUser.nickName!,
        );

        String jsonStr = importFmaInfoToJson(importFmaList);
        PublicFunctions.importFmaList(jsonStr);

        currentIndex += batchSize;
      } else {
        // 所有数据发送完毕，关闭定时器流控制器
        timerController.close();
        timer.cancel();
        eventBus.fire(EventPLuDataSavedOK(''));
      }
    });
  }

  //导出原料的json文件，只要导出勾选的原料
  void exportRaw() async {
    if (selectedRows.isEmpty) {
      showTipInfo(localizedStrings.gTipNoDataSelected, context);
      return;
    }
    List<RawDataInfo> exportRawList = [];
    for (var row in selectedRows) {
      exportRawList.add(searchRawList[row]);
    }

    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["xlsx"],
      fileName: 'components.xlsx',
    ));
    if (outputFile == null) return;

    if (!outputFile.contains(".xlsx")) {
      outputFile = "$outputFile.xlsx";
    }
    String filePath = outputFile;

    // 将 CSV 数据写入文件
    ExportResult result = await exportRawListToExcel(exportRawList, filePath);

    if (result.isSuccess) {
      showExportDialog(filePath);
    } else {
      if (context.mounted) {
        showTipInfo(result.errorMessage!, context);
      }
    }
  }

  void showExportDialog(String filePath) {
    final BuildContext currentContext = context;
    if (currentContext.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 610,
              height: 493,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                children: [
                  // 头部
                  ...dialogHeadStyle(
                      context, localizedStrings.gTipExportSuccess, true),

                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: getSvgIcon(exportSuccessSvgIcon(), 178, 178,
                              colorScheme.onTertiaryFixedVariant),
                        ),
                      ),
                    ]),
                  ),

                  // 中部
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: SelectableText(
                              filePath,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),

                  // 底部
                  Container(
                    height: 96,
                    width: 610,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        showTextButton(
                            context, btnHeight, localizedStrings.gBtnCancel,
                            () {
                          Navigator.pop(context);
                        }, colorScheme.onPrimary, colorScheme.error,
                            colorScheme.onPrimary),
                        SizedBox(
                          width: 20,
                        ),
                        showTextButton(context, btnHeight,
                            localizedStrings.gBtnOpenFileLocation, () async {
                          // 打开文件所在文件夹或直接打开文件
                          if (Platform.isWindows) {
                            // Windows: 打开文件所在文件夹并选中文件
                            await Process.run(
                                'explorer.exe', ['/select,', filePath]);
                          } else if (Platform.isMacOS) {
                            // macOS: 在Finder中显示文件
                            await Process.run('open', ['-R', filePath]);
                          } else if (Platform.isLinux) {
                            // Linux: 打开文件所在目录
                            String directory = Directory(filePath).parent.path;
                            await Process.run('xdg-open', [directory]);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }, colorScheme.onPrimary, colorScheme.primary,
                            colorScheme.onPrimary),
                        SizedBox(
                          width: 20,
                        ),
                        showTextButton(
                            context, btnHeight, localizedStrings.gBtnOpenFile,
                            () async {
                          // 直接打开文件
                          final Uri fileUri = Uri.file(filePath);
                          if (await canLaunchUrl(fileUri)) {
                            await launchUrl(fileUri);
                          } else {
                            // 如果无法直接打开，则打开文件所在目录
                            String directory = Directory(filePath).parent.path;
                            final Uri dirUri = Uri.file(directory);
                            if (await canLaunchUrl(dirUri)) {
                              await launchUrl(dirUri);
                            }
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }, colorScheme.onPrimary, colorScheme.primary,
                            colorScheme.onPrimary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<ExportResult> exportRawListToExcel(
      List<RawDataInfo> rawList, String filePath) async {
    try {
      final exportExcel = excel.Excel.createExcel();
      final sheet = exportExcel['Sheet1'];

      // 写入表头
      sheet.appendRow([
        excel.TextCellValue('Ingredient Id'),
        excel.TextCellValue('Ingredient Name'),
        excel.TextCellValue('Device Name'),
        excel.TextCellValue('Category'),
        excel.TextCellValue('Ingredient Notes'),
        excel.TextCellValue('Create Time'),
        excel.TextCellValue('Update Time'),
      ]);

      // 写入数据行

      for (var rowIndex = 0; rowIndex < rawList.length; rowIndex++) {
        final raw = rawList[rowIndex];
        String scaleName = '';

        // 查找秤的名称
        for (var scale in myAllScalesList) {
          if (scale.scaleId == raw.rawMaterial.scaleId) {
            scaleName = scale.scaleName;
            break;
          }
        }

        sheet.appendRow([
          excel.TextCellValue(rawList[rowIndex].rawMaterial.materialId),
          excel.TextCellValue(rawList[rowIndex].rawMaterial.materialName),
          excel.TextCellValue(scaleName),
          excel.TextCellValue(rawList[rowIndex].rawCategoryName == "-"
              ? ""
              : rawList[rowIndex].rawCategoryName),
          excel.TextCellValue(rawList[rowIndex].rawMaterial.ingredient),
          excel.TextCellValue(DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(rawList[rowIndex].rawMaterial.createdAt)),
          excel.TextCellValue(DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(rawList[rowIndex].rawMaterial.updatedAt)),
        ]);
      }
      final file = File(filePath);
      await file.writeAsBytes(exportExcel.save()!);

      return ExportResult(isSuccess: true);
    } catch (e) {
      String errorMessage = localizedStrings.gTipExportError;
      if (e is FileSystemException) {
        errorMessage = localizedStrings.gTipExportFileError;
      } else if (e is IOException) {
        errorMessage = localizedStrings.gTipExportIOError;
      } else if (e is PathNotFoundException) {
        errorMessage = localizedStrings.gTipExportPathError;
      }

      return ExportResult(isSuccess: false, errorMessage: errorMessage);
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
            width: 180,
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
          width: 180,
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
          width: 180,
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
        showIconButton(localizedStrings.gBtnImport,
            Icons.file_download_outlined, importFormula),
        SizedBox(
          width: 12,
        ),
        //导出配方
        showIconButton(localizedStrings.gBtnExport, Icons.file_upload_outlined,
            () {
          //导出配方
          exportFormula();
        }),
        buildIconBtn(localizedStrings.fGetFmaTemplateBtn, rawTemplateSvgIcon(),
            getFmaTemplate),
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

  int checkScaleName(String scaleName) {
    for (var scale in myAllScalesList) {
      if (scaleName == scale.scaleName) {
        return scale.scaleId;
      }
    }
    return 0;
  }

  Future<List<List<String>>> importRawFromExcel(File file) async {
    try {
      // 1. 读取Excel文件
      final bytes = await file.readAsBytes();
      final excelData = excel.Excel.decodeBytes(bytes);

      if (excelData.tables.isEmpty) {
        showTipInfo('没有数据导入', context);
        return [];
      }

      // 获取第一个工作表
      final sheet = excelData.tables.values.first;
      if (sheet.rows.isEmpty) {
        showTipInfo('没有数据导入', context);
        return [];
      }

      // 2. 解析表头并验证
      List<String> headers = [];
      for (var cell in sheet.rows[0]) {
        if (cell != null && cell.value != null) {
          headers.add(cell.value.toString());
        }
      }

      bool res = _validateHeaders(headers);
      if (!res) {
        return [];
      }

      //验证数据，导入所有的ID列，判断不能重复，也不能存在
      List<String> idList = [];
      List<String> nameList = [];
      List<String> scaleIdList = [];
      List<String> typeList = [];
      List<String> notesList = [];
      //找出'Ingredient Id',列,并判断这列的值都不重复，且不为空

      for (int row = 1; row < sheet.maxRows; row++) {
        for (int col = 0; col < sheet.maxColumns; col++) {
          if (headers[col] == 'Ingredient Name') {
            final cellValue = sheet
                .cell(excel.CellIndex.indexByColumnRow(
                    columnIndex: col, rowIndex: row))
                .value;
            String name = cellValue != null ? cellValue.toString().trim() : '';
            if (name.isEmpty) {
              showTipInfo('第${row + 1}行: Ingredient Name 不能为空', context);
              return [];
            }
            nameList.add(name);
            continue;
          }
          if (headers[col] == 'Device Name') {
            final cellValue = sheet
                .cell(excel.CellIndex.indexByColumnRow(
                    columnIndex: col, rowIndex: row))
                .value;
            String scale = cellValue != null ? cellValue.toString().trim() : '';
            int scaleId = 0;
            if (scale.isNotEmpty) {
              scaleId = checkScaleName(scale);
              if (scaleId == 0) {
                showTipInfo('第${row + 1}行: Device Name 不存在', context);
                return [];
              }
            }
            scaleIdList.add(scaleId.toString());
            continue;
          }
          if (headers[col] == 'Ingredient Id') {
            final cellValue = sheet
                .cell(excel.CellIndex.indexByColumnRow(
                    columnIndex: col, rowIndex: row))
                .value;
            String id = cellValue != null ? cellValue.toString().trim() : '';
            if (id.isEmpty) {
              showTipInfo('第${row + 1}行: Ingredient Id 不能为空', context);
              return [];
            }
            if (idList.contains(id)) {
              showTipInfo('第${row + 1}行: Ingredient Id "$id" 重复', context);
              return [];
            }
            if (checkRawExist(id)) {
              showTipInfo('第${row + 1}行: Ingredient Id "$id" 已存在', context);
              return [];
            }
            idList.add(id);
            continue;
          }
          if (headers[col] == 'Category') {
            final cellValue = sheet
                .cell(excel.CellIndex.indexByColumnRow(
                    columnIndex: col, rowIndex: row))
                .value;
            String type = cellValue != null ? cellValue.toString().trim() : '';
            typeList.add(type);
          }
          if (headers[col] == 'Ingredient Notes') {
            final cellValue = sheet
                .cell(excel.CellIndex.indexByColumnRow(
                    columnIndex: col, rowIndex: row))
                .value;
            String notes = cellValue != null ? cellValue.toString().trim() : '';
            notesList.add(notes);
            continue;
          }
        }
      }

      List<List<String>> info = [];
      info.add(idList);
      info.add(nameList);
      info.add(scaleIdList);
      info.add(typeList);
      info.add(notesList);

      return info;
    } catch (e) {
      print('Excel导入错误: $e');
      showTipInfo("导入失败：${e.toString()}", context);
      return [];
    }
  }

// 辅助方法：预加载所有有效的设备名称（用Set存储，O(1)查询）
  Set<String> _getValidScaleNames() {
    // 假设从数据库或缓存获取所有有效设备名称
    // 示例：return Set.from(scaleList.map((s) => s.name));
    return {};
  }

// 原有的获取单元格值的方法（保持不变）
  String _getValue(List<excel.Data?> row, int index) {
    if (index < 0 || index >= row.length) return "";
    final cell = row[index];
    return cell?.value?.toString() ?? "";
  }

  // Future<List<RawInfo>> importFromExcel(File file) async {
  //   try {
  //     // 读取Excel文件
  //     final bytes = await file.readAsBytes();
  //     final excelData = excel.Excel.decodeBytes(bytes);

  //     if (excelData.tables.isEmpty) {
  //       throw Exception('Excel文件为空或格式不正确');
  //     }

  //     // 获取第一个工作表
  //     final sheet = excelData.tables.values.first;
  //     if (sheet.rows.isEmpty) {
  //       throw Exception('Excel工作表为空');
  //     }

  //     // 获取表头并验证

  //     List<String> headers = [];
  //     for (var cell in sheet.rows[0]) {
  //       if (cell != null && cell.value != null) {
  //         headers.add(cell.value.toString());
  //       }
  //     }

  //     _validateHeaders(headers);

  //     // 解析数据行
  //     final dataList = <RawInfo>[];

  //     for (var i = 1; i < sheet.rows.length; i++) {
  //       final row = sheet.rows[i];
  //       if (row.isEmpty) continue;

  //       // 创建数据对象
  //       final data = RawInfo(
  //         materialId: _getValue(row, headers.indexOf('Ingredient Id')),
  //         materialName: _getValue(row, headers.indexOf('Ingredient Name')),
  //         categoryName: _getValue(row, headers.indexOf('Category')),
  //         ingredient: _getValue(row, headers.indexOf('Ingredient Notes')),
  //         scaleName: _getValue(row, headers.indexOf('Device Name')),
  //       );

  //       if (data.materialId == "" || data.materialName == "") {
  //         showTipInfo("Ingredient Id or Name is empty", context);
  //         return [];
  //       }

  //       if (checkRawExist(data.materialId)) {
  //         showTipInfo(
  //             localizedStrings.fRawIdDuplicate + data.materialId!, context);
  //         return [];
  //       }

  //       if (data.scaleName != "") {
  //         int scaleId = checkScaleName(data.scaleName);
  //         if (scaleId == 0) {
  //           showTipInfo("Device Name is not exist: " + data.scaleName, context);
  //           return [];
  //         }
  //       }

  //       dataList.add(data);
  //     }

  //     return dataList;
  //   } catch (e) {
  //     // 可以添加更详细的错误处理
  //     print('Excel导入错误: $e');
  //     return [];
  //   }
  // }

// 辅助方法：从Excel行中获取值
  // String _getValue(List<excel.Data?> row, int index) {
  //   if (index < 0 || index >= row.length) return '';
  //   return row[index]?.value?.toString().trim() ?? '';
  // }

  // 验证CSV表头是否包含所有必要字段
  bool _validateHeaders(List<String> headers) {
    const requiredHeaders = [
      'Ingredient Id',
      'Ingredient Name',
      'Category',
      'Ingredient Notes',
      'Device Name',
    ];

    for (final header in requiredHeaders) {
      if (!headers.contains(header)) {
        showTipInfo("CSV文件缺少必要的列: $header", context);
        return false;
      }
    }
    return true;
  }
}

class ExportResult {
  final bool isSuccess;
  final String? errorMessage;

  ExportResult({required this.isSuccess, this.errorMessage});
}
