import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import '../data/downloadresponse.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/common.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';
import 'package:adoptive_calendar/adoptive_calendar.dart';
import 'package:t_max/functions/adaptive.dart';

class SetSystemTimePage extends StatefulWidget {
  const SetSystemTimePage({super.key});
  @override
  State<SetSystemTimePage> createState() => SetSystemTimePageState();
}

class SetSystemTimePageState extends State<SetSystemTimePage> {
  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventbus3;

  int clickedRow = -1; //点击的行
  int selScaleId = -1; //选择的秤ID
  bool isGettingTime = false; //是否正在获取时间
  bool isSettingTime = false; //是否正在设置时间
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime customDate = DateTime.now();
  DateTime customTime = DateTime.now();
  DateTime deviceTime = DateTime.now();

  bool isManaul = false;

  TextEditingController manualTimeCtl = TextEditingController();

  Timer? _timer;

//初始化秤列表

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();
    eventBus1 = eventBus.on<EventSetScaleTime>().listen((event) {
      if (mounted) {
        setState(() {
          isSettingTime = false;
        });
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.isNotEmpty) {
          if (myRespDataFromScale.msgBody.contains('ok')) {
            // cntScaleTimerMgr.stopCntScaleTimer();
            PublicFunctions.getScaleTime(selScaleId);
            setState(() {
              isGettingTime = true;
            });
          } else {
            stopTimer();
            // cntScaleTimerMgr.startCntScaleTimer(5);
          }

          myRespDataFromScale.msgBody.contains('ok')
              ? showTipInfo((localizedStrings?.fSuccessMsg ?? "fSuccessMsg"), context)
              : showTipInfo(myRespDataFromScale.msgBody, context);
        }
      }
    });

    eventBus2 = eventBus.on<EventGetScaleTime>().listen((event) {
      if (mounted) {
        setState(() {
          isGettingTime = false;
        });
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
          String dataStr = myRespDataFromScale.msgBody;
          List<String> parts = dataStr.split(',');
          if (parts.length > 1) {
            String secondPart = parts[1].trim(); // 移除字符串两边的空白字符
            int? intValue = int.tryParse(secondPart);
            if (intValue != null) {
              setState(() {
                deviceTime =
                    DateTime.fromMillisecondsSinceEpoch(intValue * 1000);
                stopTimer();
                startTimer();
              });
              showTipInfo((localizedStrings?.fSuccessMsg ?? "fSuccessMsg"), context);
            } else {
              stopTimer();
              showTipInfo((localizedStrings?.gTipFailedGetTime ?? "gTipFailedGetTime"), context);
            }
          } else {
            stopTimer();
            showTipInfo((localizedStrings?.gTipFailedGetTime ?? "gTipFailedGetTime"), context);
          }
        } else {
          stopTimer();
          showTipInfo(myRespDataFromScale.msgBody, context);
        }
        // cntScaleTimerMgr.stopCntScaleTimer();
        // cntScaleTimerMgr.startCntScaleTimer(5);
      }
    });

    eventbus3 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        // setState(() {
        //   myFactoryInfoFromScale = event.obj;
        //   if (myFactoryInfoFromScale.modelName != '') {
        //     myComScaleInfo.isOnline = true;
        //   } else {
        //     myComScaleInfo.isOnline = false;
        //   }
        // });
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
    _timer?.cancel();
    manualTimeCtl.dispose();
    eventbus3?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        deviceTime = deviceTime.add(const Duration(seconds: 1));
      });
    });
  }

  void stopTimer() {
    setState(() {
      _timer?.cancel();
    });
  }

  //切换的时候要修改掉秤的信息
  void changeScale(int scaleId) {
    showTipInfo((localizedStrings?.gTipGettingDeviceTime ?? "gTipGettingDeviceTime"), context);
    setState(() {
      selScaleId = scaleId;
      PublicFunctions.getScaleTime(selScaleId);
      setState(() {
        isGettingTime = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Adaptive.isMobile(context);
    final width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile
          ? Drawer(
              width: scaleListWidth,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceTint,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Expanded(
                      child: NewAllScaleListWidget(
                        listWidth: scaleListWidth,
                        selScaleId: selScaleId,
                        clickScale: (scale) {
                          if (isGettingTime || isSettingTime) {
                            showTipInfo(
                                (localizedStrings?.gTipPerformingOperation ?? "gTipPerformingOperation"),
                                context);
                            return;
                          }
                          Navigator.pop(context); // 关闭抽屉
                          changeScale(scale.scaleId);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: firstLayout(context, width, isMobile),
    );
  }

  Widget firstLayout(context, width, bool isMobile) {
    return Container(
        width: width,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile)
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                title: Text(
                  (localizedStrings?.menuDeviceTime ?? "menuDeviceTime"),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  if (!isMobile)
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
                                  if (isGettingTime || isSettingTime) {
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
                  Expanded(
                    child: Row(
                      children: [
                        if (!isMobile)
                          Container(
                            width: 1,
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant, //  分隔条颜色
                          ),
                        myAllScalesList.isEmpty
                            ? SizedBox()
                            : Expanded(
                                child: SingleChildScrollView(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                        ),
                                        Container(
                                          height: scaleItemHeight,
                                          width: isMobile ? width * 0.9 : 500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerLow,
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text.rich(
                                              TextSpan(
                                                  text:
                                                      "${deviceTime.year}-${pad0(deviceTime.month)}-${pad0(deviceTime.day)} ${pad0(deviceTime.hour)}:${pad0(deviceTime.minute)}:${pad0(deviceTime.second)}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium!
                                                      .apply(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .primary)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: isMobile ? 50 : 100,
                                        ),
                                        Container(
                                            height: leftBarHeight,
                                            width: isMobile ? width * 0.9 : 500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerLow,
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                    child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: regularPadding,
                                                      right: regularPadding),
                                                  child: Text(
                                                    (localizedStrings?.gBtnSyncPcTime ?? "gBtnSyncPcTime"),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onSurface),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                )),
                                                Expanded(
                                                    child: Container(
                                                  height: scaleInnerItemHeight,
                                                  padding: EdgeInsets.only(
                                                      left: regularPadding,
                                                      right: regularPadding),
                                                  child: showTextButton(
                                                      context,
                                                      btnHeight,
                                                      (localizedStrings?.gBtnSyncTime ?? "gBtnSyncTime"),
                                                      selScaleId == -1
                                                          ? null
                                                          : () {
                                                              var timestamp = (DateTime
                                                                              .now()
                                                                          .toUtc()
                                                                          .millisecondsSinceEpoch /
                                                                      1000)
                                                                  .truncate();
                                                              // cntScaleTimerMgr.stopCntScaleTimer();
                                                              PublicFunctions
                                                                  .setScaleTime(
                                                                      timestamp
                                                                          .toString(),
                                                                      selScaleId);
                                                              setState(() {
                                                                isSettingTime =
                                                                    true;
                                                              });
                                                            },
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary),
                                                ))
                                              ],
                                            )),
                                        SizedBox(
                                          height: largePadding,
                                        ),
                                        Container(
                                            height: leftBarHeight,
                                            width: isMobile ? width * 0.9 : 500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerLow,
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                    child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: regularPadding,
                                                      right: regularPadding),
                                                  child: Text(
                                                    (localizedStrings?.gBtnSelectDate ?? "gBtnSelectDate"),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onSurface),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                )),
                                                Expanded(
                                                    child: Container(
                                                  height: scaleInnerItemHeight,
                                                  padding: EdgeInsets.only(
                                                      left: regularPadding,
                                                      right: regularPadding),
                                                  child: showTextButton(
                                                      context,
                                                      btnHeight,
                                                      (localizedStrings?.gBtnSetTime ?? "gBtnSetTime"),
                                                      selScaleId == -1
                                                          ? null
                                                          : () async {
                                                              DateTime? pickedDate =
                                                                  await showDialog(
                                                                context: context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AdoptiveCalendar(
                                                                    initialDate:
                                                                        DateTime
                                                                            .now(),
                                                                    selectedColor: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                    action: true,
                                                                  );
                                                                },
                                                              );
                                                              setState(() {
                                                                if (pickedDate !=
                                                                    null) {
                                                                  var timestamp = (pickedDate
                                                                              .toUtc()
                                                                              .millisecondsSinceEpoch /
                                                                          1000)
                                                                      .truncate();
 
                                                                  // 停止计时器
                                                                  // cntScaleTimerMgr
                                                                  //     .stopCntScaleTimer();
 
                                                                  // 同步时间到秤
                                                                  PublicFunctions
                                                                      .setScaleTime(
                                                                    timestamp
                                                                        .toString(),
                                                                    selScaleId,
                                                                  );
                                                                  setState(() {
                                                                    isSettingTime =
                                                                        true;
                                                                  });
                                                                }
                                                              });
                                                            },
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary),
                                                ))
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ))
                      ],
                    ),
                  ),
                ])),
          ],
        ));
  }

  Widget btnStyle(String head) {
    return SizedBox(
        width: 200,
        child: Text(
          head,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ));
  }
}
