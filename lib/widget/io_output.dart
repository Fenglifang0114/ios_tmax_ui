import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/readoutput.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class SetOutputPortDialog extends StatefulWidget {
  const SetOutputPortDialog({super.key});
  @override
  State<SetOutputPortDialog> createState() => _SetOutputPortDialogState();
}

class _SetOutputPortDialogState extends State<SetOutputPortDialog> {
  TextEditingController btnTypeCtl0 = TextEditingController(text: "None");
  TextEditingController btnTypeCtl1 = TextEditingController(text: "None");
  TextEditingController btnTypeCtl2 = TextEditingController(text: "None");
  TextEditingController btnTypeCtl3 = TextEditingController(text: "None");

  List<String> btnTypeList = [
    "None",
    "Start",
    "Pause",
    "Tare",
    "Zero",
  ];

  // 《无》《启动》《暂停》《扣重》《归零》

  List<TextEditingController> delayedStartCtl = [];
  List<TextEditingController> triggerOffCtl = [];
  List<TextEditingController> remarkCtl = [];
  List<bool> isPortOn = [];

  String errString = '';
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;

  List<RespOutputInfo> outputPortStatusList = [];
  List<InputInfo> inputPortStatusList = [];

  @override
  void initState() {
    super.initState();

    // 初始化12个端口的控制器
    for (int i = 0; i < 12; i++) {
      delayedStartCtl.add(TextEditingController());
      triggerOffCtl.add(TextEditingController());
      remarkCtl.add(TextEditingController());
      isPortOn.add(false);
    }

    PublicFunctions.getOutputPortStatus();
    PublicFunctions.getInputPortStatus();

    _eventbus1 = eventBus.on<EventRespGetOutputPortStatus>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            List<RespOutputInfo> tempList = respOutputInfoFromJson(dataStr);

            setState(() {
              if (tempList.isNotEmpty) {
                outputPortStatusList = tempList;

                // 更新每个端口的控制器值
                for (var element in tempList) {
                  int index = element.port! - 1; // 端口从1开始，索引从0开始
                  if (index >= 0 && index < 12) {
                    isPortOn[index] = element.status ?? false;
                    delayedStartCtl[index].text =
                        element.startTime?.toString() ?? '';
                    triggerOffCtl[index].text =
                        element.endValue?.toString() ?? '';
                    remarkCtl[index].text = element.remark ?? '';
                  }
                }
              }
            });
          } catch (e) {
            setState(() {});
          }
        } else {
          setState(() {});
        }
      }
    });

    _eventbus2 = eventBus.on<EventRespUpdateOutputPort>().listen((event) {
      if (mounted) {
        PublicFunctions.getOutputPortStatus();
      }
    });

    _eventbus3 = eventBus.on<EventRespGetInputPortStatus>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            List<InputInfo> tempList = inputInfoFromJson(dataStr);

            setState(() {
              if (tempList.isNotEmpty) {
                inputPortStatusList = tempList;

                // 更新每个端口的控制器值
                for (var element in tempList) {
                  if (element.port == 1) {
                    btnTypeCtl0.text = element.btn ?? '';
                  }
                  if (element.port == 2) {
                    btnTypeCtl1.text = element.btn ?? '';
                  }
                  if (element.port == 3) {
                    btnTypeCtl2.text = element.btn ?? '';
                  }
                  if (element.port == 4) {
                    btnTypeCtl3.text = element.btn ?? '';
                  }
                }
              }
            });
          } catch (e) {
            setState(() {});
          }
        } else {
          setState(() {});
        }
      }
    });

    _eventbus4 = eventBus.on<EventRespUpdateInputPort>().listen((event) {
      if (mounted) {
        PublicFunctions.getInputPortStatus();
      }
    });
  }

  @override
  void dispose() {
    btnTypeCtl0.dispose();
    btnTypeCtl1.dispose();
    btnTypeCtl2.dispose();
    btnTypeCtl3.dispose();
    super.dispose();

    // 释放所有控制器
    for (var ctl in delayedStartCtl) {
      ctl.dispose();
    }
    for (var ctl in triggerOffCtl) {
      ctl.dispose();
    }
    for (var ctl in remarkCtl) {
      ctl.dispose();
    }

    _eventbus1?.cancel();
    _eventbus2?.cancel();
    _eventbus3?.cancel();
    _eventbus4?.cancel();
  }

  // 更新所有输出端口状态
  void updateAllOutputPorts() {
    List<ReqGetOutput> reqGetOutputList = [];
    for (int i = 0; i < 12; i++) {
      if (delayedStartCtl[i].text.isNotEmpty &&
          triggerOffCtl[i].text.isNotEmpty) {
        int portNumber = i + 1;

        ReqGetOutput reqGetOutput = ReqGetOutput(
            port: portNumber,
            status: isPortOn[i],
            startTime: int.tryParse(delayedStartCtl[i].text) ?? 0,
            endValue: double.tryParse(triggerOffCtl[i].text) ?? 0.0,
            remark: remarkCtl[i].text);

        reqGetOutputList.add(reqGetOutput);
      }
    }

    String jsonStr = reqOutputToJson(reqGetOutputList);
    PublicFunctions.updateOutputPortStatus(jsonStr);
  }

  // 更新所有输入端口状态
  void updateAllInputPorts() {
    List<SetBtnInfo> btnInfoList = [];

    if (btnTypeCtl0.text.isNotEmpty) {
      int portNumber = 1;
      SetBtnInfo btnInfo = SetBtnInfo(port: portNumber, btn: btnTypeCtl0.text);

      btnInfoList.add(btnInfo);
    }
    if (btnTypeCtl1.text.isNotEmpty) {
      int portNumber = 2;
      SetBtnInfo btnInfo = SetBtnInfo(port: portNumber, btn: btnTypeCtl1.text);

      btnInfoList.add(btnInfo);
    }
    if (btnTypeCtl2.text.isNotEmpty) {
      int portNumber = 3;
      SetBtnInfo btnInfo = SetBtnInfo(port: portNumber, btn: btnTypeCtl2.text);

      btnInfoList.add(btnInfo);
    }
    if (btnTypeCtl3.text.isNotEmpty) {
      int portNumber = 4;
      SetBtnInfo btnInfo = SetBtnInfo(port: portNumber, btn: btnTypeCtl3.text);

      btnInfoList.add(btnInfo);
    }

    String jsonStr = setInputInfoToJson(btnInfoList);
    PublicFunctions.updateInputPortStatus(jsonStr);
  }

  Widget showTypeDropDownButton(
      String hintText, TextEditingController valueCtl) {
    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton(
            underline: SizedBox(),
            isExpanded: true,
            value: valueCtl.text == "" ? null : valueCtl.text,
            items: [
              ...btnTypeList.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item,
                      style: Theme.of(context).textTheme.bodySmall?.apply(
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                );
              })
            ],
            onChanged: (value) {
              if (value == null) {
                setState(() {
                  valueCtl.text = '';
                });

                return;
              }

              setState(() {
                valueCtl.text = value.toString();
              });
            },
            style: Theme.of(context).textTheme.bodySmall?.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1000, // 稍微加宽以适应更多列
        height: 688, // 增加高度以显示12行
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              (localizedStrings?.ioSetting ?? "ioSetting"),
              true,
              onClose: () {
                Navigator.of(context).pop();
              },
            ),

            SizedBox(
              height: 150,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: largePadding,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (localizedStrings?.inputSetting ?? "inputSetting"),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 90,
                        child: Column(children: [
                          showItemNameWithStar(context,
                              (localizedStrings?.inputPort ?? "inputPort") + " 1", false),
                          Row(
                            children: [
                              Expanded(
                                child: showTypeDropDownButton("", btnTypeCtl0),
                              ),
                            ],
                          )
                        ]),
                      ),
                      SizedBox(
                        width: 200,
                        height: 90,
                        child: Column(children: [
                          showItemNameWithStar(context,
                              (localizedStrings?.inputPort ?? "inputPort") + " 2", false),
                          Row(
                            children: [
                              Expanded(
                                child: showTypeDropDownButton("", btnTypeCtl1),
                              ),
                            ],
                          )
                        ]),
                      ),
                      SizedBox(
                        width: 200,
                        height: 90,
                        child: Column(children: [
                          showItemNameWithStar(context,
                              (localizedStrings?.inputPort ?? "inputPort") + " 3", false),
                          Row(
                            children: [
                              Expanded(
                                child: showTypeDropDownButton("", btnTypeCtl2),
                              ),
                            ],
                          )
                        ]),
                      ),
                      SizedBox(
                        width: 200,
                        height: 90,
                        child: Column(children: [
                          showItemNameWithStar(context,
                              (localizedStrings?.inputPort ?? "inputPort") + " 4", false),
                          Row(
                            children: [
                              Expanded(
                                child: showTypeDropDownButton("", btnTypeCtl3),
                              ),
                            ],
                          )
                        ]),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(
                horizontal: largePadding,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                (localizedStrings?.outputSetting ?? "outputSetting"),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // 表头
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: largePadding, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      (localizedStrings?.outputPort ?? "outputPort"),
                      style: Theme.of(context).textTheme.labelMedium?.apply(),
                    ),
                  ),
                  SizedBox(width: regularPadding),
                  SizedBox(
                    width: 180,
                    child: Text(
                      (localizedStrings?.delayedStart ?? "delayedStart"),
                      style: Theme.of(context).textTheme.labelMedium?.apply(),
                    ),
                  ),
                  SizedBox(width: regularPadding),
                  SizedBox(
                    width: 200,
                    child: Text(
                      (localizedStrings?.triggerOffValue ?? "triggerOffValue"),
                      style: Theme.of(context).textTheme.labelMedium?.apply(),
                    ),
                  ),
                  SizedBox(width: regularPadding),
                  SizedBox(
                    width: 300,
                    child: Text(
                      (localizedStrings?.fRemarkCol ?? "fRemarkCol"),
                      style: Theme.of(context).textTheme.labelMedium?.apply(),
                    ),
                  ),
                  SizedBox(width: regularPadding),
                  SizedBox(
                    width: 80,
                    child: Text(
                      "",
                      style: Theme.of(context).textTheme.labelMedium?.apply(),
                    ),
                  ),
                ],
              ),
            ),

            // 中部 - 12行输出端口配置
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                  left: largePadding,
                  right: largePadding,
                ),
                child: ListView.builder(
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    int portNumber = index + 1;
                    return Container(
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          // 端口序号
                          Container(
                            width: 100,
                            alignment: Alignment.center,
                            child: Text(
                              portNumber.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.apply(),
                            ),
                          ),
                          SizedBox(width: regularPadding),

                          // 延迟时间输入
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: delayedStartCtl[index],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                hintText: "0",
                                hintStyle: getTextStyle(
                                  color: colorScheme.surface,
                                ),
                                suffixText: "ms",
                                suffixStyle: getTextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              style: getTextStyle(),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(width: regularPadding),

                          // 触发值输入
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: triggerOffCtl[index],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                hintText: "0.0",
                                hintStyle: getTextStyle(
                                  color: colorScheme.surface,
                                ),
                                prefixText: "<     ",
                                prefixStyle: getTextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                suffixText: "g",
                                suffixStyle: getTextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              style: getTextStyle(),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(width: regularPadding),
                          // 输入备注
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: remarkCtl[index],
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                hintText: (localizedStrings?.fRemarkCol ?? "fRemarkCol"),
                                hintStyle: getTextStyle(
                                  color: colorScheme.surface,
                                ),
                              ),
                              style: getTextStyle(),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(width: regularPadding),

                          // 开关
                          SizedBox(
                            width: 80,
                            child: IconButton(
                              iconSize: 36,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(isPortOn[index]
                                  ? Icons.toggle_on_outlined
                                  : Icons.toggle_off_outlined),
                              color: isPortOn[index]
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onTertiaryFixedVariant
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              onPressed: () {
                                setState(() {
                                  isPortOn[index] = !isPortOn[index];
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // 底部按钮
            Container(
              height: 60,
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
                        updateAllOutputPorts();
                        Future.delayed(const Duration(seconds: 1), () {
                          updateAllInputPorts();
                        });

                        Navigator.of(context).pop();
                      },
                      child: Text(
                        (localizedStrings?.gBtnSave ?? "gBtnSave"),
                        style: Theme.of(context).textTheme.bodySmall?.apply(
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
                            .surface,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        (localizedStrings?.button_back ?? "button_back"),
                        style: Theme.of(context).textTheme.bodySmall?.apply(
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

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall?.apply(
          color: color ?? colorScheme.onSurface,
        ) ?? const TextStyle();
  }
}
