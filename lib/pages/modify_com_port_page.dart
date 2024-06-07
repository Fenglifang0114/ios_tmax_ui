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
import '../data/language.dart';
import '../data/modifyresult_data.dart';
import '../data/scale_info_from_scale.dart';
import '../data/screen_mgr.dart';
import '../functions/methods.dart';
import '../widget/comport_dorpdown.dart';
import '../widget/custom_button.dart';

class ModifyComPortPage extends StatefulWidget {
  const ModifyComPortPage({super.key});

  @override
  ModifyComPortPageState createState() => ModifyComPortPageState();
}

class ModifyComPortPageState extends State<ModifyComPortPage> {
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
  dynamic _eventbus6;

  String refresh = " ";
  String serialPortConnect = " ";

  void getScaleList() {
    myScaleCmd.cmdMode = "get_scale_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  @override
  void initState() {
    super.initState();
    PublicFunctions.getPortList();
    checkPortList();
    _deviceNameController.text = '';
    _eventbus1 = eventBus.on<EventRespScaleModify>().listen((event) {
      if (mounted) {
        myModifyAck = event.obj;

        if (myModifyAck.isAck == true) {
          checkSerialPort();
        } else {
          setState(() {
            serialPortConnect = myModifyAck.ackData!;
          });
        }
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

    _eventbus6 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        setState(() {
          myFactoryInfoFromScale = event.obj;
          if (myFactoryInfoFromScale.modelName != '') {
            serialPortConnect = localizedStrings.txt_serial_port_connected;
            myScreenMgr.serialPortST = true;
          } else {
            serialPortConnect = localizedStrings.txt_serial_port_connected_fail;
            myScreenMgr.serialPortST = false;
          }
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
    _eventbus6.cancel();
    deviceNum.dispose();
    model.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tempCurrentPort = myCurrentPort;

    refresh = localizedStrings.refresh_port;
    return AlertDialog(
      title: getDialogTitle(
          context, localizedStrings.serial_modify_title, Icons.usb, 400),
      content: Container(
        height: 356,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: Column(
          children: [
            // const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                        },
                        // 传入可选的数组
                        items: comLists
                            .map<DropdownMenuItem<String>>((String value) {
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
                    ComPortDropdown(
                        1, dataBitsList, myCurrentPort.dataBits.toString()),
                  ],
                ),
                const SizedBox(width: 60),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 106),
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
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  serialPortConnect,
                  style: TextStyle(
                      fontSize: 20,
                      color: (serialPortConnect.contains('fail') ||
                              serialPortConnect.contains('Unable'))
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.outline),
                )
              ],
            )
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.arrow_forward_ios,
              text: localizedStrings.button_connect,
              onPressed: () {
                mySerialPortStatus.serialPortStatus = true;
                eventBus.fire(EventSerialPortStatus(mySerialPortStatus));
                if (myCurrentPort.devPath != '') {
                  setState(() {
                    serialPortConnect = '';
                  });
                  modifyComInfo();
                }
              },
            ),
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.exit_to_app,
              text: localizedStrings.button_exit,
              onPressed: () {
                myScreenMgr.isMainScreen = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

  void checkSerialPort() {
    myScaleCmd.cmdMode = "check_serial_port";
    myScaleCmd.cmdData = '';
    if (kDebugMode) {
      print(jsonEncode(myScaleCmd));
    }
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
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
    if (myComInfoList.msgBody!.isEmpty) {
      comLists = [refresh];
      comPort = refresh;
      tempCurrentPort.devPath = '';
    } else {
      comLists = myComInfoList.msgBody!.toList();
      if (!comLists.contains(comPort)) {
        comPort = comLists[0];
        myCurrentPort.devPath = comPort; //20230411@F
      } else {
        myCurrentPort.devPath = comPort; //20240221@F
      }
    }
    // getPortList();
  }
}
