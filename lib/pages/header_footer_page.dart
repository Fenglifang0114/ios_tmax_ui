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
  const HeaderFooterPage({Key? key}) : super(key: key);

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
        child: pageHeadDesign(context,
            localizedStrings.variable_value_setting_title, [defaultScaleId]),
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
                    text: localizedStrings.download,
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
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceTint,
                    child: ListView(
                      children: [
                        const SizedBox(height: 40), // 顶部间距
                        _buildHeaderSection(), // 头部信息部分
                        const SizedBox(height: 20), // 间距
                        _buildFooterSection(), // 尾部信息部分
                        const SizedBox(height: 40), // 底部间距
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceTint,
                    child: ListView(
                      children: [
                        const SizedBox(height: 40), // 顶部间距
                        _buildOperatorSection(), // 头部信息部分
                        const SizedBox(height: 20), // 间距
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 操作员部信息部分
  Widget _buildOperatorSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Operator1:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildOperatorEditFeild(operator1Ctl),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Operator2:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildOperatorEditFeild(operator2Ctl),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Operator3:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildOperatorEditFeild(operator3Ctl),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Operator4:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildOperatorEditFeild(operator4Ctl),
            )
          ],
        ),
      ],
    );
  }

  // 头部信息部分
  Widget _buildHeaderSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Header1:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildEditFeild(header1Ctl),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Header2:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildEditFeild(header2Ctl),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Header3:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildEditFeild(header3Ctl),
            )
          ],
        ),
      ],
    );
  }

// 尾部信息部分
  Widget _buildFooterSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Footer1:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildEditFeild(footer1Ctl),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Footer2:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildEditFeild(footer2Ctl),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextTitle("Footer3:"),
            const SizedBox(width: 40),
            SizedBox(
              width: 300,
              child: _buildEditFeild(footer3Ctl),
            )
          ],
        ),
      ],
    );
  }

// 按钮部分
  Widget _buildButtonSection() {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
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
        child: Text(
          localizedStrings.download,
        ),
      ),
    );
  }

  Widget _buildTextTitle(String title) {
    return SizedBox(
      height: 40,
      width: 200,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorEditFeild(TextEditingController editTextCtl) {
    return TextField(
      readOnly: false,
      style: const TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
      controller: editTextCtl,
      maxLines: 1,
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
      maxLines: 1,
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
            localizedStrings.confirm_title,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(localizedStrings.header_confirm_info),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.button_ok,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(width: 20),
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.button_cancel,
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Data error !',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
              duration: const Duration(seconds: 3),
              backgroundColor: Theme.of(context).colorScheme.error));
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
