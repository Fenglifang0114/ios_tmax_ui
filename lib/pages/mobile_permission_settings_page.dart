import 'package:flutter/material.dart';
import 'package:t_max/data/routes_data.dart';
import 'package:t_max/data/language.dart';

class MobilePermissionSettingsPage extends StatefulWidget {
  final Set<int> selectedPermissions;
  final int? initialPageId;
  final Function(Set<int>, int?) onSaved;

  const MobilePermissionSettingsPage({
    super.key,
    required this.selectedPermissions,
    this.initialPageId,
    required this.onSaved,
  });

  @override
  State<MobilePermissionSettingsPage> createState() => _MobilePermissionSettingsPageState();
}

class _MobilePermissionSettingsPageState extends State<MobilePermissionSettingsPage> {
  late Set<int> _selectedPermissions;
  int? _initialPageId;
  
  late List<RouteData> configMenus;
  late List<RouteData> appMenus;

  @override
  void initState() {
    super.initState();
    _selectedPermissions = Set.from(widget.selectedPermissions);
    _initialPageId = widget.initialPageId;

    configMenus = getAllConfigMenus();
    appMenus = getAllAppsMenus();
  }

  void _onConfirm() {
    widget.onSaved(_selectedPermissions, _initialPageId);
    Navigator.pop(context);
  }

  Widget _buildSection(String title, List<RouteData> menus) {
    bool isAllSelected = menus.every((m) => _selectedPermissions.contains(m.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (title.contains("Configuration"))
                const Text("Default initial application", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        // Select All
        ListTile(
          leading: Checkbox(
            value: isAllSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedPermissions.addAll(menus.map((m) => m.id));
                } else {
                  _selectedPermissions.removeAll(menus.map((m) => m.id));
                  if (menus.any((m) => m.id == _initialPageId)) {
                    _initialPageId = null;
                  }
                }
              });
            },
          ),
          title: const Text("Select All", style: TextStyle(color: Colors.blue)),
        ),
        // Items
        ...menus.map((menu) {
          bool isSelected = _selectedPermissions.contains(menu.id);
          return ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedPermissions.add(menu.id);
                  } else {
                    _selectedPermissions.remove(menu.id);
                    if (_initialPageId == menu.id) {
                      _initialPageId = null;
                    }
                  }
                });
              },
            ),
            title: Text(menu.title),
            trailing: Radio<int>(
              value: menu.id,
              groupValue: _initialPageId,
              onChanged: isSelected ? (val) {
                setState(() => _initialPageId = val);
              } : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Permission settings",
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSection("Configuration permissions", configMenus),
                  const Divider(thickness: 4, color: Color(0xFFF5F5F5)),
                  _buildSection("Application permissions", appMenus),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1ABC9C),
                    elevation: 0,
                  ),
                  onPressed: _onConfirm,
                  child: Text(
                    localizedStrings?.gBtnConfirm ?? "Confirm",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
