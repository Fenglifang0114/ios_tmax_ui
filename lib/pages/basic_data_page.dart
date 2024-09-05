import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:t_max/data/olul_err_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/manager_scale_channel.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class BasicDataPage extends StatefulWidget {
  const BasicDataPage({Key? key}) : super(key: key);
  @override
  State<BasicDataPage> createState() => BasicDataPageState();
}

class BasicDataPageState extends State<BasicDataPage> {
  dynamic eventBus1;
  dynamic eventBus2;

  bool isWeightDataBtn = true;

  TextEditingController olCntCtl = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();
    PublicFunctions.getBasicData(defaultScaleId);

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
                  backgroundColor: Theme.of(context).colorScheme.outline));
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

    eventBus2 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        setState(() {
          myFactoryInfoFromScale = event.obj;
          if (myFactoryInfoFromScale.modelName != '') {
            myScreenMgr.serialPortST = true;
          } else {
            myScreenMgr.serialPortST = false;
          }
        });
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
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(body: firstLayout(context, _width));
  }

  Widget firstLayout(context, _width) {
    return Container(
        width: _width,
        // decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceTint,
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHeadDefScale(
              context,
              localizedStrings.abnormal_data_title,
            ),
            const SizedBox(height: 20),
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
                        PublicFunctions.getBasicData(defaultScaleId);
                        setState(() {
                          isWeightDataBtn = false;
                        });
                      }
                    : null,
              ),
            )),
            Expanded(
              child: SizedBox(
                width: _width,
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: _width / 3,
                          child: customCard(context, 'Power-On Count:',
                              myBasicErrInfo.powerOnCnt.toString()),
                        ),
                        SizedBox(
                          width: _width / 3,
                          child: customCard(context, 'Running Time(mins):',
                              myBasicErrInfo.runningTime.toString()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: _width / 3,
                          child: customCard(
                              context,
                              'Abnormal Power-Off Count:',
                              myBasicErrInfo.forcedShutdownCnt.toString()),
                        ),
                        SizedBox(
                          width: _width / 3,
                          child: customCard(context, 'Weighing Count:',
                              myBasicErrInfo.wgtCnt.toString()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: _width / 3,
                          child: customCard(context, 'OL Time(mins):',
                              myBasicErrInfo.olTime.toString()),
                        ),
                        SizedBox(
                          width: _width / 3,
                          child: customCard(context, 'UL Time(mins):',
                              myBasicErrInfo.ulTime.toString()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: _width / 3,
                          child: customCard(context, 'Err4 Count:',
                              myBasicErrInfo.err4Cnt.toString()),
                        ),
                        SizedBox(
                          width: _width / 3,
                          child: customCard(context, 'Err19 Count:',
                              myBasicErrInfo.err19Cnt.toString()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: _width / 3,
                          child: customCard(
                              context,
                              'Calibration Switch Count:',
                              myBasicErrInfo.calSwitchCnt.toString()),
                        ),
                        SizedBox(
                          width: _width / 3,
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
