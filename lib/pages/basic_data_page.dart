import 'dart:convert';
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
            showTipInfo(localizedStrings.gTipTimeOut, context);
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
              showTipInfo(localizedStrings.fSuccessMsg, context);
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
    eventBus1.cancel();
    eventBus2.cancel();

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
                              if (!enabledGetDataBtn) {
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
                          Expanded(
                              child: Column(children: [
                            showTitleItem(
                              Theme.of(context).colorScheme.surfaceContainerLow,
                              localizedStrings.gTipInformation,
                              localizedStrings.gTipValue,
                              localizedStrings.gTipInformation,
                              localizedStrings.gTipValue,
                            ),
                            showBasicDataItem(
                                Theme.of(context).colorScheme.surface,
                                localizedStrings.cTipPowerOnCnt,
                                myBasicErrInfo.powerOnCnt.toString(),
                                localizedStrings.cTipRunningTime,
                                myBasicErrInfo.runningTime.toString()),
                            showBasicDataItem(
                                Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow,
                                localizedStrings.cTipPowerOffCnt,
                                myBasicErrInfo.forcedShutdownCnt.toString(),
                                localizedStrings.cTipWeighingCount,
                                myBasicErrInfo.wgtCnt.toString()),
                            showBasicDataItem(
                                Theme.of(context).colorScheme.surface,
                                localizedStrings.cTipOlTime,
                                myBasicErrInfo.olTime.toString(),
                                localizedStrings.cTipUlTime,
                                myBasicErrInfo.ulTime.toString()),
                            showBasicDataItem(
                              Theme.of(context).colorScheme.surfaceContainerLow,
                              localizedStrings.cTipCalswitchCnt,
                              myBasicErrInfo.calSwitchCnt.toString(),
                              localizedStrings.cTipCalCnt,
                              myBasicErrInfo.caliCnt.toString(),
                            ),
                            showBasicDataItem(
                                Theme.of(context).colorScheme.surface,
                                localizedStrings.cTipErr4Cnt,
                                myBasicErrInfo.err4Cnt.toString(),
                                localizedStrings.cTipErr19Cnt,
                                myBasicErrInfo.err19Cnt.toString()),
                          ])),
                          Container(
                            child: showTextButton(
                                context,
                                btnHeight,
                                localizedStrings.gBtnGetBasicData,
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
}
