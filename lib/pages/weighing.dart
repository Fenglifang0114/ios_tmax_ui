import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/sel_scales_in_app.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/wgt_value_widget.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../functions/adaptive.dart';
import '../widget/page_head.dart';

class WeightModePage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const WeightModePage(
      {super.key, required this.onNavigate, required this.lastRouteName});
  @override
  State<WeightModePage> createState() => WeightModePageState();
}

class WeightModePageState extends State<WeightModePage> {


  List<int> mySelScaleIdList = [];

  Map<int, ReceiveWgtInfo> myScaleWgtMap = {};
  bool isFirstLoad = true;
  final Set<int> _processingScaleIds = {};

  dynamic eventBus5;
  dynamic eventBus6;
  dynamic eventBus7;

  // 添加定时器变量
  Timer? _scaleCheckTimer;

  @override
  void initState() {
    super.initState();
    // 确保秤列表已从后端获取
    PublicFunctions.getScaleList();

    // 初始化定时器，每隔 5 秒执行一次检查
    _scaleCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkSameScale();
    });

    // 初始加载时立即检查一次
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkSameScale();
    });

    eventBus5 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
        } else {}
      }
    });

    eventBus6 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {}
      }
    });

    // 监听秤列表更新事件，确保数据加载后刷新 UI
    eventBus7 = eventBus.on<EventRespAddScale>().listen((event) {
      if (mounted) {
        getSelScaleInApp();
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isFirstLoad) {
      getSelScaleInApp();
      isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    setSelScaleInApp();
    eventBus5.cancel();
    eventBus6.cancel();
    eventBus7.cancel();
    _scaleCheckTimer?.cancel();

    for (var item in mySelScaleIdList) {
      debugPrint("WeightMode: 正在停止秤 $item 的数据推送...");
      PublicFunctions.stopWeight(item);
    }

    super.dispose();
  }

  setSelScaleInApp() async {
    await AppSelScalesManager.setIntList(AppNames.weighing, mySelScaleIdList);
  }

  getSelScaleInApp() async {
    List<int> savedScales =
        await AppSelScalesManager.getIntList(AppNames.weighing);
    for (var item in myAllScalesList) {
      if (savedScales.contains(item.scaleId)) {
        addOrRemoveSelScale(item.scaleId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = Adaptive.isMobile(context);

    return Scaffold(
      // key: _scaffoldKey, // 移除全局键以避免布局切换时的断言错误
      drawer: isMobile
          ? Drawer(
              width: scaleListWidth + 20,
              child: SafeArea(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Container(
                        height: btnHeight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: regularPadding),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          (localizedStrings?.gTitleDeviceList ?? "gTitleDeviceList"),
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: NewMutiScaleListWidget(
                          listWidth: scaleListWidth,
                          selScaleList: mySelScaleIdList,
                          clickScale: (scale) {
                            setState(() {
                              addOrRemoveSelScale(scale.scaleId);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            pageHeadInfo(context, isMobile ? width : width - headWidthPadding,
                localizedStrings?.menuWeighing ?? 'Weighing', '', () {
              formAppSetting = false;
              widget.onNavigate(widget.lastRouteName);
            },
                leading: isMobile
                    ? Padding(
                        padding: const EdgeInsets.only(left: regularPadding),
                        child: Builder(builder: (context) {
                          return IconButton(
                            icon: Icon(Icons.menu_open,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          );
                        }),
                      )
                    : null),
            Container(
              height: regularPadding,
              color: Theme.of(context).colorScheme.surfaceDim,
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surfaceTint,
                child: Row(
                  children: [
                    if (!isMobile)
                      Container(
                        width: scaleListWidth,
                        color: Theme.of(context).colorScheme.surfaceTint,
                        child: NewMutiScaleListWidget(
                          listWidth: scaleListWidth,
                          selScaleList: mySelScaleIdList,
                          clickScale: (scale) {
                            setState(() {
                              addOrRemoveSelScale(scale.scaleId);
                            });
                          },
                        ),
                      ),
                    Expanded(
                      child: firstLayout(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkSameScale() {
    if (!mounted) return;

    if (mySelScaleIdList.length > 1) {
      Map<int, dynamic> scaleMap = {};
      for (var scale in myAllScalesList) {
        scaleMap[scale.scaleId] = scale;
      }

      // 根据物理设备（型号 + 序列号）对选中的秤进行分组
      Map<String, List<Scale>> groups = {};
      for (var scaleId in mySelScaleIdList) {
        var scale = scaleMap[scaleId];
        if (scale != null) {
          String key = "${scale.scaleModel}_${scale.scaleSn}";
          groups.putIfAbsent(key, () => []).add(scale);
        }
      }

      for (var group in groups.values) {
        if (group.length > 1) {
          // 冲突：同一个物理设备选择了多种连接方式
          showTipInfo((localizedStrings?.tipSameScale ?? "tipSameScale"), context);

          // 优先级：串口(0) > 网口(1) > 蓝牙(2)。排序并保留最高优先级的连接。
          group.sort((a, b) => a.tMedia.compareTo(b.tMedia));

          // 移除除第一个（优先级最高）之外的所有连接
          for (int i = 1; i < group.length; i++) {
            if (mySelScaleIdList.contains(group[i].scaleId)) {
              addOrRemoveSelScale(group[i].scaleId);
            }
          }
          break; // 每个检查周期只显示一次提示
        }
      }
    }
  }


  void addOrRemoveSelScale(int scaleId) async {
    if (_processingScaleIds.contains(scaleId)) {
      debugPrint("WeightMode: 秤 $scaleId 正在处理中，忽略操作");
      return;
    }

    _processingScaleIds.add(scaleId);
    
    try {
      if (mySelScaleIdList.contains(scaleId)) {
        mySelScaleIdList.remove(scaleId);
        PublicFunctions.stopWeight(scaleId);
        // 给予一点时间让指令在链路上处理完
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        mySelScaleIdList.add(scaleId);
        PublicFunctions.getWeight(scaleId);
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      if (mounted) {
        setState(() {}); // 强制刷新界面
        checkSameScale();
      }
    } finally {
      _processingScaleIds.remove(scaleId);
    }
  }

  String getScaleName(int scaleId) {
    String scaleName = "";

    for (var item in myAllScalesList) {
      if (item.scaleId == scaleId) {
        scaleName = item.scaleName;
        return scaleName;
      }
    }

    return scaleName;
  }

  Widget firstLayout(context) {
    if (mySelScaleIdList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(largePadding),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.scale_outlined,
                size: 80, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: regularPadding),
            Text(
              localizedStrings?.gTipNoDevice ?? 'No Device Selected',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: smallPadding),
            Text(
              Adaptive.isMobile(context)
                  ? '请点击左上角菜单选择设备'
                  : '请在左侧列表选择设备',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding:
          const EdgeInsets.only(left: regularPadding, bottom: regularPadding),
      color: Theme.of(context).colorScheme.surfaceDim,
      child: ListView.builder(
        itemCount: mySelScaleIdList.length,
        itemBuilder: (context, index) {
          final scaleId = mySelScaleIdList[index];
          return ScaleItemWidget(
              key: ValueKey(scaleId),
              scaleId: scaleId,
              scaleName: getScaleName(scaleId));
        },
      ),
    );
  }
}
