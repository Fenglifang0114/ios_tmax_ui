// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:t_max/widget/page_head.dart';
// import '../data/comscaleinfo_data.dart';
// import '../data/manager_scale_channel.dart';
// import 'package:t_max/data/dialog_data.dart';
// import 'package:t_max/data/license_data.dart';
// import 'package:t_max/data/scale_info_from_scale.dart';
// import 'package:t_max/eventbus/eventbus.dart';
// import 'package:t_max/pages/labeldesign_page.dart';
// import 'package:window_manager/window_manager.dart';
// import '../data/company_info.dart';
// import '../data/downloadresponse.dart';
// import '../data/language.dart';
// import '../data/screen_mgr.dart';
// import '../data/timer_manager.dart';
// import '../dialog/exit_app_dialog.dart';
// import '../functions/methods.dart';
// import '../generated/l10n.dart';
// import '../widget/bluetooth_setting.dart';
// import '../widget/custom_circle_icon.dart';
// import '../dialog/license_info.dart';
// import 'receipt_design_page.dart';
// import 'package:tray_manager/tray_manager.dart';
// import 'package:t_max/data/home_page_common_data.dart';
// import 'package:t_max/data/routes_data.dart';
// import 'package:smart_tooltip/smart_tooltip.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage>
//     with TrayListener, WindowListener {
//   List<String> items = [];

//   late ScrollController _pageScrollerController;
//   dynamic _eventbus1;

//   dynamic _eventbus3;
//   dynamic _eventbus4;
//   dynamic _eventbus5;
//   dynamic _eventbus6;
//   dynamic _eventbus7;
//   dynamic _eventbus8;
//   dynamic _eventbus9;

//   bool showHint1 = false;
//   bool showHint2 = false;

//   bool isResize = false;

//   String groupValue = 'zh';
//   DateTime now = DateTime.now();

//   bool isLeftBarCollapsed = false;
//   int? _selectedIndex; // 新增选中导航栏的索引
//   bool isExpanded = true; // 侧边栏是否展开

//   Future<void> _handleSetIcon() async {
//     String iconPath =
//         Platform.isWindows ? 'assets/images/app.ico' : 'assets/images/app.png';
//     await windowManager.setIcon(iconPath);
//   }

//   Future<void> _init() async {
//     await trayManager.setIcon(
//       Platform.isWindows ? 'assets/images/app.ico' : 'assets/images/app.png',
//     );
//     setState(() {});
//     await windowManager.setPreventClose(true); //关闭前确认
//     setState(() {});
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     localizedStrings = S.of(context);
//     Future.delayed(const Duration(milliseconds: 200), () {
//       setState(() {
//         List<RouteData> allRoutes =
//             freePagesRoutes(Theme.of(context).colorScheme.onPrimary);
//         for (var item in allRoutes) {
//           if (item.id == selectPageId) {
//             topTitleName = topTitleName = generateTitle(selectPageId);
//             _selectedIndex = allRoutes.indexOf(item);
//             break;
//           }
//         }
//         if (_selectedIndex == null) {
//           _selectedIndex = 0;
//           selectPageId = allRoutes[0].id;

//           topTitleName = generateTitle(selectPageId);
//         }
//       });
//     });
//   }

//   @override
//   void onWindowResize() {
//     isResize = true;
//   }

//   @override
//   void onWindowClose() async {
//     bool isPreventClose = await windowManager.isPreventClose();
//     if (isPreventClose) {
//       showDialog(
//         context: context,
//         barrierDismissible: false, // 允许点击空白处关闭对话框
//         builder: (context) {
//           return CustomAlertDialog(
//             titleText: localizedStrings.gTipExitApp,
//             onNoPressed: () {
//               Navigator.of(context).pop();
//             },
//             onYesPressed: () async {
//               Navigator.of(context).pop();
//               dispose();
//               await trayManager.destroy(); //退出系统托盘
//               await windowManager.destroy();
//               exit(0);
//             },
//           );
//         },
//       );
//     }
//   }

//   @override
//   void onWindowMaximize() {
//     isResize = true;
//   }

//   @override
//   void onWindowUnmaximize() {
//     isResize = true;
//   }

//   @override
//   void onWindowMinimize() {
//     isResize = true;
//   }

//   @override
//   void initState() {
//     trayManager.addListener(this);
//     windowManager.addListener(this);

//     _init();
//     _handleSetIcon();
//     windowManager.setMinimumSize(Size(1320, 720));
//     super.initState();
//     _pageScrollerController = ScrollController();
//     cntScaleTimerMgr.startCntScaleTimer(5);

//     _eventbus1 = eventBus.on<EventDialogData>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myDialogData = event.obj;
//         });
//       }
//     });
//     setState(() {
//       now = DateTime.now();
//     });

//     _eventbus3 = eventBus.on<EventRespCheckComPort>().listen((event) {
//       if (mounted) {
//         if (myScreenMgr.isMainScreen) {
//           setState(() {
//             myComScaleSn = event.obj;
//             if (myComScaleSn.modelName != '') {
//               myComScaleInfo.isOnline = true;
//               myComScaleInfo.isOnline = true;
//               PublicFunctions.getOneEepromInfo("wifi_or_bt", 1);
//             } else {
//               myComScaleInfo.isOnline = false;
//               myComScaleSn.modelName = '';
//               myComScaleSn.scaleSn = '';
//               myComScaleInfo.isOnline = false;
//               myScreenMgr.wifiOrBt = 'off';
//             }
//           });
//         }
//       }
//     });

//     _eventbus4 = eventBus.on<EventGetFactoryInfo>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myFactoryInfoFromScale = event.obj;
//         });
//       }
//     });

//     _eventbus5 = eventBus.on<EventGetOneEepromDateResp>().listen((event) {
//       if (mounted) {
//         setState(() {
//           myRespDataFromScale = event.obj;
//           if (myRespDataFromScale.msgBody.contains('ok')) {
//             if (myRespDataFromScale.msgBody.contains('bt')) {
//               myScreenMgr.wifiOrBt = 'bt';
//             } else if (myRespDataFromScale.msgBody.contains('wifi')) {
//               myScreenMgr.wifiOrBt = 'wifi';
//             } else if (myRespDataFromScale.msgBody.contains('off')) {
//               myScreenMgr.wifiOrBt = 'off';
//             }
//           }
//         });
//       }
//     });
//     _eventbus6 = eventBus.on<EventLicenseData>().listen((event) {
//       if (mounted) {
//         setState(() {
//           var eventInfo = event.obj;
//           if (eventInfo.isNotEmpty) {
//             var jsonData = json.decode(eventInfo);

//             try {
//               myLicenseData = LicenseData.fromJson(jsonData);
//             } catch (e) {
//               myLicenseData = LicenseData([]);
//             }
//             if (myLicenseData.licList.isNotEmpty) {
//               LicenseSetting().setLicInfo();
//             }
//           }
//         });
//       }
//     });
//     _eventbus7 = eventBus.on<EventCloseScalePassthResp>().listen((event) {
//       if (mounted) {
//         PublicFunctions.stopWeight(myDefScaleInfo.defScaleId!);
//       }
//     });
//     _eventbus8 = eventBus.on<EventSerialPortResponse>().listen((event) {
//       if (mounted) {
//         if (myScreenMgr.isMainScreen) {
//           setState(() {
//             myRespDataFromScale = event.obj;
//             if (myComScaleInfo.isOnline) {
//               myComScaleInfo.isOnline = false;
//               myComScaleSn.modelName = '';
//               myComScaleSn.scaleSn = '';
//               myComScaleInfo.isOnline = false;
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                   content: Text('The serial port disconnected.',
//                       style: const TextStyle(fontSize: 20)), ////此处需要秤回复
//                   duration: const Duration(seconds: 5),
//                   backgroundColor: Theme.of(context).colorScheme.error));
//             }
//           });
//         }
//       }
//     });

//     _eventbus9 = eventBus.on<EventServiceOff>().listen((event) {
//       setState(() {
//         showServiceErrorDialog(context, localizedStrings.gTipServiceOff,
//             localizedStrings.gTitleConfirm);
//       });
//     });

//     // 所有初始化完成后设置默认页面
//   }

//   @override
//   void dispose() {
//     _eventbus1.cancel();
//     _eventbus3.cancel();
//     _eventbus4.cancel();
//     _eventbus5.cancel();
//     _eventbus6.cancel();
//     _eventbus7.cancel();
//     _eventbus8.cancel();
//     _eventbus9.cancel();

//     _pageScrollerController.dispose();
//     cntScaleTimerMgr.stopCntScaleTimer();
//     trayManager.removeListener(this);
//     windowManager.removeListener(this);

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//     List<RouteData> allRoutes = freePagesRoutes(colorScheme.onPrimary);
//     print(allRoutes.length);
//     Widget showNavigationBar(bool isExpanded, List<RouteData> demos) {
//       return ListView.builder(
//         primary: false,
//         itemBuilder: (context, index) => MenuItem(
//           demo: demos[index],
//           isExpanded: isExpanded,
//           isSelected: index == _selectedIndex,
//           onTap: () {
//             setState(() {
//               _selectedIndex = index;
//               selectPageId = demos[index].id;
//               topTitleName = generateTitle(selectPageId);
//             });
//           },
//         ),
//         itemCount: demos.length,
//       );
//     }

//     return Scaffold(
//       body: Row(
//         children: [
//           // 左侧部分，宽度 240
//           Container(
//             width: isExpanded ? leftBarWidth : leftBarLittleWidth,
//             color: Theme.of(context).colorScheme.primary, // 可替换为实际内容
//             child: Column(children: [
//               Container(
//                 height: leftBarIconHeight,
//                 width: isExpanded ? leftBarWidth : leftBarLittleWidth,
//                 child: Row(
//                   children: [
//                     IconButton(
//                       padding: EdgeInsets.only(left: largePadding),
//                       iconSize: iconAppSize,
//                       onPressed: () {
//                         setState(() {
//                           isExpanded = !isExpanded;
//                         });
//                       },
//                       icon: Image.asset(
//                         appIconPath,
//                         width: iconAppSize,
//                         height: iconAppSize,
//                       ),
//                     ),
//                     isExpanded
//                         ? Expanded(
//                             child: Container(
//                                 padding: EdgeInsets.only(left: regularPadding),
//                                 child: Text(
//                                   myAppName.appName!,
//                                   style: textTheme.headlineSmall!.apply(
//                                       // 根据选中状态改变颜色
//                                       color: colorScheme.onPrimary),
//                                 )))
//                         : SizedBox()
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: showNavigationBar(isExpanded, allRoutes),
//               ),
//             ]),
//           ),

//           // 右侧部分，占据剩余空间
//           Expanded(
//             child: Column(
//               children: [
//                 // 右上部分，高度 64
//                 Container(
//                   height: topLinePadding,
//                   color: colorScheme.surfaceDim,
//                 ),
//                 Container(
//                   height: topBarHeight,
//                   color: colorScheme.surface, // 可替换为实际内容
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.only(left: largePadding),
//                         child: Text(
//                           topTitleName,
//                           style: textTheme.bodySmall!.apply(
//                               // 根据选中状态改变颜色
//                               color: colorScheme.onSurface),
//                         ),
//                       ),
//                       TopRightIcons(onRefresh: () {
//                         if (mounted) {
//                           setState(() {
//                             topTitleName = generateTitle(selectPageId);
//                           }); // 刷新整个页面
//                         }
//                       }),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   height: regularPadding,
//                   color: colorScheme.surfaceDim,
//                 ),
//                 // 右下部分，占据剩余空间

//                 Expanded(
//                   child: Row(
//                     children: [
//                       // 右下左侧部分，宽度 290
//                       Container(
//                         width: regularPadding,
//                         color: colorScheme.surfaceDim,
//                       ),
//                       _selectedIndex != null &&
//                               allRoutes[_selectedIndex!].id ==
//                                   MenuId.multiScaleManagement.index
//                           ? SizedBox()
//                           : Container(
//                               width: scaleListWidth,
//                               color: Colors.yellow, // 可替换为实际内容
//                               child: const Center(child: Text('右下左侧部分')),
//                             ),
//                       // 右下右侧部分，占据剩余空间
//                       Expanded(
//                           child: Container(
//                         color: colorScheme.surface,
//                         child: _selectedIndex != null
//                             ? allRoutes[_selectedIndex!].buildRoute!(context)
//                             : Container(
//                                 color: colorScheme.surface,
//                               ),
//                       )),
//                       Container(
//                         height: regularPadding,
//                         color: colorScheme.surfaceDim,
//                       ),
//                       Container(
//                         width: regularPadding,
//                         color: colorScheme.surfaceDim,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   height: regularPadding,
//                   color: colorScheme.surfaceDim,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget functionTitle(String titleName, IconData iconName) {
//     return Row(
//       children: [
//         CustomCircleIcon(
//           outerColor: Theme.of(context).colorScheme.primary,
//           innerColor: Theme.of(context).colorScheme.onPrimary,
//           icon: iconName,
//           size: 30.0,
//         ),
//         const SizedBox(
//           width: 10,
//         ),
//         Text(titleName),
//       ],
//     );
//   }

//   void showReceiptDesign(bool isValid) {
//     if (isValid) {
//       stopCheckSerialPort();

//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const ReceiptDesignPage()),
//       ).then((value) => _updateStatus());
//     }
//   }

//   void showLabelDesign(bool isValid) {
//     if (isValid) {
//       stopCheckSerialPort();

//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const LabelDesignPage()),
//       ).then((value) => _updateStatus());
//     }
//   }

//   void showBluetoothDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // 允许点击空白处关闭对话框
//       builder: (context) {
//         return const BluetoothDialog();
//       },
//     ).then((value) => _updateStatus());
//   }

//   void _updateStatus() {
//     setState(() {});
//     cntScaleTimerMgr.stopCntScaleTimer();
//     cntScaleTimerMgr.startCntScaleTimer(5);
//   }

//   void showLicenseDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // 允许点击空白处关闭对话框
//       builder: (context) {
//         return const LicenseInfoDialog();
//       },
//     ).then((value) => _updateStatus());
//   }

//   void stopCheckSerialPort() {
//     myScreenMgr.isMainScreen = false;
//     cntScaleTimerMgr.stopCntScaleTimer();
//   }
// }

// //主界面

// class Backdrop extends StatefulWidget {
//   const Backdrop({super.key});
//   @override
//   State<Backdrop> createState() => _BackdropState();
// }

// class _BackdropState extends State<Backdrop> {
//   //左侧部分是否收起
//   bool isLeftBarCollapsed = false;
//   late ValueNotifier<bool> _isSidebarExpandedNotifier;
//   late AnimationController _sidebarController;
//   int? _selectedIndex; // 新增选中导航栏的索引
//   bool isExpanded = true; // 侧边栏是否展开

//   @override
//   void initState() {
//     super.initState();
//     _isSidebarExpandedNotifier = ValueNotifier(true);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   // 修改后的切换侧边栏状态方法
//   void toggleSidebar() {
//     final isExpanded = _isSidebarExpandedNotifier.value;
//     _isSidebarExpandedNotifier.value = !isExpanded;
//     if (isExpanded) {
//       _sidebarController.reverse();
//     } else {
//       _sidebarController.forward();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//     List<RouteData> allRoutes = freePagesRoutes(colorScheme.onPrimary);
//     Widget showNavigationBar(bool isExpanded, List<RouteData> demos) {
//       return ListView.builder(
//         primary: false,
//         itemBuilder: (context, index) => MenuItem(
//           demo: demos[index],
//           isExpanded: isExpanded,
//           isSelected: index == _selectedIndex,
//           onTap: () {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//         ),
//         itemCount: demos.length,
//       );
//     }

//     return Scaffold(
//       body: Row(
//         children: [
//           // 左侧部分，宽度 240
//           Container(
//             width: isExpanded ? leftBarWidth : leftBarLittleWidth,
//             color: Theme.of(context).colorScheme.primary, // 可替换为实际内容
//             child: Column(children: [
//               Container(
//                 height: leftBarIconHeight,
//                 width: isExpanded ? leftBarWidth : leftBarLittleWidth,
//                 child: Row(
//                   children: [
//                     IconButton(
//                       padding: EdgeInsets.only(left: largePadding),
//                       iconSize: iconAppSize,
//                       onPressed: () {
//                         setState(() {
//                           isExpanded = !isExpanded;
//                         });
//                       },
//                       icon: Image.asset(
//                         appIconPath,
//                         width: iconAppSize,
//                         height: iconAppSize,
//                       ),
//                     ),
//                     isExpanded
//                         ? Expanded(
//                             child: Container(
//                                 padding: EdgeInsets.only(left: regularPadding),
//                                 child: Text(
//                                   myAppName.appName!,
//                                   style: textTheme.headlineSmall!.apply(
//                                       // 根据选中状态改变颜色
//                                       color: colorScheme.onPrimary),
//                                 )))
//                         : SizedBox()
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: showNavigationBar(isExpanded, allRoutes),
//               ),
//             ]),
//           ),

//           // 右侧部分，占据剩余空间
//           Expanded(
//             child: Column(
//               children: [
//                 // 右上部分，高度 64
//                 Container(
//                   height: topBarHeight,
//                   color: Colors.green, // 可替换为实际内容
//                   child:
//                       Center(child: Text(localizedStrings.menuLabelDesign)),
//                 ),
//                 SizedBox(
//                   height: regularPadding,
//                 ),
//                 // 右下部分，占据剩余空间

//                 Expanded(
//                   child: Row(
//                     children: [
//                       // 右下左侧部分，宽度 290
//                       SizedBox(
//                         width: regularPadding,
//                       ),
//                       Container(
//                         width: scaleListWidth,
//                         color: Colors.yellow, // 可替换为实际内容
//                         child: const Center(child: Text('右下左侧部分')),
//                       ),
//                       // 右下右侧部分，占据剩余空间
//                       Expanded(
//                           child: Container(
//                         color: colorScheme.surface,
//                         child: _selectedIndex != null
//                             ? allRoutes[_selectedIndex!].buildRoute!(context)
//                             : Container(
//                                 color: colorScheme.surface,
//                               ),
//                       )),
//                       SizedBox(
//                         width: regularPadding,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: regularPadding,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// typedef CategoryHeaderTapCallback = Function(bool shouldOpenList);
// const double barLeftWidth = 24;
// const double barBetweenHeight = 13;

// // 修改 MenuItem 以支持选中状态和点击回调
// class MenuItem extends StatelessWidget {
//   const MenuItem({
//     super.key,
//     required this.demo,
//     this.isExpanded = true,
//     required this.isSelected, // 新增选中状态
//     required this.onTap, // 新增点击回调
//   });

//   final RouteData demo;
//   final bool isExpanded;
//   final bool isSelected; // 新增选中状态
//   final VoidCallback onTap; // 新增点击回调

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final colorScheme = Theme.of(context).colorScheme;

//     Widget buildMenuInfo() {
//       return SizedBox(
//           height: 52, // 固定高度
//           child: Material(
//             color: isSelected
//                 ? Color(0xFF06406F)
//                 : Theme.of(context).colorScheme.primary,
//             child: MergeSemantics(
//               child: InkWell(
//                 onTap: onTap, // 绑定点击回调
//                 child: Padding(
//                     padding: EdgeInsetsDirectional.only(
//                       start: isExpanded ? 20 : barLeftWidth,
//                       end: 5,
//                     ),
//                     child: Container(
//                       alignment: Alignment.centerLeft,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             child: demo.icon,
//                           ),
//                           if (isExpanded) ...[
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Flexible(
//                               fit: FlexFit.loose,
//                               child: FittedBox(
//                                 fit: BoxFit.scaleDown, // 仅在需要时缩小内容
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   demo.title,
//                                   maxLines: 1,
//                                   style: textTheme.bodySmall!.apply(
//                                       // 根据选中状态改变颜色
//                                       color: colorScheme.onPrimary),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     )),
//               ),
//             ),
//           ));
//     }

//     if (isExpanded) {
//       return buildMenuInfo();
//     }
//     return SmartTooltip(
//         borderColor: colorScheme.onInverseSurface,
//         message: isExpanded ? '' : demo.title,
//         backgroundColor: colorScheme.onInverseSurface.withValues(alpha: 0.7),
//         textStyle: TextStyle(
//           color: colorScheme.onPrimary,
//         ),
//         position: TooltipPosition.right,
//         child: buildMenuInfo());
//   }
// }
