import 'dart:convert';
import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:t_max/data/seal_log.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/version.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';
import 'package:t_max/functions/adaptive.dart';

class CalibrationSealPage extends StatefulWidget {
  const CalibrationSealPage({super.key});
  @override
  State<CalibrationSealPage> createState() => CalibrationSealPageState();
}

class CalibrationSealPageState extends State<CalibrationSealPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  dynamic eventBus1;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus5;
  dynamic eventBus6;
  dynamic eventBus7;
  dynamic eventBus8;

  bool enabledGetInfo = true;

  String hardSealStatus = ''; //
  String softSealStatus = '';

  TextEditingController olCntCtl = TextEditingController(text: '');
  List<SealLogInfo> sealLogInfoList = [];

  int selScaleId = -1;
  bool isPass = false;
  Future<void> setAppInfo() async {
    await openAppJson();
  }

  bool _sortAscending = true;
  int? _sortColumnIndex;

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();

    setAppInfo().then((value) => setState(() {}));
    isPass = myLicenseInfo.isValid;

    eventBus1 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        try {
          OnlineInfo myOnlineInfo = event.obj;

          if (selScaleId != myOnlineInfo.scaleId ||
              myOnlineInfo.factInfo!.modelName == "" ||
              myOnlineInfo.factInfo!.scaleSn == "") {
            return;
          }
          ReqGetSealLog reqGetSealLog = ReqGetSealLog(
              myOnlineInfo.factInfo!.modelName!,
              myOnlineInfo.factInfo!.scaleSn!);
          String jsonStr = jsonEncode(reqGetSealLog);

          PublicFunctions.getSealLog(jsonStr);
        } catch (e) {
          // print(e);
        }
      }
    });

    eventBus3 = eventBus.on<EventRevGetSealStatus>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        String dataStr = event.obj;
        setState(() {
          enabledGetInfo = true;
        });
        PublicFunctions.checkSerialPort(selScaleId);

        if (dataStr.contains('fail') || dataStr.contains('time out')) {
          showTipInfo((localizedStrings?.checkSealFailed ?? "checkSealFailed"), context);
          setState(() {
            softSealStatus = "";
            hardSealStatus = "";
          });
        } else {
          List<String> splitData = dataStr.split(',');

          setState(() {
            hardSealStatus = splitData[0];
            softSealStatus = splitData[1];
          });
        }
      }
    });
    eventBus4 = eventBus.on<EventRevSoftSeal>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        String dataStr = event.obj;
        setState(() {
          enabledGetInfo = true;
        });
        if (dataStr.contains('fail') || dataStr.contains('time out')) {
          showDialog(
            context: context,
            barrierDismissible: false, // 点击对话框外部不关闭对话框
            builder: (BuildContext context) {
              return ShowSealTipDialog(
                title: (localizedStrings?.fTipTitle ?? "fTipTitle"),
                msg: (localizedStrings?.softwareSealAppliedFailed ?? "softwareSealAppliedFailed"),
                iconPath: failedSvgIcon(),
                iconColor: Theme.of(context).colorScheme.error,
              );
            },
          );
        } else {
          showDialog(
            context: context,
            barrierDismissible: false, // 点击对话框外部不关闭对话框
            builder: (BuildContext context) {
              return ShowSealTipDialog(
                title: (localizedStrings?.fTipTitle ?? "fTipTitle"),
                msg: (localizedStrings?.softwareSealAppliedSuccessfully ?? "softwareSealAppliedSuccessfully"),
                iconPath: sealOkSvgIcon(),
                iconColor: Theme.of(context).colorScheme.onTertiaryFixedVariant,
              );
            },
          );
          PublicFunctions.getSealStatus(selScaleId);
          setState(() {
            enabledGetInfo = false;
          });
        }
      }
    });
    eventBus5 = eventBus.on<EventRevRemoveSoftSeal>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        setState(() {
          enabledGetInfo = true;
        });
        if (dataStr.contains('fail') || dataStr.contains('time out')) {
          showDialog(
            context: context,
            barrierDismissible: false, // 点击对话框外部不关闭对话框
            builder: (BuildContext context) {
              return ShowUnsealFailedDialog(
                title: (localizedStrings?.fTipTitle ?? "fTipTitle"),
                msg: (localizedStrings?.softwareSealRemovalFailed ?? "softwareSealRemovalFailed"),
                iconPath: failedSvgIcon(),
                iconColor: Theme.of(context).colorScheme.error,
              );
            },
          );
        } else {
          if (dataStr.contains("ok")) {
            showDialog(
              context: context,
              barrierDismissible: false, // 点击对话框外部不关闭对话框
              builder: (BuildContext context) {
                return ShowSealTipDialog(
                  title: (localizedStrings?.fTipTitle ?? "fTipTitle"),
                  msg: (localizedStrings?.softwareSealRemovedSuccessfully ?? "softwareSealRemovedSuccessfully"),
                  iconPath: unlockOkSvgIcon(),
                  iconColor:
                      Theme.of(context).colorScheme.onTertiaryFixedVariant,
                );
              },
            ).then((value) {
              PublicFunctions.getSealStatus(selScaleId);
              setState(() {
                enabledGetInfo = false;
              });
            });
          }
        }
      }
    });
    eventBus6 = eventBus.on<EventShowSealOnce>().listen((event) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ShowUnSealOnceDialog(scaleId: selScaleId),
        );
      }
    });

    eventBus7 = eventBus.on<EventRespGetAllSealLog>().listen((event) {
      if (mounted) {
        String jsonStr = event.obj;
        if (jsonStr.isEmpty) {
          setState(() {
            sealLogInfoList = [];
          });
          return;
        }
        try {
          sealLogInfoList = sealLogInfoFromJson(jsonStr);

          setState(() {
            sealLogInfoList
                .sort((a, b) => b.operationTime!.compareTo(a.operationTime!));
          });
        } catch (e) {
          // print(e);
        }
      }
    });

    eventBus8 = eventBus.on<EventRevRemoveSoftSealOnce>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        String dataStr = event.obj;

        if (dataStr.isEmpty) {
          return;
        }

        if (dataStr.contains('fail')) {
          showTipInfo((localizedStrings?.removeSealFailed ?? "removeSealFailed"), context);
          return;
        } else {
          PublicFunctions.getSealStatus(selScaleId);
          setState(() {
            enabledGetInfo = false;
          });
        }
      }
    });

    // 在页面构建完成后显示提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (myAllScalesList.isEmpty) {
        showTipInfo((localizedStrings?.gTipNoDeviceAddFirst ?? "gTipNoDeviceAddFirst"), context);
      } else {
        if (selScaleId == -1) {
          if (Adaptive.isMobile(context)) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            showTipInfo((localizedStrings?.gTipSelectDeviceFirst ?? "gTipSelectDeviceFirst"), context);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    eventBus7.cancel();
    eventBus8.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (Adaptive.isMobile(context)) {
      return mobileLayout(context, width);
    }
    return Scaffold(
      body: firstLayout(context, width),
    );
  }

  Widget firstLayout(context, width) {
    double currentScaleListWidth = width > 1000 ? scaleListWidth : 200.0;
    return Container(
        width: width,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: currentScaleListWidth,
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: regularPadding,
                        ),
                        Expanded(
                          child: NewAllScaleListWidget(
                            listWidth: currentScaleListWidth, // 列表宽度
                            selScaleId: selScaleId,
                            clickScale: (scale) {
                              if (!enabledGetInfo) {
                                showTipInfo(
                                    (localizedStrings?.gTipPerformingOperation ?? "gTipPerformingOperation"),
                                    context);
                                return;
                              }
                              setState(() {
                                changeScale(scale.scaleId);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: Theme.of(context).colorScheme.outlineVariant, //  分隔条颜色
                ),
                myAllScalesList.isEmpty
                    ? SizedBox()
                    : Expanded(
                        child: Container(
                        padding: const EdgeInsets.all(largePadding),
                        child: Column(children: [
                          Flexible(
                            flex: 6,
                            child: SingleChildScrollView(
                              child: Container(
                                  padding: const EdgeInsets.only(bottom: largePadding),
                                  child: Column(children: [
                                Wrap(
                                  spacing: largePadding,
                                  runSpacing: largePadding,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 300,
                                      child: Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceDim,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: 78,
                                                height: 78,
                                                alignment: Alignment.center,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withAlpha(50),
                                                    ),
                                                    width: scaleItemHeight,
                                                    height: scaleItemHeight,
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 42,
                                                        height: 42,
                                                        child: getSvgIcon(
                                                            hardwareSealSvgIcon(),
                                                            42,
                                                            42,
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary)))),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    localizedStrings
                                                        .hardwareSeal,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    hardSealStatus == "true"
                                                        ? localizedStrings
                                                            .sealed
                                                        : hardSealStatus ==
                                                                "false"
                                                            ? localizedStrings
                                                                .notSealed
                                                            : localizedStrings
                                                                .toBeVerified,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                          color: hardSealStatus ==
                                                                  "true"
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error
                                                              : hardSealStatus ==
                                                                      "false"
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onTertiaryFixedVariant
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceDim,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: 78,
                                                height: 78,
                                                alignment: Alignment.center,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onTertiaryFixedVariant
                                                          .withAlpha(51),
                                                    ),
                                                    width: scaleItemHeight,
                                                    height: scaleItemHeight,
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 42,
                                                        height: 42,
                                                        child: getSvgIcon(
                                                            softwareSealSvgIcon(),
                                                            42,
                                                            42,
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onTertiaryFixedVariant)))),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    localizedStrings
                                                        .softwareSeal,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    softSealStatus == "true"
                                                        ? localizedStrings
                                                            .softwareLocked
                                                        : softSealStatus ==
                                                                "false"
                                                            ? localizedStrings
                                                                .softwareUnlocked
                                                            : localizedStrings
                                                                .toBeVerified,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                          color: softSealStatus ==
                                                                  "true"
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error
                                                              : softSealStatus ==
                                                                      "false"
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onTertiaryFixedVariant
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: largePadding * 2),
                                Wrap(
                                  spacing: 14,
                                  runSpacing: 14,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: showTextButton(
                                          context,
                                          btnHeight,
                                          (localizedStrings?.checkSeal ?? "checkSeal"),
                                          enabledGetInfo
                                              ? () {
                                                  if (selScaleId == -1) {
                                                    showTipInfo(
                                                        localizedStrings
                                                            .gTipSelectDeviceFirst,
                                                        context);
                                                    return;
                                                  }
                                                  PublicFunctions.getSealStatus(
                                                      selScaleId);
                                                  setState(() {
                                                    enabledGetInfo = false;
                                                  });
                                                }
                                              : null,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: showTextButton(
                                          context,
                                          btnHeight,
                                          (localizedStrings?.applySoftwareSeal ?? "applySoftwareSeal"),
                                          softSealStatus == "false" &&
                                                  enabledGetInfo
                                              ? () {
                                                  String sealCode =
                                                      getSealCode();
                                                  if (sealCode.isEmpty) {
                                                    return;
                                                  }
                                                  PublicFunctions.softSeal(
                                                      selScaleId, sealCode);
                                                  setState(() {
                                                    enabledGetInfo = false;
                                                  });
                                                }
                                              : null,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          Theme.of(context).colorScheme.error,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: showTextButton(
                                          context,
                                          btnHeight,
                                          (localizedStrings?.removeSoftwareSeal ?? "removeSoftwareSeal"),
                                          softSealStatus == "true" &&
                                                  enabledGetInfo
                                              ? () {
                                                  String sealCode =
                                                      getSealCode();
                                                  if (sealCode.isEmpty) {
                                                    return;
                                                  }

                                                  PublicFunctions
                                                      .removeSoftSeal(
                                                          selScaleId, sealCode);
                                                  setState(() {
                                                    enabledGetInfo = false;
                                                  });
                                                }
                                              : null,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          Theme.of(context)
                                              .colorScheme
                                              .onTertiaryFixedVariant,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                  ],
                                ),
                                SizedBox(height: largePadding),
                                Divider(
                                  height: 1,
                                ),
                                SizedBox(height: largePadding),
                                  ])),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: DataTable2(
                              columnSpacing: 12,
                              horizontalMargin: 12,
                              minWidth: 800,
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _sortAscending,
                              headingRowHeight: 45,
                              headingRowColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.surfaceDim),
                              columns: [
                                DataColumn2(
                                  label: Text(
                                    (localizedStrings?.fTipOperation ?? "fTipOperation"),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.M,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      sealLogInfoList.sort((a, b) => ascending
                                          ? a.operation!.compareTo(b.operation!)
                                          : b.operation!
                                              .compareTo(a.operation!));
                                    });
                                  },
                                ),
                                DataColumn2(
                                  label: Text(
                                    (localizedStrings?.operator ?? "operator"),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.S,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      sealLogInfoList.sort((a, b) => ascending
                                          ? a.operator!.compareTo(b.operator!)
                                          : b.operator!.compareTo(a.operator!));
                                    });
                                  },
                                ),
                                DataColumn2(
                                  label: Text(
                                    (localizedStrings?.fCreatedAtCol ?? "fCreatedAtCol"),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.M,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      sealLogInfoList.sort((a, b) => ascending
                                          ? a.operationTime!
                                              .compareTo(b.operationTime!)
                                          : b.operationTime!
                                              .compareTo(a.operationTime!));
                                    });
                                  },
                                ),
                              ],
                              rows: sealLogInfoList.map((seallog) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        seallog.operation! == "seal"
                                            ? (localizedStrings?.fTipSeal ?? "fTipSeal")
                                            : (localizedStrings?.fTipUnseal ?? "fTipUnseal"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: _getDeptColor(
                                                    seallog.operation!)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    DataCell(Text(
                                      seallog.operator!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(Text(
                                      '${seallog.operationTime!.year}-${seallog.operationTime!.month}-${seallog.operationTime!.day} ${seallog.operationTime!.hour}:${seallog.operationTime!.minute}:${seallog.operationTime!.second}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ]),
                      )),
              ]),
            ),
          ],
        ));
  }

  String getSealCode() {
    if (myConfigCode.isEmpty) {
      showTipInfo((localizedStrings?.reAcquireAuthCode ?? "reAcquireAuthCode"), context);
      return "";
    } else {
      String code = myConfigCode;
      // 将处理后的字节转换16进制字符串
      String sealCode = code.length.toString();
      sealCode += code;
      if (sealCode.length < 16) {
        sealCode = sealCode.padRight(16, '0');
      }
      return sealCode.substring(0, 16);
    }
  }

  Widget showTextInfo(String text) {
    return Expanded(
        child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      overflow: TextOverflow.ellipsis,
    ));
  }

  Widget showTitleInfo(String text) {
    return Expanded(
        child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      overflow: TextOverflow.ellipsis,
    ));
  }

  //切换的时候要修改掉秤的信息
  void changeScale(int scaleId) {
    setState(() {
      selScaleId = scaleId;
      sealLogInfoList = [];
    });
  }

  Widget mobileLayout(BuildContext context, double width) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      drawer: UnifiedDeviceDrawerContent(
        scaleList: myAllScalesList,
        isSelected: (scale) => selScaleId == scale.scaleId,
        onScaleTap: (scale) {
          if (!enabledGetInfo) {
            showTipInfo(
                (localizedStrings?.gTipPerformingOperation ?? "Performing"),
                context);
            return;
          }
          setState(() {
            changeScale(scale.scaleId);
            enabledGetInfo = false;
          });
          PublicFunctions.getSealStatus(scale.scaleId);
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leadingWidth: 96,
        leading: Builder(
          builder: (BuildContext ctx) {
            return Row(
              children: [
                const SizedBox(width: 4),
                BackButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                MobileScaleHeaderIconButton(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                ),
              ],
            );
          },
        ),
        title: Text(
          localizedStrings?.menuSealManagment ?? "Calibration Lock",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hardware Calibration Switch Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: getSvgIcon(hardwareSealSvgIcon(), 28, 28, Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizedStrings?.hardwareSeal ?? "Hardware Calibration Switch",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hardSealStatus == "true"
                                    ? localizedStrings?.sealed ?? "Sealed"
                                    : hardSealStatus == "false"
                                        ? localizedStrings?.notSealed ?? "Not Sealed"
                                        : localizedStrings?.toBeVerified ?? "To be verified",
                                style: TextStyle(
                                  color: hardSealStatus == "true"
                                      ? Colors.red
                                      : hardSealStatus == "false"
                                          ? Colors.green
                                          : Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Software Calibration Lock Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: getSvgIcon(softwareSealSvgIcon(), 28, 28, Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizedStrings?.softwareSeal ?? "Software Calibration Lock",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                softSealStatus == "true"
                                    ? localizedStrings?.softwareLocked ?? "Software Locked"
                                    : softSealStatus == "false"
                                        ? localizedStrings?.softwareUnlocked ?? "Software Unlocked"
                                        : localizedStrings?.toBeVerified ?? "To be verified",
                                style: TextStyle(
                                  color: softSealStatus == "true"
                                      ? Colors.red
                                      : softSealStatus == "false"
                                          ? Colors.green
                                          : Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Operation Record
                  Text(
                    localizedStrings?.fTipOperation ?? "Operation Record",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sealLogInfoList.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final log = sealLogInfoList[index];
                        final isSeal = log.operation == "seal";
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  isSeal
                                      ? localizedStrings?.fTipSeal ?? "Seal"
                                      : localizedStrings?.fTipUnseal ?? "Unseal",
                                  style: TextStyle(
                                    color: isSeal ? Colors.red : Colors.green,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Text(
                                log.operator ?? "",
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${log.operationTime!.year}/${log.operationTime!.month.toString().padLeft(2, '0')}/${log.operationTime!.day.toString().padLeft(2, '0')} ${log.operationTime!.hour.toString().padLeft(2, '0')}:${log.operationTime!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: enabledGetInfo
                        ? () {
                            if (selScaleId == -1) {
                              showTipInfo(localizedStrings?.gTipSelectDeviceFirst ?? "", context);
                              return;
                            }
                            PublicFunctions.getSealStatus(selScaleId);
                            setState(() {
                              enabledGetInfo = false;
                            });
                          }
                        : null,
                    child: Text(localizedStrings?.checkSeal ?? "Check Seal", style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softSealStatus == "false" && enabledGetInfo ? Colors.green : Colors.grey[300],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: softSealStatus == "false" && enabledGetInfo
                        ? () {
                            String sealCode = getSealCode();
                            if (sealCode.isEmpty) return;
                            PublicFunctions.softSeal(selScaleId, sealCode);
                            setState(() {
                              enabledGetInfo = false;
                            });
                          }
                        : null,
                    child: Text(localizedStrings?.applySoftwareSeal ?? "Enable Software Calibration Lock", style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softSealStatus == "true" && enabledGetInfo ? Colors.green : Colors.grey[300],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: softSealStatus == "true" && enabledGetInfo
                        ? () {
                            String sealCode = getSealCode();
                            if (sealCode.isEmpty) return;
                            PublicFunctions.removeSoftSeal(selScaleId, sealCode);
                            setState(() {
                              enabledGetInfo = false;
                            });
                          }
                        : null,
                    child: Text(localizedStrings?.removeSoftwareSeal ?? "Disable Software Calibration Lock", style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDeptColor(String dept) {
    switch (dept) {
      case 'unseal':
        return Theme.of(context).colorScheme.onTertiaryFixedVariant;
      case 'seal':
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.grey;
    }
  }
}

class Employee {
  final int id;
  final String name;
  final String department;
  final String salary;
  final DateTime joinDate;
  final String performance;

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.salary,
    required this.joinDate,
    required this.performance,
  });
}

// 定义弹框
class ShowSealTipDialog extends StatefulWidget {
  const ShowSealTipDialog(
      {super.key,
      required this.title,
      required this.msg,
      required this.iconPath,
      required this.iconColor});
  final String title;
  final String msg;
  final String iconPath;
  final Color iconColor;
  @override
  ShowSealTipDialogState createState() => ShowSealTipDialogState();
}

class ShowSealTipDialogState extends State<ShowSealTipDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 550,
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, widget.title, true, onClose: () {
              Navigator.pop(context, false);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 200,
                width: 380,
                child: Column(children: [
                  SizedBox(height: 20),
                  getSvgIcon(widget.iconPath, 80, 80, widget.iconColor),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 定义弹框
class ShowUnsealFailedDialog extends StatefulWidget {
  const ShowUnsealFailedDialog({
    super.key,
    required this.title,
    required this.msg,
    required this.iconPath,
    required this.iconColor,
  });
  final String title;
  final String msg;
  final String iconPath;
  final Color iconColor;

  @override
  ShowUnsealFailedDialogState createState() => ShowUnsealFailedDialogState();
}

class ShowUnsealFailedDialogState extends State<ShowUnsealFailedDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 550,
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, widget.title, true, onClose: () {
              Navigator.pop(context, false);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 200,
                width: 500,
                child: Column(children: [
                  SizedBox(height: 20),
                  getSvgIcon(widget.iconPath, 80, 80, widget.iconColor),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      eventBus.fire(EventShowSealOnce(''));
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      (localizedStrings?.removeWithCode ?? "removeWithCode"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 定义弹框
class ShowUnSealOnceDialog extends StatefulWidget {
  const ShowUnSealOnceDialog({super.key, required this.scaleId});
  final int scaleId;

  @override
  ShowUnSealOnceDialogState createState() => ShowUnSealOnceDialogState();
}

class ShowUnSealOnceDialogState extends State<ShowUnSealOnceDialog> {
  TextEditingController fileCtl = TextEditingController();
  bool isFilePickerBusy = false;

  dynamic eventBus2;

  @override
  void initState() {
    super.initState();
    eventBus2 = eventBus.on<EventRespUnsealByMasterKey>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;

        if (dataStr.contains('invalid')) {
          showTipInfo((localizedStrings?.invalidData ?? "invalidData"), context);
          return;
        } else if (dataStr.contains('expired')) {
          showTipInfo((localizedStrings?.dataExpired ?? "dataExpired"), context);
          return;
        }

        if (dataStr.contains("ok")) {
          PublicFunctions.removeSoftSealOnce(widget.scaleId);

          Navigator.pop(context, true);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    eventBus2.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 550,
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, (localizedStrings?.removeWithCode ?? "removeWithCode"), true,
                onClose: () {
              Navigator.pop(context, false);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                height: 200,
                width: 520,
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: showInputBox(context, fileCtl,
                            (localizedStrings?.removeWithCode ?? "removeWithCode"), (value) {}, false),
                      ),
                      SizedBox(width: 10),
                      showTextButton(
                          context, btnHeight, (localizedStrings?.gBtnSelectFile ?? "gBtnSelectFile"),
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
                          if (result != null && result.files.isNotEmpty) {
                            filePath = result.files.single.path!;
                          }
                          setState(() {
                            if (filePath != '') {
                              fileCtl.text = filePath;
                            }
                          });
                        } catch (e) {
                          return;
                        } finally {
                          // 无论选择文件操作成功还是失败，都将状态设置为空闲
                          setState(() {
                            isFilePickerBusy = false;
                          });
                        }
                      },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary)
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (localizedStrings?.contactSupplierForRemovalCode ?? "contactSupplierForRemovalCode"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: fileCtl.text.isNotEmpty
                        ? () async {
                            //打开文件并读取内容
                            try {
                              // 读取文件内容
                              String fileContent =
                                  await File(fileCtl.text).readAsString();

                              String codeStr = fileContent.trim();
                              codeStr = codeStr
                                  .replaceAll(" ", "")
                                  .replaceAll('\n', '')
                                  .replaceAll('\r', '');
                              PublicFunctions.unsealByMasterKey(codeStr);
                            } catch (e) {
                              return;
                            }
                          }
                        : null,
                    child: Text(
                      (localizedStrings?.removeWithCode ?? "removeWithCode"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReqGetSealLog {
  String model;
  String sn;
  ReqGetSealLog(this.model, this.sn);
  Map<String, dynamic> toJson() => {
        'Model': model,
        'Sn': sn,
      };
}
