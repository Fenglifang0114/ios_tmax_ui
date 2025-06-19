import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/wgt_value_widget.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../widget/page_head.dart';

class WeightModePage extends StatefulWidget {
  const WeightModePage({super.key});
  @override
  State<WeightModePage> createState() => WeightModePageState();
}

class WeightModePageState extends State<WeightModePage> {
  List<int> mySelScaleIdList = [];

  Map<int, ReceiveWgtInfo> myScaleWgtMap = {};

  dynamic eventBus5;
  dynamic eventBus6;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    eventBus5.cancel();
    eventBus6.cancel();

    for (var item in mySelScaleIdList) {
      PublicFunctions.stopWeight(item);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          width: width,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageHeadInfo(
                    context,
                    width - headWidthPadding,
                    localizedStrings.menuWeighing,
                    localizedStrings.gTipWeighingPageHelp),
                Container(
                  height: regularPadding,
                  color: Theme.of(context).colorScheme.surfaceDim,
                ),
                Expanded(
                    child: Container(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: Row(
                    children: [
                      Container(
                        width: scaleListWidth,
                        color: Theme.of(context).colorScheme.surfaceTint,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                height: btnHeight,
                                padding:
                                    const EdgeInsets.only(left: regularPadding),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  localizedStrings.gTitleDeviceList,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: NewMutiScaleListWidget(
                                  listWidth: scaleListWidth, // 列表宽度
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
                      firstLayout(
                          context, width - scaleListWidth - regularPadding * 2)
                    ],
                  ),
                )),
              ])),
    );
  }

  void addOrRemoveSelScale(int scaleId) {
    if (mySelScaleIdList.contains(scaleId)) {
      mySelScaleIdList.remove(scaleId);
      PublicFunctions.stopWeight(scaleId);
    } else {
      mySelScaleIdList.add(scaleId);
      PublicFunctions.getWeight(scaleId);
    }
    setState(() {}); // 强制刷新界面
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

  Widget firstLayout(context, width) {
    return Container(
      width: width,
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
