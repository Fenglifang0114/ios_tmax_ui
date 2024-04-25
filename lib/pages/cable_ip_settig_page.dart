import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/functions/methods.dart';
import '../data/downloadresponse.dart';
import '../data/scale_info_from_scale.dart';
import '../data/screen_mgr.dart';
import '../data/server_ip_data.dart';
import '../data/timer_manager.dart';
import '../eventbus/eventbus.dart';
import '../generated/l10n.dart';
import '../widget/page_head.dart';
import '../widget/wifitextfeild.dart';

class CableIpSettingPage extends StatefulWidget {
  const CableIpSettingPage({Key? key}) : super(key: key);

  @override
  State<CableIpSettingPage> createState() => CableIpSettingPageState();
}

class CableIpSettingPageState extends State<CableIpSettingPage> {
  TextEditingController netMaskController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController gateWayController = TextEditingController();
  TextEditingController serverIpCtl = TextEditingController();
  TextEditingController serverPortCtl = TextEditingController();

  bool isDownloadClicked = false;
  bool _isValidIP = true;
  bool _isValidMask = true;
  bool _isValidServerIp = true;
  bool _isValidGateway = true;
  bool _isStatic = true;

  dynamic _eventbus1;
  dynamic _eventbus2;
  RegExp ipaddressRegex = RegExp(r'[0-9.]');
  RegExp ipRegex = RegExp(
    r'^((\d{1,3}\.){3}\d{1,3})$',
    multiLine: false,
    caseSensitive: false,
  );

  dynamic localizedStrings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void initState() {
    cntScaleTimerMgr.startCntScaleTimer(1);
    _eventbus1 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
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
    //
    _eventbus2 = eventBus.on<EventSetServerIPResp>().listen((event) {
      if (mounted) {
        setState(() {
          isDownloadClicked = false;
          myRespSetServerIp = event.obj;

          if (myRespSetServerIp.msgBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myRespSetServerIp.msgBody.contains('ok'))
                        ? localizedStrings.download_result_ok
                        : myRespSetServerIp.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (myRespSetServerIp.msgBody.contains('ok'))
                    ? Colors.green.shade900
                    : Colors.red.shade900));
          }

          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.startCntScaleTimer(2);
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: pageHead(context, localizedStrings.set_ethernet_ip_title,
            localizedStrings.serial_port_status),
      ),
      body: Column(
        children: [
          Container(
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 2,
                  color: Theme.of(context).colorScheme.primary, // 左侧分隔条
                ),
                const SizedBox(width: 16), // 间距
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 40), // 顶部间距
                      buildCommonRow(
                        localizedStrings.ip_address,
                        15,
                        ipaddressRegex,
                        _isValidIP,
                        localizedStrings.error_ip_tip,
                        (value) {
                          setState(() {
                            _isValidIP = validateIpFlag(value);
                          });
                        },
                        ipController,
                        _isStatic,
                      ),
                      buildCommonRow(
                        localizedStrings.netmask,
                        15,
                        ipaddressRegex,
                        _isValidMask,
                        localizedStrings.error_ip_tip,
                        (value) {
                          setState(() {
                            _isValidMask = validateIpFlag(value);
                          });
                        },
                        netMaskController,
                        _isStatic,
                      ),
                      buildCommonRow(
                        localizedStrings.gateway,
                        15,
                        ipaddressRegex,
                        _isValidGateway,
                        localizedStrings.error_ip_tip,
                        (value) {
                          setState(() {
                            _isValidGateway = validateIpFlag(value);
                          });
                        },
                        gateWayController,
                        _isStatic,
                      ),

                      const SizedBox(height: 40), // 底部间距

                      buildCommonRow(
                        localizedStrings.server_ip,
                        15,
                        ipaddressRegex,
                        _isValidServerIp,
                        localizedStrings.error_ip_tip,
                        (value) {
                          setState(() {
                            _isValidServerIp = validateIpFlag(value);
                          });
                        },
                        serverIpCtl,
                        _isStatic,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTextTitle(localizedStrings.server_port),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 300,
                            height: 45,
                            child: _buildEditFeild(serverPortCtl),
                          )
                        ],
                      ),

                      const SizedBox(height: 40), // 底部间距

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildButtonSection(), // 按钮部分
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  bool _isValidIpAddress(bool tempValid, String value) {
    if (tempValid) {
      List<int?> parts = value.split('.').map(int.tryParse).toList();
      if (parts.any((part) => part == null || part > 255)) {
        tempValid = false;
      }
    }
    return tempValid;
  }

// 按钮部分
  Widget _buildButtonSection() {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        onPressed: (!isDownloadClicked) && (downloadFlag())
            ? () {
                _showConfirmationDialog(context);
              }
            : null,
        child: Text(
          localizedStrings.download,
        ),
      ),
    );
  }

  bool downloadFlag() {
    bool flag = false;

    bool model1 = ipController.text == '' &&
        gateWayController.text == '' &&
        netMaskController.text == '' &&
        (serverIpCtl.text != "" && serverPortCtl.text != '');
    bool model2 = ipController.text != '' &&
        gateWayController.text != '' &&
        netMaskController.text != '' &&
        (serverIpCtl.text == "" && serverPortCtl.text == '');

    bool model3 = ipController.text != '' &&
        gateWayController.text != '' &&
        netMaskController.text != '' &&
        (serverIpCtl.text != "" && serverPortCtl.text != '');

    if (model1) {
      if (_isValidServerIp) {
        flag = true;
      }
    }
    if (model2) {
      if (_isValidIP && _isValidGateway && _isValidMask) {
        flag = true;
      }
    }
    if (model3) {
      if (_isValidIP && _isValidGateway && _isValidMask && _isValidServerIp) {
        flag = true;
      }
    }

    return flag;
  }

  Widget _buildTextTitle(String title) {
    return SizedBox(
      height: 40,
      width: 200,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildEditFeild(TextEditingController editTextCtl) {
    return TextField(
      readOnly: false,
      style: const TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
      controller: editTextCtl,
      maxLines: 1,
      onChanged: (value) {
        setState(() {});
      },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        FilteringTextInputFormatter.allow(RegExp(r'^[1-9]\d*$')),
        LengthLimitingTextInputFormatter(8),
      ],
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.confirm_title,
            style: const TextStyle(color: Color.fromARGB(255, 15, 71, 161)),
          ),
          content: Text(localizedStrings.header_confirm_info),
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
        myServerIpData = ServerIpData(); //清空
        myServerIpData.ip = ipController.text;
        myServerIpData.gateway = gateWayController.text;
        myServerIpData.netmask = netMaskController.text;
        myServerIpData.serverIp = serverIpCtl.text;
        myServerIpData.serverPort = serverPortCtl.text;
        PublicFunctions.sendServerIpToScale(myServerIpData);

        setState(() {
          isDownloadClicked = true;
          cntScaleTimerMgr.stopCntScaleTimer();
        });
      }
    });
  }
}
