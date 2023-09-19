import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../data/download_prt_fmt.dart';
import '../data/downloadresponse.dart';
import '../data/license_data.dart';
import '../data/scalecmd_data.dart';
import '../eventbus/eventbus.dart';
import '../generated/l10n.dart';
import '../main.dart';
import 'home_page.dart';

var aasd = "nihao";

var filePath = "";
var pathFlag = false;

class DownloadPage extends StatefulWidget {
  DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

// late int connectionType;

class _DownloadPageState extends State<DownloadPage> {
  List<String> items = [];
  List<String> paths = [];
  List<String> printFormatSequence = [];
  List<DataRow> dataRows = [];
  String errorMessage = ''; //错误信息显示
  bool hasDuplicates = false; //判断文件有没有重复序号

  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;
  dynamic _eventbus1;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
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

  Widget _buildBlueContainer() {
    return Container(
      width: 40,
      color: Colors.blue.shade900,
      child: const SizedBox(height: 50),
    );
  }

  Widget _buildMainContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Text(
              '''
Note: Please name the files in order, and the number in the first position of the name! 
                (the order is only related to the number) 
For example: 1Weight.fmt     2ACC.fmt      3PCS.fmt      4PCT.fmt
''',
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
                  if (dataRows.isNotEmpty)
                    DataTable(
                      columns: const [
                        DataColumn(
                          label: Text(
                            "File Order",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "File Path",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                      rows: dataRows,
                    ),
                  if (dataRows.isEmpty)
                    const Text(
                      "There is no file at the moment!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red.shade900),
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
              myCheckSerialPortOnOFF.isCheck = true;
              Navigator.of(context).pop();
            },
          ),
        ),
        // SizedBox(
        //   width: 120,
        //   height: 50,
        //   child: OutlinedButton(
        //     style: OutlinedButton.styleFrom(
        //       side: BorderSide(
        //         width: 1,
        //         color: Theme.of(context).colorScheme.primary,
        //       ),
        //       foregroundColor: Colors.blue,
        //       backgroundColor: Colors.white, // 设置按钮的背景色
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
        //       ),
        //     ),
        //     child: Center(
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //         children: [
        //           Icon(
        //             Icons.arrow_back,
        //             color: Theme.of(context).colorScheme.primary,
        //           ),
        //           Text(
        //             localizedStrings.button_back,
        //             style: TextStyle(
        //                 color: Theme.of(context).colorScheme.primary,
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.normal),
        //           ),
        //         ],
        //       ),
        //     ),
        //     onPressed: () {
        //       myCheckSerialPortOnOFF.isCheck = true;
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ),
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
            onPressed: () async {
              pickFiles();
            },
            child: Text(localizedStrings.button_select_format),
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

  Future pickFiles() async {
    String executablePath = Platform.resolvedExecutable;
    var directory = p.dirname(executablePath);

    final formatfilePath = Directory('$directory\\format');
    if (!await formatfilePath.exists()) {
      await formatfilePath.create(recursive: true);
    }
    directory = formatfilePath.path;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: directory,
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['fmt'],
    );

    if (kDebugMode) {
      print(result);
    }
    if (result != null) {
      paths = result.files.map((e) => e.path!).toList();
      setState(() {
        dataRows = [];
        printFormatSequence = [];
        errorMessage = '';
        if (paths.isEmpty || paths.length > 4) {
          errorMessage =
              'You can select a maximum of 4 files and a minimum of 1 file!';
        } else {
          for (var i = 0; i < paths.length; i++) {
            String tmpFilePath = paths[i].toString();
            String tmpFileName = tmpFilePath.split('\\').last;
            String fileOrder =
                tmpFileName.replaceAll(RegExp(r'\D'), '').substring(0, 1);

            printFormatSequence.add(fileOrder);
            dataRows.add(
              DataRow(
                cells: [
                  DataCell(
                    Text(
                      fileOrder,
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
          hasDuplicates = printFormatSequence.length !=
              HashSet<String>.from(printFormatSequence).length;
          if (hasDuplicates) {
            errorMessage =
                'Please note that the file order can not be repeated!';
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;

    // final _height = MediaQuery.of(context).size.height;
    if (!pathFlag) {
      currentPath = Directory.current.path;
      if (kDebugMode) {
        print(currentPath);
      }
      pathFlag = true;
    }

    return Scaffold(
      body: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildBlueContainer(),
          _buildMainContent(),
        ],
      ),
    );
  }
}
