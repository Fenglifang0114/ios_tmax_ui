import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import 'package:t_max/functions/methods.dart';
import '../../data/scalecmd_data.dart';
import '../../eventbus/eventbus.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../data/writelog.dart';
import 'custom_button.dart';

class UpdateFirmWareDialog extends StatefulWidget {
  const UpdateFirmWareDialog({super.key});

  @override
  UpdateFirmWareDialogState createState() => UpdateFirmWareDialogState();
}

class UpdateFirmWareDialogState extends State<UpdateFirmWareDialog> {
  final TextEditingController _filePathController = TextEditingController();

  String _errorMessage = '';
  bool isSetting = false;
  dynamic _eventbus1;
  dynamic _eventbus2;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _filePathController.text = '';

    _eventbus1 = eventBus.on<EventRespUpdateFirmware>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        setState(() {
          _errorMessage = myRespDataFromScale.msgBody;
          isSetting = false;
        });
      }
    });
    _eventbus2 = eventBus.on<EventRespUpdateFirmwareProcess>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok') ||
            myRespDataFromScale.msgBody.contains('fail')) {
          isSetting = false;
          setState(() {
            _errorMessage = myRespDataFromScale.msgBody;
          });
        } else {
          if (int.tryParse(myRespDataFromScale.msgBody) != null) {
            // 字符串全是数字
            int numericValue = int.parse(myRespDataFromScale.msgBody);
            if (numericValue < 100 && numericValue * 1.5 < 100.0) {
              numericValue = (numericValue * 1.5).toInt();
            }
            updateProgress(numericValue);
          } else {
            setState(() {
              _errorMessage = myRespDataFromScale.msgBody;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _filePathController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(
          context, localizedStrings.firmware_update, Icons.usb, 400),
      content: Container(
          height: 312,
          width: 400,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surfaceBright),
          child: Container(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomOutlinedButton(
                    btnWidth: 350,
                    btnHeight: 40,
                    icon: Icons.file_open_outlined,
                    text: localizedStrings.select_firmware_btn,
                    onPressed: isSetting
                        ? null
                        : () async {
                            updateFilePath();
                          }),
                const SizedBox(height: 20),
                SizedBox(
                  width: 400,
                  height: 150,
                  child: TextField(
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        _errorMessage = '';
                      });
                    },
                    maxLines: 5,
                    style: const TextStyle(overflow: TextOverflow.ellipsis),
                    readOnly: true,
                    controller: _filePathController,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      // hintText: "请输入机种类型，如：ztp",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CustomElevatedButton(
                        btnWidth: 120,
                        btnHeight: 40,
                        icon: Icons.arrow_circle_right_outlined,
                        text: localizedStrings.button_start,
                        onPressed:
                            (isSetting || _filePathController.text.isEmpty)
                                ? null
                                : () {
                                    _progress = 0.0;
                                    _showConfirmationDialog(context,
                                        Theme.of(context).colorScheme.primary);
                                  },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  (_errorMessage.contains('ok') || _errorMessage.contains('OK'))
                      ? 'OK'
                      : _errorMessage,
                  style: TextStyle(
                      color: (_errorMessage.contains('ok') ||
                              _errorMessage.contains('OK') ||
                              _errorMessage.contains('started'))
                          ? Theme.of(context).colorScheme.surfaceContainerHigh
                          : Theme.of(context).colorScheme.error),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                  width: 400,
                  child: (isSetting)
                      ? LinearProgressIndicator(
                          value: _progress > 0 ? _progress : null,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryFixed,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary),
                        )
                      : const Text(''),
                ),
              ],
            ),
          )),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.exit_to_app,
              text: localizedStrings.button_exit,
              onPressed: isSetting
                  ? null
                  : () {
                      myScreenMgr.isMainScreen = true;
                      Navigator.of(context).pop();
                    },
            ),
          ],
        )
      ],
    );
  }

  void updateProgress(int value) {
    setState(() {
      _progress = value.toDouble() / 100;
    });
  }

  void _showConfirmationDialog(BuildContext context, Color colorName) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.confirm_title,
            style: TextStyle(color: colorName),
          ),
          content: Text(localizedStrings.update_firmware_info),
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
        sendFormatToScale(_filePathController.text);
        setState(() {
          _errorMessage = localizedStrings.update_firmware_wait;
          isSetting = true;
        });
        Timer(const Duration(seconds: 10), () {
          if (!(_progress > 0) && isSetting) {
            setState(() {
              _errorMessage = localizedStrings.update_firmware_reboot;
            });
          }
        });
      }
    });
  }

  void sendFormatToScale(String firmwarePathStr) {
    myScaleCmd.cmdMode = "update_firmware";
    myScaleCmd.cmdData = firmwarePathStr;
    PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  Future<String?> pickFirmwareFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null) {
        return result.paths[0];
      } else {
        return null;
      }
    } catch (e) {
      // print('文件选择出错：$e');
      return null;
    }
  }

  void updateFilePath() async {
    String? filePath = await pickFirmwareFile();
    setState(() {
      if (filePath != null) {
        _filePathController.text = filePath;
      } else {
        _filePathController.text = '';
      }
    });
  }
}
