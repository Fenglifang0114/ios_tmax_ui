import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/functions/methods.dart';
import '../data/download_prt_fmt.dart';
import '../data/language.dart';
import '../data/plu_data_source.dart';
import '../data/plu_field_status_data.dart';
import '../data/plu_info_list_data.dart';
import '../data/scalecmd_data.dart';
import '../data/setting_version_info.dart';
import '../dialog/show_options_dialog.dart';
import '../eventbus/eventbus.dart';
import '../widget/custom_button.dart';
import 'package:path/path.dart' as path;

import '../widget/show_error_dialog.dart';
import 'sel_scales_page.dart';

class PluEidtPage extends StatefulWidget {
  const PluEidtPage({super.key});

  @override
  State<PluEidtPage> createState() => PluEidtPageState();
}

class PluEidtPageState extends State<PluEidtPage> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  final RestorablePluSelections _pluInfoSelections = RestorablePluSelections();
  late PluInfoDataSource _pluInfoDataSource;

  var defaultSorting = 'Default sorting';
  String _downloadType = "1";
  String _saveType = "1";

  bool _isLoading = false;
  bool _getingData = false;

  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _initialized = false;
  bool showCustomArrow = false;
  bool sortArrowsAlwaysVisible = false;
  bool isSendDb = false;

  dynamic _eventbus1;
  dynamic _eventbus2;

  Timer? gettingDataTimer;

  Map<String, FieldNameStatus> colNamesMap = {};

  TextEditingController searchCtl = TextEditingController(text: "");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      colNamesMap = {
        'plu': FieldNameStatus(localizedStrings.gPluPlu, true),
        'productCode': FieldNameStatus(localizedStrings.gPluPluCode, true),
        'itemCode': FieldNameStatus(localizedStrings.gPluItemCode, true),
        'category': FieldNameStatus(localizedStrings.gPluCategory, true),
        'productName': FieldNameStatus(localizedStrings.gPluPluName, true),
        'generalUnit': FieldNameStatus(localizedStrings.gPluWgtUnit, true),
        'taxType': FieldNameStatus(localizedStrings.gPluTaxType, true),
        'price': FieldNameStatus(localizedStrings.gPluPrice, true),
        'unitWeight': FieldNameStatus(
            localizedStrings.gPluUnitWgt, mySystemVersion == 3 ? false : true),
        'pretare': FieldNameStatus(localizedStrings.gPluPretare, true),
        'limitHigh': FieldNameStatus(localizedStrings.gPluLimitHigh,
            mySystemVersion == 3 ? false : true),
        'limitLow': FieldNameStatus(
            localizedStrings.gPluLimitLow, mySystemVersion == 3 ? false : true),
      };
      _pluInfoDataSource = PluInfoDataSource(
          context, getCurrentRouteOption(context) == defaultSorting);

      if (getCurrentRouteOption(context) == defaultSorting) {
        _sortColumnIndex = 1;
      }
      _initialized = true;
      for (var entry in colNamesMap.entries) {
        if (entry.value.isSelected) {
          _pluInfoDataSource.selectedColumns.add(entry.key);
        }
      }
    }

    _pluInfoDataSource.updateSelectedDesserts(_pluInfoSelections);
    _pluInfoDataSource.addListener(_updateSelectedDessertRowListener);
    // _originalDataSource = List.from(_dessertsDataSource.desserts);
  }

  String getCurrentRouteOption(BuildContext context) {
    var isEmpty = ModalRoute.of(context) != null &&
            ModalRoute.of(context)!.settings.arguments != null &&
            ModalRoute.of(context)!.settings.arguments is String
        ? ModalRoute.of(context)!.settings.arguments as String
        : '';

    return isEmpty;
  }

  void _updateSelectedDessertRowListener() {
    setState(() {
      _pluInfoSelections.setDessertSelections(_pluInfoDataSource.pluInfoList);
    });
  }

  void sort<T>(
    Comparable<T> Function(PluData d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _pluInfoDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void initState() {
    PublicFunctions.getProductList();
    _eventbus1 = eventBus.on<EventPLuDataSavedOK>().listen((event) {
      if (mounted) {
        setState(() {
          isSendDb = false;
        });
        showErrorDialog(context, localizedStrings.gTipSaveDbOk);
      }
    });

    _eventbus2 = eventBus.on<EventProductRecList>().listen((event) {
      if (mounted) {
        List<PluInfoList> pluInfoList = event.obj;
        for (int i = 0; i < pluInfoList.length; i++) {
          PluData newPlu = PluData(0, 0, 0, 0, '', '', 0, 0, 0, 0, 0, 0, 0, '');
          newPlu.recId = pluInfoList[i].recId;
          newPlu.plu = int.tryParse(pluInfoList[i].plu) ?? 0;
          newPlu.productCode = int.tryParse(pluInfoList[i].productCode) ?? 0;
          newPlu.itemCode = int.tryParse(pluInfoList[i].itemCode) ?? 0;
          newPlu.category = pluInfoList[i].category;
          newPlu.productName = pluInfoList[i].productName;
          newPlu.price = double.tryParse(pluInfoList[i].price) ?? 0;
          newPlu.taxType = int.tryParse(pluInfoList[i].taxType) ?? 0;
          newPlu.generalUnit = int.tryParse(pluInfoList[i].generalUnit) ?? 0;
          newPlu.unitWeight = double.tryParse(pluInfoList[i].unitWeight) ?? 0;
          newPlu.pretare = double.tryParse(pluInfoList[i].pretare) ?? 0;
          newPlu.limitHigh = double.tryParse(pluInfoList[i].limitHigh) ?? 0;
          newPlu.limitLow = double.tryParse(pluInfoList[i].limitLow) ?? 0;
          newPlu.creatAt = pluInfoList[i].creatAt ?? " ";
          _pluInfoDataSource.pluInfoList.add(newPlu);
        }
        setState(() {
          _pluInfoDataSource.updateSelectedDesserts(_pluInfoSelections);
          _getingData = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    PluInfoDataSource.empty(context);
    _pluInfoDataSource.pluInfoList.clear();
    _pluInfoDataSource.selectedColumns.clear();
    _pluInfoDataSource.removeListener(_updateSelectedDessertRowListener);
    _pluInfoDataSource.dispose();
    _pluInfoSelections.dispose();
    searchCtl.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    gettingDataTimer?.cancel();

    super.dispose();
  }

  void deleteSelectedRows() {
    List<PluData> newDesserts = _pluInfoDataSource.pluInfoList
        .where((dessert) => !dessert.selected)
        .toList();
    setState(() {
      _pluInfoDataSource.pluInfoList = newDesserts;
    });
    _pluInfoDataSource.updateSelectedDesserts(_pluInfoSelections);
  }

  List<PluData> findDessertsByName(String nameToFind) {
    return _pluInfoDataSource.pluInfoList
        .where((pluInfo) => pluInfo.productName!
            .toLowerCase()
            .contains(nameToFind.toLowerCase()))
        .toList();
  }

  void handleSearchTextChanged(String value) {
    List<PluData> foundDesserts = findDessertsByName(value);
    setState(() {
      _pluInfoDataSource.pluInfoList = foundDesserts;
    });
  }

  List<DataColumn2> getcolumns() {
    List<DataColumn2> columns = [];
    for (var filed in _pluInfoDataSource.selectedColumns) {
      switch (filed) {
        case "plu":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['plu']!.field,
                overflow: TextOverflow.visible,
              ),
              // size: ColumnSize.M,
              numeric: true,
              // example of fixed 1st row
              fixedWidth: 120,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.plu!, columnIndex, ascending),
            ),
          );
          break;
        case "productCode":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['productCode']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true,
              //  size: ColumnSize.M,
              // example of fixed 1st row
              fixedWidth: 150,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.productCode!, columnIndex, ascending),
            ),
          );
          break;
        case "itemCode":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['itemCode']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true,
              //  size: ColumnSize.M,
              // example of fixed 1st row
              fixedWidth: 150,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.itemCode!, columnIndex, ascending),
            ),
          );
          break;
        case "category":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['category']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true, size: ColumnSize.M,
              // example of fixed 1st row
              // fixedWidth: 200,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.itemCode!, columnIndex, ascending),
            ),
          );
          break;
        case "productName":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['productName']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true,
              size: ColumnSize.L,
              // example of fixed 1st row
              // fixedWidth: size * 0.25 > 300 ? size * 0.2 : 300,
              onSort: (columnIndex, ascending) =>
                  sort<String>((d) => d.productName!, columnIndex, ascending),
            ),
          );
          break;
        case "generalUnit":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['generalUnit']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true, size: ColumnSize.S,
              // example of fixed 1st row
              fixedWidth: null,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.generalUnit!, columnIndex, ascending),
            ),
          );
          break;
        case "taxType":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['taxType']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true, size: ColumnSize.S,
              // example of fixed 1st row
              fixedWidth: null,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.taxType!, columnIndex, ascending),
            ),
          );
          break;
        case "price":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['price']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true, size: ColumnSize.S,
              // example of fixed 1st row
              fixedWidth: null,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.price!, columnIndex, ascending),
            ),
          );
          break;
        case "unitWeight":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['unitWeight']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true, size: ColumnSize.S,
              // example of fixed 1st row
              fixedWidth: null,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.unitWeight!, columnIndex, ascending),
            ),
          );
          break;
        case "pretare":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['pretare']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true,
              // size: ColumnSize.S,
              // example of fixed 1st row
              fixedWidth: 120,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.pretare!, columnIndex, ascending),
            ),
          );
          break;
        case "limitHigh":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['limitHigh']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true,
              // size: ColumnSize.S,
              // example of fixed 1st row
              fixedWidth: 120,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.limitHigh!, columnIndex, ascending),
            ),
          );
          break;
        case "limitLow":
          columns.add(
            DataColumn2(
              label: Text(
                colNamesMap['limitLow']!.field,
                overflow: TextOverflow.visible,
              ),
              numeric: true,
              // size: ColumnSize.S,
              // example of fixed 1st row
              fixedWidth: 120,
              onSort: (columnIndex, ascending) =>
                  sort<num>((d) => d.limitLow!, columnIndex, ascending),
            ),
          );
          break;
      }
    }

    return columns;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          width: width,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // pageHeadInfo(
                //     context,
                //     width - headWidthPadding,
                //     localizedStrings.menuPluManagement,
                //     localizedStrings.gTipPlueditPageHelp),
                Expanded(
                    child: Container(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(children: [
                        buildButtonRow(),
                        SizedBox(height: 10),
                        SizedBox(
                            width: width - 20,
                            height: height - 230,
                            child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  PaginatedDataTable2(
                                    // 100 Won't be shown since it is smaller than total records
                                    availableRowsPerPage: const [
                                      10,
                                      20,
                                      30,
                                      50
                                    ],
                                    horizontalMargin: 20,
                                    checkboxHorizontalMargin: 12,
                                    columnSpacing: 0,
                                    wrapInCard: false,
                                    renderEmptyRowsInTheEnd: false,
                                    headingRowColor:
                                        WidgetStateColor.resolveWith((states) =>
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                    headingTextStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    headingCheckboxTheme: CheckboxThemeData(
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2.0),
                                      fillColor:
                                          WidgetStateProperty.resolveWith<
                                              Color>((Set<WidgetState> states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return Theme.of(context)
                                              .colorScheme
                                              .primary;
                                        }
                                        return Theme.of(context)
                                            .colorScheme
                                            .onPrimary; // 未选中时的填充颜色，可根据需要调整
                                      }),
                                    ),
                                    //checkboxAlignment: Alignment.topLeft,

                                    datarowCheckboxTheme: CheckboxThemeData(
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2.0),
                                      fillColor:
                                          WidgetStateProperty.resolveWith<
                                              Color>((Set<WidgetState> states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return Theme.of(context)
                                              .colorScheme
                                              .primary;
                                        }
                                        return Theme.of(context)
                                            .colorScheme
                                            .onPrimary;
                                      }),
                                    ),

                                    rowsPerPage: _rowsPerPage,
                                    autoRowsToHeight: false,
                                    minWidth: _pluInfoDataSource
                                                .selectedColumns.length <
                                            8
                                        ? (width - 20)
                                        : (width - 20) > 1500
                                            ? (width - 20)
                                            : 1500,
                                    fit: FlexFit.tight,
                                    border: TableBorder(
                                        top: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        bottom: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        left: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        right: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        verticalInside: BorderSide.none,
                                        // BorderSide(
                                        //     color: Theme.of(context).colorScheme.surfaceTint),
                                        horizontalInside: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 1)),
                                    onRowsPerPageChanged: (value) {
                                      // No need to wrap into setState, it will be called inside the widget
                                      // and trigger rebuild
                                      //setState(() {
                                      _rowsPerPage = value!;
                                      if (kDebugMode) {
                                        print(_rowsPerPage);
                                      }
                                      //});
                                    },
                                    initialFirstRowIndex: 0,
                                    onPageChanged: (rowIndex) {
                                      if (kDebugMode) {
                                        print(rowIndex / _rowsPerPage);
                                      }
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      });
                                    },
                                    sortColumnIndex: _sortColumnIndex,
                                    sortAscending: _sortAscending,
                                    sortArrowIcon:
                                        Icons.keyboard_arrow_up, // custom arrow
                                    sortArrowAnimationDuration: const Duration(
                                        milliseconds:
                                            0), // custom animation duration
                                    onSelectAll: _pluInfoDataSource.selectAll,
                                    controller: null,
                                    hidePaginator: false,
                                    columns: getcolumns(),
                                    empty: Center(
                                        child: Container(
                                            padding: const EdgeInsets.all(20),
                                            color: Colors.grey[200],
                                            child: const Text('No data'))),
                                    source:
                                        getCurrentRouteOption(context) == noData
                                            ? PluInfoDataSource.empty(context)
                                            : _pluInfoDataSource,
                                  ),
                                  // if (getCurrentRouteOption(context) == custPager)
                                  //   Positioned(bottom: 16, child: CustomPager(_controller!))
                                  if (_isLoading)
                                    Container(
                                        color: const Color.fromARGB(
                                                255, 162, 160, 160)
                                            .withValues(alpha: 0.5),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.transparent,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                          ),
                                        )),
                                ]))
                      ])),
                )),
              ])),
    );
  }

  Widget buildButtonRow() {
    return Row(
      children: [
        CustomOutlinedButton(
          btnWidth: 0,
          btnHeight: 40,
          icon: Icons.delete_outline,
          text: '',
          onPressed: () {
            deleteSelectedRows();
          },
        ),
        SizedBox(
          width: 5,
        ),
        CustomOutlinedButton(
          btnWidth: 0,
          btnHeight: 40,
          icon: Icons.add,
          text: '',
          onPressed: () {
            setState(() {
              _pluInfoDataSource.pluInfoList.add(PluData(0, 0, 0, 0, '-',
                  'PLU Name', 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, ''));

              // 按照 id 进行降序排序，并确保排序的稳定性
              _pluInfoDataSource.pluInfoList.sort((a, b) {
                final idComparison = b.id.compareTo(a.id);
                if (idComparison != 0) {
                  return idComparison;
                }
                // 如果 id 相同，可以按照其他属性进行进一步的排序，这里假设按照名称进行升序排序
                return a.plu!.compareTo(b.plu!);
              });
              _pluInfoDataSource.updateSelectedDesserts(_pluInfoSelections);
            });
          },
        ),
        SizedBox(
          width: 5,
        ),
        CustomOutlinedButton(
          btnWidth: 0,
          btnHeight: 40,
          icon: Icons.settings,
          text: '',
          onPressed: () async {
            List<String> selectedOptions =
                await _showMultiSelectDialog(context);

            _pluInfoDataSource.selectedColumns = selectedOptions;
            for (var entry in colNamesMap.entries) {
              if (selectedOptions.contains(entry.key)) {
                colNamesMap[entry.key]!.isSelected = true;
              } else {
                colNamesMap[entry.key]!.isSelected = false;
              }
            }
          },
        ),
        SizedBox(
          width: 5,
        ),
        Tooltip(
          message: localizedStrings.gBtnDownload,
          child: CustomOutlinedButton(
            btnWidth: 0,
            btnHeight: 40,
            icon: Icons.download,
            text: '',
            onPressed: () async {
              List<PluData> selectedPluInfos = [];
              if (_pluInfoDataSource.pluInfoList.isEmpty) {
                return showErrorDialog(context, localizedStrings.gTipNoData);
              }
              bool selectRow = false;
              for (var dessert in _pluInfoDataSource.pluInfoList) {
                if (dessert.selected) {
                  selectedPluInfos.add(dessert);
                  selectRow = true;
                }
              }
              if (!selectRow) {
                isSendDb = false;
                return showErrorDialog(
                    context, localizedStrings.gTipNoDataSelected);
              }
              String msg = checkImportData(selectedPluInfos);
              if (msg != "") {
                isSendDb = false;
                return showErrorDialog(context, msg);
              }

              String msgStr = await downloadFormExcel(selectedPluInfos);
              if (!msgStr.contains("OK")) {
                showSnackBar(msgStr);
                return;
              }
              List<String> splitted = msgStr.split(',');
              if (splitted.length != 2) {
                return;
              }
              if (mounted) {
                _showDownloadTypeDialog(context, splitted[1]);
              }
            },
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Tooltip(
          message: localizedStrings.gBtnGetDataFormDb,
          child: CustomOutlinedButton(
            btnWidth: 80,
            btnHeight: 40,
            icon: Icons.data_thresholding_outlined,
            text: localizedStrings.gBtnGetDataFormDb,
            onPressed: _getingData
                ? null
                : () {
                    _pluInfoDataSource.pluInfoList.clear();

                    PublicFunctions.getProductList();
                    setState(() {
                      _getingData = true;
                    });
                    gettingDataTimer = Timer(Duration(seconds: 60), () {
                      setState(() {
                        _getingData = false; // 1分钟后将intpp设置为1
                      });
                    });
                  },
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Tooltip(
          message: localizedStrings.gBtnSaveDataBase,
          child: CustomOutlinedButton(
            btnWidth: 80,
            btnHeight: 40,
            icon: Icons.change_circle_outlined,
            text: localizedStrings.gBtnSaveDataBase,
            onPressed: () {
              if (isSendDb) {
                return showErrorDialog(
                    context, localizedStrings.gTipSavingData);
              }
              _showSaveDatabaseDialog(context);
            },
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Tooltip(
          message: localizedStrings.gBtnImport,
          child: CustomOutlinedButton(
            btnWidth: 80,
            btnHeight: 40,
            icon: Icons.input_rounded,
            text: localizedStrings.gBtnImport,
            onPressed: () {
              performImport();
            },
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Tooltip(
          message: localizedStrings.gBtnExport,
          child: CustomOutlinedButton(
            btnWidth: 80,
            btnHeight: 40,
            icon: Icons.list_alt_outlined,
            text: localizedStrings.gBtnExport,
            onPressed: () async {
              List<PluData> selectedPluInfos = [];
              if (_pluInfoDataSource.pluInfoList.isEmpty) {
                return showErrorDialog(context, localizedStrings.gTipNoData);
              }
              bool selectRow = false;
              for (var dessert in _pluInfoDataSource.pluInfoList) {
                if (dessert.selected) {
                  selectedPluInfos.add(dessert);
                  selectRow = true;
                }
              }
              if (!selectRow) {
                isSendDb = false;
                return showErrorDialog(
                    context, localizedStrings.gTipNoDataSelected);
              }

              String msg = await writeDessertsToExcel(selectedPluInfos);
              showSnackBar(msg);
            },
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Tooltip(
          message: localizedStrings.gBtnGetPluTemplate,
          child: CustomOutlinedButton(
            btnWidth: 60,
            btnHeight: 40,
            icon: Icons.file_copy,
            text: localizedStrings.gBtnGetPluTemplate,
            onPressed: () async {
              String msg = await performExportTemplate();
              showErrorDialog(context, msg);
            },

            // _dessertsDataSource.desserts.sort((a, b) {
            //         final idComparison = b.id.compareTo(a.id);
            //         if (idComparison != 0) {
            //           return idComparison;
            //         }
            //         // 如果 id 相同，可以按照其他属性进行进一步的排序，这里假设按照名称进行升序排序
            //         return a.plu!.compareTo(b.plu!);
            //       });
          ),
        ),
        SizedBox(
          width: 5,
        ),
      ],
    );
  }

  //保存到数据库的类型：全部下发，增量下发
  void _showSaveDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SizedBox(
              width: 400,
              height: 100,
              child: Column(
                children: [
                  StatefulBuilder(builder: (context, StateSetter setState) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 400,
                          child: RadioListTile(
                            title: Text(localizedStrings.gTipDownloadAllPlu),
                            value: '1',
                            groupValue: _saveType,
                            onChanged: (value) {
                              setState(() {
                                _saveType = value.toString();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          child: RadioListTile(
                            title: Text(localizedStrings.gTipUpdatePlu),
                            value: '2',
                            groupValue: _saveType,
                            onChanged: (value) {
                              setState(() {
                                _saveType = value.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              )),
          actions: <Widget>[
            Row(
              children: [
                CustomElevatedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.gTitleConfirm,
                  onPressed: () {
                    Navigator.of(ctx).pop(false);

                    setState(() {
                      isSendDb = true;
                    });

                    sendAllData(_saveType);
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.gBtnCancel,
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

//确定下发类型：全部下发，增量下发
  void _showDownloadTypeDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SizedBox(
              width: 400,
              height: 100,
              child: Column(
                children: [
                  StatefulBuilder(builder: (context, StateSetter setState) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 400,
                          child: RadioListTile(
                            title: Text(localizedStrings.gTipDownloadAllPlu),
                            value: '1',
                            groupValue: _downloadType,
                            onChanged: (value) {
                              setState(() {
                                _downloadType = value.toString();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          child: RadioListTile(
                            title: Text(localizedStrings.gTipUpdatePlu),
                            value: '2',
                            groupValue: _downloadType,
                            onChanged: (value) {
                              setState(() {
                                _downloadType = value.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              )),
          actions: <Widget>[
            Row(
              children: [
                CustomElevatedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.gTitleConfirm,
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                    selectDownloadType(_downloadType, filePath);
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.gBtnCancel,
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void selectDownloadType(String type, String filePath) {
    if (type == '1') {
      String sendJson = getSendMsg(1, filePath);
      showSelScaleDialog(1, sendJson);
    } else {
      String sendJson = getSendMsg(2, filePath);
      showSelScaleDialog(1, sendJson);
    }
  }

  void showSelScaleDialog(int funcNo, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return SelectScalesPage(
          funcNo: funcNo,
          sendMsgStr: msg,
        );
      },
    );
  }

  String getSendMsg(int type, String fmtPath) {
    if (type == 1) {
      myScaleCmd.cmdMode = "down_plu_to_scale";
    } else {
      myScaleCmd.cmdMode = "insert_plu_to_scale";
    }

    myDownLoadPluFile.scaleModel = 'TMax';
    myDownLoadPluFile.filePath = fmtPath;
    myDownLoadPluFile.nameMaxLen = 30;
    myScaleCmd.cmdData = json.encode(myDownLoadPluFile);
    return jsonEncode(myScaleCmd);
  }

//下发全部PLU
  void sendAllData(String saveType) {
    if (_pluInfoDataSource.pluInfoList.isEmpty) {
      isSendDb = false;
      return showErrorDialog(context, localizedStrings.gTipNoData);
    }
    bool selectRow = false;
    for (var dessert in _pluInfoDataSource.pluInfoList) {
      if (dessert.selected) {
        selectRow = true;
        break;
      }
    }
    if (!selectRow) {
      isSendDb = false;
      return showErrorDialog(context, localizedStrings.gTipNoDataSelected);
    }
    String msg = checkImportData(_pluInfoDataSource.pluInfoList);
    if (msg != "") {
      isSendDb = false;
      return showErrorDialog(context, msg);
    }
    if (saveType == "1") {
      PublicFunctions.delAllProduct();
      //全部下发，先清除
    }
    sendDataToSrv(saveType);
  }

  void sendDataToSrv(String saveType) {
    List<PluInfoList> pluList = [];
    for (var info in _pluInfoDataSource.pluInfoList) {
      if (info.selected) {
        pluList.add(PluInfoList(
            recId: 0,
            plu: info.plu.toString(),
            productCode: info.productCode.toString(),
            itemCode: info.itemCode.toString(),
            category: info.category == null ? '-' : info.category!,
            productName: info.productName!,
            generalUnit: info.generalUnit.toString(),
            taxType: info.taxType.toString(),
            price: info.price.toString(),
            unitWeight: info.unitWeight.toString(),
            pretare: info.pretare.toString(),
            limitHigh: info.limitHigh.toString(),
            limitLow: info.limitLow.toString(),
            creatAt: ''));
      }
    }
    sendPluListInBatches(pluList, saveType);
  }

  void sendPluListInBatches(List<PluInfoList> pluList, String saveType) {
    const batchSize = 100;
    int totalItems = pluList.length;

    // 创建一个定时器的流控制器
    final StreamController<Timer> timerController = StreamController<Timer>();

    // 创建一个定时器，每隔4秒向流中添加一个新的定时器实例
    var timer = Timer.periodic(const Duration(milliseconds: 50), (Timer t) {
      timerController.add(t);
    });

    // 创建一个索引，用于跟踪当前发送到哪个批次了
    int currentIndex = 0;

    // 监听定时器流，当有新的定时器实例时，发送下一批数据
    timerController.stream.listen((Timer timer) {
      if (currentIndex < totalItems) {
        int endIndex = currentIndex + batchSize;
        endIndex = endIndex < totalItems ? endIndex : totalItems;
        List<PluInfoList> batch = pluList.sublist(currentIndex, endIndex);
        String jsonData = jsonEncode(batch);
        if (saveType == "1") {
          PublicFunctions.addProduct(jsonData);
        } else {
          PublicFunctions.modifyProduct(jsonData);
        }

        currentIndex += batchSize;
      } else {
        // 所有数据发送完毕，关闭定时器流控制器
        timerController.close();
        timer.cancel();
        eventBus.fire(EventPLuDataSavedOK(''));
      }
    });
  }

  Future<List<String>> _showMultiSelectDialog(BuildContext content) async {
    List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          options: colNamesMap,
          context: context,
        );
      },
    );
    return result ?? [];
  }

  String checkImportData(List<PluData> dataSource) {
    for (var dataRow in dataSource) {
      if (!dataRow.selected) {
        continue;
      }

      // 检查PLU相关条件
      if (dataRow.plu == null) {
        return '${localizedStrings.gPluPlu}  null. ${localizedStrings.gPluPluName} : ${dataRow.productName}';
      }
      if (dataRow.plu == 0) {
        return '${localizedStrings.gPluPlu} : 1-99999. ${localizedStrings.gPluPluName} : ${dataRow.productName}';
      }

      // 检查Product Name相关条件
      if (dataRow.productName == null) {
        return '${localizedStrings.gPluPluName} null. ${localizedStrings.gPluPlu} : ${dataRow.plu}';
      }
      if (dataRow.productName == '') {
        return "${localizedStrings.gPluPluName}   . ${localizedStrings.gPluPlu} : ${dataRow.plu}";
      }

      // 检查是否有PLU值重复的情况
      List<int?> pluValues = dataSource.map((row) => row.plu).toList();
      int pluCount = pluValues.where((plu) => plu == dataRow.plu).length;
      if (pluCount > 1) {
        return '${localizedStrings.gPluPlu} ${localizedStrings.gTipPluDuplicated}.  ${localizedStrings.gPluPlu}: ${dataRow.plu}';
      }
    }
    return '';
  }

  Future<String> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    String filePath = '';
    if (result != null) {
      filePath = result.files.single.path!;
    }

    return filePath;
  }

  Future<String> performExportTemplate() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // 写入表头
      sheet.appendRow([
        if (_pluInfoDataSource.selectedColumns.contains('plu'))
          TextCellValue('PLU'),
        if (_pluInfoDataSource.selectedColumns.contains('productCode'))
          TextCellValue('ProductCode'),
        if (_pluInfoDataSource.selectedColumns.contains('itemCode'))
          TextCellValue('ItemCode'),
        if (_pluInfoDataSource.selectedColumns.contains('productName'))
          TextCellValue('ProductName'),
        if (_pluInfoDataSource.selectedColumns.contains('generalUnit'))
          TextCellValue('GeneralUnit'),
        if (_pluInfoDataSource.selectedColumns.contains('taxType'))
          TextCellValue('TaxType'),
        if (_pluInfoDataSource.selectedColumns.contains('price'))
          TextCellValue('Price'),
        if (_pluInfoDataSource.selectedColumns.contains('unitWeight'))
          TextCellValue('UnitWeight'),
        if (_pluInfoDataSource.selectedColumns.contains('pretare'))
          TextCellValue('PreTare'),
        if (_pluInfoDataSource.selectedColumns.contains('limitHigh'))
          TextCellValue('LimitHigh'),
        if (_pluInfoDataSource.selectedColumns.contains('limitLow'))
          TextCellValue('LimitLow'),
      ]);

      // 写入数据行

      sheet.appendRow([
        if (_pluInfoDataSource.selectedColumns.contains('plu'))
          TextCellValue("1"),
        if (_pluInfoDataSource.selectedColumns.contains('productCode'))
          TextCellValue('1'),
        if (_pluInfoDataSource.selectedColumns.contains('itemCode'))
          TextCellValue('1'),
        if (_pluInfoDataSource.selectedColumns.contains('productName'))
          TextCellValue('Apple'),
        if (_pluInfoDataSource.selectedColumns.contains('generalUnit'))
          TextCellValue('1'),
        if (_pluInfoDataSource.selectedColumns.contains('taxType'))
          TextCellValue('1'),
        if (_pluInfoDataSource.selectedColumns.contains('price'))
          TextCellValue('8.88'),
        if (_pluInfoDataSource.selectedColumns.contains('unitWeight'))
          TextCellValue('8'),
        if (_pluInfoDataSource.selectedColumns.contains('pretare'))
          TextCellValue('0.88'),
        if (_pluInfoDataSource.selectedColumns.contains('limitHigh'))
          TextCellValue('10'),
        if (_pluInfoDataSource.selectedColumns.contains('limitLow'))
          TextCellValue('2'),
      ]);

      sheet.appendRow([
        if (_pluInfoDataSource.selectedColumns.contains('plu'))
          TextCellValue("1-99999"),
        if (_pluInfoDataSource.selectedColumns.contains('productCode'))
          TextCellValue('Not in use yet'),
        if (_pluInfoDataSource.selectedColumns.contains('itemCode'))
          TextCellValue('Not in use yet'),
        if (_pluInfoDataSource.selectedColumns.contains('productName'))
          TextCellValue(
              'The length is 30. Characters need scale support for display and only printer support for printing.'),
        if (_pluInfoDataSource.selectedColumns.contains('generalUnit'))
          TextCellValue(
              '''weighing scale: 0-g 1-kg 2-lb 3-oz 4-lboz 5-tj 6-hj 7-t\r\nprice scale: 0-kg  1-100g  2-pcs'''),
        if (_pluInfoDataSource.selectedColumns.contains('taxType'))
          TextCellValue('0-tax1 1-tax2  2-tax3'),
        if (_pluInfoDataSource.selectedColumns.contains('price'))
          TextCellValue('unit Price'),
        if (_pluInfoDataSource.selectedColumns.contains('unitWeight'))
          TextCellValue('Unit: g'),
        if (_pluInfoDataSource.selectedColumns.contains('pretare'))
          TextCellValue('Unit: Kg'),
        if (_pluInfoDataSource.selectedColumns.contains('limitHigh'))
          TextCellValue(
              'With unit weight, upper & lower limit units are pcs and must be integers; without, they are the same as GeneralUnit.'),
        if (_pluInfoDataSource.selectedColumns.contains('limitLow'))
          TextCellValue(
              'With unit weight, upper & lower limit units are pcs and must be integers; without, they are the same as GeneralUnit.'),
      ]);

      // 让用户选择文件夹
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        final String filePath = path.join(result, 'ProductTemplate.xlsx');
        final file = File(filePath);

        // 将Excel数据保存到文件
        await file.writeAsBytes(excel.save()!);
        return (filePath);
      } else {
        return (localizedStrings.gTipFolderNoSelected);
      }
    } catch (e) {
      return ('$e');
    }
  }

  Future<void> performImport() async {
    String msg = await handleImportExcel();
    if (context.mounted && msg.isNotEmpty) {
      showErrorDialog(context, msg);
    }
  }

  Future<String> handleImportExcel() async {
    String filePath = await pickFiles();
    if (filePath == '') {
      return "";
    }
    await importDataFromXlsx(filePath);
    if (_pluInfoDataSource.pluInfoList.isEmpty) {
      return localizedStrings.gTipNoData;
    }

    // setState(() {
    //   _dessertsDataSource.updateSelectedDesserts(_dessertSelections);
    // });

    return localizedStrings.gTipImportPluOK;
  }

  Future<void> importDataFromXlsx(String filePath) async {
    // 读取Excel文件
    Excel? excel = Excel.decodeBytes(await File(filePath).readAsBytes());
    _pluInfoDataSource.pluInfoList = [];
    if (excel.tables.isEmpty) {
      return; //要弹框提示
    }
    // 数据在第一个工作表
    var firstTable = excel.tables.values.first;
    excel = null;
    Sheet sheet = firstTable;

    // 获取首行标题作为字段名列表
    List<String> headerTitles = [];
    for (int col = 0; col < sheet.maxColumns; col++) {
      headerTitles.add(sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .value
          .toString());
    }

    // 遍历每一行数据（从第二行开始，假设第一行是标题行）
    // 用于存储当前行对应的数据
    for (int row = 1; row < sheet.maxRows; row++) {
      Map<String, dynamic> rowData = {};

      // 遍历每一列，将单元格的值与对应的标题关联起来
      for (int col = 0; col < sheet.maxColumns; col++) {
        rowData[headerTitles[col]] = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
            .value;
      }
      if ((rowData.containsKey('PLU') ||
              rowData.containsKey('ProductNumber')) &&
          (rowData['ProductNumber'] != null || rowData['PLU'] != null)) {
        double priceValue = 0.0;
        if (rowData.containsKey('Price')) {
          double value = double.tryParse(rowData['Price'].toString()) ?? 0;
          priceValue = roundToTwoDecimalPlaces(value);
        }
        // 根据标题与字段名的对应关系创建Dessert对象
        PluData dessert = PluData(
          rowData.containsKey('recId')
              ? int.tryParse(rowData['recId'].toString()) ?? 0
              : 0,
          rowData.containsKey('PLU')
              ? int.tryParse(rowData['PLU'].toString()) ?? 0
              : rowData.containsKey('ProductNumber')
                  ? int.tryParse(rowData['ProductNumber'].toString()) ?? 0
                  : 0,
          rowData.containsKey('ProductCode')
              ? int.tryParse(rowData['ProductCode'].toString()) ?? 0
              : 0,
          rowData.containsKey('ItemCode')
              ? int.tryParse(rowData['ItemCode'].toString()) ?? 0
              : 0,
          rowData.containsKey('Category')
              ? rowData['Category'].toString()
              : '-',
          rowData.containsKey('ProductName')
              ? rowData['ProductName'].toString()
              : '-',
          rowData.containsKey('GeneralUnit')
              ? int.tryParse(rowData['GeneralUnit'].toString()) ?? 0
              : 0,
          rowData.containsKey('TaxType')
              ? int.tryParse(rowData['TaxType'].toString()) ?? 0
              : 0,
          rowData.containsKey('Price') ? priceValue : 0.0,
          rowData.containsKey('UnitWeight')
              ? double.tryParse(rowData['UnitWeight'].toString()) ?? 0
              : 0.0,
          rowData.containsKey('PreTare')
              ? double.tryParse(rowData['PreTare'].toString()) ?? 0
              : rowData.containsKey('Pretare')
                  ? double.tryParse(rowData['Pretare'].toString()) ?? 0
                  : 0.0,
          rowData.containsKey('LimitHigh')
              ? double.tryParse(rowData['LimitHigh'].toString()) ?? 0
              : 0.0,
          rowData.containsKey('LimitLow')
              ? double.tryParse(rowData['LimitLow'].toString()) ?? 0
              : 0.0,
          rowData.containsKey('creatAt') ? rowData['creatAt'].toString() : '',
        );

        _pluInfoDataSource.pluInfoList.add(dessert);
      }
    }

    return;
  }

  double roundToTwoDecimalPlaces(double num) {
    double multiplier = 100;
    return (num * multiplier).round() / multiplier;
  }

  Future<String> writeDessertsToExcel(List<PluData> desserts) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // 写入表头
      sheet.appendRow([
        if (_pluInfoDataSource.selectedColumns.contains('plu'))
          TextCellValue('PLU'),
        if (_pluInfoDataSource.selectedColumns.contains('productCode'))
          TextCellValue('ProductCode'),
        if (_pluInfoDataSource.selectedColumns.contains('itemCode'))
          TextCellValue('ItemCode'),
        if (_pluInfoDataSource.selectedColumns.contains('productName'))
          TextCellValue('ProductName'),
        if (_pluInfoDataSource.selectedColumns.contains('generalUnit'))
          TextCellValue('GeneralUnit'),
        if (_pluInfoDataSource.selectedColumns.contains('taxType'))
          TextCellValue('TaxType'),
        if (_pluInfoDataSource.selectedColumns.contains('price'))
          TextCellValue('Price'),
        if (_pluInfoDataSource.selectedColumns.contains('unitWeight'))
          TextCellValue('UnitWeight'),
        if (_pluInfoDataSource.selectedColumns.contains('pretare'))
          TextCellValue('PreTare'),
        if (_pluInfoDataSource.selectedColumns.contains('limitHigh'))
          TextCellValue('LimitHigh'),
        if (_pluInfoDataSource.selectedColumns.contains('limitLow'))
          TextCellValue('LimitLow'),
      ]);

      // 写入数据行
      for (var dessert in desserts) {
        sheet.appendRow([
          if (_pluInfoDataSource.selectedColumns.contains('plu'))
            TextCellValue(dessert.plu?.toString() ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('productCode'))
            TextCellValue(dessert.productCode?.toString() ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('itemCode'))
            TextCellValue(dessert.itemCode?.toString() ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('productName'))
            TextCellValue(dessert.productName ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('generalUnit'))
            TextCellValue(dessert.generalUnit?.toString() ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('taxType'))
            TextCellValue(dessert.taxType?.toString() ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('price'))
            TextCellValue(dessert.price?.toString() ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('unitWeight'))
            TextCellValue(dessert.unitWeight?.toString() ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('pretare'))
            TextCellValue(dessert.pretare?.toString() ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('limitHigh'))
            TextCellValue(dessert.limitHigh?.toString() ?? ''),
          if (_pluInfoDataSource.selectedColumns.contains('limitLow'))
            TextCellValue(dessert.limitLow?.toString() ?? ''),
        ]);
      }

      // 让用户选择文件夹

      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        final filePath = path.join(result, 'ProductList.xlsx');
        final file = File(filePath);

        // 将Excel数据保存到文件
        await file.writeAsBytes(excel.save()!);
        return ('OK,${localizedStrings.gTipSaveSuccess} $filePath');
      } else {
        return (localizedStrings.gTipFolderNoSelected);
      }
    } catch (e) {
      return ('${localizedStrings.gTipSaveFail} $e');
    }
  }

  Future<String> downloadFormExcel(List<PluData> desserts) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // 写入表头
      sheet.appendRow([
        TextCellValue('PLU'),
        TextCellValue('ProductName'),
        TextCellValue('GeneralUnit'),
        TextCellValue('TaxType'),
        TextCellValue('Price'),
        TextCellValue('UnitWeight'),
        TextCellValue('PreTare'),
        TextCellValue('LimitHigh'),
        TextCellValue('LimitLow'),
      ]);

      // 写入数据行
      for (var dessert in desserts) {
        sheet.appendRow([
          TextCellValue(dessert.plu?.toString() ?? ''),
          TextCellValue(dessert.productName ?? ''),
          TextCellValue(dessert.generalUnit?.toString() ?? ''),
          TextCellValue(dessert.taxType?.toString() ?? ''),
          TextCellValue(dessert.price?.toString() ?? ''),
          TextCellValue(dessert.unitWeight?.toString() ?? ''),
          TextCellValue(dessert.pretare?.toString() ?? ''),
          TextCellValue(dessert.limitHigh?.toString() ?? ''),
          TextCellValue(dessert.limitLow?.toString() ?? ''),
        ]);
      }

      // 让用户选择文件夹

      final result = await getAppFilePath();
      final filePath = path.join(result, 'PluList.xlsx');
      final file = File(filePath);

      // 将Excel数据保存到文件
      await file.writeAsBytes(excel.save()!);
      return ('OK,$filePath');
    } catch (e) {
      return ('${localizedStrings.gTipSaveFail} $e');
    }
  }

  Future<String> getAppFilePath() async {
    String appDirectory = Platform.resolvedExecutable;
    var directory = path.dirname(appDirectory);
    return directory;
  }

  void showSnackBar(String msg) {
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg,
              style: TextStyle(
                fontSize: 14,
              )), ////此处需要秤回复
          duration: const Duration(seconds: 6),
          backgroundColor: msg.contains('OK')
              ? Theme.of(context).colorScheme.onTertiaryFixedVariant
              : Theme.of(context).colorScheme.error));
    });
  }
}
