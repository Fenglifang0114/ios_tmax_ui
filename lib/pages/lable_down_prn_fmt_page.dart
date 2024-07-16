import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../data/download_prt_fmt.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/scale_info_from_scale.dart';
import '../data/scalecmd_data.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../data/writelog.dart';
import '../eventbus/eventbus.dart';
import '../main.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';
import 'default_prn_fmt_page.dart';

class DownloadLabelPage extends StatefulWidget {
  const DownloadLabelPage({super.key});

  @override
  State<DownloadLabelPage> createState() => _DownloadPageState();
}

// late int connectionType;

class _DownloadPageState extends State<DownloadLabelPage> {
  List<String> items = [];
  List<String> paths = [];
  List<String> printFormatSequence = [];
  String errorMessage = ''; //错误信息显示
  String? curruntPickFile = '';
  bool isDownloadClicked = false;
  bool hasDuplicates = false; //判断文件有没有重复序号

  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightModeController = TextEditingController();
  TextEditingController accModeController = TextEditingController();
  TextEditingController pcsModeController = TextEditingController();
  TextEditingController pctModeController = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;
  dynamic _eventbus1;
  dynamic _eventbus2;
  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    weightModeController.text = '';
    accModeController.text = '';
    pcsModeController.text = '';
    pctModeController.text = '';
    cntScaleTimerMgr.stopCntScaleTimer();
    cntScaleTimerMgr.startCntScaleTimer(5);
    _eventbus1 = eventBus.on<EventDownPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myDownPrnFmtResp = event.obj;
          isDownloadClicked = false;
          _stopTimer();
          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.startCntScaleTimer(5);
          if (myDownPrnFmtResp.msgBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myDownPrnFmtResp.msgBody.contains('ok'))
                        ? localizedStrings.download_result_ok
                        : myDownPrnFmtResp.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (myDownPrnFmtResp.msgBody.contains('ok'))
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.error));
          }
        });
      }
    });
    _eventbus2 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
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
  }

  String systemId = '';

  @override
  void dispose() {
    _fileScrollerController.dispose();
    _eventbus1.cancel;
    _eventbus2.cancel;
    _stopTimer();
    super.dispose();
  }

  Widget _buildMainContent() {
    return Stack(children: [
      SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            _buildDownloading(),
            Expanded(
              flex: 1,
              child: _buildButtonRow(),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                controller: _fileScrollerController,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 设置主轴对齐方式为居中
                      children: [
                        SizedBox(
                          width: 300,
                          child: Text(
                            localizedStrings.free_fmt1_txt,
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
                            controller: weightModeController,
                            readOnly: true,
                            maxLines: 2,
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
                          text: localizedStrings.button_select_format,
                          onPressed: () async {
                            weightModeController.text = '';
                            pickFiles(weightModeController);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 设置主轴对齐方式为居中
                      children: [
                        SizedBox(
                          width: 300,
                          child: Text(
                            localizedStrings.free_fmt2_txt,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          child: TextField(
                            enabled: false,
                            controller: accModeController,
                            readOnly: true,
                            maxLines: 2,
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
                          text: localizedStrings.button_select_format,
                          onPressed: () async {
                            accModeController.text = '';
                            pickFiles(accModeController);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 设置主轴对齐方式为居中
                      children: [
                        SizedBox(
                          width: 300,
                          child: Text(
                            localizedStrings.free_fmt3_txt,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          child: TextField(
                            enabled: false,
                            controller: pcsModeController,
                            readOnly: true,
                            maxLines: 2,
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
                          text: localizedStrings.button_select_format,
                          onPressed: () async {
                            pcsModeController.text = '';
                            pickFiles(pcsModeController);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 设置主轴对齐方式为居中
                      children: [
                        SizedBox(
                          width: 300,
                          child: Text(
                            localizedStrings.total_fmt_txt,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          child: TextField(
                            enabled: false,
                            controller: pctModeController,
                            readOnly: true,
                            maxLines: 2,
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
                          text: localizedStrings.button_select_format,
                          onPressed: () async {
                            pctModeController.text = '';
                            pickFiles(pctModeController);
                          },
                        ),
                      ],
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
          icon: Icons.download_outlined,
          text: localizedStrings.download,
          onPressed: (!isDownloadClicked) &&
                  (weightModeController.text.isNotEmpty ||
                      accModeController.text.isNotEmpty ||
                      pcsModeController.text.isNotEmpty ||
                      pctModeController.text.isNotEmpty)
              ? () {
                  _showConfirmationDialog(context);
                }
              : null,
        ),
        CustomElevatedButton(
          btnWidth: 200,
          btnHeight: 50,
          icon: Icons.logout,
          text: localizedStrings.download_default,
          onPressed: (!isDownloadClicked)
              ? () {
                  _jumpCfmDialog(context);
                }
              : null,
        ),
      ],
    );
  }

  //导出文件到文件夹

  void copyFileToFolder(String sourceFilePath, String destinationFolderPath) {
    File sourceFile = File(sourceFilePath);
    Directory destinationFolder = Directory(destinationFolderPath);

    if (!destinationFolder.existsSync()) {
      destinationFolder.createSync(recursive: true);
    }
    File destinationFile = File(
        '$destinationFolderPath\\${sourceFile.path.split('\\').last}'); // 目标文件路径

    try {
      sourceFile.copySync(destinationFile.path);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(('Save ${destinationFile.path} successful.'),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.outline));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('fail' + e.toString(),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error));
    }
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

  void _jumpCfmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.confirm_title,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(localizedStrings.jump_confirm_info),
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
        cntScaleTimerMgr.stopCntScaleTimer();
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const DefaultPrnFmtPage();
        }));
      }
    });
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
        sendFormatToScale(printFormatSequence);
        setState(() {
          isDownloadClicked = true;
          cntScaleTimerMgr.stopCntScaleTimer();
        });
        _startTimer(30);
      }
    });
  }

  void sendFormatToScale(List<String> fmtSequence) async {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    paths.clear();

    if (weightModeController.text.isNotEmpty) {
      paths.add('1' + weightModeController.text);
    }
    if (accModeController.text.isNotEmpty) {
      paths.add('2' + accModeController.text);
    }
    if (pcsModeController.text.isNotEmpty) {
      paths.add('3' + pcsModeController.text);
    }
    if (pctModeController.text.isNotEmpty) {
      paths.add('4' + pctModeController.text);
    }
    if (paths.isNotEmpty) {
      myDownLoadPrtFmt.scaleModel = 'TMax';
      myDownLoadPrtFmt.printerModel = 'Label';
      // myDownLoadPrtFmt.printerModel = 'ESP/POS';
      myDownLoadPrtFmt.filePaths = paths;

      myScaleCmd.cmdData = json.encode(myDownLoadPrtFmt);
      MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    }
    writelog(jsonEncode(myScaleCmd));
  }

  Future pickFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['fmt'],
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

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            child: pageHead(context, localizedStrings.label_fmt_download,
                localizedStrings.serial_port_status),
          ),
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
}
