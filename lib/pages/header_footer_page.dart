import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/pages/update_firmware_page.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import '../data/header_footer.dart';
import '../data/language.dart';
import '../data/scalecmd_data.dart';

class HeaderFooterPage extends StatefulWidget {
  const HeaderFooterPage({super.key});
  // 新增静态方法，用于显示对话框
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // 点击对话框外部关闭对话框
      builder: (context) => const HeaderFooterPage(),
    );
  }

  @override
  State<HeaderFooterPage> createState() => HeaderFooterPageState();
}

class HeaderFooterPageState extends State<HeaderFooterPage> {
  TextEditingController header1Ctl = TextEditingController(text: '');
  TextEditingController header2Ctl = TextEditingController(text: '');
  TextEditingController header3Ctl = TextEditingController(text: '');
  TextEditingController footer1Ctl = TextEditingController(text: '');
  TextEditingController footer2Ctl = TextEditingController(text: '');
  TextEditingController footer3Ctl = TextEditingController(text: '');

  TextEditingController operator1Ctl = TextEditingController(text: '');
  TextEditingController operator2Ctl = TextEditingController(text: '');
  TextEditingController operator3Ctl = TextEditingController(text: '');
  TextEditingController operator4Ctl = TextEditingController(text: '');

  Map<String, TextEditingController> titleMap = {};

  bool isDownloadClicked = false;
  List<MyvariableData> varList = [];

  @override
  void initState() {
    titleMap = {
      'Header1': header1Ctl,
      'Header2': header2Ctl,
      'Header3': header3Ctl,
      'Footer1': footer1Ctl,
      'Footer2': footer2Ctl,
      'Footer3': footer3Ctl,
      'Operator1': operator1Ctl,
      'Operator2': operator2Ctl,
      'Operator3': operator3Ctl,
      'Operator4': operator4Ctl
    };
    openVarListJson();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    return Dialog(
      child: Container(
          width: 1000,
          height: 600,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...dialogHeadStyle(
                  context,
                  localizedStrings.menuVariableValueSetting,
                  true,
                ),
                Expanded(
                    child: SizedBox(
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.all(largePadding),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 42,
                              child: Row(children: [
                                showHeader(localizedStrings.rTipHeader,
                                    Theme.of(context).colorScheme.primary),
                                SizedBox(
                                  width: smallPadding,
                                ),
                                showHeader(localizedStrings.rTipFooter,
                                    Theme.of(context).colorScheme.primary),
                                SizedBox(
                                  width: smallPadding,
                                ),
                                showHeader(localizedStrings.rTipOperator,
                                    Theme.of(context).colorScheme.primary),
                              ]),
                            ),
                            SizedBox(
                              height: 70,
                              child: Row(
                                // 让子组件在水平方向均匀分布
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      showHeader(
                                          localizedStrings.rTipHeader + ' 1:',
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                      SizedBox(
                                        height: btnHeight,
                                        child: _buildEditFeild(header1Ctl),
                                      )
                                    ],
                                  )),
                                  SizedBox(
                                    width: smallPadding,
                                  ),
                                  Expanded(
                                      child: SizedBox(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        showHeader(
                                            localizedStrings.rTipFooter + ' 1:',
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        SizedBox(
                                          height: btnHeight,
                                          child: _buildEditFeild(footer1Ctl),
                                        )
                                      ],
                                    ),
                                  )),
                                  SizedBox(
                                    width: smallPadding,
                                  ),
                                  Expanded(
                                      child: Container(
                                    padding: EdgeInsets.only(right: 0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        showHeader(
                                            localizedStrings.rTipOperator +
                                                ' 1:',
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        SizedBox(
                                          height: btnHeight,
                                          child: _buildEditFeild(operator1Ctl),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: largePadding,
                            ),
                            SizedBox(
                              height: 70,
                              child: Row(
                                // 让子组件在水平方向均匀分布
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      showHeader(
                                          localizedStrings.rTipHeader + ' 2:',
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                      SizedBox(
                                        height: btnHeight,
                                        child: _buildEditFeild(header2Ctl),
                                      )
                                    ],
                                  )),
                                  SizedBox(
                                    width: smallPadding,
                                  ),
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      showHeader(
                                          localizedStrings.rTipFooter + ' 2:',
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                      SizedBox(
                                        height: btnHeight,
                                        child: _buildEditFeild(footer2Ctl),
                                      )
                                    ],
                                  )),
                                  SizedBox(
                                    width: smallPadding,
                                  ),
                                  Expanded(
                                      child: Container(
                                    padding: EdgeInsets.only(right: 0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        showHeader(
                                            localizedStrings.rTipOperator +
                                                ' 2:',
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        SizedBox(
                                          height: btnHeight,
                                          child: _buildEditFeild(operator2Ctl),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: largePadding,
                            ),
                            SizedBox(
                              height: 70,
                              child: Row(
                                // 让子组件在水平方向均匀分布
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      showHeader(
                                          localizedStrings.rTipHeader + ' 3:',
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                      SizedBox(
                                        height: btnHeight,
                                        child: _buildEditFeild(header3Ctl),
                                      )
                                    ],
                                  )),
                                  SizedBox(
                                    width: smallPadding,
                                  ),
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      showHeader(
                                          localizedStrings.rTipFooter + ' 3:',
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                      SizedBox(
                                        height: btnHeight,
                                        child: _buildEditFeild(footer3Ctl),
                                      )
                                    ],
                                  )),
                                  SizedBox(
                                    width: smallPadding,
                                  ),
                                  Expanded(
                                      child: Container(
                                    padding: EdgeInsets.only(right: 0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        showHeader(
                                            localizedStrings.rTipOperator +
                                                ' 3:',
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        SizedBox(
                                          height: btnHeight,
                                          child: _buildEditFeild(operator3Ctl),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: largePadding,
                            ),
                            SizedBox(
                              height: 70,
                              child: Row(
                                // 让子组件在水平方向均匀分布
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Container()),
                                  SizedBox(
                                    width: smallPadding,
                                  ),
                                  Expanded(child: Container()),
                                  SizedBox(
                                    width: smallPadding,
                                  ),
                                  Expanded(
                                      child: Container(
                                    padding: EdgeInsets.only(right: 0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        showHeader(
                                            localizedStrings.rTipOperator +
                                                ' 4:',
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        SizedBox(
                                          height: btnHeight,
                                          child: _buildEditFeild(operator4Ctl),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                      Container(
                        height: 100,
                        color: Theme.of(context).colorScheme.surfaceTint,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              child: showTextButton(
                                  context,
                                  btnHeight,
                                  localizedStrings.gBtnDownload,
                                  (!isDownloadClicked) &&
                                          (header1Ctl.text.isNotEmpty ||
                                              header2Ctl.text.isNotEmpty ||
                                              header3Ctl.text.isNotEmpty ||
                                              footer1Ctl.text.isNotEmpty ||
                                              footer2Ctl.text.isNotEmpty ||
                                              footer3Ctl.text.isNotEmpty ||
                                              operator1Ctl.text.isNotEmpty ||
                                              operator2Ctl.text.isNotEmpty ||
                                              operator3Ctl.text.isNotEmpty ||
                                              operator4Ctl.text.isNotEmpty)
                                      ? () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible:
                                                false, // 点击对话框外部不关闭对话框
                                            builder: (BuildContext context) {
                                              return ShowNormalTipDialog(
                                                title:
                                                    localizedStrings.fTipTitle,
                                                msg: localizedStrings
                                                    .gTipConfirmInfo,
                                              );
                                            },
                                          ).then((confirmed) {
                                            if (confirmed == null) {
                                              return;
                                            }
                                            if (confirmed) {
                                              getJsonString();
                                              if (myHeaderFooterList
                                                  .listData.isEmpty) {
                                                if (mounted &&
                                                    context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              localizedStrings
                                                                  .gTipDataError,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)), ////此处需要秤回复
                                                          duration:
                                                              const Duration(
                                                                  seconds: 3),
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error));
                                                }

                                                return;
                                              }
                                              myScaleCmd.cmdMode =
                                                  'modify_var_value';
                                              myScaleCmd.cmdData = json
                                                  .encode(myHeaderFooterList);
                                              showSelScaleDialog(
                                                  1, jsonEncode(myScaleCmd));
                                            }
                                          });
                                          // _showConfirmationDialog(context);
                                        }
                                      : null,
                                  Theme.of(context).colorScheme.onPrimary,
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.onPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
              ])),
    );
  }

  Widget showHeader(String title, Color color) {
    return Expanded(
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodySmall!.apply(color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildEditFeild(TextEditingController editTextCtl) {
    return TextField(
      readOnly: false,
      style: Theme.of(context)
          .textTheme
          .bodySmall!
          .apply(color: Theme.of(context).colorScheme.onSurface),
      controller: editTextCtl,
      maxLines: 3,
      minLines: 1,
      onChanged: (value) {
        setState(() {});
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(32),
      ],
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
      ),
    );
  }

  void showSelScaleDialog(int funcNo, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return SelectScalesPageNew(
          funcNo: funcNo,
          sendMsgStr: msg,
        );
      },
    );
  }

  void fetchData() async {
    await getVariableList().then((dataList) {
      varList = dataList;
    }).catchError((error) {
      varList = [];
    });
  }

  void openVarListJson() async {
    final ByteData bytes =
        await rootBundle.load('assets/template/modify_var.json');
    // 将 ByteData 直接转换为 JSON 字符串
    final jsonString = bytes.buffer.asUint8List();
    final jsonData = utf8.decode(jsonString);

    Map<String, dynamic> jsonDataMap = json.decode(jsonData);

    var data = jsonDataMap['Print_var'] as List;
    varList = data.map((e) => MyvariableData.fromJson(e)).toList();
  }

  Future<List<MyvariableData>> getVariableList() async {
    File file = File('assets/template/modify_var.json');
    String jsonString = await file.readAsString(); // 异步读取文件内容

    Map<String, dynamic> jsonData = json.decode(jsonString);

    var data = jsonData['Print_var'] as List;
    List<MyvariableData> dataList =
        data.map((e) => MyvariableData.fromJson(e)).toList();

    return dataList;
  }

  int? getVarId(String varName) {
    var data = varList.firstWhere((data) => data.valuename == varName,
        orElse: () => MyvariableData(
            id: -1, valuename: '', comment: '', maxLen: 0) // 返回一个默认值
        );

    if (data.id != -1) {
      return data.id;
    } else {
      return null;
    }
  }

  void getJsonString() {
    myHeaderFooterList.listData.clear();
    // fetchData();
    if (varList == []) {
      return;
    }
    titleMap.forEach((key, value) {
      if (value.text != '') {
        var id = getVarId(key);
        if (id != null) {
          HeaderFooterData tmpHeader = HeaderFooterData(id, value.text);
          myHeaderFooterList.listData.add(tmpHeader);
        }
      }
    });
  }
}

class MyvariableData {
  final String valuename;
  final int id;
  final String comment;
  final int maxLen;

  MyvariableData(
      {required this.valuename,
      required this.id,
      required this.comment,
      required this.maxLen});

  factory MyvariableData.fromJson(Map<String, dynamic> json) {
    return MyvariableData(
      valuename: json['valuename'],
      id: json['id'],
      comment: json['comment'],
      maxLen: json['maxLen'],
    );
  }
}
