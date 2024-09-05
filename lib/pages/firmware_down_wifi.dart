import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:t_max/pages/sel_scales_page.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class FirmwareDownPage extends StatefulWidget {
  const FirmwareDownPage({super.key});

  @override
  State<FirmwareDownPage> createState() => _FirmwareDownPageState();
}

class _FirmwareDownPageState extends State<FirmwareDownPage> {
  List<String> items = [];
  String filePath = '';
  String errorMessage = ''; //错误信息显示
  String? curruntPickFile = '';

  TextEditingController repsController = TextEditingController();
  TextEditingController zipFileCtl = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    zipFileCtl.text = '';
  }

  String systemId = '';

  @override
  void dispose() {
    _fileScrollerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: pageHeadDesign(
              context, localizedStrings.firm_down_online, [defaultScaleId]),
        ),
        body: Container(
          color: Theme.of(context).colorScheme.surfaceTint,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildMainContent(),
            ],
          ),
        ));
  }

  Widget _buildMainContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Text(
              '',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          _buildButtonRow(),
          Expanded(
            child: SingleChildScrollView(
              controller: _fileScrollerController,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          localizedStrings.firm_zip_file,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 400,
                        // height: 40,
                        child: TextField(
                          enabled: false,
                          controller: zipFileCtl,
                          readOnly: true,
                          maxLines: 8,
                          minLines: 1,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      CustomOutlinedButton(
                        btnWidth: 150,
                        btnHeight: 40,
                        icon: Icons.file_open_outlined,
                        text: localizedStrings.firm_zip_file_sel,
                        onPressed: () async {
                          zipFileCtl.text = '';
                          pickFiles(zipFileCtl);
                        },
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomElevatedButton(
          btnWidth: 150,
          btnHeight: 50,
          icon: Icons.download_rounded,
          text: localizedStrings.download,
          onPressed: zipFileCtl.text.isNotEmpty
              ? () {
                  _showConfirmationDialog(context);
                }
              : null,
        ),
      ],
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
          content: Text(localizedStrings.firm_cfm_msg),
          actions: <Widget>[
            Row(
              children: [
                zipFileCtl.text.isNotEmpty
                    ? CustomElevatedButton(
                        btnWidth: 120,
                        btnHeight: 40,
                        icon: Icons.check_circle,
                        text: localizedStrings.confirm_btn,
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 10,
                ),
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
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        String msg = getSendMsg();
        showSelScaleDialog(sendOnline, msg);
      }
    });
  }

  String getSendMsg() {
    return zipFileCtl.text;
  }

  Future pickFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result != null) {
      setState(() {
        showFilePath.text = result.files.single.path!;
        filePath = showFilePath.text;
      });
    } else {
      setState(() {
        showFilePath.text = '';
        filePath = '';
      });
    }
  }
}
