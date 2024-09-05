import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/sel_scales_page.dart';
import 'package:t_max/widget/custom_button.dart';
import '../data/manager_scale_channel.dart';
import '../data/download_prt_fmt.dart';
import '../data/language.dart';
import '../data/scalecmd_data.dart';
import '../data/timer_manager.dart';
import '../data/writelog.dart';
import '../widget/page_head.dart';

const int maxDefFmtLen = 21000;

class DefaultPrnFmtPage extends StatefulWidget {
  const DefaultPrnFmtPage({super.key});

  @override
  State<DefaultPrnFmtPage> createState() => _DefaultPrnFmtPageState();
}

// late int connectionType;

class _DefaultPrnFmtPageState extends State<DefaultPrnFmtPage> {
  List<String> items = [];
  List<String> printFormatSequence = [];
  String errorMessage = ''; //错误信息显示
  String? curruntPickFile = '';
  bool isDownloadClicked = false;
  bool hasDuplicates = false; //判断文件有没有重复序号
  List<DataRow> dataRows = [];

  TextEditingController repsController = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;

  FilePickerResult? result;
  List<String> paths = [];
  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();

    cntScaleTimerMgr.stopCntScaleTimer();
    cntScaleTimerMgr.startCntScaleTimer(5);
  }

  String systemId = '';

  @override
  void dispose() {
    _fileScrollerController.dispose();

    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          child: pageHeadDesign(
            context,
            localizedStrings.label_fmt_download,
            [defaultScaleId],
          ),
        ),
      ),
      body: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(children: [
      SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            _buildDownloading(),
            Expanded(
              flex: 1,
              child: _buildButtonRow(),
            ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                controller: _fileScrollerController,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (dataRows.isNotEmpty)
                      DataTable(
                        columns: [
                          DataColumn(
                            label: SizedBox(
                              width: 300,
                              child: Text(
                                localizedStrings.def_fmt_no_title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 500,
                              child: Text(
                                localizedStrings.def_fmt_file_title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: dataRows,
                      ),
                    if (dataRows.isEmpty)
                      Text(
                        localizedStrings.def_fmt_no_file_tip,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.background),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildDownloading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        isDownloadClicked
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomElevatedButton(
          btnWidth: 200,
          btnHeight: 50,
          icon: Icons.file_open_outlined,
          text: localizedStrings.button_select_format,
          onPressed: () async {
            result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.custom,
              allowedExtensions: ['fmt'],
            );

            if (result != null) {
              paths = result!.files.map((e) => e.path!).toList();
              setState(() {
                dataRows = [];
                for (var i = 0; i < paths.length; i++) {
                  dataRows.add(
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            "Default ${i + 1}",
                          ),
                        ),
                        DataCell(
                          Text(
                            paths[i].toString(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              });
              if (result!.count > 10) {
                _showErrorDialog(context, localizedStrings.def_fmt_sel_tip);
              }
              int totalLen = 0;
              for (int i = 0; i < result!.count; i++) {
                totalLen += result!.files[i].size;
              }
              if (totalLen > maxDefFmtLen) {
                _showErrorDialog(
                    context, localizedStrings.def_fmt_out_range_tip);
                setState(() {
                  dataRows.clear();
                });
              }
            }
          },
        ),
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            onPressed: (!isDownloadClicked) && (dataRows.isNotEmpty)
                ? () {
                    if (dataRows.length > 10) {
                      _showErrorDialog(
                          context, localizedStrings.def_fmt_sel_tip);
                    } else {
                      _showConfirmationDialog(context);
                    }
                  }
                : null,
            child: Text(
              localizedStrings.download,
            ),
          ),
        ),
      ],
    );
  }

  void _startTimer(int time) {
    _downloadTimer = Timer(Duration(seconds: time), () {
      setState(() {
        isDownloadClicked = false;
      });
      _stopTimer();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(localizedStrings.download_result_fail,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error));
    });
  }

  void _stopTimer() {
    _downloadTimer?.cancel(); // 停止计时器
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.confirm_title,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(error),
          actions: <Widget>[
            Row(
              children: [
                CustomElevatedButton(
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.confirm_btn,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            )
          ],
        );
      },
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
          content: Text(localizedStrings.confirm_info),
          actions: <Widget>[
            Row(
              children: [
                CustomElevatedButton(
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.confirm_btn,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(width: 20),
                CustomOutlinedButton(
                  btnWidth: 100,
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
        printFormatSequence = paths;
        // sendFormatToScale(printFormatSequence);
        String msgStr = getSendFormatToScaleMsg(printFormatSequence);
        showSelScaleDialog(1, msgStr);
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

  String getSendFormatToScaleMsg(List<String> fmtSequence) {
    myScaleCmd.cmdMode = "down_def_print_format";
    if (fmtSequence.isEmpty) {
      return "";
    }

    myDefaultPrtFmt.scaleModel = 'TMax';
    myDefaultPrtFmt.printerModel = 'EPM205';
    myDefaultPrtFmt.filePathList = fmtSequence;
    myScaleCmd.cmdData = json.encode(myDefaultPrtFmt);

    writelog(jsonEncode(myScaleCmd));
    return jsonEncode(myScaleCmd);
  }

  void sendFormatToScale(List<String> fmtSequence) async {
    myScaleCmd.cmdMode = "down_def_print_format";

    if (fmtSequence.isNotEmpty) {
      myDefaultPrtFmt.scaleModel = 'TMax';
      myDefaultPrtFmt.printerModel = 'EPM205';
      myDefaultPrtFmt.filePathList = fmtSequence;

      myScaleCmd.cmdData = json.encode(myDefaultPrtFmt);
      PublicFunctions.sendMsg(defaultScaleId, jsonEncode(myScaleCmd));
    }

    writelog(jsonEncode(myScaleCmd));
  }

  Future pickFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result != null) {
      setState(() {
        showFilePath.text = result.files.single.path!;
      });
    } else {
      setState(() {
        showFilePath.text = '';
      });
    }
  }

  Future<String?> pickFolder() async {
    final folderPath = await FilePicker.platform.getDirectoryPath();
    return folderPath;
  }
}
