// Mobile Check Weighing Page
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
import 'package:t_max/data/writelog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';
import 'package:t_max/widget/f_open_file.dart';

class CheckWeightInfo {
  String weight;
  String unit;
  bool stable;
  bool isZero;
  bool isNet;

  CheckWeightInfo({
    required this.weight,
    required this.unit,
    required this.stable,
    this.isZero = false,
    this.isNet = false,
  });
}

class MobileCheckWeighingPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;

  const MobileCheckWeighingPage({
    super.key,
    required this.onNavigate,
    required this.lastRouteName,
  });

  @override
  State<MobileCheckWeighingPage> createState() => _MobileCheckWeighingPageState();
}

class _MobileCheckWeighingPageState extends State<MobileCheckWeighingPage> {
  int _selectedTab = 0; // 0: Weighing, 1: Record

  // Local map to store weight data for each scale
  final Map<int, CheckWeightInfo> _scaleWeightMap = {};
  final Map<int, bool> _drawerDeviceCheckedMap = {};

  // PLU Selections & High/Low limits per scale
  final Map<int, PluData?> _scalePluMap = {};
  final Map<int, double> _scaleHighValueMap = {};
  final Map<int, double> _scaleLowValueMap = {};

  // Parameter Settings State
  String _saveMode = "Manual";
  String _stableTime = "2";
  late TextEditingController _stableTimeController;
  String _dateFormat = "yy-mm-dd";
  String _dateSeparator = "/";
  String _saveType = "All"; // All, OK, LO, HI

  // Records list
  List<ScaleRecInfo> _allWgtRecList = [];

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

  // Auto Save State per Scale
  final Map<int, bool> _scalePassedZeroMap = {};
  final Map<int, Timer?> _scaleStableTimerMap = {};
  final Map<int, int> _scaleStableDurationMap = {};

  void _checkScaleAutoSave(int scaleId, CheckWeightInfo info) {
    if (_saveMode != "Auto") return;
    int stableSecs = int.tryParse(_stableTime) ?? 2;
    if (stableSecs <= 0) stableSecs = 2;

    double weightVal = double.tryParse(info.weight) ?? 0.0;
    if (info.stable && weightVal <= 0.001) {
      _scalePassedZeroMap[scaleId] = true;
    }

    if (info.stable && weightVal > 0.001 && (_scalePassedZeroMap[scaleId] ?? true)) {
      if (_scaleStableTimerMap[scaleId] == null) {
        _scaleStableDurationMap[scaleId] = 0;
        _scaleStableTimerMap[scaleId] = Timer.periodic(const Duration(seconds: 1), (timer) {
          int duration = (_scaleStableDurationMap[scaleId] ?? 0) + 1;
          _scaleStableDurationMap[scaleId] = duration;
          if (duration >= stableSecs) {
            timer.cancel();
            _scaleStableTimerMap[scaleId] = null;
            _scaleStableDurationMap[scaleId] = 0;
            if (mounted && info.stable && (double.tryParse(info.weight) ?? 0.0) > 0.001) {
              // Check Save Type filter (All, OK, LO, HI)
              double high = _scaleHighValueMap[scaleId] ?? 0.0;
              double low = _scaleLowValueMap[scaleId] ?? 0.0;
              bool shouldSave = true;
              String st = _saveType.toLowerCase();
              if (st == "ok") {
                shouldSave = (low == 0 && high == 0) || (weightVal >= low && weightVal <= high);
              } else if (st == "hi") {
                shouldSave = high > 0 && weightVal > high;
              } else if (st == "lo" || st == "low") {
                shouldSave = low > 0 && weightVal < low;
              }

              if (shouldSave) {
                _scalePassedZeroMap[scaleId] = false;
                _recordSingleScaleToDb(scaleId);
              }
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
      if (prefs.containsKey('mobile_check_rec_mode_1')) {
        _saveMode = prefs.getString('mobile_check_rec_mode_1') ?? "Manual";
      }
      if (prefs.containsKey('mobile_check_stable_time_1')) {
        _stableTime = prefs.getString('mobile_check_stable_time_1') ?? "2";
        _stableTimeController.text = _stableTime;
      }
      if (prefs.containsKey('mobile_check_date_format_1')) {
        _dateFormat = prefs.getString('mobile_check_date_format_1') ?? "yy-mm-dd";
      }
      if (prefs.containsKey('mobile_check_date_separator_1')) {
        _dateSeparator = prefs.getString('mobile_check_date_separator_1') ?? "/";
      }
      if (prefs.containsKey('mobile_check_save_type_1')) {
        _saveType = prefs.getString('mobile_check_save_type_1') ?? "All";
      }
      if (mounted) setState(() {});
    } catch (e) {
      writelog("[LOCAL_CHECK_SETTINGS_ERR] $e");
    }
  }

  Future<void> _saveLocalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mobile_check_rec_mode_1', _saveMode);
      await prefs.setString('mobile_check_stable_time_1', _stableTimeController.text);
      await prefs.setString('mobile_check_date_format_1', _dateFormat);
      await prefs.setString('mobile_check_date_separator_1', _dateSeparator);
      await prefs.setString('mobile_check_save_type_1', _saveType);
    } catch (e) {
      writelog("[SAVE_CHECK_LOCAL_SETTINGS_ERR] $e");
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
    PublicFunctions.getUIConfNormal(wgtCheckMode);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startContinuousWeightStream();
    });

    _fetchRecords();

    // Listen to live weight data
    _eventBusWeightData = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (!mounted) return;
      ReqWeightCountine reqWeight = event.obj;
      int scaleId = reqWeight.scaleId ?? 0;
      String wgtStr = reqWeight.msgBody?.weightVal ?? '0.00';
      String unitStr = reqWeight.msgBody?.weightUnit ?? 'kg';
      bool isStable = reqWeight.msgBody?.isStable ?? false;
      bool isZero = reqWeight.msgBody?.isZero ?? false;
      bool isNet = reqWeight.msgBody?.isNet ?? false;
      CheckWeightInfo info = CheckWeightInfo(
        weight: wgtStr,
        unit: unitStr,
        stable: isStable,
        isZero: isZero,
        isNet: isNet,
      );
      _scaleWeightMap[scaleId] = info;
      _checkScaleAutoSave(scaleId, info);
      setState(() {});
    });

    _eventBusScaleAdded = eventBus.on<EventRespAddScale>().listen((event) {
      if (!mounted) return;
      _startContinuousWeightStream();
      setState(() {});
    });

    _eventBusSettingParam = eventBus.on<EventSettingParam>().listen((event) {
      if (!mounted) return;
      SettingParam param = event.obj;
      setState(() {
        _saveMode = (param.recMode == msgAuto || param.recMode == "auto") ? "Auto" : "Manual";
        _stableTime = param.stableTime.isNotEmpty ? param.stableTime : "2";
        _stableTimeController.text = _stableTime;
        _dateFormat = param.dateFormat == "2"
            ? "dd-mm-yy"
            : (param.dateFormat == "3" ? "mm-dd-yy" : "yy-mm-dd");
        _dateSeparator = param.dateSeparator.isNotEmpty ? param.dateSeparator : "/";
        _saveType = param.saveMode == hiMode
            ? "Hi"
            : (param.saveMode == okMode ? "ok" : (param.saveMode == lowMode ? "Low" : "All"));
      });
      _saveLocalSettings();
    });

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _startContinuousWeightStream();
        setState(() {});
      }
    });

    _eventBusGetAllRecs = eventBus.on<EventRespGetAllWgtRecs>().listen((event) {
      if (!mounted) return;
      dynamic rawObj = event.obj;
      String jsonString = rawObj is String
          ? rawObj
          : (rawObj != null ? jsonEncode(rawObj) : '');
      try {
        RevAllWgtRecs getAllWgtInfo = revAllWgtRecsFromJson(jsonString);
        if (getAllWgtInfo.scaleRecInfos != null) {
          List<ScaleRecInfo> recs = getAllWgtInfo.scaleRecInfos!;
          if (recs.isNotEmpty || (getAllWgtInfo.totalCount ?? 0) == 0) {
            setState(() {
              _allWgtRecList = recs;
            });
          }
        }
      } catch (e) {
        writelog("[MOBILE_CHECK_RECS_ERR] Parsing error: $e");
      }
    });

    _eventBusAddRec = eventBus.on<EventAddWgtRec>().listen((event) {
      if (!mounted) return;
      _fetchRecords();
    });

    _eventBusDeleteRecs = eventBus.on<EventDelAllWgtRecs>().listen((event) {
      if (!mounted) return;
      setState(() {
        _allWgtRecList.clear();
      });
      _fetchRecords();
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
          if (!newPlu.enabled!) continue;
          newPlu.recId = pluInfoList[i].recId;
          newPlu.plu = int.tryParse(pluInfoList[i].plu ?? '0') ?? 0;
          newPlu.productCode = int.tryParse(pluInfoList[i].productCode ?? '0') ?? 0;
          newPlu.itemCode = int.tryParse(pluInfoList[i].itemCode ?? '0') ?? 0;
          newPlu.category = pluInfoList[i].category;
          newPlu.productName = pluInfoList[i].productName;
          newPlu.price = double.tryParse(pluInfoList[i].price ?? '0') ?? 0;
          newPlu.taxType = int.tryParse(pluInfoList[i].taxType ?? '0') ?? 0;
          newPlu.generalUnit = int.tryParse(pluInfoList[i].generalUnit ?? '0') ?? 0;
          newPlu.unitWeight = double.tryParse(pluInfoList[i].unitWeight ?? '0') ?? 0;
          newPlu.pretare = double.tryParse(pluInfoList[i].pretare ?? '0') ?? 0;
          newPlu.limitHigh = double.tryParse(pluInfoList[i].limitHigh ?? '0') ?? 0;
          newPlu.limitLow = double.tryParse(pluInfoList[i].limitLow ?? '0') ?? 0;
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
        String filePath = resString.contains(',') ? resString.split(',')[1] : resString;
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
        int.parse(wgtCheckMode), 1, 100, "CreatedAt", "desc");
  }

  void _saveUiConfToDb() {
    myScaleCmd.cmdMode = "update_ui_conf";
    mySettingParam.id = int.tryParse(wgtCheckMode) ?? 1;
    mySettingParam.scaleMode = int.tryParse(wgtCheckMode) ?? 1;
    mySettingParam.recMode = _saveMode == "Auto" ? msgAuto : msgManual;
    mySettingParam.stableTime = _stableTimeController.text;
    mySettingParam.dateFormat = _dateFormat == "yy-mm-dd"
        ? "1"
        : (_dateFormat == "dd-mm-yy" ? "2" : "3");
    mySettingParam.dateSeparator = _dateSeparator;
    mySettingParam.saveMode = (_saveType == "Hi" || _saveType == "HI")
        ? hiMode
        : ((_saveType == "ok" || _saveType == "OK")
            ? okMode
            : ((_saveType == "Low" || _saveType == "LO") ? lowMode : allMode));
    String updateString = jsonEncode(mySettingParam);
    myScaleCmd.cmdData = updateString;
    PublicFunctions.sendMsgChan0(jsonEncode(myScaleCmd));
  }

  // ---------------------------------------------------------------------------
  // SCALE COMMANDS & DB RECORDING
  // ---------------------------------------------------------------------------
  // void _clearPluAndLimits(int scaleId) {
  //   setState(() {
  //     _scalePluMap[scaleId] = null;
  //     _scaleHighValueMap[scaleId] = 0.0;
  //     _scaleLowValueMap[scaleId] = 0.0;
  //   });
  //   PublicFunctions.forceUntare(scaleId);
  //   showTipInfo("Cleared PLU & Limits", context);
  // }

  void _performTare(int scaleId) {
    PublicFunctions.performTareWithScaleId(scaleId);
  }

  void _performZero(int scaleId) {
    PublicFunctions.performZeroWithScaleId(scaleId);
  }

  void _openHighLowDialog(int scaleId) {
    double highVal = _scaleHighValueMap[scaleId] ?? 0.0;
    double lowVal = _scaleLowValueMap[scaleId] ?? 0.0;

    TextEditingController highController = TextEditingController(
        text: highVal > 0 ? highVal.toString() : "");
    TextEditingController lowController = TextEditingController(
        text: lowVal > 0 ? lowVal.toString() : "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header Row: Back Arrow, Scale Icon, Title "High/Low Setting", Help Icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    getSvgIcon(weighingSvgIcon(), 22, 22, const Color(0xFF1E293B)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "High/Low Setting",
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline, color: Color(0xFF1E293B)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Content Area
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // High Row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("high",
                              style: TextStyle(fontSize: 15, color: Color(0xFF334155))),
                          Container(
                            width: 140,
                            height: 38,
                            alignment: Alignment.centerRight,
                            child: TextField(
                              controller: highController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: "Please enter",
                                hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 15),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),

                    // Low Row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Low",
                              style: TextStyle(fontSize: 15, color: Color(0xFF334155))),
                          Container(
                            width: 140,
                            height: 38,
                            alignment: Alignment.centerRight,
                            child: TextField(
                              controller: lowController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: "Please enter",
                                hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 15),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),

                    // Hint Text
                    const Text(
                      "The unit of weight is the same as scale..",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Confirm Button
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
                      double newHigh = double.tryParse(highController.text) ?? 0.0;
                      double newLow = double.tryParse(lowController.text) ?? 0.0;
                      setState(() {
                        _scaleHighValueMap[scaleId] = newHigh;
                        _scaleLowValueMap[scaleId] = newLow;
                      });
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
  }

  void _recordSingleScaleToDb(int scaleId) {
    CheckWeightInfo info = _scaleWeightMap[scaleId] ??
        CheckWeightInfo(weight: '0.00', unit: 'kg', stable: false);

    PluData? plu = _scalePluMap[scaleId];
    double highLimit = _scaleHighValueMap[scaleId] ?? (plu?.limitHigh ?? 0.0);
    double lowLimit = _scaleLowValueMap[scaleId] ?? (plu?.limitLow ?? 0.0);

    PluData tempPlu = plu ??
        PluData(null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, '', '');

    Scale? tempDefScaleInfo;
    for (var s in myAllScalesList) {
      if (s.scaleId == scaleId) {
        tempDefScaleInfo = s;
        break;
      }
    }

    final newAddRec = ReqAddWgtRec()
      ..mode = int.parse(wgtCheckMode) // Always 1 for Check Weighing
      ..detailRec = [];

    final headerCommon = Header(
      id: '1',
      scaleModel: tempDefScaleInfo?.scaleModel ?? '',
      scaleSn: tempDefScaleInfo?.scaleSn ?? '',
      scaleName: tempDefScaleInfo?.scaleName ?? 'Scale$scaleId',
      plu: (tempPlu.plu == null) ? "" : tempPlu.plu.toString(),
      productCode: (tempPlu.productCode == null) ? "" : tempPlu.productCode.toString(),
      itemCode: (tempPlu.itemCode == null) ? "" : tempPlu.itemCode.toString(),
      category: (tempPlu.category == null) ? "" : tempPlu.category.toString(),
      productName: (tempPlu.productName == null) ? "" : tempPlu.productName.toString(),
      generalUnit: (tempPlu.generalUnit == null) ? "" : tempPlu.generalUnit.toString(),
      taxType: (tempPlu.taxType == null) ? "" : tempPlu.taxType.toString(),
      price: (tempPlu.price == null) ? "" : tempPlu.price.toString(),
      unitWeight: (tempPlu.unitWeight == null) ? "" : tempPlu.unitWeight.toString(),
      pretare: (tempPlu.pretare == null) ? "" : tempPlu.pretare.toString(),
      limitHigh: highLimit > 0 ? highLimit.toString() : ((tempPlu.limitHigh == null) ? "" : tempPlu.limitHigh.toString()),
      limitLow: lowLimit > 0 ? lowLimit.toString() : ((tempPlu.limitLow == null) ? "" : tempPlu.limitLow.toString()),
      weight: (info.weight == '---------') ? "0.00" : (info.weight.isNotEmpty ? info.weight : '0.00'),
      weightUnit: (info.unit == '----') ? "kg" : (info.unit.isNotEmpty ? info.unit : 'kg'),
      userNo: mySysUser.userId.toString(),
      userName: mySysUser.nickName ?? "",
      scaleMode: '0',
    );

    newAddRec.headRec = headerCommon;

    String jsonPayload = reqAddWgtRecToJson(newAddRec);
    writelog("[MOBILE_CHECK_SAVE_DB] Sending add_wgt_rec payload: $jsonPayload");
    PublicFunctions.addSummaryData(jsonPayload);

    showTipInfo("Recorded successfully", context);
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
          "Check Weighing",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E293B)),
            onPressed: _openParameterSettingsSheet,
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
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        ...myAllScalesList
            .where((scale) =>
                _drawerDeviceCheckedMap[scale.scaleId] ?? true)
            .map((scale) => _buildScaleCard(scale)),
      ],
    );
  }

  Widget _buildScaleCard(Scale scale) {
    int id = scale.scaleId;
    CheckWeightInfo info = _scaleWeightMap[id] ??
        CheckWeightInfo(weight: '0.00', unit: 'kg', stable: false);
    bool isOnline = scale.isOnline;

    PluData? plu = _scalePluMap[id];
    double highLimit = _scaleHighValueMap[id] ?? (plu?.limitHigh ?? 0.0);
    double lowLimit = _scaleLowValueMap[id] ?? (plu?.limitLow ?? 0.0);

    double weightVal = double.tryParse(info.weight) ?? 0.0;

    // Determine weight container background & text color according to check weighing OK/HI/LO
    Color? rowBgColor;
    Color weightTextColor = const Color(0xFF10B981); // Default Green
    Color unitTextColor = const Color(0xFF64748B);

    if (lowLimit > 0 || highLimit > 0) {
      if (weightVal < lowLimit) {
        // LOW -> Solid Yellow/Orange background (#EAB308)
        rowBgColor = const Color(0xFFEAB308);
        weightTextColor = Colors.white;
        unitTextColor = Colors.white;
      } else if (weightVal >= lowLimit && weightVal <= highLimit) {
        // OK -> Solid Green background (#10B981)
        rowBgColor = const Color(0xFF10B981);
        weightTextColor = Colors.white;
        unitTextColor = Colors.white;
      } else if (weightVal > highLimit) {
        // HIGH -> Solid Red background (#EF4444)
        rowBgColor = const Color(0xFFEF4444);
        weightTextColor = Colors.white;
        unitTextColor = Colors.white;
      }
    }

    String pluDisplayText = "PLU";
    if (plu != null) {
      pluDisplayText = "${plu.plu ?? ''}:${plu.productName ?? ''}";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Header Row (Scale Name on Left, PLU Selector on Right)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  scale.scaleName.isNotEmpty ? scale.scaleName : "Scale$id",
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () => _openPluSelectionSheet(id),
                  child: Row(
                    children: [
                      Text(
                        pluDisplayText,
                        style: TextStyle(
                          color: plu != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 2. Weight Display & Status Tags Row (Full Container Fill)
          Container(
            color: rowBgColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Live Weight & Unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isOnline ? info.weight : "-- --",
                      style: TextStyle(
                        color: isOnline
                            ? weightTextColor
                            : (rowBgColor != null ? Colors.white : const Color(0xFFEF4444)),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? info.unit : "",
                      style: TextStyle(color: unitTextColor, fontSize: 14),
                    ),
                  ],
                ),

                // Status Tag Indicators: [0], [NET], [->0<-]
                Row(
                  children: [
                    // [0] Zero tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: info.isZero
                            ? const Color(0xFF10B981)
                            : (rowBgColor != null ? Colors.white.withValues(alpha: 0.8) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        "0",
                        style: TextStyle(
                          color: info.isZero ? Colors.white : (rowBgColor != null ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // [NET] Net tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: rowBgColor != null ? Colors.white.withValues(alpha: 0.8) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        "NET",
                        style: TextStyle(
                          color: info.isNet
                              ? const Color(0xFF10B981)
                              : (rowBgColor != null ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // [->0<-] Center zero tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: rowBgColor != null ? Colors.white.withValues(alpha: 0.8) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        "->0<-",
                        style: TextStyle(
                          color: info.isZero
                              ? const Color(0xFF10B981)
                              : (rowBgColor != null ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 3. Action Buttons Row (4 PC SVG Action Buttons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ⇅ High/Low Setting SVG Icon
                _buildActionButton(
                  svgPath: highLowSettingSvgIcon(),
                  color: const Color(0xFF004884),
                  onPressed: () => _openHighLowDialog(id),
                ),
                const SizedBox(width: 10),
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
                  onPressed: () => _recordSingleScaleToDb(id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    String? svgPath,
    IconData? icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isSave = false,
  }) {
    Color iconColor = onPressed == null ? const Color(0xFFCBD5E1) : color;
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 40,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onPressed == null
              ? const Color(0xFFF1F5F9)
              : (isSave ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC)),
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
        // Records Card List
        Expanded(
          child: _allWgtRecList.isEmpty
              ? const Center(
                  child: Text(
                    "No Records",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _allWgtRecList.length,
                  itemBuilder: (context, index) {
                    final rec = _allWgtRecList[index];
                    return _buildRecordCard(rec, index + 1);
                  },
                ),
        ),

        // Bottom Action Buttons Area (Export, Report Setting, Delete All)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () async {
                          String? outputFile =
                              await PublicFunctions.pickSaveFilePath('report.csv');
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
                                1, outputFile, selFields, selMap);
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
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
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    PublicFunctions.newDeleteAllRecords(int.parse(wgtCheckMode));
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

  Widget _buildRecordCard(ScaleRecInfo rec, int displayIndex) {
    bool isExpanded = _expandedRecords[displayIndex] ?? (displayIndex == 1);
    Header? header = rec.header;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header Row (01 / 02 and Scale Name + Expand Arrow)
          InkWell(
            onTap: () {
              setState(() {
                _expandedRecords[displayIndex] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayIndex < 10 ? "0$displayIndex" : "$displayIndex",
                    style: const TextStyle(
                      color: Color(0xFF004884),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (header?.scaleName?.isNotEmpty ?? false)
                        Text(
                          header!.scaleName!,
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 14),
                        ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Record Details Area
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_visibleFields['Date Time'] == true)
                    _buildFieldRow("Date Time", _formatDateTimeStr(header?.createdAt)),
                  if (_visibleFields['PLU'] == true)
                    _buildFieldRow("PLU", header?.plu ?? ""),
                  if (_visibleFields['Weight'] == true)
                    _buildFieldRow("Weight", header?.weight ?? ""),
                  if (_visibleFields['Weight Unit'] == true)
                    _buildFieldRow("Weight Unit", header?.weightUnit ?? ""),
                  if (_visibleFields['Product Name'] == true)
                    _buildFieldRow("Product Name", header?.productName ?? ""),

                  const SizedBox(height: 10),
                  // 3-Column Fields Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_visibleFields['Product Code'] == true)
                              _buildGridCell("Product Code", header?.productCode ?? ""),
                            if (_visibleFields['Price'] == true)
                              _buildGridCell("Price", header?.price ?? ""),
                            if (_visibleFields['Unit Weight'] == true)
                              _buildGridCell("Unit Weight", header?.unitWeight ?? ""),
                            if (_visibleFields['Operator'] == true)
                              _buildGridCell("Operator", header?.userName ?? ""),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_visibleFields['Item Code'] == true)
                              _buildGridCell("Item Code", header?.itemCode ?? ""),
                            if (_visibleFields['Unit'] == true)
                              _buildGridCell("Unit", header?.generalUnit ?? ""),
                            if (_visibleFields['Limit High'] == true)
                              _buildGridCell("Limit High", header?.limitHigh ?? ""),
                            if (_visibleFields['Scale Name'] == true)
                              _buildGridCell("Scale Name", header?.scaleName ?? ""),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_visibleFields['Tax Type'] == true)
                              _buildGridCell("Tax Type", header?.taxType ?? ""),
                            if (_visibleFields['Limit Low'] == true)
                              _buildGridCell("Limit Low", header?.limitLow ?? ""),
                            if (_visibleFields['Pretare'] == true)
                              _buildGridCell("Pretare", header?.pretare ?? ""),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildGridCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDateTimeStr(DateTime? dt) {
    if (dt == null) return "";
    return "${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }

  // ---------------------------------------------------------------------------
  // DEVICE LIST DRAWER
  // ---------------------------------------------------------------------------
  void _openDeviceListDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DeviceListDrawer',
      barrierColor: Colors.black54,
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
  // PARAMETER SETTINGS SHEET (Matches Mockup)
  // ---------------------------------------------------------------------------
  void _openParameterSettingsSheet() {
    String tempSaveMode = _saveMode;
    String tempStableTime = _stableTime;
    String tempDateFormat = _dateFormat;
    String tempDateSeparator = _dateSeparator;
    String tempSaveType = _saveType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
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
                        // Save Mode Row
                        _buildSettingItemRow(
                          "Save Mode",
                          tempSaveMode,
                          () {
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

                        // Stable Time Row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                                  controller: TextEditingController(text: tempStableTime),
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
                                    tempStableTime = val;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        // Date Format Row
                        _buildSettingItemRow(
                          "Date Format",
                          tempDateFormat,
                          () {
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
                        _buildSettingItemRow(
                          "Date Separator",
                          tempDateSeparator,
                          () {
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
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        // Save type Row (Check Weighing specific)
                        _buildSettingItemRow(
                          "Save type",
                          tempSaveType,
                          () {
                            _openSubSelectionModal(
                              "Save type",
                              ["All", "Hi", "ok", "Low"],
                              tempSaveType,
                              (selected) {
                                setModalState(() => tempSaveType = selected);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bottom Confirm Button
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
                            _saveMode = tempSaveMode;
                            _stableTime = tempStableTime;
                            _stableTimeController.text = _stableTime;
                            _dateFormat = tempDateFormat;
                            _dateSeparator = tempDateSeparator;
                            _saveType = tempSaveType;
                          });
                          _saveLocalSettings();
                          _saveUiConfToDb();
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

  Widget _buildSettingItemRow(String title, String val, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
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

  // Sub Selection Modal Sheet
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              ...options.map((opt) {
                bool isSelected = opt == currentValue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PLU SELECTION SHEET
  // ---------------------------------------------------------------------------
  void _openPluSelectionSheet(int scaleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        PluData? tempSelected = _scalePluMap[scaleId];
        String searchQuery = "";
        TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            List<PluData> filteredList = myPluInfoList.where((plu) {
              if (searchQuery.isEmpty) return true;
              String displayStr = "${plu.plu ?? ''}:${plu.productName ?? ''}".toLowerCase();
              return displayStr.contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // 1. Header Row (Back Arrow + Centered "PLU")
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
                            "PLU",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // 2. Search Bar (Matches Mockup)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: "Please enter",
                                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                              onChanged: (val) {
                                setModalState(() {
                                  searchQuery = val;
                                });
                              },
                            ),
                          ),
                          if (searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  searchController.clear();
                                  searchQuery = "";
                                });
                              },
                              child: const Icon(Icons.cancel, color: Color(0xFF94A3B8), size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. Grid View
                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(
                            child: Text(
                              "No PLU available",
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              PluData plu = filteredList[index];
                              bool isSelected = tempSelected?.recId == plu.recId;
                              return InkWell(
                                onTap: () {
                                  setModalState(() {
                                    tempSelected = plu;
                                  });
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
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

                  // 4. Confirm Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          setState(() {
                            _scalePluMap[scaleId] = tempSelected;
                            if (tempSelected != null) {
                              _scaleHighValueMap[scaleId] = tempSelected!.limitHigh ?? 0.0;
                              _scaleLowValueMap[scaleId] = tempSelected!.limitLow ?? 0.0;
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Confirm",
                            style: TextStyle(color: Colors.white, fontSize: 16)),
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

  // ---------------------------------------------------------------------------
  // REPORT FIELD SETTING SHEET
  // ---------------------------------------------------------------------------
  void _openReportSettingSheet() {
    Map<String, bool> tempFields = Map.from(_visibleFields);
    bool selectAll = tempFields.values.every((v) => v);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
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
                            "Report Setting",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: tempFields.length,
                          itemBuilder: (context, index) {
                            String key = tempFields.keys.elementAt(index);
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: selectAll,
                              activeColor: const Color(0xFF10B981),
                              onChanged: (val) {
                                bool newVal = val ?? false;
                                setModalState(() {
                                  selectAll = newVal;
                                  tempFields.updateAll((k, v) => newVal);
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

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
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
