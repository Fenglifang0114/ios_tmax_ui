import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../../generated/l10n.dart';
import '../data/downloadresponse.dart';
import '../widget/page_head.dart';
import '../widget/timerwidget.dart';

class SetSystemTimePage extends StatefulWidget {
  const SetSystemTimePage({Key? key}) : super(key: key);
  @override
  State<SetSystemTimePage> createState() => SetSystemTimePageState();
}

class SetSystemTimePageState extends State<SetSystemTimePage> {
  dynamic eventBus1;
  dynamic eventBus2;

  String olCount = '-';
  String olTime = '-';
  String ulCount = '-';
  String ulTime = '-';

  DateTime customDate = DateTime.now();
  DateTime customTime = DateTime.now();
  bool isManaul = false;

  TextEditingController deviceTimeCtl = TextEditingController();
  TextEditingController manualTimeCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    deviceTimeCtl.text = '2024-01-11 08:08:08';
    PublicFunctions.getScaleTime();
    eventBus1 = eventBus.on<EventSetScaleTime>().listen((event) {
      if (mounted) {
        PublicFunctions.getScaleTime();
        mySetScaleTimeResp = event.obj;
        if (mySetScaleTimeResp.msgBody.isNotEmpty) {
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
        if (myGetScaleTimeResp.msgBody.isNotEmpty) {
          if (myGetScaleTimeResp.msgBody.contains('ok')) {
            String dataStr = myGetScaleTimeResp.msgBody;
            List<String> parts = dataStr.split(',');

            if (parts.length > 1) {
              String secondPart = parts[1].trim(); // 移除字符串两边的空白字符
              int? intValue = int.tryParse(secondPart);
              if (intValue != null) {
                DateTime dateTime =
                    DateTime.fromMillisecondsSinceEpoch(intValue * 1000);

                String formattedDateTime =
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
                setState(() {
                  deviceTimeCtl.text = formattedDateTime;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('fail to get time',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal)), ////此处需要秤回复
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.red.shade900));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('fail to get time',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal)), ////此处需要秤回复
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.red.shade900));
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(myGetScaleTimeResp.msgBody,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red.shade900));
        }

        setState(() {
          olCount = '50';
          olTime = '2000';
          ulCount = '100';
          ulTime = '20032';
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
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHead(context, localizedStrings.device_time_title),
            const SizedBox(height: 5),
            Expanded(
              flex: 3,
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary,
                child: Column(
                  children: [
                    Container(
                        height: 50,
                        color: Theme.of(context).colorScheme.onPrimary,
                        alignment: Alignment.centerLeft,
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            TimerWidget(),
                          ],
                        )),
                    const Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          child: Text(
                            'Last synced:',
                            style: TextStyle(
                                fontSize: 18, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: deviceTimeCtl,
                            readOnly: true,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
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
                                    var timestamp = (DateTime.now()
                                                .toUtc()
                                                .millisecondsSinceEpoch /
                                            1000)
                                        .truncate();
                                    print(timestamp);
                                    PublicFunctions.setScaleTime(
                                        timestamp.toString());
                                  },
                                  child: btnStyle('Sync now'),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
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
                    isManaul
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: manualTimeCtl,
                                  readOnly: true,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 20,
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
                              OutlinedButton(
                                  onPressed: () {
                                    var timestamp = (customDate
                                                .toUtc()
                                                .millisecondsSinceEpoch /
                                            1000)
                                        .truncate();
                                    print(timestamp);

                                    PublicFunctions.setScaleTime(
                                        timestamp.toString());
                                  },
                                  child: btnStyle('Send Date/Time')),
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
