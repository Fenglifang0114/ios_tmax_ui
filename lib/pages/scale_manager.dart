import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/data/writelog.dart';
import '../data/ipinfodata.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../data/modifyscale_data.dart';
import '../data/scale_info_from_scale.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class ScaleManagerPage extends StatefulWidget {
  const ScaleManagerPage({Key? key}) : super(key: key);

  @override
  State<ScaleManagerPage> createState() => ScaleManagerPageState();
}

class ScaleManagerPageState extends State<ScaleManagerPage> {
  List<NetScaleInfoLocal> scaleNetItems = [];
  List<int> wifiRssiList = [];
  List<String> bssidList = [];
  TextEditingController scaleModelCtl = TextEditingController();
  TextEditingController snCtl = TextEditingController();
  TextEditingController portCtl = TextEditingController();
  TextEditingController ipCtl = TextEditingController();
  TextEditingController gateWayController = TextEditingController();
  // TextEditingController dnsController = TextEditingController();
  final TextEditingController _findWifiText = TextEditingController();
  int selScaleId = -1;
  bool passwordLock = true;
  bool isAddScale = false;
  bool isTesting = false;

  bool isDel = false; //是否执行删除
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;

  Timer? getIpTimer;

  TextEditingController controller = TextEditingController();
  RegExp ipaddressRegex = RegExp(r'[0-9.]');

  RegExp ipRegex = RegExp(
    r'^((\d{1,3}\.){3}\d{1,3})$',
    multiLine: false,
    caseSensitive: false,
  );

  bool _isValidIpAddress(bool tempValid, String value) {
    if (tempValid) {
      List<int?> parts = value.split('.').map(int.tryParse).toList();
      if (parts.any((part) => part == null || part > 255)) {
        tempValid = false;
      }
    }
    return tempValid;
  }

  @override
  void initState() {
    super.initState();

    scaleNetItems = myNetScaleList;
    scaleModelCtl.text = "";
    selScaleId = defaultScaleId;
    if (myNetScaleList.isNotEmpty) {
      defNetScaleInfo =
          NetScaleListMgr.findScaleInfo(myNetScaleList, defaultScaleId);
    }
    if (defNetScaleInfo.scaleId != null) {
      scaleModelCtl.text = defNetScaleInfo.scaleModel!;
      snCtl.text = defNetScaleInfo.scaleSn!;
      ipCtl.text = defNetScaleInfo.ip!;
      portCtl.text = defNetScaleInfo.port!.toString();
    }

    _eventbus1 = eventBus.on<EventRespDelScale>().listen((event) {
      if (mounted) {
        setState(() {
          String dataStr = event.obj;
          if (dataStr.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text((dataStr.contains('ok')) ? "OK" : dataStr,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (dataStr.contains('ok'))
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.error));
            if (dataStr.contains('ok') && isDel) {
              NetScaleListMgr.delScaleById(myNetScaleList, selScaleId);
              manager.delete(selScaleId);
              selScaleId = defaultScaleId;
              isDel = false;
            }
          }
        });
      }
    });

    _eventbus2 = eventBus.on<EventRespAddScale>().listen((event) {
      if (mounted) {
        setState(() {
          isAddScale = false;
          String dataStr = event.obj;
          if (dataStr.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text((dataStr.contains('ok')) ? "OK" : dataStr,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (dataStr.contains('ok'))
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.error));
          }
        });
      }
    });

    _eventbus3 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        setState(() {
          isTesting = false;
          if (myFactoryInfoFromScale.modelName != '') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("OK",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: Theme.of(context).colorScheme.outline));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('fail',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: Theme.of(context).colorScheme.error));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final _width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: pageHeadDesign(
            context,
            localizedStrings.m_scale_title,
            [defaultScaleId],
          ),
        ),
        body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceTint,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                        height: 100,
                        // color: Theme.of(context).colorScheme.primary,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _findWifiText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).colorScheme.surfaceTint,
                                  suffixIcon: IconButton(
                                    splashRadius: 20,
                                    icon: Icon(
                                      Icons.close,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _findWifiText.clear();
                                        scaleNetItems = myNetScaleList;
                                      });
                                    },
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  labelText: 'find ip',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary, // 设置边框颜色
                                      width: 2.0, // 设置边框宽度
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    scaleNetItems = myNetScaleList;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        )),
                    Container(
                      height: 2,
                      color: Theme.of(context).colorScheme.primary, // 蓝色分隔条颜色
                    ),
                    showComScale(),
                    showScaleList(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 6,
              child: Container(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary, // 蓝色分隔条颜色
                            ),
                            showDetailScaleInfo(),
                          ],
                        ),
                      )
                    ],
                  ))),
        ]));
  }

  Widget showDetailScaleInfo() {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                buttonRow(),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 50,
                ),
                showModelName(),
                const SizedBox(
                  height: 20,
                ),
                showScaleSn(),
                const SizedBox(
                  height: 20,
                ),
                showIpAddr(),
                const SizedBox(
                  height: 20,
                ),
                showPort(),
                const SizedBox(
                  height: 60,
                ),
                showConfirmRow(),
              ],
            ),
          ),
        ),
        // 右侧剩余部分分配给此Container
      ),
    );
  }

  Widget showConfirmRow() {
    return isAddScale
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomOutlinedButton(
                btnWidth: 120,
                btnHeight: 40,
                icon: Icons.arrow_forward_ios,
                text: localizedStrings.button_ok,
                onPressed: (ipCtl.text.isNotEmpty && portCtl.text.isNotEmpty)
                    ? () {
                        addScale();
                      }
                    : null,
              ),
              const SizedBox(width: 20),
              CustomOutlinedButton(
                btnWidth: 120,
                btnHeight: 40,
                icon: Icons.exit_to_app,
                text: localizedStrings.button_cancel,
                onPressed: () {
                  setState(() {
                    isAddScale = false;
                  });
                },
              ),
            ],
          )
        : const SizedBox();
  }

  Widget showPort() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 60,
          width: 200,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Port:',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        SizedBox(
          width: 300,
          height: 40,
          child: TextField(
            enabled: isAddScale ? true : false,
            controller: portCtl,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            maxLines: 1,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
              FilteringTextInputFormatter.allow(RegExp(
                  r'^([1-9]|[1-9]\d|[1-9]\d{2}|[1-9]\d{3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$')), // 允许输入数字
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        )
      ],
    );
  }

  Widget showIpAddr() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 60,
          width: 200,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              localizedStrings.ip_address,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        SizedBox(
          width: 300,
          height: 40,
          child: TextField(
            enabled: isAddScale ? true : false,
            controller: ipCtl,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            maxLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        )
      ],
    );
  }

  Widget showScaleSn() {
    return isAddScale
        ? const SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 60,
                width: 200,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'SN:',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 300,
                height: 40,
                child: TextField(
                  enabled: false,
                  controller: snCtl,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 1,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    FilteringTextInputFormatter.allow(RegExp(
                        r'^[ -~!@#$%^&*()_+<>?:"{},.\/;]+$')), // 允许输入数字和点
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              )
            ],
          );
  }

  Widget showModelName() {
    return isAddScale
        ? const SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
                width: 200,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "ScaleModel:",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 300,
                height: 40,
                child: TextField(
                  enabled: false,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                  controller: scaleModelCtl,
                  onChanged: (value) {},
                  maxLines: 1,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(28),
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[\x00-\xF]+$')), // 允许输入数字和点
                  ],
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              )
            ],
          );
  }

  Widget buttonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomOutlinedButton(
          btnWidth: 120,
          btnHeight: 40,
          icon: Icons.add_circle_outline,
          text: 'Add Scale',
          onPressed: isTesting
              ? null
              : () {
                  setState(() {
                    isAddScale = true;
                  });
                },
        ),
        const SizedBox(
          width: 20,
        ),
        CustomOutlinedButton(
          btnWidth: 120,
          btnHeight: 40,
          icon: Icons.delete_outline,
          text: 'Delete Scale',
          onPressed: (isAddScale || isTesting) ||
                  (selScaleId == defaultScaleId) ||
                  selScaleId == 1
              ? null
              : () {
                  setState(() {
                    isDel = true;
                    delScale();
                  });
                },
        ),
        const SizedBox(
          width: 20,
        ),
        CustomOutlinedButton(
          btnWidth: 120,
          btnHeight: 40,
          icon: Icons.scale_outlined,
          text: "Set Default",
          onPressed: (selScaleId == defaultScaleId)
              ? null
              : () {
                  setState(() {
                    defaultScaleId = selScaleId;
                    if (defaultScaleId == 1) {
                      defaultScaleModel = myComScaleInfo.scaleModel;
                      defaultScaleSn = myComScaleInfo.scaleSn;
                      defscaleMedia = myComScaleInfo.portName +
                          ":" +
                          myComScaleInfo.baudRate.toString();
                    } else {
                      var tempscale = NetScaleListMgr.findScaleInfo(
                          myNetScaleList, defaultScaleId);
                      defaultScaleModel = tempscale.scaleModel!;
                      defaultScaleSn = tempscale.scaleSn!;
                      myComScaleInfo.portName +
                          ":" +
                          myComScaleInfo.baudRate.toString();
                      defscaleMedia =
                          tempscale.ip! + ":" + tempscale.port!.toString();
                    }
                  });
                },
        ),
        const SizedBox(
          width: 20,
        ),
        CustomElevatedButton(
          btnWidth: 120,
          btnHeight: 40,
          icon: Icons.connect_without_contact,
          text: 'Test Connect',
          onPressed: !isAddScale && !isTesting && !isDel
              ? () {
                  PublicFunctions.checkSerialPort(selScaleId);
                  setState(() {
                    isTesting = true;
                  });
                }
              : null,
        ),
      ],
    );
  }

  void addScale() {
    myNetInfo.ip = ipCtl.text;
    myNetInfo.port = int.tryParse(portCtl.text)!;
    String netInfoStr = jsonEncode(myNetInfo);
    myMediaConf.mediaInfoJson = netInfoStr;
    myMediaConf.type = 1;
    myModifyScale.scaleId = 10;
    myModifyScale.scaleModel = 'TMax';
    myModifyScale.mediaConf = myMediaConf;
    PublicFunctions.sendAddScale(jsonEncode(myModifyScale));
  }

  void delScale() {
    DelScaleInfo delScale = DelScaleInfo();
    delScale.scaleId = selScaleId;
    String delStr = jsonEncode(delScale);
    PublicFunctions.sendDelScale(delStr);
  }

  Widget showComScale() {
    return ListTile(
      selected: selScaleId == myComScaleInfo.scaleId,
      dense: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              myComScaleInfo.scaleModel,
              maxLines: 1, // 设置文本最大行数为1
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
              width: 150,
              child: Text(
                'SN:' + myComScaleInfo.scaleSn!,
                maxLines: 1, // 设置文本最大行数为1
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              myComScaleInfo.portName,
              maxLines: 1, // 设置文本最大行数为1
              style: const TextStyle(
                fontSize: 12,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              myComScaleInfo.baudRate.toString(),
              maxLines: 1, // 设置文本最大行数为1
              style: const TextStyle(
                fontSize: 12,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              myComScaleInfo.scaleId == defaultScaleId ? "Default" : "",
              maxLines: 1, // 设置文本最大行数为1
              style: const TextStyle(
                fontSize: 12,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
      selectedTileColor: Theme.of(context).colorScheme.primary,
      trailing: const Icon(Icons.cable),
      onTap: () {
        if (!isTesting) {
          setState(() {
            selScaleId = myComScaleInfo.scaleId;
            // 更新文本框中的值
          });
        }
      },
    );
  }

  Widget showScaleList() {
    return Expanded(
      child: ListView.builder(
        itemCount: scaleNetItems.length,
        itemBuilder: (context, index) {
          return SizedBox(
            child: Column(
              children: [
                ListTile(
                  selected: selScaleId == scaleNetItems[index].scaleId,
                  dense: true,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          scaleNetItems[index].scaleModel!,
                          maxLines: 1, // 设置文本最大行数为1
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(
                          width: 150,
                          child: Text(
                            'SN:' + scaleNetItems[index].scaleSn!,
                            maxLines: 1, // 设置文本最大行数为1
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                      SizedBox(
                        width: 50,
                        child: Text(
                          scaleNetItems[index].scaleId == defaultScaleId
                              ? "Default"
                              : "",
                          maxLines: 1, // 设置文本最大行数为1
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'IP:' + scaleNetItems[index].ip!,
                          maxLines: 1, // 设置文本最大行数为1
                          style: const TextStyle(
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Port:' + scaleNetItems[index].port!.toString(),
                          maxLines: 1, // 设置文本最大行数为1
                          style: const TextStyle(
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  ),
                  selectedTileColor: Theme.of(context).colorScheme.primary,
                  trailing: const Icon(Icons.wifi),
                  onTap: () {
                    if (!isTesting && !isAddScale && !isDel) {
                      setState(() {
                        selScaleId = scaleNetItems[index].scaleId!;
                        scaleModelCtl.text = scaleNetItems[index].scaleModel!;
                        snCtl.text = scaleNetItems[index].scaleSn!;
                        ipCtl.text = scaleNetItems[index].ip!;
                        portCtl.text = scaleNetItems[index].port!.toString();

                        print(selScaleId.toString());

                        // 更新文本框中的值
                      });
                    }
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // void sendDataToWifi() {
  //   myScaleCmd.cmdMode = 'send_data_to_wifi';
  //   myScaleCmd.cmdData = 'AT+CWMODE?\r\n';
  //   MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  // }

  // void _startTimer(int time) {
  //   setState(() {
  //     isConnecting = true;
  //   });

  //   _timer = Timer(Duration(seconds: time), () {
  //     setState(() {
  //       isConnecting = false;
  //       errorMessage = 'Time out!';
  //     });
  //   });
  // }

  // void _stopTimer() {
  //   setState(() {
  //     isConnecting = false;
  //   });
  //   _timer?.cancel(); // 停止计时器
  // }

  void sendStaticIpInfo(String ip, String gateway, String netmask) {
    myScaleCmd.cmdMode = 'set_wifi_static_ip';
    myStaticIpInfo.gateway = gateway;
    myStaticIpInfo.ip = ip;
    myStaticIpInfo.netmask = netmask;
    myScaleCmd.cmdData = jsonEncode(myStaticIpInfo).toString();
    PublicFunctions.sendMsg(defaultScaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  bool validateIpFlag(String value) {
    bool isValid = false;

    setState(() {
      if (value != '') {
        isValid = ipRegex.hasMatch(value);
        isValid = _isValidIpAddress(isValid, value);
      } else {
        isValid = true;
      }
    });
    return isValid;
  }
}
