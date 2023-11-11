import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../data/download_prt_fmt.dart';
import '../data/downloadresponse.dart';
import '../data/scalecmd_data.dart';
import '../eventbus/eventbus.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../widget/box_gradient.dart';

class ProductDownloadPage extends StatefulWidget {
  const ProductDownloadPage({super.key});

  @override
  State<ProductDownloadPage> createState() => _ProductDownloadPageState();
}

// late int connectionType;

class _ProductDownloadPageState extends State<ProductDownloadPage> {
  List<String> items = [];
  List<String> paths = [];
  List<String> printFormatSequence = [];
  List<DataRow> dataRows = [];
  String errorMessage = ''; //错误信息显示
  String? curruntPickFile = '';

  bool hasDuplicates = false; //判断文件有没有重复序号

  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController pluFileController = TextEditingController();
  TextEditingController accModeController = TextEditingController();
  TextEditingController pcsModeController = TextEditingController();
  TextEditingController pctModeController = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;
  dynamic _eventbus1;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    pluFileController.text = '';
    accModeController.text = '';
    pcsModeController.text = '';
    pctModeController.text = '';
    _eventbus1 = eventBus.on<EventDownloadResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myDownloadResponse = event.obj;
          if (myDownloadResponse.msgBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (myDownloadResponse.msgBody.contains('ok'))
                        ? 'Download successful!'
                        : myDownloadResponse.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (myDownloadResponse.msgBody.contains('ok'))
                    ? Colors.green.shade900
                    : Colors.red.shade900));
          }
        });
      }
    });
  }

  dynamic localizedStrings;
  String systemId = '';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void dispose() {
    _fileScrollerController.dispose();
    _eventbus1.cancel;
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
                        width: 150,
                        child: Text(
                          'Product File:',
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
                          controller: pluFileController,
                          readOnly: true,
                          maxLines: 2,
                          minLines: 1,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
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
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            pluFileController.text = '';
                            pickFiles(pluFileController);
                          },
                          // TODO:翻译
                          child: Text('选择Product Excel'),
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
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                width: 1,
                color: Theme.of(context).colorScheme.primary,
              ),
              foregroundColor: Colors.blue,
              backgroundColor: Colors.white, // 设置按钮的背景色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    localizedStrings.button_home,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        SizedBox(
          width: 120,
          height: 50,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
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
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            onPressed: () {
              if (!hasDuplicates && paths.isNotEmpty) {
                _showConfirmationDialog(context);
              }
            },
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
          title: const Text(
            'Confirmation',
            style: TextStyle(color: Color.fromARGB(255, 15, 71, 161)),
          ),
          content: const Text(
              '''Please confirm the order of the printing format.     
            '''),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // 不跳转
              },
            ),
            OutlinedButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true); // 跳转
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        sendFormatToScale(printFormatSequence, paths);
      }
    });
  }

  void sendFormatToScale(List<String> fmtSequence, List<String> fmtPaths) {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    if (fmtSequence.length == fmtPaths.length) {
      myDownLoadPrtFmt.scaleModel = 'TMax';
      myDownLoadPrtFmt.printerModel = 'EPM205';
      myDownLoadPrtFmt.filePaths = fmtPaths;

      myScaleCmd.cmdData = json.encode(myDownLoadPrtFmt);
      MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    }
  }

  Future pickFiles(TextEditingController showFilePath) async {
    String executablePath = Platform.resolvedExecutable;
    var directory = p.dirname(executablePath);

    final formatfilePath = Directory(directory);
    if (!await formatfilePath.exists()) {
      await formatfilePath.create(recursive: true);
    }
    directory = formatfilePath.path;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      showFilePath.text = result.files.single.path!;
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
    // final width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;
    // if (!pathFlag) {
    //   currentPath = Directory.current.path;
    //   if (kDebugMode) {
    //     print(currentPath);
    //   }
    //   pathFlag = true;
    // }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          decoration: BoxDecoration(gradient: boxGradient()),
          child: Row(
            children: [
              SizedBox(
                width: 50,
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  child: Text(
                    "Product Download",
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onPrimary),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
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
}
