import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/routes_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/functions/adaptive.dart';

import 'package:t_max/data/writelog.dart';

class MobileSettingPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String? lastRouteName;

  const MobileSettingPage({super.key, required this.onNavigate, this.lastRouteName});

  @override
  State<MobileSettingPage> createState() => _MobileSettingPageState();
}

class _MobileSettingPageState extends State<MobileSettingPage> {
  List<RouteData> settingMenus = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMenus();
  }

  void _loadMenus() {
    final hierarchicalMenus = getHierarchicalConfigMenus();
    final settingGroup = hierarchicalMenus.firstWhere(
      (group) => group.title == (localizedStrings?.gBtnSetting ?? "gBtnSetting"),
      orElse: () => RouteDataGroup(title: '', children: []),
    );
    
    setState(() {
      settingMenus = settingGroup.children.whereType<RouteData>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        itemCount: settingMenus.length,
        separatorBuilder: (context, index) => const SizedBox(height: smallPadding),
        itemBuilder: (context, index) {
          final menu = settingMenus[index];
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                writelog("[MOBILE_SETTING] Tapped menu item: ${menu.title}, route: ${menu.routeName}");
                if (menu.routeName != null) {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => buildPageContent(widget.onNavigate, menu.routeName, widget.lastRouteName),
                    ),
                  );
                }
              },
              child: Container(
                height: scaleItemHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: scaleItemHeight,
                      height: scaleItemHeight,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Color(0xFF0D558E),
                        ),
                        width: 48,
                        height: 48,
                        child: Container(
                          alignment: Alignment.center,
                          child: getSvgIcon(menu.iconPath, 24, 24, Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            menu.title,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            menu.subtitle,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
