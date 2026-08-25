// Mobile Weighing Data Collection Page
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_max/data/const_var_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/new_get_recs.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/data/settingparam_data.dart';
import 'package:t_max/data/wgt_value_data.dart';
import 'package:t_max/data/writelog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/f_open_file.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/dialog/mobile_page_help_dialog.dart';

class MobileWeighingDataCollectionPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;

  const MobileWeighingDataCollectionPage({
    super.key,
    required this.onNavigate,
    required this.lastRouteName,
  });

  @override
  State<MobileWeighingDataCollectionPage> createState() =>
      _MobileWeighingDataCollectionPageState();
}

class _MobileWeighingDataCollectionPageState
    extends State<MobileWeighingDataCollectionPage> {
  int _selectedTab = 0; // 0: Weighing, 1: Record
  bool _isSummaryMode =
      true; // true: Weight Summary Mode, false: Weight Independent Mode

  // Local map to store weight data for each scale
  final Map<int, WeightInfo> _scaleWeightMap = {};
  final Map<int, bool> _drawerDeviceCheckedMap = {};

  // PLU Selections
  PluData? _summaryPluData;
  final Map<int, PluData?> _independentPluMap = {};

  // Unit Dropdown Selection for Summary Mode
  String _summaryUnit = 'kg';

  // Parameter Settings State
  String _saveMode = "Manual";
  String _stableTime = "2";
  late TextEditingController _stableTimeController;
  String _dateFormat = "yy-mm-dd";
  String _dateSeparator = "/";

  // Records list
  List<ScaleRecInfo> _allWgtRecList = [];
  bool _isLoadingRecords = false;

  // Visible Report Fields
  Map<String, bool> _visibleFields = {
    'Id': true,
    'Date Time': true,
    'PLU': true,
    'Product Code': true,
    'Item Code': true,
    'Product Name': true,
    'Price': true,
    'Unit': true,
    'Tax Type': true,
    'Unit Weight': true,
    'Limit High': true,
    'Limit Low': true,
    'Pretare': true,
    'Weight': true,
    'Weight Unit': true,
    'Operator': true,
    'Scale Name': true,
  };

  // Expanded status for Record cards
  final Map<int, bool> _expandedRecords = {};

  // Timers & Event Listeners
  Timer? _timer;
  dynamic _eventBusWeightData;
  dynamic _eventBusGetAllRecs;
  dynamic _eventBusAddRec;
  dynamic _eventBusDeleteRecs;
  dynamic _eventBusSettingParam;
  dynamic _eventBusScaleAdded;
  dynamic _eventBusProductList;
  dynamic _eventBusExportRecs;

  // Auto Save State for Independent Mode
  final Map<int, bool> _scalePassedZeroMap = {};
  final Map<int, Timer?> _scaleStableTimerMap = {};
  final Map<int, int> _scaleStableDurationMap = {};

  void _checkScaleAutoSave(int scaleId, WeightInfo info) {
    if (_isSummaryMode || _saveMode != "Auto") return;
    int stableSecs = int.tryParse(_stableTime) ?? 2;
    if (stableSecs <= 0) stableSecs = 2;

    double weightVal = double.tryParse(info.weight) ?? 0.0;
    if (info.stable && weightVal <= 0.001) {
      _scalePassedZeroMap[scaleId] = true;
    }

    if (info.stable &&
        weightVal > 0.001 &&
        (_scalePassedZeroMap[scaleId] ?? true)) {
      if (_scaleStableTimerMap[scaleId] == null) {
        _scaleStableDurationMap[scaleId] = 0;
        _scaleStableTimerMap[scaleId] =
            Timer.periodic(const Duration(seconds: 1), (timer) {
          int duration = (_scaleStableDurationMap[scaleId] ?? 0) + 1;
          _scaleStableDurationMap[scaleId] = duration;
          if (duration >= stableSecs) {
            timer.cancel();
            _scaleStableTimerMap[scaleId] = null;
            _scaleStableDurationMap[scaleId] = 0;
            if (mounted &&
                info.stable &&
                (double.tryParse(info.weight) ?? 0.0) > 0.001) {
              _scalePassedZeroMap[scaleId] = false;
              _recordSingleScaleToDb(scaleId);
            }
          }
        });
      }
    } else if (!info.stable) {
      _scaleStableTimerMap[scaleId]?.cancel();
      _scaleStableTimerMap[scaleId] = null;
      _scaleStableDurationMap[scaleId] = 0;
    }
  }

  Future<void> _loadLocalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('mobile_wgt_mode_0')) {
        _isSummaryMode = prefs.getBool('mobile_wgt_mode_0') ?? true;
      }
      if (prefs.containsKey('mobile_rec_mode_0')) {
        _saveMode = prefs.getString('mobile_rec_mode_0') ?? "Manual";
      }
      if (prefs.containsKey('mobile_stable_time_0')) {
        _stableTime = prefs.getString('mobile_stable_time_0') ?? "2";
        _stableTimeController.text = _stableTime;
      }
      if (prefs.containsKey('mobile_date_format_0')) {
        _dateFormat = prefs.getString('mobile_date_format_0') ?? "yy-mm-dd";
      }
      if (prefs.containsKey('mobile_date_separator_0')) {
        _dateSeparator = prefs.getString('mobile_date_separator_0') ?? "/";
      }
      if (mounted) setState(() {});
    } catch (e) {
      writelog("[LOCAL_SETTINGS_ERR] $e");
    }
  }

  Future<void> _saveLocalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mobile_wgt_mode_0', _isSummaryMode);
      await prefs.setString('mobile_rec_mode_0', _saveMode);
      await prefs.setString('mobile_stable_time_0', _stableTimeController.text);
      await prefs.setString('mobile_date_format_0', _dateFormat);
      await prefs.setString('mobile_date_separator_0', _dateSeparator);
    } catch (e) {
      writelog("[SAVE_LOCAL_SETTINGS_ERR] $e");
    }
  }

  void _startContinuousWeightStream() {
    if (myAllScalesList.isEmpty) {
      PublicFunctions.getScaleList();
      return;
    }
    for (var scale in myAllScalesList) {
      bool isChecked =
          _drawerDeviceCheckedMap[scale.scaleId] ?? true;
      if (isChecked) {
        PublicFunctions.getWeight(scale.scaleId);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _stableTimeController = TextEditingController(text: _stableTime);
    _loadLocalSettings();
    PublicFunctions.getScaleList();
    PublicFunctions.getProductList();
    PublicFunctions.getUIConfNormal(wgtCollectionMode);

    // Initial continuous weight stream start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startContinuousWeightStream();
    });

    // Fetch initial records
    _fetchRecords();

    // Listen to live scale weight updates
    _eventBusWeightData = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (!mounted) return;
      ReqWeightCountine reqWeight = event.obj;
      int scaleId = reqWeight.scaleId ?? 0;
      String wgtStr = reqWeight.msgBody?.weightVal ?? '0.00';
      String unitStr = reqWeight.msgBody?.weightUnit ?? 'kg';
      bool isStable = reqWeight.msgBody?.isStable ?? false;
      WeightInfo info =
          WeightInfo(weight: wgtStr, unit: unitStr, stable: isStable);
      _scaleWeightMap[scaleId] = info;
      _checkScaleAutoSave(scaleId, info);
      setState(() {});
    });

    // Listen to Scale List updates and register continuous weight
    _eventBusScaleAdded = eventBus.on<EventRespAddScale>().listen((event) {
      if (!mounted) return;
      _startContinuousWeightStream();
      setState(() {});
    });

    // Listen to UI Config (Parameter Settings) updates from DB
    _eventBusSettingParam = eventBus.on<EventSettingParam>().listen((event) {
      if (!mounted) return;
      SettingParam param = event.obj;
      setState(() {
        _isSummaryMode = param.wgtMode == 1;
        _saveMode = (param.recMode == msgAuto || param.recMode == "auto")
            ? "Auto"
            : "Manual";
        _stableTime = param.stableTime.isNotEmpty ? param.stableTime : "2";
        _stableTimeController.text = _stableTime;
        _dateFormat = param.dateFormat == "2"
            ? "dd-mm-yy"
            : (param.dateFormat == "3" ? "mm-dd-yy" : "yy-mm-dd");
        _dateSeparator =
            param.dateSeparator.isNotEmpty ? param.dateSeparator : "/";
      });
      _saveLocalSettings();
    });

    // Refresh UI timer & periodically send continuous weight registration
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _startContinuousWeightStream();
        setState(() {});
      }
    });

    // Event bus listeners
    _eventBusGetAllRecs = eventBus.on<EventRespGetAllWgtRecs>().listen((event) {
      if (!mounted) return;
      dynamic rawObj = event.obj;
      String jsonString = rawObj is String
          ? rawObj
          : (rawObj != null ? jsonEncode(rawObj) : '');
      writelog("[MOBILE_RECS] Received records json len: ${jsonString.length}");
      try {
        RevAllWgtRecs getAllWgtInfo = revAllWgtRecsFromJson(jsonString);
        if (getAllWgtInfo.scaleRecInfos != null) {
          List<ScaleRecInfo> recs = getAllWgtInfo.scaleRecInfos!;
          setState(() {
            _allWgtRecList = recs;
            _isLoadingRecords = false;
          });
        } else {
          setState(() {
            _isLoadingRecords = false;
          });
        }
      } catch (e) {
        writelog("[MOBILE_RECS_ERR] Parsing error: $e");
        if (mounted) {
          setState(() {
            _isLoadingRecords = false;
          });
        }
      }
    });

    _eventBusAddRec = eventBus.on<EventAddWgtRec>().listen((event) {
      if (!mounted) return;
      writelog("[MOBILE_ADD_REC_ACK] Record added success, refetching...");
      Future.delayed(const Duration(milliseconds: 200), () => _fetchRecords());
    });

    _eventBusDeleteRecs = eventBus.on<EventDelAllWgtRecs>().listen((event) {
      if (!mounted) return;
      setState(() {
        _allWgtRecList.clear();
      });
      Future.delayed(const Duration(milliseconds: 200), () => _fetchRecords());
    });

    _eventBusProductList = eventBus.on<EventProductRecList>().listen((event) {
      if (!mounted) return;
      List<PluDataFromDb> pluInfoList = event.obj;
      setState(() {
        myPluInfoList.clear();
        for (int i = 0; i < pluInfoList.length; i++) {
          PluData newPlu = PluData(0, 0, 0, 0, '', '', 0, 0, 0, 0, 0, 0, 0, '',
              false, '', 0, 0, '', '');
          newPlu.enabled = pluInfoList[i].enabled ?? true;
          if (!newPlu.enabled!) {
            continue;
          }
          newPlu.recId = pluInfoList[i].recId;
          newPlu.plu = int.tryParse(pluInfoList[i].plu ?? '0') ?? 0;
          newPlu.productCode =
              int.tryParse(pluInfoList[i].productCode ?? '0') ?? 0;
          newPlu.itemCode = int.tryParse(pluInfoList[i].itemCode ?? '0') ?? 0;
          newPlu.category = pluInfoList[i].category;
          newPlu.productName = pluInfoList[i].productName;
          newPlu.price = double.tryParse(pluInfoList[i].price ?? '0') ?? 0;
          newPlu.taxType = int.tryParse(pluInfoList[i].taxType ?? '0') ?? 0;
          newPlu.generalUnit =
              int.tryParse(pluInfoList[i].generalUnit ?? '0') ?? 0;
          newPlu.unitWeight =
              double.tryParse(pluInfoList[i].unitWeight ?? '0') ?? 0;
          newPlu.pretare = double.tryParse(pluInfoList[i].pretare ?? '0') ?? 0;
          newPlu.limitHigh =
              double.tryParse(pluInfoList[i].limitHigh ?? '0') ?? 0;
          newPlu.limitLow =
              double.tryParse(pluInfoList[i].limitLow ?? '0') ?? 0;
          newPlu.creatAt = pluInfoList[i].createdAt?.toIso8601String() ?? " ";
          newPlu.updateAt = pluInfoList[i].updatedAt?.toIso8601String() ?? " ";
          newPlu.createBy = pluInfoList[i].createBy;
          newPlu.updateBy = pluInfoList[i].updateBy;
          myPluInfoList.add(newPlu);
        }
      });
    });

    _eventBusExportRecs = eventBus.on<EventExportAllRecs>().listen((event) {
      if (!mounted) return;
      String resString = event.obj;
      if (resString.contains('ok')) {
        String filePath =
            resString.contains(',') ? resString.split(',')[1] : resString;
        showExportDialog(filePath, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Export Failed: $resString"),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _stableTimeController.dispose();
    _timer?.cancel();
    _eventBusWeightData?.cancel();
    _eventBusGetAllRecs?.cancel();
    _eventBusAddRec?.cancel();
    _eventBusDeleteRecs?.cancel();
    _eventBusSettingParam?.cancel();
    _eventBusScaleAdded?.cancel();
    _eventBusProductList?.cancel();
    _eventBusExportRecs?.cancel();
    super.dispose();
  }

  void _fetchRecords() {
    PublicFunctions.newGetRecords(
        int.parse(wgtCollectionMode), 1, 100, "CreatedAt", "desc");
  }

  void _saveUiConfToDb() {
    myScaleCmd.cmdMode = "update_ui_conf";
    mySettingParam.id = int.tryParse(wgtCollectionMode) ?? 0;
    mySettingParam.scaleMode = int.tryParse(wgtCollectionMode) ?? 0;
    mySettingParam.wgtMode = _isSummaryMode ? 1 : 0;
    mySettingParam.recMode = _saveMode == "Auto" ? msgAuto : msgManual;
    mySettingParam.stableTime = _stableTimeController.text;
    mySettingParam.dateFormat = _dateFormat == "yy-mm-dd"
        ? "1"
        : (_dateFormat == "dd-mm-yy" ? "2" : "3");
    mySettingParam.dateSeparator = _dateSeparator;
    String updateString = jsonEncode(mySettingParam);
    myScaleCmd.cmdData = updateString;
    PublicFunctions.sendMsgChan0(jsonEncode(myScaleCmd));
  }

  // ---------------------------------------------------------------------------
  // SCALE COMMANDS & DB RECORDING
  // ---------------------------------------------------------------------------
  // void _clearTare(int scaleId) {
  //   PublicFunctions.forceUntare(scaleId);
  // }

  void _performTare(int scaleId) {
    PublicFunctions.performTareWithScaleId(scaleId);
  }

  void _performZero(int scaleId) {
    PublicFunctions.performZeroWithScaleId(scaleId);
  }

  void _recordSummaryToDb() {
    double totalWgt = 0.0;
    Map<int, WeightInfo> scaleWgtMapDetail = {};
    List<int> selScaleList = [];

    // Calculate total weight from online scales with unit conversion
    if (myAllScalesList.isEmpty) {
      selScaleList.add(1);
      WeightInfo info = _scaleWeightMap[1] ??
          WeightInfo(weight: '0.00', unit: 'kg', stable: false);
      double rawW = double.tryParse(info.weight) ?? 0.0;
      double convertedW = convertUnit(
          rawW, info.unit.isNotEmpty ? info.unit : 'kg', _summaryUnit);
      scaleWgtMapDetail[1] = WeightInfo(
        weight: convertedW.toStringAsFixed(2),
        unit: _summaryUnit,
        stable: info.stable,
      );
      totalWgt = convertedW;
    } else {
      for (var scale in myAllScalesList) {
        int id = scale.scaleId;
        bool isChecked = _drawerDeviceCheckedMap[id] ?? scale.isOnline;
        if (!isChecked) continue;
        WeightInfo info = _scaleWeightMap[id] ??
            WeightInfo(weight: '0.00', unit: 'kg', stable: false);
        double rawW = double.tryParse(info.weight) ?? 0.0;
        double convertedW = convertUnit(
            rawW, info.unit.isNotEmpty ? info.unit : 'kg', _summaryUnit);
        totalWgt += convertedW;
        scaleWgtMapDetail[id] = WeightInfo(
          weight: convertedW.toStringAsFixed(2),
          unit: _summaryUnit,
          stable: info.stable,
        );
        selScaleList.add(id);
      }
    }

    _sendDataToDb(
      selScaleList: selScaleList,
      scaleWgtMapDetail: scaleWgtMapDetail,
      totalWeight: totalWgt,
      baseUnit: _summaryUnit,
      selPlu: _summaryPluData,
    );
  }

  void _recordSingleScaleToDb(int scaleId) {
    WeightInfo info = _scaleWeightMap[scaleId] ??
        WeightInfo(weight: '0.00', unit: 'kg', stable: false);
    double w = double.tryParse(info.weight) ?? 0.0;
    PluData? plu = _independentPluMap[scaleId];

    _sendDataToDb(
      selScaleList: [scaleId],
      scaleWgtMapDetail: {scaleId: info},
      totalWeight: w,
      baseUnit: info.unit.isNotEmpty ? info.unit : 'kg',
      selPlu: plu,
      rawWeightStr: info.weight.isNotEmpty ? info.weight : '0.00',
    );
  }

  void _sendDataToDb({
    required List<int> selScaleList,
    required Map<int, WeightInfo> scaleWgtMapDetail,
    required double totalWeight,
    required String baseUnit,
    required PluData? selPlu,
    String? rawWeightStr,
  }) {
    final scaleIdToScaleMap = <int, Scale>{};
    for (final scale in myAllScalesList) {
      scaleIdToScaleMap[scale.scaleId] = scale;
    }

    final tempPlu = selPlu ??
        PluData(null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, '', '');

    final newAddRec = ReqAddWgtRec()
      ..mode =
          int.parse(wgtCollectionMode) // Always 0 for Weighing Data Collection
      ..detailRec = [];

    final headerCommon = Header(
      id: '1',
      plu: tempPlu.plu?.toString() ?? '',
      productCode: tempPlu.productCode?.toString() ?? '',
      itemCode: tempPlu.itemCode?.toString() ?? '',
      category: tempPlu.category ?? '',
      productName: tempPlu.productName ?? '',
      generalUnit: tempPlu.generalUnit?.toString() ?? '',
      taxType: tempPlu.taxType?.toString() ?? '',
      price: tempPlu.price?.toString() ?? '',
      unitWeight: tempPlu.unitWeight?.toString() ?? '',
      pretare: tempPlu.pretare?.toString() ?? '',
      limitHigh: tempPlu.limitHigh?.toString() ?? '',
      limitLow: tempPlu.limitLow?.toString() ?? '',
      weight: rawWeightStr ?? totalWeight.toStringAsFixed(2),
      weightUnit: baseUnit,
      userNo: mySysUser.userId.toString(),
      userName: mySysUser.nickName,
      scaleMode: _isSummaryMode ? '1' : '0',
    );

    if (scaleWgtMapDetail.length == 1) {
      final scaleId = scaleWgtMapDetail.keys.first;
      final tempScale = scaleIdToScaleMap[scaleId];
      newAddRec.headRec = headerCommon.copyWith(
        scaleModel: tempScale?.scaleModel ?? '',
        scaleSn: tempScale?.scaleSn ?? '',
        scaleName: tempScale?.scaleName ?? 'Scale$scaleId',
      );
      newAddRec.detailRec = [];
    } else {
      newAddRec.headRec = headerCommon.copyWith(
        scaleModel: '',
        scaleSn: '',
        scaleName: '',
      );

      int seq = 1;
      for (final scaleId in scaleWgtMapDetail.keys) {
        final tempScale = scaleIdToScaleMap[scaleId];
        final weightInfo = scaleWgtMapDetail[scaleId]!;

        newAddRec.detailRec!.add(NewWgtDetail(
          no: seq,
          scaleModel: tempScale?.scaleModel ?? '',
          scaleSn: tempScale?.scaleSn ?? '',
          weight: weightInfo.weight,
          weightUnit: baseUnit,
          scaleName: tempScale?.scaleName ?? 'Scale$scaleId',
        ));
        seq++;
      }
    }

    String jsonPayload = reqAddWgtRecToJson(newAddRec);
    writelog("[MOBILE_SAVE_DB] Sending add_wgt_rec payload: $jsonPayload");
    PublicFunctions.addSummaryData(jsonPayload);

    showTipInfo(
      "Recorded successfully",
      context,
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 96,
        leading: Row(
          children: [
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else if (widget.lastRouteName.isNotEmpty) {
                  widget.onNavigate(widget.lastRouteName);
                } else {
                  widget.onNavigate('/multiScaleManagement');
                }
              },
            ),
            MobileScaleHeaderIconButton(
              onTap: _openDeviceListDrawer,
            ),
          ],
        ),
        title: const Text(
          "Weighing Data Collection",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF1E293B)),
            onPressed: () {
              showMobilePageHelpDialog(
                context,
                localizedStrings?.menuWeighingDataCollection ?? "Weighing Data Collection",
                localizedStrings?.gTipWgtDataCollectionHelp ??
                    "1. Connect scales to view live weight data.\n2. Select PLU item or total summary mode.\n3. Click Save button to store weighing data collection record.",
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Tabs [ Weighing ] [ Record ]
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Weighing",
                          style: TextStyle(
                            color: _selectedTab == 0
                                ? Theme.of(context).colorScheme.onPrimary
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedTab = 1);
                        _fetchRecords();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Record",
                          style: TextStyle(
                            color: _selectedTab == 1
                                ? Theme.of(context).colorScheme.onPrimary
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content View
          Expanded(
            child: _selectedTab == 0 ? _buildWeighingTab() : _buildRecordTab(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WEIGHING TAB
  // ---------------------------------------------------------------------------
  Widget _buildWeighingTab() {
    double totalWgt = 0.0;
    for (var scale in myAllScalesList) {
      bool isChecked =
          _drawerDeviceCheckedMap[scale.scaleId] ?? true;
      if (!isChecked) continue;
      WeightInfo info = _scaleWeightMap[scale.scaleId] ??
          WeightInfo(weight: '0.00', unit: 'kg', stable: false);
      double rawW = double.tryParse(info.weight) ?? 0.0;
      double convertedW = convertUnit(
          rawW, info.unit.isNotEmpty ? info.unit : 'kg', _summaryUnit);
      totalWgt += convertedW;
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Mode Sub-header Row
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isSummaryMode
                    ? "Weight Summary Mode"
                    : "Weight Independent Mode",
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Color(0xFF334155)),
                onPressed: _openParameterSettingsSheet,
              ),
            ],
          ),
        ),

        // Summary Mode Area (Only visible in Summary Mode)
        if (_isSummaryMode) ...[
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // PLU Selector
          _buildPluSelectorRow(
            pluData: _summaryPluData,
            onTap: () => _openPluSelectionSheet(isSummary: true),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Total Weight & Save Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        totalWgt.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Color(0xFF0F4C81),
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _summaryUnit,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF64748B)),
                        style: const TextStyle(
                            color: Color(0xFF334155), fontSize: 16),
                        items: ['kg', 'g', 'lb'].map((u) {
                          return DropdownMenuItem(value: u, child: Text(u));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _summaryUnit = val);
                        },
                      ),
                    ],
                  ),
                ),
                // Global Save Button 💾
                IconButton(
                  iconSize: 32,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      border: Border.all(color: const Color(0xFF10B981)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.save,
                        color: Color(0xFF10B981), size: 24),
                  ),
                  onPressed: _recordSummaryToDb,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Scale Cards List
        ...myAllScalesList
            .where((scale) =>
                _drawerDeviceCheckedMap[scale.scaleId] ?? true)
            .map((scale) => _buildScaleCard(scale)),
      ],
    );
  }

  Widget _buildPluSelectorRow(
      {required PluData? pluData, required VoidCallback onTap}) {
    String displayText = "PLU";
    if (pluData != null) {
      displayText = "${pluData.plu ?? ''}:${pluData.productName ?? ''}";
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayText,
              style: TextStyle(
                color: pluData != null
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleCard(Scale scale) {
    int id = scale.scaleId;
    WeightInfo info = _scaleWeightMap[id] ??
        WeightInfo(weight: '0.00', unit: 'kg', stable: false);
    bool isOnline = scale.isOnline;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scale Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                scale.scaleName.isNotEmpty ? scale.scaleName : "Scale$id",
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Independent Mode PLU selector on card right side
              if (!_isSummaryMode)
                InkWell(
                  onTap: () => _openPluSelectionSheet(scaleId: id),
                  child: Row(
                    children: [
                      Text(
                        _independentPluMap[id] != null
                            ? "${_independentPluMap[id]!.plu}:${_independentPluMap[id]!.productName}"
                            : "PLU",
                        style: TextStyle(
                          color: _independentPluMap[id] != null
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Color(0xFF94A3B8), size: 20),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Weight Value & Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    isOnline ? info.weight : "-- --",
                    style: TextStyle(
                      color: isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? info.unit : "",
                    style:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
              // Status Badges
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      "0",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text("NET",
                        style:
                            TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text("->0<-",
                        style:
                            TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons Row (3 PC SVG Action Buttons: Tare, Zero, Save)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // ➔T Tare SVG Icon
              _buildActionButton(
                svgPath: performTareSvgIcon(),
                color: const Color(0xFF004884),
                onPressed: isOnline ? () => _performTare(id) : null,
              ),
              const SizedBox(width: 10),
              // ->0<- Zero SVG Icon
              _buildActionButton(
                svgPath: performZeroSvgIcon(),
                color: const Color(0xFF004884),
                onPressed: isOnline ? () => _performZero(id) : null,
              ),
              const SizedBox(width: 10),
              // 💾 Save SVG Icon
              _buildActionButton(
                svgPath: saveSvgIcon(),
                color: const Color(0xFF10B981),
                isSave: true,
                onPressed: isOnline ? () => _recordSingleScaleToDb(id) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    String? svgPath,
    IconData? icon,
    required Color color,
    bool isSave = false,
    VoidCallback? onPressed,
  }) {
    Color iconColor = onPressed == null
        ? const Color(0xFF94A3B8)
        : (isSave ? const Color(0xFF10B981) : color);

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 40,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSave ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          border: Border.all(
            color: onPressed == null
                ? const Color(0xFFE2E8F0)
                : (isSave ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: svgPath != null
            ? getSvgIcon(svgPath, 24, 24, iconColor)
            : Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RECORD TAB
  // ---------------------------------------------------------------------------
  Widget _buildRecordTab() {
    return Column(
      children: [
        // Records List with Pull-to-Refresh & Loading State
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _fetchRecords();
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: _isLoadingRecords && _allWgtRecList.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF004884)),
                  )
                : _allWgtRecList.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Center(
                              child: Text(
                                localizedStrings?.fNoRecordTip ?? "No records found",
                                style: const TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemCount: _allWgtRecList.length,
                        itemBuilder: (context, index) {
                          return _buildRecordCard(_allWgtRecList[index], index + 1);
                        },
                      ),
          ),
        ),

        // Bottom Action Buttons
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () async {
                          String? outputFile =
                              await PublicFunctions.pickSaveFilePath(
                                  'report.csv');
                          if (outputFile != null) {
                            List<String> selFields = [];
                            Map<String, String> selMap = {};
                            _visibleFields.forEach((key, val) {
                              if (val) {
                                selFields.add(key);
                                selMap[key] = key;
                              }
                            });
                            PublicFunctions.exportAllRecords(
                                0, outputFile, selFields, selMap);
                          }
                        },
                        child: const Text(
                          "Export",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004884),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: _openReportSettingSheet,
                        child: const Text(
                          "Report Setting",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    PublicFunctions.newDeleteAllRecords(
                        int.parse(wgtCollectionMode));
                  },
                  child: const Text(
                    "Delete All",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(ScaleRecInfo record, int indexNo) {
    bool isSummary = record.details != null && record.details!.isNotEmpty;
    bool isExpanded = _expandedRecords[indexNo] ?? true;
    Header? header = record.header;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: () {
              setState(() {
                _expandedRecords[indexNo] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    indexNo < 10 ? "0$indexNo" : "$indexNo",
                    style: const TextStyle(
                      color: Color(0xFF004884),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      // If Single Scale Record, display Scale Name next to expand icon
                      if (!isSummary &&
                          (header?.scaleName?.isNotEmpty ?? false))
                        Text(
                          header!.scaleName!,
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 14),
                        ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Card Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Base Record Attributes
                  if (_visibleFields['PLU'] == true)
                    _buildFieldRow("PLU", header?.plu ?? ""),
                  if (_visibleFields['Product Name'] == true)
                    _buildFieldRow("Product Name", header?.productName ?? ""),
                  if (_visibleFields['Weight'] == true)
                    _buildFieldRow("Weight", header?.weight ?? ""),
                  if (_visibleFields['Weight Unit'] == true)
                    _buildFieldRow("Weight Unit", header?.weightUnit ?? ""),
                  if (_visibleFields['Date Time'] == true)
                    _buildFieldRow(
                        "Date Time", _formatDateTimeStr(header?.createdAt)),

                  // Summary Details Section (Only for Summary Records)
                  if (isSummary) ...[
                    const SizedBox(height: 10),
                    ...record.details!.map((detail) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Scale Name",
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12)),
                                  Text(detail.scaleName ?? "",
                                      style: const TextStyle(
                                          color: Color(0xFF004884),
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("Weight",
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12)),
                                  Text(detail.weight ?? "",
                                      style: const TextStyle(
                                          color: Color(0xFF004884),
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ],

                  const SizedBox(height: 8),

                  // Extended Attributes
                  if (_visibleFields['Product Code'] == true)
                    _buildFieldRow("Product Code", header?.productCode ?? ""),
                  if (_visibleFields['Item Code'] == true)
                    _buildFieldRow("Item Code", header?.itemCode ?? ""),
                  if (_visibleFields['Tax Type'] == true)
                    _buildFieldRow("Tax Type", header?.taxType ?? ""),
                  if (_visibleFields['Price'] == true)
                    _buildFieldRow("Price", header?.price ?? ""),
                  if (_visibleFields['Unit'] == true)
                    _buildFieldRow("Unit", header?.generalUnit ?? ""),
                  if (_visibleFields['Limit Low'] == true)
                    _buildFieldRow("Limit Low", header?.limitLow ?? ""),
                  if (_visibleFields['Unit Weight'] == true)
                    _buildFieldRow("Unit Weight", header?.unitWeight ?? ""),
                  if (_visibleFields['Limit High'] == true)
                    _buildFieldRow("Limit High", header?.limitHigh ?? ""),
                  if (_visibleFields['Pretare'] == true)
                    _buildFieldRow("Pretare", header?.pretare ?? ""),
                  if (_visibleFields['Operator'] == true)
                    _buildFieldRow("Operator", header?.userName ?? ""),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTimeStr(DateTime? dt) {
    if (dt == null) return "";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${dt.year}-${twoDigits(dt.month)}-${twoDigits(dt.day)} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}:${twoDigits(dt.second)}";
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DEVICE LIST DRAWER (Matches Design Mockup)
  // ---------------------------------------------------------------------------
  void _openDeviceListDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DeviceListDrawer',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerLeft,
          child: StatefulBuilder(
            builder: (context, setDrawerState) {
              return UnifiedDeviceDrawerContent(
                scaleList: myAllScalesList,
                isSelected: (scale) => _drawerDeviceCheckedMap[scale.scaleId] ?? true,
                onScaleTap: (scale) {
                  bool newChecked = !(_drawerDeviceCheckedMap[scale.scaleId] ?? true);
                  setDrawerState(() {
                    _drawerDeviceCheckedMap[scale.scaleId] = newChecked;
                  });
                  if (newChecked) {
                    PublicFunctions.getWeight(scale.scaleId);
                  } else {
                    PublicFunctions.stopWeight(scale.scaleId);
                  }
                  setState(() {});
                },
              );
            },
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // MODAL SHEETS
  // ---------------------------------------------------------------------------

  // Parameter Settings Sheet ⚙
  void _openParameterSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool tempSummaryMode = _isSummaryMode;
        String tempSaveMode = _saveMode;
        String tempDateFormat = _dateFormat;
        String tempDateSeparator = _dateSeparator;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // Page Header (Back Arrow + Centered Title)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFF1E293B)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "Parameter settings",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // List of Settings
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      children: [
                        // Weight Summary Mode Row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Weight Summary Mode",
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xFF334155))),
                              Switch(
                                value: tempSummaryMode,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (val) {
                                  setModalState(() => tempSummaryMode = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        // Save Mode Row
                        _buildSettingOptionRow(
                          title: "Save Mode",
                          val: tempSaveMode,
                          onTap: () {
                            _openSubSelectionModal(
                              "Save Mode",
                              ["Manual", "Auto"],
                              tempSaveMode,
                              (selected) {
                                setModalState(() => tempSaveMode = selected);
                              },
                            );
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        // Stable Time (s) Row (Editable input box)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Stable Time (s)",
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xFF334155))),
                              Container(
                                width: 100,
                                height: 38,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFCBD5E1)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextField(
                                  controller: _stableTimeController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                      fontSize: 15, color: Color(0xFF334155)),
                                  onChanged: (val) {
                                    _stableTime = val;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        // Date Format Row
                        _buildSettingOptionRow(
                          title: "Date Format",
                          val: tempDateFormat,
                          onTap: () {
                            _openSubSelectionModal(
                              "Date Format",
                              ["yy-mm-dd", "dd-mm-yy", "mm-dd-yy"],
                              tempDateFormat,
                              (selected) {
                                setModalState(() => tempDateFormat = selected);
                              },
                            );
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        // Date Separator Row
                        _buildSettingOptionRow(
                          title: "Date Separator",
                          val: tempDateSeparator,
                          onTap: () {
                            _openSubSelectionModal(
                              "Date Separator",
                              [".", "-", "/"],
                              tempDateSeparator,
                              (selected) {
                                setModalState(
                                    () => tempDateSeparator = selected);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bottom Green Confirm Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          setState(() {
                            _isSummaryMode = tempSummaryMode;
                            _saveMode = tempSaveMode;
                            _dateFormat = tempDateFormat;
                            _dateSeparator = tempDateSeparator;
                            _stableTime = _stableTimeController.text;
                          });
                          _saveUiConfToDb();
                          _saveLocalSettings();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingOptionRow({
    required String title,
    required String val,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 15, color: Color(0xFF334155))),
            Row(
              children: [
                Text(val,
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF64748B))),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    color: Color(0xFF94A3B8), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Sub Selection Modal Sheet (Matches mockups for Save Mode, Date Format, Date Separator)
  void _openSubSelectionModal(String title, List<String> options,
      String currentValue, ValueChanged<String> onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Title on Left, (X) Close Icon on Right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined,
                        color: Color(0xFF64748B), size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Vertical Card Options
              ...options.map((opt) {
                bool isSelected = opt == currentValue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      onSelected(opt);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF004884)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        opt,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // PLU Selection Sheet
  void _openPluSelectionSheet({bool isSummary = false, int? scaleId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        PluData? tempSelected =
            isSummary ? _summaryPluData : _independentPluMap[scaleId];
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "PLU",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Search Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                        hintText: "Please enter",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // PLU Grid
                  Expanded(
                    child: myPluInfoList.isEmpty
                        ? const Center(child: Text("No PLU available"))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: myPluInfoList.length,
                            itemBuilder: (context, idx) {
                              final plu = myPluInfoList[idx];
                              bool isSelected = tempSelected?.plu == plu.plu;
                              return InkWell(
                                onTap: () {
                                  setModalState(() => tempSelected = plu);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF004884)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF004884)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${plu.plu ?? ''}:${plu.productName ?? ''}",
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        setState(() {
                          if (isSummary) {
                            _summaryPluData = tempSelected;
                          } else if (scaleId != null) {
                            _independentPluMap[scaleId] = tempSelected;
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Confirm",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Report Setting Sheet (PLU Field)
  void _openReportSettingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        Map<String, bool> tempFields = Map.from(_visibleFields);
        bool selectAll = tempFields.values.every((v) => v);

        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> keys = tempFields.keys.toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "Report Setting",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: [
                        // 2 column checkboxes
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 4,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: keys.length,
                          itemBuilder: (context, idx) {
                            String key = keys[idx];
                            return Row(
                              children: [
                                Checkbox(
                                  value: tempFields[key],
                                  activeColor: const Color(0xFF10B981),
                                  onChanged: (val) {
                                    setModalState(() {
                                      tempFields[key] = val ?? false;
                                      selectAll =
                                          tempFields.values.every((v) => v);
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    key,
                                    style: const TextStyle(
                                        fontSize: 14, color: Color(0xFF334155)),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Checkbox(
                              value: selectAll,
                              activeColor: const Color(0xFF10B981),
                              onChanged: (val) {
                                bool boolVal = val ?? false;
                                setModalState(() {
                                  selectAll = boolVal;
                                  tempFields.updateAll((k, v) => boolVal);
                                });
                              },
                            ),
                            const Text("Select all",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        setState(() {
                          _visibleFields = tempFields;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Confirm",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
