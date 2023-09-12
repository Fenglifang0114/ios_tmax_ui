import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/currentport_data.dart';
import 'package:t_max/data/modifyscale_data.dart';
import '../../data/device_data.dart';
import '../../data/downloadresponse.dart';
import '../../data/scalecmd_data.dart';
import '../../eventbus/eventbus.dart';
import '../../main.dart';
import '../data/cominfoslist_data.dart';
import '../data/comscaleinfo_data.dart';
import '../functions/methods.dart';
import '../generated/l10n.dart';
import '../widget/comportdorpdown.dart';

class ModifyComPortPage extends StatefulWidget {
  const ModifyComPortPage({super.key});

  @override
  _ModifyComPortPageState createState() => _ModifyComPortPageState();
}

class _ModifyComPortPageState extends State<ModifyComPortPage> {
  final TextEditingController _deviceNameController = TextEditingController();
  List<String> comLists = [];
  String comPort = "";
  List<String> baudRateList = [
    '115200',
    '57600',
    '19200',
    '14400',
    '9600',
    '4800',
    '2400'
  ];
  List<String> scaleModelList = ['TMax'];
  String scaleModel = myModifyScale.scaleModel.toString();
  List<String> dataBitsList = ['8', '7', '6', '5'];
  List<String> stopBitsList = ['1', '1.5', '2'];
  List<String> checkBitsList = ['None', 'Odd', 'Even'];
  List<String> protocolList = ['Xon/Xoff', 'None', 'Rts/Cts', 'Dsr/Dtr'];
  String dialogtype = "com";
  String connectionType = "";
  TextEditingController deviceNum =
      TextEditingController(text: myDevicedata.scaleSn);
  TextEditingController model = TextEditingController();
  TextEditingController description = TextEditingController();

  bool isSetting = false;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  var localizedStrings;
  String refresh = " ";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void initState() {
    super.initState();
    PublicFunctions.getPortList();
    checkPortList();
    _deviceNameController.text = '';
    _eventbus1 = eventBus.on<EventConnectBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myConnectBTResponse = event.obj;
          isSetting = false;
          if (myConnectBTResponse.msgBody.isNotEmpty) {}
        });
      }
    });
    _eventbus2 = eventBus.on<EventComInfoList>().listen((event) {
      if (mounted) {
        setState(() {
          myComInfoList = event.obj;
          checkPortList();
        });
      }
    });
    _eventbus3 = eventBus.on<EventComScaleList>().listen((event) {
      if (mounted) {
        setState(() {
          myComScaleList = event.obj;
          if (myComScaleList.comScaleList.isNotEmpty) {
            myDevicedata.name = myComScaleList.comScaleList[0].scaleModel;
            myDevicedata.type = 'icons.usb';
            myDevicedata.scaleID =
                myComScaleList.comScaleList[0].scaleId.toString();
            myCurrentPort.baud = myComScaleList.comScaleList[0].baudRate;
            myCurrentPort.dataBits = myComScaleList.comScaleList[0].dataBits;
            myCurrentPort.devPath = myComScaleList.comScaleList[0].portName;
            myCurrentPort.parity = myComScaleList.comScaleList[0].parity;
            myCurrentPort.stopBits = myComScaleList.comScaleList[0].stopBits;
            myDevicedata.mediaType = myComScaleList.comScaleList[0].tMedia;
            myDevicedata.scaleSn = myComScaleList.comScaleList[0].scaleSn;
          }
        });
      }
    });
    _eventbus4 = eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
        });
      }
    });
    _eventbus5 = eventBus.on<EventCurrentPort>().listen((event) {
      if (mounted) {
        setState(() {
          myCurrentPort = event.obj;
        });
      }
    });
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tempCurrentPort = myCurrentPort;
    // localizedStrings = S.of(context);
    refresh = localizedStrings.refresh_port;
    return AlertDialog(
      title: Container(
          color: Colors.blue.shade900,
          child: Row(
            children: [
              const Icon(Icons.usb, color: Colors.white),
              Text(localizedStrings.serial_modify_title,
                  style: const TextStyle(color: Colors.white))
            ],
          )),
      content: Container(
        height: 356,
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 233, 232, 232)),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  // const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(localizedStrings.scale_model),
                          // ComPortDropdown(
                          //     3, scale_model, myCurrentPort.baud.toString()),
                          const SizedBox(height: 15),
                          Text(localizedStrings.scale_model),
                          Container(
                            height: 53,
                            width: 200,
                            padding: const EdgeInsets.all(0),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              // decoration: const InputDecoration(border: OutlineInputBorder()),
                              // 设置默认值
                              value: scaleModel,
                              // 选择回调
                              onChanged: (String? newPosition) {
                                scaleModel = newPosition.toString();
                              },
                              // 传入可选的数组
                              items: scaleModelList
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem(
                                    value: value, child: Text(value));
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 15),

                          Text(localizedStrings.baud_rate),
                          ComPortDropdown(
                              3, baudRateList, myCurrentPort.baud.toString()),
                          const SizedBox(height: 15),
                          Text(localizedStrings.data_bits),
                          ComPortDropdown(1, dataBitsList,
                              myCurrentPort.dataBits.toString()),
                        ],
                      ),
                      const SizedBox(width: 60),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          Text(localizedStrings.serial_port),
                          Container(
                            height: 53,
                            width: 200,
                            padding: const EdgeInsets.all(0),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              // decoration: const InputDecoration(border: OutlineInputBorder()),
                              // 设置默认值
                              value: comPort,
                              // 选择回调
                              onChanged: (String? newPosition) {
                                PublicFunctions.getPortList();
                                checkPortList();
                                comPort = newPosition.toString();
                                if (comPort != localizedStrings.refresh_port) {
                                  tempCurrentPort.devPath = comPort;
                                } else {
                                  tempCurrentPort.devPath = '';
                                }

                                // setState(() {
                                //   checkPortList();
                                //   // eventBus.fire(EventDialogData(myDialogData));
                                // });
                              },
                              // 传入可选的数组
                              items: comLists.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem(
                                    value: value, child: Text(value));
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(localizedStrings.Parity),
                          ComPortDropdown(
                              4,
                              checkBitsList,
                              (myCurrentPort.parity == 0)
                                  ? (checkBitsList[0])
                                  : (myCurrentPort.parity == 1)
                                      ? (checkBitsList[1])
                                      : (myCurrentPort.parity == 2)
                                          ? (checkBitsList[2])
                                          : checkBitsList[0]),
                          const SizedBox(height: 15),
                          Text(localizedStrings.stop_bits),
                          ComPortDropdown(
                              2,
                              stopBitsList,
                              (myCurrentPort.stopBits == 0)
                                  ? (stopBitsList[0])
                                  : (myCurrentPort.stopBits == 1)
                                      ? (stopBitsList[1])
                                      : (myCurrentPort.stopBits == 2)
                                          ? (stopBitsList[2])
                                          : stopBitsList[0]),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 75),
                ],
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
                child: Text(localizedStrings.button_ok),
                onPressed: () {
                  mySerialPortStatus.serialPortStatus = true;
                  eventBus.fire(EventSerialPortStatus(mySerialPortStatus));
                  if (myCurrentPort.devPath != '') {
                    modifyComInfo();
                  }
                  Navigator.of(context).pop(connectionType);
                }),
            const SizedBox(width: 20),
            OutlinedButton(
                child: Text(localizedStrings.button_cancel),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // to go back to screen after submitting
                })
          ],
        )
      ],
    );
  }

  void sendModifyInfo(String modifyString) {
    myScaleCmd.cmdMode = "modify_scale";
    myScaleCmd.cmdData = modifyString;
    if (kDebugMode) {
      print(jsonEncode(myScaleCmd));
    }
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  void modifyComInfo() {
    String infoString = jsonEncode(tempCurrentPort);
    myMediaConf.mediaInfoJson = infoString;
    myMediaConf.type = myDevicedata.mediaType;
    myModifyScale.scaleId = int.parse(myDevicedata.scaleID);
    myModifyScale.scaleModel = scaleModel;
    myModifyScale.mediaConf = myMediaConf;
    String modifyInfoString = jsonEncode(myModifyScale);
    sendModifyInfo(modifyInfoString);
  }

  void checkPortList() {
    if (myComInfoList.msgBody!.isEmpty == true) {
      comLists = [refresh];
      comPort = refresh;
      tempCurrentPort.devPath = '';
    } else {
      comLists = myComInfoList.msgBody!.toList();
      if (!comLists.contains(comPort)) {
        comPort = comLists[0];
        myCurrentPort.devPath = comPort; //20230411@F
      }
    }
    // getPortList();
  }
}
