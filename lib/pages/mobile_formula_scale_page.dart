import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/pages/mobile_category_management_page.dart';
import 'package:t_max/pages/mobile_edit_formula_page.dart';
import 'package:t_max/pages/mobile_edit_ingredient_page.dart';
import 'package:t_max/pages/mobile_ingredient_detail_page.dart';
import 'package:t_max/pages/mobile_formula_records_page.dart';
import 'package:t_max/pages/mobile_formula_record_detail_page.dart';
import 'package:t_max/pages/mobile_formula_detail_page.dart';
import 'package:t_max/pages/start_fma_pct_page.dart';
import 'package:t_max/pages/start_fma_secret_page.dart';

class MobileFormulaScalePage extends StatefulWidget {
  final Function(String)? onNavigate;
  final String? lastRouteName;

  const MobileFormulaScalePage({
    super.key,
    this.onNavigate,
    this.lastRouteName,
  });

  @override
  State<MobileFormulaScalePage> createState() => _MobileFormulaScalePageState();
}

class _MobileFormulaScalePageState extends State<MobileFormulaScalePage> {
  // Current active sub-list tab index: 0 = Formula List, 1 = Ingredient List, 2 = Temporary Storage Record
  int _activeListIndex = 0;
  final List<String> _listTabTitles = [
    'Formula List',
    'Ingredient List',
    'Temporary Storage Record',
  ];

  // Drawer scale checked states
  final Map<int, bool> _drawerDeviceCheckedMap = {};

  // Search & Filters
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Category';
  String _selectedConfidential = 'Confidential';

  // Data lists
  List<FormulaInfoDb> _searchFmaList = [];
  final Set<int> _selectedFormulaIds = {};

  List<RawDataInfo> _searchRawList = [];
  final Set<int> _selectedRawIds = {};

  List<DarfFmaInfo> _searchDraftFmaList = [];
  final Set<String> _selectedDraftIds = {};

  // Eventbus listeners
  dynamic _eventbusFormulaList;
  dynamic _eventbusFormulaType;
  dynamic _eventbusDelFormula;
  dynamic _eventbusDelManyFma;
  dynamic _eventbusAddFormula;
  dynamic _eventbusUpdateFormula;
  dynamic _eventbusRawList;
  dynamic _eventbusRawType;
  dynamic _eventbusAddRaw;
  dynamic _eventbusEditRaw;
  dynamic _eventbusDelRaw;
  dynamic _eventbusDelManyRaw;
  dynamic _eventbusDraftFma;
  dynamic _eventbusDelDraft;
  dynamic _eventbusCreateDraft;

  @override
  void initState() {
    super.initState();
    _initEventBusListeners();
    _loadData();
  }

  void _initEventBusListeners() {
    _eventbusFormulaList = eventBus.on<EventRespFormulaList>().listen((event) {
      if (!mounted) return;
      String dataStr = event.obj;
      if (dataStr.isNotEmpty && dataStr != 'null') {
        try {
          List<FormulaInfoDb> temp = formulaInfoDbFromJson(dataStr);
          setState(() {
            formulaDataList = temp;
            _filterFormulas();
          });
        } catch (e) {
          debugPrint('Error parsing formula list: $e');
        }
      } else {
        setState(() {
          formulaDataList = [];
          _searchFmaList = [];
        });
      }
    });

    _eventbusFormulaType = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
      if (!mounted) return;
      String dataStr = event.obj;
      if (dataStr.isNotEmpty && dataStr != 'null') {
        try {
          setState(() {
            formulaTypeList = categoryTypeListFromJson(dataStr);
          });
        } catch (e) {
          debugPrint('Error parsing formula types: $e');
        }
      }
    });

    _eventbusRawList = eventBus.on<EventRespGetRawDataList>().listen((event) {
      if (!mounted) return;
      String dataStr = event.obj;
      if (dataStr.isNotEmpty && dataStr != 'null') {
        try {
          List<RawDataInfo> temp = rawDataInfoFromJson(dataStr);
          setState(() {
            rawDataList = temp;
            _filterRawMaterials();
          });
        } catch (e) {
          debugPrint('Error parsing raw list: $e');
        }
      } else {
        setState(() {
          rawDataList = [];
          _searchRawList = [];
        });
      }
    });

    _eventbusRawType = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (!mounted) return;
      String dataStr = event.obj;
      if (dataStr.isNotEmpty && dataStr != 'null') {
        try {
          setState(() {
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } catch (e) {
          debugPrint('Error parsing raw types: $e');
        }
      }
    });

    _eventbusDelFormula = eventBus.on<EventRespDelFormula>().listen((event) {
      if (!mounted) return;
      _loadData();
    });

    _eventbusDelManyFma = eventBus.on<EventRespDelManyFma>().listen((event) {
      if (!mounted) return;
      _loadData();
    });

    _eventbusAddRaw = eventBus.on<EventRespAddRawData>().listen((event) {
      if (!mounted) return;
      _loadData();
    });

    _eventbusEditRaw = eventBus.on<EventRespEditRawData>().listen((event) {
      if (!mounted) return;
      _loadData();
    });

    _eventbusDelRaw = eventBus.on<EventRespDelRawData>().listen((event) {
      if (!mounted) return;
      _loadData();
    });

    _eventbusDelManyRaw = eventBus.on<EventRespDelManyRaw>().listen((event) {
      if (!mounted) return;
      _loadData();
    });

    _eventbusAddFormula = eventBus.on<EventRespAddFormula>().listen((event) {
      if (!mounted) return;
      _loadData();
    });

    _eventbusUpdateFormula = eventBus.on<EventRespEditFormula>().listen((event) {
      if (!mounted) return;
      _loadData();
    });

    _eventbusDraftFma = eventBus.on<EventRespGetDraftFmaWgtRecList>().listen((event) {
      if (!mounted) return;
      String dataStr = event.obj;
      if (dataStr.isNotEmpty && dataStr != 'null') {
        try {
          List<DarfFmaInfoListFromDb> dbList = darfFmaInfoListFromDbFromJson(dataStr);
          List<DarfFmaInfo> tempList = [];
          for (var item in dbList) {
            DarfFmaInfo tempDarfFma = DarfFmaInfo();
            for (var fmaRec in formulaDataList) {
              if (fmaRec.header?.formulaId == item.header?.formulaId) {
                tempDarfFma.fmaRec = item;
                tempDarfFma.fmaInfo = fmaRec;
                break;
              }
            }
            tempList.add(tempDarfFma);
          }
          setState(() {
            darfFmaInfoList = tempList;
            _filterDraftFormulas();
          });
        } catch (e) {
          debugPrint('Error parsing draft formula list: $e');
        }
      } else {
        setState(() {
          darfFmaInfoList = [];
          _searchDraftFmaList = [];
        });
      }
    });

    _eventbusDelDraft = eventBus.on<EventRespDelDraftFmaWgtRecList>().listen((event) {
      if (!mounted) return;
      PublicFunctions.getDraftRecords();
    });

    _eventbusCreateDraft = eventBus.on<EventRespCreateDraftFmaWgtRecList>().listen((event) {
      if (!mounted) return;
      PublicFunctions.getDraftRecords();
    });
  }

  void _loadData() {
    PublicFunctions.getFormulaTypeList();
    PublicFunctions.getFormulaList();
    PublicFunctions.getRawTypeList();
    PublicFunctions.getRawList();
    PublicFunctions.getDraftRecords();
  }

  void _filterDraftFormulas() {
    String query = _searchController.text.trim().toLowerCase();
    List<DarfFmaInfo> list = List.from(darfFmaInfoList);

    if (query.isNotEmpty) {
      list = list.where((d) {
        String name = d.fmaInfo?.header?.formulaName?.toLowerCase() ?? '';
        String id = d.fmaInfo?.header?.formulaId?.toLowerCase() ?? '';
        String orderId = d.fmaRec?.header?.orderId?.toLowerCase() ?? '';
        return name.contains(query) || id.contains(query) || orderId.contains(query);
      }).toList();
    }

    setState(() {
      _searchDraftFmaList = list;
    });
  }

  void _filterFormulas() {
    String query = _searchController.text.trim().toLowerCase();
    List<FormulaInfoDb> list = List.from(formulaDataList);

    if (query.isNotEmpty) {
      list = list.where((f) {
        String name = f.header?.formulaName?.toLowerCase() ?? '';
        String id = f.header?.formulaId?.toString() ?? '';
        return name.contains(query) || id.contains(query);
      }).toList();
    }

    if (_selectedConfidential != 'Confidential' && _selectedConfidential != 'All') {
      bool isConfidential = _selectedConfidential == 'Confidential' || _selectedConfidential == '保密';
      list = list.where((f) {
        bool confidential = f.header?.isEncrypted ?? false;
        return isConfidential ? confidential : !confidential;
      }).toList();
    }

    setState(() {
      _searchFmaList = list;
    });
  }

  void _filterRawMaterials() {
    String query = _searchController.text.trim().toLowerCase();
    List<RawDataInfo> list = List.from(rawDataList);

    if (query.isNotEmpty) {
      list = list.where((raw) {
        String name = raw.materialName?.toLowerCase() ?? '';
        String id = raw.materialId?.toLowerCase() ?? '';
        return name.contains(query) || id.contains(query);
      }).toList();
    }

    if (_selectedCategory != 'Category' && _selectedCategory != 'All') {
      list = list.where((raw) {
        return getRawTypeName(raw.categoryId ?? 0) == _selectedCategory;
      }).toList();
    }

    setState(() {
      _searchRawList = list;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _eventbusFormulaList?.cancel();
    _eventbusFormulaType?.cancel();
    _eventbusRawList?.cancel();
    _eventbusRawType?.cancel();
    _eventbusDelFormula?.cancel();
    _eventbusDelManyFma?.cancel();
    _eventbusAddFormula?.cancel();
    _eventbusUpdateFormula?.cancel();
    _eventbusAddRaw?.cancel();
    _eventbusEditRaw?.cancel();
    _eventbusDelRaw?.cancel();
    _eventbusDelManyRaw?.cancel();
    _eventbusDraftFma?.cancel();
    _eventbusDelDraft?.cancel();
    _eventbusCreateDraft?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DEVICE LIST DRAWER
  // ---------------------------------------------------------------------------
  void _openDeviceListDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DeviceDrawer',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setDrawerState) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: double.infinity,
                  color: Colors.white,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            localizedStrings?.fScaleList ?? 'Scale List',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF004884),
                            ),
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),

                        // Device List
                        Expanded(
                          child: myAllScalesList.isEmpty
                              ? Center(
                                  child: Text(
                                    localizedStrings?.gTipNoDevice ?? 'No devices found',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  itemCount: myAllScalesList.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    Scale scale = myAllScalesList[index];
                                    int id = scale.scaleId;
                                    bool isChecked = _drawerDeviceCheckedMap[id] ?? scale.isOnline;

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: isChecked ? const Color(0xFF004884) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isChecked ? const Color(0xFF004884) : Colors.grey.shade200,
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isChecked
                                                ? Colors.white.withValues(alpha: 0.2)
                                                : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.language,
                                            color: isChecked ? Colors.white : const Color(0xFF004884),
                                          ),
                                        ),
                                        title: Text(
                                          scale.scaleName.isNotEmpty
                                              ? scale.scaleName
                                              : 'Device No.${scale.scaleId}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isChecked ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        subtitle: Text(
                                          scale.isOnline
                                              ? (localizedStrings?.gTipOnline ?? 'Online')
                                              : (localizedStrings?.gTipOffline ?? 'Offline'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isChecked
                                                ? Colors.white.withValues(alpha: 0.8)
                                                : (scale.isOnline
                                                    ? Colors.green.shade600
                                                    : Colors.red.shade400),
                                          ),
                                        ),
                                        onTap: () {
                                          setDrawerState(() {
                                            _drawerDeviceCheckedMap[id] = !isChecked;
                                          });
                                          setState(() {});
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SELECT LIST BOTTOM SHEET (Formula List vs Ingredient List)
  // ---------------------------------------------------------------------------
  void _openSelectListBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Option Cards
                ...List.generate(_listTabTitles.length, (index) {
                  bool isSelected = _activeListIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _activeListIndex = index;
                          _searchController.clear();
                          _selectedCategory = 'Category';
                          if (index == 0) {
                            _filterFormulas();
                          } else if (index == 1) {
                            _filterRawMaterials();
                          }
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF004884) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _listTabTitles[index],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION & ACTIONS
  // ---------------------------------------------------------------------------
  void _openFormulaRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MobileFormulaRecordsPage(),
      ),
    );
  }

  void _startFormulaWeighing(FormulaInfoDb formula) {
    bool confidential = formula.header?.isEncrypted ?? false;
    int scaleId = myAllScalesList.isNotEmpty ? myAllScalesList.first.scaleId : 1;
    double totalWgt = formula.header?.totalWeight ?? 1000.0;
    String unit = formula.header?.formulaUnit ?? 'g';

    if (confidential) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormulaSecretWeighingPage(
            selectFormula: formula,
            selScaleId: scaleId,
            totalFmaWgt: totalWgt,
            fmaUnit: unit,
            fromDraft: false,
            selectDarftInfo: null,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormulaPctWeighingPage(
            selectFormula: formula,
            selScaleId: scaleId,
            totalFmaWgt: totalWgt,
            fmaUnit: unit,
            fromDarft: false,
          ),
        ),
      );
    }
  }

  void _onAddNewItem() {
    if (_activeListIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileEditFormulaPage(),
        ),
      ).then((_) => _loadData());
    } else if (_activeListIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileEditIngredientPage(),
        ),
      ).then((_) => _loadData());
    }
  }

  void _openIngredientDetailScreen(RawDataInfo raw) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileIngredientDetailPage(rawInfo: raw),
      ),
    ).then((_) => _loadData());
  }

  void _deleteSelectedRawMaterials() {
    if (_selectedRawIds.isEmpty) return;
    List<int> idsToDelete = List.from(_selectedRawIds);
    setState(() {
      rawDataList.removeWhere((item) => item.recId != null && idsToDelete.contains(item.recId));
      _selectedRawIds.clear();
      _filterRawMaterials();
    });
    for (var recId in idsToDelete) {
      PublicFunctions.deleteRawData(recId);
    }
    _loadData();
  }

  // ---------------------------------------------------------------------------
  // BUILD METHOD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (widget.onNavigate != null && widget.lastRouteName != null) {
              widget.onNavigate!(widget.lastRouteName!);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.scale, color: Color(0xFF004884)),
              onPressed: _openDeviceListDrawer,
            ),
            const SizedBox(width: 4),
            const Text(
              'Formula',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: _onAddNewItem,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Row 1: Dropdown List Selector Trigger
                  InkWell(
                    onTap: _openSelectListBottomSheet,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _listTabTitles[_activeListIndex],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Row 2: Search & Filter Inputs
                  Row(
                    children: [
                      // Search Field
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) {
                              if (_activeListIndex == 0) {
                                _filterFormulas();
                              } else if (_activeListIndex == 1) {
                                _filterRawMaterials();
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'ID or Name',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      if (_activeListIndex == 2) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: _selectedDraftIds.isNotEmpty ? const Color(0xFF004884) : Colors.grey.shade400,
                            size: 24,
                          ),
                          onPressed: _selectedDraftIds.isNotEmpty ? _deleteSelectedDraftRecords : null,
                          tooltip: 'Delete Selected Drafts',
                        ),
                      ] else ...[
                        // Category Dropdown
                        Expanded(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                                items: ['Category', ...(_activeListIndex == 0 ? formulaTypeList : rawTypeList).map((t) => t.categoryName)]
                                    .map((String val) => DropdownMenuItem(
                                          value: val,
                                          child: Text(val, overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCategory = val);
                                    if (_activeListIndex == 0) {
                                      _filterFormulas();
                                    } else if (_activeListIndex == 1) {
                                      _filterRawMaterials();
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        if (_activeListIndex == 0) ...[
                          const SizedBox(width: 8),
                          // Confidential Dropdown
                          Expanded(
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedConfidential,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  items: ['Confidential', 'All', 'Public']
                                      .map((String val) => DropdownMenuItem(
                                            value: val,
                                            child: Text(val, overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedConfidential = val);
                                      _filterFormulas();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 3: Action Row depending on active list tab
                  if (_activeListIndex == 0) ...[
                    Row(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Row(
                            children: const [
                              Icon(Icons.qr_code_scanner, color: Color(0xFF004884), size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Barcode',
                                style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        InkWell(
                          onTap: _openFormulaRecords,
                          child: Row(
                            children: const [
                              Icon(Icons.article_outlined, color: Color(0xFF004884), size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Records',
                                style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (_activeListIndex == 1) ...[
                    // 4 Action Icons for Ingredient List: [Import], [Export], [Category Management], [Delete]
                    Row(
                      children: [
                        // Import Icon [↓]
                        IconButton(
                          icon: const Icon(Icons.file_download_outlined, color: Color(0xFF004884)),
                          onPressed: () {},
                          tooltip: 'Import',
                        ),
                        // Export Icon [↑]
                        IconButton(
                          icon: const Icon(Icons.file_upload_outlined, color: Color(0xFF004884)),
                          onPressed: () {},
                          tooltip: 'Export',
                        ),
                        // Category Management Icon [≡]
                        IconButton(
                          icon: const Icon(Icons.list_alt_outlined, color: Color(0xFF004884)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MobileCategoryManagementPage(isRawType: true),
                              ),
                            ).then((_) => _loadData());
                          },
                          tooltip: 'Category Management',
                        ),
                        const Spacer(),
                        // Delete Icon [🗑]
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: _selectedRawIds.isNotEmpty ? Colors.red : Colors.grey.shade400,
                          ),
                          onPressed: _selectedRawIds.isNotEmpty ? _deleteSelectedRawMaterials : null,
                          tooltip: 'Delete Selected',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Main List View
            Expanded(
              child: _activeListIndex == 0
                  ? _buildFormulaListView()
                  : (_activeListIndex == 1
                      ? _buildIngredientListView()
                      : _buildTemporaryStorageListView()),
            ),

            // Bottom Sticky Panel for Formula List and Ingredient List
            _buildBottomActionPanel(),
          ],
        ),
      ),
    );
  }

  void _deleteSelectedFormulas() {
    if (_selectedFormulaIds.isEmpty) return;
    List<int> idsToDelete = List.from(_selectedFormulaIds);
    setState(() {
      formulaDataList.removeWhere((item) => item.header?.recId != null && idsToDelete.contains(item.header!.recId));
      _selectedFormulaIds.clear();
      _filterFormulas();
    });
    for (var recId in idsToDelete) {
      PublicFunctions.deleteFormulaData(recId);
    }
  }

  void _deleteSelectedDraftRecords() {
    if (_selectedDraftIds.isEmpty) return;
    List<String> ordersToDelete = List.from(_selectedDraftIds);
    setState(() {
      darfFmaInfoList.removeWhere((item) => item.fmaRec?.header?.orderId != null && ordersToDelete.contains(item.fmaRec!.header!.orderId));
      _selectedDraftIds.clear();
      _filterDraftFormulas();
    });
    for (var orderId in ordersToDelete) {
      PublicFunctions.deleteDraftRecord(orderId);
    }
  }

  Widget _buildBottomActionPanel() {
    if (_activeListIndex > 1) return const SizedBox.shrink();

    bool isFormulaTab = _activeListIndex == 0;
    bool hasSelection = isFormulaTab ? _selectedFormulaIds.isNotEmpty : _selectedRawIds.isNotEmpty;
    String templateText = isFormulaTab ? 'Get Formula Template' : 'Get Ingredient Template';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top full-width Template Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading $templateText...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004884),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: Text(
                templateText,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Bottom 3-button equal width row (Export, Import, Delete)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004884),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                    ),
                    child: const Text('Export', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004884),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                    ),
                    child: const Text('Import', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: hasSelection ? (isFormulaTab ? _deleteSelectedFormulas : _deleteSelectedRawMaterials) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasSelection ? const Color(0xFFEF4444) : const Color(0xFFD1D5DB),
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: hasSelection ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaListView() {
    return _searchFmaList.isEmpty
        ? Center(
            child: Text(
              'No formulas available',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchFmaList.length,
            separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              FormulaInfoDb formula = _searchFmaList[index];
              int recId = formula.header?.recId ?? 0;
              String idStr = (formula.header?.formulaId != null && formula.header!.formulaId!.isNotEmpty)
                  ? formula.header!.formulaId!
                  : (index + 1).toString().padLeft(3, '0');
              String name = formula.header?.formulaName ?? '-';
              bool isConfidential = formula.header?.isEncrypted ?? false;
              bool isSelected = _selectedFormulaIds.contains(recId);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: isSelected,
                      activeColor: const Color(0xFF004884),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedFormulaIds.add(recId);
                          } else {
                            _selectedFormulaIds.remove(recId);
                          }
                        });
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004884),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        idStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isConfidential ? 'Confidential' : 'Public',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isConfidential ? Colors.red.shade600 : Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MobileFormulaDetailPage(formula: formula),
                    ),
                  ).then((_) => _loadData());
                },
              );
            },
          );
  }

  Widget _buildIngredientListView() {
    List<RawDataInfo> displayRawList = _searchRawList;

    return displayRawList.isEmpty
        ? Center(
            child: Text(
              'No ingredients available',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayRawList.length,
            separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              RawDataInfo raw = displayRawList[index];
              int recId = raw.recId ?? index + 1;
              String idStr = (raw.materialId != null && raw.materialId!.isNotEmpty)
                  ? raw.materialId!
                  : (index + 1).toString().padLeft(3, '0');
              String name = (raw.materialName != null && raw.materialName!.isNotEmpty)
                  ? raw.materialName!
                  : '-';
              bool isSelected = _selectedRawIds.contains(recId);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: isSelected,
                      activeColor: const Color(0xFF004884),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedRawIds.add(recId);
                          } else {
                            _selectedRawIds.remove(recId);
                          }
                        });
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004884),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        idStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => _openIngredientDetailScreen(raw),
              );
            },
          );
  }

  Widget _buildTemporaryStorageListView() {
    List<DarfFmaInfo> displayList = _searchDraftFmaList;

    return displayList.isEmpty
        ? Center(
            child: Text(
              'No temporary storage records available',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayList.length,
            separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              DarfFmaInfo darftFma = displayList[index];
              String orderId = darftFma.fmaRec?.header?.orderId ?? index.toString();
              String idStr = (darftFma.fmaInfo?.header?.formulaId != null &&
                      darftFma.fmaInfo!.header!.formulaId!.isNotEmpty)
                  ? darftFma.fmaInfo!.header!.formulaId!
                  : (index + 1).toString().padLeft(3, '0');
              String name = darftFma.fmaInfo?.header?.formulaName ?? '-';
              bool isSelected = _selectedDraftIds.contains(orderId);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: isSelected,
                      activeColor: const Color(0xFF004884),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedDraftIds.add(orderId);
                          } else {
                            _selectedDraftIds.remove(orderId);
                          }
                        });
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004884),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        idStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MobileFormulaRecordDetailPage(
                          darftFma: darftFma,
                          selScaleId: myAllScalesList.isNotEmpty ? myAllScalesList.first.scaleId : 1,
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MobileFormulaRecordDetailPage(
                        darftFma: darftFma,
                        selScaleId: myAllScalesList.isNotEmpty ? myAllScalesList.first.scaleId : 1,
                      ),
                    ),
                  ).then((_) => _loadData());
                },
              );
            },
          );
  }
}
