import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/fma_type_mgr.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';

class MobileCategoryManagementPage extends StatefulWidget {
  final bool isRawType;

  const MobileCategoryManagementPage({
    super.key,
    this.isRawType = false,
  });

  @override
  State<MobileCategoryManagementPage> createState() => _MobileCategoryManagementPageState();
}

class _MobileCategoryManagementPageState extends State<MobileCategoryManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoryTypeList> _filteredCategoryList = [];

  dynamic _eventbusGetList;
  dynamic _eventbusAddType;

  @override
  void initState() {
    super.initState();
    _performSearch('');
    _initEventBus();
    _fetchTypeList();
  }

  void _fetchTypeList() {
    if (widget.isRawType) {
      PublicFunctions.getRawTypeList();
    } else {
      PublicFunctions.getFormulaTypeList();
    }
  }

  List<CategoryTypeList> get _currentSourceList {
    return widget.isRawType ? rawTypeList : formulaTypeList;
  }

  void _initEventBus() {
    if (widget.isRawType) {
      _eventbusGetList = eventBus.on<EventRespGetRawTypeList>().listen((event) {
        if (!mounted) return;
        String dataStr = event.obj;
        if (dataStr.isNotEmpty && dataStr != 'null') {
          try {
            setState(() {
              rawTypeList = categoryTypeListFromJson(dataStr);
              _performSearch(_searchController.text);
            });
          } catch (_) {}
        } else {
          setState(() {
            rawTypeList = [];
            _filteredCategoryList = [];
          });
        }
      });

      _eventbusAddType = eventBus.on<EventRespRawTypeAdd>().listen((event) {
        if (!mounted) return;
        PublicFunctions.getRawTypeList();
      });
    } else {
      _eventbusGetList = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
        if (!mounted) return;
        String dataStr = event.obj;
        if (dataStr.isNotEmpty && dataStr != 'null') {
          try {
            setState(() {
              formulaTypeList = categoryTypeListFromJson(dataStr);
              _performSearch(_searchController.text);
            });
          } catch (_) {}
        } else {
          setState(() {
            formulaTypeList = [];
            _filteredCategoryList = [];
          });
        }
      });

      _eventbusAddType = eventBus.on<EventRespAddFormulaType>().listen((event) {
        if (!mounted) return;
        PublicFunctions.getFormulaTypeList();
      });
    }
  }

  void _performSearch(String query) {
    String keyword = query.trim().toLowerCase();
    setState(() {
      _filteredCategoryList = _currentSourceList.where((item) {
        return item.categoryId != 0 &&
            item.categoryName.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _eventbusGetList?.cancel();
    _eventbusAddType?.cancel();
    super.dispose();
  }

  void _showDeleteUnusedDialog() {
    showDialog(
      context: context,
      builder: (_) => const ShowDeleteTipDialog(
        title: 'Tip',
        msg: 'Are you sure you want to delete unused categories?',
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        if (widget.isRawType) {
          PublicFunctions.delUnusedRawType();
        } else {
          PublicFunctions.delUnusedFmaType();
        }
      }
    });
  }

  void _openAddCategoryBottomSheet() {
    TextEditingController categoryInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool canConfirm = categoryInputController.text.trim().isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isRawType ? 'Add Ingredient Category' : 'Add Formula Category',
                          style: const TextStyle(
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
                    const SizedBox(height: 16),

                    // Input Box
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: categoryInputController,
                        onChanged: (_) => setModalState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Please enter the ingredient category.',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: canConfirm
                            ? () {
                                String text = categoryInputController.text.trim();
                                for (var item in _currentSourceList) {
                                  if (item.categoryName == text) {
                                    showTipInfo('Category already exists.', context);
                                    return;
                                  }
                                }
                                if (widget.isRawType) {
                                  PublicFunctions.addRawType(text);
                                } else {
                                  PublicFunctions.addFormulaType(text);
                                }
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004884),
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openEditCategoryDialog(CategoryTypeList category) {
    if (!widget.isRawType) {
      showDialog(
        context: context,
        builder: (_) => EditFormulaTypeDialog(categoryTypeInfo: category),
      ).then((_) {
        _fetchTypeList();
      });
    } else {
      TextEditingController editController = TextEditingController(text: category.categoryName);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Ingredient Category'),
            content: TextField(
              controller: editController,
              decoration: const InputDecoration(
                hintText: 'Please enter category name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  String newName = editController.text.trim();
                  if (newName.isNotEmpty) {
                    PublicFunctions.editRawType(newName, category.categoryId);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ).then((_) {
        _fetchTypeList();
      });
    }
  }

  void _deleteCategory(CategoryTypeList category) {
    if (widget.isRawType) {
      for (var raw in rawDataList) {
        if (raw.categoryId == category.categoryId) {
          showTipInfo('Category is in use and cannot be deleted.', context);
          return;
        }
      }
      PublicFunctions.deleteRawType(category.categoryName);
    } else {
      for (var fma in formulaDataList) {
        if (fma.header?.categoryId == category.categoryId) {
          showTipInfo('Category is in use and cannot be deleted.', context);
          return;
        }
      }
      PublicFunctions.deleteFmaType(category.categoryName);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<CategoryTypeList> displayList = _filteredCategoryList;
    if (_currentSourceList.isEmpty && _searchController.text.isEmpty) {
      displayList = [
        CategoryTypeList(categoryId: 1, categoryName: 'Particulate matter'),
        CategoryTypeList(categoryId: 2, categoryName: 'liquid'),
        CategoryTypeList(categoryId: 3, categoryName: 'solid'),
      ];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Category Management',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined, color: Colors.red, size: 22),
            onPressed: _showDeleteUnusedDialog,
            tooltip: 'Clear Unused Categories',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _performSearch,
                  decoration: const InputDecoration(
                    hintText: 'Please enter',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Category List
            Expanded(
              child: displayList.isEmpty
                  ? Center(
                      child: Text(
                        'No category found',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
                      itemBuilder: (context, index) {
                        CategoryTypeList item = displayList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.categoryName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Edit Pencil Icon Button
                              InkWell(
                                onTap: () => _openEditCategoryDialog(item),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Red Delete Trash Icon Button
                              InkWell(
                                onTap: () => _deleteCategory(item),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Add Button (Dark Blue #004884)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _openAddCategoryBottomSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004884),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
