import 'package:flutter/material.dart';
import 'package:t_max/data/custom_model_info.dart';
import 'package:t_max/data/language.dart';

/// 移动端机种与协议选择页面（对应图2与图3）
class MobileSelectModelPage extends StatefulWidget {
  final List<ModelNameInfo> modelList;
  final ModelNameInfo? initialModel;
  final String? initialProtocol;
  final bool onlyScpX;

  const MobileSelectModelPage({
    super.key,
    required this.modelList,
    this.initialModel,
    this.initialProtocol,
    this.onlyScpX = false,
  });

  @override
  State<MobileSelectModelPage> createState() => _MobileSelectModelPageState();
}

class _MobileSelectModelPageState extends State<MobileSelectModelPage> {
  String _searchQuery = '';
  ModelNameInfo? _selectedModel;
  SubModel? _selectedSubModel;

  late Map<String, List<ModelNameInfo>> _groupedModels;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel;
    if (widget.initialModel != null && widget.initialProtocol != null) {
      _selectedSubModel = SubModel(
        modelName: widget.initialModel?.customScaleName,
        protocolName: widget.initialProtocol,
      );
    }
    _groupModels();
  }

  /// 转换 Category 英文名称为本地化多语言显示
  String _getCategoryDisplayName(String rawCategory) {
    if (rawCategory == 'Weighing Scale') {
      return (localizedStrings?.menuWeighing != null && localizedStrings!.menuWeighing.isNotEmpty)
          ? localizedStrings!.menuWeighing
          : "计重";
    } else if (rawCategory == 'Counting Scale') {
      return "计数";
    } else if (rawCategory == 'Pricing Scale') {
      return "计价";
    } else if (rawCategory == 'Instrument') {
      return "仪表";
    }
    return rawCategory;
  }

  void _groupModels() {
    _groupedModels = {};
    final filteredList = widget.modelList.where((model) {
      if (widget.onlyScpX) {
        final subModels = model.subModel ?? [];
        bool hasScpX = subModels.any((sm) => sm.protocolName == 'SCP-X');
        if (!hasScpX) return false;
      }

      final customName = model.customScaleName ?? '';
      final innerName = model.innerScaleName ?? '';
      final category = model.category ?? '';
      final query = _searchQuery.toLowerCase().trim();

      if (query.isEmpty) return true;
      return customName.toLowerCase().contains(query) ||
          innerName.toLowerCase().contains(query) ||
          category.toLowerCase().contains(query);
    }).toList();


    for (var model in filteredList) {
      final category = model.category ?? 'Other';
      if (!_groupedModels.containsKey(category)) {
        _groupedModels[category] = [];
      }
      _groupedModels[category]!.add(model);
    }
  }

  /// 点击机种按钮，弹出协议选择及格式预览弹窗 (图3)
  void _onModelTapped(ModelNameInfo model) async {
    final subModels = model.subModel ?? [];
    if (subModels.isEmpty) {
      setState(() {
        _selectedModel = model;
        _selectedSubModel = SubModel(modelName: model.customScaleName, protocolName: 'SCP-01');
      });
      return;
    }

    // 默认选择第一个 SubModel 或当前已选的 SubModel
    SubModel initialSub = subModels.first;
    if (_selectedModel?.customScaleName == model.customScaleName && _selectedSubModel != null) {
      initialSub = subModels.firstWhere(
        (sm) => sm.protocolName == _selectedSubModel?.protocolName,
        orElse: () => subModels.first,
      );
    }

    final chosenSubModel = await showDialog<SubModel>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _MobileProtocolDialog(
          modelName: model.customScaleName ?? model.innerScaleName ?? '',
          subModels: subModels,
          initialSubModel: initialSub,
        );
      },
    );

    if (chosenSubModel != null) {
      setState(() {
        _selectedModel = model;
        _selectedSubModel = chosenSubModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _groupModels();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizedStrings?.gModelName ?? "Model Name",
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Search Name",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),

          // 机种分类列表
          Expanded(
            child: _groupedModels.isEmpty
                ? const Center(
                    child: Text(
                      "No models found",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _groupedModels.length,
                    itemBuilder: (context, index) {
                      final categoryKey = _groupedModels.keys.elementAt(index);
                      final models = _groupedModels[categoryKey]!;
                      final categoryTitle = _getCategoryDisplayName(categoryKey);

                      // 如果当前选中的 Model 属于该分类，获取其已选协议显示在 Header 右侧
                      String selectedProtocolDisplay = '';
                      if (_selectedModel != null && models.contains(_selectedModel)) {
                        selectedProtocolDisplay = _selectedSubModel?.protocolName ?? '';
                      }


                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  categoryTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (selectedProtocolDisplay.isNotEmpty)
                                  Text(
                                    selectedProtocolDisplay,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D558E),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // 机种 3 列网格按钮
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: models.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (context, mIndex) {
                              final model = models[mIndex];
                              final isSelected = _selectedModel?.customScaleName == model.customScaleName;

                              return InkWell(
                                onTap: () => _onModelTapped(model),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF001F3F) : Colors.white,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF001F3F) : const Color(0xFFDDDDDD),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    model.customScaleName ?? model.innerScaleName ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),

          // 底部 Confirm 按钮
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedModel != null
                      ? () {
                          Navigator.pop(context, {
                            'model': _selectedModel,
                            'subModel': _selectedSubModel,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1CB079),
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    localizedStrings?.gBtnConfirm ?? "Confirm",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 协议选择与图片预览弹窗 (图3)
class _MobileProtocolDialog extends StatefulWidget {
  final String modelName;
  final List<SubModel> subModels;
  final SubModel initialSubModel;

  const _MobileProtocolDialog({
    required this.modelName,
    required this.subModels,
    required this.initialSubModel,
  });

  @override
  State<_MobileProtocolDialog> createState() => _MobileProtocolDialogState();
}

class _MobileProtocolDialogState extends State<_MobileProtocolDialog> {
  late SubModel _currentSubModel;

  @override
  void initState() {
    super.initState();
    _currentSubModel = widget.initialSubModel;
  }

  /// 根据 ProtocolName 拼装图片资源路径，如 assets/SCP/SCP-01.jpg
  String _getScpImagePath(String? protocolName) {
    if (protocolName == null || protocolName.isEmpty) {
      return 'assets/SCP/SCP-01.jpg';
    }
    String cleanName = protocolName.replaceAll('ASP-', '').trim();
    if (cleanName.isEmpty) cleanName = 'SCP-01';
    return 'assets/SCP/$cleanName.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getScpImagePath(_currentSubModel.protocolName);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部：标题与关闭按钮
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 8, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizedStrings?.gModelName ?? "Model Name",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 24),
                  onPressed: () => Navigator.pop(context, null),
                ),
              ],
            ),
          ),

          // 协议单选列表 (Radio buttons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: widget.subModels.map((subModel) {
                final displayName = subModel.protocolName ?? '';
                final isSelected = _currentSubModel.protocolName == subModel.protocolName;


                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentSubModel = subModel;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: subModel.protocolName ?? '',
                        groupValue: _currentSubModel.protocolName ?? '',
                        activeColor: const Color(0xFF0D558E),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _currentSubModel = subModel;
                            });
                          }
                        },
                      ),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // 中间协议格式图片预览
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 320),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.8,
                  maxScale: 3.0,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            "Image not found: $imagePath",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 底部 Confirm 按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _currentSubModel);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CB079),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
              child: Text(
                localizedStrings?.gBtnConfirm ?? "Confirm",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
