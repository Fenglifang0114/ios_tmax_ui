import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class DownSerialOutputPage extends StatefulWidget {
  const DownSerialOutputPage({super.key});

  @override
  State<DownSerialOutputPage> createState() => _DownReciptPageState();
}

class _DownReciptPageState extends State<DownSerialOutputPage> {
  bool isDownloadClicked = false;

  TextEditingController folderCtl = TextEditingController();
  List<String> jsonFilesList = [];

  dynamic _eventbus1;
  dynamic _eventbus2;
  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();

    folderCtl.text = '';

    cntScaleTimerMgr.stopCntScaleTimer();
    // cntScaleTimerMgr.startCntScaleTimer(5);
    _eventbus1 = eventBus.on<EventSerialOutputResp>().listen((event) {
      if (mounted) {
        setState(() {
          isDownloadClicked = false;
          // cntScaleTimerMgr.stopCntScaleTimer();
          // cntScaleTimerMgr.startCntScaleTimer(5);
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myRespDataFromScale.msgBody.contains('ok'))
                        ? 'Download successful!'
                        : myRespDataFromScale.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (myRespDataFromScale.msgBody.contains('ok'))
                    ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                    : Theme.of(context).colorScheme.error));
          }
        });
      }
    });
    _eventbus2 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        // setState(() {
        //   myFactoryInfoFromScale = event.obj;
        //   if (myFactoryInfoFromScale.modelName != '') {
        //     myComScaleInfo.isOnline = true;
        //   } else {
        //     myComScaleInfo.isOnline = false;
        //   }
        // });
      }
    });
  }

  String systemId = '';

  @override
  void dispose() {
    _eventbus1.cancel;
    _eventbus2.cancel;
    folderCtl.dispose();
    _stopTimer();
    _downloadTimer?.cancel();
    _eventbus1?.cancel();
    _eventbus2?.cancel();
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
            child: pageHeadDefScale(
              context,
              localizedStrings.gTitleSerialOutputDownload,
              '',
            ),
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
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          localizedStrings.output_res_folder,
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
                          controller: folderCtl,
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
                        icon: Icons.folder_open_outlined,
                        text: localizedStrings.output_select_folder,
                        onPressed: () async {
                          jsonFilesList.clear();
                          folderCtl.text = '';
                          pickFiles(folderCtl);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
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
        CustomOutlinedButton(
          btnWidth: 150,
          btnHeight: 50,
          icon: Icons.download_outlined,
          text: localizedStrings.gBtnDownload,
          onPressed: (!isDownloadClicked) && (folderCtl.text.isNotEmpty)
              ? () async {
                  await generateFileList(folderCtl.text);
                  if (jsonFilesList.isEmpty) {
                    if (mounted && context.mounted) {
                      _showConfirmationDialog(
                          context, localizedStrings.output_no_file);
                    }
                  } else {
                    if (mounted && context.mounted) {
                      _showConfirmationDialog(
                          context, localizedStrings.output_confirm_info);
                    }
                  }
                }
              : null,
        ),
      ],
    );
  }

  //导出文件到文件夹

  void _startTimer(int time) {
    _downloadTimer = Timer(Duration(seconds: time), () {
      setState(() {
        isDownloadClicked = false;
      });
      _stopTimer();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(localizedStrings.gTipDownloadFail,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error));
    });
  }

  void _stopTimer() {
    _downloadTimer?.cancel(); // 停止计时器
  }

  void _showConfirmationDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(msg),
          actions: <Widget>[
            Row(
              children: [
                (jsonFilesList.isNotEmpty)
                    ? CustomElevatedButton(
                        btnWidth: 100,
                        btnHeight: 40,
                        icon: Icons.check_circle,
                        text: localizedStrings.gBtnConfirm,
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )
                    : const SizedBox(
                        width: 30,
                      ),
                const SizedBox(width: 20),
                CustomOutlinedButton(
                  btnWidth: 100,
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
    ).then((confirmed) async {
      if (confirmed) {
        if (jsonFilesList.isNotEmpty) {
          PublicFunctions.sendOutputFmtToScale(
              jsonFilesList, myDefScaleInfo.defScaleId!);
          setState(() {
            isDownloadClicked = true;
            // cntScaleTimerMgr.stopCntScaleTimer();
          });
          _startTimer(30);
        }
      }
    });
  }

  Future<Directory> getJsonFileDir(String pathStr) async {
    var directory = Directory(pathStr);
    return directory;
  }

  Future generateFileList(String pathStr) async {
    final formatfilePath = await getJsonFileDir(pathStr);
    var directory = formatfilePath.path;
    List<String> filePaths = [
      '$directory\\OL.json',
      '$directory\\UL.json',
      '$directory\\Weight.json',
      '$directory\\Pcs.json',
      '$directory\\Price.json',
      '$directory\\Percent.json',
    ];
    for (int i = 1; i <= 6; i++) {
      String filePath = filePaths[i - 1];
      File file = File(filePath);
      if (await file.exists()) {
        jsonFilesList.add('$i$filePath');
      }
    }
  }

  Future pickFiles(TextEditingController showFilePath) async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        showFilePath.text = result;
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
