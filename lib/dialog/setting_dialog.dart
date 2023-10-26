import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/currentport_data.dart';
import 'package:t_max/data/modifyscale_data.dart';
import '../../data/device_data.dart';
import '../../data/scalecmd_data.dart';
import '../../data/settingparam_data.dart';
import '../../functions/methods.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import 'modifyNetwork_dialog.dart';

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
      text: (mySettingParam.stableTimeToRec.isEmpty)
          ? "0"
          : (mySettingParam.stableTimeToRec));
  TextEditingController errorText = TextEditingController();
  bool isSaveModeChecked = true;
  int _checkSaveMode = 1;
  int _checkDateMode = 1;
  int _checkScaleMode = 1;
  String dateSeparator = '-';
  int _checkDateSeparator = 1;
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
    _checkScaleMode = int.parse(mySettingParam.scaleMode);
    _checkDateMode = (mySettingParam.dateFormat.isEmpty)
        ? 1
        : int.parse(mySettingParam.dateFormat);
    tempCurrentPort = myCurrentPort;
  }

  var localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
          color: Colors.blue.shade900,
          child: Row(
            children: [
              const Icon(Icons.settings, color: Colors.white),
              Text(localizedStrings.parameter_settings_title,
                  style: const TextStyle(color: Colors.white))
            ],
          )),
      content: Container(
          height: 350,
          decoration:
              const BoxDecoration(color: Color.fromARGB(255, 233, 232, 232)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 2),
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              saveModeRadio(),
                              const SizedBox(height: 15),
                              scaleModeRadio(),
                              const SizedBox(height: 15),
                              Text(localizedStrings.stable_time),
                              SizedBox(
                                width: 400,
                                height: 30,
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
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: InputDecoration(
                                    enabled:
                                        (_checkSaveMode == 2) ? true : false,
                                    counterText: "",
                                    // hintText: "请输入机种类型，如：ztp",
                                    // border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    if (stableTime.text.toString().isNotEmpty) {
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
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  SizedBox(
                                      width: 100,
                                      child:
                                          Text(localizedStrings.date_format)),
                                  Column(
                                    children: [
                                      dateFormatRadio(1, "yy-mm-dd"),
                                      dateFormatRadio(2, "dd-mm-yy"),
                                      dateFormatRadio(3, "mm-dd-yy"),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  const SizedBox(
                                      width: 100,
                                      child: Text("Date Separator")),
                                  Column(
                                    children: [
                                      dateSeparatorRadio(1, "."),
                                      dateSeparatorRadio(2, "-"),
                                      dateSeparatorRadio(3, "/"),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(localizedStrings.zero_range),
                              SizedBox(
                                width: 400,
                                height: 30,
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
                                  textAlignVertical: TextAlignVertical.bottom,
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
                        ],
                      ),
                      SizedBox(
                        width: 400,
                        height: 36,
                        child: TextField(
                          enabled: false,
                          controller: errorText,
                          maxLength: 100,
                          style: const TextStyle(color: Colors.red),
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: const InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            counterText: "",
                            focusColor:
                                Colors.red, // hintText: "请输入机种类型，如：ztp",
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
            MaterialButton(
                textColor: Colors.white,
                color: Colors.blue.shade900,
                child: Text(localizedStrings.button_ok),
                onPressed: () {
                  updateUIConf();
                  PublicFunctions.getUIConf();
                  // myDialogData.type = dialogtype;
                  // print(myDialogData.type);
                  // connectionType =
                  //     deviceName.text.toString() + ",Icons.usb";
                  // 传值
                  Navigator.of(context).pop(connectionType);
                }),
            const SizedBox(width: 20),
            OutlinedButton(
                child: Text(localizedStrings.button_cancel),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // to go back to screen after submitting
                })
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
    mySettingParam.scaleMode = _checkScaleMode.toString();
    mySettingParam.stableTimeToRec = stableTime.text;
    mySettingParam.zeroRange = zeroRange.text;
    String updateString = jsonEncode(mySettingParam);
    myScaleCmd.cmdData = updateString;
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
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
        SizedBox(width: 100, child: Text(localizedStrings.save_mode)),
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

  Widget scaleModeRadio() {
    return Row(
      children: [
        const SizedBox(width: 100, child: Text("Scale Mode:")),
        scaleModeSingleRadio(1),
        const Text('Normal'),
        const SizedBox(width: 20),
        scaleModeSingleRadio(2),
        const Text('Take-in'),
        const SizedBox(width: 20),
        scaleModeSingleRadio(3),
        const Text('Take-out'),
      ],
    );
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
}
