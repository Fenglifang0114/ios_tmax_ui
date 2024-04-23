import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/downloadresponse.dart';
import '../data/header_footer.dart';
import '../data/scale_info_from_scale.dart';
import '../data/scalecmd_data.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../eventbus/eventbus.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../widget/page_head.dart';

class HeaderFooterPage extends StatefulWidget {
  const HeaderFooterPage({Key? key}) : super(key: key);

  @override
  State<HeaderFooterPage> createState() => HeaderFooterPageState();
}

class HeaderFooterPageState extends State<HeaderFooterPage> {
  TextEditingController header1Ctl = TextEditingController();
  TextEditingController header2Ctl = TextEditingController();
  TextEditingController header3Ctl = TextEditingController();
  TextEditingController footer1Ctl = TextEditingController();
  TextEditingController footer2Ctl = TextEditingController();
  TextEditingController footer3Ctl = TextEditingController();

  TextEditingController operator1Ctl = TextEditingController();
  TextEditingController operator2Ctl = TextEditingController();
  TextEditingController operator3Ctl = TextEditingController();
  TextEditingController operator4Ctl = TextEditingController();

  List<TextEditingController> listCtls = [];

  bool isDownloadClicked = false;

  dynamic _eventbus1;
  dynamic _eventbus2;

  dynamic localizedStrings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void initState() {
    header1Ctl.text = "";
    header2Ctl.text = "";
    header3Ctl.text = "";
    footer1Ctl.text = "";
    footer2Ctl.text = "";
    footer3Ctl.text = "";

    operator1Ctl.text = "";
    operator2Ctl.text = "";
    operator3Ctl.text = "";
    operator4Ctl.text = "";

    listCtls.add(header1Ctl);
    listCtls.add(header2Ctl);
    listCtls.add(header3Ctl);
    listCtls.add(footer1Ctl);
    listCtls.add(footer2Ctl);
    listCtls.add(footer3Ctl);

    listCtls.add(operator1Ctl);
    listCtls.add(operator2Ctl);
    listCtls.add(operator3Ctl);
    listCtls.add(operator4Ctl);
    cntScaleTimerMgr.startCntScaleTimer(1);
    _eventbus1 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        setState(() {
          myFactoryInfoFromScale = event.obj;
          if (myFactoryInfoFromScale.modelName != '') {
            myScreenMgr.serialPortST = true;
          } else {
            myScreenMgr.serialPortST = false;
          }
        });
      }
    });

    _eventbus2 = eventBus.on<EventModifyHeaderFooterResp>().listen((event) {
      if (mounted) {
        setState(() {
          isDownloadClicked = false;
          myRespModifyHeaderFooter = event.obj;

          if (myRespModifyHeaderFooter.msgBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myRespModifyHeaderFooter.msgBody.contains('ok'))
                        ? localizedStrings.download_result_ok
                        : myRespModifyHeaderFooter.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor:
                    (myRespModifyHeaderFooter.msgBody.contains('ok'))
                        ? Colors.green.shade900
                        : Colors.red.shade900));
          }

          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.startCntScaleTimer(2);
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _eventbus1.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localizedStrings = S.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: pageHead(context, localizedStrings.header_footer_setting_title,
            localizedStrings.serial_port_status),
      ),

      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.onPrimary,
                    child: Column(
                      children: [
                        Container(
                          height: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
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
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.onPrimary,
                    child: Column(
                      children: [
                        Container(
                          height: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              const SizedBox(height: 40), // 顶部间距
                              _buildOperatorSection(), // 头部信息部分
                              const SizedBox(height: 20), // 间距
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter, // 让子组件在顶部中心对齐
                  child: _buildButtonSection(), // 按钮部分
                ),
              ],
            ),
          ),
        ],
      ),
      // ),

      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     _buildButtonSection(), // 按钮部分
      //   ],
      // ),
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
              width: 400,
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
              width: 400,
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
              width: 400,
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
              width: 400,
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
              width: 400,
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
              width: 400,
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
              width: 400,
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
              width: 400,
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
              width: 400,
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
              width: 400,
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
            style: const TextStyle(color: Color.fromARGB(255, 15, 71, 161)),
          ),
          content: Text(localizedStrings.header_confirm_info),
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
        getJsonString();
        myScaleCmd.cmdMode = 'modify_header_footer';
        myScaleCmd.cmdData = json.encode(myHeaderFooterList);
        MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
        setState(() {
          isDownloadClicked = true;
          cntScaleTimerMgr.stopCntScaleTimer();
        });
      }
    });
  }

  void getJsonString() {
    myHeaderFooterList.listData.clear();
    for (int i = 0; i < 9; i++) {
      String headerText = listCtls[i].text;
      if (headerText.isNotEmpty && headerText != "") {
        HeaderFooterData tmpHeader = HeaderFooterData(i + 1, headerText);
        myHeaderFooterList.listData.add(tmpHeader);
      }
    }
  }
}
