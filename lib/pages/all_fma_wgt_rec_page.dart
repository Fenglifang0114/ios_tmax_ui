import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/manager_scale_channel.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/widget/sticky_table.dart';

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

class AllFmaWgtRecPage extends StatefulWidget {
  const AllFmaWgtRecPage({super.key});
  @override
  State<AllFmaWgtRecPage> createState() => AllFmaWgtRecPageState();
}

class AllFmaWgtRecPageState extends State<AllFmaWgtRecPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool sort = false;

  bool selectAll = false; // 添加全选状态
  int? clickedRow; // 添加点击行状态
  // 定义 FocusNode
  // final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchCtl = TextEditingController();
  final TextEditingController encryptedCtl = TextEditingController();
  final TextEditingController formulaTypeCtl = TextEditingController();
  final TextEditingController rawTypeCtl = TextEditingController();
  FormulaInfoDb? selectedFormula; //选中的配方，用于展示原料列表
  Detail selectedDetail = Detail(); //配方中选中的原料
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal(); //默认秤
  List<NetScaleInfoLocal> scaleNetItems = []; //秤列表
  int selScaleId = -1; //选择的秤ID

  ScrollController scrollController = ScrollController(); //滚动控制器
  ScrollController scrollController1 = ScrollController(); //滚动控制器

  List<bool> _isExpanded = [];
  bool _isAllSelected = false;
  late List<bool> _selectedRows;

  // // 添加一个状态变量，用于跟踪每行的展开状态
  // List<bool> isRowExpanded = [];

//初始化秤列表
  void initScaleList() {
    scaleNetItems = myNetScaleList;
    selScaleId = myDefScaleInfo.defScaleId!;
    if (myNetScaleList.isNotEmpty) {
      defNetScaleInfo = NetScaleListMgr.findScaleInfo(
          myNetScaleList, myDefScaleInfo.defScaleId!);
    }

    for (var i = 0; i < fmaRecFromDbList.length; i++) {
      _isExpanded.add(false);
    }
    _selectedRows = List.generate(fmaRecFromDbList.length, (index) => false);
  }
  //myComScaleInfo

  @override
  void initState() {
    super.initState();
    initScaleList();
    // // 初始化展开状态列表
    // for (var i = 0; i < fmaRecFromDbList.length; i++) {
    //   isRowExpanded.add(false);
    // }
    _tabController = TabController(length: 2, vsync: this);
  }

  void _toggleAllSelection() {
    setState(() {
      _isAllSelected = !_isAllSelected;
      for (int i = 0; i < _selectedRows.length; i++) {
        _selectedRows[i] = _isAllSelected;
      }
    });
  }

  void _toggleRowSelection(int index) {
    setState(() {
      _selectedRows[index] = !_selectedRows[index];
      _isAllSelected = _selectedRows.every((element) => element);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollController.dispose(); // 释放滚动控制器
    scrollController1.dispose(); // 释放滚动控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      color: bgColor, //对接时修改颜色值
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          // 获取父容器的可用高度
          double availableHeight = constraints.maxHeight;

          // 其他子组件的固定高度
          double otherChildrenHeight = 54 +
              1 +
              70 +
              14 +
              65; // 对应 showTitleAndReturn、Divider、showFormulaSearch、Container 的高度

          // 计算 showFormulaTable 可用的高度
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

  showFormulaTable(double formulaTableHeight) {
    return Expanded(
      flex: 7,
      child: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          child: Container(
            // padding: const EdgeInsets.all(10),
            width: 3000,
            height: formulaTableHeight,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                border: Border.all(
                    width: 0.2,
                    color: Theme.of(context).colorScheme.onSurface)),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // 水平滚动
              controller: scrollController1,
              child: //   return Expanded(
                  Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    // 表格头
                    Container(
                      width: 3000,
                      height: 40,
                      color: const Color(0xFFE6EEF4),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isAllSelected,
                            onChanged: (bool? value) {
                              _toggleAllSelection();
                            },
                          ),
                          Expanded(
                            child:
                                Text(localizedStrings.fOrderNo ?? "Order No"),
                          ),
                          Expanded(child: Text(localizedStrings.fFmaIdLabel)),
                          Expanded(child: Text(localizedStrings.fFmaNameLabel)),
                          Expanded(
                              child: Text(localizedStrings.fMaterialNameCol)),
                          Expanded(
                              child: Text(localizedStrings.fMaterialIdCol)),
                          Expanded(child: Text(localizedStrings.fFmaModeCol)),
                          Expanded(child: Text(localizedStrings.fConfidential)),
                          Expanded(
                              child:
                                  Text(localizedStrings.fFormulaTotalWeight)),
                          Expanded(
                              child: Text(localizedStrings.fActualTotalWeight)),
                          Expanded(
                              child:
                                  Text(localizedStrings.fMaterialSingleWeight)),
                          Expanded(
                              child:
                                  Text(localizedStrings.fActualSingleWeight)),
                          Expanded(
                              child: Text(localizedStrings.fAllowableError)),
                          Expanded(child: Text(localizedStrings.fActualError)),
                          Expanded(
                              child:
                                  Text(localizedStrings.fQualificationStatus)),
                          Expanded(child: Text(localizedStrings.fCreatedAtCol)),
                          const SizedBox(width: 60, child: Text('')),
                        ],
                      ),
                    ),
                    Divider(
                      color: lineColor,
                      thickness: 1,
                      height: 1,
                    ),
                    Container(
                      height: formulaTableHeight,
                      child: ListView.builder(
                        itemCount: fmaRecFromDbList.length,
                        itemBuilder: (context, index) {
                          final rowData = fmaRecFromDbList[index];
                          return Column(
                            children: [
                              // 主行
                              Container(
                                height: 40,
                                color: const Color.fromARGB(255, 247, 247, 247),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _selectedRows[index],
                                      onChanged: (bool? value) {
                                        _toggleRowSelection(index);
                                      },
                                    ),
                                    Expanded(
                                        child: Text(
                                            rowData.header?.recordId ?? "")),
                                    Expanded(
                                        child: Text(
                                            rowData.header!.formulaId ?? "")),
                                    Expanded(
                                        child: Text(
                                            rowData.header!.formulaName ?? "")),
                                    Expanded(child: Text('')),
                                    Expanded(child: Text('')),
                                    Expanded(
                                        child: Text(
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
                                              ? greenColor
                                              : Color(0xFFF13851)),
                                    )),
                                    Expanded(
                                        child: Text(
                                            "${rowData.header!.actualFmaTotalWgt} ${rowData.header!.totalWeightUnit}")),
                                    Expanded(
                                        child: Text(
                                            "${rowData.header!.actualTotalWeight} ${rowData.header!.totalWeightUnit}")),
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
                                                ? greenColor
                                                : Color(0xFFF13851)),
                                      ),
                                    ),
                                    Expanded(
                                        // 格式化日期时间，显示本地时区的年月日时分秒
                                        child: Text(rowData
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
                                color: lineColor,
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
                                                        width: 48), // 对齐复选框位置
                                                    const Expanded(
                                                        child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(
                                                      child: Text(
                                                        detail.sequence == 0
                                                            ? localizedStrings
                                                                .fFmaContainer
                                                            : detail.materialName ??
                                                                "",
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                          detail.materialId ??
                                                              ''),
                                                    ),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(child: Text('')),
                                                    Expanded(
                                                        child: Text(detail
                                                                        .sequence ==
                                                                    0 ||
                                                                rowData.header!
                                                                        .isEncrypted
                                                                        .toString() ==
                                                                    "true"
                                                            ? '-'
                                                            : "${detail.targetWgt.toString()} ${rowData.header!.totalWeightUnit!}")),

                                                    Expanded(
                                                        child: Text((detail
                                                                        .sequence ==
                                                                    0 ||
                                                                (rowData.header!
                                                                        .isEncrypted
                                                                        .toString() !=
                                                                    "true"))
                                                            ? '${detail.actualWeight.toString()} ${rowData.header!.totalWeightUnit!}'
                                                            : "-")),
                                                    Expanded(
                                                      child: Text(detail
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
                                                        child: Text(detail
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
                                                                    ? greenColor
                                                                    : Color(
                                                                        0xFFF13851)))),
                                                    Expanded(child: Text('')),
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
                                                (rowData.details?.length ?? 0) -
                                                    1)
                                              Divider(
                                                color: lineColor,
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

  // showFormulaTable() {  备用原有的程序
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.only(left: 20, right: 20),
  //       color: Theme.of(context).colorScheme.surface,
  //       child: Column(
  //         children: [
  //           // 表格头
  //           Container(
  //             height: 40,
  //             color: const Color(0xFFE6EEF4),
  //             child: Row(
  //               children: [
  //                 Checkbox(
  //                   value: _isAllSelected,
  //                   onChanged: (bool? value) {
  //                     _toggleAllSelection();
  //                   },
  //                 ),
  //                 Expanded(
  //                   child: Text(localizedStrings.fOrderNo ?? "Order No"),
  //                 ),
  //                 Expanded(child: Text(localizedStrings.fFmaIdLabel)),
  //                 Expanded(child: Text(localizedStrings.fFmaNameLabel)),
  //                 Expanded(child: Text(localizedStrings.fMaterialNameCol)),
  //                 Expanded(child: Text(localizedStrings.fMaterialIdCol)),
  //                 Expanded(child: Text(localizedStrings.fFmaModeCol)),
  //                 Expanded(child: Text(localizedStrings.fConfidential)),
  //                 Expanded(child: Text(localizedStrings.fFormulaTotalWeight)),
  //                 Expanded(child: Text(localizedStrings.fActualTotalWeight)),
  //                 Expanded(child: Text(localizedStrings.fMaterialSingleWeight)),
  //                 Expanded(child: Text(localizedStrings.fActualSingleWeight)),
  //                 Expanded(child: Text(localizedStrings.fAllowableError)),
  //                 Expanded(child: Text(localizedStrings.fActualError)),
  //                 Expanded(child: Text(localizedStrings.fQualificationStatus)),
  //                 Expanded(child: Text(localizedStrings.fCreatedAtCol)),
  //                 const SizedBox(width: 60, child: Text('')),
  //               ],
  //             ),
  //           ),
  //           Divider(
  //             color: lineColor,
  //             thickness: 1,
  //             height: 1,
  //           ),
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: fmaRecFromDbList.length,
  //               itemBuilder: (context, index) {
  //                 final rowData = fmaRecFromDbList[index];
  //                 return Column(
  //                   children: [
  //                     // 主行
  //                     Container(
  //                       height: 40,
  //                       color: const Color.fromARGB(255, 247, 247, 247),
  //                       child: Row(
  //                         children: [
  //                           Checkbox(
  //                             value: _selectedRows[index],
  //                             onChanged: (bool? value) {
  //                               _toggleRowSelection(index);
  //                             },
  //                           ),
  //                           Expanded(
  //                               child: Text(rowData.header?.recordId ?? "")),
  //                           Expanded(
  //                               child: Text(rowData.header!.formulaId ?? "")),
  //                           Expanded(
  //                               child: Text(rowData.header!.formulaName ?? "")),
  //                           Expanded(child: Text('')),
  //                           Expanded(child: Text('')),
  //                           Expanded(
  //                               child: Text(
  //                                   rowData.header!.formulaMode! == 'wgt'
  //                                       ? localizedStrings.fWeightMode
  //                                       : localizedStrings.fPctMode)),
  //                           Expanded(
  //                               child: Text(
  //                             " ${rowData.header!.isEncrypted.toString() == "true" ? localizedStrings.fConfidential : localizedStrings.fPublic}",
  //                             style: TextStyle(
  //                                 color:
  //                                     rowData.header!.isEncrypted.toString() ==
  //                                             "false"
  //                                         ? greenColor
  //                                         : Color(0xFFF13851)),
  //                           )),
  //                           Expanded(
  //                               child: Text(
  //                                   "${rowData.header!.actualFmaTotalWgt} ${rowData.header!.totalWeightUnit}")),
  //                           Expanded(
  //                               child: Text(
  //                                   "${rowData.header!.actualTotalWeight} ${rowData.header!.totalWeightUnit}")),
  //                           Expanded(child: Text('')),
  //                           Expanded(child: Text('')),
  //                           Expanded(child: Text('')),
  //                           Expanded(child: Text('')),
  //                           Expanded(
  //                             child: Text(
  //                               rowData.header!.isQualified.toString() == "yes"
  //                                   ? localizedStrings.fQualified
  //                                   : localizedStrings.fUnqualified,
  //                               style: TextStyle(
  //                                   color: rowData.header!.isQualified
  //                                               .toString() ==
  //                                           "yes"
  //                                       ? greenColor
  //                                       : Color(0xFFF13851)),
  //                             ),
  //                           ),
  //                           Expanded(
  //                               // 格式化日期时间，显示本地时区的年月日时分秒
  //                               child: Text(rowData.header!.recordSaveTime !=
  //                                       null
  //                                   ? DateFormat('yyyy-MM-dd HH:mm:ss')
  //                                       .format(rowData.header!.recordSaveTime!)
  //                                   : '')),
  //                           SizedBox(
  //                             width: 60,
  //                             child: IconButton(
  //                               icon: Icon(
  //                                 _isExpanded[index]
  //                                     ? Icons.expand_less
  //                                     : Icons.expand_more,
  //                               ),
  //                               onPressed: () {
  //                                 setState(() {
  //                                   _isExpanded[index] = !_isExpanded[index];
  //                                 });
  //                               },
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     Divider(
  //                       color: lineColor,
  //                       thickness: 1,
  //                       height: 1,
  //                     ),

  //                     // 展开的明细行
  //                     Visibility(
  //                       visible: _isExpanded[index],
  //                       child: Column(
  //                         children: rowData.details
  //                                 ?.asMap()
  //                                 .entries
  //                                 .map<Widget>((entry) {
  //                               final detailIndex = entry.key;
  //                               final detail = entry.value;
  //                               return Column(
  //                                 children: [
  //                                   Container(
  //                                     height: 40,
  //                                     color: Colors.white,
  //                                     child: SizedBox(
  //                                       height: 38,
  //                                       child: Row(
  //                                         children: [
  //                                           const SizedBox(
  //                                               width: 48), // 对齐复选框位置
  //                                           const Expanded(child: Text('')),
  //                                           Expanded(child: Text('')),
  //                                           Expanded(child: Text('')),
  //                                           Expanded(
  //                                             child: Text(
  //                                               detail.sequence == 0
  //                                                   ? localizedStrings
  //                                                       .fFmaContainer
  //                                                   : detail.materialName ?? "",
  //                                             ),
  //                                           ),
  //                                           Expanded(
  //                                             child:
  //                                                 Text(detail.materialId ?? ''),
  //                                           ),
  //                                           Expanded(child: Text('')),
  //                                           Expanded(child: Text('')),
  //                                           Expanded(child: Text('')),
  //                                           Expanded(child: Text('')),
  //                                           Expanded(
  //                                               child: Text(detail.sequence ==
  //                                                           0 ||
  //                                                       rowData.header!
  //                                                               .isEncrypted
  //                                                               .toString() ==
  //                                                           "true"
  //                                                   ? '-'
  //                                                   : "${detail.targetWgt.toString()} ${rowData.header!.totalWeightUnit!}")),

  //                                           Expanded(
  //                                               child: Text((detail.sequence ==
  //                                                           0 ||
  //                                                       (rowData.header!
  //                                                               .isEncrypted
  //                                                               .toString() !=
  //                                                           "true"))
  //                                                   ? '${detail.actualWeight.toString()} ${rowData.header!.totalWeightUnit!}'
  //                                                   : "-")),
  //                                           Expanded(
  //                                             child: Text(detail.sequence ==
  //                                                         0 ||
  //                                                     rowData.header!
  //                                                             .isEncrypted
  //                                                             .toString() ==
  //                                                         "true"
  //                                                 ? '-'
  //                                                 : rowData.header!
  //                                                             .formulaMode! ==
  //                                                         "pct"
  //                                                     ? "${double.parse((detail.allowableError! * rowData.header!.actualFmaTotalWgt! / 100).toStringAsFixed(3)).toString()} ${rowData.header!.totalWeightUnit!}"
  //                                                     : "${detail.allowableError!.toString()} ${rowData.header!.totalWeightUnit!}"),
  //                                           ),
  //                                           Expanded(
  //                                               child: Text(detail.sequence ==
  //                                                           0 ||
  //                                                       rowData.header!
  //                                                               .isEncrypted
  //                                                               .toString() ==
  //                                                           "true"
  //                                                   ? '-'
  //                                                   : "${detail.actualErrorWgt.toString()} ${rowData.header!.totalWeightUnit!}")),
  //                                           Expanded(
  //                                               child: Text(
  //                                                   detail.sequence == 0 ||
  //                                                           rowData.header!
  //                                                                   .isEncrypted
  //                                                                   .toString() ==
  //                                                               "true"
  //                                                       ? '-'
  //                                                       : detail.isQualified
  //                                                                   .toString() ==
  //                                                               "ok"
  //                                                           ? localizedStrings
  //                                                               .fQualified
  //                                                           : localizedStrings
  //                                                               .fUnqualified,
  //                                                   style: TextStyle(
  //                                                       color: detail
  //                                                                   .isQualified
  //                                                                   .toString() ==
  //                                                               "ok"
  //                                                           ? greenColor
  //                                                           : Color(
  //                                                               0xFFF13851)))),
  //                                           Expanded(child: Text('')),
  //                                           SizedBox(
  //                                             width: 60,
  //                                             child: Text(''),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   // 判断是否为最后一个元素，不是则显示分割线
  //                                   if (detailIndex <
  //                                       (rowData.details?.length ?? 0) - 1)
  //                                     Divider(
  //                                       color: lineColor,
  //                                       thickness: 1,
  //                                       height: 1,
  //                                     )
  //                                 ],
  //                               );
  //                             }).toList() ??
  //                             [],
  //                       ),
  //                     ),
  //                   ],
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
                  ), // 返回图标
                  onPressed: () {
                    Navigator.pop(context); // 返回到上一个页面
                  },
                ),
                Text(
                  localizedStrings.fRecordTitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ), // 标题文本
              ],
            ),
          ),
          Icon(
            Icons.help,
            color: Color(0xFFF4B837),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }

  bool getExportStatus() {
    //查找是否有选中的行
    bool hasSelectedRow = _selectedRows.any((element) => element);

    return hasSelectedRow;
  }

  // 导出选中数据到 CSV 文件
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
      // 准备 CSV 表头
      final header = [
        'Order No',
        'Fma Id',
        'Fma Name',
        'Material Name',
        'Material Id',
        'Fma Mode',
        'Confidential',
        'Formula Total Weight',
        'Actual Total Weight',
        'Material Single Weight',
        'Actual Single Weight',
        'Allowable Error',
        'Actual Error',
        'Qualification Status',
        'Created At'
      ];

      List<List<dynamic>> csvData = [header];

      // 遍历选中的行
      for (int i = 0; i < _selectedRows.length; i++) {
        if (_selectedRows[i]) {
          final rowData = fmaRecFromDbList[i];
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
            "${headerData?.actualTotalWeight} ${headerData?.totalWeightUnit}",
            "",
            "",
            "",
            "",
            headerData?.isQualified.toString() == "yes"
                ? localizedStrings.fQualified
                : localizedStrings.fUnqualified,
            headerData?.recordSaveTime != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format(headerData!.recordSaveTime!)
                : ''
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
                        ? localizedStrings.fQualified
                        : localizedStrings.fUnqualified,
                ""
              ];
              csvData.add(detailRow);
            }
          }
        }
      }

      // 生成 CSV 内容
      final csv = const ListToCsvConverter().convert(csvData);
      final file = File(path);
      // 将 CSV 内容写入文件
      await file.writeAsString(csv);
      // 提示导出成功
      showTipInfo(localizedStrings.fSaveSuccess, context);
    } catch (e) {
      // 提示导出失败
      print("Export failed: $e");
    }
  }

  showFormulaSearch() {
    return Container(
      height: 70,
      color: Theme.of(context).colorScheme.surface,
      child: Row(children: [
        Spacer(),
        SizedBox(
          width: 200,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: greenColor,
              fixedSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
              ),
            ),
            onPressed: (!getExportStatus())
                ? null
                : () {
                    // SizedBox(
                    //   width: 20,
                    // ),
                    // SizedBox(
                    //     width: 210,
                    //     height: 40,
                    //     child: Align(
                    //       alignment: Alignment.centerLeft,
                    //       child: TextField(
                    //         style: TextStyle(
                    //           color: Theme.of(context).colorScheme.onSurfaceVariant,
                    //         ),
                    //         controller: _searchCtl,
                    //         decoration: InputDecoration(
                    //           prefixIcon: Icon(
                    //             Icons.search,
                    //             color: Theme.of(context).colorScheme.primary,
                    //           ),
                    //           suffixIcon: _ClearButton(controller: _searchCtl),
                    //           hintText: localizedStrings.fSearchHint,
                    //           hintStyle: TextStyle(
                    //               color: Theme.of(context).colorScheme.onSurfaceVariant,
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.normal),
                    //           border: const OutlineInputBorder(
                    //             borderRadius: BorderRadius.zero,
                    //           ),
                    //         ),
                    //       ),
                    //     )),
                    // SizedBox(
                    //   width: 14,
                    // ),
                    // Container(
                    //   width: 210,
                    //   height: 40,
                    //   padding: const EdgeInsets.only(left: 16, right: 20),
                    //   decoration: BoxDecoration(
                    //       color: Theme.of(context).colorScheme.surface,
                    //       borderRadius: BorderRadius.circular(0),
                    //       border: Border.all(
                    //         color: Theme.of(context).colorScheme.outline,
                    //         width: 1,
                    //       )),
                    //   child: DropdownButton(
                    //     underline: SizedBox(),
                    //     isExpanded: true,
                    //     value: formulaTypeCtl.text.isEmpty ? null : formulaTypeCtl.text,
                    //     items: formulaTypeList.isEmpty
                    //         ? [
                    //             DropdownMenuItem<String>(
                    //               value: null,
                    //               child: Text(localizedStrings.fPleaseSelectCategory),
                    //             )
                    //           ]
                    //         : [
                    //             DropdownMenuItem<String>(
                    //               value: null,
                    //               child: Text(localizedStrings.fPleaseSelectCategory),
                    //             ),
                    //             ...formulaTypeList.map((CategoryTypeList item) {
                    //               return DropdownMenuItem<String>(
                    //                 value: item.categoryName,
                    //                 child: Text(item.categoryName),
                    //               );
                    //             })
                    //           ],
                    //     onChanged: (value) {
                    //       if (value == null) return;
                    //       setState(() {
                    //         formulaTypeCtl.text = value.toString();
                    //       });
                    //     },
                    //     style: TextStyle(
                    //       color: Theme.of(context).colorScheme.onSurfaceVariant,
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.normal,
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: 14,
                    // ),
                    // Container(
                    //   width: 210,
                    //   height: 40,
                    //   padding: const EdgeInsets.only(left: 16, right: 20),
                    //   decoration: BoxDecoration(
                    //       color: Theme.of(context).colorScheme.surface,
                    //       borderRadius: BorderRadius.circular(0),
                    //       border: Border.all(
                    //         color: Theme.of(context).colorScheme.outline,
                    //         width: 1,
                    //       )),
                    //   child: DropdownButton<EncryptedValue>(
                    //     underline: SizedBox(),
                    //     isExpanded: true,
                    //     value: encryptedCtl.text == ""
                    //         ? null
                    //         : EncryptedValue.values.firstWhere((element) =>
                    //             element.getTranslation(context) == encryptedCtl.text),
                    //     items: EncryptedValue.values.map((value) {
                    //       return DropdownMenuItem<EncryptedValue>(
                    //         value: value,
                    //         child: Text(value.getTranslation(context)),
                    //       );
                    //     }).toList(),
                    //     onChanged: (value) {
                    //       if (value == null) return;
                    //       setState(() {
                    //         encryptedCtl.text = value.getTranslation(context);
                    //       });
                    //     },
                    //     style: TextStyle(
                    //       color: Theme.of(context).colorScheme.onSurfaceVariant,
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.normal,
                    //     ),
                    //   ),
                    // ),
                    // 实现导出选择的配方称重明细
                    exportSelectedDataToCSV();
                  },
            child: Text(
              localizedStrings.fExportRecordsBtn,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onPrimary,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ]),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.clear,
        size: 20,
      ),
      onPressed: () => controller.clear(),
    );
  }
}
