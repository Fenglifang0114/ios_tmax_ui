import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/olul_err_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/manager_scale_channel.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';
import 'package:t_max/functions/adaptive.dart';
import 'package:t_max/dialog/mobile_page_help_dialog.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';

class BasicDataPage extends StatefulWidget {
  const BasicDataPage({super.key});
  @override
  State<BasicDataPage> createState() => BasicDataPageState();
}

class BasicDataPageState extends State<BasicDataPage> {
  dynamic eventBus1;
  dynamic eventBus2;

  bool enabledGetDataBtn = true;

  TextEditingController olCntCtl = TextEditingController(text: '');

  int selScaleId = -1;

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();
    eventBus1 = eventBus.on<EventGetBasicData>().listen((event) {
      if (mounted) {
        enabledGetDataBtn = true;
        myBasicErrInfo = BasicErrInfo(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        String jsonString = event.obj;
        setState(() {
          if (jsonString.contains('fail') || jsonString.contains('time out')) {
            showTipInfo((localizedStrings?.gTipTimeOut ?? "gTipTimeOut"), context);
            for (var item in myAllScalesList) {
              if (item.scaleId == selScaleId) {
                item.isOnline = false;
                break;
              }
            }
          } else {
            try {
              final jsonResponse = json.decode(jsonString);
              myBasicErrInfo = BasicErrInfo.fromJson(jsonResponse);
              showTipInfo((localizedStrings?.fSuccessMsg ?? "fSuccessMsg"), context);
            } catch (e) {
              showTipInfo(jsonString, context);
            }
          }
        });
      }
    });
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
    // 在页面构建完成后显示提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (myAllScalesList.isEmpty) {
        showTipInfo((localizedStrings?.gTipNoDeviceAddFirst ?? "gTipNoDeviceAddFirst"), context);
      } else {
        if (selScaleId == -1) {
          showTipInfo((localizedStrings?.gTipSelectDeviceFirst ?? "gTipSelectDeviceFirst"), context);
        }
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus2.cancel();

    olCntCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile =
        Platform.isAndroid || Platform.isIOS || Adaptive.isMobile(context);
    if (isMobile) {
      return mobileLayout(context, width);
    }
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
                              if (!enabledGetDataBtn) {
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
                          Expanded(
                              child: Column(children: [
                            showTitleItem(
                              Theme.of(context).colorScheme.surfaceContainerLow,
                              (localizedStrings?.gTipInformation ?? "gTipInformation"),
                              (localizedStrings?.gTipValue ?? "gTipValue"),
                              (localizedStrings?.gTipInformation ?? "gTipInformation"),
                              (localizedStrings?.gTipValue ?? "gTipValue"),
                            ),
                            showBasicDataItem(
                                Theme.of(context).colorScheme.surface,
                                (localizedStrings?.cTipPowerOnCnt ?? "cTipPowerOnCnt"),
                                myBasicErrInfo.powerOnCnt.toString(),
                                (localizedStrings?.cTipRunningTime ?? "cTipRunningTime"),
                                myBasicErrInfo.runningTime.toString()),
                            showBasicDataItem(
                                Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow,
                                (localizedStrings?.cTipPowerOffCnt ?? "cTipPowerOffCnt"),
                                myBasicErrInfo.forcedShutdownCnt.toString(),
                                (localizedStrings?.cTipWeighingCount ?? "cTipWeighingCount"),
                                myBasicErrInfo.wgtCnt.toString()),
                            showBasicDataItem(
                                Theme.of(context).colorScheme.surface,
                                (localizedStrings?.cTipOlTime ?? "cTipOlTime"),
                                myBasicErrInfo.olTime.toString(),
                                (localizedStrings?.cTipUlTime ?? "cTipUlTime"),
                                myBasicErrInfo.ulTime.toString()),
                            showBasicDataItem(
                              Theme.of(context).colorScheme.surfaceContainerLow,
                              (localizedStrings?.cTipCalswitchCnt ?? "cTipCalswitchCnt"),
                              myBasicErrInfo.calSwitchCnt.toString(),
                              (localizedStrings?.cTipCalCnt ?? "cTipCalCnt"),
                              myBasicErrInfo.caliCnt.toString(),
                            ),
                            showBasicDataItem(
                                Theme.of(context).colorScheme.surface,
                                (localizedStrings?.cTipErr4Cnt ?? "cTipErr4Cnt"),
                                myBasicErrInfo.err4Cnt.toString(),
                                (localizedStrings?.cTipErr19Cnt ?? "cTipErr19Cnt"),
                                myBasicErrInfo.err19Cnt.toString()),
                          ])),
                          Container(
                            child: showTextButton(
                                context,
                                btnHeight,
                                (localizedStrings?.gBtnGetBasicData ?? "gBtnGetBasicData"),
                                enabledGetDataBtn
                                    ? () {
                                        PublicFunctions.getBasicData(
                                            selScaleId);
                                        setState(() {
                                          enabledGetDataBtn = false;
                                        });
                                      }
                                    : null,
                                Theme.of(context).colorScheme.onPrimary,
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.onPrimary),
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

  Widget showTitleItem(
      Color color, String text1, String text2, String text3, String text4) {
    return Container(
      height: btnHeight,
      color: color,
      child: Row(
        children: [
          showTitleInfo(text1),
          showTitleInfo(text2),
          showTitleInfo(text3),
          showTitleInfo(text4),
        ],
      ),
    );
  }

  Widget showBasicDataItem(
      Color color, String text1, String text2, String text3, String text4) {
    return Container(
      height: btnHeight,
      color: color,
      child: Row(
        children: [
          showTextInfo(text1),
          showTextInfo(text2),
          showTextInfo(text3),
          showTextInfo(text4),
        ],
      ),
    );
  }

  //切换的时候要修改掉秤的信息
  void changeScale(int scaleId) {
    // PublicFunctions.stopWeight(selScaleId);
    setState(() {
      selScaleId = scaleId;
    });

    // PublicFunctions.getWeight(scaleId);
  }

  Widget mobileLayout(BuildContext context, double width) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: UnifiedDeviceDrawerContent(
        scaleList: myAllScalesList,
        isSelected: (scale) => selScaleId == scale.scaleId,
        onScaleTap: (scale) {
          if (!enabledGetDataBtn) {
            showTipInfo(
                (localizedStrings?.gTipPerformingOperation ?? "Performing"),
                context);
            return;
          }
          Navigator.pop(context);
          setState(() {
            changeScale(scale.scaleId);
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 96,
        leading: Builder(
          builder: (BuildContext ctx) {
            return Row(
              children: [
                const SizedBox(width: 4),
                BackButton(
                  color: Colors.black87,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                MobileScaleHeaderIconButton(
                  onTap: () {
                    Scaffold.of(ctx).openDrawer();
                  },
                ),
              ],
            );
          },
        ),
        title: Text(
          localizedStrings?.menuBasicDataCollection ?? "Basic Data Collection",
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              showMobilePageHelpDialog(
                context,
                localizedStrings?.menuBasicDataCollection ?? "Basic Data Collection",
                localizedStrings?.gTipBasicDataPageHelp ?? "Help instructions for Basic Data Collection page.",
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.withAlpha(51)),
                ),
                child: Column(
                  children: [
                    _buildMobileHeaderRow(),
                    _buildMobileDataRow((localizedStrings?.cTipPowerOnCnt ?? "Power-On Count"), myBasicErrInfo.powerOnCnt.toString(), true),
                    _buildMobileDataRow((localizedStrings?.cTipPowerOffCnt ?? "Abnormal Power-Off Count"), myBasicErrInfo.forcedShutdownCnt.toString(), false),
                    _buildMobileDataRow((localizedStrings?.cTipOlTime ?? "OL Time(mins)"), myBasicErrInfo.olTime.toString(), true),
                    _buildMobileDataRow((localizedStrings?.cTipErr4Cnt ?? "Err4 Count"), myBasicErrInfo.err4Cnt.toString(), false),
                    _buildMobileDataRow((localizedStrings?.cTipCalswitchCnt ?? "Calibration Switch Count"), myBasicErrInfo.calSwitchCnt.toString(), true),
                    _buildMobileDataRow((localizedStrings?.cTipRunningTime ?? "Running Time(mins)"), myBasicErrInfo.runningTime.toString(), false),
                    _buildMobileDataRow((localizedStrings?.cTipWeighingCount ?? "Weighing Count"), myBasicErrInfo.wgtCnt.toString(), true),
                    _buildMobileDataRow((localizedStrings?.cTipUlTime ?? "UL Time(mins)"), myBasicErrInfo.ulTime.toString(), false),
                    _buildMobileDataRow((localizedStrings?.cTipErr19Cnt ?? "Err19 Count"), myBasicErrInfo.err19Cnt.toString(), true),
                    _buildMobileDataRow((localizedStrings?.cTipCalCnt ?? "Calibration Count"), myBasicErrInfo.caliCnt.toString(), false),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005A9E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: enabledGetDataBtn
                    ? () {
                        if (selScaleId == -1) {
                          showTipInfo(localizedStrings?.gTipSelectDeviceFirst ?? "Select Device", context);
                          return;
                        }
                        PublicFunctions.getBasicData(selScaleId);
                        setState(() {
                          enabledGetDataBtn = false;
                        });
                      }
                    : null,
                child: Text(
                  localizedStrings?.gBtnGetBasicData ?? "Get Basic Data",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeaderRow() {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              localizedStrings?.gTipInformation ?? "Information",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              localizedStrings?.gTipValue ?? "Parameter List",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDataRow(String title, String value, bool isEven) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Colors.grey.withAlpha(25)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
