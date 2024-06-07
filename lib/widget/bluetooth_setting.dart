import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/functions/methods.dart';
import '../../eventbus/eventbus.dart';
import '../../main.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import 'custom_button.dart';

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
    return AlertDialog(
      title: getDialogTitle(context, localizedStrings.bluetooth_modification,
          Icons.bluetooth, 400),
      content: Container(
        height: 310,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceTint),
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
                              CustomOutlinedButton(
                                  btnWidth: 120,
                                  btnHeight: 40,
                                  icon: Icons.bluetooth_audio,
                                  text: localizedStrings.get_bt_name,
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
                              const SizedBox(width: 40),
                              CustomOutlinedButton(
                                  btnWidth: 120,
                                  btnHeight: 40,
                                  icon: Icons.mode_edit,
                                  text: localizedStrings.modify_bt_name,
                                  onPressed: isSetting
                                      ? null
                                      : () {
                                          try {
                                            setState(() {
                                              _errorMessage = '';
                                              if (MyApp
                                                  .webchannel1.heartStatus) {
                                                sendBluetoothName();
                                              } else {
                                                _errorMessage = localizedStrings
                                                    .serial_error;
                                              }
                                            });
                                          } catch (e) {
                                            setState(() {
                                              _errorMessage =
                                                  localizedStrings.serial_error;
                                            });
                                          }
                                        }),
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
                          CustomOutlinedButton(
                              btnWidth: 340,
                              btnHeight: 40,
                              icon: Icons.settings_bluetooth_outlined,
                              text: localizedStrings.bt_modify_emission,
                              onPressed: isSetting
                                  ? null
                                  : () {
                                      setState(() {
                                        _errorMessage = '';
                                      });
                                      if (emissionPowerVale == 'Strong') {
                                        PublicFunctions.modifyBtPowerStrong();
                                      } else if (emissionPowerVale ==
                                          'Normal') {
                                        PublicFunctions.modifyBtPowerNormal();
                                      } else {
                                        PublicFunctions.modifyBtPowerWeak();
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
                                        _errorMessage.contains('ERROR') ||
                                        _errorMessage.contains('fail'))
                                    ? _errorMessage
                                    : '',
                            style: TextStyle(
                                color: (_errorMessage.contains('ok') ||
                                        _errorMessage.contains('OK'))
                                    ? Theme.of(context).colorScheme.outline
                                    : Theme.of(context).colorScheme.error),
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
            const SizedBox(width: 30),
          ],
        )
      ],
    );
  }

  void sendBluetoothName() async {
    if (_deviceNameController.text.isNotEmpty) {
      PublicFunctions.modifyBtName(_deviceNameController.text);
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
      // print(time);
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
