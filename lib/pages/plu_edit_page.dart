import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/download_prt_fmt.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/plu_data.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/data/plu_field_status_data.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/dialog/add_plu_info_dialog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/show_options_dialog.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/update_firmware_page.dart';

import 'package:t_max/widget/dialog_head_style.dart';
import 'package:t_max/widget/f_open_file.dart';
import 'package:t_max/widget/show_error_dialog.dart';

class PluEidtPage extends StatefulWidget {
  const PluEidtPage({super.key});

  @override
  State<PluEidtPage> createState() => _PluEidtPageState();
}

class _PluEidtPageState extends State<PluEidtPage> {
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  Timer? gettingDataTimer;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;

  bool showCustomArrow = false;
  bool sortArrowsAlwaysVisible = false;
  bool isSendDb = false;
  bool isImporting = false;

  String _downloadType = "1";

  bool shouldToggleAll = false; // 是否全选
  String _sortField = ''; // 当前排序列名
  bool _sortAscending = true; // 排序方向
  PluDataSource? _dataSource;
  List<PluDataModel> dataModels = <PluDataModel>[];
  List<PluDataModel> importPlu = <PluDataModel>[];
  TextEditingController pageController = TextEditingController(text: "1");
  List<String> fieldOrder = [];

  TextEditingController pluCtl = TextEditingController(text: "");
  TextEditingController pluNameCtl = TextEditingController(text: "");
  TextEditingController categoryCtl = TextEditingController(text: "");

  final columnWidth = {
    'select': 50.0,
    'plu': double.nan,
    'productName': double.nan,
    'category': double.nan,
    'generalUnit': double.nan,
    'taxType': double.nan,
    'price': double.nan,
    'unitWeight': double.nan,
    'pretare': double.nan,
    'limitHigh': double.nan,
    'limitLow': double.nan,
    'productCode': double.nan,
    'itemCode': double.nan,
    'enable': double.nan,
  };

  final ValueNotifier<bool> allSelectedNotifier = ValueNotifier<bool>(false);

  // 分页控制变量

  int currentPage = 1;
  int pageSize = 20;
  int totalPages = 1;
  int totalCount = 0;

  // 计算总页数
  void _calculateTotalPages() {
    totalPages = (totalCount / pageSize).ceil();
    if (totalPages == 0) totalPages = 1;
    if (currentPage > totalPages) {
      currentPage = totalPages;
    }
  }

  void getCurrentPageDataFormDb() {
    ReqGetPluByPage reqGetPluByPage = ReqGetPluByPage();
    reqGetPluByPage.page = currentPage;
    reqGetPluByPage.pageSize = pageSize;
    reqGetPluByPage.fieldName = getSortField();
    reqGetPluByPage.direction = _sortAscending ? 'asc' : 'desc';

    SearchPlu reqSearch = SearchPlu();
    reqSearch.category = categoryCtl.text;
    reqSearch.plu = pluCtl.text;
    reqSearch.pluName = pluNameCtl.text;
    reqSearch.enabled = false;
    reqSearch.setEnabled = false;

    reqGetPluByPage.search = reqSearch;

    String jsonStr = jsonEncode(reqGetPluByPage);
    PublicFunctions.getPluByPage(jsonStr);
  }

  // 切换到指定页

  void _changePage(int page) {
    if (page < 1) {
      page = 1;
    } else if (page > totalPages) {
      page = totalPages;
    }
    setState(() {
      currentPage = page;
      getCurrentPageDataFormDb();
    });
  }

  // 获取当前页数据

  List<PluDataModel> _getCurrentPageData() {
    final startIndex = 0; //(currentPage - 1) * pageSize; //改为当前页的起始索引
    final endIndex = pageSize; //currentPage * pageSize;
    if (startIndex >= dataModels.length) return [];
    return dataModels.sublist(
      startIndex,
      endIndex > dataModels.length ? dataModels.length : endIndex,
    );
  }

  // 更新数据源

  void _updateDataSource() {
    _dataSource = PluDataSource(
      dataModels: _getCurrentPageData(),
      allSelectedNotifier: allSelectedNotifier,
      updateAllSelectedStatus: _updateAllSelectedStatus,
      onEnabled: _handleEnabled,
      orderField: fieldOrder, // 传递列可见性配置
      textScheme: textTheme,
      colorScheme: colorScheme,
      canSelect: true,
      enableTitle: localizedStrings.gBtnEnable,
      disableTitle: localizedStrings.gBtnDisable,
    );
  }

  // 初始化分页

  void _initPagination() {
    _calculateTotalPages();
    _updateDataSource();
  }

  // 当数据变化时重新计算分页
  void _onDataChanged() {
    _calculateTotalPages();
    _updateDataSource();
    _updateAllSelectedStatus();
  }

  void _deleteSelectedItems() async {
    List<int> recIds = [];
    setState(() {
      for (var model in dataModels) {
        if (model.isSelected) {
          recIds.add(model.pluData.recId!);
        }
      }
      dataModels.removeWhere((model) => model.isSelected);
      _onDataChanged();
    });

    ReqDelPlu reqDelPlu = ReqDelPlu();
    reqDelPlu.recId = recIds;
    //分批删除
    int batchSize = 1000;
    for (int i = 0; i < recIds.length; i += batchSize) {
      int end = i + batchSize;
      if (end > recIds.length) {
        end = recIds.length;
      }
      List<int> batch = recIds.sublist(i, end);
      ReqDelPlu reqDelPlu = ReqDelPlu();
      reqDelPlu.recId = batch;
      String jsonStr = reqDelPluToJson(reqDelPlu);
      PublicFunctions.delProduct(jsonStr);
      // 等待100毫秒
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _updateEnabledItems(bool enabled) async {
    List<int> recIds = [];
    setState(() {
      for (var model in dataModels) {
        if (model.isSelected) {
          model.pluData.enabled = enabled;
          recIds.add(model.pluData.recId!);
        }
      }
      _onDataChanged();
    });
    //分批次启用或禁用
    int batchSize = 1000;
    for (int i = 0; i < recIds.length; i += batchSize) {
      int end = i + batchSize;
      if (end > recIds.length) {
        end = recIds.length;
      }
      List<int> batch = recIds.sublist(i, end);
      ReqEnabledPlu reqEnabledPlu = ReqEnabledPlu();
      reqEnabledPlu.pluList = batch;
      reqEnabledPlu.enabled = enabled;
      reqEnabledPlu.updateBy = mySysUser.nickName;
      String jsonStr = reqEnabledPluToJson(reqEnabledPlu);
      PublicFunctions.enablePlu(jsonStr);
      // 等待100毫秒
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // 定义可选列配置，固定列不参与选择
  final Map<String, bool> _columnVisibility = {
    'plu': true,
    'productName': true,
    'category': true,
    'price': true,
    'generalUnit': true,
    'taxType': true,
    'unitWeight': true,
    'pretare': true,
    'limitHigh': true,
    'limitLow': true,
    'productCode': true,
    'itemCode': true,
  };

  // 处理删除单行
  void _handleEnabled(PluDataModel model) {
    setState(() {
      // 处理启用状态
      model.pluData.enabled ??= true;
      if (model.pluData.enabled!) {
        model.pluData.enabled = false;
      } else {
        model.pluData.enabled = true;
      }
      _onDataChanged();
    });
    ReqEnabledPlu reqEnabledPlu = ReqEnabledPlu();
    reqEnabledPlu.pluList = [model.pluData.recId ?? 0];
    reqEnabledPlu.enabled = model.pluData.enabled;
    reqEnabledPlu.updateBy = mySysUser.nickName;
    String jsonStr = reqEnabledPluToJson(reqEnabledPlu);
    PublicFunctions.enablePlu(jsonStr);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 仅在数据源未初始化时创建实例

    _dataSource ??= PluDataSource(
      dataModels: [], // 实际数据
      allSelectedNotifier: ValueNotifier(false),
      updateAllSelectedStatus: () {},

      onEnabled: (model) {},
      orderField: fieldOrder, // 传递列可见性配置
      // 现在可以安全访问主题
      textScheme: Theme.of(context).textTheme,
      colorScheme: Theme.of(context).colorScheme,
      canSelect: true,
      enableTitle: localizedStrings.gBtnEnable,
      disableTitle: localizedStrings.gBtnDisable,
    );

    allSelectedNotifier.addListener(() {
      if (shouldToggleAll) {
        shouldToggleAll = false;
        if (allSelectedNotifier.value) {
          _selectAll();
        } else {
          _deselectAll();
        }
      } else {}
    });
    for (var key in _columnVisibility.keys) {
      if (_columnVisibility[key] == true) {
        fieldOrder.add(key);
      }
    }
    _initPagination();
    // PublicFunctions.getProductList();
    getCurrentPageDataFormDb();
    PublicFunctions.getPluSetting();
  }

  @override
  void initState() {
    super.initState();

    _eventbus1 = eventBus.on<EventPLuDataSavedOK>().listen((event) {
      if (mounted) {
        setState(() {
          isSendDb = false;
        });
        dataModels.clear();
        getCurrentPageDataFormDb();

        if (isImportAll) {
          isImportAll = false;
          showErrorDialog(context, localizedStrings.gTipImportPluSame);
        }
      }
    });

    _eventbus2 = eventBus.on<EventProductRecList>().listen((event) {
      if (mounted) {
        List<PluDataFromDb> pluInfoList = event.obj;
        setPluToList(pluInfoList);
      }
    });

    _eventbus3 = eventBus.on<EventRespProductAddOne>().listen((event) {
      if (mounted) {
        setState(() {
          dataModels.clear();
          currentPage = 1;
          _sortAscending = false;
          getCurrentPageDataFormDb();
        });
      }
    });

    _eventbus4 = eventBus.on<EventRespProductDel>().listen((event) {
      if (mounted) {
        dataModels.clear();
        currentPage = 1;
        getCurrentPageDataFormDb();
      }
    });

    _eventbus5 = eventBus.on<EventPLuList>().listen((event) {
      if (mounted) {
        dataModels.clear();
        String jsonData = event.obj;
        if (jsonData.isEmpty) {
          setPluToList([]);
          return;
        }
        RevGetPlu revPlu = reqAddPluFromJson(jsonData);
        totalCount = revPlu.total ?? 0;
        if (revPlu.pluList == null) {
          return;
        }
        setPluToList(revPlu.pluList!);
      }
    });

    _eventbus6 = eventBus.on<EventRespExportPluList>().listen((event) {
      if (mounted) {
        String jsonData = event.obj;
        if (jsonData.isEmpty) {
          return;
        }
        if (jsonData.contains('fail')) {
          showTipInfo(localizedStrings.gTipExportFail, context);
          return;
        }
        showExportDialog(jsonData, context);
      }
    });
    _eventbus7 = eventBus.on<EventRespPluSetting>().listen((event) {
      if (mounted) {
        String jsonStr = event.obj;
        if (jsonStr.isEmpty ||
            jsonStr.contains('fail') ||
            jsonStr.contains('ok')) {
          return;
        }

        SetPluFields revPluSetting = setPluFieldsFromJson(jsonStr);
        if (revPluSetting.selPlu == null) {
          fieldOrder = ["plu", "productName"];
        } else {
          fieldOrder = ["plu", "productName"];
          for (var item in revPluSetting.selPlu!) {
            fieldOrder.add(item);
          }
        }

        for (var item in _columnVisibility.entries) {
          if (fieldOrder.contains(item.key)) {
            _columnVisibility[item.key] = true;
          } else {
            _columnVisibility[item.key] = false;
          }
        }
        setState(() {
          _onDataChanged();
        });
      }
    });
    _eventbus8 = eventBus.on<EventRespDownAllPlu>().listen((event) {
      if (mounted) {
        String jsonData = event.obj;
        if (jsonData.contains('ok')) {
          String filePath = jsonData.split(',')[1];
          selectDownloadType("1", filePath);
        }
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    allSelectedNotifier.dispose();
    gettingDataTimer?.cancel();
    dataModels.clear();
    super.dispose();
  }

  setPluToList(List<PluDataFromDb> pluInfoList) {
    for (int i = 0; i < pluInfoList.length; i++) {
      PluData newPlu = PluData(
          0, 0, 0, 0, '', '', 0, 0, 0, 0, 0, 0, 0, '', false, '', 0, 0, '', '');
      newPlu.enabled = pluInfoList[i].enabled ?? false;
      newPlu.recId = pluInfoList[i].recId;
      newPlu.plu = int.tryParse(pluInfoList[i].plu ?? '0') ?? 0;
      newPlu.productCode = int.tryParse(pluInfoList[i].productCode ?? '0') ?? 0;
      newPlu.itemCode = int.tryParse(pluInfoList[i].itemCode ?? '0') ?? 0;
      newPlu.category = pluInfoList[i].category;
      newPlu.productName = pluInfoList[i].productName;
      newPlu.price = double.tryParse(pluInfoList[i].price ?? '0') ?? 0;
      newPlu.taxType = int.tryParse(pluInfoList[i].taxType ?? '0') ?? 0;
      newPlu.generalUnit = int.tryParse(pluInfoList[i].generalUnit ?? '0') ?? 0;
      newPlu.unitWeight =
          double.tryParse(pluInfoList[i].unitWeight ?? '0') ?? 0;
      newPlu.pretare = double.tryParse(pluInfoList[i].pretare ?? '0') ?? 0;
      newPlu.limitHigh = double.tryParse(pluInfoList[i].limitHigh ?? '0') ?? 0;
      newPlu.limitLow = double.tryParse(pluInfoList[i].limitLow ?? '0') ?? 0;
      newPlu.creatAt = pluInfoList[i].createdAt?.toIso8601String() ?? " ";
      newPlu.updateAt = pluInfoList[i].updatedAt?.toIso8601String() ?? " ";
      newPlu.createBy = pluInfoList[i].createBy;
      newPlu.updateBy = pluInfoList[i].updateBy;
      newPlu.createUser = pluInfoList[i].createUser;
      newPlu.updateUser = pluInfoList[i].updateUser;
      PluDataModel tempData = PluDataModel(pluData: newPlu);
      dataModels.add(tempData);
    }
    setState(() {
      _onDataChanged();
    });
  }

  // 更新全选状态
  void _updateAllSelectedStatus() {
    final currentPageData = _getCurrentPageData();
    final allSelected = currentPageData.every((model) => model.isSelected);
    // final allUnselected = currentPageData.every((model) => !model.isSelected);
    if (allSelected && currentPageData.isNotEmpty) {
      allSelectedNotifier.value = true;
    } else {
      setState(() {});
      allSelectedNotifier.value = false;
    }
  }

  void _selectAll() {
    setState(() {
      for (final model in dataModels) {
        model.isSelected = true;
      }
    });
  }

  void _deselectAll() {
    setState(() {
      for (final model in dataModels) {
        model.isSelected = false;
      }
    });
  }

  showIconBtn(String tip, Widget icon, Color color, Function()? onPressed) {
    return Tooltip(
        message: tip, // 提示信息
        child: IconButton(
          iconSize: 24,
          color: colorScheme.primary,
          style: IconButton.styleFrom(
            disabledBackgroundColor: colorScheme.surfaceDim,
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              // 设置为矩形形状
              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
            ),
            fixedSize: const Size(40, 40), // 设置固定大小
          ),
          onPressed: onPressed,
          icon: icon,
        ));
  }

  Widget buildButtonRow() {
    // 收集所有按钮的文本

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        showSearchBox(),
        Spacer(),
        Container(
          // width: regularPadding * 4 + 40 * 4,
          alignment: Alignment.centerRight,
          child: checkSelectPlu() ? showCancelBtnList() : showSelectBtnList(),
        ),
      ],
    );
  }

  Future<ExportResult> exportRawTemplate(String filePath) async {
    try {
      Excel excel = performExportTemplate(_columnVisibility);
      File file = File(filePath);
      await file.writeAsBytes(excel.save()!);
      return ExportResult(isSuccess: true);
    } catch (e) {
      String errorMessage = localizedStrings.gTipExportError;
      if (e is FileSystemException) {
        errorMessage = localizedStrings.gTipExportFileError;
      } else if (e is IOException) {
        errorMessage = localizedStrings.gTipExportIOError;
      }
      return ExportResult(isSuccess: false, errorMessage: errorMessage);
    }
  }

  Future<void> performImport() async {
    List<int> nowPluList = [];
    for (var element in dataModels) {
      nowPluList.add(element.pluData.plu ?? 0);
    }
    String filePath = await pickFiles();
    if (filePath.isEmpty) {
      setState(() {
        isImporting = false;
      });
      return;
    }
    String msg = await handleImportExcel(nowPluList, filePath);
    if (context.mounted && msg.isNotEmpty && mounted) {
      showErrorDialog(context, msg);
      setState(() {
        isImporting = false;
      });
    }
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

  Future<String> handleImportExcel(
      List<int> nowPluList, String filePath) async {
    importPlu.clear();
    await importDataFromXlsx(filePath, nowPluList);

    if (importPlu.isEmpty) {
      return localizedStrings.gTipNoData;
    }
    if (importPlu.isNotEmpty) {
      addDataToSrv();
      setState(() {
        _onDataChanged();
      });
    }

    //新增的PLU列表

    return localizedStrings.gTipImportPluOK;
  }

  bool isImportAll = false; //是否全部导入，有重复的PLU会去掉
  bool checkImportPLu(int plu, List<int> nowPluList) {
    if (nowPluList.isEmpty) {
      return true;
    }
    for (var item in nowPluList) {
      if (item == plu) {
        isImportAll = true;
        return false;
      }
    }
    return true;
  }

  Future<void> importDataFromXlsx(String filePath, List<int> nowPluList) async {
    // 读取Excel文件
    Excel? excel = Excel.decodeBytes(await File(filePath).readAsBytes());

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
        String unit = rowData['GeneralUnit'].toString();
        unit = unit.replaceAll(' ', '');
        unit = unit.toLowerCase();
        int unitInt = 0;
        for (var entry in pluUnit.entries) {
          if (entry.value == unit) {
            unitInt = entry.key;
            break;
          }
        }

        String taxStr = rowData['TaxType'].toString();
        int taxInt = 0;
        for (var entry in pluTax.entries) {
          if (entry.value == taxStr) {
            taxInt = entry.key;
            break;
          }
        }

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
          rowData.containsKey('GeneralUnit') ? unitInt : 0,
          rowData.containsKey('TaxType') ? taxInt : 0,
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
          '',
          rowData.containsKey('ebabled')
              ? rowData['ebabled'].toString() == '1'
              : true,
          '',
          0,
          0,
          '',
          '',
        );
        PluDataModel pluDataModel = PluDataModel(pluData: dessert);

        if (checkImportPLu(dessert.plu ?? 0, nowPluList)) {
          importPlu.add(pluDataModel);
        }
      }
    }

    return;
  }

  double roundToTwoDecimalPlaces(double num) {
    double multiplier = 100;
    return (num * multiplier).round() / multiplier;
  }

  String checkImportData(List<PluDataModel> dataSource) {
    for (var dataRow in dataSource) {
      if (!dataRow.isSelected) {
        continue;
      }

      // 检查PLU相关条件
      if (dataRow.pluData.plu == null) {
        return '${localizedStrings.gPluPlu}  null. ${localizedStrings.gPluPluName} : ${dataRow..pluData.productName}';
      }
      if (dataRow.pluData.plu == 0) {
        return '${localizedStrings.gPluPlu} : 1-99999. ${localizedStrings.gPluPluName} : ${dataRow..pluData.productName}';
      }

      // 检查Product Name相关条件
      if (dataRow.pluData.productName == null) {
        return '${localizedStrings.gPluPluName} null. ${localizedStrings.gPluPlu} : ${dataRow.pluData.plu}';
      }
      if (dataRow.pluData.productName == '') {
        return "${localizedStrings.gPluPluName}   . ${localizedStrings.gPluPlu} : ${dataRow.pluData.plu}";
      }

      // 检查是否有PLU值重复的情况
      List<int?> pluValues = dataSource.map((row) => row.pluData.plu).toList();
      int pluCount =
          pluValues.where((plu) => plu == dataRow.pluData.plu).length;
      if (pluCount > 1) {
        return '${localizedStrings.gPluPlu} ${localizedStrings.gTipPluDuplicated}.  ${localizedStrings.gPluPlu}: ${dataRow.pluData.plu}';
      }
    }
    return '';
  }

  //下发全部PLU
  void sendAllData(String saveType) {
    if (dataModels.isEmpty) {
      isSendDb = false;
      return showErrorDialog(context, localizedStrings.gTipNoData);
    }
    bool selectRow = false;
    for (var dessert in dataModels) {
      if (dessert.isSelected) {
        selectRow = true;
        break;
      }
    }
    if (!selectRow) {
      isSendDb = false;
      return showErrorDialog(context, localizedStrings.gTipNoDataSelected);
    }
    String msg = checkImportData(dataModels);
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
    List<PluDataFromDb> pluList = [];
    for (var info in dataModels) {
      if (info.isSelected) {
        pluList.add(PluDataFromDb(
          recId: 0,
          plu: info.pluData.plu.toString(),
          productCode: info.pluData.productCode.toString(),
          itemCode: info.pluData.itemCode.toString(),
          category:
              info.pluData.category == null ? '-' : info.pluData.category!,
          productName: info.pluData.productName!,
          generalUnit: info.pluData.generalUnit.toString(),
          taxType: info.pluData.taxType.toString(),
          price: info.pluData.price.toString(),
          unitWeight: info.pluData.unitWeight.toString(),
          pretare: info.pluData.pretare.toString(),
          limitHigh: info.pluData.limitHigh.toString(),
          limitLow: info.pluData.limitLow.toString(),
          enabled: info.pluData.enabled,
          createBy: info.pluData.createBy,
          updateBy: info.pluData.updateBy,
        ));
      }
    }
    sendPluListInBatches(pluList, saveType);
  }

  void addDataToSrv() {
    List<PluDataFromDb> pluList = [];
    for (var info in importPlu) {
      pluList.add(PluDataFromDb(
        recId: 0,
        plu: info.pluData.plu.toString(),
        productCode: info.pluData.productCode.toString(),
        itemCode: info.pluData.itemCode.toString(),
        category: info.pluData.category == null ? '-' : info.pluData.category!,
        productName: info.pluData.productName!,
        generalUnit: info.pluData.generalUnit.toString(),
        taxType: info.pluData.taxType.toString(),
        price: info.pluData.price.toString(),
        unitWeight: info.pluData.unitWeight.toString(),
        pretare: info.pluData.pretare.toString(),
        limitHigh: info.pluData.limitHigh.toString(),
        limitLow: info.pluData.limitLow.toString(),
        enabled: info.pluData.enabled,
        createBy: info.pluData.createBy,
        updateBy: info.pluData.updateBy,
        createUser: mySysUser.nickName,
        updateUser: mySysUser.nickName,
      ));
    }
    sendPluListInBatches(pluList, "1");
  }

  void sendPluListInBatches(List<PluDataFromDb> pluList, String saveType) {
    const batchSize = 100;
    int totalItems = pluList.length;

    // 创建一个定时器的流控制器
    final StreamController<Timer> timerController = StreamController<Timer>();

    // 创建一个定时器，每隔4秒向流中添加一个新的定时器实例
    Timer.periodic(const Duration(milliseconds: 50), (Timer t) {
      timerController.add(t);
    });

    // 创建一个索引，用于跟踪当前发送到哪个批次了
    int currentIndex = 0;
    int batchNumber = 0;

    // 监听定时器流，当有新的定时器实例时，发送下一批数据
    timerController.stream.listen((Timer timer) {
      if (currentIndex < totalItems) {
        int endIndex = currentIndex + batchSize;
        endIndex = endIndex < totalItems ? endIndex : totalItems;
        List<PluDataFromDb> batch = pluList.sublist(currentIndex, endIndex);
        String jsonData = jsonEncode(batch);
        if (saveType == "1") {
          batchNumber = batchNumber + 1;
          ReqImportPlu importPluReq = ReqImportPlu(
            index: batchNumber,
            pluList: batch,
            total: totalItems,
          );
          String jsonStr = reqAddPluToJson(importPluReq);
          PublicFunctions.addProduct(jsonStr);
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

  void showAddPluDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AddPluInfoDialog(
            type: 0,
            selField: fieldOrder,
            pluInfo: PluData(
              0,
              0,
              0,
              0,
              '0',
              '0',
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              '0',
              true,
              '',
              0,
              0,
              '',
              '',
            ),
            pluList: getPluList(),
            onSave: (PluData pluData) {
              String jsonData = jsonEncode(PluDataFromDb(
                recId: 0,
                plu: pluData.plu.toString(),
                productCode: pluData.productCode.toString(),
                itemCode: pluData.itemCode.toString(),
                category: pluData.category == null ? '-' : pluData.category!,
                productName: pluData.productName!,
                generalUnit: pluData.generalUnit.toString(),
                taxType: pluData.taxType.toString(),
                price: pluData.price.toString(),
                unitWeight: pluData.unitWeight.toString(),
                pretare: pluData.pretare.toString(),
                limitHigh: pluData.limitHigh.toString(),
                limitLow: pluData.limitLow.toString(),
                createBy: mySysUser.userId,
                updateBy: mySysUser.userId,
              ));

              PublicFunctions.addOneProduct(jsonData);
            });
      },
    );
  }

  bool checkSelectPlu() {
    bool res = false;
    List<PluDataModel> selectedPluInfos = [];
    if (dataModels.isEmpty) {
      return res;
    }

    for (var dessert in dataModels) {
      if (dessert.isSelected) {
        selectedPluInfos.add(dessert);

        res = true;
        break;
      }
    }

    return res;
  }

  Widget showSelectBtnList() {
    return Row(
      children: [
        showIconBtn(
            localizedStrings.gBtnDownload,
            getSvgIcon(
                downloadToScaleSvgIcon(),
                24,
                24,
                dataModels.isNotEmpty
                    ? colorScheme.onPrimary
                    : colorScheme.surfaceContainerHighest),
            colorScheme.onTertiaryFixedVariant,
            dataModels.isEmpty
                ? null
                : () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ShowNormalTipDialog(
                            title: localizedStrings.fTipTitle,
                            msg: localizedStrings.downAllPluTip,
                          );
                        }).then((value) async {
                      if (value == true) {
                        final result = await getAppFilePath();
                        final filePath = path.join(result, 'PluList.xlsx');
                        PublicFunctions.downAllPlu(filePath);
                      }
                    });
                  }),
        SizedBox(
          width: regularPadding,
        ),
        showIconBtn(
          localizedStrings.gBtnAdd,
          getSvgIcon(addSvgIcon(), 24, 24, colorScheme.onPrimary),
          colorScheme.primary,
          isImporting
              ? null
              : () {
                  showAddPluDialog();
                },
        ),
        SizedBox(
          width: regularPadding,
        ),
        //导出
        showIconBtn(
          localizedStrings.gBtnExport,
          getSvgIcon(
              exportSvgIcon(),
              24,
              24,
              dataModels.isNotEmpty
                  ? colorScheme.onPrimary
                  : colorScheme.surfaceContainerHighest),
          colorScheme.primary,
          dataModels.isNotEmpty
              ? () async {
                  final directory = Directory.current.path;
                  String? outputFile = (await FilePicker.platform.saveFile(
                    initialDirectory: directory,
                    type: FileType.custom,
                    dialogTitle: 'Output file:',
                    allowedExtensions: ["csv"],
                    fileName: 'export_product.csv',
                  ));
                  if (outputFile == null) {
                    return;
                  }
                  if (!outputFile.contains(".csv")) {
                    outputFile = "$outputFile.csv";
                  }

                  SearchPlu searchPluInfo = SearchPlu(
                    plu: pluCtl.text,
                    category: categoryCtl.text,
                    pluName: pluNameCtl.text,
                    setEnabled: false,
                    enabled: false,
                  );

                  ExportPlu exportPluInfo = ExportPlu(
                    translation: getTranslationMap(),
                    searchPlu: searchPluInfo,
                    path: outputFile,
                  );

                  String jsonStr = jsonEncode(exportPluInfo);
                  PublicFunctions.exportProduct(jsonStr);
                }
              : null,
        ),

        SizedBox(
          width: regularPadding,
        ),
        //导入
        showIconBtn(
            localizedStrings.gBtnImport,
            getSvgIcon(importSvgIcon(), 24, 24, colorScheme.onPrimary),
            colorScheme.primary,
            isImporting
                ? null
                : () {
                    setState(() {
                      isImporting = true;
                    });
                    performImport();
                  }),
        SizedBox(
          width: regularPadding,
        ),
        //设置
        showIconBtn(
            localizedStrings.gBtnReportSetting,
            getSvgIcon(reportSettingSvgIcon(), 24, 24, colorScheme.onPrimary),
            colorScheme.primary,
            isImporting
                ? null
                : () async {
                    _showMultiSelectDialog(context);
                  }),
        SizedBox(
          width: regularPadding,
        ),
        //模板
        showIconBtn(
            localizedStrings.gBtnGetPluTemplate,
            getSvgIcon(rawTemplateSvgIcon(), 24, 24, colorScheme.onPrimary),
            colorScheme.primary,
            isImporting
                ? null
                : () async {
                    // 让用户选择文件夹
                    final result = await FilePicker.platform.getDirectoryPath();
                    if (result == null) {
                      return '';
                    }
                    final String filePath =
                        path.join(result, 'ProductTemplate.xlsx');
                    ExportResult msg = await exportRawTemplate(filePath);
                    if (!mounted) return '';
                    if (msg.isSuccess) {
                      showExportDialog(filePath, context);
                    } else {
                      showTipInfo(msg.errorMessage!, context);
                    }
                  }),
        SizedBox(
          width: regularPadding,
        ), //批量删除
        showIconBtn(
          localizedStrings.fClearBtn,
          getSvgIcon(
              clearSvgIcon(),
              24,
              24,
              dataModels.isNotEmpty
                  ? colorScheme.onPrimary
                  : colorScheme.surfaceContainerHighest),
          colorScheme.error,
          dataModels.isEmpty
              ? null
              : () {
                  showClearTipDialog();
                },
        ),
        SizedBox(
          width: regularPadding,
        ),
      ],
    );
  }

  void showClearTipDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowDeleteTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.fClearDataBtn,
        );
      },
    ).then((value) {
      if (value) {
        PublicFunctions.clearAllProduct();
      }
    });
  }

  showSearchBox() {
    return Container(
      height: 68,
      color: Theme.of(context).colorScheme.surface,
      child: Row(children: [
        SizedBox(
            width: 120,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: pluCtl,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 16,
                      ),
                      onPressed: () {
                        pluCtl.clear();
                      },
                    ),
                    hintText: "PLU",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
        SizedBox(
            width: 150,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: pluNameCtl,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 16,
                      ),
                      onPressed: () {
                        pluNameCtl.clear();
                      },
                    ),
                    hintText: localizedStrings.gPluName,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
        SizedBox(
            width: 120,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: categoryCtl,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 16,
                      ),
                      onPressed: () {
                        categoryCtl.clear();
                      },
                    ),
                    hintText: localizedStrings.gPluCategory,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
        Tooltip(
            message: localizedStrings.search, // 翻译
            child: IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  currentPage = 1;
                  getCurrentPageDataFormDb();
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
                  pluCtl.clear();
                  pluNameCtl.clear();
                  categoryCtl.clear();
                  getCurrentPageDataFormDb();
                });
              },
              iconSize: 24,
            )),
      ]),
    );
  }

  Widget showCancelBtnList() {
    return Row(
      children: [
        showIconBtn(
          localizedStrings.gBtnDownload,
          getSvgIcon(
              downloadToScaleSvgIcon(),
              24,
              24,
              checkSelectPlu()
                  ? colorScheme.onPrimary
                  : colorScheme.surfaceContainerHighest),
          colorScheme.onTertiaryFixedVariant,
          !checkSelectPlu()
              ? null
              : () async {
                  List<PluDataModel> selectedPluInfos = [];

                  bool selectRow = false;
                  for (var dessert in dataModels) {
                    if (dessert.isSelected) {
                      selectedPluInfos.add(dessert);
                      selectRow = true;
                    }
                  }
                  if (!selectRow) {
                    isSendDb = false;
                    return showErrorDialog(
                        context, localizedStrings.gTipNoDataSelected);
                  }
                  for (var dessert in selectedPluInfos) {
                    if (dessert.pluData.enabled == false) {
                      isSendDb = false;
                      return showErrorDialog(
                          context, localizedStrings.gTipDownPluDisabled);
                    }
                  }

                  String msg = checkImportData(selectedPluInfos);
                  if (msg != "") {
                    isSendDb = false;
                    return showErrorDialog(context, msg);
                  }

                  String msgStr = await downloadFormExcel(selectedPluInfos);
                  if (!msgStr.contains("OK") && mounted) {
                    showTipInfo(msgStr, context);
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
        SizedBox(
          width: regularPadding,
        ),
        //批量启用
        showIconBtn(
          localizedStrings.gBtnEnable,
          getSvgIcon(
              enabledSvgIcon(),
              24,
              24,
              checkSelectPlu()
                  ? colorScheme.onPrimary
                  : colorScheme.surfaceContainerHighest),
          colorScheme.onTertiaryFixedVariant,
          !checkSelectPlu()
              ? null
              : () {
                  _updateEnabledItems(true);
                },
        ),
        SizedBox(
          width: regularPadding,
        ),
        //批量停用
        showIconBtn(
          localizedStrings.gBtnDisable,
          getSvgIcon(
              disabledSvgIcon(),
              24,
              24,
              checkSelectPlu()
                  ? colorScheme.onPrimary
                  : colorScheme.surfaceContainerHighest),
          colorScheme.error,
          !checkSelectPlu()
              ? null
              : () {
                  _updateEnabledItems(false);
                },
        ),
        SizedBox(
          width: regularPadding,
        ),

        //批量删除
        showIconBtn(
          localizedStrings.gBtnDelete,
          getSvgIcon(
              deleteSvgIcon(),
              24,
              24,
              checkSelectPlu()
                  ? colorScheme.onPrimary
                  : colorScheme.surfaceContainerHighest),
          colorScheme.error,
          !checkSelectPlu()
              ? null
              : () {
                  showDeleteDialog();
                },
        ),
        SizedBox(
          width: regularPadding,
        ),
      ],
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowDeleteTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.fConfirmDelete,
        );
      },
    ).then((value) {
      if (value) {
        _deleteSelectedItems();
      }
    });
  }

  _showMultiSelectDialog(BuildContext content) {
    Map<String, FieldNameStatus> colNamesMap = {};
    for (var item in _columnVisibility.entries) {
      colNamesMap[item.key] =
          FieldNameStatus(getColumnName(item.key), item.value);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          options: colNamesMap,
          context: context,
          selectedOptions: fieldOrder,
        );
      },
    ).then((value) {
      if (value != null) {
        List<String> selectedOptions = value;
        fieldOrder = selectedOptions;

        SetPluFields setInfo = SetPluFields(selPlu: fieldOrder);
        String jsonStr = setPluFieldsToJson(setInfo);
        PublicFunctions.setPluFields(jsonStr);

        for (var item in _columnVisibility.entries) {
          if (selectedOptions.contains(item.key)) {
            _columnVisibility[item.key] = true;
          } else {
            _columnVisibility[item.key] = false;
          }
        }
        setState(() {
          _onDataChanged();
        });
      }
    });
  }

  //确定下发类型：全部下发，增量下发
  void _showDownloadTypeDialog(BuildContext context, String filePath) {
    String localDownloadType = _downloadType; // 临时变量用于管理对话框内的状态

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 500,
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Column(
                  children: [
                    // 头部
                    ...dialogHeadStyle(
                        context, localizedStrings.gTitleConfirm, false),

                    // 中部
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 400,
                              child: RadioListTile(
                                title: Text(
                                  localizedStrings.gTipDownloadAllPlu,
                                  style: getTextStyle(),
                                ),
                                value: '1',
                                groupValue: localDownloadType,
                                onChanged: (value) {
                                  setState(() {
                                    localDownloadType = '1';
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 400,
                              child: RadioListTile(
                                title: Text(
                                  localizedStrings.gTipUpdatePlu,
                                  style: getTextStyle(),
                                ),
                                value: '2',
                                groupValue: localDownloadType,
                                onChanged: (value) {
                                  setState(() {
                                    localDownloadType = '2';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 底部
                    Container(
                      height: 96,
                      width: 400,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                fixedSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _downloadType = localDownloadType; // 更新外部状态
                                });
                                Navigator.of(ctx).pop(false);
                                selectDownloadType(_downloadType, filePath);
                              },
                              child: Text(
                                localizedStrings.gBtnConfirm,
                                style: getTextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                fixedSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(ctx).pop(false);
                              },
                              child: Text(
                                localizedStrings.gBtnCancel,
                                style: getTextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
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
        return SelectScalesPageNew(
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

  Future<String> downloadFormExcel(List<PluDataModel> desserts) async {
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
          TextCellValue(dessert.pluData.plu?.toString() ?? ''),
          TextCellValue(dessert.pluData.productName ?? ''),
          TextCellValue(dessert.pluData.generalUnit?.toString() ?? ''),
          TextCellValue(dessert.pluData.taxType?.toString() ?? ''),
          TextCellValue(dessert.pluData.price?.toString() ?? ''),
          TextCellValue(dessert.pluData.unitWeight?.toString() ?? ''),
          TextCellValue(dessert.pluData.pretare?.toString() ?? ''),
          TextCellValue(dessert.pluData.limitHigh?.toString() ?? ''),
          TextCellValue(dessert.pluData.limitLow?.toString() ?? ''),
        ]);
      }
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

  String getSortField() {
    String field = _sortField;

    switch (_sortField) {
      case 'productName':
        field = 'product_name';
        break;
      case 'generalUnit':
        field = 'general_unit';
        break;
      case 'taxType':
        field = 'tax_type';
        break;
      case 'unitWeight':
        field = 'unit_weight';
        break;
      case 'limitHigh':
        field = 'limit_high';
        break;
      case 'limitLow':
        field = 'limit_low';
        break;
      case 'productCode':
        field = 'product_code';
        break;
      case 'itemCode':
        field = 'item_code';
        break;
    }
    return field;
  }

  void _sortData() {
    currentPage = 1;
    getCurrentPageDataFormDb();
  }

  GridColumn getColumnWidget(double width, String columnName, String title) {
    return GridColumn(
      width: width,
      allowSorting: true,
      columnName: columnName,
      label: InkWell(
        onTap: () {
          setState(() {
            if (_sortField == columnName) {
              // 如果已经是当前排序字段，则切换排序顺序
              _sortAscending = !_sortAscending;
            } else {
              // 否则设置为新的排序字段，默认升序
              _sortField = columnName;
              _sortAscending = true;
            }
            _sortData();
          });
        },
        child: Container(
          color: colorScheme.surfaceDim,
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: getTitleTextStyle(color: colorScheme.onSurface),
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

  void performModifyPlu(PluDataModel modifyPlu) {
    PluDataFromDb editPlus = PluDataFromDb();
    editPlus = PluDataFromDb(
      recId: modifyPlu.pluData.recId,
      plu: modifyPlu.pluData.plu.toString(),
      productCode: modifyPlu.pluData.productCode.toString(),
      itemCode: modifyPlu.pluData.itemCode.toString(),
      category: modifyPlu.pluData.category == null
          ? '-'
          : modifyPlu.pluData.category!,
      productName: modifyPlu.pluData.productName!,
      generalUnit: modifyPlu.pluData.generalUnit.toString(),
      taxType: modifyPlu.pluData.taxType.toString(),
      price: modifyPlu.pluData.price.toString(),
      unitWeight: modifyPlu.pluData.unitWeight.toString(),
      pretare: modifyPlu.pluData.pretare.toString(),
      limitHigh: modifyPlu.pluData.limitHigh.toString(),
      limitLow: modifyPlu.pluData.limitLow.toString(),
      enabled: modifyPlu.pluData.enabled,
      createBy: modifyPlu.pluData.createBy,
      updateBy: mySysUser.userId,
      createUser: mySysUser.nickName,
      updateUser: mySysUser.nickName,
    );

    String jsonData = jsonEncode(editPlus);
    PublicFunctions.modifyProduct(jsonData);
  }

  List<int> getPluList() {
    List<int> pluList = [];
    for (var item in dataModels) {
      pluList.add(item.pluData.plu!);
    }
    return pluList;
  }

  List<GridColumn> showFieldTitle(double itemWidth) {
    List<GridColumn> fieldTitle = [];
    for (int i = 0; i < fieldOrder.length; i++) {
      String fieldName = fieldOrder[i];

      switch (fieldName) {
        case 'plu':
          fieldTitle
              .add(getColumnWidget(itemWidth, 'plu', localizedStrings.gPluPlu));
          break;
        case 'productName':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'productName', localizedStrings.gPluPluName));
          break;
        case 'category':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'category', localizedStrings.gPluCategory));
          break;
        case 'price':
          fieldTitle.add(
              getColumnWidget(itemWidth, 'price', localizedStrings.gPluPrice));
          break;
        case 'generalUnit':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'generalUnit', localizedStrings.gPluWgtUnit));
          break;
        case 'taxType':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'taxType', localizedStrings.gPluTaxType));
          break;
        case 'unitWeight':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'unitWeight', localizedStrings.gPluUnitWgt));
          break;
        case 'pretare':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'pretare', localizedStrings.gPluPretare));
          break;
        case 'limitHigh':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'limitHigh', localizedStrings.gPluLimitHigh));
          break;
        case 'limitLow':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'limitLow', localizedStrings.gPluLimitLow));
          break;
        case 'productCode':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'productCode', localizedStrings.gPluPluCode));
          break;
        case 'itemCode':
          fieldTitle.add(getColumnWidget(
              itemWidth, 'itemCode', localizedStrings.gPluItemCode));
          break;
        default:
          break;
      }
    }

    return fieldTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: regularPadding),
            height: leftBarIconHeight,
            child: buildButtonRow(),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                  left: regularPadding, right: regularPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double tableWidth = constraints.maxWidth;

                  tableWidth = tableWidth - 50 - 120;

                  int count = 0;
                  for (var key in _columnVisibility.keys) {
                    if (_columnVisibility[key]!) {
                      count++;
                    }
                  }

                  double itemWidth = tableWidth / (count);

                  itemWidth = itemWidth < 150 ? 150 : itemWidth;

                  return SfDataGrid(
                    headerRowHeight: 48.0,
                    frozenColumnsCount: 1,
                    footerFrozenColumnsCount: 1,
                    columnWidthMode: ColumnWidthMode.fill,
                    gridLinesVisibility: GridLinesVisibility.horizontal,
                    headerGridLinesVisibility: GridLinesVisibility.none,
                    selectionMode: SelectionMode.none,
                    columnResizeMode: ColumnResizeMode.onResize,
                    allowSorting: false,
                    onCellTap: (details) {
                      // 获取点击的行索引
                      int index = 0; //(currentPage - 1) * pageSize;
                      int rowIndex = details.rowColumnIndex.rowIndex;
                      rowIndex = rowIndex + index;

                      if (rowIndex > 0) {
                        var dataRow = dataModels[rowIndex - 1];

                        showDialog(
                          context: context,
                          builder: (context) => AddPluInfoDialog(
                            type: 1,
                            selField: fieldOrder,
                            pluList: getPluList(),
                            pluInfo: dataRow.pluData,
                            onSave: (updatedPlu) {
                              setState(() {
                                dataModels[rowIndex - 1] =
                                    PluDataModel(pluData: updatedPlu);
                                _onDataChanged();
                                performModifyPlu(dataModels[rowIndex - 1]);
                              });
                            },
                          ),
                        );
                      }
                    },
                    onColumnResizeUpdate: (detail) {
                      setState(() {
                        columnWidth[detail.column.columnName] = detail.width;
                      });
                      return true;
                    },
                    source: _dataSource ??
                        PluDataSource(
                          dataModels: _getCurrentPageData(),
                          allSelectedNotifier: allSelectedNotifier,
                          updateAllSelectedStatus: _updateAllSelectedStatus,
                          onEnabled: _handleEnabled,
                          orderField: fieldOrder,
                          textScheme: textTheme,
                          colorScheme: colorScheme,
                          canSelect: true,
                          enableTitle: localizedStrings.gBtnEnable,
                          disableTitle: localizedStrings.gBtnDisable,
                        ),
                    columns: [
                      GridColumn(
                        width: 50,
                        allowSorting: false,
                        columnName: 'select',
                        label: ValueListenableBuilder<bool>(
                          valueListenable: allSelectedNotifier,
                          builder: (context, value, child) {
                            return Container(
                                color: colorScheme.surfaceDim,
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.centerLeft,
                                child: Checkbox(
                                  value: value,
                                  onChanged: (bool? newValue) {
                                    shouldToggleAll = true;
                                    allSelectedNotifier.value =
                                        newValue ?? false;
                                  },
                                ));
                          },
                        ),
                      ),
                      ...showFieldTitle(itemWidth),
                      GridColumn(
                        width: 120,
                        allowSorting: false,
                        columnName: 'enable',
                        label: Container(
                          color: colorScheme.surfaceDim,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(localizedStrings.gStatus),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // 分页控件
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            // decoration: BoxDecoration(
            //   border: Border(
            //     top: BorderSide(color: const Color.fromARGB(255, 44, 9, 197)!),
            //   ),
            // ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 页码导航
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.first_page),
                      onPressed: currentPage > 1 ? () => _changePage(1) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: currentPage > 1
                          ? () => _changePage(currentPage - 1)
                          : null,
                    ),
                    Text(
                      localizedStrings.tipPageSequnce +
                          ' $currentPage / $totalPages ${localizedStrings.tipPage}',
                      style: getTitleTextStyle(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: currentPage < totalPages
                          ? () => _changePage(currentPage + 1)
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.last_page),
                      onPressed: currentPage < totalPages
                          ? () => _changePage(totalPages)
                          : null,
                    ),
                    SizedBox(
                      width: regularPadding,
                    ),
                    Text(
                      localizedStrings.tipJumpPage,
                      style: getTitleTextStyle(),
                    ),
                    SizedBox(
                      width: regularPadding,
                    ),
                    SizedBox(
                      width: 70,
                      height: 38,
                      child: TextField(
                        controller: pageController,
                        enabled: totalPages > 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // 只允许输入数字
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0.0))),
                          hintText: '',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface, // 设置提示文本颜色
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),

                        maxLines: 1,
                        minLines: 1,
                        expands: false,

                        // 监听回车键
                        onSubmitted: (value) {
                          if (value.isEmpty) {
                            return;
                          }

                          if (int.parse(value) > 0) {
                            int page = int.tryParse(value) ?? 1;
                            _changePage(page);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: regularPadding,
                    ),
                    Text(
                      localizedStrings.tipPage,
                      style: getTitleTextStyle(),
                    ),
                  ],
                ),
                SizedBox(
                  width: largePadding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExportResult {
  bool isSuccess;
  String? errorMessage;
  ExportResult({required this.isSuccess, this.errorMessage});
}
