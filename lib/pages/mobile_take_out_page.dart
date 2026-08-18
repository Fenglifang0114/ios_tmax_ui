import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:t_max/data/const_var_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
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
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/widget/f_open_file.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';
import 'package:t_max/dialog/mobile_page_help_dialog.dart';

class TakeOutWeightInfo {
  String weight;
  String unit;
  bool stable;
  bool isZero;
  bool isNet;

  TakeOutWeightInfo({
    required this.weight,
    required this.unit,
    required this.stable,
    this.isZero = false,
    this.isNet = false,
  });
}

class MobileTakeOutPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;

  const MobileTakeOutPage({
    super.key,
    required this.onNavigate,
    required this.lastRouteName,
  });

  @override
  State<MobileTakeOutPage> createState() => _MobileTakeOutPageState();
}

class _MobileTakeOutPageState extends State<MobileTakeOutPage> {
  int _selectedTab = 0; // 0: Weighing, 1: Record
  bool _isSummaryMode =
      true; // true: Weight Summary Mode, false: Weight Independent Mode

  // Local maps for weight data per scale
  final Map<int, TakeOutWeightInfo> _scaleWeightMap = {};
  final Map<int, double> _scaleLastWgtMap = {};
  final Map<int, double> _scaleTakeOutWgtMap = {};
  final Map<int, bool> _scaleStartTakeOutMap = {};

  final Map<int, bool> _drawerDeviceCheckedMap = {};

  // PLU Selections
  PluData? _summaryPluData;
  final Map<int, PluData?> _independentPluMap = {};

  // Summary Unit Dropdown Selection
  String _summaryUnit = 'kg';

  // Parameter Settings State
  String _saveMode = "Manual";
  String _stableTime = "2";
  late TextEditingController _stableTimeController;
  String _dateFormat = "yy-mm-dd";
  String _dateSeparator = "/";

  // Records list
  List<ScaleRecInfo> _allWgtRecList = [];

  // Visible Report Fields
  final Map<String, bool> _visibleFields = {
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

  @override
  void initState() {
    super.initState();
    _stableTimeController = TextEditingController(text: _stableTime);

    for (var scale in myAllScalesList) {
      _drawerDeviceCheckedMap[scale.scaleId] = true;
    }

    _loadUiConfFromDb();
    _fetchRecords();
    _fetchPluList();
    _startContinuousWeightStream();

    _eventBusWeightData = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (!mounted) return;
      ReqWeightCountine tempWeight = event.obj;
      if (tempWeight.scaleId != null && tempWeight.msgBody != null) {
        int id = tempWeight.scaleId!;
        String rawW = tempWeight.msgBody!.weightVal;
        String u = tempWeight.msgBody!.weightUnit;
        bool st = tempWeight.msgBody!.isStable;
        bool isZ = tempWeight.msgBody!.isZero;
        bool isN = tempWeight.msgBody!.isNet;

        setState(() {
          TakeOutWeightInfo info = TakeOutWeightInfo(
            weight: rawW,
            unit: u.isNotEmpty ? u : 'kg',
            stable: st,
            isZero: isZ,
            isNet: isN,
          );
          _scaleWeightMap[id] = info;

          double nowVal = double.tryParse(rawW) ?? 0.0;
          bool isStarted = _scaleStartTakeOutMap[id] ?? false;
          double lastVal = _scaleLastWgtMap[id] ?? 0.0;

          if (nowVal >= 0 && isStarted) {
            double decVal = lastVal - nowVal;
            _scaleTakeOutWgtMap[id] = decVal > 0 ? decVal : 0.0;
          } else if (!isStarted) {
            _scaleTakeOutWgtMap[id] = 0.0;
          }

          for (var s in myAllScalesList) {
            if (s.scaleId == id && !s.isOnline) {
              s.isOnline = true;
              _drawerDeviceCheckedMap[id] = true;
            }
          }
        });

        if (!_isSummaryMode && _saveMode == "Auto") {
          _checkScaleAutoSave(id, _scaleWeightMap[id]!);
        }
      }
    });

    _eventBusGetAllRecs = eventBus.on<EventRespGetAllWgtRecs>().listen((event) {
      if (!mounted) return;
      dynamic rawObj = event.obj;
      String jsonString = rawObj is String
          ? rawObj
          : (rawObj != null ? jsonEncode(rawObj) : '');
      writelog("[MOBILE_TAKEOUT_RECS] Received records json: $jsonString");
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
        writelog("[MOBILE_TAKEOUT_RECS_ERR] Parsing error: $e");
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

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _startContinuousWeightStream();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stableTimeController.dispose();
    _eventBusWeightData?.cancel();
    _eventBusGetAllRecs?.cancel();
    _eventBusAddRec?.cancel();
    _eventBusDeleteRecs?.cancel();
    _eventBusSettingParam?.cancel();
    _eventBusScaleAdded?.cancel();
    _eventBusProductList?.cancel();
    _eventBusExportRecs?.cancel();
    for (var timer in _scaleStableTimerMap.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  void _startContinuousWeightStream() {
    for (var scale in myAllScalesList) {
      bool isChecked =
          _drawerDeviceCheckedMap[scale.scaleId] ?? true;
      if (isChecked) {
        PublicFunctions.getWeight(scale.scaleId);
      }
    }
  }

  void _fetchPluList() {
    PublicFunctions.getProductList();
  }

  void _fetchRecords() {
    PublicFunctions.newGetRecords(
        int.parse(wgtTakeOutMode), 1, 100, "CreatedAt", "desc");
  }

  void _loadUiConfFromDb() {
    PublicFunctions.getUIConfNormal(wgtTakeOutMode);
  }

  void _saveUiConfToDb() {
    myScaleCmd.cmdMode = "update_ui_conf";
    mySettingParam.id = int.tryParse(wgtTakeOutMode) ?? 3;
    mySettingParam.scaleMode = int.tryParse(wgtTakeOutMode) ?? 3;
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

  void _checkScaleAutoSave(int scaleId, TakeOutWeightInfo info) {
    if (_saveMode != "Auto") return;
    int stableSecs = int.tryParse(_stableTime) ?? 2;
    if (stableSecs <= 0) stableSecs = 2;

    double decVal = _scaleTakeOutWgtMap[scaleId] ?? 0.0;
    if (info.stable && info.isZero) {
      _scalePassedZeroMap[scaleId] = true;
    }

    if (info.stable &&
        decVal > 0.001 &&
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
                (_scaleTakeOutWgtMap[scaleId] ?? 0.0) > 0.001) {
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

  // ---------------------------------------------------------------------------
  // SCALE COMMANDS & DB RECORDING
  // ---------------------------------------------------------------------------
  void _performTare(int scaleId) {
    PublicFunctions.performTareWithScaleId(scaleId);
  }

  void _performZero(int scaleId) {
    PublicFunctions.performZeroWithScaleId(scaleId);
  }

  void _toggleStartTakeOut(int scaleId) {
    TakeOutWeightInfo info = _scaleWeightMap[scaleId] ??
        TakeOutWeightInfo(weight: '0.00', unit: 'kg', stable: false);
    double nowVal = double.tryParse(info.weight) ?? 0.0;

    bool isStarted = _scaleStartTakeOutMap[scaleId] ?? false;

    if (!isStarted) {
      if (nowVal <= 0.0001) {
        showTipInfo(
            "Invalid weight data. Please add weight on scale first.", context);
        return;
      }
      setState(() {
        _scaleStartTakeOutMap[scaleId] = true;
        _scaleLastWgtMap[scaleId] = nowVal;
        _scaleTakeOutWgtMap[scaleId] = 0.0;
      });
    } else {
      setState(() {
        _scaleStartTakeOutMap[scaleId] = false;
        _scaleLastWgtMap[scaleId] = 0.0;
        _scaleTakeOutWgtMap[scaleId] = 0.0;
      });
    }
  }

  void _recordSummaryToDb() {
    double totalWgt = 0.0;
    Map<int, WeightInfo> scaleWgtMapDetail = {};
    List<int> selScaleList = [];

    if (myAllScalesList.isEmpty) {
      selScaleList.add(1);
      TakeOutWeightInfo info = _scaleWeightMap[1] ??
          TakeOutWeightInfo(weight: '0.00', unit: 'kg', stable: false);
      double decVal = _scaleTakeOutWgtMap[1] ?? 0.0;
      double convertedW = convertUnit(
          decVal, info.unit.isNotEmpty ? info.unit : 'kg', _summaryUnit);
      scaleWgtMapDetail[1] = WeightInfo(
        weight: convertedW.toStringAsFixed(2),
        unit: _summaryUnit,
        stable: info.stable,
      );
      totalWgt = convertedW;
    } else {
      for (var scale in myAllScalesList) {
        if (scale.isOnline) {
          int id = scale.scaleId;
          TakeOutWeightInfo info = _scaleWeightMap[id] ??
              TakeOutWeightInfo(weight: '0.00', unit: 'kg', stable: false);
          double decVal = _scaleTakeOutWgtMap[id] ?? 0.0;
          double convertedW = convertUnit(
              decVal, info.unit.isNotEmpty ? info.unit : 'kg', _summaryUnit);
          totalWgt += convertedW;
          scaleWgtMapDetail[id] = WeightInfo(
            weight: convertedW.toStringAsFixed(2),
            unit: _summaryUnit,
            stable: info.stable,
          );
          selScaleList.add(id);
        }
      }
    }

    PluData tempPlu = _summaryPluData ??
        PluData(null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, '', '');

    final newAddRec = ReqAddWgtRec()
      ..mode = int.parse(wgtTakeOutMode) // Always 3 for Take Out Scale
      ..detailRec = [];

    Scale? tempDefScaleInfo;
    if (myAllScalesList.isNotEmpty) {
      tempDefScaleInfo = myAllScalesList.firstWhere(
        (element) => element.scaleId == selScaleList.first,
        orElse: () => myAllScalesList[0],
      );
    }

    final headerCommon = Header(
      id: '1',
      scaleModel: tempDefScaleInfo?.scaleModel ?? '',
      scaleSn: tempDefScaleInfo?.scaleSn ?? '',
      scaleName: tempDefScaleInfo?.scaleName ?? 'Scale1',
      plu: (tempPlu.plu == null) ? "" : tempPlu.plu.toString(),
      productCode:
          (tempPlu.productCode == null) ? "" : tempPlu.productCode.toString(),
      itemCode: (tempPlu.itemCode == null) ? "" : tempPlu.itemCode.toString(),
      category: (tempPlu.category == null) ? "" : tempPlu.category.toString(),
      productName:
          (tempPlu.productName == null) ? "" : tempPlu.productName.toString(),
      generalUnit:
          (tempPlu.generalUnit == null) ? "" : tempPlu.generalUnit.toString(),
      taxType: (tempPlu.taxType == null) ? "" : tempPlu.taxType.toString(),
      price: (tempPlu.price == null) ? "" : tempPlu.price.toString(),
      unitWeight:
          (tempPlu.unitWeight == null) ? "" : tempPlu.unitWeight.toString(),
      pretare: (tempPlu.pretare == null) ? "" : tempPlu.pretare.toString(),
      limitHigh:
          (tempPlu.limitHigh == null) ? "" : tempPlu.limitHigh.toString(),
      limitLow: (tempPlu.limitLow == null) ? "" : tempPlu.limitLow.toString(),
      weight: totalWgt.toStringAsFixed(2),
      weightUnit: _summaryUnit,
      userNo: mySysUser.userId.toString(),
      userName: mySysUser.nickName ?? "",
      scaleMode: '1',
    );

    newAddRec.headRec = headerCommon;

    if (selScaleList.length > 1) {
      for (var scaleId in selScaleList) {
        WeightInfo? wgtDetailInfo = scaleWgtMapDetail[scaleId];
        Scale? scaleInfo;
        for (var s in myAllScalesList) {
          if (s.scaleId == scaleId) {
            scaleInfo = s;
            break;
          }
        }

        NewWgtDetail detailItem = NewWgtDetail(
          no: scaleId,
          scaleModel: scaleInfo?.scaleModel ?? '',
          scaleSn: scaleInfo?.scaleSn ?? '',
          scaleName: scaleInfo?.scaleName ?? 'Scale$scaleId',
          weight: wgtDetailInfo?.weight ?? '0.00',
          weightUnit: wgtDetailInfo?.unit ?? _summaryUnit,
        );
        newAddRec.detailRec?.add(detailItem);
      }
    }

    String jsonPayload = reqAddWgtRecToJson(newAddRec);
    writelog(
        "[MOBILE_TAKEOUT_SAVE_DB] Sending add_wgt_rec payload: $jsonPayload");
    PublicFunctions.addSummaryData(jsonPayload);

    // Reset baseline last weight and decrement weight for saved scales
    for (var id in selScaleList) {
      if (_scaleStartTakeOutMap[id] == true) {
        TakeOutWeightInfo info = _scaleWeightMap[id] ??
            TakeOutWeightInfo(weight: '0.00', unit: 'kg', stable: false);
        _scaleLastWgtMap[id] = double.tryParse(info.weight) ?? 0.0;
        _scaleTakeOutWgtMap[id] = 0.0;
      }
    }

    showTipInfo(
        localizedStrings?.fSaveSuccess ?? "Recorded successfully", context);
  }

  void _recordSingleScaleToDb(int scaleId) {
    TakeOutWeightInfo info = _scaleWeightMap[scaleId] ??
        TakeOutWeightInfo(weight: '0.00', unit: 'kg', stable: false);

    bool isStarted = _scaleStartTakeOutMap[scaleId] ?? false;
    double decVal = _scaleTakeOutWgtMap[scaleId] ?? 0.0;

    String recordedWgtStr = '0.00';
    if (isStarted) {
      if (decVal <= 0) {
        showTipInfo("Invalid weight data", context);
        return;
      }
      recordedWgtStr = decVal.toStringAsFixed(3);
      _scaleLastWgtMap[scaleId] = double.tryParse(info.weight) ?? 0.0;
      _scaleTakeOutWgtMap[scaleId] = 0.0;
    } else {
      double rawW = double.tryParse(info.weight) ?? 0.0;
      if (rawW <= 0) {
        showTipInfo("Invalid weight data", context);
        return;
      }
      recordedWgtStr = rawW.toStringAsFixed(3);
    }

    PluData? plu =
        _isSummaryMode ? _summaryPluData : _independentPluMap[scaleId];
    PluData tempPlu = plu ??
        PluData(null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, '', '');

    Scale? tempDefScaleInfo;
    for (var s in myAllScalesList) {
      if (s.scaleId == scaleId) {
        tempDefScaleInfo = s;
        break;
      }
    }

    final newAddRec = ReqAddWgtRec()
      ..mode = int.parse(wgtTakeOutMode) // Always 3 for Take Out Scale
      ..detailRec = [];

    final headerCommon = Header(
      id: '1',
      scaleModel: tempDefScaleInfo?.scaleModel ?? '',
      scaleSn: tempDefScaleInfo?.scaleSn ?? '',
      scaleName: tempDefScaleInfo?.scaleName ?? 'Scale$scaleId',
      plu: (tempPlu.plu == null) ? "" : tempPlu.plu.toString(),
      productCode:
          (tempPlu.productCode == null) ? "" : tempPlu.productCode.toString(),
      itemCode: (tempPlu.itemCode == null) ? "" : tempPlu.itemCode.toString(),
      category: (tempPlu.category == null) ? "" : tempPlu.category.toString(),
      productName:
          (tempPlu.productName == null) ? "" : tempPlu.productName.toString(),
      generalUnit:
          (tempPlu.generalUnit == null) ? "" : tempPlu.generalUnit.toString(),
      taxType: (tempPlu.taxType == null) ? "" : tempPlu.taxType.toString(),
      price: (tempPlu.price == null) ? "" : tempPlu.price.toString(),
      unitWeight:
          (tempPlu.unitWeight == null) ? "" : tempPlu.unitWeight.toString(),
      pretare: (tempPlu.pretare == null) ? "" : tempPlu.pretare.toString(),
      limitHigh:
          (tempPlu.limitHigh == null) ? "" : tempPlu.limitHigh.toString(),
      limitLow: (tempPlu.limitLow == null) ? "" : tempPlu.limitLow.toString(),
      weight: recordedWgtStr,
      weightUnit: info.unit.isNotEmpty ? info.unit : 'kg',
      userNo: mySysUser.userId.toString(),
      userName: mySysUser.nickName ?? "",
      scaleMode: _isSummaryMode ? '1' : '0',
    );

    newAddRec.headRec = headerCommon;

    String jsonPayload = reqAddWgtRecToJson(newAddRec);
    writelog(
        "[MOBILE_TAKEOUT_SAVE_DB] Sending add_wgt_rec payload: $jsonPayload");
    PublicFunctions.addSummaryData(jsonPayload);

    showTipInfo(
        localizedStrings?.fSaveSuccess ?? "Recorded successfully", context);
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
        title: Text(
          localizedStrings?.menuTakeOutScale ?? "Take Out Scale",
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF1E293B)),
            onPressed: () => _openHelpDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Tab Bar Navigation (Weighing / Record)
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
                              ? const Color(0xFF004884)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          localizedStrings?.menuWeighing ?? "Weighing",
                          style: TextStyle(
                            color: _selectedTab == 0
                                ? Colors.white
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
                              ? const Color(0xFF004884)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          localizedStrings?.fRecordTitle ?? "Record",
                          style: TextStyle(
                            color: _selectedTab == 1
                                ? Colors.white
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
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Tab Content
          Expanded(
            child: _selectedTab == 0
                ? _buildWeighingTabContent()
                : _buildRecordTabContent(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WEIGHING TAB CONTENT
  // ---------------------------------------------------------------------------
  Widget _buildWeighingTabContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Sub-Header Card: Displays Mode Name & Gear Icon
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isSummaryMode
                      ? (localizedStrings?.gTipWeightSummationMode ??
                          "Weight Summary Mode")
                      : (localizedStrings?.gTipStandaloneMode ??
                          "Weight Independent Mode"),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: _openParameterSettingsSheet,
                  child: const Icon(Icons.settings_outlined,
                      color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),

          // Summary Header Card (Red box in user's mockup) when in Summary Mode
          if (_isSummaryMode) _buildSummaryHeaderCard(),

          // List of Scale Cards
          myAllScalesList.isEmpty
              ? _buildScaleCard(UnifiedScale(
                  isOnline: true,
                  scaleModel: "",
                  scaleCat: 0,
                  scaleSn: "",
                  scaleId: 1,
                  tMedia: 0,
                  isDefault: true,
                  scaleName: "Scale1",
                  sendService: false,
                  mediaConfig: SerialMediaConfig(
                    devPath: "COM1",
                    baudRate: 9600,
                    dataBits: 8,
                    stopBits: 1,
                    parity: 0,
                  ),
                ))
              : Column(
                  children: myAllScalesList
                      .where((scale) =>
                          _drawerDeviceCheckedMap[scale.scaleId] ?? true)
                      .map((scale) {
                    return _buildScaleCard(scale);
                  }).toList(),
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryHeaderCard() {
    double grandTotal = 0.0;

    if (myAllScalesList.isEmpty) {
      TakeOutWeightInfo info = _scaleWeightMap[1] ??
          TakeOutWeightInfo(weight: '0.00', unit: 'kg', stable: false);
      double decVal = _scaleTakeOutWgtMap[1] ?? 0.0;
      double convertedW = convertUnit(
          decVal, info.unit.isNotEmpty ? info.unit : 'kg', _summaryUnit);
      grandTotal = convertedW;
    } else {
      for (var scale in myAllScalesList) {
        bool isChecked =
            _drawerDeviceCheckedMap[scale.scaleId] ?? true;
        if (isChecked) {
          int id = scale.scaleId;
          TakeOutWeightInfo info = _scaleWeightMap[id] ??
              TakeOutWeightInfo(weight: '0.00', unit: 'kg', stable: false);
          double decVal = _scaleTakeOutWgtMap[id] ?? 0.0;
          double convertedW = convertUnit(
              decVal, info.unit.isNotEmpty ? info.unit : 'kg', _summaryUnit);
          grandTotal += convertedW;
        }
      }
    }

    String pluDisplayText = "PLU";
    if (_summaryPluData != null) {
      pluDisplayText =
          "${_summaryPluData!.plu ?? ''}:${_summaryPluData!.productName ?? ''}";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          // Top PLU Selection Row
          InkWell(
            onTap: () => _openPluSelectionSheet(scaleId: null),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pluDisplayText,
                    style: TextStyle(
                      color: _summaryPluData != null
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF94A3B8),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF64748B), size: 20),
                ],
              ),
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Bottom Weight, Unit & Save Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    grandTotal.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Color(0xFF004884),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _summaryUnit,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Color(0xFF64748B)),
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (String? newUnit) {
                        if (newUnit != null) {
                          setState(() {
                            _summaryUnit = newUnit;
                          });
                        }
                      },
                      items: <String>['kg', 'g', 'lb', 'oz']
                          .map<DropdownMenuItem<String>>((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _recordSummaryToDb(),
                child: Container(
                  width: 60,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: getSvgIcon(
                      saveSvgIcon(), 26, 26, const Color(0xFF10B981)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScaleCard(Scale scale) {
    int id = scale.scaleId;
    TakeOutWeightInfo info = _scaleWeightMap[id] ??
        TakeOutWeightInfo(weight: '0.00', unit: 'kg', stable: false);
    bool isOnline = scale.isOnline;

    bool isStarted = _scaleStartTakeOutMap[id] ?? false;
    double decVal = _scaleTakeOutWgtMap[id] ?? 0.0;

    String pluDisplayText = "PLU";
    PluData? plu = _isSummaryMode ? _summaryPluData : _independentPluMap[id];
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
          // 1. Header Row (Scale Name on Left, PLU Selector on Right for Independent Mode)
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
                if (!_isSummaryMode)
                  InkWell(
                    onTap: () => _openPluSelectionSheet(scaleId: id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pluDisplayText,
                            style: TextStyle(
                              color: plu != null
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF64748B), size: 18),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 2. Main Live Weight & Status Tags Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
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
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: info.isZero
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        "0",
                        style: TextStyle(
                          color: info.isZero
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        "NET",
                        style: TextStyle(
                          color: info.isNet
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        "->0<-",
                        style: TextStyle(
                          color: info.isZero
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
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

          // 3. Sub-Weight Display Row (Take Out Decrement Weight)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              children: [
                Text(
                  isStarted
                      ? decVal.toStringAsFixed(3)
                      : (isOnline ? "0.000" : "-- --"),
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
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
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 4. Action Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  svgPath: performTareSvgIcon(),
                  color: const Color(0xFF004884),
                  onPressed: isOnline ? () => _performTare(id) : null,
                ),
                const SizedBox(width: 10),
                _buildActionButton(
                  svgPath: performZeroSvgIcon(),
                  color: const Color(0xFF004884),
                  onPressed: isOnline ? () => _performZero(id) : null,
                ),
                const SizedBox(width: 10),
                _buildActionButton(
                  svgPath: isStarted ? endWgtSvgIcon() : startWgtSvgIcon(),
                  color: isStarted
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF004884),
                  onPressed: isOnline ? () => _toggleStartTakeOut(id) : null,
                ),
                if (!_isSummaryMode) ...[
                  const SizedBox(width: 10),
                  _buildActionButton(
                    svgPath: saveSvgIcon(),
                    color: const Color(0xFF10B981),
                    isSave: true,
                    onPressed: () => _recordSingleScaleToDb(id),
                  ),
                ],
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
  // RECORD TAB CONTENT
  // ---------------------------------------------------------------------------
  Widget _buildRecordTabContent() {
    return Column(
      children: [
        // Records List
        Expanded(
          child: _allWgtRecList.isEmpty
              ? Center(
                  child: Text(
                    localizedStrings?.fNoRecordTip ?? "No records found",
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _allWgtRecList.length,
                  itemBuilder: (context, index) {
                    return _buildRecordCard(_allWgtRecList[index], index + 1);
                  },
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
                              await PublicFunctions.pickSaveFilePath('export.csv');
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
                                int.parse(wgtTakeOutMode),
                                outputFile,
                                selFields,
                                selMap);
                          }
                        },
                        child: Text(
                          localizedStrings?.gBtnExport ?? "Export",
                          style: const TextStyle(
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
                        child: Text(
                          localizedStrings?.gBtnReportSetting ?? "Report Setting",
                          style: const TextStyle(
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
                        int.parse(wgtTakeOutMode));
                  },
                  child: Text(
                    localizedStrings?.gBtnDeleteAll ?? "Delete All",
                    style: const TextStyle(
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

                  const SizedBox(height: 10),

                  // 3-Column Fields Grid for Extended Attributes
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_visibleFields['Product Code'] == true)
                              _buildGridCell(
                                  "Product Code", header?.productCode ?? ""),
                            if (_visibleFields['Price'] == true)
                              _buildGridCell("Price", header?.price ?? ""),
                            if (_visibleFields['Unit Weight'] == true)
                              _buildGridCell(
                                  "Unit Weight", header?.unitWeight ?? ""),
                            if (_visibleFields['Operator'] == true)
                              _buildGridCell(
                                  "Operator", header?.userName ?? ""),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_visibleFields['Item Code'] == true)
                              _buildGridCell(
                                  "Item Code", header?.itemCode ?? ""),
                            if (_visibleFields['Unit'] == true)
                              _buildGridCell(
                                  "Unit", header?.generalUnit ?? ""),
                            if (_visibleFields['Limit High'] == true)
                              _buildGridCell(
                                  "Limit High", header?.limitHigh ?? ""),
                            if (isSummary && _visibleFields['Scale Name'] == true)
                              _buildGridCell(
                                  "Scale Name", header?.scaleName ?? ""),
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
                              _buildGridCell(
                                  "Limit Low", header?.limitLow ?? ""),
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
      ),
    );
  }

  String _formatDateTimeStr(DateTime? dt) {
    if (dt == null) return "";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${dt.year}.${twoDigits(dt.month)}.${twoDigits(dt.day)} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}:${twoDigits(dt.second)}";
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

  Widget _buildGridCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          const SizedBox(height: 2),
          Text(value.isNotEmpty ? value : "--",
              style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
                  bool current = _drawerDeviceCheckedMap[scale.scaleId] ?? true;
                  bool newChecked = !current;
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
  // MODAL SHEETS & DIALOGS
  // ---------------------------------------------------------------------------
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
                        Expanded(
                          child: Text(
                            localizedStrings?.gParameterSettingsTitle ??
                                "Parameter settings",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      children: [
                        // Weight Summary Mode Switch Row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizedStrings?.gTipWeightSummationMode ??
                                    "Weight Summary Mode",
                                style: const TextStyle(
                                    fontSize: 15, color: Color(0xFF334155)),
                              ),
                              Switch(
                                value: tempSummaryMode,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (val) {
                                  setModalState(() {
                                    tempSummaryMode = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        _buildSettingOptionRow(
                          title: localizedStrings?.save_mode ?? "Save Mode",
                          val: tempSaveMode == "Auto"
                              ? (localizedStrings?.gTipAuto ?? "Auto")
                              : (localizedStrings?.gTipManual ?? "Manual"),
                          onTap: () {
                            _openSubSelectionModal(
                              localizedStrings?.save_mode ?? "Save Mode",
                              [
                                localizedStrings?.gTipManual ?? "Manual",
                                localizedStrings?.gTipAuto ?? "Auto"
                              ],
                              tempSaveMode == "Auto"
                                  ? (localizedStrings?.gTipAuto ?? "Auto")
                                  : (localizedStrings?.gTipManual ?? "Manual"),
                              (selected) {
                                setModalState(() {
                                  tempSaveMode = selected ==
                                          (localizedStrings?.gTipAuto ?? "Auto")
                                      ? "Auto"
                                      : "Manual";
                                });
                              },
                            );
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizedStrings?.gTipStableTime ??
                                    "Stable Time (s)",
                                style: const TextStyle(
                                    fontSize: 15, color: Color(0xFF334155)),
                              ),
                              SizedBox(
                                width: 60,
                                height: 36,
                                child: TextField(
                                  controller: _stableTimeController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        _buildSettingOptionRow(
                          title: localizedStrings?.date_format ?? "Date Format",
                          val: tempDateFormat,
                          onTap: () {
                            _openSubSelectionModal(
                              localizedStrings?.date_format ?? "Date Format",
                              ["yy-mm-dd", "dd-mm-yy", "mm-dd-yy"],
                              tempDateFormat,
                              (selected) {
                                setModalState(() {
                                  tempDateFormat = selected;
                                });
                              },
                            );
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        _buildSettingOptionRow(
                          title: localizedStrings?.gDateSeparator ??
                              "Date Separator",
                          val: tempDateSeparator,
                          onTap: () {
                            _openSubSelectionModal(
                              localizedStrings?.gDateSeparator ??
                                  "Date Separator",
                              ["/", "-", "."],
                              tempDateSeparator,
                              (selected) {
                                setModalState(() {
                                  tempDateSeparator = selected;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
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
                            _isSummaryMode = tempSummaryMode;
                            _saveMode = tempSaveMode;
                            _stableTime = _stableTimeController.text;
                            _dateFormat = tempDateFormat;
                            _dateSeparator = tempDateSeparator;
                          });
                          _saveUiConfToDb();
                          Navigator.pop(context);
                        },
                        child: Text(
                          localizedStrings?.gBtnConfirm ?? "Confirm",
                          style: const TextStyle(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF004884)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            opt,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check,
                                color: Colors.white, size: 20),
                        ],
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

  void _openPluSelectionSheet({required int? scaleId}) {
    String searchText = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<PluData> filteredList = myPluInfoList.where((p) {
              if (searchText.isEmpty) return true;
              String q = searchText.toLowerCase();
              return (p.plu?.toString().toLowerCase().contains(q) ?? false) ||
                  (p.productName?.toLowerCase().contains(q) ?? false);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizedStrings?.gPluName ?? "Select PLU",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: localizedStrings?.fSearchHint ?? "Please enter",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        searchText = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: Text(localizedStrings?.fNoRecordTip ??
                                "No PLU available"))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: filteredList.length,
                            itemBuilder: (context, i) {
                              PluData plu = filteredList[i];
                              bool isSelected = scaleId == null
                                  ? (_summaryPluData?.plu == plu.plu)
                                  : (_independentPluMap[scaleId]?.plu ==
                                      plu.plu);

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (scaleId == null) {
                                      _summaryPluData = plu;
                                    } else {
                                      _independentPluMap[scaleId] = plu;
                                    }
                                  });
                                  Navigator.pop(context);
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openReportSettingSheet() {
    Map<String, bool> tempFields = Map.from(_visibleFields);
    bool selectAll = tempFields.values.every((v) => v);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          localizedStrings?.gBtnReportSetting ??
                              "Report Setting",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: tempFields.keys.length,
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
                                          fontSize: 14,
                                          color: Color(0xFF334155)),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: selectAll,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (val) {
                                  bool boolVal = val ?? false;
                                  setModalState(() {
                                    selectAll = boolVal;
                                    for (var k in tempFields.keys) {
                                      tempFields[k] = boolVal;
                                    }
                                  });
                                },
                              ),
                              Text(localizedStrings?.gSelectAll ?? "Select all",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                          _visibleFields.addAll(tempFields);
                        });
                        Navigator.pop(context);
                      },
                      child: Text(localizedStrings?.gBtnConfirm ?? "Confirm",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
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

  void _openHelpDialog() {
    showMobilePageHelpDialog(
      context,
      localizedStrings?.menuTakeOutScale ?? "Take Out Scale",
      localizedStrings?.gTipTakeOutPageHelp ??
          localizedStrings?.gTipIncrementWgtPageHelp ??
          "1. Click [Start] to activate Take Out Scale function. It records the weight decrement during unloading.\n2. Click [Save] to save current weight decrement record.\n3. Click [Record] tab to view saved records.\n4. Click [Settings] to switch save mode (Manual/Auto) and set date format.",
    );
  }
}
