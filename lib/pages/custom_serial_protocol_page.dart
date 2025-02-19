import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/timer_manager.dart';
import 'package:t_max/functions/methods.dart';
import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import '../data/custom_serial_protocol_text_dart.dart';
import '../data/language.dart';
import '../data/reqweightdata_data.dart';

import '../eventbus/eventbus.dart';
import 'package:path/path.dart' as p;
import '../widget/custom_button.dart';
import '../widget/page_head.dart';
import 'package:archive/archive_io.dart';

class CustomSerialProtocol extends StatefulWidget {
  const CustomSerialProtocol({super.key});

  @override
  State<CustomSerialProtocol> createState() => _CustomSerialProtocolState();
}

class _CustomSerialProtocolState extends State<CustomSerialProtocol> {
  List<SerialProtocolText> textListOl = [];
  List<SerialProtocolText> textListUl = [];
  List<SerialProtocolText> textListWgt = [];
  List<SerialProtocolText> textListPcs = [];
  List<SerialProtocolText> textListPrice = [];
  List<SerialProtocolText> textListPct = [];

  List<String> outputData = [];
  List<String> alignments = ['left', 'right'];
  List<String> fillings = ['0', 'space'];
  List<String> jsonFilesList = [];

  List<int> decimals = [0, 1, 2, 3, 4];

  Map<String, int> pageMap = {
    "OL": 1,
    "UL": 2,
    "Weight": 3,
    "Pcs": 4,
    "Price": 5,
    "Percent": 6,
  };

  String pageTitle = '';
  String _selectedAlignment = 'left';
  String _selectedFilling = 'space';

  int count = 0;
  int _selectedDecimal = 3;
  final double buttonWidth = 100;
  final double buttonHeight = 40;

  late int _currentPageIndex;
  late ColorScheme colorScheme;
  bool isArrowBackHovered = false;
  bool isArrowForwardHovered = false;
  bool serialPreview = false;
  bool _isHexDisplay = false;
  bool _downloading = false;
  // bool _cntStop = false; //连续发送已经停止
  bool sendStop = false; //连续发送已经停止

  TextEditingController myContentCtl =
      TextEditingController(text: mySerialProtocolText.content);
  TextEditingController myMaxLenCtl =
      TextEditingController(text: mySerialProtocolText.maxLength.toString());
  TextEditingController myBoolTypeTrueCtl =
      TextEditingController(text: mySerialProtocolText.isTrue);
  TextEditingController myBoolTypeFalseCtl =
      TextEditingController(text: mySerialProtocolText.isFalse);

  final textController = TextEditingController();
  final RegExp englishRegExp = RegExp(r'^[\x00-\x7F]*$');
  final List<String> _buttonLabels = [
    'Text',
    'Text_Hex',
    'Net',
    'Gross',
    'Tare',
    'WeightUnit',
    'isstable',
    'istare',
    'PCS',
    'Percent',
  ];

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  final ScrollController _scrollController = ScrollController();

  bool isListEmpty() {
    if (textListOl.isNotEmpty ||
        textListPcs.isNotEmpty ||
        textListPct.isNotEmpty ||
        textListPrice.isNotEmpty ||
        textListUl.isNotEmpty ||
        textListWgt.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    _currentPageIndex = 3;
    super.initState();
    initOutputList();
    cntScaleTimerMgr.stopCntScaleTimer();
    DefScaleInfo.getDefScaleInfo(1);
    // cntScaleTimerMgr.startCntScaleTimer(5);
    _eventbus1 = eventBus.on<EventSerialOutputResp>().listen((event) {
      if (mounted) {
        setState(() {
          _downloading = false;
          cntScaleTimerMgr.stopCntScaleTimer();
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
    _eventbus2 = eventBus.on<EventScalePassthData>().listen((event) {
      if (mounted) {
        if (serialPreview) {
          setState(() {
            myRespDataFromScale = event.obj;
            outputData.add(myRespDataFromScale.msgBody);
            if (outputData.length > 1000) {
              outputData.clear();
            }
          });
          scrollToBottom();
        }
      }
    });

    _eventbus3 = eventBus.on<EventOpenScalePassthResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        setState(() {});
      }
    });

    _eventbus4 = eventBus.on<EventCloseScalePassthResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
          cntScaleTimerMgr.stopCntScaleTimer();
          // cntScaleTimerMgr.startCntScaleTimer(5);
          PublicFunctions.stopWeight(1);
        } else if (!serialPreview) {
          // PublicFunctions.openScalePassth(1);
          PublicFunctions.stopWeight(1);
        }
      }
    });

    _eventbus5 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        // myRespDataFromScale = event.obj;
        if (!serialPreview) {
          PublicFunctions.stopWeight(1);
        }
      }
    });

    _eventbus6 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      // if (mounted) {
      //   setState(() {
      //     myFactoryInfoFromScale = event.obj;
      //     if (myFactoryInfoFromScale.modelName != '') {
      //       myComScaleInfo.isOnline = true;
      //     } else {
      //       myComScaleInfo.isOnline = false;
      //     }
      //   });
      // }
    });

    _eventbus7 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        setState(() {
          myReqWeightCountine = event.obj;
          if (myReqWeightCountine.scaleId! == 1) {
            if (!serialPreview) {
              PublicFunctions.stopWeight(1);
            } else {
              PublicFunctions.openScalePassth(1);
            }
          }
        });
      }
    });

    _eventbus8 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        setState(() {
          if (myRespDataFromScale.msgBody.contains('ok')) {
            // print('ok');
            return;
          } else {
            if (!serialPreview) {
              PublicFunctions.stopWeight(1);
            }
          }
        });
      }
    });
  }

  String convertHexToAsciiString(String hexString) {
    final bytes = hexString
        .replaceAll(" ", "")
        .split('')
        .map((e) => int.parse(e, radix: 16))
        .toList();

    final codePoints = List<int>.generate(
        bytes.length ~/ 2, (i) => bytes[i * 2] * 16 + bytes[i * 2 + 1]);
    final asciiCharacters =
        codePoints.map((codePoint) => String.fromCharCode(codePoint)).toList();
    return asciiCharacters.join('');
  }

  void scrollToBottom() {
    // 滚动到底部
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollToBottom); // 移除监听
    _scrollController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    colorScheme = Theme.of(context).colorScheme;
    pageTitle = getTitleName(_currentPageIndex);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          height: 50,
          width: screenSize.width - 10,
          color: colorScheme.primary,
          child: pageHeadDefScale(context, localizedStrings.gTitleSerialOutput,
              localizedStrings.gTipSerialDesignPageHelp),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 1,
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 2,
                    color: colorScheme.primary,
                  ),
                  Expanded(
                    flex: 6, // 设置子部件占用空间的比例
                    child: Container(
                      color: colorScheme.surfaceTint,
                      child: ListView.builder(
                        itemCount: _buttonLabels.length + 1, // +1是为了添加"Enter"按钮
                        itemBuilder: (context, index) {
                          if (index == _buttonLabels.length) {
                            // 最后一个是"Enter"按钮
                            return TextButton(
                              onPressed: () {
                                setState(() {
                                  _addEnter(_currentPageIndex);
                                });
                              },
                              child: const Text('Enter'),
                            );
                          }
                          final label = _buttonLabels[index];
                          return TextButton(
                            onPressed: () {
                              setState(() {
                                if (label == 'Text') {
                                  _addTextData(_currentPageIndex);
                                }
                                if (label == 'Text_Hex') {
                                  _addTextHexData(_currentPageIndex);
                                } else {
                                  _addVarData(label, _currentPageIndex);
                                }
                              });
                            },
                            child: Text(label),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                  color: colorScheme.surfaceTint,
                  border: Border.all(
                      width: 0.2,
                      color: Theme.of(context).colorScheme.onSurface)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: ListView(
                      children: [
                        Row(
                          children: [
                            pageTitleWidget(3),
                            pageTitleWidget(1),
                            pageTitleWidget(2),
                            pageTitleWidget(4),
                            pageTitleWidget(5),
                            pageTitleWidget(6),
                          ],
                        ),
                        Divider(
                          height: 10,
                          thickness: 10,
                          color: colorScheme.scrim,
                        ),
                        SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(
                              pageTitle,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary),
                            ),
                          ),
                        ),
                        _buildTexts(_currentPageIndex),
                      ],
                    ),
                  ),
                  Divider(
                    height: 2,
                    color: colorScheme.primary,
                  ),
                  Expanded(
                    flex: 4,
                    child: secondPageBuild(_currentPageIndex),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 4,
              child: Container(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1, // 设置子部件占用空间的比例
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CustomElevatedButton(
                              btnWidth: buttonWidth,
                              btnHeight: 40,
                              icon: Icons.download_rounded,
                              text: localizedStrings.gBtnDownload,
                              onPressed: (!serialPreview &&
                                      isListEmpty() &&
                                      !_downloading)
                                  ? () async {
                                      jsonFilesList.clear();
                                      for (var i = 1; i < 7; i++) {
                                        bool res = await generateJson(i);
                                        if (!res) {
                                          return;
                                        }
                                      }
                                      await generateFileList();
                                      if (jsonFilesList.isNotEmpty) {
                                        PublicFunctions.sendOutputFmtToScale(
                                            jsonFilesList,
                                            myDefScaleInfo.defScaleId!);
                                      }
                                      setState(() {
                                        _downloading = true;
                                      });
                                      cntScaleTimerMgr.stopCntScaleTimer();
                                    }
                                  : null,
                            ),
                            CustomElevatedButton(
                              btnWidth: buttonWidth,
                              btnHeight: buttonHeight,
                              icon: Icons.visibility_outlined,
                              text: localizedStrings.cBtnOpenPreview,
                              onPressed: !serialPreview &&
                                      (myDefScaleInfo.defScaleId! == 1)
                                  ? handleButtonPress
                                  : null,
                            ),
                            CustomElevatedButton(
                              btnWidth: buttonWidth,
                              btnHeight: buttonHeight,
                              icon: Icons.visibility_off_outlined,
                              text: localizedStrings.cBtnClosePreview,
                              onPressed: () async {
                                setState(() {
                                  serialPreview = false;
                                  outputData.clear();
                                });
                                // PublicFunctions.closeScalePassth(1);
                                PublicFunctions.stopWeight(1);
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: colorScheme.primary,
                      ),
                      !serialPreview
                          ? Expanded(
                              flex: 6, // 设置子部件占用空间的比例
                              child: ListView(
                                children: (getListName(_currentPageIndex).isNotEmpty &&
                                        mySerialProtocolText.type == 'Bool' &&
                                        mySerialProtocolText.tabOrder != 9999 &&
                                        (mySerialProtocolText.varName == 'isstable' ||
                                            mySerialProtocolText.varName ==
                                                'istare'))
                                    ? _boolProperty()
                                    : (getListName(_currentPageIndex).isNotEmpty &&
                                            mySerialProtocolText.type ==
                                                'TEXT' &&
                                            mySerialProtocolText.tabOrder !=
                                                9999)
                                        ? _textProperty()
                                        : (getListName(_currentPageIndex).isNotEmpty &&
                                                mySerialProtocolText.type ==
                                                    'TEXT_HEX' &&
                                                mySerialProtocolText.tabOrder !=
                                                    9999)
                                            ? _textHexProperty()
                                            : (getListName(_currentPageIndex).isNotEmpty &&
                                                    mySerialProtocolText.type ==
                                                        'String' &&
                                                    mySerialProtocolText.tabOrder !=
                                                        9999)
                                                ? _stringProperty()
                                                : (getListName(_currentPageIndex)
                                                            .isNotEmpty &&
                                                        mySerialProtocolText.type ==
                                                            'Enter')
                                                    ? _enterProperty()
                                                    : (getListName(_currentPageIndex)
                                                                .isNotEmpty &&
                                                            mySerialProtocolText.type ==
                                                                'Float' &&
                                                            mySerialProtocolText
                                                                    .tabOrder !=
                                                                9999)
                                                        ? _floatProperty()
                                                        : (getListName(_currentPageIndex)
                                                                    .isNotEmpty &&
                                                                mySerialProtocolText
                                                                        .type ==
                                                                    'Integer' &&
                                                                mySerialProtocolText.tabOrder != 9999)
                                                            ? _intProperty()
                                                            : [],
                              ),
                            )
                          : Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          OutlinedButton(
                                              style: ButtonStyle(
                                                side: WidgetStateProperty
                                                    .resolveWith<BorderSide>(
                                                  (Set<WidgetState> states) {
                                                    return BorderSide(
                                                      color: colorScheme
                                                          .scrim, // 设置边框颜色为红色
                                                      width: 2, // 设置边框宽度
                                                    );
                                                  },
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  outputData.clear();
                                                });
                                              },
                                              child: Text(
                                                localizedStrings.gBtnClear,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                          OutlinedButton(
                                              style: ButtonStyle(
                                                backgroundColor: _isHexDisplay
                                                    ? WidgetStateProperty.all(
                                                        colorScheme.primary)
                                                    : WidgetStateProperty.all(
                                                        colorScheme.onPrimary),
                                                side: WidgetStateProperty
                                                    .resolveWith<BorderSide>(
                                                  (Set<WidgetState> states) {
                                                    return BorderSide(
                                                      color: colorScheme
                                                          .scrim, // 设置边框颜色为红色
                                                      width: 2, // 设置边框宽度
                                                    );
                                                  },
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isHexDisplay =
                                                      !_isHexDisplay;
                                                });
                                                PublicFunctions
                                                    .changeScalePassth(
                                                        _isHexDisplay, 1);
                                              },
                                              child: Text(
                                                'HEX',
                                                style: TextStyle(
                                                  color: _isHexDisplay
                                                      ? colorScheme.onPrimary
                                                      : colorScheme.primary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ))
                                        ],
                                      )),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      margin: const EdgeInsets.all(10.0),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary, // 边框颜色
                                          width: 2.0, // 边框宽度
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0)), // 边框圆角
                                      ),
                                      child: ListView.builder(
                                        padding:
                                            const EdgeInsets.all(10.0), // 添加边距
                                        itemCount: outputData.length,
                                        itemBuilder: (context, index) {
                                          return Text(outputData[index]);
                                        },
                                        controller: _scrollController,
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                    ],
                  )))
        ],
      ),
    );
  }

//导出文件到压缩包
  void exportFile() async {
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      dialogTitle: 'Output file:',
      type: FileType.custom,
      allowedExtensions: ['zip'],
      fileName: 'serialOutput.zip',
    ));

    if (outputFile != null) {
      if (!outputFile.contains(".zip")) {
        outputFile = "$outputFile.zip";
      }
      final serialOutputPath = await getJsonFileDir();
      if (!await serialOutputPath.exists()) {
        await serialOutputPath.create(recursive: true);
      }
      var sourceFolder = serialOutputPath.path;
      copyFilesAndCompressToZip(sourceFolder, directory, outputFile);
    }
  }

  void copyFilesAndCompressToZip(String sourceFolderPath,
      String destinationFolderPath, String destFolderZipPath) {
    Directory sourceFolder = Directory(sourceFolderPath);
    Directory destinationFolder = Directory(destinationFolderPath);

    if (!destinationFolder.existsSync()) {
      // 如果目标文件夹不存在，可以使用 createSync() 方法创建
      destinationFolder.createSync(recursive: true);
    }

    List<FileSystemEntity> files = sourceFolder.listSync(recursive: true);
    Archive archive = Archive(); // 创建一个空的 Archive 对象
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(('There are no files to save.'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
          duration: const Duration(seconds: 3),
          backgroundColor:
              Theme.of(context).colorScheme.onTertiaryFixedVariant));
    }

    for (var file in files) {
      if (file is File) {
        String destinationFilePath = file.path
            .replaceAll(sourceFolder.path, destinationFolder.path); // 目标文件路径

        File destinationFile = File(destinationFilePath);
        try {
          file.copySync(destinationFile.path);
          ArchiveFile archiveFile = ArchiveFile(
              destinationFile.path,
              destinationFile.lengthSync(),
              File(destinationFile.path)
                  .readAsBytesSync()); // 创建 ArchiveFile 对象
          archive.addFile(archiveFile); // 将 ArchiveFile 对象添加到 Archive 中
          destinationFile.deleteSync();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('fail$e',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
              duration: const Duration(seconds: 3),
              backgroundColor: Theme.of(context).colorScheme.error));
        }
      }
    }
    if (archive.isNotEmpty) {
      List<int>? zipData = ZipEncoder().encode(archive); // 压缩 Archive 对象为字节数组
      Archive archiveWithoutDirectory = Archive();
      for (var file in archive) {
        if (!file.isFile) continue;
        String fileName = file.name.contains('/')
            ? file.name.substring(file.name.lastIndexOf('/') + 1)
            : file.name;
        ArchiveFile archiveFile =
            ArchiveFile(fileName, file.size, file.content);
        archiveWithoutDirectory.addFile(archiveFile);
      }

      zipData =
          ZipEncoder().encode(archiveWithoutDirectory); // 重新压缩仅包含文件的 Archive 对象
      File(destFolderZipPath).writeAsBytesSync(zipData!); // 将字节数组写入目标 ZIP 文件
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(('Save $destFolderZipPath successful.'),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
          duration: const Duration(seconds: 3),
          backgroundColor:
              Theme.of(context).colorScheme.onTertiaryFixedVariant));
    }
  }

  void handleButtonPress() async {
    setState(() {
      cntScaleTimerMgr.stopCntScaleTimer();
      serialPreview = true;
      _isHexDisplay = false;
      outputData.clear();
    });
    PublicFunctions.getWeight(1);
  }

  String getTitleName(int pageId) {
    String titleName = '';
    switch (pageId) {
      case 1:
        titleName = localizedStrings.serial_page_ol;
        break;
      case 2:
        titleName = localizedStrings.serial_page_ul;
        break;
      case 3:
        titleName = localizedStrings.serial_page_weight;
        break;
      case 4:
        titleName = localizedStrings.serial_page_pcs;
        break;
      case 5:
        titleName = localizedStrings.serial_page_price;
        break;
      case 6:
        titleName = localizedStrings.serial_page_percent;
        break;
      default:
        titleName = ""; // 如果没有匹配的pageId，设置一个默认值
        break;
    }
    return titleName;
  }

  Flexible pageTitleWidget(int pageId) {
    return Flexible(
      flex: 1,
      child: Container(
          color: (_currentPageIndex == pageId)
              ? colorScheme.scrim
              : colorScheme.onPrimary,
          child: OutlinedButton(
              style: ButtonStyle(
                side: WidgetStateProperty.resolveWith<BorderSide>(
                  (Set<WidgetState> states) {
                    return BorderSide(
                      color: colorScheme.scrim, // 设置边框颜色为红色
                      width: 2, // 设置边框宽度
                    );
                  },
                ),
              ),
              onPressed: () {
                setState(() {
                  _currentPageIndex = pageId;
                  // pageTitle = localizedStrings.serial_page_ol;
                });
              },
              child: Text(
                getTitleName(pageId),
                overflow: TextOverflow.ellipsis,
              ))),
    );
  }

  Container secondPageBuild(int pageId) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceTint,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 30,
            color: colorScheme.primary,
            child: Center(
              child: Text(
                localizedStrings.cBtnOpenPreview,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: colorScheme.surfaceTint,
              child: SingleChildScrollView(
                child: Text(
                  _getOutputData(pageId),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addEnter(int pageId) {
    List<SerialProtocolText> list = getListName(pageId);

    list.add(SerialProtocolText(
        'Enter', '\\r\\n', '', 'left', 0, ++count, '', '', '', 0, '', false));
    setState(() {
      mySerialProtocolText = list[list.length - 1];
      _changeSelect(list.length - 1, list);
    });
  }

  List<SerialProtocolText> getListName(int pageId) {
    if (pageId == pageMap["OL"]) {
      return textListOl;
    } else if (pageId == pageMap["UL"]) {
      return textListUl;
    } else if (pageId == pageMap["Weight"]) {
      return textListWgt;
    } else if (pageId == pageMap["Pcs"]) {
      return textListPcs;
    } else if (pageId == pageMap["Price"]) {
      return textListPrice;
    } else if (pageId == pageMap["Percent"]) {
      return textListPct;
    }
    return textListWgt;
  }

  String _getOutputData(int pageId) {
    String res = '';
    res = outPutData(getListName(pageId));
    return res;
  }

  String outPutData(List<SerialProtocolText> list) {
    String res = '';
    for (var i = 0; i < list.length; i++) {
      if (list[i].type == 'TEXT') {
        res = res + list[i].content;
      } else if (list[i].type == 'Bool') {
        if (list[i].varName == 'isstable' || list[i].varName == 'istare') {
          res = res + list[i].isTrue;
        }
      } else if (list[i].type == 'Enter') {
        res = '$res\r\n';
      } else {
        res = res + list[i].content;
      }
    }
    return res;
  }

  _boolProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.surfaceTint,
        child: Center(
          child: Text(
            'Text Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: colorScheme.primary),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        (mySerialProtocolText.varName == 'isstable')
            ? 'Stable Text:'
            : 'Gross Text',
        style: TextStyle(color: colorScheme.primary),
      ),
      TextField(
        controller: myBoolTypeTrueCtl,
        onChanged: (value) {
          setState(() {
            _changedDefault(mySerialProtocolText.tabOrder, value, 1);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        // inputFormatters: [
        //   FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        // ],
        decoration: const InputDecoration(),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        (mySerialProtocolText.varName == 'isstable')
            ? 'Unstable Text:'
            : 'Net Text',
        style: TextStyle(color: colorScheme.primary),
      ),
      TextField(
        controller: myBoolTypeFalseCtl,
        onChanged: (value) {
          setState(() {
            _changedDefault(mySerialProtocolText.tabOrder, value, 2);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        // inputFormatters: [
        //   FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        // ],
        decoration: const InputDecoration(),
      ),
      const SizedBox(
        height: 15,
      ),
      arrowWidget(),
      const SizedBox(
        height: 15,
      ),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteItem(_currentPageIndex);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, // 设置按钮的背景色
            elevation: 10, // 设置按钮的阴影
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
            ),
          ),
          child: Text('Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ))),
      const SizedBox(
        height: 50,
      ),
      const SizedBox(
        height: 50,
      ),
    ];
  }

  void _changedDefault(int index, String data, int defaultIndex) {
    for (var i = 0; i < textListWgt.length; i++) {
      if (textListWgt[i].tabOrder == index) {
        if (defaultIndex == 1) {
          textListWgt[i].isTrue = data;
        } else {
          textListWgt[i].isFalse = data;
        }

        break;
      }
    }
  }

  _enterProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.tertiaryContainer,
        child: Center(
          child: Text(
            'Enter Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: colorScheme.primary),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Content:    \\r\\n',
        style: TextStyle(color: colorScheme.primary),
      ),
      const SizedBox(
        height: 15,
      ),
      arrowWidget(),
      const SizedBox(
        height: 15,
      ),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteItem(_currentPageIndex);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, // 设置按钮的背景色
            elevation: 10, // 设置按钮的阴影
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
            ),
          ),
          child: Text('Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ))),
    ];
  }

  _changedContent(String data, int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    for (var i = 0; i < list.length; i++) {
      if (list[i].tabOrder == mySerialProtocolText.tabOrder) {
        list[i].content = data;
        break;
      }
    }
  }

  _changedAlignment(String data, int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    for (var i = 0; i < list.length; i++) {
      if (list[i].tabOrder == mySerialProtocolText.tabOrder) {
        list[i].alignment = data;
        if (list[i].varName == 'WeightUnit') {
          if (list[i].maxLength == 0) {
            list[i].content = 'kg';
          } else {
            list[i].content = '';
            String space = ' ';

            for (var j = 1; j <= list[i].maxLength; j++) {
              if (j == 1) {
                list[i].content = 'g';
              } else if (j == 2) {
                list[i].content = 'kg';
              } else {
                if (list[i].alignment == 'Left') {
                  list[i].content = list[i].content + space;
                } else {
                  list[i].content = space + list[i].content;
                }
              }
            }
          }
        }
        break;
      }
    }
  }

  _changedFilling(String data, int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    for (var i = 0; i < list.length; i++) {
      if (list[i].tabOrder == mySerialProtocolText.tabOrder) {
        list[i].filling = data;
        break;
      }
    }
  }

  _changedDecimal(int data, int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    if (data > 0) {
      if (mySerialProtocolText.maxLength < data + 2) {
        mySerialProtocolText.maxLength = data + 2;
        myMaxLenCtl.text = mySerialProtocolText.maxLength.toString();
      }
    }
    for (var i = 0; i < list.length; i++) {
      if (list[i].tabOrder == mySerialProtocolText.tabOrder) {
        list[i].decimal = data;
        list[i].maxLength = mySerialProtocolText.maxLength;

        break;
      }
    }
  }

  void _changedMaxLength(String data, int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    if (data.isEmpty) {
      data = '0';
    }

    for (var item in list) {
      if (item.tabOrder == mySerialProtocolText.tabOrder) {
        item.maxLength = int.parse(data);
        if (item.maxLength == 0) {
          if (item.varName == 'WeightUnit') {
            item.content = 'kg';
          } else {
            item.content = '000.000';
          }
          myContentCtl.text = item.content;
        } else {
          item.content = '';
          String space = ' ';
          if (item.varName == 'WeightUnit') {
            for (var j = 1; j <= item.maxLength; j++) {
              if (j == 1) {
                item.content = 'g';
              } else if (j == 2) {
                item.content = 'kg';
              } else {
                if (item.alignment == 'Left') {
                  item.content += space;
                } else {
                  item.content = space + item.content;
                }
              }
            }
          } else {
            StringBuffer contentBuffer = StringBuffer();
            for (var j = 0; j < item.maxLength; j++) {
              if (j < 10) {
                contentBuffer.write(j);
              } else if (j < 20) {
                contentBuffer.write(j - 10);
              } else {
                contentBuffer.write(j - 20);
              }
            }
            item.content = contentBuffer.toString();
          }
          myContentCtl.text = item.content;
        }
        break;
      }
    }
    setState(() {});
  }

//文本编辑属性
  _textProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.tertiaryContainer,
        child: Center(
          child: Text(
            'Text Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: colorScheme.primary),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Content:',
        style: TextStyle(color: colorScheme.primary),
      ),
      TextField(
        controller: myContentCtl,
        onChanged: (value) {
          setState(() {
            _changedContent(value, _currentPageIndex);
          });
        },
        textAlignVertical: TextAlignVertical.top,

        // inputFormatters: [
        //   FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        // ],
        decoration: const InputDecoration(),
      ),
      const SizedBox(
        height: 15,
      ),
      arrowWidget(),
      const SizedBox(
        height: 15,
      ),
      deleteButton(),
    ];
  }

  //文本HEX编辑属性
  _textHexProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.tertiaryContainer,
        child: Center(
          child: Text(
            'Text Hex Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Hexadecimal input, please separate with a space \r\nfor example: 31 32 33 34 35 36',
        style: TextStyle(color: colorScheme.error),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: colorScheme.primary),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Hex:',
        style: TextStyle(color: colorScheme.primary),
      ),
      TextField(
        controller: myContentCtl,
        onChanged: (value) {
          setState(() {
            _changedContent(value, _currentPageIndex);
          });
        },
        textAlignVertical: TextAlignVertical.top,

        // inputFormatters: [
        //   FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        // ],
        decoration: const InputDecoration(),
      ),
      const SizedBox(
        height: 15,
      ),
      arrowWidget(),
      const SizedBox(
        height: 15,
      ),
      deleteButton(),
    ];
  }

//变量编辑属性
  _stringProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.tertiaryContainer,
        child: Center(
          child: Text(
            'String Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: colorScheme.primary),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Alignment:',
        style: TextStyle(color: colorScheme.primary),
      ),
      _alignmentDropdownButton(_currentPageIndex),
      Text(
        'Filling:',
        style: TextStyle(color: colorScheme.primary),
      ),
      _fillingDropdownButton(_currentPageIndex),
      Text(
        'Max Length:',
        style: TextStyle(color: colorScheme.primary),
      ),
      maxLenWidget(),
      Text(
        'Default Value:',
        style: TextStyle(color: colorScheme.primary),
      ),
      TextField(
        readOnly: true,
        controller: myContentCtl,
        onChanged: (value) {
          setState(() {
            _changedContent(value, _currentPageIndex);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        // inputFormatters: [
        //   FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        // ],
        decoration: const InputDecoration(),
      ),
      const SizedBox(
        height: 15,
      ),
      arrowWidget(),
      const SizedBox(
        height: 15,
      ),
      deleteButton(),
      const SizedBox(
        height: 50,
      ),
      const SizedBox(
        height: 50,
      ),
    ];
  }

  DropdownButton _decimalDropdownButton(int pageId) {
    return DropdownButton<String>(
      dropdownColor: colorScheme.secondaryFixed,
      style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.normal),
      hint: Text(
        'Decimal:',
        style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      value: _selectedDecimal.toString(),
      items: decimals
          .map((int value) => DropdownMenuItem<String>(
                value: value.toString(),
                child: Text(value.toString()),
              ))
          .toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDecimal = int.parse(newValue!);
          _changedDecimal(_selectedDecimal, pageId);
          myContentCtl.text = mySerialProtocolText.content;
        });
      },
    );
  }

  DropdownButton _fillingDropdownButton(int pageId) {
    return DropdownButton<String>(
      dropdownColor: colorScheme.secondaryFixed,
      style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.normal),
      hint: Text(
        'Filling:',
        style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      value: _selectedFilling,
      items: fillings
          .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
          .toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedFilling = newValue!;
          _changedFilling(_selectedFilling, pageId);
          myContentCtl.text = mySerialProtocolText.content;
        });
      },
    );
  }

  DropdownButton _alignmentDropdownButton(int pageId) {
    return DropdownButton<String>(
      dropdownColor: colorScheme.secondaryFixed,
      style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.normal),
      hint: Text(
        'Alignment:',
        style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      value: _selectedAlignment,
      items: alignments
          .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
          .toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedAlignment = newValue!;
          _changedAlignment(_selectedAlignment, pageId);
          myContentCtl.text = mySerialProtocolText.content;
        });
      },
    );
  }

  //float类型的属性编辑

  _floatProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.tertiaryContainer,
        child: Center(
          child: Text(
            'Float Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: colorScheme.primary),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Alignment:',
        style: TextStyle(color: colorScheme.primary),
      ),
      _alignmentDropdownButton(_currentPageIndex),
      Text(
        'Filling:',
        style: TextStyle(color: colorScheme.primary),
      ),
      _fillingDropdownButton(_currentPageIndex),
      Text(
        'Decimal:',
        style: TextStyle(color: colorScheme.primary),
      ),
      _decimalDropdownButton(_currentPageIndex),
      Text(
        'Max Length:',
        style: TextStyle(color: colorScheme.primary),
      ),
      maxLenWidget(),
      Text(
        'Default Value:',
        style: TextStyle(color: colorScheme.primary),
      ),
      TextField(
        readOnly: true,
        controller: myContentCtl,
        onChanged: (value) {
          setState(() {
            _changedContent(value, _currentPageIndex);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        // inputFormatters: [
        //   FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        // ],
        decoration: const InputDecoration(),
      ),
      const SizedBox(
        height: 15,
      ),
      arrowWidget(),
      const SizedBox(
        height: 15,
      ),
      deleteButton(),
      const SizedBox(
        height: 50,
      ),
      const SizedBox(
        height: 50,
      ),
    ];
  }

  _intProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.tertiaryContainer,
        child: Center(
          child: Text(
            'Integer Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: colorScheme.primary),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Alignment:',
        style: TextStyle(color: colorScheme.primary),
      ),
      _alignmentDropdownButton(_currentPageIndex),
      Text(
        'Filling:',
        style: TextStyle(color: colorScheme.primary),
      ),
      _fillingDropdownButton(_currentPageIndex),
      Text(
        'Max Length:',
        style: TextStyle(color: colorScheme.primary),
      ),
      maxLenWidget(),
      Text(
        'Default Value:',
        style: TextStyle(color: colorScheme.primary),
      ),
      TextField(
        readOnly: true,
        controller: myContentCtl,
        onChanged: (value) {
          setState(() {
            _changedContent(value, _currentPageIndex);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        // inputFormatters: [
        //   FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        // ],
        decoration: const InputDecoration(),
      ),
      const SizedBox(
        height: 15,
      ),
      arrowWidget(),
      const SizedBox(
        height: 15,
      ),
      deleteButton(),
      const SizedBox(
        height: 50,
      ),
      const SizedBox(
        height: 50,
      ),
    ];
  }

  Widget deleteButton() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            _deleteItem(_currentPageIndex);
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary, // 设置按钮的背景色
          elevation: 10, // 设置按钮的阴影
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
          ),
        ),
        child: Text('Delete',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            )));
  }

  Widget arrowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          width: 50,
        ),
        InkWell(
          onTap: () {
            setState(() {
              _itemBack(mySerialProtocolText.tabOrder, _currentPageIndex);
            });
            // 处理按钮点击事件
          },
          onHover: (value) {
            setState(() {
              isArrowBackHovered = value;
            });
          },
          child: Container(
            height: 30.0,
            width: 30.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary,
                width: 1.0,
              ),
              color: !isArrowBackHovered
                  ? Theme.of(context).colorScheme.onPrimary
                  : colorScheme.secondaryFixed,
            ),
            child: Icon(
              Icons.arrow_back,
              color: colorScheme.primary,
              size: 24.0,
            ),
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        InkWell(
          onTap: () {
            setState(() {
              _itemForward(mySerialProtocolText.tabOrder, _currentPageIndex);
            });
            // 处理按钮点击事件
          },
          onHover: (value) {
            setState(() {
              isArrowForwardHovered = value;
            });
          },
          child: Container(
            height: 30.0,
            width: 30.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary,
                width: 1.0,
              ),
              color: !isArrowForwardHovered
                  ? Theme.of(context).colorScheme.onPrimary
                  : colorScheme.secondaryFixed,
            ),
            child: Icon(
              Icons.arrow_forward,
              color: colorScheme.primary,
              size: 24.0,
            ),
          ),
        ),
        const SizedBox(
          width: 50,
        ),
      ],
    );
  }

  TextField maxLenWidget() {
    return TextField(
      controller: myMaxLenCtl,
      onChanged: (value) {
        if (value.isNotEmpty) {
          if (mySerialProtocolText.decimal != 0 &&
              mySerialProtocolText.type == "Float") {
            if (int.parse(value) < mySerialProtocolText.decimal + 2) {
              mySerialProtocolText.maxLength = mySerialProtocolText.decimal + 2;
              value = mySerialProtocolText.maxLength.toString();
              myMaxLenCtl.text = value;
              myMaxLenCtl.selection = TextSelection.fromPosition(
                  TextPosition(offset: value.length));
            }
          }
          _changedMaxLength(value, _currentPageIndex);
        }
      },
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'^([0-9]|1[0-9]|20)$'),
        ),
      ],
      decoration: const InputDecoration(),
    );
  }

  void _itemBack(int index, int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    SerialProtocolText tempData = SerialProtocolText(
        'TEXT', 'Text', '', 'left', 0, list.length, '', '', '0', 0, '', false);

    for (var i = 0; i < list.length; i++) {
      if (list[i].tabOrder == index) {
        tempData = list[i];
        if (i != 0) {
          list[i] = list[i - 1];
          list[i - 1] = tempData;
        }
        break;
      }
    }
  }

  void _itemForward(int index, int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    SerialProtocolText tempData = SerialProtocolText(
        'TEXT', 'Text', '', 'left', 0, list.length, '', '', '0', 0, '', false);

    for (var i = 0; i < list.length; i++) {
      if (list[i].tabOrder == index) {
        tempData = list[i];
        if (i + 1 < list.length) {
          list[i] = list[i + 1];
          list[i + 1] = tempData;
        }
        break;
      }
    }
  }

  Widget _buildTexts(int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    return Wrap(
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (var i = 0; i < list.length; i++)
          _buildTextContent(list[i], pageId),
      ],
    );
  }

  void _deleteItem(int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    for (var i = 0; i < list.length; i++) {
      if (list[i].tabOrder == mySerialProtocolText.tabOrder) {
        list.removeAt(i);
        mySerialProtocolText.tabOrder = 9999;
        break;
      }
    }
  }

  void _addTextData(int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    list.add(SerialProtocolText(
        'TEXT', 'Text', '', 'right', 0, ++count, '', '', '0', 0, '', false));
    setState(() {
      mySerialProtocolText = list[list.length - 1];
      myContentCtl.text = mySerialProtocolText.content;
      _changeSelect(list.length - 1, list);
    });
  }

  void _addTextHexData(int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    list.add(SerialProtocolText('TEXT_HEX', '54 65 73 74', '', 'right', 0,
        ++count, '', '', '0', 0, '', false));
    setState(() {
      mySerialProtocolText = list[list.length - 1];
      myContentCtl.text = mySerialProtocolText.content;
      _changeSelect(list.length - 1, list);
    });
  }

  void _changeSelect(int index, List<SerialProtocolText> list) {
    for (var i = 0; i < list.length; i++) {
      list[i].isSelect = false;
    }
    list[index].isSelect = true;
  }

//找居中的位置取整函数
  int integerDivision(int num) {
    if (num > 1) {
      return num ~/ 2;
    }
    return 0;
  }

  void _addVarData(String varname, int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    if (varname == 'WeightUnit') {
      list.add(SerialProtocolText('String', ' kg', varname, 'right', 3, ++count,
          '', '', 'space', 0, '', false));
    } else if (varname == 'isstable') {
      list.add(SerialProtocolText('Bool', ' kg', varname, 'right', 3, ++count,
          'ST', 'US', 'space', 0, '', false));
    } else if (varname == 'istare') {
      list.add(SerialProtocolText('Bool', ' kg', varname, 'right', 3, ++count,
          'NT', 'GS', 'space', 0, '', false));
    } else if (varname == 'isiero') {
      list.add(SerialProtocolText('Bool', ' kg', varname, 'right', 3, ++count,
          'Z', 'NZ', 'space', 0, '', false));
    } else if (varname == 'Gross' ||
        varname == 'Tare' ||
        varname == 'Net' ||
        varname == 'Percent') {
      list.add(SerialProtocolText('Float', '0123456', varname, 'right', 7,
          ++count, '', '', 'space', 3, '', false));
    } else if (varname == 'PCS') {
      list.add(SerialProtocolText('Integer', '01', varname, 'right', 2, ++count,
          '', '', 'space', 0, '', false));
    }
    setState(() {
      mySerialProtocolText = list[list.length - 1];
      myContentCtl.text = mySerialProtocolText.content;
      myMaxLenCtl.text = mySerialProtocolText.maxLength.toString();
      myBoolTypeTrueCtl.text = mySerialProtocolText.isTrue;
      myBoolTypeFalseCtl.text = mySerialProtocolText.isFalse;
      _selectedAlignment = mySerialProtocolText.alignment;
      _selectedFilling = mySerialProtocolText.filling; //FLF
      _selectedDecimal = mySerialProtocolText.decimal;

      _changeSelect(list.length - 1, list);
    });
  }

  //创建中间区域的Button
  Widget _buildTextContent(SerialProtocolText textData, int pageId) {
    List<SerialProtocolText> list = getListName(pageId);
    return Container(
      height: 30,
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: colorScheme.primary),
      ),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: (textData.isSelect)
                ? WidgetStateProperty.all(colorScheme.primary)
                : null),
        onPressed: () {
          setState(() {
            mySerialProtocolText = textData;
            myContentCtl.text = mySerialProtocolText.content;
            myMaxLenCtl.text = mySerialProtocolText.maxLength.toString();
            _selectedAlignment = mySerialProtocolText.alignment;
            myBoolTypeTrueCtl.text = mySerialProtocolText.isTrue;
            myBoolTypeFalseCtl.text = mySerialProtocolText.isFalse;
            _selectedFilling = mySerialProtocolText.filling;
            _selectedDecimal = mySerialProtocolText.decimal;
            for (var i = 0; i < list.length; i++) {
              if (list[i].tabOrder == textData.tabOrder) {
                _changeSelect(i, list);
                break;
              }
            }
          });
        },
        //根据类型显示button的名字
        child: Text(
          (textData.type == 'Float' ||
                  textData.type == 'Integer' ||
                  textData.type == 'Bool' ||
                  textData.type == 'String')
              ? textData.varName
              : textData.content,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: (textData.isSelect)
                  ? Theme.of(context).colorScheme.onPrimary
                  : colorScheme.primary),
        ),
      ),
    );
  }

  bool validateHexStringWithSpaces(String str) {
    List<String> parts = str.split(' ');
    for (String part in parts) {
      if (part.length != 2 || !RegExp(r'^[0-9A-Fa-f]{2}$').hasMatch(part)) {
        return false;
      }
    }
    return true;
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
            OutlinedButton(
              child: Text(localizedStrings.gBtnConfirm),
              onPressed: () {
                Navigator.of(context).pop(true); // 跳转
              },
            ),
          ],
        );
      },
    );
  }

  bool fileExists(String filePath) {
    try {
      File(filePath).statSync();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> readJsonFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        var jsondata = json.decode(contents);
        if (jsondata.toString().isNotEmpty) {
          return true;
        }
        return false;
      } catch (e) {
        // print("Error reading file: $e");
        return false;
      }
    } else {
      // print("File does not exist");
      return false;
    }
  }

  Future<List<SerialProtocolText>> loadJsonData(String filePath) async {
    List<SerialProtocolText> textList = [];
    if (fileExists(filePath)) {
      bool res = await readJsonFile(filePath);
      if (res) {
        final file = File(filePath);
        final contents = await file.readAsString();

        var olList = OutPutList.fromJson(json.decode(contents));

        textList = switchListData(olList);
      }
    }

    return textList;
  }

  void initOutputList() async {
    final formatfilePath = await getJsonFileDir();
    if (!await formatfilePath.exists()) {
      return;
    } else {
      var directory = formatfilePath.path;

      var filePath1 = '$directory\\Weight.json';
      textListWgt = await loadJsonData(filePath1);
      var filePath2 = '$directory\\UL.json';
      textListUl = await loadJsonData(filePath2);
      var filePath3 = '$directory\\OL.json';
      textListOl = await loadJsonData(filePath3);
      var filePath4 = '$directory\\Pcs.json';
      textListPcs = await loadJsonData(filePath4);
      var filePath5 = '$directory\\Price.json';
      textListPrice = await loadJsonData(filePath5);
      var filePath6 = '$directory\\Percent.json';
      textListPct = await loadJsonData(filePath6);
    }
    setState(() {});
  }

  List<SerialProtocolText> switchListData(OutPutList origList) {
    List<SerialProtocolText> tempList = [];
    SerialProtocolText tmpData;
    if (origList.data.isEmpty) {
      return tempList;
    }
    try {
      for (var item in origList.data) {
        if (!item.isvar &&
            item.ishex != null &&
            !item.ishex! &&
            item.value != null) {
          if (item.value == '\\r\\n') {
            tempList.add(SerialProtocolText('Enter', '\\r\\n', '', 'left', 0,
                ++count, '', '', '', 0, '', false));
          } else {
            tempList.add(SerialProtocolText('TEXT', item.value!, '', 'right', 0,
                ++count, '', '', '0', 0, '', false));
          }

          continue;
        } else if (!item.isvar &&
            item.ishex != null &&
            item.ishex! &&
            item.value != null) {
          tempList.add(SerialProtocolText('TEXT_HEX', item.value!, '', 'right',
              0, ++count, '', '', '0', 0, '', false));
          continue;
        } else if (item.isvar) {
          if (item.varname == null) {
            continue;
          }

          var funcData = origList.function.firstWhere(
              (data) => data.id == item.functionid!,
              orElse: () =>
                  FunctionData(id: -1, type: '', description: '') // 返回一个默认值
              );
          if (funcData.id == -1) {
            continue;
          }
          String filling = '';

          if (item.varname == 'WeightUnit') {
            if (funcData.filling != null) {
              filling = funcData.filling == '0' ? '0' : 'space';
            }
            tmpData = SerialProtocolText(
                'String',
                ' kg',
                item.varname!,
                funcData.alignment!,
                item.length!,
                ++count,
                '',
                '',
                filling,
                0,
                '',
                false);
            tempList.add(tmpData);
            continue;
          } else if (item.varname == 'isstable') {
            tmpData = SerialProtocolText(
                'Bool',
                '   ',
                item.varname!,
                'Left',
                item.length!,
                ++count,
                funcData.istrue!,
                funcData.isfalse!,
                'space',
                0,
                '',
                false);
            tempList.add(tmpData);
            continue;
          } else if (item.varname == 'istare') {
            if (funcData.filling != null) {
              filling = funcData.filling == '0' ? '0' : 'space';
            }
            tmpData = SerialProtocolText(
                'Bool',
                '   ',
                item.varname!,
                'Left',
                item.length!,
                ++count,
                funcData.istrue!,
                funcData.isfalse!,
                filling,
                0,
                '',
                false);
            tempList.add(tmpData);
            continue;
          } else if (item.varname == 'isiero') {
            if (funcData.filling != null) {
              filling = funcData.filling == '0' ? '0' : 'space';
            }
            tmpData = SerialProtocolText(
                'Bool',
                '   ',
                item.varname!,
                'Left',
                item.length!,
                ++count,
                funcData.istrue!,
                funcData.isfalse!,
                filling,
                0,
                '',
                false);
            tempList.add(tmpData);
            continue;
          } else if (item.varname == 'Gross' ||
              item.varname == 'Tare' ||
              item.varname == 'Net' ||
              item.varname == 'Percent') {
            if (funcData.filling != null) {
              filling = funcData.filling == '0' ? '0' : 'space';
            }
            tmpData = SerialProtocolText(
                'Float',
                '0123456',
                item.varname!,
                funcData.alignment!,
                item.length!,
                ++count,
                '',
                '',
                filling,
                funcData.decimal!,
                '',
                false);
            tempList.add(tmpData);
            continue;
          } else if (item.varname == 'PCS') {
            if (funcData.filling != null) {
              filling = funcData.filling == '0' ? '0' : 'space';
            }
            tmpData = SerialProtocolText(
                'Integer',
                '01',
                item.varname!,
                funcData.alignment!,
                item.length!,
                ++count,
                '',
                '',
                filling,
                0,
                '',
                false);
            tempList.add(tmpData);
            continue;
          }
          continue;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return tempList;
  }

  Future<bool> generateJson(int pageId) async {
    List<Map<String, dynamic>> functionList = [];
    List<Map<String, dynamic>> dataList = [];
    List<SerialProtocolText> list = getListName(pageId);
    if (list.isEmpty) {
      return true;
    }
    int functionId = 0;
    for (var i = 0; i < list.length; i++) {
      if (list[i].type == 'TEXT') {
        dataList
            .add({"isvar": false, 'ishex': false, "value": list[i].content});
      }
      if (list[i].type == 'TEXT_HEX') {
        if (validateHexStringWithSpaces(list[i].content)) {
          dataList
              .add({"isvar": false, 'ishex': true, "value": list[i].content});
        } else {
          _showConfirmationDialog(
              context, 'The hexadecimal input is not valid');
          return false;
        }
      } else if (list[i].type == 'Enter') {
        dataList.add({"isvar": false, "value": '\r\n'});
      } else if (list[i].type == 'String') {
        String fillingValue = ' ';
        if (list[i].filling == '0') {
          fillingValue = '0';
        }
        functionList.add({
          "id": functionId,
          "type": "string",
          "alignment": list[i].alignment,
          "filling": fillingValue,
          "description": ""
        });
        dataList.add({
          "isvar": true,
          "varname": list[i].varName,
          "functionid": functionId,
          "length": list[i].maxLength,
        });
        functionId++;
      } else if (list[i].type == 'Float') {
        String fillingValue = ' ';
        if (list[i].filling == '0') {
          fillingValue = '0';
        }
        functionList.add({
          "id": functionId,
          "type": "float",
          "decimal": list[i].decimal,
          "alignment": list[i].alignment,
          "filling": fillingValue,
          "description": ""
        });
        dataList.add({
          "isvar": true,
          "varname": list[i].varName,
          "functionid": functionId,
          "length": list[i].maxLength,
        });
        functionId++;
      } else if (list[i].type == 'Bool') {
        functionList.add({
          "id": functionId,
          "type": "bool",
          "istrue": list[i].isTrue,
          "isfalse": list[i].isFalse,
          "description": ""
        });
        dataList.add({
          "isvar": true,
          "varname": list[i].varName,
          "functionid": functionId,
          "length": list[i].maxLength,
        });
        functionId++;
      } else if (list[i].type == 'Integer') {
        String fillingValue = ' ';
        if (list[i].filling == '0') {
          fillingValue = '0';
        }
        functionList.add({
          "id": functionId,
          "type": "integer",
          "alignment": list[i].alignment,
          "filling": fillingValue,
          "description": ""
        });
        dataList.add({
          "isvar": true,
          "varname": list[i].varName,
          "functionid": functionId,
          "length": list[i].maxLength,
        });
        functionId++;
      }
    }

    Map<String, dynamic> jsonData = {
      "function": functionList,
      "data": dataList
    };
    String jsonString = jsonEncode(jsonData);
    await writeJsonToFile(jsonString, pageId);
    return true;
  }

  Future<Directory> getJsonFileDir() async {
    String executablePath = Platform.resolvedExecutable;
    var directory = p.dirname(executablePath);
    return Directory('$directory\\output');
  }

  Future<void> writeJsonToFile(String jsonString, int pageId) async {
    final formatfilePath = await getJsonFileDir();
    if (!await formatfilePath.exists()) {
      await formatfilePath.create(recursive: true);
    }
    var directory = formatfilePath.path;
    String filePath = '';
    if (pageId == 1) {
      filePath = '$directory\\OL.json';
    } else if (pageId == 2) {
      filePath = '$directory\\UL.json';
    } else if (pageId == 3) {
      filePath = '$directory\\Weight.json';
    } else if (pageId == 4) {
      filePath = '$directory\\Pcs.json';
    } else if (pageId == 5) {
      filePath = '$directory\\Price.json';
    } else if (pageId == 6) {
      filePath = '$directory\\Percent.json';
    }
    // 创建文件并写入JSON字符串
    File file = File(filePath);
    file.writeAsString(jsonString);
  }

  generateFileList() async {
    final formatfilePath = await getJsonFileDir();
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
}
