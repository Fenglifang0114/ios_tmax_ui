//配置app

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/parse_log.dart';

import 'package:t_max/data/routes_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/license_info.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import 'package:t_max/widget/show_license_res.dart';

class AppsSettingPage extends StatefulWidget {
  const AppsSettingPage({
    super.key,
  });

  @override
  State<AppsSettingPage> createState() => _AppsSettingPageState();
}

class _AppsSettingPageState extends State<AppsSettingPage> {
  // 模拟第二部分列表数据

  late List<RouteData> allAppsMenus = [];
  late List<RouteData> allConfigMenus = [];
  TextEditingController activationFileCtl = TextEditingController();
  List<String> licList = [];
  dynamic eventbus1;
  dynamic eventbus2;

  final TextEditingController pidCtl = TextEditingController();
  TextEditingController licCtl = TextEditingController();

  String pId = '';
  String dueDate = '';
  bool isPass = false;
  bool licenseKey = false;
  String moduleName = '';
  LicenseInfo newLicInfo = LicenseInfo(false, '', '', '');
  final double iconSize = 36;
  bool pressedConfig = true;
  final double minItemWidth = 410;
  final double spacing = 30;
  final double runSpacing = 20;
  final double minItemHeight = 210;
  final double freeAppHeight = 180;

  bool isFilePickerBusy = false;

  //做一个map 存放功能和激活的日期，描述

  ValueNotifier<Map<String, ShowAppActiveInfo>> mapActiveMenusRes =
      ValueNotifier({});

  @override
  void didChangeDependencies() {
    allAppsMenus = getAllAppsMenus();
    allConfigMenus = getAllConfigMenus();

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    eventbus1 = eventBus.on<EventCheckLicenseKey>().listen((event) {
      if (mounted) {
        setState(() {
          var jsonStr = event.obj;
          if (jsonStr.isNotEmpty) {
            List<String> strList = jsonStr.split(',');
            if (strList.length == 4) {
              if (strList[1] == 'true') {
                moduleName = strList[0];
                licenseKey = true;
                isPass = true;
                pId = strList[2]; // id
                dueDate = strList[3];
                newLicInfo.pId = pId;
                newLicInfo.liceseDate = dueDate;
                newLicInfo.moduleName = moduleName;
                newLicInfo.isValid = licenseKey;
              } else {
                licenseKey = false;
              }
            }
          }
          if (licenseKey) {
            findLicType(moduleName);
          } else {
            updateResCtl();
          }
        });
      }
    });
    eventbus2 = eventBus.on<EventRespUpdateLic>().listen((event) {
      if (mounted) {
        setState(() {
          var jsonStr = event.obj;
          if (jsonStr.isNotEmpty) {}
        });
        updateResCtl();
      }
    });
  }

  @override
  void dispose() {
    eventbus1.cancel();
    eventbus2.cancel();
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

  // 共用激活功能
  Future<void> commonActivateFunction() async {
    await validLicense();
    if (licList.isNotEmpty) {
      mapActiveMenusRes = ValueNotifier({});
      PublicFunctions.checkLicenseKey(licList[0]);
      activationFileCtl.text = "";
      showLicenseResDialog();
    }
  }

  //验证新日期是否可用，true 可用，直接更新，false 询问是否更新
  bool isLongerValidityPeriod(String oldLicenseDate, String newLicenseDate) {
    bool res = false;
    if (oldLicenseDate == '' && newLicenseDate != '') {
      return true;
    }
    if (oldLicenseDate != '' && newLicenseDate == '') {
      return false;
    }

    DateTime dateTimeOld = DateTime.parse(oldLicenseDate);
    DateTime dateTimeNew = DateTime.parse(newLicenseDate);

    if (dateTimeOld.isBefore(dateTimeNew)) {
      res = true;
    }
    return res;
  }

  void findLicType(String moduleNameStr) {
    switch (moduleNameStr) {
      case tConfigLic:
        if (newLicInfo.isValid) {
          if (isLongerValidityPeriod(myTConLicInfo.liceseDate, dueDate)) {
            myTConLicInfo = newLicInfo;
            updateLicenseInfo();

            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[tConfigLic] =
                  ShowAppActiveInfo(myTConLicInfo.liceseDate, "ok");
          } else {
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[tConfigLic] = ShowAppActiveInfo(myTConLicInfo.liceseDate,
                  localizedStrings.gTipDateNotUpdated);

            updateResCtl();
          }
        } else {
          mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
            ..[tConfigLic] =
                ShowAppActiveInfo(myTConLicInfo.liceseDate, "fail");

          myTConLicInfo = newLicInfo;
          updateLicenseInfo();
        }

        break;
      case redeLic:
        if (newLicInfo.isValid) {
          if (isLongerValidityPeriod(myRedeLicInfo.liceseDate, dueDate)) {
            myRedeLicInfo = newLicInfo;
            updateLicenseInfo();
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[redeLic] = ShowAppActiveInfo(myRedeLicInfo.liceseDate, "ok");
          } else {
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[redeLic] = ShowAppActiveInfo(myRedeLicInfo.liceseDate,
                  localizedStrings.gTipDateNotUpdated);

            updateResCtl();
          }
        } else {
          mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
            ..[redeLic] = ShowAppActiveInfo(myRedeLicInfo.liceseDate, "fail");
          myRedeLicInfo = newLicInfo;
          updateLicenseInfo();
        }

        break;
      case wedaLic:
        if (newLicInfo.isValid) {
          if (isLongerValidityPeriod(myWedaLicInfo.liceseDate, dueDate)) {
            myWedaLicInfo = newLicInfo;
            updateLicenseInfo();

            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[wedaLic] = ShowAppActiveInfo(myWedaLicInfo.liceseDate, "ok");
          } else {
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[wedaLic] = ShowAppActiveInfo(myWedaLicInfo.liceseDate,
                  localizedStrings.gTipDateNotUpdated);
            updateResCtl();
          }
        } else {
          myWedaLicInfo = newLicInfo;
          mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
            ..[wedaLic] = ShowAppActiveInfo(myWedaLicInfo.liceseDate, "fail");
          updateLicenseInfo();
        }

        break;
      case chweLic:
        if (newLicInfo.isValid) {
          if (isLongerValidityPeriod(myChweLicInfo.liceseDate, dueDate)) {
            myChweLicInfo = newLicInfo;
            updateLicenseInfo();

            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[chweLic] = ShowAppActiveInfo(myChweLicInfo.liceseDate, "ok");
          } else {
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[chweLic] = ShowAppActiveInfo(myChweLicInfo.liceseDate,
                  localizedStrings.gTipDateNotUpdated);

            updateResCtl();
          }
        } else {
          myChweLicInfo = newLicInfo;
          mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
            ..[chweLic] = ShowAppActiveInfo(myChweLicInfo.liceseDate, "fail");
          updateLicenseInfo();
        }

        break;
      case inweLic:
        if (newLicInfo.isValid) {
          if (isLongerValidityPeriod(myInWeLicInfo.liceseDate, dueDate)) {
            myInWeLicInfo = newLicInfo;
            updateLicenseInfo();
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[inweLic] = ShowAppActiveInfo(myInWeLicInfo.liceseDate, "ok");
          } else {
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[inweLic] = ShowAppActiveInfo(myInWeLicInfo.liceseDate,
                  localizedStrings.gTipDateNotUpdated);

            updateResCtl();
          }
        } else {
          myInWeLicInfo = newLicInfo;
          mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
            ..[inweLic] = ShowAppActiveInfo(myInWeLicInfo.liceseDate, "fail");
          updateLicenseInfo();
        }

        break;
      case taouLic:
        if (newLicInfo.isValid) {
          if (isLongerValidityPeriod(myTaouLicInfo.liceseDate, dueDate)) {
            myTaouLicInfo = newLicInfo;
            updateLicenseInfo();
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[taouLic] = ShowAppActiveInfo(myTaouLicInfo.liceseDate, "ok");
          } else {
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[taouLic] = ShowAppActiveInfo(myTaouLicInfo.liceseDate,
                  localizedStrings.gTipDateNotUpdated);

            updateResCtl();
          }
        } else {
          myTaouLicInfo = newLicInfo;
          mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
            ..[taouLic] = ShowAppActiveInfo(myTaouLicInfo.liceseDate, "fail");
          updateLicenseInfo();
        }
        break;
      case faspLic:
        if (newLicInfo.isValid) {
          if (isLongerValidityPeriod(myFaSpInfo.liceseDate, dueDate)) {
            myFaSpInfo = newLicInfo;
            updateLicenseInfo();
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[faspLic] = ShowAppActiveInfo(myFaSpInfo.liceseDate, "ok");
          } else {
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[faspLic] = ShowAppActiveInfo(
                  myFaSpInfo.liceseDate, localizedStrings.gTipDateNotUpdated);

            updateResCtl();
          }
        } else {
          myFaSpInfo = newLicInfo;
          mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
            ..[faspLic] = ShowAppActiveInfo(myFaSpInfo.liceseDate, "fail");
          updateLicenseInfo();
        }
        break;
      case foscLic:
        if (newLicInfo.isValid) {
          if (isLongerValidityPeriod(myFoScLicInfo.liceseDate, dueDate)) {
            myFoScLicInfo = newLicInfo;
            updateLicenseInfo();
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[foscLic] = ShowAppActiveInfo(myFoScLicInfo.liceseDate, "ok");
          } else {
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[foscLic] = ShowAppActiveInfo(myFoScLicInfo.liceseDate,
                  localizedStrings.gTipDateNotUpdated);

            updateResCtl();
          }
        } else {
          myFoScLicInfo = newLicInfo;
          mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
            ..[foscLic] = ShowAppActiveInfo(myFoScLicInfo.liceseDate, "fail");
          updateLicenseInfo();
        }
        break;
      case ladeLic:
        if (newLicInfo.isValid) {
          if (isLongerValidityPeriod(myLadeLicInfo.liceseDate, dueDate)) {
            myLadeLicInfo = newLicInfo;
            updateLicenseInfo();
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[ladeLic] = ShowAppActiveInfo(myLadeLicInfo.liceseDate, "ok");
          } else {
            mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
              ..[ladeLic] = ShowAppActiveInfo(myLadeLicInfo.liceseDate,
                  localizedStrings.gTipDateNotUpdated);

            updateResCtl();
          }
        } else {
          myLadeLicInfo = newLicInfo;
          mapActiveMenusRes.value = Map.from(mapActiveMenusRes.value)
            ..[ladeLic] = ShowAppActiveInfo(myLadeLicInfo.liceseDate, "fail");
          updateLicenseInfo();
        }
        break;

      default:
        break;
    }
  }

  Widget buildConfigInfo(BuildContext context, int id) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (allConfigMenus.isEmpty) return SizedBox();

    bool isConfigCertified = myTConLicInfo.isValid;
    bool isAdded = getIsAddedConfig(id);
    bool isFreed = isFreeConfig(id);
    RouteData tempApp =
        allConfigMenus.firstWhere((element) => element.id == id);

    return Container(
      decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            width: 1,
            color: colorScheme.surfaceContainerLow,
          )),
      padding: const EdgeInsets.all(regularPadding),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 使用 ConstrainedBox 限制按钮的最大宽度为 300
                getSvgIcon(tempApp.iconPath, iconSize, iconSize,
                    Theme.of(context).colorScheme.primary),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 使用 ConstrainedBox 限制按钮的最大宽度为 300
                      SizedBox(
                        child: IconButton(
                            iconSize: 36,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(getConfigSwithState(id)
                                ? Icons.toggle_on_outlined
                                : Icons.toggle_off_outlined),
                            color: getConfigSwithState(id)
                                ? Theme.of(context)
                                    .colorScheme
                                    .onTertiaryFixedVariant
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            onPressed: (isFreeConfig(id))
                                ? () {
                                    if (!isAdded) {
                                      addSelectConfig(id);
                                    } else {
                                      removeSelectConfig(id);
                                    }
                                  }
                                : (isConfigCertified)
                                    ? () {
                                        if (!isAdded) {
                                          addSelectConfig(id);
                                        } else {
                                          removeSelectConfig(id);
                                        }
                                      }
                                    : null),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: smallPadding,
          ),
          SizedBox(
            height: 30,
            child: Row(
              children: [
                // 使用 Expanded 组件让前面的文本自适应空间
                Expanded(
                  child: RichText(
                    maxLines: 1, // 限制最多显示 1 行
                    text: TextSpan(
                      text: tempApp.title,
                      style: textTheme.labelMedium!
                          .apply(color: colorScheme.onSurface),
                    ),
                    overflow: TextOverflow.ellipsis, // 超出部分用省略号表示
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: smallPadding,
          ),
          Container(
            height: 60,
            alignment: Alignment.topLeft,
            child: Text(
              tempApp.subtitle,
              maxLines: 3,
              textAlign: TextAlign.left,
              style: textTheme.bodySmall!
                  .apply(color: colorScheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isFreed) Spacer(),
          if (!isFreed)
            Container(
              alignment: Alignment.centerLeft,
              height: 30,
              child: Text(
                isConfigCertified
                    ? localizedStrings.gTipActivated
                    : localizedStrings.gTipUnactivated,
                style: textTheme.bodySmall!.apply(
                    color: isConfigCertified
                        ? colorScheme.onTertiaryFixedVariant
                        : colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  void updateLicenseInfo() {
    PublicFunctions.updateLicense(licList[0]);
  }

  bool getIsAddedConfig(int id) {
    return selectedConfigPaidMenuIds.contains(id);
  }

  bool getIsAddedApp(int id) {
    return selectedAppsPaidMenuIds.contains(id);
  }

  bool getConfigSwithState(int id) {
    bool isAdded = getIsAddedConfig(id);
    bool isConfigCertified = myTConLicInfo.isValid;
    if (isFreeConfig(id) && !isAdded) {
      return false;
    }
    if (isFreeConfig(id) && isAdded) {
      return true;
    }

    if (isConfigCertified && isAdded) {
      return true;
    }

    if (isConfigCertified && !isAdded) {
      return false;
    }

    return false;
  }

  bool getAppSwithState(int id) {
    bool isAdded = getIsAddedApp(id);
    bool isConfigCertified = getIsConfigCertified(id);
    if (isFreeApp(id) && !isAdded) {
      return false;
    }
    if (isFreeApp(id) && isAdded) {
      return true;
    }

    if (isConfigCertified && isAdded) {
      return true;
    }

    if (isConfigCertified && !isAdded) {
      return false;
    }

    return false;
  }

  Widget buildAppInfo(BuildContext context, int id) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (allAppsMenus.isEmpty) return SizedBox();

    bool isConfigCertified = getIsConfigCertified(id);
    bool isAdded = getIsAddedApp(id);
    bool isFreed = isFreeApp(id);
    RouteData tempApp = allAppsMenus.firstWhere((element) => element.id == id);

    return Container(
      decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            width: 1,
            color: colorScheme.surfaceContainerLow,
          )),
      padding: const EdgeInsets.all(regularPadding),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 使用 ConstrainedBox 限制按钮的最大宽度为 300
                getSvgIcon(tempApp.iconPath, iconSize, iconSize,
                    Theme.of(context).colorScheme.primary),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 使用 ConstrainedBox 限制按钮的最大宽度为 300
                      SizedBox(
                        child: IconButton(
                          iconSize: 36,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(getAppSwithState(id)
                              ? Icons.toggle_on_outlined
                              : Icons.toggle_off_outlined),
                          color: getAppSwithState(id)
                              ? Theme.of(context)
                                  .colorScheme
                                  .onTertiaryFixedVariant
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          onPressed: isFreeApp(id)
                              ? () {
                                  if (!isAdded) {
                                    addSelectApp(id);
                                  } else {
                                    removeSelectApp(id);
                                  }
                                }
                              : isConfigCertified
                                  ? () {
                                      if (!isAdded) {
                                        addSelectApp(id);
                                      } else {
                                        removeSelectApp(id);
                                      }
                                    }
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: smallPadding,
          ),
          SizedBox(
            height: 30,
            child: Row(
              children: [
                // 使用 Expanded 组件让前面的文本自适应空间
                Expanded(
                  child: RichText(
                    maxLines: 1, // 限制最多显示 1 行
                    text: TextSpan(
                      text: tempApp.title,
                      style: textTheme.labelMedium!
                          .apply(color: colorScheme.onSurface),
                    ),
                    overflow: TextOverflow.ellipsis, // 超出部分用省略号表示
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: smallPadding,
          ),
          Container(
            height: 60,
            alignment: Alignment.topLeft,
            child: Text(
              tempApp.subtitle,
              maxLines: 3,
              textAlign: TextAlign.left,
              style: textTheme.bodySmall!
                  .apply(color: colorScheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isFreed) Spacer(),
          if (!isFreed)
            Container(
              alignment: Alignment.centerLeft,
              height: 30,
              child: Text(
                isConfigCertified
                    ? localizedStrings.gTipActivated
                    : localizedStrings.gTipUnactivated,
                style: textTheme.bodySmall!.apply(
                    color: isConfigCertified
                        ? colorScheme.onTertiaryFixedVariant
                        : colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  void addSelectConfig(int id) {
    setState(() {
      selectedConfigPaidMenuIds.add(id);
    });
    writePageIdsToJson(
        selectedConfigPaidMenuIds, selectedAppsPaidMenuIds, '/settingsConfig');
  }

  void removeSelectConfig(int id) {
    setState(() {
      selectedConfigPaidMenuIds.remove(id);
    });
    writePageIdsToJson(
        selectedConfigPaidMenuIds, selectedAppsPaidMenuIds, '/settingsConfig');
  }

  void addSelectApp(int id) {
    setState(() {
      selectedAppsPaidMenuIds.add(id);
    });
    writePageIdsToJson(
        selectedConfigPaidMenuIds, selectedAppsPaidMenuIds, '/settingsConfig');
  }

  void removeSelectApp(int id) {
    setState(() {
      selectedAppsPaidMenuIds.remove(id);
    });
    writePageIdsToJson(
        selectedConfigPaidMenuIds, selectedAppsPaidMenuIds, '/settingsConfig');
  }

  // 显示激活弹框，在弹框内选择文件
  Future<void> showActivateDialog() async {
    final BuildContext dialogContext = context; // 保存上下文，避免异步问题
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 638,
                height: 388,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Column(
                  children: [
                    ...dialogHeadStyle(
                        context, localizedStrings.gBtnActivate, true,
                        onClose: () {
                      activationFileCtl.text = '';
                      Navigator.pop(context);
                    }),
                    Expanded(
                      flex: 10,
                      child: Container(
                        padding: EdgeInsets.all(largePadding),
                        child: Column(children: [
                          Expanded(
                              child: Container(
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 400,
                                    child: showInputBox(
                                        activationFileCtl,
                                        localizedStrings
                                            .gTipSelectActivationFile),
                                  ),
                                  SizedBox(
                                    width: regularPadding,
                                  ),
                                  textBtn(context, colorScheme, textTheme,
                                      () async {
                                    // 开始选择文件时，将状态设置为忙碌
                                    if (isFilePickerBusy) {
                                      return;
                                    }
                                    isFilePickerBusy = true;

                                    String filePath = '';
                                    try {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['txt'],
                                      );
                                      if (result != null &&
                                          result.files.isNotEmpty) {
                                        filePath = result.files.single.path!;
                                      }
                                      setState(() {
                                        if (filePath != '') {
                                          activationFileCtl.text = filePath;
                                        }
                                      });
                                    } catch (e) {
                                      showTipInfo(
                                          localizedStrings.gTipFailToSelectFile,
                                          context);
                                    } finally {
                                      // 无论选择文件操作成功还是失败，都将状态设置为空闲
                                      setState(() {
                                        isFilePickerBusy = false;
                                      });
                                    }
                                  }, localizedStrings.gBtnSelectFile,
                                      inputHeight)
                                ]),
                          )),
                        ]),
                      ),
                    ),
                    Container(
                      height: bottomBtnHeight,
                      padding: const EdgeInsets.only(bottom: largePadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              constraints: const BoxConstraints(
                                maxWidth: 400,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  fixedSize:
                                      const Size(double.infinity, inputHeight),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                onPressed: activationFileCtl.text.isNotEmpty
                                    ? () {
                                        Navigator.pop(context);
                                        commonActivateFunction();
                                      }
                                    : null,
                                child: Text(
                                  localizedStrings.gBtnActivate,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                          SizedBox(width: 20),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 200,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                fixedSize:
                                    const Size(double.infinity, btnHeight),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () {
                                activationFileCtl.text = '';
                                Navigator.pop(context);
                              },
                              child: Text(
                                localizedStrings.gBtnCancel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget myPageHeadInfo(
      dynamic context, double maxWidth, String pageTitle, String helpInfo) {
    return Container(
        height: pageTopTitleHeight,
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                subTitle(context, maxWidth, pageTitle),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  const SizedBox(
                    width: largePadding,
                  ),
                  Row(children: [
                    Text(
                      localizedStrings.gSystemId + ": ",
                      style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SelectableText(
                      myLicenseInfo.pId,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .apply(color: Theme.of(context).colorScheme.primary),
                    ),
                  ]),
                  const SizedBox(
                    width: largePadding,
                  ),
                  textBtn(
                    context,
                    Theme.of(context).colorScheme,
                    Theme.of(context).textTheme,
                    showActivateDialog,
                    localizedStrings.gBtnActivate,
                    36,
                  ),
                  const SizedBox(
                    width: largePadding,
                  ),
                  // PageInfoButton(helpInfo: helpInfo, onRefresh: () {}),
                  const SizedBox(
                    width: largePadding,
                  ),
                ])
              ],
            ),
          ),
          Divider(
            color:
                Theme.of(context).colorScheme.surfaceContainerLow, // 设置分割线的颜色
            height: 1, // 设置分割线的高度
            thickness: 1, // 设置分割线的粗细
          ),
        ]));
  }

  Widget subTitle(
    dynamic context,
    double maxWidth,
    String pageTitle,
  ) {
    return Row(
      children: [
        SizedBox(
          width: largePadding,
        ),
        SizedBox(
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: getSvgIcon(returnSvgIcon(), 28, 28,
                  Theme.of(context).colorScheme.primary)),
        ),
        SizedBox(
          width: regularPadding,
        ),
        SizedBox(
          width: maxWidth,
          child: Text(
            pageTitle,
            style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    allAppsMenus = getAllAppsMenus();
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(children: [
        // 第一部分，固定高度 64
        myPageHeadInfo(
            context, width - 700, localizedStrings.gBtnConfigSetting, ''),
        Container(
          height: regularPadding,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        // 第二部分和第三部分按 13:10 比例分配剩余空间
        Expanded(
          child: Container(
              color: colorScheme.surface,
              child: Row(children: [
                Container(
                  width: 80,
                  padding: EdgeInsets.only(top: regularPadding),
                  color: colorScheme.surface,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 第一个图标按钮
                      Tooltip(
                        message: localizedStrings.menuConfiguration,
                        child: InkWell(
                          onTapUp: (_) {
                            setState(() {
                              pressedConfig = true; // 抬起时更新状态
                            });
                          },
                          onTapCancel: () {
                            setState(() {
                              pressedConfig = false; // 取消点击时更新状态
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            color: pressedConfig
                                ? colorScheme.primary
                                : colorScheme.surfaceDim,
                            child: Center(
                              child: getSvgIcon(
                                  configSettingSvgIcon(),
                                  22,
                                  22,
                                  pressedConfig
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // 按钮间距
                      // 第二个图标按钮
                      Tooltip(
                        message: localizedStrings.gTitleAppConfig,
                        child: InkWell(
                          onTapUp: (_) {
                            setState(() {
                              pressedConfig = false; // 抬起时更新状态
                            });
                          },
                          onTapCancel: () {
                            setState(() {
                              pressedConfig = true; // 取消点击时更新状态
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            color: !pressedConfig
                                ? colorScheme.primary
                                : colorScheme.surfaceDim,
                            child: Center(
                              child: getSvgIcon(
                                  appSettingSvgIcon(),
                                  22,
                                  22,
                                  !pressedConfig
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: regularPadding,
                  color: colorScheme.surfaceDim,
                ),
                if (pressedConfig) showConfigSettingWidget(),
                if (!pressedConfig) showAppSettingsWidget()
              ])),
        ),
      ]),
    );
  }

  Widget showConfigSettingWidget() {
    return Expanded(
        child: Container(
      padding: EdgeInsets.only(
          left: regularPadding, right: regularPadding, bottom: regularPadding),
      child: Column(children: [
        Container(
            height: 112,
            color: Theme.of(context).colorScheme.surface,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                height: btnHeight,
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Text(
                    localizedStrings.menuConfiguration,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .apply(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ]),
              ),
              Row(children: [
                Expanded(
                  child: SelectableText(
                    localizedStrings.gSubtitleConfigFunctionCharge,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                )
              ]),
            ])),
        Expanded(
            child: Container(
                padding: EdgeInsets.only(
                    left: regularPadding,
                    right: regularPadding,
                    bottom: regularPadding),
                child: ListView(
                  children: [
                    Container(
                      height: btnHeight,
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Text(
                          localizedStrings.gTipFreeConfiguration,
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ]),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // 计算可用高度
                        final availableWidth = constraints.maxWidth;
                        final itemWidth = calculateColumnCount(
                            availableWidth, minItemWidth, spacing);
                        // 过滤出免费的应用
                        final freeConfigMenus = allConfigMenus
                            .where(
                                (menu) => freeConfigMenuIds.contains(menu.id))
                            .toList();
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: spacing, // 元素间的水平间距
                            runSpacing: runSpacing, // 元素间的垂直间距

                            children: List.generate(
                              freeConfigMenus.length,
                              (index) {
                                return SizedBox(
                                  width: itemWidth,
                                  height: freeAppHeight, // 固定元素高度
                                  child: buildConfigInfo(
                                      context, freeConfigMenus[index].id),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: regularPadding,
                    ),
                    Container(
                      height: btnHeight,
                      alignment: Alignment.centerLeft,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizedStrings.gTipAdvancedConfiguration,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                            ),
                            if (myTConLicInfo.isValid)
                              Text(
                                ' ${localizedStrings.gExpirationDate}  :  ${myTConLicInfo.liceseDate} ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                              ),
                          ]),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // 计算可用高度
                        final availableWidth = constraints.maxWidth;
                        final itemWidth = calculateColumnCount(
                            availableWidth, minItemWidth, spacing);
                        // 过滤出免费的应用
                        final paidConfigMenus = allConfigMenus
                            .where(
                                (menu) => paidConfigMenuIds.contains(menu.id))
                            .toList();
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: spacing, // 元素间的水平间距
                            runSpacing: runSpacing, // 元素间的垂直间距

                            children: List.generate(
                              paidConfigMenus.length,
                              (index) {
                                return SizedBox(
                                  width: itemWidth,
                                  height: minItemHeight, // 固定元素高度
                                  child: buildConfigInfo(
                                      context, paidConfigMenus[index].id),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ))),
      ]),
    ));
  }

  Widget showAppSettingsWidget() {
    return Expanded(
        child: Container(
      padding: EdgeInsets.only(
          left: regularPadding, right: regularPadding, bottom: regularPadding),
      child: Column(children: [
        Container(
            height: 112,
            color: Theme.of(context).colorScheme.surface,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                height: btnHeight,
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Text(
                    localizedStrings.gTitleAppConfig,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .apply(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ]),
              ),
              Row(children: [
                Expanded(
                  child: SelectableText(
                    localizedStrings.gSubtitleAppsCharge,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                )
              ]),
            ])),
        Divider(height: 1, color: Theme.of(context).colorScheme.surfaceDim),
        SizedBox(
          height: regularPadding,
        ),
        Expanded(
            child: Container(
                padding: EdgeInsets.only(
                    left: regularPadding,
                    right: regularPadding,
                    bottom: regularPadding),
                child: ListView(
                  children: [
                    Container(
                      height: btnHeight,
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Text(
                          localizedStrings.gTipFreeApplications,
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ]),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // 计算可用高度
                        final availableWidth = constraints.maxWidth;
                        final itemWidth = calculateColumnCount(
                            availableWidth, minItemWidth, spacing);
                        // 过滤出免费的应用
                        final freeAppsMenus = allAppsMenus
                            .where((menu) => freeAppMenuIds.contains(menu.id))
                            .toList();
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: spacing, // 元素间的水平间距
                            runSpacing: runSpacing, // 元素间的垂直间距

                            children: List.generate(
                              freeAppsMenus.length,
                              (index) {
                                return SizedBox(
                                  width: itemWidth,
                                  height: freeAppHeight, // 固定元素高度
                                  child: buildAppInfo(
                                      context, freeAppsMenus[index].id),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: regularPadding,
                    ),
                    Container(
                      height: btnHeight,
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Text(
                          localizedStrings.gTipRetailApplications,
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ]),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // 计算可用高度

                        final availableWidth = constraints.maxWidth;

                        final itemWidth = calculateColumnCount(
                            availableWidth, minItemWidth, spacing);

                        final retailAppsMenus = allAppsMenus
                            .where((menu) => retailAppMenuIds.contains(menu.id))
                            .toList();
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: spacing, // 元素间的水平间距
                            runSpacing: runSpacing, // 元素间的垂直间距
                            children: List.generate(
                              retailAppsMenus.length,
                              (index) {
                                return SizedBox(
                                  width: itemWidth,
                                  height: minItemHeight, // 固定元素高度
                                  child: buildAppInfo(
                                      context, retailAppsMenus[index].id),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: regularPadding,
                    ),
                    Container(
                      height: btnHeight,
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Text(
                          localizedStrings.gTipIndustrialApplications,
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ]),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // 计算可用高度
                        final availableWidth = constraints.maxWidth;

                        final itemWidth = calculateColumnCount(
                            availableWidth, minItemWidth, spacing);

                        final industrialAppsMenus = allAppsMenus
                            .where((menu) =>
                                industrialAppMenuIds.contains(menu.id))
                            .toList();
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: spacing, // 元素间的水平间距
                            runSpacing: runSpacing, // 元素间的垂直间距
                            children: List.generate(
                              industrialAppsMenus.length,
                              (index) {
                                return SizedBox(
                                  width: itemWidth,
                                  height: minItemHeight, // 固定元素高度
                                  child: buildAppInfo(
                                      context, industrialAppsMenus[index].id),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ))),
      ]),
    ));
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
        return ShowLicenseResDialog(
          mapActiveMenusRes: mapActiveMenusRes,
        );
      },
    ).then((value) {
      setState(() {});
    });
  }

  Widget textBtn(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    VoidCallback? func,
    String name,
    double height,
  ) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          fixedSize: Size(double.infinity, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        onPressed: func,
        child: Text(
          name,
          style: Theme.of(context).textTheme.bodySmall!.apply(
              color: func == null
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.onPrimary),
          overflow: TextOverflow.ellipsis,
        ));
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
          if (licList[i].length == 74 || licList[i].length == 78) {
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
