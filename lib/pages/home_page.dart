// //主页

//首页   测试首页
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_tooltip/smart_tooltip_text.dart';
import 'package:t_max/data/company_info.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/manager_scale_channel.dart';
import 'package:t_max/data/routes_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:t_max/data/screen_mgr.dart';
import 'package:t_max/dialog/company_info_dialog.dart';
import 'package:t_max/dialog/exit_app_dialog.dart';
import 'package:t_max/dialog/language_setting.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/widget/version.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with TrayListener, WindowListener {
  final GlobalKey<NavigatorState> _contentNavigatorKey = GlobalKey();
  String _selectedNavRoute = '/';
  String lastRouteName = defualtSelectPage; //除了设置外的最后一个路由
  bool _showNavigation = true; // 控制导航栏显示

  bool isLeftBarCollapsed = false;
  bool isExpanded = true; // 侧边栏是否展开
  bool isResize = false;
  DateTime dataTimeNow = DateTime.now();

  dynamic _eventbus1; // 监听事件
  dynamic _eventbus3; // 监听事件
  dynamic _eventbus4; // 监听事件
  dynamic _eventbus5; // 监听事件
  dynamic _eventbus6; // 监听事件
  dynamic _eventbus7; // 监听事件
  dynamic _eventbus8; // 监听事件
  dynamic _eventbus9; // 监听事件

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _navigateContent(defualtSelectPage);
      });
    });
  }

  @override
  void onWindowResize() {
    isResize = true;
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      showDialog(
        context: context,
        barrierDismissible: false, // 允许点击空白处关闭对话框
        builder: (context) {
          return CustomAlertDialog(
            titleText: localizedStrings.gTipExitApp,
            onNoPressed: () {
              Navigator.of(context).pop();
            },
            onYesPressed: () async {
              Navigator.of(context).pop();
              dispose();
              await trayManager.destroy(); //退出系统托盘
              await windowManager.destroy();
              exit(0);
            },
          );
        },
      );
    }
  }

  @override
  void onWindowMaximize() {
    isResize = true;
  }

  @override
  void onWindowUnmaximize() {
    isResize = true;
  }

  @override
  void onWindowMinimize() {
    isResize = true;
  }

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);

    windowManager.setMinimumSize(Size(1320, 720));
    super.initState();

    _eventbus1 = eventBus.on<EventDialogData>().listen((event) {
      if (mounted) {
        setState(() {
          myDialogData = event.obj;
        });
      }
    });
    setState(() {
      dataTimeNow = DateTime.now();
    });

    // _eventbus3 = eventBus.on<EventRespCheckComPort>().listen((event) {
    //   if (mounted) {
    //     if (myScreenMgr.isMainScreen) {
    //       setState(() {
    //         myComScaleSn = event.obj;
    //         if (myComScaleSn.modelName != '') {
    //           myComScaleInfo.isOnline = true;
    //           myComScaleInfo.isOnline = true;
    //           PublicFunctions.getOneEepromInfo("wifi_or_bt", 1);
    //         } else {
    //           myComScaleInfo.isOnline = false;
    //           myComScaleSn.modelName = '';
    //           myComScaleSn.scaleSn = '';
    //           myComScaleInfo.isOnline = false;
    //           myScreenMgr.wifiOrBt = 'off';
    //         }
    //       });
    //     }
    //   }
    // });

    _eventbus4 = eventBus.on<EventGetFactoryInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myFactoryInfoFromScale = event.obj;
        });
      }
    });

    _eventbus5 = eventBus.on<EventGetOneEepromDateResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.contains('ok')) {
            if (myRespDataFromScale.msgBody.contains('bt')) {
              myScreenMgr.wifiOrBt = 'bt';
            } else if (myRespDataFromScale.msgBody.contains('wifi')) {
              myScreenMgr.wifiOrBt = 'wifi';
            } else if (myRespDataFromScale.msgBody.contains('off')) {
              myScreenMgr.wifiOrBt = 'off';
            }
          }
        });
      }
    });
    _eventbus6 = eventBus.on<EventLicenseData>().listen((event) {
      if (mounted) {
        setState(() {
          var eventInfo = event.obj;
          if (eventInfo.isNotEmpty) {
            var jsonData = json.decode(eventInfo);

            try {
              myLicenseData = LicenseData.fromJson(jsonData);
            } catch (e) {
              myLicenseData = LicenseData([]);
            }
            if (myLicenseData.licList.isNotEmpty) {
              LicenseSetting().setLicInfo();
            }
          }
        });
      }
    });
    _eventbus7 = eventBus.on<EventCloseScalePassthResp>().listen((event) {
      if (mounted) {
        PublicFunctions.stopWeight(myDefScaleInfo.defScaleId!);
      }
    });
    _eventbus8 = eventBus.on<EventSerialPortResponse>().listen((event) {
      if (mounted) {
        if (myScreenMgr.isMainScreen) {
          setState(() {
            myRespDataFromScale = event.obj;
            if (myComScaleInfo.isOnline) {
              myComScaleInfo.isOnline = false;
              myComScaleSn.modelName = '';
              myComScaleSn.scaleSn = '';
              myComScaleInfo.isOnline = false;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('The serial port disconnected.',
                      style: const TextStyle(fontSize: 20)), ////此处需要秤回复
                  duration: const Duration(seconds: 5),
                  backgroundColor: Theme.of(context).colorScheme.error));
            }
          });
        }
      }
    });

    _eventbus9 = eventBus.on<EventServiceOff>().listen((event) {
      setState(() {
        showServiceErrorDialog(context, localizedStrings.gTipServiceOff,
            localizedStrings.gTitleConfirm);
      });
    });

    // 所有初始化完成后设置默认页面
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();

    trayManager.removeListener(this);
    windowManager.removeListener(this);

    super.dispose();
  }

  void _navigateContent(String routeName) {
    setState(() {
      _selectedNavRoute = routeName;
      _showNavigation = !routeName.startsWith('/settings'); // 控制导航栏显示
    });

    if (routeName.contains('/settings')) {
      // _contentNavigatorKey.currentState?.pushNamed(routeName);
      _contentNavigatorKey.currentState?.pushReplacementNamed(routeName);
    } else {
      lastRouteName = routeName;
      _contentNavigatorKey.currentState?.pushReplacementNamed(routeName);
    }
  }

  Widget showNavigationBar(bool isExpanded, List<RouteData> demos) {
    return ListView.builder(
      primary: false,
      itemBuilder: (context, index) => MenuItem(
        demo: demos[index],
        isExpanded: isExpanded,
        isSelected: demos[index].routeName! == _selectedNavRoute,
        onTap: () => _navigateContent(demos[index].routeName!),
      ),
      itemCount: demos.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Row(
        children: [
          // 动态显示的左侧导航栏
          if (_showNavigation)
            Container(
              width: isExpanded ? leftBarWidth : leftBarLittleWidth,
              color: Theme.of(context).colorScheme.primary, // 可替换为实际内容
              child: Column(children: [
                SizedBox(
                  height: leftBarIconHeight,
                  width: isExpanded ? leftBarWidth : leftBarLittleWidth,
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.only(left: largePadding),
                        iconSize: iconAppSize,
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        icon: Image.asset(
                          appIconPath,
                          width: iconAppSize,
                          height: iconAppSize,
                        ),
                      ),
                      isExpanded
                          ? Expanded(
                              child: Container(
                                  padding:
                                      EdgeInsets.only(left: regularPadding),
                                  child: Text(
                                    myAppName.appName!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .apply(
                                            // 根据选中状态改变颜色
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                  )))
                          : SizedBox()
                    ],
                  ),
                ),
                Expanded(
                  child: showNavigationBar(isExpanded, getCurrentConfigMenus()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 120,
                        height: 40,
                        child: Image.asset(companyImage)),
                  ],
                ),
                SizedBox(
                  height: largePadding,
                )
              ]),
            ),

          // 右侧主区域
          Expanded(
            child: Column(
              children: [
                // 顶部设置栏（始终显示）
                Container(
                  height: topLinePadding,
                  color: colorScheme.surfaceDim,
                ),
                SizedBox(
                  height: topBarHeight,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _showNavigation
                            ? Container(
                                padding: EdgeInsets.only(left: largePadding),
                                child: Text(
                                  generateTitle(getPageId(_selectedNavRoute)),
                                  style: textTheme.bodySmall!.apply(
                                      // 根据选中状态改变颜色
                                      color: colorScheme.onSurface),
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(left: largePadding),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      appIconPath,
                                      width: iconAppSize,
                                      height: iconAppSize,
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(
                                            left: regularPadding),
                                        child: Text(
                                          myAppName.appName!,
                                          style: textTheme.headlineSmall!.apply(
                                              // 根据选中状态改变颜色
                                              color: colorScheme.primary),
                                        ))
                                  ],
                                ),
                              ),
                        Row(
                          children: [
                            PopupMenuButton<String>(
                              tooltip: localizedStrings.menuApplications,
                              icon: getSvgIcon(appsSvgIcon(), topIconSize,
                                  topIconSize, colorScheme.primary),
                              offset: Offset(-15, 40),
                              color: colorScheme.onInverseSurface
                                  .withValues(alpha: 0.7),
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem(
                                  value: '1',
                                  child: Text(
                                    localizedStrings.menuConfiguration,
                                    style: textTheme.bodySmall!.apply(
                                      // 根据选中状态改变颜色
                                      color: colorScheme.surface,
                                    ),
                                  ),
                                  onTap: () {
                                    _navigateContent('/settingsConfig');
                                  },
                                ),
                                PopupMenuDivider(height: 1.0),
                                PopupMenuItem(
                                  value: '2',
                                  child: Text(
                                    localizedStrings.menuApplications,
                                    style: textTheme.bodySmall!.apply(
                                      // 根据选中状态改变颜色
                                      color: colorScheme.surface,
                                    ),
                                  ),
                                  onTap: () {
                                    _navigateContent('/settingsApps');
                                  },
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              tooltip: localizedStrings.menuLanguageSetting,
                              icon: getSvgIcon(settingSvgIcon(), topIconSize,
                                  topIconSize, colorScheme.primary),
                              offset: Offset(-15, 40),
                              color: colorScheme.onInverseSurface
                                  .withValues(alpha: 0.7),
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem(
                                  value: '1',
                                  child: Text(
                                    localizedStrings.menuLanguageSetting,
                                    style: textTheme.bodySmall!.apply(
                                      // 根据选中状态改变颜色
                                      color: colorScheme.surface,
                                    ),
                                  ),
                                  onTap: () {
                                    Future.delayed(
                                      Duration.zero,
                                      () {
                                        showSetLanguageDialog();
                                      },
                                    );
                                  },
                                ),
                                PopupMenuDivider(height: 1.0),
                              ],
                            ),
                            Tooltip(
                              message: localizedStrings.menuSystemInformation,
                              child: IconButton(
                                icon: getSvgIcon(infoSvgIcon(), topIconSize,
                                    topIconSize, colorScheme.primary),
                                onPressed: () {
                                  // showLicenseDialog(context);
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false, // 允许点击空白处关闭对话框
                                    builder: (context) {
                                      return const CompanyInfoDialog();
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: regularPadding,
                            )
                          ],
                        ),
                      ]),
                ),

                Container(
                  height: regularPadding,
                  color: colorScheme.surfaceDim,
                ),
                // 内容区域导航器
                Expanded(
                    child: Row(children: [
                  Container(
                    width: regularPadding,
                    color: colorScheme.surfaceDim,
                  ),
                  Expanded(
                    child: Navigator(
                      key: _contentNavigatorKey,
                      initialRoute: _selectedNavRoute,
                      onGenerateRoute: (settings) {
                        final pageContent = buildPageContent(
                            _navigateContent, settings.name, lastRouteName);

                        return MaterialPageRoute(
                          builder: (context) => pageContent,
                          settings: settings,
                        );
                      },
                    ),
                  ),
                  Container(
                    width: regularPadding,
                    color: colorScheme.surfaceDim,
                  ),
                ])),
                Container(
                  height: regularPadding,
                  color: colorScheme.surfaceDim,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int getPageId(String routeName) {
    int pageId = 9999;
    for (var item in getAllConfigMenus()) {
      if (item.routeName == routeName) {
        pageId = item.id;
        break;
      }
    }
    if (pageId == 9999) {
      for (var item in getAllAppsMenus()) {
        if (item.routeName == routeName) {
          pageId = item.id;
          break;
        }
      }
    }
    return pageId;
  }

  void showSetLanguageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LanguageSettingPage();
      },
    ).then((_) {
      if (mounted) {
        // 更新 localizedStrings

        setState(() {
          // 刷新整个页面
          _navigateContent(_selectedNavRoute);
        });
      }
    });
  }
}

typedef CategoryHeaderTapCallback = Function(bool shouldOpenList);
const double barLeftWidth = 24;
const double barBetweenHeight = 13;

// 修改 MenuItem 以支持选中状态和点击回调
class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.demo,
    this.isExpanded = true,
    required this.isSelected, // 新增选中状态
    required this.onTap, // 新增点击回调
  });

  final RouteData demo;
  final bool isExpanded;
  final bool isSelected; // 新增选中状态
  final VoidCallback onTap; // 新增点击回调

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildMenuInfo() {
      return SizedBox(
          height: 52, // 固定高度
          child: Material(
            color: isSelected
                ? Color(0xFF06406F)
                : Theme.of(context).colorScheme.primary,
            child: MergeSemantics(
              child: InkWell(
                onTap: onTap, // 绑定点击回调
                child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: isExpanded ? 20 : barLeftWidth,
                      end: 5,
                    ),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: getSvgIcon(demo.iconPath, 22, 22,
                                Theme.of(context).colorScheme.onPrimary),
                          ),
                          if (isExpanded) ...[
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: FittedBox(
                                fit: BoxFit.scaleDown, // 仅在需要时缩小内容
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  demo.title,
                                  maxLines: 1,
                                  style: textTheme.bodySmall!.apply(
                                      // 根据选中状态改变颜色
                                      color: colorScheme.onPrimary),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
              ),
            ),
          ));
    }

    if (isExpanded) {
      return buildMenuInfo();
    }
    return SmartTooltip(
        borderColor: colorScheme.onInverseSurface,
        message: isExpanded ? '' : demo.title,
        backgroundColor: colorScheme.onInverseSurface.withValues(alpha: 0.7),
        textStyle: TextStyle(
          color: colorScheme.onPrimary,
        ),
        position: TooltipPosition.right,
        child: buildMenuInfo());
  }
}
