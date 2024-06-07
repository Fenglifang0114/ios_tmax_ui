import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '../data/download_prt_fmt.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/scale_info_from_scale.dart';
import '../data/scalecmd_data.dart';
import '../data/screen_mgr.dart';
import '../data/timer_manager.dart';
import '../eventbus/eventbus.dart';
import '../main.dart';
import '../widget/page_head.dart';

class ProductDownloadPage extends StatefulWidget {
  const ProductDownloadPage({super.key});

  @override
  State<ProductDownloadPage> createState() => _ProductDownloadPageState();
}

class _ProductDownloadPageState extends State<ProductDownloadPage> {
  List<String> items = [];
  String filePath = '';
  String errorMessage = ''; //错误信息显示
  String? curruntPickFile = '';

  TextEditingController repsController = TextEditingController();
  TextEditingController pluAllCtl = TextEditingController();
  TextEditingController pluPartCtl = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;

  bool _isShowDownload = true;

  String _nameLen = '30';
  final List<String> nameMaxLen = ['30'];

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    pluAllCtl.text = '';
    cntScaleTimerMgr.stopCntScaleTimer();
    cntScaleTimerMgr.startCntScaleTimer(5);
    _eventbus1 = eventBus.on<EventRespDownPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myDownPluResp = event.obj;
          if (myDownPluResp.msgBody.isNotEmpty) {
            _isShowDownload = true;
            cntScaleTimerMgr.stopCntScaleTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myDownPluResp.msgBody.contains('ok'))
                        ? 'Download is successful!'
                        : myDownPluResp.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (myDownPluResp.msgBody.contains('ok'))
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.error));
          }
        });
      }
    });
    _eventbus2 = eventBus.on<EventRespInsertPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myDownPluResp = event.obj;
          if (myDownPluResp.msgBody.isNotEmpty) {
            _isShowDownload = true;
            cntScaleTimerMgr.stopCntScaleTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myDownPluResp.msgBody.contains('ok'))
                        ? 'Download is successful!'
                        : myDownPluResp.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (myDownPluResp.msgBody.contains('ok'))
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.error));
          }
        });
      }
    });
    _eventbus3 = eventBus.on<EventRespDelPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myDownPluResp = event.obj;
          if (myDownPluResp.msgBody.isNotEmpty) {
            _isShowDownload = true;
            cntScaleTimerMgr.stopCntScaleTimer();
            cntScaleTimerMgr.startCntScaleTimer(5);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myDownPluResp.msgBody.contains('ok'))
                        ? 'Delete is successful!'
                        : myDownPluResp.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (myDownPluResp.msgBody.contains('ok'))
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.error));
          }
        });
      }
    });

    _eventbus4 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
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
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    super.dispose();
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
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      const SizedBox(
                        width: 200,
                        child: Text(
                          'Product name max length:',
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 400,
                        // height: 40,
                        child: DropdownButton<String>(
                          alignment: AlignmentDirectional.centerStart,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          dropdownColor:
                              Theme.of(context).colorScheme.onPrimary,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                          hint: Text(
                            localizedStrings.printer,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                          ),
                          value: _nameLen,
                          items: nameMaxLen
                              .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _nameLen = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      const SizedBox(
                        width: 300,
                        height: 40,
                        child: Text(''),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      const SizedBox(
                        width: 200,
                        child: Text(
                          'All Products:',
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
                          controller: pluAllCtl,
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
                            pluAllCtl.text = '';
                            pickFiles(pluAllCtl);
                          },
                          child: const Text('Choose Product Excel'),
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
                            setState(() {
                              pluAllCtl.text = '';
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      const SizedBox(
                        width: 200,
                        child: Text(
                          'Partial Products:',
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
                          controller: pluPartCtl,
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
                            pluPartCtl.text = '';
                            pickFiles(pluPartCtl);
                          },
                          child: const Text('Choose Product Excel'),
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
                            setState(() {
                              pluPartCtl.text = '';
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  !_isShowDownload
                      ? Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
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
            onPressed: () {
              downloadTemplate();
            },
            child: const Text(
              "Get Product Template",
            ),
          ),
        ),
        SizedBox(
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
            onPressed: _isShowDownload
                ? () {
                    _showConfirmationDialog(context);
                  }
                : null,
            child: const Text(
              "Download",
            ),
          ),
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
            'Confirmation',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: isOneModeDown()
              ? const Text('Please confirm the PLU file.')
              : const Text('Only one PLU file can be selected'),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // 不跳转
              },
            ),
            isOneModeDown()
                ? OutlinedButton(
                    child: const Text('Confirm'),
                    onPressed: () {
                      Navigator.of(context).pop(true); // 跳转
                    },
                  )
                : const SizedBox(),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        sendFormatToScale();
        setState(() {
          _isShowDownload = false;
          cntScaleTimerMgr.stopCntScaleTimer();
        });
      }
    });
  }

  bool isOneModeDown() {
    bool res = false;
    if (pluAllCtl.text.isNotEmpty && pluPartCtl.text.isEmpty) {
      res = true;
    } else if (pluAllCtl.text.isEmpty && pluPartCtl.text.isNotEmpty) {
      res = true;
    }

    return res;
  }

  Future<void> sendFormatToScale() async {
    if (pluAllCtl.text.isNotEmpty) {
      myScaleCmd.cmdMode = "down_plu_to_scale";
      sendFileToScale(pluAllCtl.text);
    } else if (pluPartCtl.text.isNotEmpty) {
      myScaleCmd.cmdMode = "insert_plu_to_scale";

      sendFileToScale(pluPartCtl.text);
    }
  }

  void sendFileToScale(String fmtPath) {
    myDownLoadPluFile.scaleModel = 'TMax';
    myDownLoadPluFile.filePath = fmtPath;
    myDownLoadPluFile.nameMaxLen = (_nameLen == '30') ? 30 : 60;
    myScaleCmd.cmdData = json.encode(myDownLoadPluFile);
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  void delPluListFromScale(List<String> pluList) {
    myScaleCmd.cmdMode = "del_plu_from_scale";
    myDelPlu.scaleModel = 'TMax';
    myDelPlu.pluId = pluList;
    myScaleCmd.cmdData = json.encode(myDelPlu);
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
  }

  Future pickFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
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

  Future<void> downloadTemplate() async {
    var directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      dialogTitle: 'Output file:',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      fileName: 'product_template.xlsx',
    ));
    if (outputFile != null) {
      File output = File(outputFile); // 将文件路径转换为File对象

      // 读取预置的模板文件
      final ByteData bytes =
          await rootBundle.load('assets/template/product_template.xlsx');
      final buffer = bytes.buffer;

      // 将模板文件保存到指定路径
      await output.writeAsBytes(
          buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: pageHead(context, localizedStrings.plu_download_title,
              localizedStrings.serial_port_status),
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
