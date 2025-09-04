//所有的路由
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/pages/basic_data_page.dart';
import 'package:t_max/pages/blue_tooth_setting_page.dart';
import 'package:t_max/pages/calibration_page.dart';
import 'package:t_max/pages/check_weighers_page.dart';
import 'package:t_max/pages/configuration_center_page.dart';
import 'package:t_max/pages/serial_protocol_page.dart';
import 'package:t_max/pages/down_recipt_fmt_page.dart';
import 'package:t_max/pages/flow_rate_page.dart';
import 'package:t_max/pages/formula_scale_page.dart';
import 'package:t_max/pages/labeldesign_page.dart';
import 'package:t_max/pages/lable_down_prn_fmt_page.dart';
import 'package:t_max/pages/multi_scale_management_page.dart';
import 'package:t_max/pages/plu_edit_page.dart';
import 'package:t_max/pages/receipt_design_page.dart';
import 'package:t_max/pages/retail_report_page.dart';
import 'package:t_max/pages/set_system_time.dart';
import 'package:t_max/pages/sys_user_manager.dart';
import 'package:t_max/pages/take_in_page.dart';
import 'package:t_max/pages/take_out_page.dart';
import 'package:t_max/pages/update_firmware_page.dart';
import 'package:t_max/pages/weighing.dart';
import 'package:t_max/pages/weight_collection_page.dart';
import 'package:t_max/pages/wifi_setting_page.dart';

class RouteData {
  RouteData({
    required this.title,
    required this.subtitle,
    required this.id,
    this.routeName,
    this.selected,
    required this.iconPath,
  });

  String title;
  String subtitle;
  int id;
  String? routeName;
  String? selected;
  String iconPath;
}

List<int> allPaidConfigMenu = [
  MenuId.labelDesignPage.index,
  MenuId.receiptDesignPage.index,
  MenuId.serialOutputDesignPage.index,
  MenuId.basicDataCollectionPage.index,
  // MenuId.parameterSettingPage.index,
];

List<RouteData> getAllConfigMenus() {
  List<RouteData> allConfigMenus = [
    RouteData(
      id: MenuId.multiScaleManagement.index,
      title: localizedStrings.menuMultiScaleManagement,
      routeName: "/multiScaleManagement",
      subtitle: localizedStrings.subTitleMultiScaleManagement,
      iconPath: multiScaleSvgIcon(),
    ),
    RouteData(
      id: MenuId.setSystemTimePage.index,
      title: localizedStrings.menuDeviceTime,
      routeName: "/setSystemTime",
      subtitle: localizedStrings.subTitleDeviceTime,
      iconPath: dateTimeSvgIcon(),
    ),
    RouteData(
      id: MenuId.btSettingPage.index,
      title: localizedStrings.menuBluetoothSetting,
      routeName: "/btSetting",
      subtitle: localizedStrings.subTitleBluetoothSetting,
      iconPath: btSettingSvgIcon(),
    ),
    RouteData(
      id: MenuId.wifiSettingPage.index,
      title: localizedStrings.menuWifiSetting,
      routeName: "/wifiSetting",
      subtitle: localizedStrings.subTitleWifiSetting,
      iconPath: wifiSettingSvgIcon(),
    ),
    RouteData(
      id: MenuId.updateFirmwarePage.index,
      title: localizedStrings.menuFirmwareUpdate,
      routeName: "/updateFirmware",
      subtitle: localizedStrings.subTitleFirmwareUpdate,
      iconPath: firmwareSvgIcon(),
    ),
    RouteData(
      id: MenuId.labelDesignPage.index,
      title: localizedStrings.menuLabelDesign,
      routeName: "/labelDesign",
      subtitle: localizedStrings.subTitleLabelDesign,
      iconPath: labelDesignSvgIcon(),
    ),
    RouteData(
      id: MenuId.receiptDesignPage.index,
      title: localizedStrings.menuReceiptDesign,
      routeName: "/receiptDesign",
      subtitle: localizedStrings.subTitleReceiptDesign,
      iconPath: reciptDesignSvgIcon(),
    ),
    RouteData(
      id: MenuId.serialOutputDesignPage.index,
      title: localizedStrings.menuSerialOutputDesign,
      routeName: "/serialOutputDesign",
      subtitle: localizedStrings.subTitleSerialOutputDesign,
      iconPath: serialSvgIcon(),
    ),
    RouteData(
      id: MenuId.basicDataCollectionPage.index,
      title: localizedStrings.menuBasicDataCollection,
      routeName: "/basicDataCollection",
      subtitle: localizedStrings.subTitleBasicDataCollection,
      iconPath: basicDataSvgIcon(),
    ),
    // RouteData(
    //     id: MenuId.parameterSettingPage.index,
    //     title: localizedStrings.menuParameterSetting,
    //     routeName: "/parameterSetting",
    //     subtitle: localizedStrings.subTitleParameterSetting,
    //     iconPath: parameterSvgIcon()),
    RouteData(
        id: MenuId.calibrationPage.index,
        title: localizedStrings.menuWeighingSetting,
        routeName: "/calibration",
        subtitle: localizedStrings.subTitleCalibration,
        iconPath: calibrationSvgIcon()),
    RouteData(
      id: MenuId.pluEditPage.index,
      title: localizedStrings.menuPluManagement,
      routeName: "/pluEdit",
      subtitle: localizedStrings.subTitlePluManagement,
      iconPath: pluEditSvgIcon(),
    ),
    RouteData(
        id: MenuId.downloadLabelPage.index,
        title: localizedStrings.menuLabelFormatDownload,
        routeName: "/downloadLabel",
        subtitle: localizedStrings.subTitleLabelFormatDownload,
        iconPath: labelDownloadSvgIcon()),
    RouteData(
        id: MenuId.downReciptPage.index,
        title: localizedStrings.menuReceiptFormatDownload,
        routeName: "/downRecipt",
        subtitle: localizedStrings.subTitleReceiptFormatDownload,
        iconPath: reciptDownloadSvgIcon()),
  ];
  return allConfigMenus;
}

List<RouteData> getCurrentConfigMenus() {
  List<RouteData> currentConfigMenus = [];
  List<RouteData> allConfigMenus = getAllConfigMenus();
  for (var menu in allConfigMenus) {
    if (freeConfigMenuIds.contains(menu.id) &&
        selectedConfigPaidMenuIds.contains(menu.id) &&
        getUserPermission(menu.id)) {
      currentConfigMenus.add(menu);
    } else if (myLicenseInfo.isValid &&
        selectedConfigPaidMenuIds.contains(menu.id) &&
        getUserPermission(menu.id)) {
      currentConfigMenus.add(menu);
    }
  }
  return currentConfigMenus;
}

String generateTitle(int pageId) {
  if (pageId == MenuId.multiScaleManagement.index) {
    return localizedStrings.menuMultiScaleManagement;
  } else if (pageId == MenuId.setSystemTimePage.index) {
    return localizedStrings.menuDeviceTime;
  } else if (pageId == MenuId.btSettingPage.index) {
    return localizedStrings.menuBluetoothSetting;
  } else if (pageId == MenuId.wifiSettingPage.index) {
    return localizedStrings.menuWifiSetting;
  } else if (pageId == MenuId.updateFirmwarePage.index) {
    return localizedStrings.menuFirmwareUpdate;
  } else if (pageId == MenuId.labelDesignPage.index) {
    return localizedStrings.menuLabelDesign;
  } else if (pageId == MenuId.receiptDesignPage.index) {
    return localizedStrings.menuReceiptDesign;
  } else if (pageId == MenuId.serialOutputDesignPage.index) {
    return localizedStrings.menuSerialOutputDesign;
  } else if (pageId == MenuId.basicDataCollectionPage.index) {
    return localizedStrings.menuBasicDataCollection;
  }
  // else if (pageId == MenuId.parameterSettingPage.index) {
  //   return localizedStrings.menuParameterSetting;
  // }
  else if (pageId == MenuId.weightModePage.index) {
    return localizedStrings.menuWeighing;
  } else if (pageId == MenuId.pluEditPage.index) {
    return localizedStrings.menuPluManagement;
  } else if (pageId == MenuId.downloadLabelPage.index) {
    return localizedStrings.menuLabelFormatDownload;
  } else if (pageId == MenuId.downReciptPage.index) {
    return localizedStrings.menuReceiptFormatDownload;
  } else if (pageId == MenuId.retailReportPage.index) {
    return localizedStrings.menuRetailReport;
  } else if (pageId == MenuId.weightDataCollectionPage.index) {
    return localizedStrings.menuWeighingDataCollection;
  } else if (pageId == MenuId.checkWeighersPage.index) {
    return localizedStrings.menuCheckWeighing;
  } else if (pageId == MenuId.takeInPage.index) {
    return localizedStrings.menuIncrementWeighing;
  } else if (pageId == MenuId.takeOutPage.index) {
    return localizedStrings.menuTakeOutScale;
  } else if (pageId == MenuId.formulationScalePage.index) {
    return localizedStrings.menuFormula;
  } else if (pageId == MenuId.flowRatePage.index) {
    return localizedStrings.menuFlowRate;
  } else if (pageId == MenuId.calibrationPage.index) {
    return localizedStrings.menuWeighingSetting;
  } else if (pageId == MenuId.appLabelDesignPage.index) {
    return localizedStrings.menuLabelDesign;
  } else if (pageId == MenuId.appRcpDesignPage.index) {
    return localizedStrings.menuReceiptDesign;
  }
  return '';
}

String generateHelpTitle(int pageId) {
  if (pageId == MenuId.multiScaleManagement.index) {
    return localizedStrings.gTipScaleMgrPageHelp;
  } else if (pageId == MenuId.setSystemTimePage.index) {
    return localizedStrings.gTipDeviceTimePageHelp;
  } else if (pageId == MenuId.wifiSettingPage.index) {
    return localizedStrings.gTipWifiSettingPageHelp;
  } else if (pageId == MenuId.updateFirmwarePage.index) {
    return localizedStrings.gTipUpdateFirmwarePageHelp;
  } else if (pageId == MenuId.labelDesignPage.index) {
    return localizedStrings.gTipLabelDesignPageHelp;
  } else if (pageId == MenuId.receiptDesignPage.index) {
    return localizedStrings.gTipReceiptDesignPageHelp;
  } else if (pageId == MenuId.serialOutputDesignPage.index) {
    return localizedStrings.gTipSerialDesignPageHelp;
  } else if (pageId == MenuId.basicDataCollectionPage.index) {
    return localizedStrings.gTipBasicDataPageHelp;
  }
  // else if (pageId == MenuId.parameterSettingPage.index) {
  //   return localizedStrings.gTipParameterSettingPageHelp;
  // }
  else if (pageId == MenuId.pluEditPage.index) {
    return localizedStrings.gTipPlueditPageHelp;
  } else if (pageId == MenuId.downloadLabelPage.index) {
    return localizedStrings.gTipLabelFmtDownPageHelp;
  } else if (pageId == MenuId.downReciptPage.index) {
    return localizedStrings.gTipReceiptFmtDownPageHelp;
  } else if (pageId == MenuId.appLabelDesignPage.index) {
    return localizedStrings.gTipLabelDesignPageHelp;
  } else if (pageId == MenuId.appRcpDesignPage.index) {
    return localizedStrings.gTipReceiptDesignPageHelp;
  }
  return '';
}

List<int> allPaidAppMenu = [
  MenuId.weightDataCollectionPage.index,
  MenuId.checkWeighersPage.index,
  MenuId.takeInPage.index,
  MenuId.takeOutPage.index,
  MenuId.appLabelDesignPage.index,
  MenuId.appRcpDesignPage.index,
  MenuId.formulationScalePage.index,
  MenuId.flowRatePage.index,
];

List<RouteData> getAllAppsMenus() {
  return [
    RouteData(
      id: MenuId.weightModePage.index,
      title: localizedStrings.menuWeighing,
      routeName: "/weightMode",
      subtitle: localizedStrings.subTitleWeighing,
      iconPath: weighingSvgIcon(),
    ),
    RouteData(
        id: MenuId.retailReportPage.index,
        title: localizedStrings.menuRetailReport,
        routeName: "/retailReport",
        subtitle: localizedStrings.subTitleRetailReport,
        iconPath: detailReportSvgIcon()),
    RouteData(
        id: MenuId.weightDataCollectionPage.index,
        title: localizedStrings.menuWeighingDataCollection,
        routeName: "/weightDataCollection",
        subtitle: localizedStrings.subTitleWeighingDataCollection,
        iconPath: wgtCollectionSvgIcon()),
    RouteData(
        id: MenuId.checkWeighersPage.index,
        title: localizedStrings.menuCheckWeighing,
        routeName: "/checkWeighing",
        subtitle: localizedStrings.subTitleCheckWeighing,
        iconPath: checkScaleSvgIcon()),
    RouteData(
        id: MenuId.takeInPage.index,
        title: localizedStrings.menuIncrementWeighing,
        routeName: "/takeIn",
        subtitle: localizedStrings.subTitleIncrementWeighing,
        iconPath: takeInSvgIcon()),
    RouteData(
      id: MenuId.takeOutPage.index,
      title: localizedStrings.menuTakeOutScale,
      routeName: "/takeOut",
      subtitle: localizedStrings.subTitleTakeOutScale,
      iconPath: takeOutSvgIcon(),
    ),
    RouteData(
        id: MenuId.formulationScalePage.index,
        title: localizedStrings.menuFormula,
        routeName: "/formulationScale",
        subtitle: localizedStrings.subTitleFormula,
        iconPath: firmwareSvgIcon()),
    RouteData(
        id: MenuId.flowRatePage.index,
        title: localizedStrings.menuFlowRate,
        routeName: "/flowRate",
        subtitle: localizedStrings.subTitleFlowRate,
        iconPath: rateSpeedSvgIcon()),
    RouteData(
      id: MenuId.appLabelDesignPage.index,
      title: localizedStrings.menuLabelDesign,
      routeName: "/labelDesign",
      subtitle: localizedStrings.subTitleLabelDesign,
      iconPath: labelDesignSvgIcon(),
    ),
    RouteData(
      id: MenuId.appRcpDesignPage.index,
      title: localizedStrings.menuReceiptDesign,
      routeName: "/receiptDesign",
      subtitle: localizedStrings.subTitleReceiptDesign,
      iconPath: reciptDesignSvgIcon(),
    ),
  ];
}

bool getUserPermission(int id) {
  if (mySysUser.roleId == adminRoleId || mySysUser.roleId == superAdminRoleId) {
    return true;
  }
  if (mySysUser.pageIdList!.isEmpty) {
    return false;
  }
  if (mySysUser.pageIdList!.contains(id)) {
    return true;
  }
  return false;
}

bool getIsAppCertified(int id) {
  if (id == MenuId.weightDataCollectionPage.index) {
    return myWedaLicInfo.isValid;
  } else if (id == MenuId.checkWeighersPage.index) {
    return myChweLicInfo.isValid;
  } else if (id == MenuId.takeInPage.index) {
    return myInWeLicInfo.isValid;
  } else if (id == MenuId.takeOutPage.index) {
    return myTaouLicInfo.isValid;
  } else if (id == MenuId.formulationScalePage.index) {
    return myFoScLicInfo.isValid;
  } else if (id == MenuId.flowRatePage.index) {
    return myFaSpInfo.isValid;
  } else if (id == MenuId.labelDesignPage.index) {
    return myLadeLicInfo.isValid;
  } else if (id == MenuId.receiptDesignPage.index) {
    return myRedeLicInfo.isValid;
  } else if (id == MenuId.appLabelDesignPage.index) {
    return myLadeLicInfo.isValid;
  } else if (id == MenuId.appRcpDesignPage.index) {
    return myRedeLicInfo.isValid;
  }

  return false;
}

bool isFreeConfig(int pId) => freeConfigMenuIds.contains(pId);

bool isFreeApp(int pId) => freeAppMenuIds.contains(pId);

Widget buildPageContent(dynamic Function(String) navigateContent,
    String? pageName, String? lastRouteName) {
  // if (pageName == '/settingsApps') {
  //   return AppsPage(onNavigate: navigateContent, lastRouteName: lastRouteName!);
  // }
  if (pageName == '/settingsConfig') {
    return ConfigurationPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName!);
  }
  if (pageName == '/settingsUser') {
    return SysUserManagerPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName!);
  }

  // if (pageName == '/settingsAppsSetting') {
  //   return AppsSettingPage(
  //       onNavigate: navigateContent, lastRouteName: lastRouteName!);
  // }

  int pageId = 9999;
  for (var item in getAllConfigMenus()) {
    if (item.routeName == pageName) {
      pageId = item.id;
      break;
    }
  }
  if (pageId == 9999) {
    for (var item in getAllAppsMenus()) {
      if (item.routeName == pageName) {
        pageId = item.id;
        break;
      }
    }
  }
  if (pageId == 9999) {
    return Container();
  }

  if (pageId == MenuId.multiScaleManagement.index) {
    return MultiScaleManagement();
  } else if (pageId == MenuId.setSystemTimePage.index) {
    return SetSystemTimePage();
  } else if (pageId == MenuId.wifiSettingPage.index) {
    return WifiSettingPage();
  } else if (pageId == MenuId.btSettingPage.index) {
    return BluetoothPage();
  } else if (pageId == MenuId.updateFirmwarePage.index) {
    return UpdateFirmwarePage();
  } else if (pageId == MenuId.labelDesignPage.index) {
    return LabelDesignPage(
      type: "config",
    );
  } else if (pageId == MenuId.receiptDesignPage.index) {
    return ReceiptDesignPage(type: "config");
  } else if (pageId == MenuId.serialOutputDesignPage.index) {
    return CustomSerialProtocol();
  } else if (pageId == MenuId.basicDataCollectionPage.index) {
    return BasicDataPage();
  }
  //  else if (pageId == MenuId.parameterSettingPage.index) {
  //   return SetParameterPage();
  // }
  else if (pageId == MenuId.weightModePage.index) {
    return WeightModePage();
  } else if (pageId == MenuId.pluEditPage.index) {
    return PluEidtPage();
  } else if (pageId == MenuId.downloadLabelPage.index) {
    return DownloadLabelPage();
  } else if (pageId == MenuId.downReciptPage.index) {
    return DownReciptPage();
  } else if (pageId == MenuId.retailReportPage.index) {
    return RetailReportPage();
  } else if (pageId == MenuId.weightDataCollectionPage.index) {
    return WeightDataCollectionPage();
  } else if (pageId == MenuId.checkWeighersPage.index) {
    return CheckWeighersPage();
  } else if (pageId == MenuId.takeInPage.index) {
    return TakeInPage();
  } else if (pageId == MenuId.takeOutPage.index) {
    return TakeOutPage();
  } else if (pageId == MenuId.formulationScalePage.index) {
    return FormulationScalePage();
  } else if (pageId == MenuId.flowRatePage.index) {
    return FlowRatePage();
  } else if (pageId == MenuId.multiScaleManagement.index) {
    return MultiScaleManagement();
  } else if (pageId == MenuId.calibrationPage.index) {
    return CalibrationPage();
  }
  return Container();
}

String getRoutePath(int pageId) {
  for (var item in getAllConfigMenus()) {
    if (item.id == pageId) {
      return item.routeName!;
    }
  }
  for (var item in getAllAppsMenus()) {
    if (item.id == pageId) {
      return item.routeName!;
    }
  }
  return "";
}

void goAppPage(RouteData appRoute, BuildContext context,
    dynamic Function(String) navigateContent) {
  if (appRoute.id == MenuId.formulationScalePage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormulationScalePage()),
    );
  } else if (appRoute.id == MenuId.weightModePage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeightModePage()),
    );
  } else if (appRoute.id == MenuId.appLabelDesignPage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const LabelDesignPage(type: "app")),
    );
  } else if (appRoute.id == MenuId.appRcpDesignPage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ReceiptDesignPage(type: "app")),
    );
  } else if (appRoute.id == MenuId.retailReportPage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RetailReportPage()),
    );
  } else if (appRoute.id == MenuId.weightDataCollectionPage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeightDataCollectionPage()),
    );
  } else if (appRoute.id == MenuId.checkWeighersPage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckWeighersPage()),
    );
  } else if (appRoute.id == MenuId.takeInPage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TakeInPage()),
    );
  } else if (appRoute.id == MenuId.takeOutPage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TakeOutPage()),
    );
  } else if (appRoute.id == MenuId.flowRatePage.index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FlowRatePage()),
    );
  } else {
    navigateContent(appRoute.routeName!);
  }
  return;
}

//配置页面的功能要分类
//一级标题multi Scale Management 包含的页面为MenuId.multiScaleManagement.index 没有二级标题

//一级标题Setting 包含的二级标题为
//MenuId.setSystemTimePage.index,
//MenuId.btSettingPage.index,
//MenuId.wifiSettingPage.index,
//MenuId.updateFirmwarePage.index
//MenuId.updateFirmwarePage.index,

//一级标题Format 包含的二级标题为
//MenuId.labelDesignPage.index,
//MenuId.receiptDesignPage.index,
//MenuId.serialOutputDesignPage.index,
//MenuId.downloadLabelPage.index,
// MenuId.downReciptPage.index,

//一级标题Basic Data 包含的二级标题为
//MenuId.basicDataCollectionPage.index,
// MenuId.pluEditPage.index,

class RouteDataGroup {
  final String title;
  final List<dynamic> children; // 可以包含RouteData或RouteDataGroup
  bool isExpanded; // 控制展开/收起状态
  final String iconPath;

  RouteDataGroup({
    required this.title,
    required this.children,
    this.isExpanded = false,
    this.iconPath = '',
  });
}

// 添加新的获取层级菜单方法
List<RouteDataGroup> getHierarchicalConfigMenus() {
  // 获取原始权限过滤后的菜单列表
  final originalMenus = getCurrentConfigMenus();

  return [
    // 多秤管理组
    RouteDataGroup(
      title: localizedStrings.menuMultiScaleManagement,
      iconPath: multiScaleSvgIcon(),
      children: [
        // 使用firstWhereOrNull避免找不到时抛出异常
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.multiScaleManagement.index)
      ]
          // 过滤空值
          .whereType<RouteData>()
          .toList(),
    ),

    // 设置组
    RouteDataGroup(
      title: localizedStrings.gBtnSetting,
      iconPath: settingSvgIcon(),
      children: [
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.setSystemTimePage.index),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.wifiSettingPage.index),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.btSettingPage.index),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.updateFirmwarePage.index),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.calibrationPage.index),
      ].whereType<RouteData>().toList(),
    ),

    // 格式组
    RouteDataGroup(
      title: localizedStrings.menuFormat,
      iconPath: formatTitleSvgIcon(),
      children: [
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.labelDesignPage.index),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.receiptDesignPage.index),
        originalMenus.firstWhereOrNull(
            (m) => m.id == MenuId.serialOutputDesignPage.index),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.downloadLabelPage.index),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.downReciptPage.index),
      ].whereType<RouteData>().toList(),
    ),

    // 基础数据组
    RouteDataGroup(
      title: localizedStrings.menuData,
      iconPath: basicDataTitleSvgIcon(),
      children: [
        originalMenus.firstWhereOrNull(
            (m) => m.id == MenuId.basicDataCollectionPage.index),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.pluEditPage.index),
      ].whereType<RouteData>().toList(),
    ),
  ];
}
