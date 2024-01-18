import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../../generated/l10n.dart';
import '../data/common.dart';
import '../data/downloadresponse.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../widget/page_head.dart';

class SetSystemTimePage extends StatefulWidget {
  const SetSystemTimePage({Key? key}) : super(key: key);
  @override
  State<SetSystemTimePage> createState() => SetSystemTimePageState();
}

class SetSystemTimePageState extends State<SetSystemTimePage> {
  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventbus3;

  DateTime customDate = DateTime.now();
  DateTime customTime = DateTime.now();
  DateTime deviceTime = DateTime.now();

  bool isManaul = false;

  TextEditingController manualTimeCtl = TextEditingController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();
    PublicFunctions.getScaleTime();

    eventBus1 = eventBus.on<EventSetScaleTime>().listen((event) {
      if (mounted) {
        mySetScaleTimeResp = event.obj;
        if (mySetScaleTimeResp.msgBody.isNotEmpty) {
          if (mySetScaleTimeResp.msgBody.contains('ok')) {
            cntScaleTimerMgr.stopCntScaleTimer();
            PublicFunctions.getScaleTime();
          } else {
            stopTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  (mySetScaleTimeResp.msgBody.contains('ok'))
                      ? mySetScaleTimeResp.msgBody
                      : mySetScaleTimeResp.msgBody,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
              duration: const Duration(seconds: 3),
              backgroundColor: (mySetScaleTimeResp.msgBody.contains('ok'))
                  ? Colors.green.shade900
                  : Colors.red.shade900));
        }
      }
    });

    eventBus2 = eventBus.on<EventGetScaleTime>().listen((event) {
      if (mounted) {
        myGetScaleTimeResp = event.obj;
        if (myGetScaleTimeResp.msgBody.contains('ok')) {
          String dataStr = myGetScaleTimeResp.msgBody;
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
            } else {
              stopTimer();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('failed to get time',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal)), ////此处需要秤回复
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.red.shade900));
            }
          } else {
            stopTimer();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('failed to get time',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.red.shade900));
          }
        } else {
          stopTimer();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(myGetScaleTimeResp.msgBody,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red.shade900));
        }
        cntScaleTimerMgr.stopCntScaleTimer();
        cntScaleTimerMgr.startCntScaleTimer(5);
      }
    });

    eventbus3 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        setState(() {
          myRespCheckSerialPort = event.obj;
          if (myRespCheckSerialPort.msgBody == 'ok') {
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
    _timer?.cancel();
    super.dispose();
  }

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        deviceTime = deviceTime.add(Duration(seconds: 1));
      });
    });
  }

  void stopTimer() {
    setState(() {
      _timer?.cancel();
    });
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
            pageHead(context, localizedStrings.device_time_title,
                localizedStrings.serial_port_status),
            const SizedBox(height: 5),
            Expanded(
              flex: 3,
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary,
                child: Column(
                  children: [
                    const Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          child: Text(
                            'Device time:',
                            style: TextStyle(
                                fontSize: 18, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        height: 50,
                        color: Theme.of(context).colorScheme.onPrimary,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              width: 300,
                              child: Text.rich(
                                TextSpan(
                                    text:
                                        "${deviceTime.year}-${pad0(deviceTime.month)}-${pad0(deviceTime.day)} ${pad0(deviceTime.hour)}:${pad0(deviceTime.minute)}:${pad0(deviceTime.second)}",
                                    style: const TextStyle(
                                      fontSize: 30.0,
                                      color: Colors.blue,
                                      height: 1.5,
                                    )),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            OutlinedButton(
                              onPressed: () {
                                var timestamp = (DateTime.now()
                                            .toUtc()
                                            .millisecondsSinceEpoch /
                                        1000)
                                    .truncate();
                                cntScaleTimerMgr.stopCntScaleTimer();
                                PublicFunctions.setScaleTime(
                                    timestamp.toString());
                              },
                              child: btnStyle('Sync PC Time'),
                            ),
                          ],
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(children: [
                      Expanded(
                        flex: 10,
                        child: Container(
                          color: Theme.of(context).colorScheme.onPrimary,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                            child: Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      isManaul = true;
                                      customDate = customTime = DateTime.now();
                                      String formattedDateTime =
                                          DateFormat('yyyy-MM-dd HH:mm:ss')
                                              .format(DateTime.now());
                                      manualTimeCtl.text = formattedDateTime;
                                    });
                                  },
                                  child: btnStyle('Set Date/Time'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(
                      height: 40,
                    ),
                    isManaul
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  controller: manualTimeCtl,
                                  readOnly: true,
                                  style: TextStyle(fontSize: 30),
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              OutlinedButton(
                                  onPressed: () {
                                    var timestamp = (customDate
                                                .toUtc()
                                                .millisecondsSinceEpoch /
                                            1000)
                                        .truncate();
                                    print(timestamp);
                                    cntScaleTimerMgr.stopCntScaleTimer();

                                    PublicFunctions.setScaleTime(
                                        timestamp.toString());
                                  },
                                  child: btnStyle('Sync Time')),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 40,
                    ),
                    isManaul
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  DateTime? selectDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2018, 3, 5),
                                      lastDate: DateTime(2100, 3, 5),
                                      locale:
                                          Locale(Intl.getCurrentLocale(), ''));

                                  if (selectDate != null) {
                                    setState(() {
                                      customDate = selectDate;
                                      customDate = DateTime(
                                          customDate.year,
                                          customDate.month,
                                          customDate.day,
                                          customTime.hour,
                                          customTime.minute,
                                          0);
                                      manualTimeCtl.text =
                                          DateFormat('yyyy-MM-dd HH:mm:ss')
                                              .format(customDate);
                                    });
                                  }
                                },
                                child: SizedBox(
                                    width: 200, child: btnStyle('Select Date')),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              OutlinedButton(
                                  onPressed: () async {
                                    TimeOfDay? selectedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (selectedTime != null) {
                                      String formattedTime =
                                          DateFormat('yyyy-MM-dd HH:mm:ss')
                                              .format(DateTime(
                                                  customDate.year,
                                                  customDate.month,
                                                  customDate.day,
                                                  selectedTime.hour,
                                                  selectedTime.minute,
                                                  0));
                                      customTime = DateTime(
                                          customDate.year,
                                          customDate.month,
                                          customDate.day,
                                          selectedTime.hour,
                                          selectedTime.minute,
                                          0);
                                      customDate = customTime;
                                      manualTimeCtl.text = formattedTime;
                                      print('Selected Time: $selectedTime');
                                    }
                                  },
                                  child: btnStyle('Select Time')),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget btnStyle(String head) {
    return SizedBox(
        width: 200,
        child: Text(
          head,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.blue),
        ));
  }

  _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.confirm_title,
            style: const TextStyle(color: Color.fromARGB(255, 15, 71, 161)),
          ),
          content: Text(localizedStrings.data_delete_confirm),
          actions: <Widget>[
            OutlinedButton(
              child: Text(localizedStrings.button_cancel),
              onPressed: () {
                Navigator.of(context).pop(false); // 不跳转
              },
            ),
            OutlinedButton(
              child: Text(localizedStrings.confirm_btn),
              onPressed: () {
                Navigator.of(context).pop(true); // 跳转
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        PublicFunctions.deleteAllRecordsTakeOut();
      }
    });
  }
}
