import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/olul_err_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../../generated/l10n.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../widget/page_head.dart';

class AbnormalDataPage extends StatefulWidget {
  const AbnormalDataPage({Key? key}) : super(key: key);
  @override
  State<AbnormalDataPage> createState() => AbnormalDataPageState();
}

class AbnormalDataPageState extends State<AbnormalDataPage> {
  dynamic eventBus1;
  dynamic eventBus2;
  String olCount = '-';
  String olTime = '-';
  String ulCount = '-';
  String ulTime = '-';

  bool isWeightDataBtn = true;

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();

    PublicFunctions.getWeightErr();

    isWeightDataBtn = false;

    eventBus1 = eventBus.on<EventGetWeightErr>().listen((event) {
      if (mounted) {
        myGetWeightErrResp = event.obj;
        setState(() {
          isWeightDataBtn = true;
        });

        if (myGetWeightErrResp.msgBody.contains('fail') ||
            myGetWeightErrResp.msgBody.contains('no')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(myGetWeightErrResp.msgBody,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
              duration: const Duration(seconds: 3),
              backgroundColor: Theme.of(context).colorScheme.error));
        } else {
          try {
            final jsonResponse = json.decode(myGetWeightErrResp.msgBody);
            myOlUlErrInfo = OlUlErrInfo.fromJson(jsonResponse);
            setState(() {
              olCount = myOlUlErrInfo.olCnt.toString();
              olTime = myOlUlErrInfo.olTime.toString();
              ulCount = myOlUlErrInfo.ulCnt.toString();
              ulTime = myOlUlErrInfo.ulTime.toString();
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(myGetWeightErrResp.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: Theme.of(context).colorScheme.error));
          }
        }
        cntScaleTimerMgr.stopCntScaleTimer();
        cntScaleTimerMgr.startCntScaleTimer(5);
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

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(body: firstLayout(context, _width));
  }

  Widget firstLayout(context, _width) {
    return Container(
        width: _width,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.background),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHead(context, localizedStrings.abnormal_data_title,
                localizedStrings.serial_port_status),
            const SizedBox(height: 5),
            Expanded(
              flex: 3,
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary,
                child: Column(
                  children: [
                    Container(
                        height: 30,
                        color: Theme.of(context).colorScheme.onPrimary,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Text(
                              'Abnormal weight:',
                              style: TextStyle(),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            OutlinedButton(
                                onPressed: isWeightDataBtn
                                    ? () {
                                        cntScaleTimerMgr.stopCntScaleTimer();
                                        PublicFunctions.getWeightErr();
                                        setState(() {
                                          isWeightDataBtn = false;
                                        });
                                      }
                                    : null,
                                child: const Text('Get abnormal data'))
                          ],
                        )),
                    Row(children: [
                      Expanded(
                        flex: 10,
                        child: Container(
                          color: Theme.of(context).colorScheme.onPrimary,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                            child: DataTable(
                              dataRowMinHeight: 40.0,
                              dataRowMaxHeight: 40,
                              showBottomBorder: true,
                              headingRowHeight: 40.0,
                              columnSpacing: 2,
                              horizontalMargin: 2,
                              columns: const [
                                DataColumn(
                                  label: Text('Status'),
                                ),
                                DataColumn(
                                  label: Text('Counts'),
                                ),
                                DataColumn(
                                  label: Text('Total time(s)'),
                                ),
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    const DataCell(Text(
                                      'OL',
                                      style: TextStyle(fontSize: 12),
                                    )),
                                    DataCell(Text(
                                      olCount,
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                    DataCell(Text(
                                      olTime,
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    const DataCell(Text(
                                      'UL',
                                      style: TextStyle(fontSize: 12),
                                    )),
                                    DataCell(Text(
                                      ulCount,
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                    DataCell(Text(
                                      ulTime,
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                  ],
                                ),
                              ],
                              headingRowColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                return Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1); // Use the default value.
                              }),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ));
  }
}
