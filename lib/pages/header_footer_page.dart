import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/pages/sel_scales_page.dart';
import '../data/header_footer.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../data/scalecmd_data.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class HeaderFooterPage extends StatefulWidget {
  const HeaderFooterPage({super.key});

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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: pageHeadDesign(context, localizedStrings.rTitleSetVariableValues,
            [myDefScaleInfo.defScaleId!]),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceTint,
            height: 40,
          ),
          Container(
            color: Theme.of(context).colorScheme.surfaceTint,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter, // 让子组件在顶部中心对齐
                  child: // 按钮部分
                      CustomElevatedButton(
                    btnWidth: 150,
                    btnHeight: 50,
                    icon: Icons.download_rounded,
                    text: localizedStrings.gBtnDownload,
                    onPressed: (!isDownloadClicked) &&
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
                            _showConfirmationDialog(context);
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderExpanded(),
                _buildFooterExpanded(),
                _buildOperatorExpanded(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderExpanded() {
    return Expanded(
      flex: 3,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceTint,
            child: ListView(
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildTextTotalTitle(localizedStrings.rTipHeader)],
                ),
                const SizedBox(height: 20),
                _buildHeaderSection(constraints.maxWidth),
                const SizedBox(height: 20),
                // 尾部信息部分
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooterExpanded() {
    return Expanded(
      flex: 3,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceTint,
            child: ListView(
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildTextTotalTitle(localizedStrings.rTipFooter)],
                ),
                const SizedBox(height: 20),
                _buildFooterSection(constraints.maxWidth),
                const SizedBox(height: 20),
                // 尾部信息部分
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOperatorExpanded() {
    return Expanded(
      flex: 3,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceTint,
            child: ListView(
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextTotalTitle(localizedStrings.rTipOperator)
                  ],
                ),
                const SizedBox(height: 20),
                _buildOperatorSection(constraints.maxWidth),
                const SizedBox(height: 20),
                // 尾部信息部分
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(double width) {
    return SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildTextTitle(localizedStrings.rTipHeader + ' 1:', width / 4),
                Expanded(
                  child: _buildEditFeild(header1Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Row(
              children: [
                _buildTextTitle(localizedStrings.rTipHeader + ' 2:', width / 4),
                Expanded(
                  child: _buildEditFeild(header2Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Row(
              children: [
                _buildTextTitle(localizedStrings.rTipHeader + ' 3:', width / 4),
                Expanded(
                  child: _buildEditFeild(header3Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
          ],
        ));
  }

  Widget _buildFooterSection(double width) {
    return SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildTextTitle(localizedStrings.rTipFooter + ' 1:', width / 4),
                Expanded(
                  child: _buildEditFeild(footer1Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Row(
              children: [
                _buildTextTitle(localizedStrings.rTipFooter + ' 2:', width / 4),
                Expanded(
                  child: _buildEditFeild(footer2Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Row(
              children: [
                _buildTextTitle(localizedStrings.rTipFooter + ' 3:', width / 4),
                Expanded(
                  child: _buildEditFeild(footer3Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
          ],
        ));
  }

  Widget _buildOperatorSection(double width) {
    return SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildTextTitle(
                    localizedStrings.rTipOperator + ' 1:', width / 4),
                Expanded(
                  child: _buildOperatorEditFeild(operator1Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Row(
              children: [
                _buildTextTitle(
                    localizedStrings.rTipOperator + ' 2:', width / 4),
                Expanded(
                  child: _buildOperatorEditFeild(operator2Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Row(
              children: [
                _buildTextTitle(
                    localizedStrings.rTipOperator + ' 3: ', width / 4),
                Expanded(
                  child: _buildOperatorEditFeild(operator3Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Row(
              children: [
                _buildTextTitle(
                    localizedStrings.rTipOperator + ' 4: ', width / 4),
                Expanded(
                  child: _buildOperatorEditFeild(operator4Ctl),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
          ],
        ));
  }

  Widget _buildTextTotalTitle(String title) {
    return SizedBox(
      height: 40,
      width: 300,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.right,
          style: TextStyle(
              fontSize: 20, color: Theme.of(context).colorScheme.primary),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTextTitle(String title, double width) {
    return SizedBox(
      width: width,
      child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(),
            ),
          )),
    );
  }

  Widget _buildOperatorEditFeild(TextEditingController editTextCtl) {
    return TextField(
      readOnly: false,
      style: const TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
      controller: editTextCtl,
      maxLines: 3,
      minLines: 1,
      onChanged: (value) {
        setState(() {});
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(20),
      ],
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildEditFeild(TextEditingController editTextCtl) {
    return TextField(
      readOnly: false,
      style: const TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
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
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(localizedStrings.gTipConfirmInfo),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.gBtnConfirm,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(width: 20),
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.gBtnCancel,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            )
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        getJsonString();
        if (myHeaderFooterList.listData.isEmpty) {
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(localizedStrings.gTipDataError,
                    style:
                        TextStyle(fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: Theme.of(context).colorScheme.error));
          }

          return;
        }
        myScaleCmd.cmdMode = 'modify_var_value';
        myScaleCmd.cmdData = json.encode(myHeaderFooterList);
        showSelScaleDialog(1, jsonEncode(myScaleCmd));
      }
    });
  }

  void showSelScaleDialog(int funcNo, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return SelectScalesPage(
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
