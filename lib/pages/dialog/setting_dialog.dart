import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/currentport_data.dart';
import 'package:t_max/data/modifyscale_data.dart';
import 'package:t_max/pages/dialog/showComPort_dialog.dart';
import '../../data/device_data.dart';
import '../../data/scalecmd_data.dart';
import '../../data/settingparam_data.dart';
import '../../main.dart';

TextEditingController zeroRange = TextEditingController(
    text:
        (mySettingParam.zeroRange.isEmpty) ? "0" : (mySettingParam.zeroRange));
TextEditingController stableTime = TextEditingController(
    text: (mySettingParam.stableTimeToRec.isEmpty)
        ? "0"
        : (mySettingParam.stableTimeToRec));
TextEditingController errorText = TextEditingController();
bool isSaveModeChecked = true;
int _checkMode = 1;
int _checkDateMode = 1;

settingDialog(BuildContext context) {
  _checkMode = ((mySettingParam.recMode.isEmpty)
      ? 1
      : (mySettingParam.recMode == "auto")
          ? 2
          : (mySettingParam.recMode == "manual")
              ? 1
              : 0);

  _checkDateMode = (mySettingParam.dateFormat.isEmpty)
      ? 1
      : int.parse(mySettingParam.dateFormat);

  tempCurrentPort = myCurrentPort;
  return showDialog(
      barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            title: Container(
                color: Colors.blue.shade900,
                child: Row(
                  children: const [
                    Icon(Icons.usb, color: Colors.white),
                    Text("参数设置", style: TextStyle(color: Colors.white))
                  ],
                )),
            content: Container(
              height: 330,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 233, 232, 232)),
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
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: 100, child: Text("Save Mode:")),
                                    Radio(
                                        value: 1,
                                        groupValue: _checkMode,
                                        onChanged: (value) {
                                          debugPrint(value.toString());
                                          setState(() {
                                            _checkMode = 1;
                                            stableTime.clear();
                                          });
                                        }),
                                    const Text("Manual"),
                                    const SizedBox(width: 50),
                                    Radio(
                                        value: 2,
                                        groupValue: _checkMode,
                                        onChanged: (value) {
                                          debugPrint(value.toString());
                                          setState(() {
                                            _checkMode = 2;
                                          });
                                        }),
                                    const Text("Auto"),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                const Text("Stable Time:"),
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
                                      enabled: (_checkMode == 2) ? true : false,
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
                                          errorText.text = "Stable Time不能大于20秒";
                                        } else {
                                          errorText.text = "";
                                        }
                                      }
                                      print(value);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: 100,
                                        child: Text("Date Format:")),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Radio(
                                                value: 1,
                                                groupValue: _checkDateMode,
                                                onChanged: (value) {
                                                  debugPrint(value.toString());
                                                  setState(() {
                                                    _checkDateMode = 1;
                                                  });
                                                }),
                                            const Text("yy-mm-dd"),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio(
                                                value: 2,
                                                groupValue: _checkDateMode,
                                                onChanged: (value) {
                                                  debugPrint(value.toString());
                                                  setState(() {
                                                    _checkDateMode = 2;
                                                  });
                                                }),
                                            const Text("dd-mm-yy"),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio(
                                                value: 3,
                                                groupValue: _checkDateMode,
                                                onChanged: (value) {
                                                  debugPrint(value.toString());
                                                  setState(() {
                                                    _checkDateMode = 3;
                                                  });
                                                }),
                                            const Text("mm-dd-yy"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                const Text("Zero Range:"),
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
                                    onChanged: (value) {
                                      print(value);
                                    },
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
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              counterText: "",
                              focusColor:
                                  Colors.red, // hintText: "请输入机种类型，如：ztp",
                              // border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              print(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                      textColor: Colors.white,
                      color: Colors.blue.shade900,
                      child: const Text("确定"),
                      onPressed: () {
                        updateUIConf();
                        getUIConf();
                        // myDialogData.type = dialogtype;
                        // print(myDialogData.type);
                        // connectionType =
                        //     deviceName.text.toString() + ",Icons.usb";
                        // 传值
                        Navigator.of(context).pop(connectionType);
                      }),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("取消"),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // to go back to screen after submitting
                      })
                ],
              )
            ],
          );
        }));
      });
}

void sendModifyInfo(String modifyString) {
  myScaleCmd.cmdMode = "modify_scale";
  myScaleCmd.cmdData = modifyString;
  print(jsonEncode(myScaleCmd));
  MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
}

void getScaleList() {
  myScaleCmd.cmdMode = "get_scale_list";
  myScaleCmd.cmdData = "";
  MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
}

void updateUIConf() {
  myScaleCmd.cmdMode = "update_ui_conf";
  mySettingParam.dateFormat = _checkDateMode.toString();
  mySettingParam.recMode = (_checkMode == 2) ? "auto" : "manual";
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
  sendModifyInfo(modifyInfoString);
}
