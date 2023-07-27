import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/downloadresponse.dart';
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

  String _errorMessage = '';
  bool isSetting = false;
  dynamic _eventbus1;
  @override
  void initState() {
    super.initState();
    _deviceNameController.text = '';
    _eventbus1 = eventBus.on<EventConnectBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myConnectBTResponse = event.obj;
          isSetting = false;
          if (myConnectBTResponse.msgBody.isNotEmpty) {
            _errorMessage = myConnectBTResponse.msgBody;
          }
        });
      }
    });
  }

  var localizedStrings;
  String set_message = '';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _eventbus1.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);
    return AlertDialog(
      title: Container(
        color: Colors.blue.shade900,
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
                          const SizedBox(height: 150),
                          Text(
                            (_errorMessage.contains('ok'))
                                ? localizedStrings.bluetooth_modify_ok
                                : (_errorMessage.contains('error'))
                                    ? localizedStrings.bluetooth_modify_error
                                    : '',
                            style: TextStyle(
                                color:
                                    (myConnectBTResponse.msgBody.contains('ok'))
                                        ? Colors.green.shade900
                                        : Colors.red.shade900),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
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
            ElevatedButton(
              child: Text(localizedStrings.button_set),
              onPressed: isSetting
                  ? null
                  : () {
                      try {
                        setState(() {
                          _errorMessage = '';
                          if (MyApp.webchannel1.heartStatus) {
                            sendBluetoothName();
                          } else {
                            _errorMessage = localizedStrings.serial_error;
                          }
                        });
                      } catch (e) {
                        setState(() {
                          _errorMessage = localizedStrings.serial_error;
                        });
                      }
                    },
            ),
            const SizedBox(width: 20),
            OutlinedButton(
              child: Text(localizedStrings.button_cancel),
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
    } else {
      _errorMessage = 'Device name can not be empty!';
    }
  }
}
