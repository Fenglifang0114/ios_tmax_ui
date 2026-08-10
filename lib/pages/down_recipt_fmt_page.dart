import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:t_max/pages/update_firmware_page.dart';
import '../data/manager_scale_channel.dart';
import 'package:t_max/functions/methods.dart';
import '../data/download_prt_fmt.dart';
import '../data/language.dart';
import '../data/scalecmd_data.dart';
import '../data/writelog.dart';
import '../widget/custom_button.dart';
import 'package:t_max/functions/adaptive.dart';
import 'package:t_max/pages/mobile_sel_scales_page.dart';

class DownReciptPage extends StatefulWidget {
  const DownReciptPage({super.key});

  @override
  State<DownReciptPage> createState() => _DownReciptPageState();
}

// late int connectionType;

class _DownReciptPageState extends State<DownReciptPage> {
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

  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    weightModeController.text = '';
    accModeController.text = '';
    pcsModeController.text = '';
    pctModeController.text = '';
  }

  String systemId = '';

  @override
  void dispose() {
    _fileScrollerController.dispose();

    _stopTimer();
    weightController.dispose();
    repsController.dispose();
    weightModeController.dispose();
    accModeController.dispose();
    pcsModeController.dispose();
    pctModeController.dispose();
    _downloadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Adaptive.isMobile(context)) {
      return _buildMobileContent(context);
    }
    final width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Container(
            width: width,
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // pageHeadInfo(
                  //     context,
                  //     width - headWidthPadding,
                  //     (localizedStrings?.menuReceiptFormatDownload ?? "menuReceiptFormatDownload"),
                  //     (localizedStrings?.gTipReceiptFmtDownPageHelp ?? "gTipReceiptFmtDownPageHelp")),
                  Expanded(
                      child: Container(
                    color: Theme.of(context).colorScheme.surfaceTint,
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceTint,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildMainContent(),
                        ],
                      ),
                    ),
                  )),
                ])));
  }

  Widget _buildMobileContent(BuildContext context) {
    bool hasData = weightModeController.text.isNotEmpty ||
        accModeController.text.isNotEmpty ||
        pcsModeController.text.isNotEmpty ||
        pctModeController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizedStrings?.menuReceiptFormatDownload ?? "Receipt Format Download",
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMobileFormatField((localizedStrings?.gReceiptFormat ?? "Receipt Format") + " 1", weightModeController),
                  const SizedBox(height: 16),
                  _buildMobileFormatField((localizedStrings?.gReceiptFormat ?? "Receipt Format") + " 2", accModeController),
                  const SizedBox(height: 16),
                  _buildMobileFormatField((localizedStrings?.gReceiptFormat ?? "Receipt Format") + " 3", pcsModeController),
                  // PctMode is usually for Total in receipt as well if there are 4, but screenshot shows 3. 
                  // I'll add 4 if it's used, but let's check screenshot: it has 3. 
                  // I'll just put all 4 like PC version just in case, or match screenshot perfectly.
                  // PC code has pctModeController as well but it's not in the screenshot. I will just render what's available.
                  // The PC code only displays 3 rows actually! 
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!isDownloadClicked && hasData) ? () {
                     _showConfirmationDialog(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    disabledBackgroundColor: Colors.grey[300],
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) return Colors.grey[300]!;
                        return Colors.grey[300]!; // as per screenshot, it's gray even when active or maybe light gray.
                      },
                    ),
                  ),
                  child: Text(
                    localizedStrings?.gBtnDownload ?? "Download",
                    style: TextStyle(color: hasData ? Colors.black87 : Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFormatField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.text = '';
                pickFiles(controller);
              },
              child: Container(
                width: 48,
                height: 48,
                color: const Color(0xFF0D558E),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Stack(children: [
      SizedBox(
        width: math.max(MediaQuery.of(context).size.width - 300, 950.0),
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
                          width: 200,
                          child: Text(
                            (localizedStrings?.gReceiptFormat ?? "gReceiptFormat") + " 1:",
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
                          text: (localizedStrings?.button_select_format ?? "button_select_format"),
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
                          width: 200,
                          child: Text(
                            (localizedStrings?.gReceiptFormat ?? "gReceiptFormat") + " 2:",
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          child: TextField(
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
                          text: (localizedStrings?.button_select_format ?? "button_select_format"),
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
                          width: 200,
                          child: Text(
                            (localizedStrings?.gReceiptFormat ?? "gReceiptFormat") + " 3:",
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          child: TextField(
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
                          text: (localizedStrings?.button_select_format ?? "button_select_format"),
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
        CustomOutlinedButton(
          btnWidth: 150,
          btnHeight: 50,
          icon: Icons.download_outlined,
          text: (localizedStrings?.gBtnDownload ?? "gBtnDownload"),
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
          backgroundColor:
              Theme.of(context).colorScheme.onTertiaryFixedVariant));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('fail$e',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  // void _startTimer(int time) {
  //   _downloadTimer = Timer(Duration(seconds: time), () {
  //     setState(() {
  //       isDownloadClicked = false;
  //     });
  //     _stopTimer();

  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text((localizedStrings?.gBtnDownload_result_fail ?? "gBtnDownload_result_fail"),
  //             style: const TextStyle(
  //                 fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
  //         duration: const Duration(seconds: 3),
  //         backgroundColor: Theme.of(context).colorScheme.error));
  //   });
  // }

  void _stopTimer() {
    _downloadTimer?.cancel(); // 停止计时器
  }

  void _showConfirmationDialog(BuildContext context) {
    if (Adaptive.isMobile(context)) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizedStrings?.gTitleConfirm ?? "Confirmation",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    'assets/images/person.png',
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    localizedStrings?.gConfirmPrnFmtOrderTip ?? "Please confirm the order of the printing formats.",
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CB079),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    child: Text(
                      localizedStrings?.gBtnConfirm ?? "Confirm",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ).then((confirmed) {
        if (confirmed == true) {
          String msg = getSendMsg(printFormatSequence);
          showSelScaleDialog(1, msg);
        }
      });
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            (localizedStrings?.gTitleConfirm ?? "gTitleConfirm"),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(localizedStrings?.gConfirmPrnFmtOrderTip ?? "gConfirmPrnFmtOrderTip"),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                ),
                const SizedBox(width: 20),
                CustomOutlinedButton(
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                ),
              ],
            )
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        String msg = getSendMsg(printFormatSequence);
        showSelScaleDialog(1, msg);
      }
    });
  }

  void showSelScaleDialog(int funcNo, String msg) {
    if (Adaptive.isMobile(context)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MobileSelectScalesPage(funcNo: funcNo, sendMsgStr: msg)));
    } else {
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
  }

  String getSendMsg(List<String> fmtSequence) {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    paths.clear();
    if (weightModeController.text.isNotEmpty) {
      paths.add('1${weightModeController.text}');
    }
    if (accModeController.text.isNotEmpty) {
      paths.add('2${accModeController.text}');
    }
    if (pcsModeController.text.isNotEmpty) {
      paths.add('3${pcsModeController.text}');
    }
    if (pctModeController.text.isNotEmpty) {
      paths.add('4${pctModeController.text}');
    }
    if (paths.isEmpty) {
      return "";
    }

    myDownLoadPrtFmt.scaleModel = 'TMax';
    myDownLoadPrtFmt.printerModel = 'Receipt';
    myDownLoadPrtFmt.filePaths = paths;
    myScaleCmd.cmdData = json.encode(myDownLoadPrtFmt);

    writelog(jsonEncode(myScaleCmd));
    return jsonEncode(myScaleCmd);
  }

  void sendFormatToScale(List<String> fmtSequence) async {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    paths.clear();

    if (weightModeController.text.isNotEmpty) {
      paths.add('1${weightModeController.text}');
    }
    if (accModeController.text.isNotEmpty) {
      paths.add('2${accModeController.text}');
    }
    if (pcsModeController.text.isNotEmpty) {
      paths.add('3${pcsModeController.text}');
    }
    if (pctModeController.text.isNotEmpty) {
      paths.add('4${pctModeController.text}');
    }
    if (paths.isNotEmpty) {
      myDownLoadPrtFmt.scaleModel = 'TMax';
      // myDownLoadPrtFmt.printerModel = 'EPM205';
      myDownLoadPrtFmt.printerModel = 'Receipt';
      myDownLoadPrtFmt.filePaths = paths;

      myScaleCmd.cmdData = json.encode(myDownLoadPrtFmt);
      PublicFunctions.sendMsg(
          myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    }
    writelog(jsonEncode(myScaleCmd));
  }

  Future pickFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: Platform.isAndroid ? FileType.any : FileType.custom,
      allowedExtensions: Platform.isAndroid ? null : ['fmt'],
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
