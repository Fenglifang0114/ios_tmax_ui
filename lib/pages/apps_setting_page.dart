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
import 'package:t_max/dialog/app_common_data.dart';
import 'package:t_max/dialog/license_info.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/show_license_res.dart';

class AppsSettingPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const AppsSettingPage(
      {super.key, required this.onNavigate, required this.lastRouteName});

  @override
  State<AppsSettingPage> createState() => _AppsSettingPageState();
}

class _AppsSettingPageState extends State<AppsSettingPage> {
  // 模拟第二部分列表数据

  late List<RouteData> allAppsMenus = [];
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
  final double iconSize = 24;

  //做一个map 存放功能和激活的日期，描述

  ValueNotifier<Map<String, ShowAppActiveInfo>> mapActiveMenusRes =
      ValueNotifier({});

  @override
  void didChangeDependencies() {
    allAppsMenus = getAllAppsMenus();

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
      default:
        break;
    }
  }

  void updateLicenseInfo() {
    PublicFunctions.updateLicense(licList[0]);
  }

  bool getIsAddedApp(int id) {
    return selectedAppsPaidMenuIds.contains(id);
  }

  Widget buildAppInfo(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (allAppsMenus.isEmpty) return SizedBox();

    bool isConfigCertified = getIsConfigCertified(allAppsMenus[index].id);
    bool isAdded = getIsAddedApp(allAppsMenus[index].id);

    return Container(
      // 使用 withValues 替代 withOpacity
//加边框
      decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            width: 1,
            color: colorScheme.surfaceContainerLow,
          )),
      padding: const EdgeInsets.all(regularPadding),
      child: Column(
        children: [
          Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 使用 ConstrainedBox 限制按钮的最大宽度为 300
                getSvgIcon(allAppsMenus[index].iconPath, iconSize, iconSize,
                    Theme.of(context).colorScheme.primary),
                SizedBox(
                  width: smallPadding,
                ),
                Flexible(
                  child: Row(
                    children: [
                      // 使用 Expanded 组件让前面的文本自适应空间
                      Expanded(
                        flex: 2,
                        child: RichText(
                          maxLines: 1, // 限制最多显示 1 行
                          text: TextSpan(
                            text: allAppsMenus[index].title,
                            style: textTheme.bodySmall!
                                .apply(color: colorScheme.onSurface),
                          ),
                          overflow: TextOverflow.ellipsis, // 超出部分用省略号表示
                        ),
                      ),
                      // 使用 Expanded 组件让后面的文本自适应空间
                      Expanded(
                        flex: 1,
                        child: RichText(
                          textAlign: TextAlign.right,
                          maxLines: 1, // 限制最多显示 1 行
                          text: TextSpan(
                            text: isFreeApp(allAppsMenus[index].id)
                                ? localizedStrings.gTipFree
                                : isConfigCertified
                                    ? localizedStrings.gTipPerpetual
                                    : localizedStrings.gTipUnactivated,
                            style: textTheme.bodySmall!.apply(
                                color: isFreeApp(allAppsMenus[index].id)
                                    ? colorScheme.primary
                                    : isConfigCertified
                                        ? colorScheme.onTertiaryFixedVariant
                                        : colorScheme.error),
                          ),
                          overflow: TextOverflow.ellipsis, // 超出部分用省略号表示
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
          Expanded(
            child: Container(
              // 使用 withValues 替代 withOpacity
              alignment: Alignment.topLeft,
              child: SelectableText(
                allAppsMenus[index].subtitle,
                textAlign: TextAlign.left,
                style: textTheme.bodySmall!
                    .apply(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          SizedBox(
            height: smallPadding,
          ),
          Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 使用 ConstrainedBox 限制按钮的最大宽度为 300
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 350,
                  ),
                  child: textAddAppBtn(
                      colorScheme,
                      textTheme,
                      isFreeApp(allAppsMenus[index].id) && !isAdded
                          ? () {
                              setState(() {
                                selectedAppsPaidMenuIds
                                    .add(allAppsMenus[index].id);
                              });
                              writePageIdsToJson(
                                  selectedConfigPaidMenuIds,
                                  selectedAppsPaidMenuIds,
                                  widget.lastRouteName);
                            }
                          : isConfigCertified && !isAdded
                              ? () {
                                  setState(() {
                                    selectedAppsPaidMenuIds
                                        .add(allAppsMenus[index].id);
                                    print(selectedAppsPaidMenuIds.length);
                                  });
                                  writePageIdsToJson(
                                      selectedConfigPaidMenuIds,
                                      selectedAppsPaidMenuIds,
                                      widget.lastRouteName);
                                }
                              : isFreeApp(allAppsMenus[index].id) && isAdded
                                  ? null
                                  : isConfigCertified && isAdded
                                      ? null
                                      : !isConfigCertified
                                          ? null
                                          : null,
                      isAdded
                          ? localizedStrings.gBtnAdded
                          : localizedStrings.gBtnAddApp,
                      isAdded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                    Container(
                        height: 54,
                        padding: const EdgeInsets.only(
                            left: largePadding, right: largePadding),
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          Container(
                            width: 3,
                            height: regularPadding,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                localizedStrings.gBtnRenew,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.cancel,
                                size: iconSize,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryFixed,
                              ),
                              onPressed: () {
                                activationFileCtl.text = '';
                                Navigator.pop(context);
                              })
                        ])),
                    // 分割线
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        padding: EdgeInsets.all(largePadding),
                        child: Column(children: [
                          Expanded(
                              child: buildActivatePart(colorScheme, textTheme,
                                  () async {
                            String filePath = '';
                            try {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['txt'],
                              );
                              if (result != null && result.files.isNotEmpty) {
                                filePath = result.files.single.path!;
                              }
                              setState(() {
                                if (filePath != '') {
                                  activationFileCtl.text = filePath;
                                }
                              });
                            } catch (e) {
                              setState(() {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: const Text('Open fail',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight
                                                    .bold)), ////此处需要秤回复
                                        duration: const Duration(seconds: 5),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .error));
                              });
                            }
                          }, localizedStrings.gBtnSelectFile)),
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
                                  localizedStrings.gBtnRenew,
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
                                fixedSize: const Size(double.infinity, 48),
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    allAppsMenus = getAllAppsMenus();

    return Scaffold(
      body: Column(children: [
        // 第一部分，固定高度 64

        // 第二部分和第三部分按 13:10 比例分配剩余空间
        Expanded(
          child: Container(
              color: colorScheme.surface,
              child: Row(children: [
                Container(
                  width: regularPadding,
                  color: colorScheme.surfaceDim,
                ),
                Expanded(
                    child: Container(
                  padding: EdgeInsets.only(
                      left: regularPadding,
                      right: regularPadding,
                      bottom: regularPadding),
                  child: Column(children: [
                    Container(
                        height: leftBarIconHeight,
                        color: colorScheme.surface,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          localizedStrings.gTitleAppConfig,
                                          style: textTheme.bodyLarge!.apply(
                                              color: colorScheme.onSurface),
                                        ),
                                      ),
                                      Container(
                                          child: Row(children: [
                                        Text(
                                          localizedStrings.gSystemId + ": ",
                                          style: textTheme.bodySmall!.apply(
                                              color: colorScheme.onSurface),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SelectableText(
                                          myLicenseInfo.pId,
                                          style: textTheme.bodyLarge!.apply(
                                              color: colorScheme.primary),
                                        ),
                                      ])),
                                    ]),
                              ),
                            ])),
                    Expanded(
                        flex: 13,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: regularPadding,
                              right: regularPadding,
                              bottom: regularPadding),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // 计算可用高度
                              final availableWidth = constraints.maxWidth;
                              // 计算每个元素的宽度，减去元素间的间距后平分
                              final itemWidth = (availableWidth - 2 * 30) / 3;
                              return SingleChildScrollView(
                                child: Wrap(
                                  spacing: 30, // 元素间的水平间距
                                  runSpacing: 20, // 元素间的垂直间距
                                  children: List.generate(
                                    allAppsMenus.length,
                                    (index) {
                                      return SizedBox(
                                        width: itemWidth,
                                        height: 138, // 固定元素高度
                                        child: buildAppInfo(context, index),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                    Container(
                      height: 36,
                      color: colorScheme.surface,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            textBtn(
                              context,
                              colorScheme,
                              textTheme,
                              showActivateDialog,
                              localizedStrings.gBtnActivate,
                              36,
                            ),
                            SizedBox(
                              width: regularPadding,
                            ),
                            textColorBtn(
                              context,
                              colorScheme,
                              textTheme,
                              () {
                                widget.onNavigate('/settingsApps');
                              },
                              localizedStrings.gBtnBackToPrevious,
                              36,
                              Theme.of(context).colorScheme.onSurfaceVariant,
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ]),
                    ),
                  ]),
                )),
              ])),
        ),
        Container(
          height: regularPadding,
          color: colorScheme.surfaceDim,
        ),
      ]),
    );
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

  Widget buildActivatePart(ColorScheme colorScheme, TextTheme textTheme,
      VoidCallback? func, String name) {
    return Container(
      alignment: Alignment.center,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 400,
          child: showInputBox(
              activationFileCtl, localizedStrings.gTipSelectActivationFile),
        ),
        SizedBox(
          width: regularPadding,
        ),
        textBtn(context, colorScheme, textTheme, func, name, inputHeight)
      ]),
    );
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
                      Container(
                        child: Text(
                          title,
                          style: textTheme.bodyLarge!
                              .apply(color: colorScheme.onSurface),
                        ),
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

  Widget textAddAppBtn(ColorScheme colorScheme, TextTheme textTheme,
      VoidCallback? func, String name, bool isAdded) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: isAdded ? Color(0xFFFFF3F3) : colorScheme.scrim,
          fixedSize: const Size(double.infinity, 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        onPressed: func,
        child: Text(
          name,
          style: Theme.of(context).textTheme.bodySmall!.apply(
              color: func == null
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : isAdded
                      ? colorScheme.error
                      : colorScheme.primary),
          overflow: TextOverflow.ellipsis,
        ));
  }
}
