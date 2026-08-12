//所有的路由
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/labeldesign/label_design_page.dart';
import 'package:t_max/pages/apps_setting_page.dart';
import 'package:t_max/pages/basic_data_page.dart';
import 'package:t_max/pages/blue_tooth_setting_page.dart';
import 'package:t_max/pages/calibration_page.dart';
import 'package:t_max/pages/calibration_seal_page.dart';
import 'package:t_max/pages/check_weighers_page.dart';
import 'package:t_max/pages/configuration_center_page.dart';
import 'package:t_max/pages/serial_protocol_page.dart';
import 'package:t_max/pages/down_recipt_fmt_page.dart';
import 'package:t_max/pages/flow_rate_page.dart';
import 'package:t_max/pages/formula_scale_page.dart';
import 'package:t_max/pages/mobile_formula_scale_page.dart';
import 'package:t_max/pages/lable_down_prn_fmt_page.dart';
import 'package:t_max/pages/multi_scale_management_page.dart';
import 'package:t_max/pages/plu_edit_page.dart';
import 'package:t_max/pages/receipt_design_page.dart';
import 'package:t_max/pages/retail_report_page.dart';
import 'package:t_max/pages/set_system_time.dart';
import 'package:t_max/pages/sys_log_page.dart';
import 'package:t_max/pages/sys_user_manager.dart';
import 'package:t_max/pages/take_in_page.dart';
import 'package:t_max/pages/take_out_page.dart';
import 'package:t_max/pages/update_firmware_page.dart';
import 'package:t_max/pages/weighing.dart';
import 'package:t_max/pages/weight_collection_page.dart';
import 'package:t_max/pages/wifi_setting_page.dart';
import 'package:t_max/pages/wired_setting_page.dart';
import 'package:t_max/pages/mobile_setting_page.dart';
import 'package:t_max/pages/mobile_data_page.dart';
import 'package:t_max/pages/mobile_format_page.dart';
import 'package:t_max/pages/mobile_sys_log_page.dart';
import 'package:t_max/pages/mobile_sys_user_manager.dart';
import 'package:t_max/pages/mobile_serial_output_design_page.dart';
import 'package:t_max/pages/mobile_receipt_design_page.dart';
import 'package:t_max/pages/mobile_weighing_data_collection_page.dart';
import 'package:t_max/pages/mobile_check_weighing_page.dart';
import 'package:t_max/pages/mobile_take_out_page.dart';
import 'package:t_max/pages/mobile_take_in_page.dart';
import 'package:t_max/pages/mobile_retail_report_page.dart';


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
  MenuId.labelDesignPage,
  MenuId.receiptDesignPage,
  MenuId.serialOutputDesignPage,
  MenuId.basicDataCollectionPage,
  // MenuId.parameterSettingPage,
  MenuId.sealManagmentPage,
];

List<RouteData> getApplication() {
  List<RouteData> application = [
    RouteData(
      id: MenuId.appConfigPage,
      title: (localizedStrings?.menuApplications ?? "menuApplications"),
      routeName: "/setConfig",
      subtitle: (localizedStrings?.menuApplications ?? "menuApplications"),
      iconPath: appSvgIcon(),
    ),
  ];
  return application;
}

List<RouteData> getAllConfigMenus() {
  List<RouteData> allConfigMenus = [
    RouteData(
      id: MenuId.multiScaleManagement,
      title: (localizedStrings?.menuMultiScaleManagement ??
          "menuMultiScaleManagement"),
      routeName: "/multiScaleManagement",
      subtitle: (localizedStrings?.subTitleMultiScaleManagement ??
          "subTitleMultiScaleManagement"),
      iconPath: multiScaleSvgIcon(),
    ),
    RouteData(
      id: MenuId.setSystemTimePage,
      title: (localizedStrings?.menuDeviceTime ?? "menuDeviceTime"),
      routeName: "/setSystemTime",
      subtitle: (localizedStrings?.subTitleDeviceTime ?? "subTitleDeviceTime"),
      iconPath: dateTimeSvgIcon(),
    ),
    RouteData(
      id: MenuId.btSettingPage,
      title: (localizedStrings?.menuBluetoothSetting ?? "menuBluetoothSetting"),
      routeName: "/btSetting",
      subtitle: (localizedStrings?.subTitleBluetoothSetting ??
          "subTitleBluetoothSetting"),
      iconPath: btSettingSvgIcon(),
    ),
    RouteData(
      id: MenuId.wifiSettingPage,
      title: (localizedStrings?.menuWifiSetting ?? "menuWifiSetting"),
      routeName: "/wifiSetting",
      subtitle:
          (localizedStrings?.subTitleWifiSetting ?? "subTitleWifiSetting"),
      iconPath: wifiSettingSvgIcon(),
    ),
    RouteData(
      id: MenuId.updateFirmwarePage,
      title: (localizedStrings?.menuFirmwareUpdate ?? "menuFirmwareUpdate"),
      routeName: "/updateFirmware",
      subtitle: (localizedStrings?.subTitleFirmwareUpdate ??
          "subTitleFirmwareUpdate"),
      iconPath: firmwareSvgIcon(),
    ),
    RouteData(
      id: MenuId.labelDesignPage,
      title: (localizedStrings?.menuLabelDesign ?? "menuLabelDesign"),
      routeName: "/labelDesign",
      subtitle:
          (localizedStrings?.subTitleLabelDesign ?? "subTitleLabelDesign"),
      iconPath: labelDesignSvgIcon(),
    ),
    RouteData(
      id: MenuId.receiptDesignPage,
      title: (localizedStrings?.menuReceiptDesign ?? "menuReceiptDesign"),
      routeName: "/receiptDesign",
      subtitle:
          (localizedStrings?.subTitleReceiptDesign ?? "subTitleReceiptDesign"),
      iconPath: reciptDesignSvgIcon(),
    ),
    RouteData(
      id: MenuId.serialOutputDesignPage,
      title: (localizedStrings?.menuSerialOutputDesign ??
          "menuSerialOutputDesign"),
      routeName: "/serialOutputDesign",
      subtitle: (localizedStrings?.subTitleSerialOutputDesign ??
          "subTitleSerialOutputDesign"),
      iconPath: serialSvgIcon(),
    ),
    RouteData(
      id: MenuId.basicDataCollectionPage,
      title: (localizedStrings?.menuBasicDataCollection ??
          "menuBasicDataCollection"),
      routeName: "/basicDataCollection",
      subtitle: (localizedStrings?.subTitleBasicDataCollection ??
          "subTitleBasicDataCollection"),
      iconPath: basicDataSvgIcon(),
    ),
    RouteData(
      id: MenuId.wiredSettingPage,
      title: (localizedStrings?.menuWiredSetting ?? "menuWiredSetting"),
      routeName: "/wiredSetting",
      subtitle:
          (localizedStrings?.subTitleWiredSetting ?? "subTitleWiredSetting"),
      iconPath: wiredSettingSvgIcon(),
    ),
    RouteData(
      id: MenuId.sealManagmentPage,
      title: (localizedStrings?.menuSealManagment ?? "menuSealManagment"),
      routeName: "/sealManagment",
      subtitle:
          (localizedStrings?.subTitleSealManagment ?? "subTitleSealManagment"),
      iconPath: sealManagmentSvgIcon(),
    ),

    // RouteData(
    //     id: MenuId.parameterSettingPage.index,
    //     title: (localizedStrings?.menuParameterSetting ?? "menuParameterSetting"),
    //     routeName: "/parameterSetting",
    //     subtitle: (localizedStrings?.subTitleParameterSetting ?? "subTitleParameterSetting"),
    //     iconPath: parameterSvgIcon()),
    RouteData(
        id: MenuId.calibrationPage,
        title: (localizedStrings?.menuWeighingSetting ?? "menuWeighingSetting"),
        routeName: "/calibration",
        subtitle:
            (localizedStrings?.subTitleCalibration ?? "subTitleCalibration"),
        iconPath: calibrationSvgIcon()),
    RouteData(
      id: MenuId.pluEditPage,
      title: (localizedStrings?.menuPluManagement ?? "menuPluManagement"),
      routeName: "/pluEdit",
      subtitle:
          (localizedStrings?.subTitlePluManagement ?? "subTitlePluManagement"),
      iconPath: pluEditSvgIcon(),
    ),
    RouteData(
        id: MenuId.downloadLabelPage,
        title: (localizedStrings?.menuLabelFormatDownload ??
            "menuLabelFormatDownload"),
        routeName: "/downloadLabel",
        subtitle: (localizedStrings?.subTitleLabelFormatDownload ??
            "subTitleLabelFormatDownload"),
        iconPath: labelDownloadSvgIcon()),
    RouteData(
        id: MenuId.downReciptPage,
        title: (localizedStrings?.menuReceiptFormatDownload ??
            "menuReceiptFormatDownload"),
        routeName: "/downRecipt",
        subtitle: (localizedStrings?.subTitleReceiptFormatDownload ??
            "subTitleReceiptFormatDownload"),
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
    } else if (myTConLicInfo.isValid &&
        selectedConfigPaidMenuIds.contains(menu.id) &&
        getUserPermission(menu.id)) {
      currentConfigMenus.add(menu);
    }
  }
// 多秤管理菜单要一直都在
  for (var menu in allConfigMenus) {
    if (menu.id == MenuId.multiScaleManagement &&
        !currentConfigMenus.contains(menu)) {
      currentConfigMenus.add(menu);
    }
  }

  return currentConfigMenus;
}

String generateTitle(int pageId) {
  if (pageId == MenuId.multiScaleManagement) {
    return (localizedStrings?.menuMultiScaleManagement ??
        "menuMultiScaleManagement");
  } else if (pageId == MenuId.setSystemTimePage) {
    return (localizedStrings?.menuDeviceTime ?? "menuDeviceTime");
  } else if (pageId == MenuId.btSettingPage) {
    return (localizedStrings?.menuBluetoothSetting ?? "menuBluetoothSetting");
  } else if (pageId == MenuId.wifiSettingPage) {
    return (localizedStrings?.menuWifiSetting ?? "menuWifiSetting");
  } else if (pageId == MenuId.updateFirmwarePage) {
    return (localizedStrings?.menuFirmwareUpdate ?? "menuFirmwareUpdate");
  } else if (pageId == MenuId.labelDesignPage) {
    return (localizedStrings?.menuLabelDesign ?? "menuLabelDesign");
  } else if (pageId == MenuId.receiptDesignPage) {
    return (localizedStrings?.menuReceiptDesign ?? "menuReceiptDesign");
  } else if (pageId == MenuId.serialOutputDesignPage) {
    return (localizedStrings?.menuSerialOutputDesign ??
        "menuSerialOutputDesign");
  } else if (pageId == MenuId.basicDataCollectionPage) {
    return (localizedStrings?.menuBasicDataCollection ??
        "menuBasicDataCollection");
  } else if (pageId == MenuId.sealManagmentPage) {
    return (localizedStrings?.menuSealManagment ?? "menuSealManagment");
  }

  // else if (pageId == MenuId.parameterSettingPage.index) {
  //   return (localizedStrings?.menuParameterSetting ?? "menuParameterSetting");
  // }
  else if (pageId == MenuId.weightModePage) {
    return (localizedStrings?.menuWeighing ?? "menuWeighing");
  } else if (pageId == MenuId.pluEditPage) {
    return (localizedStrings?.menuPluManagement ?? "menuPluManagement");
  } else if (pageId == MenuId.downloadLabelPage) {
    return (localizedStrings?.menuLabelFormatDownload ??
        "menuLabelFormatDownload");
  } else if (pageId == MenuId.downReciptPage) {
    return (localizedStrings?.menuReceiptFormatDownload ??
        "menuReceiptFormatDownload");
  } else if (pageId == MenuId.retailReportPage) {
    return (localizedStrings?.menuRetailReport ?? "menuRetailReport");
  } else if (pageId == MenuId.weightDataCollectionPage) {
    return (localizedStrings?.menuWeighingDataCollection ??
        "menuWeighingDataCollection");
  } else if (pageId == MenuId.checkWeighersPage) {
    return (localizedStrings?.menuCheckWeighing ?? "menuCheckWeighing");
  } else if (pageId == MenuId.takeInPage) {
    return (localizedStrings?.menuIncrementWeighing ?? "menuIncrementWeighing");
  } else if (pageId == MenuId.takeOutPage) {
    return (localizedStrings?.menuTakeOutScale ?? "menuTakeOutScale");
  } else if (pageId == MenuId.formulationScalePage) {
    return (localizedStrings?.menuFormula ?? "menuFormula");
  } else if (pageId == MenuId.flowRatePage) {
    return (localizedStrings?.menuFlowRate ?? "menuFlowRate");
  } else if (pageId == MenuId.calibrationPage) {
    return (localizedStrings?.menuWeighingSetting ?? "menuWeighingSetting");
  } else if (pageId == MenuId.appLabelDesignPage) {
    return (localizedStrings?.menuLabelDesign ?? "menuLabelDesign");
  } else if (pageId == MenuId.appRcpDesignPage) {
    return (localizedStrings?.menuReceiptDesign ?? "menuReceiptDesign");
  } else if (pageId == MenuId.wiredSettingPage) {
    return (localizedStrings?.menuWiredSetting ?? "menuWiredSetting");
  }

  if (pageId == MenuId.appConfigPage) {
    return (localizedStrings?.menuApplications ?? "menuApplications");
  }
  return '';
}

String generateHelpTitle(int pageId) {
  if (pageId == MenuId.multiScaleManagement) {
    return (localizedStrings?.gTipScaleMgrPageHelp ?? "gTipScaleMgrPageHelp");
  } else if (pageId == MenuId.setSystemTimePage) {
    return (localizedStrings?.gTipDeviceTimePageHelp ??
        "gTipDeviceTimePageHelp");
  } else if (pageId == MenuId.wifiSettingPage) {
    return (localizedStrings?.gTipWifiSettingPageHelp ??
        "gTipWifiSettingPageHelp");
  } else if (pageId == MenuId.updateFirmwarePage) {
    return (localizedStrings?.gTipUpdateFirmwarePageHelp ??
        "gTipUpdateFirmwarePageHelp");
  } else if (pageId == MenuId.labelDesignPage) {
    return (localizedStrings?.gTipLabelDesignPageHelp ??
        "gTipLabelDesignPageHelp");
  } else if (pageId == MenuId.receiptDesignPage) {
    return (localizedStrings?.gTipReceiptDesignPageHelp ??
        "gTipReceiptDesignPageHelp");
  } else if (pageId == MenuId.serialOutputDesignPage) {
    return (localizedStrings?.gTipSerialDesignPageHelp ??
        "gTipSerialDesignPageHelp");
  } else if (pageId == MenuId.basicDataCollectionPage) {
    return (localizedStrings?.gTipBasicDataPageHelp ?? "gTipBasicDataPageHelp");
  } else if (pageId == MenuId.pluEditPage) {
    return (localizedStrings?.gTipPlueditPageHelp ?? "gTipPlueditPageHelp");
  } else if (pageId == MenuId.downloadLabelPage) {
    return (localizedStrings?.gTipLabelFmtDownPageHelp ??
        "gTipLabelFmtDownPageHelp");
  } else if (pageId == MenuId.downReciptPage) {
    return (localizedStrings?.gTipReceiptFmtDownPageHelp ??
        "gTipReceiptFmtDownPageHelp");
  } else if (pageId == MenuId.appLabelDesignPage) {
    return (localizedStrings?.gTipLabelDesignPageHelp ??
        "gTipLabelDesignPageHelp");
  } else if (pageId == MenuId.appRcpDesignPage) {
    return (localizedStrings?.gTipReceiptDesignPageHelp ??
        "gTipReceiptDesignPageHelp");
  } else if (pageId == MenuId.wiredSettingPage) {
    return (localizedStrings?.menuWiredSetting ?? "menuWiredSetting");
  } else if (pageId == MenuId.sealManagmentPage) {
    return (localizedStrings?.menuSealManagment ?? "menuSealManagment");
  }

  return '';
}

List<int> allPaidAppMenu = [
  MenuId.weightDataCollectionPage,
  MenuId.checkWeighersPage,
  MenuId.takeInPage,
  MenuId.takeOutPage,
  MenuId.appLabelDesignPage,
  MenuId.appRcpDesignPage,
  MenuId.formulationScalePage,
  MenuId.flowRatePage,
];

List<RouteData> getAllAppsMenus() {
  List<RouteData> appsMenus = [
    RouteData(
      id: MenuId.weightModePage,
      title: (localizedStrings?.menuWeighing ?? "menuWeighing"),
      routeName: "/weightMode",
      subtitle: (localizedStrings?.subTitleWeighing ?? "subTitleWeighing"),
      iconPath: weighingSvgIcon(),
    ),
    RouteData(
        id: MenuId.retailReportPage,
        title: (localizedStrings?.menuRetailReport ?? "menuRetailReport"),
        routeName: "/retailReport",
        subtitle:
            (localizedStrings?.subTitleRetailReport ?? "subTitleRetailReport"),
        iconPath: detailReportSvgIcon()),
    RouteData(
        id: MenuId.weightDataCollectionPage,
        title: (localizedStrings?.menuWeighingDataCollection ??
            "menuWeighingDataCollection"),
        routeName: "/weightDataCollection",
        subtitle: (localizedStrings?.subTitleWeighingDataCollection ??
            "subTitleWeighingDataCollection"),
        iconPath: wgtCollectionSvgIcon()),
    RouteData(
        id: MenuId.checkWeighersPage,
        title: (localizedStrings?.menuCheckWeighing ?? "menuCheckWeighing"),
        routeName: "/checkWeighing",
        subtitle: (localizedStrings?.subTitleCheckWeighing ??
            "subTitleCheckWeighing"),
        iconPath: checkScaleSvgIcon()),
    RouteData(
        id: MenuId.takeInPage,
        title: (localizedStrings?.menuIncrementWeighing ??
            "menuIncrementWeighing"),
        routeName: "/takeIn",
        subtitle: (localizedStrings?.subTitleIncrementWeighing ??
            "subTitleIncrementWeighing"),
        iconPath: takeInSvgIcon()),
    RouteData(
      id: MenuId.takeOutPage,
      title: (localizedStrings?.menuTakeOutScale ?? "menuTakeOutScale"),
      routeName: "/takeOut",
      subtitle:
          (localizedStrings?.subTitleTakeOutScale ?? "subTitleTakeOutScale"),
      iconPath: takeOutSvgIcon(),
    ),
    RouteData(
        id: MenuId.formulationScalePage,
        title: (localizedStrings?.menuFormula ?? "menuFormula"),
        routeName: "/formulationScale",
        subtitle: (localizedStrings?.subTitleFormula ?? "subTitleFormula"),
        iconPath: firmwareSvgIcon()),
    RouteData(
        id: MenuId.flowRatePage,
        title: (localizedStrings?.menuFlowRate ?? "menuFlowRate"),
        routeName: "/flowRate",
        subtitle: (localizedStrings?.subTitleFlowRate ?? "subTitleFlowRate"),
        iconPath: rateSpeedSvgIcon()),
    RouteData(
      id: MenuId.appLabelDesignPage,
      title: (localizedStrings?.menuLabelDesign ?? "menuLabelDesign"),
      routeName: "/labelDesign",
      subtitle:
          (localizedStrings?.subTitleLabelDesign ?? "subTitleLabelDesign"),
      iconPath: labelDesignSvgIcon(),
    ),
    RouteData(
      id: MenuId.appRcpDesignPage,
      title: (localizedStrings?.menuReceiptDesign ?? "menuReceiptDesign"),
      routeName: "/receiptDesign",
      subtitle:
          (localizedStrings?.subTitleReceiptDesign ?? "subTitleReceiptDesign"),
      iconPath: reciptDesignSvgIcon(),
    ),
  ];

  if (Platform.isAndroid || Platform.isIOS) {
    appsMenus.removeWhere((menu) =>
        menu.id == MenuId.formulationScalePage ||
        menu.id == MenuId.flowRatePage ||
        menu.id == MenuId.appLabelDesignPage ||
        menu.id == MenuId.appRcpDesignPage);
  }

  return appsMenus;
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
  if (id == MenuId.weightDataCollectionPage) {
    return myWedaLicInfo.isValid;
  } else if (id == MenuId.checkWeighersPage) {
    return myChweLicInfo.isValid;
  } else if (id == MenuId.takeInPage) {
    return myInWeLicInfo.isValid;
  } else if (id == MenuId.takeOutPage) {
    return myTaouLicInfo.isValid;
  } else if (id == MenuId.formulationScalePage) {
    return myFoScLicInfo.isValid;
  } else if (id == MenuId.flowRatePage) {
    return myFaSpInfo.isValid;
  } else if (id == MenuId.labelDesignPage) {
    return myLadeLicInfo.isValid;
  } else if (id == MenuId.receiptDesignPage) {
    return myRedeLicInfo.isValid;
  } else if (id == MenuId.appLabelDesignPage) {
    return myLadeLicInfo.isValid;
  } else if (id == MenuId.appRcpDesignPage) {
    return myRedeLicInfo.isValid;
  }
  return false;
}

bool isFreeConfig(int pId) => freeConfigMenuIds.contains(pId);

bool isFreeApp(int pId) => freeAppMenuIds.contains(pId);

Widget buildPageContent(dynamic Function(String) navigateContent,
    String? pageName, String? lastRouteName) {
  lastRouteName ??= '/setConfig';
  if (pageName != null && pageName.contains('/settingsApp')) {
    pageName = pageName.replaceAll('/settingsApp', '');
  }
  if (pageName == '/setConfig') {
    return ConfigurationPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
  }
  if (pageName == '/settingsUser') {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileSysUserManagerPage(
          onNavigate: navigateContent, lastRouteName: lastRouteName);
    }
    return SysUserManagerPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
  }
  if (pageName == '/mobileSetting') {
    return MobileSettingPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
  }
  if (pageName == '/mobileData') {
    return MobileDataPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
  }
  if (pageName == '/mobileFormat') {
    return MobileFormatPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
  }
  if (pageName == '/settingsLog') {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileSysLogPage(
          onNavigate: navigateContent, lastRouteName: lastRouteName);
    }
    return SysLogPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
  }

  if (pageName == '/settingsFunction') {
    return AppsSettingPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
    // return ConfigurationPage(
    //     onNavigate: navigateContent, lastRouteName: lastRouteName!);
  }

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

  if (pageId == MenuId.multiScaleManagement) {
    return MultiScaleManagement();
  } else if (pageId == MenuId.setSystemTimePage) {
    return SetSystemTimePage();
  } else if (pageId == MenuId.wifiSettingPage) {
    return WifiSettingPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName ?? defualtSelectPage,
    );
  } else if (pageId == MenuId.wiredSettingPage) {
    return WiredSettingPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName ?? defualtSelectPage,
    );
  } else if (pageId == MenuId.btSettingPage) {
    return BluetoothPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName ?? defualtSelectPage,
    );
  } else if (pageId == MenuId.updateFirmwarePage) {
    return UpdateFirmwarePage();
  } else if (pageId == MenuId.labelDesignPage) {
    return LabelDesignPage(
      type: formAppSetting ? "app" : "config",
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.receiptDesignPage || pageId == MenuId.appRcpDesignPage) {
    if (Platform.isAndroid || Platform.isIOS) {
      return const MobileReceiptDesignPage();
    }
    return ReceiptDesignPage(
      type: formAppSetting ? "app" : "config",
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.serialOutputDesignPage) {
    if (Platform.isAndroid || Platform.isIOS) {
      return const MobileSerialOutputDesignPage();
    }
    return const CustomSerialProtocol();
  } else if (pageId == MenuId.basicDataCollectionPage) {
    return BasicDataPage();
  } else if (pageId == MenuId.sealManagmentPage) {
    return CalibrationSealPage();
  } else if (pageId == MenuId.sealManagmentPage) {
    return CalibrationSealPage();
  }

  //  else if (pageId == MenuId.parameterSettingPage.index) {
  //   return SetParameterPage();
  // }
  else if (pageId == MenuId.weightModePage) {
    return WeightModePage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.pluEditPage) {
    return PluEidtPage();
  } else if (pageId == MenuId.downloadLabelPage) {
    return DownloadLabelPage();
  } else if (pageId == MenuId.downReciptPage) {
    return DownReciptPage();
  } else if (pageId == MenuId.retailReportPage) {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileRetailReportPage(
        onNavigate: navigateContent,
        lastRouteName: lastRouteName,
      );
    }
    return RetailReportPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.weightDataCollectionPage) {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileWeighingDataCollectionPage(
        onNavigate: navigateContent,
        lastRouteName: lastRouteName,
      );
    }
    return WeightDataCollectionPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.checkWeighersPage) {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileCheckWeighingPage(
        onNavigate: navigateContent,
        lastRouteName: lastRouteName,
      );
    }
    return CheckWeighersPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.takeInPage) {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileTakeInPage(
        onNavigate: navigateContent,
        lastRouteName: lastRouteName,
      );
    }
    return TakeInPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.takeOutPage) {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileTakeOutPage(
        onNavigate: navigateContent,
        lastRouteName: lastRouteName,
      );
    }
    return TakeOutPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.formulationScalePage) {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileFormulaScalePage(
        onNavigate: navigateContent,
        lastRouteName: lastRouteName,
      );
    }
    return FormulationScalePage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.flowRatePage) {
    return FlowRatePage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.multiScaleManagement) {
    return MultiScaleManagement();
  } else if (pageId == MenuId.calibrationPage) {
    return CalibrationPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName ?? defualtSelectPage,
    );
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
  final appMemu = getApplication();

  bool hasS15 = myAllScalesList.any((scale) => scale.scaleModel == "S15");

  return [
    // 多秤管理组
    RouteDataGroup(
      title: (localizedStrings?.menuMultiScaleManagement ??
          "menuMultiScaleManagement"),
      iconPath: multiScaleSvgIcon(),
      children: [
        // 使用firstWhereOrNull避免找不到时抛出异常
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.multiScaleManagement)
      ]
          // 过滤空值
          .whereType<RouteData>()
          .toList(),
    ),

    // 设置组
    RouteDataGroup(
      title: (localizedStrings?.gBtnSetting ?? "gBtnSetting"),
      iconPath: settingSvgIcon(),
      children: [
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.setSystemTimePage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.wifiSettingPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.wiredSettingPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.btSettingPage),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.updateFirmwarePage),
        if (hasS15)
          originalMenus.firstWhereOrNull((m) => m.id == MenuId.calibrationPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.sealManagmentPage),
      ].whereType<RouteData>().toList(),
    ),

    // 格式组
    RouteDataGroup(
      title: (localizedStrings?.menuFormat ?? "menuFormat"),
      iconPath: formatTitleSvgIcon(),
      children: [
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.labelDesignPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.receiptDesignPage),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.serialOutputDesignPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.downloadLabelPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.downReciptPage),
      ].whereType<RouteData>().toList(),
    ),

    // 基础数据组
    RouteDataGroup(
      title: (localizedStrings?.menuData ?? "menuData"),
      iconPath: basicDataTitleSvgIcon(),
      children: [
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.basicDataCollectionPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.pluEditPage),
        appMemu.firstWhereOrNull((m) => m.id == MenuId.retailReportPage),
      ].whereType<RouteData>().toList(),
    ),
    // App管理组
    RouteDataGroup(
      title: (localizedStrings?.menuApplications ?? "menuApplications"),
      iconPath: appSvgIcon(),
      children: [
        // // 使用firstWhereOrNull避免找不到时抛出异常
        appMemu.firstWhereOrNull((m) => m.id == MenuId.appConfigPage)
      ]
          // 过滤空值
          .whereType<RouteData>()
          .toList(),
    ),
  ];
}
