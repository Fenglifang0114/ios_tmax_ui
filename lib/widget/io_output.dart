import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/readoutput.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class SetOutputPortDialog extends StatefulWidget {
  const SetOutputPortDialog({super.key});
  @override
  State<SetOutputPortDialog> createState() => _SetOutputPortDialogState();
}

class _SetOutputPortDialogState extends State<SetOutputPortDialog> {
  List<TextEditingController> delayedStartCtl = [];
  List<TextEditingController> triggerOffCtl = [];
  List<TextEditingController> remarkCtl = [];
  List<bool> isPortOn = [];

  String errString = '';
  dynamic _eventbus1;
  dynamic _eventbus2;

  List<RespOutputInfo> outputPortStatusList = [];

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
  }

  @override
  void dispose() {
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
              localizedStrings.ioSetting,
              true,
              onClose: () {
                Navigator.of(context).pop();
              },
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
                      localizedStrings.outputPort,
                      style: Theme.of(context).textTheme.labelMedium?.apply(),
                    ),
                  ),
                  SizedBox(width: regularPadding),
                  SizedBox(
                    width: 180,
                    child: Text(
                      localizedStrings.delayedStart,
                      style: Theme.of(context).textTheme.labelMedium?.apply(),
                    ),
                  ),
                  SizedBox(width: regularPadding),
                  SizedBox(
                    width: 200,
                    child: Text(
                      localizedStrings.triggerOffValue,
                      style: Theme.of(context).textTheme.labelMedium?.apply(),
                    ),
                  ),
                  SizedBox(width: regularPadding),
                  SizedBox(
                    width: 300,
                    child: Text(
                      localizedStrings.fRemarkCol,
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
                                  color: colorScheme.surfaceContainerHighest,
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
                                  color: colorScheme.surfaceContainerHighest,
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
                                hintText: localizedStrings.fRemarkCol,
                                hintStyle: getTextStyle(
                                  color: colorScheme.surfaceContainerHighest,
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
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        localizedStrings.gBtnSave,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
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
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        localizedStrings.button_back,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
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
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? colorScheme.onSurface,
        );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:t_max/data/home_page_common_data.dart';
// import 'package:t_max/data/icons.dart';
// import 'package:t_max/data/language.dart';
// import 'package:t_max/data/readoutput.dart';
// import 'package:t_max/eventbus/eventbus.dart';
// import 'package:t_max/functions/methods.dart';
// import 'package:t_max/widget/common_widget.dart';
// import 'package:t_max/widget/dialog_head_style.dart';

// class SetOutputPortDialog extends StatefulWidget {
//   const SetOutputPortDialog({super.key});
//   @override
//   State<SetOutputPortDialog> createState() => _SetOutputPortDialogState();
// }

// class _SetOutputPortDialogState extends State<SetOutputPortDialog> {
//   TextEditingController outputPortCtl = TextEditingController();
//   TextEditingController delayedStartCtl = TextEditingController();
//   TextEditingController triggerOffCtl = TextEditingController();

//   String errString = '';
//   dynamic _eventbus1;
//   dynamic _eventbus2;
//   bool isPortOn = false;

//   List<RespOutputInfo> outputPortStatusList = [];

//   @override
//   void initState() {
//     super.initState();
//     PublicFunctions.getOutputPortStatus();

//     _eventbus1 = eventBus.on<EventRespGetOutputPortStatus>().listen((event) {
//       if (mounted) {
//         String dataStr = event.obj;
//         if (dataStr != '' && dataStr != 'null') {
//           try {
//             List<RespOutputInfo> tempList = respOutputInfoFromJson(dataStr);

//             setState(() {
//               if (tempList.isNotEmpty) {
//                 outputPortStatusList = tempList;
//               }
//             });
//           } catch (e) {
//             print(e);
//             setState(() {});
//           }
//         } else {
//           setState(() {});
//         }
//       }
//     });
//     _eventbus2 = eventBus.on<EventRespUpdateOutputPort>().listen((event) {
//       if (mounted) {
//         PublicFunctions.getOutputPortStatus();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     outputPortCtl.dispose();
//     delayedStartCtl.dispose();
//     triggerOffCtl.dispose();

//     _eventbus1?.cancel();
//     _eventbus2?.cancel();
//   }

//   bool searchFmaBarcode(String barcode) {
//     if (barcode.isEmpty) {
//       return false;
//     }
//     // 搜索配方
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         width: 861,
//         height: 688,
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface,
//           borderRadius: BorderRadius.circular(0),
//         ),
//         child: Column(
//           children: [
//             // 头部
//             ...dialogHeadStyle(
//               context,
//               localizedStrings.ioSetting,
//               true,
//               onClose: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             // 中部
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.only(
//                     left: largePadding,
//                     right: largePadding,
//                     bottom: largePadding * 2),
//                 child: Column(children: [
//                   Container(
//                     height: largePadding,
//                     alignment: Alignment.centerLeft,
//                   ),
//                   Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         SizedBox(
//                           height: 40,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               // 使用 ConstrainedBox 限制按钮的最大宽度为 300
//                               getSvgIcon(outputSvgIcon(), 50, 50,
//                                   Theme.of(context).colorScheme.primary),
//                               SizedBox(width: largePadding),
//                               Text(
//                                   "${localizedStrings.outputPort} ${outputPortCtl.text}",
//                                   textAlign: TextAlign.left,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .onSurface,
//                                       )),
//                             ],
//                           ),
//                         ),
//                         Expanded(flex: 1, child: SizedBox()),
//                         SizedBox(
//                           width: 40,
//                           height: 40,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               // 使用 ConstrainedBox 限制按钮的最大宽度为 300
//                               SizedBox(
//                                 child: IconButton(
//                                     iconSize: 36,
//                                     padding: EdgeInsets.zero,
//                                     visualDensity: VisualDensity.compact,
//                                     icon: Icon(isPortOn
//                                         ? Icons.toggle_on_outlined
//                                         : Icons.toggle_off_outlined),
//                                     color: isPortOn
//                                         ? Theme.of(context)
//                                             .colorScheme
//                                             .onTertiaryFixedVariant
//                                         : Theme.of(context)
//                                             .colorScheme
//                                             .onSurfaceVariant,
//                                     onPressed: () {
//                                       setState(() {
//                                         isPortOn = !isPortOn;
//                                       });
//                                     }),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ]),
//                   Container(
//                     height: largePadding,
//                     alignment: Alignment.centerLeft,
//                   ),
//                   SizedBox(
//                     height: 90,
//                     width: 590,
//                     child: Row(children: [
//                       Expanded(
//                           flex: 1,
//                           child: Column(children: [
//                             showItemNameWithStar(
//                                 context, localizedStrings.outputPort, false),
//                             showOutputDropDownBtn(localizedStrings.outputPort),
//                           ])),
//                       SizedBox(
//                         width: largePadding,
//                       ),
//                       Expanded(
//                           flex: 1,
//                           child: Column(children: [
//                             showItemNameWithStar(
//                                 context, localizedStrings.delayedStart, false),
//                             SizedBox(
//                                 height: 48,
//                                 child: Row(children: [
//                                   Expanded(
//                                     child: TextField(
//                                       onChanged: (value) {
//                                         setState(() {});
//                                       },
//                                       controller: delayedStartCtl,
//                                       inputFormatters: [
//                                         FilteringTextInputFormatter.allow(
//                                             RegExp(
//                                                 r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
//                                         LengthLimitingTextInputFormatter(10),
//                                       ],
//                                       decoration: InputDecoration(
//                                         border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(0.0))),
//                                         hintText: "",
//                                         hintStyle: getTextStyle(
//                                           color: colorScheme
//                                               .surfaceContainerHighest,
//                                         ),
//                                         suffixIcon: Container(
//                                             width: 50,
//                                             alignment: Alignment.center,
//                                             child: Center(
//                                               child: Text(
//                                                 "ms",
//                                                 style: getTextStyle(
//                                                   color: colorScheme
//                                                       .onSurfaceVariant,
//                                                 ),
//                                               ),
//                                             )),
//                                       ),
//                                       style: getTextStyle(),
//                                     ),
//                                   ),
//                                 ]))
//                           ])),
//                       SizedBox(
//                         width: largePadding,
//                       ),
//                       Expanded(
//                           flex: 1,
//                           child: Column(children: [
//                             showItemNameWithStar(context,
//                                 localizedStrings.triggerOffValue, false),
//                             SizedBox(
//                                 height: 48,
//                                 child: Row(children: [
//                                   Expanded(
//                                     child: TextField(
//                                       onChanged: (value) {
//                                         setState(() {});
//                                       },
//                                       controller: triggerOffCtl,
//                                       inputFormatters: [
//                                         FilteringTextInputFormatter.allow(
//                                             RegExp(
//                                                 r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
//                                         LengthLimitingTextInputFormatter(10),
//                                       ],
//                                       decoration: InputDecoration(
//                                         border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(0.0))),
//                                         hintText: "",
//                                         hintStyle: getTextStyle(
//                                           color: colorScheme
//                                               .surfaceContainerHighest,
//                                         ),
//                                         prefixIcon: Container(
//                                           width: 30,
//                                           alignment: Alignment.center,
//                                           child: Text(
//                                             "<",
//                                             style: getTextStyle(
//                                               color:
//                                                   colorScheme.onSurfaceVariant,
//                                             ),
//                                           ),
//                                         ),
//                                         suffixIcon: Container(
//                                             width: 50,
//                                             alignment: Alignment.center,
//                                             child: Center(
//                                               child: Text(
//                                                 "g",
//                                                 style: getTextStyle(
//                                                   color: colorScheme
//                                                       .onSurfaceVariant,
//                                                 ),
//                                               ),
//                                             )),
//                                       ),
//                                       style: getTextStyle(),
//                                     ),
//                                   ),
//                                 ]))
//                           ])),
//                     ]),
//                   ),
//                 ]),
//               ),
//             ),
//             // 底部
//             Container(
//               height: 96,
//               width: 400,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onPrimary,
//                         backgroundColor: Theme.of(context).colorScheme.primary,
//                         fixedSize: const Size(double.infinity, 48),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.zero,
//                         ),
//                       ),
//                       onPressed: outputPortCtl.text.isEmpty ||
//                               delayedStartCtl.text.isEmpty ||
//                               triggerOffCtl.text.isEmpty
//                           ? null
//                           : () {
//                               int port = int.parse(outputPortCtl.text);
//                               int delayedStart =
//                                   int.parse(delayedStartCtl.text);
//                               double triggerOff =
//                                   double.parse(triggerOffCtl.text);

//                               ReqGetOutput reqGetOutput = ReqGetOutput(
//                                   port: port,
//                                   status: isPortOn,
//                                   startTime: delayedStart,
//                                   endValue: triggerOff);

//                               String jsonStr = reqGetOutputToJson(reqGetOutput);
//                               PublicFunctions.updateOutputPortStatus(jsonStr);
//                             },
//                       child: Text(
//                         localizedStrings.gBtnConfirm,
//                         style: Theme.of(context).textTheme.bodySmall!.apply(
//                               color: Theme.of(context).colorScheme.onPrimary,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onSurfaceVariant,
//                         backgroundColor: Theme.of(context)
//                             .colorScheme
//                             .surfaceContainerHighest,
//                         fixedSize: const Size(double.infinity, 48),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.zero,
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text(
//                         localizedStrings.gBtnCancel,
//                         style: Theme.of(context).textTheme.bodySmall!.apply(
//                               color: Theme.of(context).colorScheme.onPrimary,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   ColorScheme get colorScheme => Theme.of(context).colorScheme;

//   TextStyle getTextStyle({Color? color}) {
//     return Theme.of(context).textTheme.bodySmall!.apply(
//           color: color ?? colorScheme.onSurface,
//         );
//   }

//   List<String> outputPortList = [
//     "1",
//     "2",
//     "3",
//     "4",
//     "5",
//     "6",
//     "7",
//     "8",
//     "9",
//     "10",
//     "11",
//     "12"
//   ];

//   //选择输出端口
//   Widget showOutputDropDownBtn(String hintText) {
//     return Container(
//         height: 48,
//         padding: const EdgeInsets.only(left: 10, right: 10),
//         decoration: BoxDecoration(
//           border: Border.all(
//               color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
//           borderRadius: BorderRadius.circular(0), // 设置圆角
//         ),
//         child: DropdownButton<String>(
//             // 明确指定泛型类型
//             underline: SizedBox(),
//             isExpanded: true,
//             value: outputPortCtl.text.isEmpty
//                 ? null
//                 : outputPortCtl.text, // 使用检查后的值
//             items: [
//               // 提示项
//               DropdownMenuItem<String>(
//                 value: null,
//                 child: Text(
//                   hintText,
//                   style: Theme.of(context).textTheme.bodySmall!.copyWith(
//                         fontSize: 12,
//                         color: Theme.of(context)
//                             .colorScheme
//                             .surfaceContainerHighest,
//                       ),
//                 ),
//               ),

//               ...outputPortList.map((String item) {
//                 return DropdownMenuItem<String>(
//                   value: item,
//                   child: Text(item,
//                       style: Theme.of(context).textTheme.bodySmall!.apply(
//                             color: Theme.of(context).colorScheme.onSurface,
//                           )),
//                 );
//               }),
//             ],
//             onChanged: (String? value) {
//               // 明确参数类型
//               if (value == null) {
//                 setState(() {
//                   outputPortCtl.text = '';
//                 });
//                 return;
//               }

//               setState(() {
//                 outputPortCtl.text = value;

//                 for (var element in outputPortStatusList) {
//                   if (element.port == int.parse(value)) {
//                     isPortOn = element.status ?? false;
//                     delayedStartCtl.text = element.startTime?.toString() ?? '';
//                     triggerOffCtl.text = element.endValue?.toString() ?? '';
//                     break;
//                   }
//                 }
//               });
//             },
//             style: Theme.of(context).textTheme.bodySmall!.apply(
//                   color: Theme.of(context).colorScheme.onSurface,
//                 )));
//   }
// }
