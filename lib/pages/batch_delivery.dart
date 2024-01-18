import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/timer_manager.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/main.dart';
import '../data/downloadresponse.dart';
import '../data/parse_log.dart';
import '../data/screen_mgr.dart';
import '../data/writelog.dart';
import '../eventbus/eventbus.dart';
import '../generated/l10n.dart';
import '../widget/page_head.dart';

class BatchDeliveryPage extends StatefulWidget {
  const BatchDeliveryPage({Key? key}) : super(key: key);

  @override
  State<BatchDeliveryPage> createState() => _BatchDeliveryPageState();
}

class _BatchDeliveryPageState extends State<BatchDeliveryPage> {
  List<String> outputData = [];
  List<CheckBoxData> checkBoxData = [];
  List<Map<String, dynamic>> jsonDataList = [];
  List<String> ipListNew = [];
  String lastIpStr = '';

  final ScrollController _scrollController = ScrollController();
  TextEditingController btNameCtl = TextEditingController();
  TextEditingController wifiNameCtl = TextEditingController();
  TextEditingController ipAddrCtl = TextEditingController();
  TextEditingController prnFmt1Ctl = TextEditingController();
  TextEditingController prnFmt2Ctl = TextEditingController();
  TextEditingController prnFmt3Ctl = TextEditingController();
  TextEditingController prnFmt4Ctl = TextEditingController();

  TextEditingController serialOutput1Ctl = TextEditingController();
  TextEditingController serialOutput2Ctl = TextEditingController();
  TextEditingController serialOutput3Ctl = TextEditingController();
  TextEditingController serialOutput4Ctl = TextEditingController();
  TextEditingController serialOutput5Ctl = TextEditingController();
  TextEditingController serialOutput6Ctl = TextEditingController();

  String logContant = '';
  late ColorScheme colorScheme;

  bool isWifiSelect = false;
  bool isBtSelect = false;
  bool isPrnFmtSelect = false;
  bool isSerialOutput = false;
  bool isModifyBtName = false;
  bool isModifyBtPower = false;
  bool isConnectAp = false;
  bool isConnectDhcp = false;
  bool isConnectStaticIp = false;
  bool isAutoIncrease = false;
  bool isIpListSelect = false;
  bool ipIsUsedUp = false;
  bool isDownloading = false;

  bool prnFmt1 = false;
  bool prnFmt2 = false;
  bool prnFmt3 = false;
  bool prnFmt4 = false;

  int downLoadIndex = 0;

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;

  TextEditingController _ipListCtl = TextEditingController();

  void getLog() async {
    logContant = await readlog();
    jsonDataList = parseLog(logContant, '');
    String btNameStr = getBtNameFromLog(jsonDataList);
    if (btNameStr.isNotEmpty) {
      setState(() {
        btNameCtl.text = btNameStr;
        isModifyBtName = true;
      });
    }
    String wifiName = getWifiNameFromLog(jsonDataList);
    if (wifiName.isNotEmpty) {
      setState(() {
        wifiNameCtl.text = wifiName;
        isConnectAp = true;
      });
    }
    String ipAddrStr = getIpAddrFromLog(jsonDataList);
    if (isConnectAp && ipAddrStr.isNotEmpty) {
      setState(() {
        lastIpStr = ipAddrStr;
        ipAddrCtl.text = ipAddrStr;
        isConnectStaticIp = true;
      });
    }
    if (isConnectAp && !isConnectStaticIp) {
      isConnectDhcp = true;
    } else {
      isConnectDhcp = false;
    }
    List<String> prnFmtList = getPrintFmtFromLog(jsonDataList);
    if (prnFmtList.isNotEmpty) {
      setState(() {
        for (int i = 0; i < prnFmtList.length; i++) {
          String text = prnFmtList[i];
          if (i == 0) {
            prnFmt1 = true;
            prnFmt1Ctl.text = text;
          } else if (i == 1) {
            prnFmt2 = true;
            prnFmt2Ctl.text = text;
          } else if (i == 2) {
            prnFmt3 = true;
            prnFmt3Ctl.text = text;
          } else if (i == 3) {
            prnFmt4 = true;
            prnFmt4Ctl.text = text;
          }
        }
      });
    }

    List<String> serialOutputList = getSerialOutputFromLog(jsonDataList);
    if (serialOutputList.isNotEmpty) {
      setState(() {
        for (int i = 0; i < serialOutputList.length; i++) {
          String text = serialOutputList[i];
          if (i == 0) {
            serialOutput1Ctl.text = text;
          } else if (i == 1) {
            serialOutput2Ctl.text = text;
          } else if (i == 2) {
            serialOutput3Ctl.text = text;
          } else if (i == 3) {
            serialOutput4Ctl.text = text;
          } else if (i == 4) {
            serialOutput5Ctl.text = text;
          } else if (i == 5) {
            serialOutput6Ctl.text = text;
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.startCntScaleTimer(5);

    ipAddrCtl.text = '';
    wifiNameCtl.text = '';
    btNameCtl.text = '';
    prnFmt1Ctl.text = '';
    prnFmt2Ctl.text = '';
    prnFmt3Ctl.text = '';
    prnFmt4Ctl.text = '';

    checkBoxData = [
      CheckBoxData(
        name: 'Wifi Setting', // 使用翻译字段
        value: false,
      ),
      CheckBoxData(
        name: 'Bluetooth Setting',
        value: true,
      ),
      CheckBoxData(
        name: 'Location Setting',
        value: false,
      ),
    ];
    getLog();

    _eventbus1 = eventBus.on<EventSerialOutputResp>().listen((event) {
      if (mounted) {
        setState(() {
          mySetSerialOutputResp = event.obj;
          if (mySetSerialOutputResp.msgBody.isNotEmpty) {
            outputData.add(getDateTime() +
                ':' +
                'Download Serial OutPut' +
                '\r\n' +
                mySetSerialOutputResp.msgBody +
                '\r\n');
          }
        });

        performNextDask();
      }
    });
    _eventbus2 = eventBus.on<EventDownPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myDownPrnFmtResp = event.obj;
          if (myDownPrnFmtResp.msgBody.isNotEmpty) {
            outputData.add(getDateTime() +
                ':' +
                'Download Print Format' +
                '\r\n' +
                myDownPrnFmtResp.msgBody +
                '\r\n');
          }
        });
        performNextDask();
      }
    });

    _eventbus3 = eventBus.on<EventConnectBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myConnectBTResponse = event.obj;

          if (myConnectBTResponse.msgBody.isNotEmpty) {
            outputData.add(getDateTime() +
                ':' +
                'Modify Bluetooth Name' +
                '\r\n' +
                myConnectBTResponse.msgBody +
                '\r\n');
          }
        });
        performNextDask();
      }
    });
    _eventbus4 = eventBus.on<EventBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myRespBTData = event.obj;

          if (myRespBTData.msgBody.isNotEmpty) {
            outputData.add(getDateTime() +
                ':' +
                'Modify Emission Power' +
                '\r\n' +
                myRespBTData.msgBody +
                '\r\n');
          }
        });
        performNextDask();
      }
    });
    _eventbus5 = eventBus.on<EventConnectAp>().listen((event) {
      if (mounted) {
        setState(() {
          myConnectApResponse = event.obj;
          if (myConnectApResponse.msgBody.isNotEmpty) {
            outputData.add(getDateTime() +
                ':' +
                'Connect Ap' +
                '\r\n' +
                myConnectApResponse.msgBody +
                '\r\n');
          }
        });
        performNextDask();
      }
    });

    _eventbus6 = eventBus.on<EventConnectStaticIp>().listen((event) {
      if (mounted) {
        setState(() {
          mySetStaticIpResp = event.obj;
          if (mySetStaticIpResp.msgBody.isNotEmpty) {
            outputData.add(getDateTime() +
                ':' +
                'Connect Static Ip' +
                '\r\n' +
                mySetStaticIpResp.msgBody +
                '\r\n');
          }
        });
        performNextDask();
      }
    });
    _eventbus7 = eventBus.on<EventConnectDynamicIp>().listen((event) {
      if (mounted) {
        setState(() {
          mySetDynamicIpResp = event.obj;
          if (mySetDynamicIpResp.msgBody.isNotEmpty) {
            outputData.add(getDateTime() +
                ':' +
                'Connect Dynamic Ip' +
                '\r\n' +
                mySetDynamicIpResp.msgBody +
                '\r\n');
          }
        });
        performNextDask();
      }
    });
    _eventbus8 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
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

  String getDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  void performNextDask() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });

    performDownload();
  }

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  String convertHexToAsciiString(String hexString) {
    final bytes = hexString
        .replaceAll(" ", "")
        .split('')
        .map((e) => int.parse(e, radix: 16))
        .toList();

    final codePoints = List<int>.generate(
        bytes.length ~/ 2, (i) => bytes[i * 2] * 16 + bytes[i * 2 + 1]);
    final asciiCharacters =
        codePoints.map((codePoint) => String.fromCharCode(codePoint)).toList();
    return asciiCharacters.join('');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          height: 50,
          width: screenSize.width - 10,
          color: colorScheme.primary,
          child: pageHead(
              context, 'Batch Delivery', localizedStrings.serial_port_status),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 5,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: titleStyle('Setting'),
                  ),
                  Expanded(
                    flex: 5, // 设置子部件占用空间的比例
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5), // 设置上下边距值
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isWifiSelect,
                                  onChanged: (value) {
                                    setState(() {
                                      isWifiSelect = value!;
                                      if (isWifiSelect) {
                                        isBtSelect = false;
                                      }
                                    });
                                  },
                                ),
                                textStyle(localizedStrings.wifi_setting_title,
                                    constraints),
                                // 省略部分代码
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isBtSelect,
                                  onChanged: (value) {
                                    setState(() {
                                      isBtSelect = value!;
                                      if (isBtSelect) {
                                        isWifiSelect = false;
                                      }
                                    });
                                  },
                                ),
                                textStyle(localizedStrings.bt_setting_title,
                                    constraints),
                                // 省略部分代码
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isPrnFmtSelect,
                                  onChanged: (value) {
                                    setState(() {
                                      isPrnFmtSelect = value!;
                                    });
                                  },
                                ),
                                textStyle(
                                    localizedStrings.print_format_download,
                                    constraints),
                                // 省略部分代码
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isSerialOutput,
                                  onChanged: (value) {
                                    setState(() {
                                      isSerialOutput = value!;
                                    });
                                  },
                                ),
                                textStyle(localizedStrings.serial_output,
                                    constraints),
                                // 省略部分代码
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  Expanded(
                      flex: 1, // 设置子部件占用空间的比例
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // SizedBox(
                          //   width: 150,
                          //   height: 50,
                          //   child: OutlinedButton(
                          //     style: OutlinedButton.styleFrom(
                          //       side: BorderSide(
                          //         width: 1,
                          //         color: Theme.of(context).colorScheme.primary,
                          //       ),
                          //       foregroundColor:
                          //           Theme.of(context).colorScheme.primary,
                          //       backgroundColor: Theme.of(context)
                          //           .colorScheme
                          //           .onPrimary, // 设置按钮的背景色
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius:
                          //             BorderRadius.circular(4), // 设置按钮的圆角
                          //       ),
                          //     ),
                          //     child: Center(
                          //       child: Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceEvenly,
                          //         children: [
                          //           Icon(
                          //             Icons.home,
                          //             color:
                          //                 Theme.of(context).colorScheme.primary,
                          //           ),
                          //           Text(
                          //             localizedStrings.button_home,
                          //             maxLines: 1,
                          //             overflow: TextOverflow.ellipsis,
                          //             style: TextStyle(
                          //                 color: Theme.of(context)
                          //                     .colorScheme
                          //                     .primary,
                          //                 fontSize: 14,
                          //                 fontWeight: FontWeight.normal),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //     onPressed: () {
                          //       PublicFunctions.closeScalePassth();
                          //       myScreenMgr.isMainScreen = true;
                          //       Navigator.of(context).pop();
                          //     },
                          //   ),
                          // ),
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: OutlinedButton(
                              style: !isDownloading
                                  ? OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        width: 1,
                                        color: colorScheme.primary,
                                      ),
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      backgroundColor:
                                          colorScheme.primary, // 设置按钮的背景色
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4), // 设置按钮的圆角
                                      ),
                                    )
                                  : OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        width: 1,
                                        color: colorScheme.secondaryContainer,
                                      ),
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      backgroundColor: colorScheme
                                          .secondaryContainer, // 设置按钮的背景色
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4), // 设置按钮的圆角
                                      ),
                                    ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.download,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    Text(
                                      localizedStrings.download,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: isDownloading
                                  ? null
                                  : () {
                                      if (checkDownload()) {
                                        downLoadIndex = 0;
                                        performDownload();
                                        setState(() {
                                          isDownloading = true;
                                          cntScaleTimerMgr.stopCntScaleTimer();
                                        });
                                      }
                                    },
                            ),
                          ),
                        ],
                      )),
                ],
              )),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: ListView(
                      children: [
                        titleStyle('Bluetooth:'),
                        isBtSelect && isModifyBtName
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Bt Name',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 30,
                                    child: TextField(
                                      controller: btNameCtl,
                                      readOnly: false,
                                      maxLines: 1,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                child:
                                    Text('', overflow: TextOverflow.ellipsis)),
                        const SizedBox(
                          height: 5,
                        ),
                        titleStyle('WiFi:'),
                        (isWifiSelect && isConnectAp)
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Connect Ap',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 30,
                                    child: TextField(
                                      controller: wifiNameCtl,
                                      readOnly: true,
                                      maxLines: 1,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                child:
                                    Text('', overflow: TextOverflow.ellipsis)),
                        (isWifiSelect && isConnectDhcp)
                            ? const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Set DHCP',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              )
                            : const SizedBox(),
                        isWifiSelect && isConnectStaticIp
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Set Static Ip',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        height: 30,
                                        child: TextField(
                                          controller: ipAddrCtl,
                                          readOnly: false,
                                          maxLines: 1,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // (isWifiSelect && isConnectStaticIp)
                                  //     ? Row(
                                  //         children: [
                                  //           Checkbox(
                                  //             value: isAutoIncrease,
                                  //             onChanged: (value) {
                                  //               isAutoIncrease = value!;
                                  //               if (isAutoIncrease) {
                                  //                 setState(() {
                                  //                   isIpListSelect = false;
                                  //                 });
                                  //                 performAutoIp();
                                  //               }
                                  //             },
                                  //           ),
                                  //           Text(
                                  //             'ip Auto-increase',
                                  //             overflow: TextOverflow.ellipsis,
                                  //             maxLines: 1,
                                  //             style: TextStyle(
                                  //                 color: Theme.of(context)
                                  //                     .colorScheme
                                  //                     .primary),
                                  //           ),

                                  //           // 省略部分代码
                                  //         ],
                                  //       )
                                  //     : const SizedBox(),
                                  (isWifiSelect && isConnectStaticIp)
                                      ? Row(
                                          children: [
                                            Checkbox(
                                              value: isIpListSelect,
                                              onChanged: (value) {
                                                setState(() {
                                                  isIpListSelect = value!;
                                                  if (isIpListSelect) {
                                                    isAutoIncrease = false;
                                                    getIpListFormFile();
                                                    _showEditIpList(context);
                                                  }
                                                });
                                              },
                                            ),
                                            Text(
                                              'ip List',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                            ),

                                            // 省略部分代码
                                          ],
                                        )
                                      : const SizedBox(),
                                ],
                              )
                            : const SizedBox(),
                        titleStyle('Print Format:'),
                        SizedBox(
                          height: 280,
                          child: Column(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: prnFmt1Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: prnFmt2Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: prnFmt3Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: prnFmt4Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        titleStyle('Serial Output:'),
                        SizedBox(
                          height: 400,
                          child: Column(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: serialOutput1Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: serialOutput2Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: serialOutput3Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: serialOutput4Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: serialOutput5Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: serialOutput6Ctl,
                                  readOnly: true,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 5,
              child: Column(
                children: [
                  Text(
                    'Download Result:',
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 20,
                        color: colorScheme.primary),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue, // 边框颜色
                          width: 1.0, // 边框宽度
                        ),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(10.0)), // 边框圆角
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10.0), // 添加边距
                        itemCount: outputData.length,
                        itemBuilder: (context, index) {
                          return Text(outputData[index]);
                        },
                        controller: _scrollController,
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  String ipFilePath = '';

  performAutoIp() {
    if (isValidIPAddress(lastIpStr)) {
      ipListNew = generateIpRange(lastIpStr);
      if (ipListNew.isNotEmpty) {
        ipIsUsedUp = false;
        setState(() {
          ipAddrCtl.text = ipListNew[0];
        });

        ipListNew.removeAt(0);
      } else {
        ipIsUsedUp = true;
      }
    }
  }

  List<String> generateIpRange(String start) {
    List<int> startParts = start.split(".").map((e) => int.parse(e)).toList();
    List<String> ipList = [];
    if (startParts[3] >= 254) {
      return ipList;
    }
    for (var i = startParts[3] + 1; i <= 254; i++) {
      startParts[3] = i;
      ipList.add(
          "${startParts[0]}.${startParts[1]}.${startParts[2]}.${startParts[3]}");
    }
    return ipList;
  }

  getIpListFormFile() async {
    ipFilePath = await getAppFilePath(myIpListName);
    bool fileExists = await File(ipFilePath).exists();
    if (!fileExists) {
      await File(ipFilePath).create(recursive: true);
    } else {
      String fileContent = await File(ipFilePath).readAsString();
      setState(() {
        _ipListCtl.text = fileContent;
      });
    }
  }

  void _showErrorDialog(BuildContext context, String tipStr) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.confirm_title,
            style: const TextStyle(color: Color.fromARGB(255, 15, 71, 161)),
          ),
          content: SizedBox(
            width: 300,
            height: 70,
            child: Text(
              tipStr,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: <Widget>[
            SizedBox(
              height: 30,
              child: OutlinedButton(
                child: Text(localizedStrings.confirm_btn),
                onPressed: () {
                  Navigator.of(context).pop(true); // 跳转
                },
              ),
            )
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          isDownloading = false;

          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.startCntScaleTimer(5);
        });
      }
    });
  }

  void _showEditIpList(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text(
            'Edit Ip List',
            style: TextStyle(color: Color.fromARGB(255, 15, 71, 161)),
          ),
          content: SizedBox(
              width: 400,
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ipListCtl,
                      maxLines: null, // 可以无限制地输入多行文本
                      decoration: const InputDecoration(
                        labelText: 'Edit your ip list here',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              )),
          actions: <Widget>[
            OutlinedButton(
              child: Text(localizedStrings.button_cancel),
              onPressed: () {
                setState(() {
                  isIpListSelect = false;
                  ipListNew = [];
                });
                Navigator.of(context).pop(false); // 不跳转
              },
            ),
            OutlinedButton(
              child: Text(localizedStrings.confirm_btn),
              onPressed: () {
                if (generateIpList()) {
                  Navigator.of(context).pop(true);
                } else {
                  _showErrorDialog(context, 'ip is not valid');
                }
                // 跳转
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          ipAddrCtl.text = ipListNew[0];
          ipListNew.removeAt(0);
        });
      }
    });
  }

  bool isValidIPAddress(String ipAddress) {
    // IP地址的正则表达式
    RegExp ipRegex = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return ipRegex.hasMatch(ipAddress);
  }

  bool generateIpList() {
    ipListNew = [];
    if (_ipListCtl.text.isNotEmpty) {
      List<String> lines = LineSplitter.split(_ipListCtl.text).toList();

      for (String line in lines) {
        String trimSpaceStr = line.replaceAll(r'\s', '');
        bool isValid = isValidIPAddress(trimSpaceStr);
        if (isValid) {
          ipListNew.add(trimSpaceStr);
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
    File(ipFilePath).writeAsStringSync('');
    for (int i = 0; i < ipListNew.length; i++) {
      File(ipFilePath)
          .writeAsStringSync(ipListNew[i] + '\r\n', mode: FileMode.append);
    }
    if (ipListNew.isNotEmpty) {
      ipIsUsedUp = false;
    }

    return true;
  }

  bool checkDownload() {
    if (!isWifiSelect && !isBtSelect && !isPrnFmtSelect && !isSerialOutput) {
      _showErrorDialog(context, 'No downloads were selected');
      return false;
    }
    if (isBtSelect && !isModifyBtName) {
      _showErrorDialog(context, 'No bluetooth record');
      return false;
    }

    if (isBtSelect && btNameCtl.text == '') {
      _showErrorDialog(context, 'Please enter a Bluetooth name');
      return false;
    }
    if (isWifiSelect && !isConnectAp) {
      _showErrorDialog(context, 'No WiFi connection logging');
      return false;
    }

    if (isWifiSelect && !isConnectDhcp && !isConnectStaticIp) {
      _showErrorDialog(context, 'No IP address mode,DHCP or Static');
      return false;
    }
    if (isWifiSelect &&
        isConnectStaticIp &&
        !(isAutoIncrease || isIpListSelect)) {
      _showErrorDialog(context, 'Please select a static IP rule');
      return false;
    }
    if (isWifiSelect &&
        isConnectStaticIp &&
        (isAutoIncrease || isIpListSelect) &&
        ipIsUsedUp) {
      _showErrorDialog(context, 'Static IP addresses have been used up');
      return false;
    }

    if (isPrnFmtSelect &&
        (prnFmt1Ctl.text.isEmpty &&
            prnFmt2Ctl.text.isEmpty &&
            prnFmt3Ctl.text.isEmpty &&
            prnFmt4Ctl.text.isEmpty)) {
      _showErrorDialog(context, 'No print format');
      return false;
    }
    if (isSerialOutput &&
        (serialOutput1Ctl.text.isEmpty &&
            serialOutput2Ctl.text.isEmpty &&
            serialOutput3Ctl.text.isEmpty &&
            serialOutput4Ctl.text.isEmpty &&
            serialOutput5Ctl.text.isEmpty &&
            serialOutput6Ctl.text.isEmpty)) {
      _showErrorDialog(context, 'No Serial Output format');
      return false;
    }

    return true;
  }

  void performDownload() {
    for (int i = 0; i < 7; i++) {
      if (downLoadIndex == 0 &&
          isBtSelect &&
          isModifyBtName &&
          btNameCtl.text.isNotEmpty) {
        outputData.add(
            getDateTime() + ':' + 'Now modify the Bluetooth name' + '\r\n');
        PublicFunctions.modifyBtName(btNameCtl.text);
        downLoadIndex++;
        return;
      }

      if (downLoadIndex == 2 && isWifiSelect && isConnectAp) {
        List<Map<String, dynamic>> filteredList =
            jsonDataList.where((item) => item["Req"] == "connect_ap").toList();

        if (filteredList.isNotEmpty) {
          outputData.add(getDateTime() + ':' + 'Now set AP info ' + '\r\n');
          MyApp.webchannel1.sendMessage(jsonEncode(filteredList[0]));
          writelog(jsonEncode(filteredList[0]));
        }

        downLoadIndex++;

        return;
      }
      if (downLoadIndex == 3 && isWifiSelect && isConnectDhcp) {
        outputData.add(getDateTime() + ':' + 'Now set DHCP' + '\r\n');
        PublicFunctions.setWifiDynamicMode();
        downLoadIndex++;

        return;
      }
      if (downLoadIndex == 4 && isWifiSelect && isConnectStaticIp) {
        List<Map<String, dynamic>> filteredList = jsonDataList
            .where((item) => item["Req"] == "set_wifi_static_ip")
            .toList();
        if (filteredList.isNotEmpty) {
          Map<String, dynamic> jsonWifi =
              jsonDecode((filteredList[0])['ReqData']);
          jsonWifi['ip'] = ipAddrCtl.text;
          filteredList[0]['ReqData'] = jsonEncode(jsonWifi);
          outputData.add(getDateTime() + ':' + 'Now set static ip' + '\r\n');

          MyApp.webchannel1.sendMessage(jsonEncode(filteredList[0]));
          writelog(jsonEncode(filteredList[0]));
        }
        downLoadIndex++;

        return;
      }
      if (downLoadIndex == 5 && isPrnFmtSelect) {
        List<Map<String, dynamic>> filteredList = jsonDataList
            .where((item) => item["Req"] == "down_print_format_to_scale")
            .toList();
        if (filteredList.isNotEmpty) {
          outputData
              .add(getDateTime() + ':' + 'Now download print format' + '\r\n');
          MyApp.webchannel1.sendMessage(jsonEncode(filteredList[0]));
          writelog(jsonEncode(filteredList[0]));
        }
        downLoadIndex++;
        return;
      }
      if (downLoadIndex == 6 && isSerialOutput) {
        List<Map<String, dynamic>> filteredList = jsonDataList
            .where((item) => item["Req"] == "set_output_format")
            .toList();
        outputData.add(getDateTime() + ':' + 'Now set output format' + '\r\n');
        MyApp.webchannel1.sendMessage(jsonEncode(filteredList[0]));
        writelog(jsonEncode(filteredList[0]));
        downLoadIndex++;
        return;
      }

      downLoadIndex++;
    }

    _showErrorDialog(context, 'This download is complete');
    outputData.add('----------------------------------');
    outputData.add('----------------------------------');
    scrollToBottom();

    if (isWifiSelect &&
        isConnectStaticIp &&
        (isAutoIncrease || isIpListSelect)) {
      if (ipListNew.isNotEmpty) {
        setState(() {
          ipAddrCtl.text = ipListNew[0];
        });

        ipListNew.removeAt(0);
      } else {
        ipIsUsedUp = true;
      }
    }
  }

  void scrollToBottom() {
    // 滚动到底部
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100), // 滚动续时间
        curve: Curves.easeInOut // 滚动曲线
        );
  }

  Widget titleStyle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 30,
      color: colorScheme.scrim,
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget textStyle(String title, BoxConstraints constraint) {
    return SizedBox(
      width: constraint.maxWidth - 35,
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget checkBoxRow(
      String nameString, bool selectFlag, void Function(bool?)? onChanged) {
    // 省略部分代码
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Checkbox(
          value: selectFlag,
          onChanged: onChanged,
        ),
        // 省略部分代码
      ],
    );
  }
}

class CheckBoxData {
  final String name;
  bool value;
  CheckBoxData({
    required this.name,
    required this.value,
  });
}
