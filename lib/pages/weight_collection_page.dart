import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/new_get_recs.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/settingparam_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/wgt_value_data.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/functions/adaptive.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/total_wgt_common.dart';
import 'package:provider/provider.dart';
import '../widget/page_head.dart';
import 'package:t_max/widget/f_open_file.dart';

class WeightDataCollectionPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const WeightDataCollectionPage({super.key, required this.onNavigate, required this.lastRouteName});

  @override
  State<WeightDataCollectionPage> createState() => WeightDataCollectionPageState();
}

class WeightDataCollectionPageState extends State<WeightDataCollectionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  late TableState _tableState;
  PluData? selectedPluData;
  List<int> mySelScaleIdList = [];
  Map<int, WeightInfo> scaleWeightMap = {};
  
  // 重量状态监听器
  final ValueNotifier<String> totalWeightNotifier = ValueNotifier<String>("0.00");
  final ValueNotifier<bool> totalWgtStableNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> totalWgtUnitNotifier = ValueNotifier<String>("kg");
  
  late Timer updateTimer;
  Timer? scaleCheckTimer;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _tableState = TableState(mode: int.tryParse(wgtCollectionMode) ?? 0);
    _initEventBus();
    startTimer();
    
    scaleCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) checkSameScale();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tableState.loadPage(1);
        PublicFunctions.getUIConfNormal(wgtCollectionMode);
        PublicFunctions.getProductList();
      }
    });
  }

  void _initEventBus() {
    _subscriptions.add(eventBus.on<EventUpdateSettingParam>().listen((event) {
      if (mounted) PublicFunctions.getUIConfNormal(wgtCollectionMode);
    }));
    _subscriptions.add(eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) setState(() => mySettingParam = event.obj);
    }));
    _subscriptions.add(eventBus.on<EventRevAddRec>().listen((event) {
      if (mounted) _tableState.loadPage(1);
    }));
    _subscriptions.add(eventBus.on<EventRespGetAllWgtRecs>().listen((event) {
      if (mounted) {
        RevAllWgtRecs getAllWgtInfo = revAllWgtRecsFromJson(event.obj);
        if ((getAllWgtInfo.totalCount ?? 0) > 0) {
          _tableState.addData(List<ScaleRecInfo>.from(getAllWgtInfo.scaleRecInfos ?? []));
          _tableState.setTotalCount(getAllWgtInfo.totalCount ?? 0);
        } else {
          _tableState.allData.clear();
          _tableState.setTotalCount(0);
        }
      }
    }));
    _subscriptions.add(eventBus.on<EventDelAllWgtRecs>().listen((event) {
      if (mounted) {
        _tableState.allData.clear();
        _tableState.loadPage(1);
      }
    }));
    _subscriptions.add(eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        ReqWeightCountine tempWeight = event.obj;
        if (tempWeight.scaleId != null && tempWeight.msgBody != null) {
          scaleWeightMap[tempWeight.scaleId!] = WeightInfo(
            weight: tempWeight.msgBody!.weightVal.toString(),
            unit: tempWeight.msgBody!.weightUnit,
            stable: tempWeight.msgBody!.isStable,
          );
          updateTotalWeightAndStable();
        }
      }
    }));
    _subscriptions.add(eventBus.on<EventProductRecList>().listen((event) {
      if (mounted) {
        List<PluDataFromDb> pluInfoList = event.obj;
        setState(() {
          myPluInfoList.clear();
          for (var item in pluInfoList) {
            if (!(item.enabled ?? false)) continue;
            PluData newPlu = PluData(0, 0, 0, 0, '', '', 0, 0, 0, 0, 0, 0, 0, '', false, '', 0, 0, '', '');
            newPlu.recId = item.recId;
            newPlu.plu = int.tryParse(item.plu ?? '0') ?? 0;
            newPlu.productName = item.productName;
            newPlu.unitWeight = double.tryParse(item.unitWeight ?? '0') ?? 0;
            myPluInfoList.add(newPlu);
          }
        });
      }
    }));
    _subscriptions.add(eventBus.on<EventAddWgtRec>().listen((event) {
      if (mounted) _tableState.loadPage(1);
    }));
    _subscriptions.add(eventBus.on<EventExportAllRecs>().listen((event) {
      if (mounted) {
        String resString = event.obj;
        if (resString.contains('ok')) {
          String filePath = resString.split(',')[1];
          showExportDialog(filePath, context);
        } else {
          showTipInfo(S.of(context).gTipExportFail + ": $resString", context);
        }
      }
    }));
  }

  void startTimer() {
    updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        updateTotalWeightAndStable();
      }
    });
  }

  void updateTotalWeightAndStable() {
    double total = 0.0;
    bool allStable = true;
    String unit = "kg";
    
    if (mySelScaleIdList.isEmpty) {
      allStable = false;
    } else {
      for (var id in mySelScaleIdList) {
        final wgt = scaleWeightMap[id];
        if (wgt == null) {
          allStable = false;
          break;
        }
        total += double.tryParse(wgt.weight) ?? 0.0;
        if (!wgt.stable) allStable = false;
        unit = wgt.unit;
      }
    }
    
    totalWeightNotifier.value = total.toStringAsFixed(2);
    totalWgtStableNotifier.value = allStable;
    totalWgtUnitNotifier.value = unit;
  }

  void checkSameScale() {
    if (mySelScaleIdList.length < 2) return;
    
    String? firstSn;
    for (var id in mySelScaleIdList) {
      final scale = myAllScalesList.firstWhere((s) => s.scaleId == id, orElse: () => myAllScalesList.first);
      if (firstSn == null) {
        firstSn = scale.scaleSn;
      } else if (firstSn != scale.scaleSn) {
        showTipInfo("Scales must have same SN for collection", context);
        break;
      }
    }
  }

  Future<void> sendDataToDb() async {
    if (mySelScaleIdList.isEmpty) return;
    if (!totalWgtStableNotifier.value) return;

    final firstScaleId = mySelScaleIdList.first;
    final firstScale = myAllScalesList.firstWhere((s) => s.scaleId == firstScaleId, orElse: () => myAllScalesList.first);
    
    final headRec = Header()
      ..weight = totalWeightNotifier.value.toString()
      ..weightUnit = totalWgtUnitNotifier.value
      ..plu = selectedPluData?.plu.toString() ?? ""
      ..productName = selectedPluData?.productName ?? ""
      ..scaleModel = firstScale.scaleModel
      ..scaleSn = firstScale.scaleSn
      ..scaleName = firstScale.scaleName
      ..userNo = mySysUser.userId.toString()
      ..userName = mySysUser.userName
      ..createdAt = DateTime.now();

    final detailRecs = scaleWeightMap.entries
        .where((e) => mySelScaleIdList.contains(e.key))
        .map((e) {
      final scale = myAllScalesList.firstWhere((s) => s.scaleId == e.key, orElse: () => myAllScalesList.first);
      return NewWgtDetail()
        ..scaleName = scale.scaleName
        ..scaleModel = scale.scaleModel
        ..scaleSn = scale.scaleSn
        ..weight = e.value.weight
        ..weightUnit = e.value.unit
        ..createdAt = DateTime.now();
    }).toList();

    // 手动构建干净的 Map，避免 null 值引起后端 Go 解析错误
    Map<String, dynamic> headMap = {
      "Weight": totalWeightNotifier.value.toString(),
      "WeightUnit": totalWgtUnitNotifier.value,
      "Plu": selectedPluData?.plu.toString() ?? "",
      "ProductName": selectedPluData?.productName ?? "",
      "ScaleModel": firstScale.scaleModel,
      "ScaleSn": firstScale.scaleSn,
      "ScaleName": firstScale.scaleName,
      "UserNo": mySysUser.userId.toString(),
      "UserName": mySysUser.userName,
    };

    List<Map<String, dynamic>> detailList = detailRecs.map((e) => {
      "ScaleName": e.scaleName,
      "ScaleModel": e.scaleModel,
      "ScaleSn": e.scaleSn,
      "Weight": e.weight,
      "WeightUnit": e.weightUnit,
    }).toList();

    Map<String, dynamic> data = {
      "Mode": mySettingParam.scaleMode,
      "HeadRec": headMap,
      "DetailRec": detailList,
    };

    PublicFunctions.addSummaryData(jsonEncode(data));
    showTipInfo(S.of(context).fSaveSuccess, context);
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    updateTimer.cancel();
    scaleCheckTimer?.cancel();
    totalWeightNotifier.dispose();
    totalWgtStableNotifier.dispose();
    totalWgtUnitNotifier.dispose();
    _tableState.dispose();
    super.dispose();
  }

  void addOrRemoveSelScale(int scaleId) {
    if (mySelScaleIdList.contains(scaleId)) {
      mySelScaleIdList.remove(scaleId);
      PublicFunctions.stopWeight(scaleId);
    } else {
      mySelScaleIdList.add(scaleId);
      PublicFunctions.getWeight(scaleId);
    }
    setState(() {});
    checkSameScale();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Adaptive.isMobile(context);
    String pageTitle = S.of(context).menuWeighingDataCollection;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _tableState.loadPage(1),
          ),
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onNavigate(widget.lastRouteName);
          },
        ),
      ),
      drawer: isMobile ? _buildDrawer() : null,
      body: isMobile ? _buildMobileBody() : _buildDesktopBody(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
            child: Center(
              child: Text(
                "Scale List",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            child: NewMutiScaleListWidget(
              listWidth: double.infinity,
              selScaleList: mySelScaleIdList,
              clickScale: (scale) => addOrRemoveSelScale(scale.scaleId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      children: [
        // 左侧：秤列表
        Container(
          width: 260,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5))),
          ),
          child: NewMutiScaleListWidget(
            listWidth: 260,
            selScaleList: mySelScaleIdList,
            clickScale: (scale) => addOrRemoveSelScale(scale.scaleId),
          ),
        ),
        // 中间：数值显示与操作
        Container(
          width: 340,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5))),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: SingleChildScrollView(
            child: _buildValueSection(),
          ),
        ),
        // 右侧：数据表格
        Expanded(
          child: ChangeNotifierProvider<TableState>.value(
            value: _tableState,
            child: const WgtDataTable(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody() {
    return Column(
      children: [
        _buildValueSection(),
        const Divider(height: 1),
        Expanded(
          child: ChangeNotifierProvider<TableState>.value(
            value: _tableState,
            child: const WgtDataTable(),
          ),
        ),
      ],
    );
  }

  Future<void> _handleExport() async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        type: FileType.custom,
        dialogTitle: 'Output file:',
        allowedExtensions: ["csv"],
        fileName: 'report.csv',
      );

      if (outputFile != null) {
        if (!outputFile.toLowerCase().endsWith(".csv")) {
          outputFile = "$outputFile.csv";
        }
        PublicFunctions.exportAllRecords(
            mySettingParam.scaleMode, outputFile, mySelFields(), mySelMap());
      }
    } catch (e) {
      showTipInfo("Export Error: $e", context);
    }
  }

  Widget _buildValueSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    // 如果不是移动端，但在三列布局中，我们也希望内部垂直排列
    final bool useVerticalLayout = isMobile || MediaQuery.of(context).size.width >= 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PLU 选择区
          Text(
            "Product (PLU)",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PluData>(
                isExpanded: true,
                hint: Text(myPluInfoList.isEmpty ? "Loading products..." : "Select PLU"),
                value: myPluInfoList.contains(selectedPluData) ? selectedPluData : null,
                items: myPluInfoList.map((p) => DropdownMenuItem(value: p, child: Text("${p.plu} - ${p.productName}"))).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedPluData = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 操作按钮区
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _tableState.allData.clear();
                    PublicFunctions.newDeleteAllRecords(mySettingParam.scaleMode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  icon: const Icon(Icons.delete_sweep, size: 20),
                  label: Text(S.of(context).gBtnDeleteAll, style: const TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _handleExport();
                  },
                  icon: const Icon(Icons.download, size: 20),
                  label: Text(S.of(context).gBtnExport, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 重量显示区
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildValueDisplay(
                  S.of(context).fTotalWeight,
                  totalWeightNotifier,
                  totalWgtUnitNotifier.value,
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: totalWgtStableNotifier,
                  builder: (context, isStable, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isStable ? sendDataToDb : null,
                        icon: Icon(isStable ? Icons.save : Icons.hourglass_empty),
                        label: Text(S.of(context).gBtnSave),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isStable ? Theme.of(context).colorScheme.primary : null,
                          foregroundColor: isStable ? Theme.of(context).colorScheme.onPrimary : null,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(String label, ValueNotifier<String> notifier, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        ValueListenableBuilder<String>(
          valueListenable: notifier,
          builder: (context, value, _) {
            return Text(
              "$value $unit",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  List<String> mySelFields() {
    List<String> res = [];
    for (var item in _tableState.visibleColumns.keys) {
      if (_tableState.visibleColumns[item]!.isSelect) {
        res.add(item);
      }
    }
    return res;
  }

  Map<String, String> mySelMap() {
    Map<String, String> res = {};
    for (var item in _tableState.visibleColumns.keys) {
      if (_tableState.visibleColumns[item]!.isSelect) {
        res[item] = _tableState.visibleColumns[item]!.showName;
      }
    }
    return res;
  }
}
