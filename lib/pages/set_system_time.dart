import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/common.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';
import '../widget/page_head.dart';

class SetSystemTimePage extends StatefulWidget {
  const SetSystemTimePage({super.key});
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
    PublicFunctions.getScaleTime(myDefScaleInfo.defScaleId!);

    eventBus1 = eventBus.on<EventSetScaleTime>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.isNotEmpty) {
          if (myRespDataFromScale.msgBody.contains('ok')) {
            cntScaleTimerMgr.stopCntScaleTimer();
            PublicFunctions.getScaleTime(myDefScaleInfo.defScaleId!);
          } else {
            stopTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  (myRespDataFromScale.msgBody.contains('ok'))
                      ? myRespDataFromScale.msgBody
                      : myRespDataFromScale.msgBody,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
              duration: const Duration(seconds: 3),
              backgroundColor: (myRespDataFromScale.msgBody.contains('ok'))
                  ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                  : Theme.of(context).colorScheme.error));
        }
      }
    });

    eventBus2 = eventBus.on<EventGetScaleTime>().listen((event) {
      if (mounted) {
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
            } else {
              stopTimer();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('failed to get time',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal)), ////此处需要秤回复
                  duration: const Duration(seconds: 3),
                  backgroundColor: Theme.of(context).colorScheme.error));
            }
          } else {
            stopTimer();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('failed to get time',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: Theme.of(context).colorScheme.error));
          }
        } else {
          stopTimer();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(myRespDataFromScale.msgBody,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
              duration: const Duration(seconds: 3),
              backgroundColor: Theme.of(context).colorScheme.error));
        }
        cntScaleTimerMgr.stopCntScaleTimer();
        cntScaleTimerMgr.startCntScaleTimer(5);
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
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus2.cancel();
    _timer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(body: firstLayout(context, width));
  }

  Widget firstLayout(context, width) {
    return Container(
        width: width,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.secondaryFixed),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHeadDefScale(
              context,
              localizedStrings.cTitleDeviceTime,
              localizedStrings.gTipDeviceTimePageHelp,
            ),
            const SizedBox(height: 5),
            Expanded(
              flex: 3,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceTint,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        height: 50,
                        color: Theme.of(context).colorScheme.surfaceTint,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              width: 400,
                              child: Text.rich(
                                TextSpan(
                                    text:
                                        "${deviceTime.year}-${pad0(deviceTime.month)}-${pad0(deviceTime.day)} ${pad0(deviceTime.hour)}:${pad0(deviceTime.minute)}:${pad0(deviceTime.second)}",
                                    style: TextStyle(
                                      fontSize: 30.0,
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                    timestamp.toString(),
                                    myDefScaleInfo.defScaleId!);
                              },
                              child: btnStyle(localizedStrings.cBtnSyncPcTime),
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
                          color: Theme.of(context).colorScheme.surfaceTint,
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
                                  child: btnStyle(localizedStrings.cBtnSetTime),
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
                                width: 400,
                                child: TextField(
                                  controller: manualTimeCtl,
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 30),
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
                                    cntScaleTimerMgr.stopCntScaleTimer();

                                    PublicFunctions.setScaleTime(
                                        timestamp.toString(),
                                        myDefScaleInfo.defScaleId!);
                                  },
                                  child:
                                      btnStyle(localizedStrings.cBtnSyncTime)),
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
                                    width: 200,
                                    child: btnStyle(
                                        localizedStrings.cBtnSelectDate)),
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
                                    }
                                  },
                                  child: btnStyle(
                                      localizedStrings.cBtnSelectTime)),
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
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ));
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(localizedStrings.data_delete_confirm),
          actions: <Widget>[
            OutlinedButton(
              child: Text(localizedStrings.gBtnCancel),
              onPressed: () {
                Navigator.of(context).pop(false); // 不跳转
              },
            ),
            OutlinedButton(
              child: Text(localizedStrings.gBtnConfirm),
              onPressed: () {
                Navigator.of(context).pop(true); // 跳转
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        PublicFunctions.deleteAllRecordsTakeOut(myDefScaleInfo.defScaleId!);
      }
    });
  }
}
