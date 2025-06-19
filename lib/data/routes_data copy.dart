// //所有的路由

// // Copyright 2019 The Flutter team. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:t_max/data/home_page_common_data.dart';
// import 'package:t_max/data/icons.dart';
// import 'package:t_max/data/language.dart';
// import 'package:t_max/data/license_data.dart';

// import '../widget/defer_widget.dart';
// // 假设你需要使用 MultiScaleManagement、SetSystemTimePage 等类
// import '../pages/all_page_path.dart' deferred as all_path
//     show
//         MultiScaleManagement,
//         SetSystemTimePage,
//         IndustryHomePage,
//         WifiSettingPage,
//         UpdateFirmwarePage,
//         WeightModePage,
//         PluEidtPage,
//         DownloadLabelPage,
//         DownReciptPage,
//         TransactionReportPage,
//         HeaderFooterPage,
//         WeightDataCollectionPage,
//         CheckWeighersPage,
//         TakeInPage,
//         TakeOutPage,
//         FormulationScalePage,
//         FlowRatePage;

// class RouteData {
//   const RouteData({
//     required this.title,
//     required this.subtitle,
//     this.buildRoute,
//     this.icon,
//     required this.id,
//   });

//   final String title;
//   final String subtitle;
//   final SvgPicture? icon;
//   final WidgetBuilder? buildRoute;
//   final int id;
// }

// const double iconsize = 22.0;

// // ... 已有代码 ...

// // 假设这是验证和付费状态变量，可根据实际情况修改

// List<RouteData> freePagesRoutes(Color color) {
//   LibraryLoader pagesLibrary = all_path.loadLibrary;
//   // 免费菜单
//   final List<RouteData> freeMenus = [
//     RouteData(
//       id: MenuId.multiScaleManagement.index,
//       title: localizedStrings.menuMultiScaleManagement,
//       icon: TIcons.multiScaleSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.MultiScaleManagement(),
//       ),
//       subtitle: localizedStrings.menuMultiScaleManagement,
//     ),
//     RouteData(
//       id: MenuId.setSystemTimePage.index,
//       title: localizedStrings.menuDeviceTime,
//       icon: TIcons.dateTimeSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.SetSystemTimePage(),
//       ),
//       subtitle: localizedStrings.menuDeviceTime,
//     ),
//     RouteData(
//       id: MenuId.btSettingPage.index,
//       title: localizedStrings.menuBluetoothSetting,
//       icon: TIcons.btSettingSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.IndustryHomePage(),
//       ),
//       subtitle: localizedStrings.menuBluetoothSetting,
//     ),
//     RouteData(
//       id: MenuId.wifiSettingPage.index,
//       title: localizedStrings.menuWifiSetting,
//       icon: TIcons.wifiSettingSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.WifiSettingPage(),
//       ),
//       subtitle: localizedStrings.menuWifiSetting,
//     ),
//     RouteData(
//       id: MenuId.updateFirmwarePage.index,
//       title: localizedStrings.menuFirmwareUpdate,
//       icon: TIcons.firmwareSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.UpdateFirmwarePage(),
//       ),
//       subtitle: localizedStrings.menuFirmwareUpdate,
//     ),
//     // 可以继续添加其他免费菜单
//   ];
// //免费菜单预留到20
//   // 付费菜单

//   final List<RouteData> paidMenus = [
//     //标签设计
//     RouteData(
//       id: MenuId.labelDesignPage.index,
//       title: localizedStrings.menuLabelDesign, // 'Label Design',
//       icon: TIcons.dateTimeSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.IndustryHomePage(),
//       ),
//       subtitle: localizedStrings.menuLabelDesign,
//     ),
//     //票据设计
//     RouteData(
//       id: MenuId.receiptDesignPage.index,
//       title: localizedStrings.menuReceiptDesign,
//       icon: TIcons.btSettingSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.IndustryHomePage(),
//       ),
//       subtitle: localizedStrings.menuReceiptDesign,
//     ),
//     RouteData(
//       id: MenuId.serialOutputDesignPage.index,
//       title: localizedStrings.menuSerialOutputDesign,
//       icon: TIcons.wifiSettingSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.IndustryHomePage(),
//       ),
//       subtitle: localizedStrings.menuSerialOutputDesign,
//     ),
//     RouteData(
//       id: MenuId.basicDataCollectionPage.index,
//       title: localizedStrings.menuBasicDataCollection,
//       icon: TIcons.firmwareSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.IndustryHomePage(),
//       ),
//       subtitle: localizedStrings.menuBasicDataCollection,
//     ),
//     RouteData(
//       id: MenuId.parameterSettingPage.index,
//       title: localizedStrings.menuParameterSetting,
//       icon: TIcons.firmwareSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.IndustryHomePage(),
//       ),
//       subtitle: localizedStrings.menuParameterSetting,
//     ),
//   ];

//   // 初始化路由列表，先添加免费菜单
//   List<RouteData> routes = List.from(freeMenus);

//   // 如果验证成功且已付费，根据用户选择添加付费菜单
//   if (myLicenseInfo.isValid) {
//     for (var paidMenu in paidMenus) {
//       if (selectedConfigPaidMenuIds.contains(paidMenu.id)) {
//         routes.add(paidMenu);
//       }
//     }
//   }

//   return routes;
// }

// String generateTitle(int pageId) {
//   if (pageId == MenuId.multiScaleManagement.index) {
//     return localizedStrings.menuMultiScaleManagement;
//   } else if (pageId == MenuId.setSystemTimePage.index) {
//     return localizedStrings.menuDeviceTime;
//   } else if (pageId == MenuId.btSettingPage.index) {
//     return localizedStrings.menuBluetoothSetting;
//   } else if (pageId == MenuId.wifiSettingPage.index) {
//     return localizedStrings.menuWifiSetting;
//   } else if (pageId == MenuId.updateFirmwarePage.index) {
//     return localizedStrings.menuFirmwareUpdate;
//   } else if (pageId == MenuId.labelDesignPage.index) {
//     return localizedStrings.menuLabelDesign;
//   } else if (pageId == MenuId.receiptDesignPage.index) {
//     return localizedStrings.menuReceiptDesign;
//   } else if (pageId == MenuId.serialOutputDesignPage.index) {
//     return localizedStrings.menuSerialOutputDesign;
//   } else if (pageId == MenuId.basicDataCollectionPage.index) {
//     return localizedStrings.menuBasicDataCollection;
//   } else if (pageId == MenuId.parameterSettingPage.index) {
//     return localizedStrings.menuParameterSetting;
//   } else if (pageId == MenuId.weightModePage.index) {
//     return localizedStrings.menuWeighing;
//   } else if (pageId == MenuId.pluEditPage.index) {
//     return localizedStrings.menuPluManagement;
//   } else if (pageId == MenuId.downloadLabelPage.index) {
//     return localizedStrings.menuLabelFormatDownload;
//   } else if (pageId == MenuId.downReciptPage.index) {
//     return localizedStrings.menuReceiptFormatDownload;
//   } else if (pageId == MenuId.transactionReportPage.index) {
//     return localizedStrings.menuTransactionReport;
//   } else if (pageId == MenuId.headerFooterPage.index) {
//     return localizedStrings.menuHeaderFooter;
//   } else if (pageId == MenuId.weightDataCollectionPage.index) {
//     return localizedStrings.menuWeightDataCollection;
//   } else if (pageId == MenuId.checkWeighersPage.index) {
//     return localizedStrings.menuCheckWeighers;
//   } else if (pageId == MenuId.takeInPage.index) {
//     return localizedStrings.menuTakeIn;
//   } else if (pageId == MenuId.takeOutPage.index) {
//     return localizedStrings.menuTakeOut;
//   } else if (pageId == MenuId.formulationScalePage.index) {
//     return localizedStrings.menuFormulationScale;
//   } else if (pageId == MenuId.flowRatePage.index) {
//     return localizedStrings.menuFlowRate;
//   }
//   return '';
// }

// List<RouteData> getConfigPaidMenus(Color color) {
//   return [
//     //标签设计
//     RouteData(
//       id: MenuId.labelDesignPage.index,
//       title: localizedStrings.menuLabelDesign, // 'Label Design',
//       icon: TIcons.labelDesignSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),

//       subtitle: localizedStrings.menuLabelDesign,
//     ),
//     //票据设计
//     RouteData(
//       id: MenuId.receiptDesignPage.index,
//       title: localizedStrings.menuReceiptDesign,
//       icon: TIcons.reciptDesignSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       subtitle: localizedStrings.menuReceiptDesign,
//     ),
//     RouteData(
//       id: MenuId.serialOutputDesignPage.index,
//       title: localizedStrings.menuSerialOutputDesign,
//       icon: TIcons.serialSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       subtitle: localizedStrings.menuSerialOutputDesign,
//     ),
//     RouteData(
//       id: MenuId.basicDataCollectionPage.index,
//       title: localizedStrings.menuBasicDataCollection,
//       icon: TIcons.basicDataSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       subtitle: localizedStrings.menuBasicDataCollection,
//     ),
//     RouteData(
//       id: MenuId.parameterSettingPage.index,
//       title: localizedStrings.menuParameterSetting,
//       icon: TIcons.parameterSvgIcon(
//         width: iconsize,
//         height: iconsize,
//         color: color,
//       ),
//       subtitle: localizedStrings.menuParameterSetting,
//     ),
//   ];
// }

// // 所有的App,免费的和收费的

// List<RouteData> appsPagesRoutes(Color color, double size, {int type = 0}) {
//   LibraryLoader pagesLibrary = all_path.loadLibrary;
//   // 免费菜单
//   final List<RouteData> freeAppsMenus = [
//     RouteData(
//       id: MenuId.weightModePage.index,
//       title: localizedStrings.menuWeighing,
//       icon: TIcons.weighingSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.WeightModePage(),
//       ),
//       subtitle: localizedStrings.menuWeighing,
//     ),
//     RouteData(
//       id: MenuId.pluEditPage.index,
//       title: localizedStrings.menuPluManagement,
//       icon: TIcons.pluEditSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.PluEidtPage(),
//       ),
//       subtitle: localizedStrings.menuPluManagement,
//     ),
//     RouteData(
//       id: MenuId.downloadLabelPage.index,
//       title: localizedStrings.menuLabelFormatDownload,
//       icon: TIcons.labelDownloadSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.DownloadLabelPage(),
//       ),
//       subtitle: localizedStrings.menuLabelFormatDownload,
//     ),
//     RouteData(
//       id: MenuId.downReciptPage.index,
//       title: localizedStrings.menuReceiptFormatDownload,
//       icon: TIcons.reciptDownloadSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.DownReciptPage(),
//       ),
//       subtitle: localizedStrings.menuReceiptFormatDownload,
//     ),
//     RouteData(
//       id: MenuId.transactionReportPage.index,
//       title: localizedStrings.menuRetailReport,
//       icon: TIcons.detailReportSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.TransactionReportPage(),
//       ),
//       subtitle: localizedStrings.menuRetailReport,
//     ),
//     RouteData(
//       id: MenuId.headerFooterPage.index,
//       title: localizedStrings.menuVariableValueSetting,
//       icon: TIcons.varSettingSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.HeaderFooterPage(),
//       ),
//       subtitle: localizedStrings.menuVariableValueSetting,
//     ),
//   ];

//   List<RouteData> routes = [];

//   final List<RouteData> paidAddAppsMenus = [
//     RouteData(
//       id: MenuId.weightDataCollectionPage.index,
//       title: localizedStrings.menuWeighingDataCollection,
//       icon: TIcons.wgtCollectionSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.WeightDataCollectionPage(),
//       ),
//       subtitle: localizedStrings.menuWeighingDataCollection,
//     ),
//     RouteData(
//       id: MenuId.checkWeighersPage.index,
//       title: localizedStrings.menuCheckWeighing,
//       icon: TIcons.checkScaleSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.CheckWeighersPage(),
//       ),
//       subtitle: localizedStrings.menuCheckWeighing,
//     ),
//     RouteData(
//       id: MenuId.takeInPage.index,
//       title: localizedStrings.menuIncrementWeighing,
//       icon: TIcons.addScaleSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.TakeInPage(),
//       ),
//       subtitle: localizedStrings.menuIncrementWeighing,
//     ),
//     RouteData(
//       id: MenuId.takeOutPage.index,
//       title: localizedStrings.menuTakeOutScale,
//       icon: TIcons.minusScaleSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.TakeOutPage(),
//       ),
//       subtitle: localizedStrings.menuTakeOutScale,
//     ),
//     RouteData(
//       id: MenuId.formulationScalePage.index,
//       title: localizedStrings.menuFormula,
//       icon: TIcons.formulaModeSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.FormulationScalePage(),
//       ),
//       subtitle: localizedStrings.menuFormula,
//     ),
//     RouteData(
//       id: MenuId.flowRatePage.index,
//       title: localizedStrings.menuFlowRate,
//       icon: TIcons.rateSpeedSvgIcon(
//         width: size,
//         height: size,
//         color: color,
//       ),
//       buildRoute: (_) => DeferredWidget(
//         pagesLibrary,
//         () => all_path.FlowRatePage(),
//       ),
//       subtitle: localizedStrings.menuFlowRate,
//     ),
//   ];

//   for (var menu in freeAppsMenus) {
//     if (selectedAppsPaidMenuIds.contains(menu.id)) {
//       routes.add(menu);
//     }
//   }

//   for (var menu in paidAddAppsMenus) {
//     if (selectedAppsPaidMenuIds.contains(menu.id)) {
//       routes.add(menu);
//     }
//   }

//   if (type == 1) {
//     List<RouteData> allRoutes = [];
//     for (var menu in freeAppsMenus) {
//       allRoutes.add(menu);
//     }

//     for (var menu in paidAddAppsMenus) {
//       allRoutes.add(menu);
//     }
//     return allRoutes;
//   }

//   return routes;
// }
