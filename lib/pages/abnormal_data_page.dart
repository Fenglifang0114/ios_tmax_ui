import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/olul_err_data.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../../generated/l10n.dart';
import '../widget/page_head.dart';

class AbnormalDataPage extends StatefulWidget {
  const AbnormalDataPage({Key? key}) : super(key: key);
  @override
  State<AbnormalDataPage> createState() => AbnormalDataPageState();
}

class AbnormalDataPageState extends State<AbnormalDataPage> {
  dynamic eventBus14;
  String olCount = '-';
  String olTime = '-';
  String ulCount = '-';
  String ulTime = '-';

  bool isWeightDataBtn = true;

  @override
  void initState() {
    super.initState();
    PublicFunctions.getWeightErr();

    isWeightDataBtn = false;

    eventBus14 = eventBus.on<EventGetWeightErr>().listen((event) {
      if (mounted) {
        myGetWeightErrResp = event.obj;
        setState(() {
          isWeightDataBtn = true;
        });

        if (myGetWeightErrResp.msgBody.isNotEmpty) {
          if (myGetWeightErrResp.msgBody.contains('fail') ||
              myGetWeightErrResp.msgBody.contains('no')) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(myGetWeightErrResp.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.red.shade900));
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
                  backgroundColor: Colors.red.shade900));
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    eventBus14.cancel();
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
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHead(context, localizedStrings.abnormal_data_title),
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
                                      'Overload anomalies',
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
                                      'Underload anomalies',
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
