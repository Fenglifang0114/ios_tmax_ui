import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/no_device_widget.dart';
import '../data/downloadresponse.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/common.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';
import 'package:adoptive_calendar/adoptive_calendar.dart';
import 'package:t_max/functions/adaptive.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/dialog/mobile_page_help_dialog.dart';

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
    localizedStrings = S.of(context);
    final bool isMobile = Adaptive.isMobile(context);
    final width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildMobileDrawer(context) : null,
      body: firstLayout(context, width, isMobile),
    );
  }

  Widget firstLayout(context, width, bool isMobile) {
    if (isMobile) {
      return _buildMobileContent(context, width);
    }
    return Container(
        width: width,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

  Widget _buildMobileContent(BuildContext context, double width) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: Builder(
          builder: (BuildContext ctx) {
            return Row(
              children: [
                BackButton(
                  color: Colors.black87,
                  onPressed: () => Navigator.pop(context),
                ),
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: getSvgIcon(
                        weighingSvgIcon(), 24, 24, Colors.black87),
                  ),
                ),
              ],
            );
          },
        ),
        title: Text(
          localizedStrings?.menuDeviceTime ?? "Device Time",
          style: const TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              showMobilePageHelpDialog(
                context,
                localizedStrings?.menuDeviceTime ?? "Device Time",
                localizedStrings?.gTipDeviceTimePageHelp ?? "Help instructions for Device Time page.",
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Text(
              "Device",
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
          Container(
            height: 1,
            color: const Color(0xFFEEEEEE),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD0D0D0)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  "${pad0(deviceTime.hour)}:${pad0(deviceTime.minute)}:${pad0(deviceTime.second)}",
                  style: const TextStyle(
                    color: Color(0xFF005696),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${deviceTime.year}-${pad0(deviceTime.month)}-${pad0(deviceTime.day)}",
                  style: const TextStyle(
                    color: Color(0xFF005696),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Container()),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selScaleId == -1
                            ? null
                            : () {
                                var timestamp = (DateTime.now()
                                            .toUtc()
                                            .millisecondsSinceEpoch /
                                        1000)
                                    .truncate();
                                PublicFunctions.setScaleTime(
                                    timestamp.toString(), selScaleId);
                                setState(() {
                                  isSettingTime = true;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005696),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          localizedStrings?.gBtnSyncTime ?? "Sync Time",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selScaleId == -1
                            ? null
                            : () async {
                                DateTime? pickedDate = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AdoptiveCalendar(
                                      initialDate: DateTime.now(),
                                      selectedColor:
                                          Theme.of(context).colorScheme.primary,
                                      action: true,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  var timestamp = (pickedDate
                                              .toUtc()
                                              .millisecondsSinceEpoch /
                                          1000)
                                      .truncate();
                                  PublicFunctions.setScaleTime(
                                      timestamp.toString(), selScaleId);
                                  setState(() {
                                    isSettingTime = true;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005696),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          localizedStrings?.gBtnSetTime ?? "Set Date/Time",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 16, right: 16),
              child: Text(
                localizedStrings?.gTitleDeviceList ?? "Device List",
                style: const TextStyle(
                  color: Color(0xFF005696),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: myAllScalesList.isEmpty
                  ? showNoDeviceWidget(context)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: myAllScalesList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final scale = myAllScalesList[index];
                        final bool isSelect = (selScaleId == scale.scaleId);
                        final bool isOnline = scale.isOnline;

                        String iconPath = serialPortSvgIcon();
                        if (scale.tMedia == netScaleType) {
                          iconPath = networkSvgIcon();
                        } else if (scale.tMedia == btScaleType) {
                          iconPath = btSvgIcon();
                        }

                        return GestureDetector(
                          onTap: () {
                            if (isGettingTime || isSettingTime) {
                              showTipInfo(
                                localizedStrings?.gTipPerformingOperation ??
                                    "Performing operation",
                                context,
                              );
                              return;
                            }
                            Navigator.pop(context);
                            changeScale(scale.scaleId);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelect
                                  ? const Color(0xFF005696)
                                  : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelect
                                        ? Colors.white.withOpacity(0.2)
                                        : const Color(0xFFE8EEF4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  child: getSvgIcon(
                                    iconPath,
                                    24,
                                    24,
                                    isSelect ? Colors.white : const Color(0xFF005696),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        scale.scaleName,
                                        style: TextStyle(
                                          color:
                                              isSelect ? Colors.white : Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isOnline
                                            ? (localizedStrings?.gTipOnline ?? "Online")
                                            : (localizedStrings?.gTipOffline ??
                                                "Offline"),
                                        style: TextStyle(
                                          color: isSelect
                                              ? Colors.white.withOpacity(0.9)
                                              : (isOnline
                                                  ? const Color(0xFF005696)
                                                  : const Color(0xFFFF4D4F)),
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
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
