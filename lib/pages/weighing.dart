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

  // 娣诲姞瀹氭椂鍣ㄥ彉閲?
  Timer? _scaleCheckTimer;

  @override
  void initState() {
    super.initState();
    // 纭繚绉ゅ垪琛ㄥ凡浠庡悗绔幏鍙?
    PublicFunctions.getScaleList();

    // 鍒濆鍖栧畾鏃跺櫒锛屾瘡闅?绉掓墽琛屼竴娆℃鏌?
    _scaleCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkSameScale();
    });

    // 鍒濆鍔犺浇鏃剁珛鍗虫鏌ヤ竴娆?
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

    // 鐩戝惉绉ゅ垪琛ㄦ洿鏂颁簨浠讹紝纭繚鏁版嵁鍔犺浇鍚庡埛鏂?UI
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
      debugPrint("WeightMode: 姝ｅ湪鍋滄绉?$item 鐨勬暟鎹帹閫?..");
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
      // key: _scaffoldKey, // 绉婚櫎鍏ㄥ眬閿互閬垮厤甯冨眬鍒囨崲鏃剁殑鏂█閿欒
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

      // 鏍规嵁鐗╃悊璁惧锛堝瀷鍙?+ 搴忓垪鍙凤級瀵归€変腑鐨勭Г杩涜鍒嗙粍
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
          // 鍐茬獊锛氬悓涓€涓墿鐞嗚澶囬€夋嫨浜嗗绉嶈繛鎺ユ柟寮?
          showTipInfo((localizedStrings?.tipSameScale ?? "tipSameScale"), context);

          // 浼樺厛绾э細涓插彛(0) > 缃戝彛(1) > 钃濈墮(2)銆傛帓搴忓苟淇濈暀鏈€楂樹紭鍏堢骇鐨勮繛鎺ャ€?
          group.sort((a, b) => a.tMedia.compareTo(b.tMedia));

          // 绉婚櫎闄ょ涓€涓紙浼樺厛绾ф渶楂橈級涔嬪鐨勬墍鏈夎繛鎺?
          for (int i = 1; i < group.length; i++) {
            if (mySelScaleIdList.contains(group[i].scaleId)) {
              addOrRemoveSelScale(group[i].scaleId);
            }
          }
          break; // 姣忎釜妫€鏌ュ懆鏈熷彧鏄剧ず涓€娆℃彁绀?
        }
      }
    }
  }


  void addOrRemoveSelScale(int scaleId) async {
    if (_processingScaleIds.contains(scaleId)) {
      debugPrint("WeightMode: 绉?$scaleId 姝ｅ湪澶勭悊涓紝蹇界暐鎿嶄綔");
      return;
    }

    _processingScaleIds.add(scaleId);
    
    try {
      if (mySelScaleIdList.contains(scaleId)) {
        mySelScaleIdList.remove(scaleId);
        PublicFunctions.stopWeight(scaleId);
        // 缁欎簣涓€鐐规椂闂磋鎸囦护鍦ㄩ摼璺笂澶勭悊瀹?
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        mySelScaleIdList.add(scaleId);
        PublicFunctions.getWeight(scaleId);
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      if (mounted) {
        setState(() {}); // 寮哄埗鍒锋柊鐣岄潰
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
                  ? '璇风偣鍑诲乏涓婅鑿滃崟閫夋嫨璁惧'
                  : '璇峰湪宸︿晶鍒楄〃閫夋嫨璁惧',
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
