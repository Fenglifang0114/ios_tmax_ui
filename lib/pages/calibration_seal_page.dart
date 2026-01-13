import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/olul_err_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/version.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/manager_scale_channel.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';

class CalibrationSealPage extends StatefulWidget {
  const CalibrationSealPage({super.key});
  @override
  State<CalibrationSealPage> createState() => CalibrationSealPageState();
}

class CalibrationSealPageState extends State<CalibrationSealPage> {
  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus5;
  dynamic eventBus6;

  bool enabledGetInfo = true;

  String hardSealStatus = ''; //
  String softSealStatus = '';

  TextEditingController olCntCtl = TextEditingController(text: '');

  int selScaleId = -1;
  bool isPass = false;
  Future<void> setAppInfo() async {
    await openAppJson();
  }

  final List<Employee> _employees = List.generate(
      100,
      (i) => Employee(
            id: i + 1,
            name: '员工 ${i + 1}',
            department: [
              'unseal',
              'seal',
            ][i % 2],
            salary: ' sdfjisodjf sdfjisod sdfjio test remark',
            joinDate:
                DateTime(2020 + i % 5, (i % 12) + 1, (i % 28) + 1, 10, 30, 20),
            performance: ['优秀', '良好', '一般', '待改进'][i % 4],
          ));

  bool _sortAscending = true;
  int? _sortColumnIndex;

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();

    setAppInfo().then((value) => setState(() {}));
    isPass = myLicenseInfo.isValid;

    eventBus2 = eventBus.on<EventSelWeighingScaleId>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        int scaleId = event.obj;
        if (scaleId != selScaleId) {
          setState(() {
            selScaleId = scaleId;
            DefScaleInfo.getDefScaleInfo(scaleId);
            PublicFunctions.getBasicData(myDefScaleInfo.defScaleId!);
          });
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

        if (dataStr.contains('fail') || dataStr.contains('time out')) {
          showTipInfo(localizedStrings.checkSealFailed, context);
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
                title: localizedStrings.fTipTitle,
                msg: localizedStrings.softwareSealAppliedFailed,
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
                title: localizedStrings.fTipTitle,
                msg: localizedStrings.softwareSealAppliedSuccessfully,
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
                title: localizedStrings.fTipTitle,
                msg: localizedStrings.softwareSealRemovalFailed,
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
                  title: localizedStrings.fTipTitle,
                  msg: localizedStrings.softwareSealRemovedSuccessfully,
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

    // 在页面构建完成后显示提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (myAllScalesList.isEmpty) {
        showTipInfo(localizedStrings.gTipNoDeviceAddFirst, context);
      } else {
        if (selScaleId == -1) {
          showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
        }
      }
    });
  }

  @override
  void dispose() {
    eventBus2.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: firstLayout(context, width),
    );
  }

  Widget firstLayout(context, width) {
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
                  width: scaleListWidth,
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
                            listWidth: scaleListWidth, // 列表宽度
                            selScaleId: selScaleId,
                            clickScale: (scale) {
                              if (!enabledGetInfo) {
                                showTipInfo(
                                    localizedStrings.gTipPerformingOperation,
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
                          SizedBox(
                              height: 230,
                              child: Column(children: [
                                Row(
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
                                    SizedBox(width: largePadding),
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
                                                            .sealed
                                                        : softSealStatus ==
                                                                "false"
                                                            ? localizedStrings
                                                                .notSealed
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
                                Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: showTextButton(
                                          context,
                                          btnHeight,
                                          localizedStrings.checkSeal,
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
                                      width: 14,
                                    ),
                                    Container(
                                      child: showTextButton(
                                          context,
                                          btnHeight,
                                          localizedStrings.applySoftwareSeal,
                                          softSealStatus == "false" &&
                                                  enabledGetInfo
                                              ? () {
                                                  PublicFunctions.softSeal(
                                                      selScaleId,
                                                      '78uyy89ikoi98789');
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
                                      width: 14,
                                    ),
                                    Container(
                                      child: showTextButton(
                                          context,
                                          btnHeight,
                                          localizedStrings.removeSoftwareSeal,
                                          softSealStatus == "true" &&
                                                  enabledGetInfo
                                              ? () {
                                                  PublicFunctions
                                                      .removeSoftSeal(
                                                          selScaleId,
                                                          '78uyy89ikoi98789');
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
                          Expanded(
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
                                    '操作',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.M,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      _employees.sort((a, b) => ascending
                                          ? a.department.compareTo(b.department)
                                          : b.department
                                              .compareTo(a.department));
                                    });
                                  },
                                ),
                                DataColumn2(
                                  label: Text(
                                    'ID',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.S,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      _employees.sort((a, b) => ascending
                                          ? a.id.compareTo(b.id)
                                          : b.id.compareTo(a.id));
                                    });
                                  },
                                ),
                                DataColumn2(
                                  label: Text(
                                    '操作员',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.S,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      _employees.sort((a, b) => ascending
                                          ? a.name.compareTo(b.name)
                                          : b.name.compareTo(a.name));
                                    });
                                  },
                                ),
                                DataColumn2(
                                  label: Text(
                                    '备注',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.L,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      _employees.sort((a, b) => ascending
                                          ? a.salary.compareTo(b.salary)
                                          : b.salary.compareTo(a.salary));
                                    });
                                  },
                                ),
                                DataColumn2(
                                  label: Text(
                                    '操作时间',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.M,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      _employees.sort((a, b) => ascending
                                          ? a.joinDate.compareTo(b.joinDate)
                                          : b.joinDate.compareTo(a.joinDate));
                                    });
                                  },
                                ),
                              ],
                              rows: _employees.map((employee) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        employee.department,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: _getDeptColor(
                                                    employee.department)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    DataCell(Text(
                                      employee.id.toString(),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(Text(
                                      employee.name,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(
                                      Text(
                                        employee.salary,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    DataCell(Text(
                                      '${employee.joinDate.year}-${employee.joinDate.month}-${employee.joinDate.day} ${employee.joinDate.hour}:${employee.joinDate.minute}:${employee.joinDate.second}',
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
    // PublicFunctions.stopWeight(selScaleId);
    setState(() {
      selScaleId = scaleId;
    });

    // PublicFunctions.getWeight(scaleId);
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
                      localizedStrings.gBtnConfirm,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // SizedBox(
                  //   width: 20,
                  // ),
                  // Expanded(
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       foregroundColor:
                  //           Theme.of(context).colorScheme.onPrimary,
                  //       backgroundColor: Theme.of(context)
                  //           .colorScheme
                  //           .surfaceContainerHighest,
                  //       fixedSize: const Size(double.infinity, 48),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.zero,
                  //       ),
                  //     ),
                  //     onPressed: () {
                  //       Navigator.pop(context, false);
                  //     },
                  //     child: Text(
                  //       localizedStrings.gBtnCancel,
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.normal,
                  //         color: Theme.of(context).colorScheme.onPrimary,
                  //         overflow: TextOverflow.ellipsis,
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
                      localizedStrings.removeWithCode,
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
                        localizedStrings.gBtnCancel,
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
  TextEditingController removalCodeCtl = TextEditingController();

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
            ...dialogHeadStyle(context, localizedStrings.removeWithCode, true,
                onClose: () {
              Navigator.pop(context, false);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 200,
                width: 500,
                child: Column(children: [
                  showInputBox(context, removalCodeCtl,
                      localizedStrings.removeWithCode, (value) {}, true),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizedStrings.contactSupplierForRemovalCode,
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
                    onPressed: () {
                      PublicFunctions.removeSoftSealOnce(widget.scaleId);
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      localizedStrings.removeWithCode,
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
                        localizedStrings.gBtnCancel,
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
