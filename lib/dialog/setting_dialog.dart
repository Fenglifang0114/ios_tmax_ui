import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/modifyscale_data.dart';
import '../../data/device_data.dart';
import '../../data/scalecmd_data.dart';
import '../../data/settingparam_data.dart';
import '../../functions/methods.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../data/scalelist_data.dart';
import '../widget/custom_button.dart';
import 'modify_network_dialog.dart';

class ParamSettingDialog extends StatefulWidget {
  const ParamSettingDialog({super.key});

  @override
  _ParamSettingDialogState createState() => _ParamSettingDialogState();
}

class _ParamSettingDialogState extends State<ParamSettingDialog> {
  TextEditingController zeroRange = TextEditingController(
      text: (mySettingParam.zeroRange.isEmpty)
          ? "0"
          : (mySettingParam.zeroRange));
  TextEditingController stableTime = TextEditingController(
      text: (mySettingParam.stableTime.isEmpty)
          ? "0"
          : (mySettingParam.stableTime));
  TextEditingController errorText = TextEditingController();
  bool isSaveModeChecked = true;
  int _checkSaveMode = 1;
  int _checkDateMode = 1;
  int _checkScaleMode = 1;
  String dateSeparator = '-';
  int _checkDateSeparator = 1;
  int _checkHiLow = 1;
  @override
  void initState() {
    super.initState();
    _checkSaveMode = ((mySettingParam.recMode.isEmpty)
        ? 1
        : (mySettingParam.recMode == "auto")
            ? 2
            : (mySettingParam.recMode == "manual")
                ? 1
                : 1);
    _checkDateSeparator = ((mySettingParam.dateSeparator.isEmpty)
        ? 2
        : (mySettingParam.dateSeparator == "-")
            ? 2
            : (mySettingParam.dateSeparator == "/")
                ? 3
                : 1);
    _checkScaleMode = mySettingParam.scaleMode;
    _checkDateMode = (mySettingParam.dateFormat.isEmpty)
        ? 1
        : int.parse(mySettingParam.dateFormat);
    tempCurrentPort = myCurrentPort;
    _checkHiLow = int.parse(mySettingParam.saveMode);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(context, localizedStrings.serial_modify_title,
          Icons.settings_outlined, 400),
      content: Container(
          height: 350,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.background),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 2),
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary),
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              saveModeRadio(),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      localizedStrings.stable_time,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 40,
                                    child: TextField(
                                      controller: stableTime,
                                      maxLength: 2,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      maxLines: 1,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[0-9]"))
                                      ], //数字包括小数,
                                      textAlignVertical: TextAlignVertical.top,
                                      decoration: InputDecoration(
                                        enabled: (_checkSaveMode == 2)
                                            ? true
                                            : false,
                                        counterText: "",
                                        // hintText: "请输入机种类型，如：ztp",
                                        // border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        if (stableTime.text
                                            .toString()
                                            .isNotEmpty) {
                                          if (int.parse(
                                                  stableTime.text.toString()) >
                                              20) {
                                            errorText.text = localizedStrings
                                                .stable_time_error_tip;
                                          } else {
                                            errorText.text = "";
                                          }
                                        }
                                        if (kDebugMode) {
                                          print(value);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  SizedBox(
                                      width: 200,
                                      child: Text(
                                        localizedStrings.date_format,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                  Column(
                                    children: [
                                      dateFormatRadio(1, "yy-mm-dd"),
                                      dateFormatRadio(2, "dd-mm-yy"),
                                      dateFormatRadio(3, "mm-dd-yy"),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const SizedBox(
                                      width: 200,
                                      child: Text(
                                        "Date Separator",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      dateSeparatorRadio(1, "."),
                                      dateSeparatorRadio(2, "-"),
                                      dateSeparatorRadio(3, "/"),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      localizedStrings.zero_range,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 40,
                                    child: TextField(
                                      controller: zeroRange,
                                      maxLength: 8,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      maxLines: 1,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d+(\.)?[0-9]{0,7}'))
                                      ], //数字包括小数,
                                      textAlignVertical: TextAlignVertical.top,
                                      decoration: const InputDecoration(
                                        counterText: "",
                                        // hintText: "请输入机种类型，如：ztp",
                                        // border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              (mySettingParam.scaleMode == 1)
                                  ? Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Save Mode:',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        checkHiLowRadio(1, 'All'),
                                        checkHiLowRadio(2, 'Hi'),
                                        checkHiLowRadio(3, 'Ok'),
                                        checkHiLowRadio(4, 'Low'),
                                      ],
                                    )
                                  : const SizedBox(
                                      height: 30,
                                    ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 400,
                        height: 36,
                        child: TextField(
                          enabled: false,
                          controller: errorText,
                          maxLength: 100,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                            counterText: "",
                            focusColor: Theme.of(context)
                                .colorScheme
                                .error, // hintText: "请输入机种类型，如：ztp",
                            // border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomElevatedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.check_circle,
              text: localizedStrings.button_ok,
              onPressed: () {
                updateUIConf();
                Navigator.of(context).pop(connectionType);
              },
            ),
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.cancel,
              text: localizedStrings.button_cancel,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

  void updateUIConf() {
    myScaleCmd.cmdMode = "update_ui_conf";
    mySettingParam.dateFormat = _checkDateMode.toString();
    mySettingParam.recMode = (_checkSaveMode == 2) ? "auto" : "manual";
    mySettingParam.dateSeparator = (_checkDateSeparator == 1)
        ? "."
        : (_checkDateSeparator == 2)
            ? "-"
            : '/';
    mySettingParam.stableTime = stableTime.text;
    mySettingParam.zeroRange = zeroRange.text;
    if (mySettingParam.scaleMode == 1) {
      mySettingParam.saveMode = _checkHiLow.toString();
    }
    String updateString = jsonEncode(mySettingParam);
    myScaleCmd.cmdData = updateString;
    PublicFunctions.sendMsg(defaultScaleId, jsonEncode(myScaleCmd));
  }

  void modifyComInfo() {
    String infoString = jsonEncode(tempCurrentPort);
    myMediaConf.mediaInfoJson = infoString;
    myMediaConf.type = myDevicedata.mediaType;
    myModifyScale.scaleId = int.parse(myDevicedata.scaleID);
    myModifyScale.mediaConf = myMediaConf;
    String modifyInfoString = jsonEncode(myModifyScale);
    PublicFunctions.sendModifyInfo(modifyInfoString);
  }

  Widget saveModeRadio() {
    return Row(
      children: [
        SizedBox(
            width: 200,
            child: Text(
              localizedStrings.save_mode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
        saveModeSingleRadio(1),
        const Text('manual'),
        const SizedBox(width: 20),
        saveModeSingleRadio(2),
        const Text('auto'),
      ],
    );
  }

  Radio saveModeSingleRadio(int radioId) {
    return Radio(
        value: radioId,
        groupValue: _checkSaveMode,
        onChanged: (value) {
          debugPrint(value.toString());
          setState(() {
            _checkSaveMode = radioId;
            if (radioId == 1) {
              stableTime.clear();
            }
          });
        });
  }

  Radio scaleModeSingleRadio(int radioId) {
    return Radio(
        value: radioId,
        groupValue: _checkScaleMode,
        onChanged: (value) {
          debugPrint(value.toString());
          setState(() {
            _checkScaleMode = radioId;
          });
        });
  }

  Widget dateFormatRadio(int data, String str) {
    return Row(
      children: [
        Radio(
            value: data,
            groupValue: _checkDateMode,
            onChanged: (value) {
              debugPrint(value.toString());
              setState(() {
                _checkDateMode = data;
              });
            }),
        Text(str),
      ],
    );
  }

  Widget dateSeparatorRadio(int data, String str) {
    return Row(
      children: [
        Radio(
            value: data,
            groupValue: _checkDateSeparator,
            onChanged: (value) {
              debugPrint(value.toString());
              setState(() {
                _checkDateSeparator = data;
              });
            }),
        Text(str),
      ],
    );
  }

  Widget checkHiLowRadio(int data, String str) {
    return Row(
      children: [
        Radio(
            value: data,
            groupValue: _checkHiLow,
            onChanged: (value) {
              debugPrint(value.toString());
              setState(() {
                _checkHiLow = data;
              });
            }),
        Text(str),
      ],
    );
  }
}
