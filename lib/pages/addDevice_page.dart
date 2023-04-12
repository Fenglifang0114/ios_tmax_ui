// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/conninfolist_data.dart';
import 'package:t_max/data/report_data.dart';
import 'package:t_max/data/respdata_data.dart';
import '../common/WebSocketScaleChannel.dart';
import '../data/device_data.dart';
import '../data/downloadresponse.dart';
import '../eventbus/eventbus.dart';
import '../pages/widget/themeColor.dart';
import 'dialog/showComPort_dialog.dart';
import 'labeldesign_page.dart';
import 'widget/reusableListItem.dart';
import 'widget/showWeightReport.dart';
import 'widget/leftSidebar.dart';
import 'widget/appbarMsg.dart';
import 'widget/version.dart';

late WebSocketScaleChannel webchannel1;

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({Key? key}) : super(key: key);

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  List<String> items = [];
  List<String> comPortList = [];
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  List<DataRow> dataRows = [];

  late ScrollController _pageScrollerController;

  String scaleUrl = 'ws://127.0.0.1:7878/tmax?scaleid=1';
  // String scaleUrl = 'ws://10.5.100.89:7878/tmax?scaleid=';

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;

  @override
  void initState() {
    super.initState();
    webchannel1 = WebSocketScaleChannel(scaleUrl);
    // getPortList();
    initScaleList();
    _pageScrollerController = ScrollController();
    _eventbus1 = eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
        });
      }
    });

    _eventbus2 = eventBus.on<EventSerialinfoData>().listen((event) {
      if (mounted) {
        setState(() {
          myReportData = event.obj;
        });
      }
    });

    _eventbus3 = eventBus.on<EventConnInfoList>().listen((event) {
      if (mounted) {
        setState(() {
          myConnInfoList = event.obj;
        });
      }
    });
    _eventbus4 = eventBus.on<EventRespData>().listen((event) {
      if (mounted) {
        setState(() {
          myRespData = event.obj;
        });
      }
    });

    _eventbus5 = eventBus.on<EventComInfoList>().listen((event) {
      if (mounted) {
        setState(() {
          myComInfoList = event.obj;
          checkPortList();
        });
      }
    });

    _eventbus6 = eventBus.on<EventComScaleList>().listen((event) {
      if (mounted) {
        setState(() {
          myComScaleList = event.obj;

          reconnectScale();
          initScaleList();
        });
      }
    });
    _eventbus7 = eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
          // getWeight();
          // getRecords();
        });
      }
    });

    _eventbus8 = eventBus.on<EventSerialPortResponse>().listen((event) {
      if (mounted) {
        setState(() {
          mySerialPortResponse = event.obj;
          if (mySerialPortResponse.msgBody.isNotEmpty &&
              mySerialPortStatus.serialPortStatus) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(mySerialPortResponse.msgBody,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)), ////此处需要秤回复
                duration: const Duration(seconds: 10),
                backgroundColor: Colors.red.shade900));
          }
          mySerialPortStatus.serialPortStatus = false;
          eventBus.fire(EventSerialPortStatus(mySerialPortStatus));
        });
      }
    });

    _eventbus9 = eventBus.on<EventSerialPortStatus>().listen((event) {
      if (mounted) {
        setState(() {
          mySerialPortStatus = event.obj;
        });
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();
    _pageScrollerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        // MaterialApp(
        //   debugShowCheckedModeBanner: false,
        //   theme: themeColor(),
        //   home:
        Scaffold(
      drawer: leftSidebar(context),
      // AppBar：相当于iOS 的导航栏
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: AppBar(
            title: version(),
            actions: [AppbarMsg(context)],
          )),
      body: ListView(
        // 水平拉伸
        scrollDirection: Axis.horizontal,

        children: [
          Container(
            width: 20,
            color: Colors.blue.shade900,
          ),
          Row(
            children: [
              //左侧添加设备
              Container(
                width: 200,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(width: 0.5, color: Colors.black))),
                child: Column(
                  children: <Widget>[
                    //添加设备
                    // Row(
                    //   children: const [
                    //     Icon(Icons.add),
                    //     Text("添加设备："),
                    //     SizedBox(width: 20),
                    //   ],
                    // ),
                    // Row(
                    //   children: [
                    //     TextButton(
                    //         onPressed: () {
                    //           showAddNetworkDialog(context).then((onValue) {
                    //             // print(onValue);
                    //             setState(() {
                    //               items.add(onValue.toString());
                    //             });
                    //           });
                    //         },
                    //         child: const Text("网络")),
                    //     TextButton(
                    //       onPressed: () {
                    //         if (kDebugMode) {
                    //           print(jsonEncode(myScaleCmd));
                    //         }
                    //         checkPortList();

                    //         showAddComPortDialog(context).then((onValue) {
                    //           if (kDebugMode) {
                    //             print(onValue);
                    //           }
                    //           setState(() {
                    //             items.add(onValue.toString());
                    //           });
                    //         });
                    //       },
                    //       child: const Text("串口"),
                    //     ),
                    //     TextButton(
                    //       onPressed: () {
                    //         showAddBluetoothDialog(context).then((onValue) {
                    //           print(onValue);
                    //           setState(() {
                    //             items.add(onValue.toString());
                    //           });
                    //         });
                    //       },
                    //       child: const Text("蓝牙"),
                    //     ),
                    //   ],
                    // ),
                    const Divider(
                      height: 1.0,
                      color: Color(0xFF004a98),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 20, top: 5, right: 20), //设置 child 居中
                      alignment: const Alignment(0, 0),
                      height: 40,
                      width: 220, //边框设置
                      decoration: new BoxDecoration(
                          //背景
                          color: Colors.yellow.shade900,
                          //设置四周圆角 角度
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          //设置四周边框
                          // border: new Border.all(width: 1, color: Colors.red),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.blue,
                                offset: Offset(0.0, 2.0),
                                blurRadius: 1.0,
                                spreadRadius: 1.0),
                          ]),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const LabelDesignPage();
                          }));
                        },
                        child: const Text(
                          "Print Format Design",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 20, top: 5, right: 20), //设置 child 居中
                      alignment: const Alignment(0, 0),
                      height: 40,
                      width: 220, //边框设置
                      decoration: new BoxDecoration(
                          //背景
                          color: Colors.white,
                          //设置四周圆角 角度
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          //设置四周边框
                          // border: new Border.all(width: 1, color: Colors.red),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blue.shade900,
                                offset: const Offset(0.0, 2.0),
                                blurRadius: 1.0,
                                spreadRadius: 1.0),
                          ]),
                      child: const Text(
                        "My device",
                        style: TextStyle(
                            color: Color.fromARGB(255, 13, 73, 161),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    Expanded(
                      child: ListView.builder(
                        controller: _pageScrollerController,
                        itemBuilder: (context, index) {
                          String idContextIcon = (index + 1).toString() +
                              "," +
                              items[index].toString();
                          return ReusableListItem(idContextIcon);
                        },
                        itemCount: items.length,
                      ),
                    ),
                  ],
                ),
              ),
              // GridPage()
              //右侧重量显示
              const ShowWeightReport(),
            ],
          )
        ],
      ),
      // ),
    );
  }

  void reconnectScale() {
    String scaleId;
    if (webchannel1.heartStatus == false) {
      if (myComScaleList.comScaleList.isNotEmpty) {
        scaleId = myComScaleList.comScaleList[0].scaleId.toString();
        // webchannel1 = WebSocketScaleChannel(scaleUrl + scaleId);
        webchannel1 = WebSocketScaleChannel(scaleUrl);
        webchannel1.connect();
      }
    }
  }

  void initScaleList() {
    if (myComScaleList.comScaleList.isNotEmpty) {
      items.clear();
      int tmpLenth = myComScaleList.comScaleList.length;

      for (int i = 0; i < tmpLenth; i++) {
        String iconType = "";
        if (myComScaleList.comScaleList[i].tMedia == 0) {
          if (myComScaleList.comScaleList[i].isOnline == true) {
            iconType = "Icons.usb";
          } else {
            iconType = "Icons.usb_off";
          }
        } else {
          iconType = "Icons.device_unknown";
        }
        items.add(myComScaleList.comScaleList[i].scaleModel.toString() +
            "," +
            iconType +
            "," +
            myComScaleList.comScaleList[i].scaleId.toString());
      }
    }
  }
}
