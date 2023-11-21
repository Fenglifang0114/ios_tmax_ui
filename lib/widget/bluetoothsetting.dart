import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/functions/methods.dart';
import '../../data/scalecmd_data.dart';
import '../../eventbus/eventbus.dart';
import '../../generated/l10n.dart';
import '../../main.dart';

class BluetoothDialog extends StatefulWidget {
  const BluetoothDialog({super.key});

  @override
  _BluetoothDialogState createState() => _BluetoothDialogState();
}

class _BluetoothDialogState extends State<BluetoothDialog> {
  final TextEditingController _deviceNameController = TextEditingController();
  List<String> emissionPowerList = ['Strong', 'Normal', 'Weak'];
  String emissionPowerVale = '';
  Timer? _timer;

  String _errorMessage = '';
  bool isSetting = false;
  dynamic _eventbus1;
  dynamic _eventbus2;
  @override
  void initState() {
    super.initState();
    _deviceNameController.text = '';
    emissionPowerVale = 'Strong';
    _eventbus1 = eventBus.on<EventConnectBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myConnectBTResponse = event.obj;
          isSetting = false;
          if (myConnectBTResponse.msgBody.isNotEmpty) {
            _errorMessage = myConnectBTResponse.msgBody;
          }
          _stopTimer();
        });
      }
    });
    _eventbus2 = eventBus.on<EventBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myRespBTData = event.obj;
          isSetting = false;
          if (myRespBTData.msgBody.isNotEmpty) {
            if (myRespBTData.msgBody.contains("TTM:NAM")) {
              _deviceNameController.text = getBtName(myRespBTData.msgBody);
            }
            _errorMessage = myRespBTData.msgBody;
          }
          _stopTimer();
        });
      }
    });
  }

  String getBtName(String data) {
    int start = data.indexOf('TTM:NAM-') + 'TTM:NAM-'.length;
    int end = data.indexOf('\r\n\u0000');

    String result = data.substring(start, end);
    return result;
  }

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);
    return AlertDialog(
      title: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          children: [
            const Icon(Icons.bluetooth, color: Colors.white),
            Text(
              localizedStrings.bluetooth_modification,
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
      content: Container(
        height: 300,
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 233, 232, 232)),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizedStrings.device_name),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 400,
                            height: 30,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _errorMessage = '';
                                });
                              },
                              maxLines: 1,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(35),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[\x00-\xF]+$')),
                              ],
                              controller: _deviceNameController,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                // hintText: "请输入机种类型，如：ztp",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                  child: Text(localizedStrings.get_bt_name),
                                  onPressed: isSetting
                                      ? null
                                      : () {
                                          setState(() {
                                            _errorMessage = '';
                                            _deviceNameController.clear();
                                          });
                                          PublicFunctions.getBtName();
                                          _startTimer(15);
                                        }),
                              const SizedBox(width: 50),
                              OutlinedButton(
                                child: Text(localizedStrings.modify_bt_name),
                                onPressed: isSetting
                                    ? null
                                    : () {
                                        try {
                                          setState(() {
                                            _errorMessage = '';
                                            if (MyApp.webchannel1.heartStatus) {
                                              sendBluetoothName();
                                            } else {
                                              _errorMessage =
                                                  localizedStrings.serial_error;
                                            }
                                          });
                                        } catch (e) {
                                          setState(() {
                                            _errorMessage =
                                                localizedStrings.serial_error;
                                          });
                                        }
                                      },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(localizedStrings.bt_emission_power),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 400,
                            child: DropdownButtonFormField<String>(
                              // isExpanded: true,
                              // decoration: const InputDecoration(border: OutlineInputBorder()),
                              // 设置默认值
                              value: emissionPowerVale,
                              // 选择回调
                              onChanged: (String? newPosition) {
                                emissionPowerVale = newPosition.toString();
                                setState(() {
                                  _errorMessage = '';
                                });
                              },
                              // 传入可选的数组
                              items: emissionPowerList
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem(
                                    value: value, child: Text(value));
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                              child: Text(localizedStrings.bt_modify_emission),
                              onPressed: isSetting
                                  ? null
                                  : () {
                                      setState(() {
                                        _errorMessage = '';
                                      });
                                      if (emissionPowerVale == 'Strong') {
                                        PublicFunctions
                                            .modifyBtEmissionPower3();
                                      } else if (emissionPowerVale ==
                                          'Normal') {
                                        PublicFunctions
                                            .modifyBtEmissionPower2();
                                      } else {
                                        PublicFunctions
                                            .modifyBtEmissionPower1();
                                      }
                                      _startTimer(15);
                                    }),
                          const SizedBox(height: 10),
                          Text(
                            (_errorMessage.contains('ok') ||
                                    _errorMessage.contains('OK'))
                                ? 'OK'
                                : (_errorMessage.contains('error') ||
                                        _errorMessage.contains('Time out') ||
                                        _errorMessage.contains('ERROR'))
                                    ? _errorMessage
                                    : '',
                            style: TextStyle(
                                color: (_errorMessage.contains('ok') ||
                                        _errorMessage.contains('OK'))
                                    ? Colors.green.shade900
                                    : Colors.red.shade900),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2,
                    width: 400,
                    child: isSetting
                        ? LinearProgressIndicator(
                            value: null,
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary),
                          )
                        // const CircularProgressIndicator(
                        //     strokeWidth: 3,
                        //   )
                        : const Text(''),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            )
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              child: Text(localizedStrings.button_exit),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

  void sendBluetoothName() {
    myScaleCmd.cmdMode = 'modify_bt_name';
    if (_deviceNameController.text.isNotEmpty) {
      myScaleCmd.cmdData = _deviceNameController.text;
      MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
      isSetting = true;
      _startTimer(15);
    } else {
      setState(() {
        _errorMessage = 'Device name can not be empty! error';
      });
    }
  }

  void _startTimer(int time) {
    setState(() {
      isSetting = true;
      print(time);
    });

    _timer = Timer(Duration(seconds: time), () {
      setState(() {
        isSetting = false;
        _errorMessage = 'Time out!';
      });
    });
  }

  void _stopTimer() {
    isSetting = false;
    _timer?.cancel(); // 停止计时器
  }
}
