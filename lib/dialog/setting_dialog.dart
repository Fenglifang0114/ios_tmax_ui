import 'dart:convert';
import 'package:t_max/widget/t_max_dialog.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/modifyscale_data.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import '../../data/device_data.dart';
import '../../data/scalecmd_data.dart';
import '../../data/settingparam_data.dart';
import '../../functions/methods.dart';
import '../data/const_var_data.dart';
import '../data/language.dart';
import '../data/scalelist_data.dart';
import '../widget/custom_button.dart';
import 'modify_network_dialog.dart';

class ParameterSettingDialog extends StatefulWidget {
  const ParameterSettingDialog({super.key});
  @override
  ParameterSettingDialogState createState() => ParameterSettingDialogState();
}

class ParameterSettingDialogState extends State<ParameterSettingDialog> {
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
  int _wgtMode = 0;
  int _checkSaveMode = 1;
  int _checkDateMode = 1;
  int checkScaleMode = 1;
  String dateSeparator = '-';
  int _checkDateSeparator = 1;
  int _checkHiLow = 1;
  @override
  void initState() {
    _checkSaveMode = ((mySettingParam.recMode.isEmpty)
        ? 1
        : (mySettingParam.recMode == msgAuto)
            ? 2
            : (mySettingParam.recMode == msgManual)
                ? 1
                : 1);
    _checkDateSeparator = ((mySettingParam.dateSeparator.isEmpty)
        ? 2
        : (mySettingParam.dateSeparator == "-")
            ? 2
            : (mySettingParam.dateSeparator == "/")
                ? 3
                : 1);
    checkScaleMode = mySettingParam.scaleMode;
    _checkDateMode = (mySettingParam.dateFormat.isEmpty)
        ? 1
        : int.parse(mySettingParam.dateFormat);
    tempCurrentPort = myCurrentPort;
    _checkHiLow = int.tryParse(mySettingParam.saveMode) ?? 1;
    _wgtMode = mySettingParam.wgtMode;
    if (mySettingParam.scaleMode.toString() == wgtCheckMode) {
      _wgtMode = 0;
    }
    super.initState();
  }

  @override
  void dispose() {
    zeroRange.dispose();
    stableTime.dispose();
    errorText.dispose();
    zeroRange.dispose();
    stableTime.dispose();
    errorText.dispose();
    super.dispose();
  }

  showTypeDropDownButton(String hintText, TextEditingController valueCtl) {
    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 5, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: SizedBox());
  }

  @override
  Widget build(BuildContext context) {
    return TMaxDialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        height: 493,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              (localizedStrings?.gParameterSettingsTitle ?? "gParameterSettingsTitle"),
              true,
            ),

            // 中部
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(
                        left: regularPadding,
                        right: regularPadding,
                        top: largePadding),
                    child: Row(children: [
                      Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              if (mySettingParam.scaleMode.toString() !=
                                  wgtCheckMode)
                                showTitleName(
                                    (localizedStrings?.gTipWeightSummationMode ?? "gTipWeightSummationMode")),
                              showTitleName(localizedStrings?.save_mode ?? "save_mode"),
                              showTitleName(localizedStrings?.gTipStableTime ?? "gTipStableTime"),
                              showTitleName(localizedStrings?.date_format ?? "date_format"),
                              showTitleName(localizedStrings?.gDateSeparator ?? "gDateSeparator"),
                              if (mySettingParam.scaleMode == 1)
                                showTitleName(localizedStrings?.gTipSaveType ?? "gTipSaveType"),
                            ],
                          )),
                      SizedBox(
                        width: largePadding,
                      ),
                      Expanded(
                          flex: mySettingParam.scaleMode == 1
                              ? 3
                              : 2, //检重秤hi low ok占宽度
                          child: Column(
                            children: [
                              if (mySettingParam.scaleMode.toString() !=
                                  wgtCheckMode)
                                SizedBox(
                                  height: 42,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _wgtMode = 1;
                                            _checkSaveMode = 1;
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          width: 120,
                                          child: Row(
                                            children: [
                                              wgtModeSingleRadio(1),
                                              Expanded(
                                                  child: Text(
                                                'Yes',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .apply(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant),
                                                overflow: TextOverflow.ellipsis,
                                              ))
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _wgtMode = 0;
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          width: 120,
                                          child: Row(
                                            children: [
                                              wgtModeSingleRadio(0),
                                              Expanded(
                                                  child: Text(
                                                'No',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .apply(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant),
                                                overflow: TextOverflow.ellipsis,
                                              ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: 42,
                                child: Row(
                                  children: [
                                    showSaveModeWidget(
                                        1, (localizedStrings?.gTipManual ?? "gTipManual")),
                                    showSaveModeWidget(
                                        2, (localizedStrings?.gTipAuto ?? "gTipAuto"))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 42,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 100,
                                      height: 30,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          enabled: (_checkSaveMode == 2)
                                              ? true
                                              : false,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant,
                                            ),
                                          ),
                                        ),
                                        controller: stableTime,
                                        maxLengthEnforcement:
                                            MaxLengthEnforcement.enforced,
                                        maxLines: 1,
                                        inputFormatters: [
                                          // 限制输入为数字
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          // 自定义输入格式化器，限制输入 0 到 20 之间的整数
                                          TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            if (newValue.text.isEmpty) {
                                              return newValue;
                                            }
                                            final int? value =
                                                int.tryParse(newValue.text);
                                            if (value != null &&
                                                value >= 0 &&
                                                value <= 20) {
                                              return newValue;
                                            }
                                            return oldValue;
                                          }),
                                        ],
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        onChanged: (value) {
                                          if (stableTime.text
                                              .toString()
                                              .isNotEmpty) {
                                            if (int.parse(stableTime.text
                                                    .toString()) >
                                                20) {
                                              errorText.text = localizedStrings
                                                  .stable_time_error_tip;
                                            } else {
                                              errorText.text = "";
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 42,
                                child: Row(
                                  children: [
                                    dateFormatRadio(1, "yy-mm-dd"),
                                    dateFormatRadio(2, "dd-mm-yy"),
                                    dateFormatRadio(3, "mm-dd-yy"),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 42,
                                child: Row(
                                  children: [
                                    dateSeparatorRadio(1, "."),
                                    dateSeparatorRadio(2, "-"),
                                    dateSeparatorRadio(3, "/"),
                                  ],
                                ),
                              ),
                              if (mySettingParam.scaleMode == 1)
                                SizedBox(
                                  height: 42,
                                  child: Row(
                                    children: [
                                      checkHiLowRadio(1, 'All'),
                                      checkHiLowRadio(2, 'Hi'),
                                      checkHiLowRadio(3, 'Ok'),
                                      checkHiLowRadio(4, 'Low'),
                                    ],
                                  ),
                                ),
                            ],
                          )),
                    ]))),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        updateUIConf();
                        Navigator.pop(context);
                      },
                      child: Text(
                        (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateUIConf() {
    myScaleCmd.cmdMode = "update_ui_conf";
    mySettingParam.wgtMode = _wgtMode;
    mySettingParam.dateFormat = _checkDateMode.toString();
    mySettingParam.recMode = (_checkSaveMode == 2) ? msgAuto : msgManual;
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
    PublicFunctions.sendMsgChan0(jsonEncode(myScaleCmd));
  }

  Widget dateSeparatorRadio(int data, String str) {
    return Container(
      alignment: Alignment.centerLeft,
      width: 120,
      child: Row(
        children: [
          Radio(
              value: data,
              groupValue: _checkDateSeparator,
              onChanged: (value) {
                setState(() {
                  _checkDateSeparator = data;
                });
              }),
          Expanded(
              child: Text(
            str,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ))
        ],
      ),
    );
  }

  Widget dateFormatRadio(int type, String str) {
    return Container(
      alignment: Alignment.centerLeft,
      width: 120,
      child: Row(
        children: [
          Radio(
              value: type,
              groupValue: _checkDateMode,
              onChanged: (value) {
                setState(() {
                  _checkDateMode = type;
                });
              }),
          Expanded(
              child: Text(
            str,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ))
        ],
      ),
    );
  }

  Radio wgtModeSingleRadio(int radioId) {
    return Radio(
        value: radioId,
        groupValue: _wgtMode,
        onChanged: (value) {
          setState(() {
            _wgtMode = radioId;
            if (_wgtMode == 1) {
              _checkSaveMode = 1;
            }
          });
        });
  }

  Widget showSaveModeWidget(int type, String title) {
    return Container(
      alignment: Alignment.centerLeft,
      width: 120,
      child: Row(
        children: [
          saveModeSingleRadio(type),
          Expanded(
              child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ))
        ],
      ),
    );
  }

  Radio saveModeSingleRadio(int radioId) {
    return Radio(
        value: radioId,
        groupValue: _checkSaveMode,
        onChanged: _wgtMode == 1
            ? null
            : (value) {
                setState(() {
                  _checkSaveMode = radioId;
                });
              });
  }

  showTitleName(String title) {
    return Container(
      height: 42,
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .apply(color: Theme.of(context).colorScheme.onSurface),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget checkHiLowRadio(int data, String str) {
    return Container(
      alignment: Alignment.centerLeft,
      width: 120,
      child: Row(
        children: [
          Radio(
              value: data,
              groupValue: _checkHiLow,
              onChanged: (value) {
                // debugPrint(value.toString());
                setState(() {
                  _checkHiLow = data;
                });
              }),
          Expanded(
              child: Text(
            str,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ))
        ],
      ),
    );
  }
}

class ParamSettingDialog extends StatefulWidget {
  const ParamSettingDialog({super.key});

  @override
  ParamSettingDialogState createState() => ParamSettingDialogState();
}

class ParamSettingDialogState extends State<ParamSettingDialog> {
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
        : (mySettingParam.recMode == msgAuto)
            ? 2
            : (mySettingParam.recMode == msgManual)
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
    _checkHiLow = int.tryParse(mySettingParam.saveMode) ?? 1;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(context, (localizedStrings?.gParameterSettingsTitle ?? "gParameterSettingsTitle"),
          Icons.settings_outlined, 400),
      content: Container(
          height: 300,
          width: 440,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryFixed),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary),
                  child: Column(
                    children: [
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
                                      (localizedStrings?.gTipStableTime ?? "gTipStableTime") + ":",
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
                                        (localizedStrings?.date_format ?? "date_format") + ":",
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
                                  SizedBox(
                                      width: 200,
                                      child: Text(
                                        (localizedStrings?.gDateSeparator ?? "gDateSeparator") + ":",
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
                              const SizedBox(height: 5),
                              (mySettingParam.scaleMode == 1)
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            (localizedStrings?.save_mode ?? "save_mode") + ":",
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
              text: (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
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
              text: (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
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
    mySettingParam.recMode = (_checkSaveMode == 2) ? msgAuto : msgManual;
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
    PublicFunctions.sendMsgChan0(jsonEncode(myScaleCmd));
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
              (localizedStrings?.save_mode ?? "save_mode") + ":",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
        Column(
          children: [
            Row(
              children: [
                saveModeSingleRadio(1),
                SizedBox(
                    width: 200,
                    child: Text(
                      (localizedStrings?.gTipManual ?? "gTipManual"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
            Row(
              children: [
                saveModeSingleRadio(2),
                SizedBox(
                    width: 200,
                    child: Text(
                      (localizedStrings?.gTipAuto ?? "gTipAuto"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            )
          ],
        )
      ],
    );
  }

  Radio saveModeSingleRadio(int radioId) {
    return Radio(
        value: radioId,
        groupValue: _checkSaveMode,
        onChanged: (value) {
          // debugPrint(value.toString());
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
          // debugPrint(value.toString());
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
              // debugPrint(value.toString());
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
              // debugPrint(value.toString());
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
              // debugPrint(value.toString());
              setState(() {
                _checkHiLow = data;
              });
            }),
        Text(str),
      ],
    );
  }
}
