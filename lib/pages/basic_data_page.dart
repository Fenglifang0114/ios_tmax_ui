import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:t_max/data/olul_err_data.dart';

import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';

import '../data/comscaleinfo_data.dart';
import '../data/manager_scale_channel.dart';
import '../data/language.dart';

import '../data/scale_list_data.dart';
import '../data/timer_manager.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class BasicDataPage extends StatefulWidget {
  const BasicDataPage({super.key});
  @override
  State<BasicDataPage> createState() => BasicDataPageState();
}

class BasicDataPageState extends State<BasicDataPage> {
  dynamic eventBus1;
  dynamic eventBus2;

  bool isWeightDataBtn = true;

  TextEditingController olCntCtl = TextEditingController(text: '');
  List<NetScaleInfoLocal> scaleNetItems = [];
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  int selScaleId = -1;

  void initScaleList() {
    scaleNetItems = myNetScaleList;
    selScaleId = myDefScaleInfo.defScaleId!;
    if (myNetScaleList.isNotEmpty) {
      defNetScaleInfo = NetScaleListMgr.findScaleInfo(
          myNetScaleList, myDefScaleInfo.defScaleId!);
    }
  }

  @override
  void initState() {
    super.initState();
    initScaleList();
    cntScaleTimerMgr.stopCntScaleTimer();
    PublicFunctions.getBasicData(myDefScaleInfo.defScaleId!);

    isWeightDataBtn = false;

    eventBus1 = eventBus.on<EventGetBasicData>().listen((event) {
      if (mounted) {
        isWeightDataBtn = true;
        myBasicErrInfo = BasicErrInfo(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        String jsonString = event.obj;
        setState(() {
          if (jsonString.contains('fail') || jsonString.contains('no')) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(jsonString,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: Theme.of(context).colorScheme.error));
          } else {
            try {
              final jsonResponse = json.decode(jsonString);
              myBasicErrInfo = BasicErrInfo.fromJson(jsonResponse);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('OK',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal)), ////此处需要秤回复
                  duration: const Duration(seconds: 3),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(jsonString,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal)), ////此处需要秤回复
                  duration: const Duration(seconds: 3),
                  backgroundColor: Theme.of(context).colorScheme.error));
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
      appBar: AppBar(
          title: Container(
            child:
                pageHeadDefScale(context, localizedStrings.abnormal_data_title),
          ),
          leading: IconTheme(
              data: IconThemeData(
                  color: Theme.of(context).colorScheme.primary // 设置抽屉图标颜色
                  ),
              child: Builder(builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }))),
      body: firstLayout(context, width),
      drawer: Drawer(
          child: myWeighingScaleListDrawer(
              context,
              localizedStrings.gTipScaleList,
              scaleNetItems,
              selScaleId) // showNetScaleList(),
          ),
    );
  }

  Widget firstLayout(context, width) {
    return Container(
        width: width,
        // decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceTint,
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: SizedBox(
              width: 300,
              child: CustomOutlinedButton(
                btnWidth: 200,
                btnHeight: 50,
                icon: Icons.date_range,
                text: localizedStrings.abnormal_weight,
                onPressed: isWeightDataBtn
                    ? () {
                        PublicFunctions.getBasicData(
                            myDefScaleInfo.defScaleId!);
                        setState(() {
                          isWeightDataBtn = false;
                        });
                      }
                    : null,
              ),
            )),
            Expanded(
              child: SizedBox(
                width: width,
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: width / 3,
                          child: customCard(context, 'Power-On Count:',
                              myBasicErrInfo.powerOnCnt.toString()),
                        ),
                        SizedBox(
                          width: width / 3,
                          child: customCard(context, 'Running Time(mins):',
                              myBasicErrInfo.runningTime.toString()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: width / 3,
                          child: customCard(
                              context,
                              'Abnormal Power-Off Count:',
                              myBasicErrInfo.forcedShutdownCnt.toString()),
                        ),
                        SizedBox(
                          width: width / 3,
                          child: customCard(context, 'Weighing Count:',
                              myBasicErrInfo.wgtCnt.toString()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: width / 3,
                          child: customCard(context, 'OL Time(mins):',
                              myBasicErrInfo.olTime.toString()),
                        ),
                        SizedBox(
                          width: width / 3,
                          child: customCard(context, 'UL Time(mins):',
                              myBasicErrInfo.ulTime.toString()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: width / 3,
                          child: customCard(context, 'Err4 Count:',
                              myBasicErrInfo.err4Cnt.toString()),
                        ),
                        SizedBox(
                          width: width / 3,
                          child: customCard(context, 'Err19 Count:',
                              myBasicErrInfo.err19Cnt.toString()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: width / 3,
                          child: customCard(
                              context,
                              'Calibration Switch Count:',
                              myBasicErrInfo.calSwitchCnt.toString()),
                        ),
                        SizedBox(
                          width: width / 3,
                          child: customCard(context, 'Calibration Count:',
                              myBasicErrInfo.caliCnt.toString()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget customCard(BuildContext context, String titleName, String value) {
    return Card(
        elevation: 2.0,
        shadowColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(10),
        color: Theme.of(context).colorScheme.surfaceTint,
        child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    titleName,
                    overflow: TextOverflow.visible,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    value,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            )));
  }
}
