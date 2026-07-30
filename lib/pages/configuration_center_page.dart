//配置Config的页面 按年收费

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/routes_data.dart';
import 'package:t_max/dialog/license_info.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/show_license_res.dart';
import 'package:t_max/functions/adaptive.dart';

class ConfigurationPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const ConfigurationPage(
      {super.key, required this.onNavigate, required this.lastRouteName});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage>
    with SingleTickerProviderStateMixin {
  // 模拟第二部分列表数据

  late List<RouteData> allConfigMenus = [];
  late List<RouteData> allAppsMenus = [];
  TextEditingController activationFileCtl = TextEditingController();
  List<String> licList = [];

  dynamic eventbus2;

  final TextEditingController pidCtl = TextEditingController();
  TextEditingController licCtl = TextEditingController();

  String pId = '';
  String dueDate = '';
  bool isPass = false;
  bool licenseKey = false;
  String moduleName = '';
  LicenseInfo newLicInfo = LicenseInfo(false, '', '', '');
  final double spacing = 30;
  final double runSpacing = 20;
  final double minColumnWidth = 320;
  final double minColumnHeight = 180;

  //做一个map 存放功能和激活的日期，描述

  ValueNotifier<Map<String, ShowAppActiveInfo>> mapActiveMenusRes =
      ValueNotifier({});

  Map<int, bool> isHoveredListConfig = {};
  Map<int, bool> isHoveredListApps = {};
  late TabController _tabController;

  @override
  void didChangeDependencies() {
    allConfigMenus = getAllConfigMenus();
    allAppsMenus = getAllAppsMenus();
    for (var element in allConfigMenus) {
      isHoveredListConfig[element.id] = false;
    }
    for (var element in allAppsMenus) {
      isHoveredListApps[element.id] = false;
    }

    super.didChangeDependencies();
  }

  void goToInitPage() {
    if (mySysUser.roleId == superAdminRoleId ||
        mySysUser.roleId == adminRoleId) {
      return;
    }
    if (mySysUser.pageIdList == null) {
      return;
    }
    int initPage = mySysUser.initialPageId!;
    if (!mySysUser.pageIdList!.contains(initPage)) {
      return;
    }
    bool isSelPage = getIsAddedConfig(initPage) ||
        selectedAppsPaidMenuIds.contains(initPage);
    if (!isSelPage) {
      return;
    }

    //从config中找到initPage
    RouteData? initRoute =
        allConfigMenus.firstWhere((element) => element.id == initPage,
            orElse: () => RouteData(
                  title: '',
                  subtitle: '',
                  id: -1,
                  iconPath: '',
                  routeName: '',
                ));
    if (initRoute.id != -1) {
      bool isPermission = getUserPermission(initRoute.id);
      bool isFree = isFreeConfig(initRoute.id);
      bool isConfigCertified = myTConLicInfo.isValid;
      if (isPermission && (isFree || isConfigCertified)) {
        widget.onNavigate(initRoute.routeName!);
        return;
      }
    }
    //如果没有找到，就找app
    RouteData? initAppRoute =
        allAppsMenus.firstWhere((element) => element.id == initPage,
            orElse: () => RouteData(
                  title: '',
                  subtitle: '',
                  id: -1,
                  iconPath: '',
                  routeName: '',
                ));
    if (initAppRoute.id != -1) {
      bool isPermission = getUserPermission(initAppRoute.id);
      bool isFree = isFreeApp(initAppRoute.id);
      bool isAppCertified = getIsAppCertified(initAppRoute.id);

      if (isPermission && (isFree || isAppCertified)) {
        formAppSetting = true;
        String route = "/settingsApp${initAppRoute.routeName!}";
        widget.onNavigate(route);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: 1); //管理员初始化为initialIndex: 0 操作员initialIndex: 1

    eventbus2 = eventBus.on<EventRespUpdateLic>().listen((event) {
      if (mounted) {
        setState(() {
          var jsonStr = event.obj;
          if (jsonStr.isNotEmpty) {}
        });
        updateResCtl();
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (firstLogin) {
        firstLogin = false;
        goToInitPage();
      }
    });
  }

  @override
  void dispose() {
    eventbus2.cancel();
    _tabController.dispose();
    activationFileCtl.dispose();
    pidCtl.dispose();
    licCtl.dispose();

    super.dispose();
  }

  void updateResCtl() {
    nextLicCheck();
  }

  void nextLicCheck() {
    if (licList.length >= 2) {
      licList.removeAt(0);
      PublicFunctions.checkLicenseKey(licList[0]);
    } else {
      licList.clear();
    }
  }

  bool getIsAddedConfig(int id) {
    for (var element in getCurrentConfigMenus()) {
      if (element.id == id) {
        return true;
      }
    }
    return false;
  }

  Widget buildAppInfo(
    BuildContext context,
    int id,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    RouteData tempMenu = allAppsMenus.firstWhere((element) => element.id == id);

    if (selectedAppsPaidMenuIds.isEmpty) return SizedBox();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        setState(() {
          isHoveredListApps[id] = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHoveredListApps[id] = false;
        });
      },
      child: GestureDetector(
          onTap: () {
            // 点击卡片跳转页面
            formAppSetting = true;
            String route = "/settingsApp${tempMenu.routeName!}";
            if (Adaptive.isMobile(context)) {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => buildPageContent(widget.onNavigate, route, widget.lastRouteName),
                ),
              );
            } else {
              widget.onNavigate(route);
            }
          },
          child: AnimatedContainer(
              padding: EdgeInsets.all(20),
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isHoveredListApps[id]!
                    ? colorScheme.primary
                    : colorScheme.surface,
                border: Border.all(
                    width: 1, color: colorScheme.surfaceContainerLow),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 36,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        getSvgIcon(
                            tempMenu.iconPath,
                            iconAppSize,
                            iconAppSize,
                            isHoveredListApps[id]!
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.primary),
                        SizedBox(
                          width: smallPadding,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tempMenu.title,
                      style: textTheme.labelMedium!.apply(
                          color: isHoveredListApps[id]!
                              ? Theme.of(context).colorScheme.onPrimary
                              : colorScheme.onSurface),
                      textAlign: TextAlign.left,

                      overflow: TextOverflow.ellipsis, // 超出部分用省略号表示
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: SelectableText(
                        tempMenu.subtitle,
                        textAlign: TextAlign.left,
                        style: textTheme.bodySmall!.apply(
                            color: isHoveredListApps[id]!
                                ? Theme.of(context).colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: smallPadding,
                  ),
                ],
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    allConfigMenus = getAllConfigMenus();
    final bool isMobile = Adaptive.isMobile(context);

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Application", // Ideally localizedStrings?.menuApplication ?? "Application"
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: allAppsMenus.where((menu) {
            bool isAdded = selectedAppsPaidMenuIds.contains(menu.id);
            bool isConfigCertified = getIsAppCertified(menu.id);
            bool isFree = isFreeApp(menu.id);
            bool isPermission = getUserPermission(menu.id);

            return isAdded && isPermission && (isConfigCertified || isFree);
          }).map((menu) {
            return GestureDetector(
              onTap: () {
                formAppSetting = true;
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => buildPageContent(widget.onNavigate, menu.routeName, widget.lastRouteName),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    getSvgIcon(
                        menu.iconPath,
                        32,
                        32,
                        colorScheme.primary),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menu.title,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            menu.subtitle,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        color: colorScheme.surface,
        padding: EdgeInsets.only(
            left: regularPadding,
            right: regularPadding,
            bottom: regularPadding),
        child: Column(children: [
          Divider(
            height: 1,
            color: colorScheme.surfaceDim,
          ),
          SizedBox(
            height: largePadding,
          ),
          Expanded(
            child: Center(
                child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(
                left: regularPadding,
                right: regularPadding,
                bottom: regularPadding,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 计算每个元素的宽度，减去元素间的间距后平分
                  final availableWidth = constraints.maxWidth;
                  final double itemWidth = calculateColumnCount(
                      availableWidth, minColumnWidth, spacing);
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: spacing, // 元素间的水平间距
                      runSpacing: runSpacing, // 元素间的垂直间距
                      children: allAppsMenus.where((menu) {
                        bool isAdded =
                            selectedAppsPaidMenuIds.contains(menu.id);
                        bool isConfigCertified = getIsAppCertified(menu.id);
                        bool isFree = isFreeApp(menu.id);
                        bool isPermission = getUserPermission(menu.id);

                        return isAdded &&
                            isPermission &&
                            (isConfigCertified || isFree);
                      }).map((menu) {
                        return SizedBox(
                          width: itemWidth,
                          height: minColumnHeight, // 固定元素高度
                          child: buildAppInfo(context, menu.id),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            )),
          ),
        ]),
      ),
    );
  }

  // 定义一个函数来计算列数
  double calculateColumnCount(
      double availableWidth, double minItemWidth, double spacing) {
    int count = 0;

    for (int columns = 3; columns <= 20; columns++) {
      final calculatedWidth =
          (availableWidth - (columns - 1) * spacing) / columns;
      if (calculatedWidth < minItemWidth) {
        count = columns - 1;
        break;
      }
    }

    // 计算每个元素的宽度
    final itemWidth = (availableWidth - (count - 1) * spacing) / count;
    return itemWidth;
  }

  void showLicenseResDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        // 将 ValueNotifier 传递给对话框
        return ShowLicenseResDialog(
          mapActiveMenusRes: mapActiveMenusRes,
        );
      },
    ).then((value) {
      setState(() {});
    });
  }

  showInputBox(TextEditingController controller, String hintText) {
    return Container(
      height: inputHeight,
      padding: const EdgeInsets.only(left: regularPadding, right: largePadding),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerLow), // 设置边框颜色
        borderRadius: BorderRadius.circular(0), // 设置圆角
      ),
      child: TextField(
        enabled: false,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest, // 设置提示文本颜色
          ),
          border: InputBorder.none, // 移除默认边框
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface, // 设置输入文本颜色
          fontSize: 14,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget buildBottomTitle(ColorScheme colorScheme, TextTheme textTheme,
      String title, String subtitle) {
    return Container(
        height: leftBarIconHeight,
        color: colorScheme.surface,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge!
                            .apply(color: colorScheme.onSurface),
                      ),
                    ]),
              ),
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 使用 SingleChildScrollView 实现滚动功能
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical, // 垂直滚动
                          child: Text(
                            subtitle,
                            style: textTheme.bodySmall!.apply(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ]),
              )
            ]));
  }

  void showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LicenseInfoDialog();
      },
    ).then((value) => setState(() {}));
  }

  Future validLicense() async {
    String dataStr = activationFileCtl.text;
    if (dataStr.isNotEmpty) {
      try {
        File file = File(dataStr);
        String content = await file.readAsString();
        licList = content.split('\r\n');
        List<String> tmpList = [];
        for (var i = 0; i < licList.length; i++) {
          if (licList[i].length == 74 ||
              licList[i].length == 78 ||
              licList[i].contains('++==')) {
            tmpList.add(licList[i]);
          }
        }
        licList = tmpList;
      } catch (e) {
        // print('读取文件时出错: $e');
        return;
      }
    }
  }
}
