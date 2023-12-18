import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
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
  String filePath = '';
  List<DataRow> dataRows = [];
  String errorMessage = ''; //错误信息显示
  String? curruntPickFile = '';

  TextEditingController repsController = TextEditingController();
  TextEditingController pluFileController = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;
  dynamic _eventbus1;
  bool _isShowDownload = true;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    pluFileController.text = '';

    _eventbus1 = eventBus.on<EventRespDownPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myDownPluResp = event.obj;
          if (myDownPluResp.msgBody.isNotEmpty) {
            _isShowDownload = true;
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
                          child: const Text('Choose Product Excel'),
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
            onPressed: _isShowDownload
                ? () {
                    if (filePath.isNotEmpty) {
                      _showConfirmationDialog(context);
                    }
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
          title: const Text(
            'Confirmation',
            style: TextStyle(color: Color.fromARGB(255, 15, 71, 161)),
          ),
          content: const Text('Please confirm the PLU file.'),
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
        sendFormatToScale(filePath);
        setState(() {
          _isShowDownload = false;
        });
      }
    });
  }

  void sendFormatToScale(String fmtPath) {
    myScaleCmd.cmdMode = "down_plu_to_scale";
    if (fmtPath.isNotEmpty) {
      myDownLoadPluFile.scaleModel = 'TMax';
      myDownLoadPluFile.filePath = fmtPath;
      myScaleCmd.cmdData = json.encode(myDownLoadPluFile);
      MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    }
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
              const SizedBox(
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
