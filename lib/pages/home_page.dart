// //涓婚〉

//棣栭〉   娴嬭瘯棣栭〉
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:t_max/data/company_info.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/g_data.dart';
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
import 'package:t_max/dialog/sys_user_pwd.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/widget/home_widget.dart';
import 'package:t_max/widget/page_info.dart';
import 'package:t_max/widget/version.dart';
import 'package:t_max/common/window_lifecycle_mixin.dart';
import 'package:t_max/functions/adaptive.dart';
import 'package:t_max/common/web_socket_channel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with WindowLifecycleMixin {
  String _selectedNavRoute = '/';
  String lastRouteName = defualtSelectPage; //闄や簡璁剧疆澶栫殑鏈€鍚庝竴涓矾鐢?

  bool isLeftBarCollapsed = false;
  // isResize 宸茬粡鍦?WindowLifecycleMixin 涓畾涔?
  DateTime dataTimeNow = DateTime.now();

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;
  dynamic _eventbus10;
  bool _hideScaffoldElements = false;
  int _currentTabIndex = 0;
  ScrollController scrollController = ScrollController();
  bool isHovering = false; // 鐢ㄤ簬鎺у埗榧犳爣鎮仠鐘舵€?

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
    if (!_isInitialized) {
      _isInitialized = true;
      Future.delayed(const Duration(milliseconds: 10), () {
        if (mounted) {
          setState(() {
            if (mySysUser.roleId == superAdminRoleId ||
                mySysUser.roleId == adminRoleId) {
              _navigateContent('/multiScaleManagement');
            } else {
              _navigateContent(defualtSelectPage);
            }
          });
        }
      });
    }
  }



  @override
  void initState() {
    initWindowLifecycle();
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
    _eventbus2 = eventBus.on<EventMySysUser>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    _eventbus4 = eventBus.on<EventGetFactoryInfo>().listen((event) {
      if (mounted) {
        OnlineInfo info = event.obj;
        setState(() {
          myFactoryInfoFromScale = info.factInfo!;
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
              List<dynamic> jsonList = json.decode(eventInfo);
              if (jsonList.isNotEmpty) {
                myLicenseInfo.pId = jsonList[0]['Id'];
              }
            } catch (e) {
              myLicenseInfo.pId = '';
            }

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
                      style: const TextStyle(fontSize: 20)), ////姝ゅ闇€瑕佺Г鍥炲
                  duration: const Duration(seconds: 5),
                  backgroundColor: Theme.of(context).colorScheme.error));
            }
          });
        }
      }
    });

    _eventbus9 = eventBus.on<EventServiceOff>().listen((event) {
      setState(() {
        showServiceErrorDialog(context, (localizedStrings?.gTipServiceOff ?? "gTipServiceOff"),
            (localizedStrings?.gTitleConfirm ?? "gTitleConfirm"));
      });
    });

    _eventbus10 = eventBus.on<EventUpdateNavMenu>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    eventBus.on<EventUiCmd>().listen((event) {
      if (mounted) {
        if (event.obj == 'hideScaffoldElements') {
          setState(() {
            _hideScaffoldElements = true;
          });
        } else if (event.obj == 'showScaffoldElements') {
          setState(() {
            _hideScaffoldElements = false;
          });
        } else if (event.obj == 'showAddDevice') {
          // You can also handle 'showAddDevice' if needed elsewhere
        }
      }
    });

    // 所有初始化完成后设置默认页面鎵€鏈夊垵濮嬪寲瀹屾垚鍚庤缃粯璁ら〉闈?
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();
    _eventbus10.cancel();

    disposeWindowLifecycle();

    scrollController.dispose();
    super.dispose();
  }

  void _navigateContent(String routeName) {
    setState(() {
      _selectedNavRoute = routeName;
      showLeftNavigationBar = !routeName.startsWith('/settings'); // 鎺у埗瀵艰埅鏍忔樉绀?
    });

    if (routeName.contains('/settings')) {
      if (routeName.contains('/settingsApp')) {
        routeName = routeName.replaceAll('/settingsApp', '');
      }

      contentNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              buildPageContent(_navigateContent, routeName, null),
        ),
        (route) => false, // 杩欎釜鏉′欢姘歌繙杩斿洖 false锛岃〃绀虹Щ闄ゆ墍鏈夌幇鏈夎矾鐢?
      );
    } else {
      lastRouteName = routeName;
      // contentNavigatorKey.currentState?.pushReplacementNamed(routeName);
      contentNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              buildPageContent(_navigateContent, routeName, null),
        ),
        (route) => false, // 杩欎釜鏉′欢姘歌繙杩斿洖 false锛岃〃绀虹Щ闄ゆ墍鏈夌幇鏈夎矾鐢?
      );
    }
  }

  Widget showNavigationBar() {
    // 鑾峰彇灞傜骇鑿滃崟鏁版嵁
    final hierarchicalMenus = getHierarchicalConfigMenus();

    return ListView.builder(
      itemCount: hierarchicalMenus.length,
      itemBuilder: (context, index) {
        final group = hierarchicalMenus[index];
        return _buildMenuGroup(group, index);
      },
    );
  }

  final Map<int, bool> _expandedStates = {};

// 鏋勫缓鑿滃崟缁?
  Widget _buildMenuGroup(RouteDataGroup group, int groupIndex) {
    if (group.children.isEmpty) {
      return Container();
    }

    // 鐗规畩澶勭悊"澶氬彴绉ょ鐞?缁?- 鐩存帴浣滀负鑿滃崟椤硅烦杞?
    if (group.title == (localizedStrings?.menuMultiScaleManagement ?? "menuMultiScaleManagement")) {
      // 鑾峰彇绗竴涓湁鏁堣矾鐢遍」
      final effectiveRoute = group.children.firstWhere(
        (item) => item is RouteData,
        orElse: () => RouteData(
          id: 0,
          title: '',
          subtitle: '',
          routeName: '',
          iconPath: '',
        ),
      ) as RouteData?;

      return effectiveRoute != null
          ? _buildMenuItem(effectiveRoute, showIcon: true)
          : Container();
    }

    if (group.title == (localizedStrings?.menuApplications ?? "menuApplications")) {
      final effectiveRoute = group.children.firstWhere(
        (item) => item is RouteData,
        orElse: () => RouteData(
          id: MenuId.appConfigPage,
          title: '',
          subtitle: '',
          routeName: '',
          iconPath: '',
        ),
      ) as RouteData?;

      return effectiveRoute != null
          ? _buildMenuItem(effectiveRoute, showIcon: true)
          : Container();
    }

    return ExpansionTile(
      title: Text(group.title,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              )),
      shape: Border(),
      leading: getSvgIcon(
          group.iconPath, 22, 22, Theme.of(context).colorScheme.onPrimary),
      trailing: Icon(
        (_expandedStates[groupIndex] ?? false)
            ? Icons.expand_less
            : Icons.expand_more,
        color: Theme.of(context).colorScheme.onPrimary, // 璁剧疆鍥炬爣棰滆壊
        size: 20, // 鍙€夛細璋冩暣鍥炬爣澶у皬
      ),
      onExpansionChanged: (isExpanded) {
        setState(() {
          _expandedStates[groupIndex] = isExpanded;
        });
      },
      children: group.children.map((item) {
        // 鍒ゆ柇瀛愰」绫诲瀷骞舵瀯寤?
        if (item is RouteDataGroup) {
          return _buildMenuGroup(item, groupIndex); // 鏀寔宓屽缁?
        } else if (item is RouteData) {
          return _buildMenuItem(item, isSubMenu: true);
        }
        return Container();
      }).toList(),
    );
  }

// 鏋勫缓鑿滃崟椤癸紙澧炲姞isSubMenu鍙傛暟锛?
  Widget _buildMenuItem(RouteData item,
      {bool showIcon = false, bool isSubMenu = false}) {
    return ShowMenuItem(
      showIcon: showIcon,
      demo: item,
      isExpanded: true,
      isSelected: item.routeName == _selectedNavRoute, // 閫変腑鐘舵€?
      onTap: () {
        _navigateContent(item.routeName!);
      }, // 鐐瑰嚮鍥炶皟
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Adaptive.isMobile(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    localizedStrings = S.of(context);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return CustomAlertDialog(
                titleText: (localizedStrings?.gTipExitApp ?? "gTipExitApp"),
                onNoPressed: () {
                  Navigator.of(context).pop();
                },
                onYesPressed: () async {
                  Navigator.of(context).pop();
                  dispose();
                  if (!Platform.isAndroid) {
                    await trayManager.destroy();
                    await windowManager.destroy();
                  }
                  exit(0);
                },
              );
            },
          );
        }
      },
      child: Scaffold(
      drawer: isMobile ? Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 120,
                color: Colors.white,
                padding: const EdgeInsets.only(top: 40, left: 16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset(logoIconPath, width: 40, height: 40),
                    const SizedBox(width: 12),
                    Text(
                      myAppName.appName!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(Icons.tune, "Configuration", () {
                      Navigator.pop(context);
                      setState(() {
                        _currentTabIndex = 0;
                        _navigateContent('/multiScaleManagement');
                      });
                    }),
                    _buildDrawerItem(Icons.apps, "Application", () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => buildPageContent(_navigateContent, '/setConfig', null),
                        ),
                      );
                    }),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Divider(color: Color(0xFFEEEEEE), height: 1),
                    ),
                    _buildDrawerItem(Icons.people_outline, "User management", () {}),
                    _buildDrawerItem(Icons.receipt_long, "Log Management", () {}),
                    _buildDrawerItem(Icons.balance, "Function Center", () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => buildPageContent(_navigateContent, '/settingsFunction', null),
                        ),
                      );
                    }),
                    _buildDrawerItem(Icons.lock_outline, "Change password", () {}),
                    _buildDrawerItem(Icons.language, "Set Language", () {
                      Navigator.pop(context);
                      showSetLanguageDialog();
                    }),
                    _buildDrawerItem(Icons.info_outline, "System Information", () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return const CompanyInfoDialog();
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ) : null,
      appBar: (isMobile && _hideScaffoldElements) ? null : PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 56 : 40),
        child: isMobile ? AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.grid_view_outlined, color: Colors.black87),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(
            "Connecting",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.black87),
              onPressed: () {},
            ),
            if (_selectedNavRoute == '/multiScaleManagement')
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
                onPressed: () {
                  eventBus.fire(EventUiCmd('showAddDevice'));
                },
              ),
            const SizedBox(width: 8),
          ],
        ) : DraggableTitleBar(title: ''),
      ),
      body: Row(
        children: [
          // Desktop Navigation Bar
          if (!isMobile && showLeftNavigationBar)
            Container(
              width: leftBarWidth,
              color: colorScheme.primary,
              child: Column(children: [
                SizedBox(
                  height: leftBarIconHeight,
                  width: leftBarWidth,
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.only(left: largePadding),
                        iconSize: iconAppSize,
                        onPressed: () {},
                        icon: Image.asset(logoIconPath, width: iconAppSize, height: iconAppSize),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: regularPadding),
                          child: Text(myAppName.appName!, style: textTheme.headlineSmall!.copyWith(color: colorScheme.onPrimary)),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(child: showNavigationBar()),
                const SizedBox(height: 16),
                Image.asset(companyImage, width: 120, height: 40),
                const SizedBox(height: 16),
              ]),
            ),

          // Main Area
          Expanded(
            child: Column(
              children: [
                if (!isMobile) ...[
                  Container(height: topLinePadding, color: colorScheme.surfaceDim),
                  SizedBox(
                    height: topBarHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: largePadding),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!showLeftNavigationBar) ...[
                                Image.asset(logoIconPath, width: 24, height: 24),
                                const SizedBox(width: 8),
                                Text(myAppName.appName!, style: textTheme.titleMedium!.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                              ],
                              Text(generateTitle(getPageId(_selectedNavRoute)), style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                        _buildTopBarActions(colorScheme, textTheme),
                      ],
                    ),
                  ),
                  Container(height: regularPadding, color: colorScheme.surfaceDim),
                ],
                // Content
                Expanded(
                  child: Container(
                    padding: isMobile ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: regularPadding),
                    color: isMobile ? Colors.white : colorScheme.surfaceDim,
                    child: Navigator(
                      key: contentNavigatorKey,
                      initialRoute: _selectedNavRoute,
                      onGenerateRoute: (settings) {
                        final pageContent = buildPageContent(_navigateContent, settings.name, lastRouteName);
                        return MaterialPageRoute(
                          builder: (context) => pageContent,
                          settings: settings,
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile && !_hideScaffoldElements ? BottomNavigationBar(
        currentIndex: _currentTabIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D558E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
            // Map tabs to routes
            switch (index) {
              case 0:
                _navigateContent('/multiScaleManagement');
                break;
              case 1:
                _navigateContent('/mobileSetting'); // Navigate to the setting list
                break;
              case 2:
                _navigateContent('/labelDesign'); // Example format route
                break;
              case 3:
                _navigateContent('/basicDataCollection'); // Example data route
                break;
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(Icons.devices_other_outlined)),
            activeIcon: Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(Icons.devices_other)),
            label: "Connecting",
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(Icons.settings_outlined)),
            activeIcon: Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(Icons.settings)),
            label: localizedStrings?.gBtnSetting ?? "Setting",
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(Icons.description_outlined)),
            activeIcon: Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(Icons.description)),
            label: localizedStrings?.menuFormat ?? "Format",
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(Icons.dns_outlined)),
            activeIcon: Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(Icons.dns)),
            label: localizedStrings?.menuData ?? "Data",
          ),
        ],
      ) : null,
    ));
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
    );
  }

  Widget showSysSetting(ColorScheme colorScheme, TextTheme textTheme) {
    return PopupMenuButton<String>(
      tooltip: (localizedStrings?.gSystemSetting ?? "gSystemSetting"),
      splashRadius: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      icon: Icon(
        Icons.settings,
        color: colorScheme.surfaceContainerHighest,
      ),
      offset: Offset(-15, 40),
      color: colorScheme.onSurfaceVariant,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuItem(
            value: '1',
            child: Text(
              (localizedStrings?.userManagement ?? "userManagement"),
              style: textTheme.bodySmall!.apply(
                // 鏍规嵁閫変腑鐘舵€佹敼鍙橀鑹?
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () {
                  _navigateContent('/settingsUser');
                },
              );
            },
          ),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuDivider(height: 1.0),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuItem(
            value: '5',
            child: Text(
              (localizedStrings?.logManagement ?? "logManagement"),
              style: textTheme.bodySmall!.apply(
                // 鏍规嵁閫変腑鐘舵€佹敼鍙橀鑹?
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () {
                  _navigateContent('/settingsLog');
                },
              );
            },
          ),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuDivider(height: 1.0),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuItem(
            value: '6',
            child: Text(
              (localizedStrings?.gBtnConfigSetting ?? "gBtnConfigSetting"),
              style: textTheme.bodySmall!.apply(
                // 鏍规嵁閫変腑鐘舵€佹敼鍙橀鑹?
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () {
                  _navigateContent('/settingsFunction');
                },
              );
            },
          ),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuDivider(height: 1.0),
        if ((mySysUser.roleId == superAdminRoleId && mySysUser.isChanged!) ||
            (mySysUser.roleId != superAdminRoleId))
          PopupMenuItem(
            value: '2',
            child: Text(
              (localizedStrings?.titleChangePassword ?? "titleChangePassword"),
              style: textTheme.bodySmall!.apply(
                // 鏍规嵁閫変腑鐘舵€佹敼鍙橀鑹?
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () {
                  showModifyPwdDialog();
                },
              );
            },
          ),
        PopupMenuDivider(height: 1.0),
        PopupMenuItem(
          value: '3',
          child: Text(
            (localizedStrings?.menuLanguageSetting ?? "menuLanguageSetting"),
            style: textTheme.bodySmall!.apply(
              // 鏍规嵁閫変腑鐘舵€佹敼鍙橀鑹?
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
        if ((mySysUser.roleId == superAdminRoleId && mySysUser.isChanged!) ||
            (mySysUser.roleId != superAdminRoleId))
          PopupMenuDivider(height: 1.0),
        if ((mySysUser.roleId == superAdminRoleId && mySysUser.isChanged!) ||
            (mySysUser.roleId != superAdminRoleId))
          PopupMenuItem(
            value: '4',
            child: Text(
              (localizedStrings?.titleLogout ?? "titleLogout"),
              style: textTheme.bodySmall!.apply(
                // 鏍规嵁閫変腑鐘舵€佹敼鍙橀鑹?
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              firstLogin = true;
              PublicFunctions.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (Route<dynamic> route) => false,
              );
            },
          ),
        PopupMenuDivider(height: 1.0),
      ],
    );
  }

  Widget _buildTopBarActions(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildServiceStatusDot(colorScheme),
        SizedBox(width: regularPadding),
        if (generateHelpTitle(getPageId(_selectedNavRoute)) != '')
          Tooltip(
            message: (localizedStrings?.gTipHelp ?? "gTipHelp"),
            child: PageInfoButton(
                helpInfo: generateHelpTitle(getPageId(_selectedNavRoute)),
                onRefresh: () {},
                color: colorScheme.surfaceContainerHighest),
          ),
        SizedBox(width: regularPadding),
        Image.asset(
          'assets/images/person.png',
          width: 24.0,
          height: 24.0,
        ),
        SizedBox(width: regularPadding),
        SizedBox(
          child: Text(
            mySysUser.nickName ?? '',
            style: textTheme.bodySmall!.apply(
              color: Adaptive.isMobile(context) ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: regularPadding),
        showSysSetting(colorScheme, textTheme),
        SizedBox(width: regularPadding),
        Tooltip(
          message: (localizedStrings?.menuSystemInformation ?? "menuSystemInformation"),
          child: IconButton(
            icon: getSvgIcon(
                infoSvgIcon(),
                topIconSize,
                topIconSize,
                Adaptive.isMobile(context) ? colorScheme.onPrimary : colorScheme.surfaceContainerHighest),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const CompanyInfoDialog();
                },
              );
            },
          ),
        ),
        SizedBox(width: regularPadding),
      ],
    );
  }

  Widget _buildServiceStatusDot(ColorScheme colorScheme) {
    return StreamBuilder<ServiceState>(
      stream: WebSocketManager().connectionStream,
      initialData: WebSocketManager().currentState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? ServiceState.disconnected;
        Color color;
        String tooltip;

        switch (state) {
          case ServiceState.connected:
            color = Colors.greenAccent;
            tooltip = "Service Connected";
            break;
          case ServiceState.connecting:
            color = Colors.orangeAccent;
            tooltip = "Connecting to Service...";
            break;
          case ServiceState.retrying:
            color = Colors.redAccent;
            tooltip = "Service Lost. Retrying in ${WebSocketManager().nextRetrySeconds}s...";
            break;
          case ServiceState.disconnected:
          default:
            color = Colors.grey;
            tooltip = "Service Disconnected";
            break;
        }

        return Tooltip(
          message: tooltip,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
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
    if (routeName == '/setConfig') {
      pageId = MenuId.appConfigPage;
    }
    return pageId;
  }

  void showSetLanguageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 鍏佽鐐瑰嚮绌虹櫧澶勫叧闂璇濇
      builder: (context) {
        return const LanguageSettingPage();
      },
    ).then((value) {
      if (value == null) {
        return;
      }
      if (mounted && value == true) {
        setState(() {
          _navigateContent(_selectedNavRoute);
        });
      }
    });
  }

  void showModifyPwdDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 鍏佽鐐瑰嚮绌虹櫧澶勫叧闂璇濇
      builder: (context) {
        return const ModifyPwdPage();
      },
    );
  }
}
