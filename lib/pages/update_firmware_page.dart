import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:t_max/pages/sel_scales_page.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class UpdateFirmwarePage extends StatefulWidget {
  const UpdateFirmwarePage({super.key});

  @override
  State<UpdateFirmwarePage> createState() => _UpdateFirmwarePageState();
}

class _UpdateFirmwarePageState extends State<UpdateFirmwarePage> {
  TextEditingController zipFileCtl = TextEditingController();
  late ScrollController _fileScrollerController;

  bool showNetworkPage = true;
  bool isSetting = false;

  String _errMsgSerial = '';
  String filePath = '';

  dynamic _eventbus1;
  dynamic _eventbus2;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    zipFileCtl.text = '';

    _eventbus1 = eventBus.on<EventRespUpdateFirmware>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        setState(() {
          _errMsgSerial = myRespDataFromScale.msgBody;
          isSetting = false;
          if (myRespDataFromScale.msgBody.contains("connection")) {
            showForceDialog(context, localizedStrings.gTipDeviceLost);
          } else if (myRespDataFromScale.msgBody.contains("match")) {
            showForceDialog(context, localizedStrings.gTipModelNotMatch);
          }
        });
      }
    });
    _eventbus2 = eventBus.on<EventRespUpdateFirmwareProcess>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok') ||
            myRespDataFromScale.msgBody.contains('fail')) {
          isSetting = false;
          setState(() {
            _errMsgSerial = myRespDataFromScale.msgBody;
          });
        } else {
          if (int.tryParse(myRespDataFromScale.msgBody) != null) {
            // 字符串全是数字
            int numericValue = int.parse(myRespDataFromScale.msgBody);
            if (numericValue < 100 && numericValue * 1.5 < 100.0) {
              numericValue = (numericValue * 1.5).toInt();
            }
            updateProgress(numericValue);
          } else {
            setState(() {
              _errMsgSerial = myRespDataFromScale.msgBody;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _fileScrollerController.dispose();
    zipFileCtl.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: pageHeadDesign(
              context,
              localizedStrings.gTitleUpdateFirmware,
              [myDefScaleInfo.defScaleId!],
              localizedStrings.gTipUpdateFirmwarePageHelp),
        ),
        body: Container(
          color: Theme.of(context).colorScheme.surfaceTint,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              mainContent(),
            ],
          ),
        ));
  }

  Widget mainContent() {
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
          _buildBtnDownload(),
          SizedBox(
            height: 50,
          ),
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
                          localizedStrings.gTipFirmwareZipFile,
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
                        text: localizedStrings.gBtnSelectZipFirmware,
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
                    height: 100,
                  ),
                  Text(
                    (_errMsgSerial.contains('ok') ||
                            _errMsgSerial.contains('OK'))
                        ? 'OK'
                        : _errMsgSerial,
                    style: TextStyle(
                        fontSize: 16,
                        color: (_errMsgSerial.contains('ok') ||
                                _errMsgSerial.contains('OK') ||
                                _errMsgSerial.contains('started'))
                            ? Theme.of(context)
                                .colorScheme
                                .onTertiaryFixedVariant
                            : Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 10,
                    width: 400,
                    child: (isSetting)
                        ? LinearProgressIndicator(
                            value: _progress > 0 ? _progress : null,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondaryFixed,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary),
                          )
                        : const Text(''),
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

  void useSerialPortUpdate(String force) {
    PublicFunctions.sendFormatToScale("${zipFileCtl.text},$force");
    setState(() {
      _errMsgSerial = localizedStrings.gTipWait;
      isSetting = true;
    });
    Timer(const Duration(seconds: 10), () {
      if (!(_progress > 0) && isSetting) {
        setState(() {
          _errMsgSerial = localizedStrings.gTipRebootForUpdate;
        });
      }
    });
  }

  void useNetworkUpdate() {
    String msg = zipFileCtl.text;
    showSelScaleDialog(sendOnline, msg);
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

  void _showCfmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(localizedStrings.gTipSelectUpdateWay),
          actions: <Widget>[
            Row(
              children: [
                zipFileCtl.text.isNotEmpty
                    ? CustomElevatedButton(
                        btnWidth: 120,
                        btnHeight: 40,
                        icon: Icons.cable,
                        text: localizedStrings.gBtnViaSerialUpdate,
                        onPressed: () {
                          useSerialPortUpdate("0");
                          Navigator.of(context).pop();
                        },
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 10,
                ),
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.wifi,
                  text: localizedStrings.gBtnViaNetworkUpdate,
                  onPressed: () {
                    Navigator.of(context).pop();
                    useNetworkUpdate();
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.gBtnCancel,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showForceDialog(BuildContext context, String tipStr) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SizedBox(
            width: 300,
            height: 70,
            child: Text(
              tipStr,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                CustomElevatedButton(
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.gBtnConfirm,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
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
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        useSerialPortUpdate("1");
      }
    });
  }

  Widget _buildBtnDownload() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomElevatedButton(
          btnWidth: 150,
          btnHeight: 50,
          icon: Icons.arrow_circle_right_outlined,
          text: localizedStrings.gBtnDownload,
          onPressed: (isSetting || zipFileCtl.text.isEmpty)
              ? null
              : () {
                  setState(() {
                    _progress = 0.0;
                    _errMsgSerial = "";
                  });

                  _showCfmDialog(context);
                },
        ),
      ],
    );
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

  void updateProgress(int value) {
    setState(() {
      _progress = value.toDouble() / 100;
    });
  }
}
