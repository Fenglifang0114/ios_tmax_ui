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
import '../widget/page_head.dart';

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

  TextEditingController repsController = TextEditingController();
  TextEditingController zipFileCtl = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;
  dynamic _eventbus1;
  dynamic _eventbus2;

  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    zipFileCtl.text = '';

    cntScaleTimerMgr.stopCntScaleTimer();
    cntScaleTimerMgr.startCntScaleTimer(5);

    _eventbus1 = eventBus.on<EventDownDefPrnFmtResp>().listen((event) {
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
                duration: const Duration(seconds: 5),
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
              flex: 2,
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
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          // height: 40,
                          child: TextField(
                            controller: zipFileCtl,
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
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: OutlinedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              zipFileCtl.text = '';
                              pickFiles(zipFileCtl);
                            },
                            child: Text(localizedStrings.button_select_format),
                          ),
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
            Expanded(
              flex: 1,
              child: _buildButtonRow(),
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
            onPressed: (!isDownloadClicked) && (zipFileCtl.text.isNotEmpty)
                ? () {
                    _showConfirmationDialog(context);
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
    myScaleCmd.cmdMode = "down_def_print_format";

    if (zipFileCtl.text.isNotEmpty) {
      myDefaultPrtFmt.scaleModel = 'TMax';
      myDefaultPrtFmt.printerModel = 'EPM205';
      myDefaultPrtFmt.filePath = zipFileCtl.text;

      myScaleCmd.cmdData = json.encode(myDefaultPrtFmt);
      MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
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
      body: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildMainContent(),
        ],
      ),
    );
  }
}
