import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/update_firmware_page.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dropdown_copy.dart';
import 'package:t_max/widget/scale_list.dart';
import '../data/downloadresponse.dart';
import '../data/custom_serial_protocol_text_dart.dart';
import '../data/language.dart';
import '../data/reqweightdata_data.dart';
import '../eventbus/eventbus.dart';
import 'package:path/path.dart' as p;
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
  final double topTitleHeight = 76;
  final double leftBtnWidth = 223;
  final double rightBtnWidth = 350;

  late int _currentPageIndex;
  late ColorScheme colorScheme;
  bool isArrowBackHovered = false;
  bool isArrowForwardHovered = false;
  bool serialPreview = false;
  bool _isHexDisplay = false;
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

  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  final ScrollController _scrollController = ScrollController();

  int selScaleId = -1;

  List<Scale> comScalesList = [];
  bool isPassthDataRev = false; //是否收到秤的透传数据
  late Timer _timer; //监控透传的状态

  //切换的时候要修改掉秤的信息
  void changeScale(int scaleId) {
    if (isPassthDataRev && selScaleId == scaleId) {
      return;
    }
    if (selScaleId != -1 && selScaleId != scaleId) {
      PublicFunctions.stopWeight(selScaleId);
    }

    setState(() {
      selScaleId = scaleId;
      _isHexDisplay = false;
      outputData.clear();
    });

    PublicFunctions.getWeight(scaleId);
  }

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
    for (var scale in myAllScalesList) {
      if (scale.tMedia == comScaleType) {
        comScalesList.add(scale);
      }
    }
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (isPassthDataRev) {
        setState(() {
          isPassthDataRev = false;
        });
      }
    });

    _eventbus2 = eventBus.on<EventScalePassthData>().listen((event) {
      if (mounted) {
        if (serialPreview) {
          setState(() {
            myRespDataFromScale = event.obj;
            if (myRespDataFromScale.scaleId == selScaleId) {
              outputData.add(myRespDataFromScale.msgBody);
              if (outputData.length > 1000) {
                outputData.clear();
              }
              isPassthDataRev = true;
            }
            for (var item in myAllScalesList) {
              if (item.scaleId == myRespDataFromScale.scaleId) {
                item.isOnline = true;
                break;
              }
            }
          });
          scrollToBottom();
        } else {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            PublicFunctions.stopWeight(myRespDataFromScale.scaleId);
          }
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
          for (var item in myAllScalesList) {
            if (item.scaleId == myRespDataFromScale.scaleId) {
              item.isOnline = true;
              break;
            }
          }

          PublicFunctions.stopWeight(selScaleId);
        } else if (!serialPreview) {
          // PublicFunctions.openScalePassth(1);
          PublicFunctions.stopWeight(selScaleId);
        }
      }
    });

    _eventbus5 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        // myRespDataFromScale = event.obj;
        if (!serialPreview) {
          PublicFunctions.stopWeight(selScaleId);
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
          if (myReqWeightCountine.scaleId! == selScaleId) {
            if (!serialPreview) {
              PublicFunctions.stopWeight(selScaleId);
            } else {
              PublicFunctions.openScalePassth(selScaleId);
            }
          } else {
            PublicFunctions.stopWeight(myReqWeightCountine.scaleId!);
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
            for (var item in myAllScalesList) {
              if (item.scaleId == myRespDataFromScale.scaleId) {
                item.isOnline = true;
                break;
              }
            }
            return;
          } else {
            if (!serialPreview) {
              PublicFunctions.stopWeight(selScaleId);
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

    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _timer.cancel();
    if (selScaleId != -1) {
      PublicFunctions.stopWeight(selScaleId);
    }
    myContentCtl.dispose();
    myMaxLenCtl.dispose();
    myBoolTypeTrueCtl.dispose();
    myBoolTypeFalseCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    colorScheme = Theme.of(context).colorScheme;
    pageTitle = getTitleName(_currentPageIndex);

    return Scaffold(
      body: (!serialPreview)
          ? Container(
              width: width,
              decoration: BoxDecoration(color: colorScheme.surface),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // pageHeadInfo(
                    //     context,
                    //     width - headWidthPadding,
                    //     localizedStrings.menuSerialOutputDesign,
                    //     localizedStrings.gTipSerialDesignPageHelp),
                    buildPageTitle(),
                    buildBottomPart(),
                  ]))
          : buildPreview(width),
    );
  }

  Widget buildPreview(double width) {
    return Container(
        width: width,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: subTitleInfo(
                  context,
                  width - headWidthPadding,
                  localizedStrings.gTitlePreview,
                  localizedStrings.gTipScaleMgrPageHelp),
            ),
            Expanded(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: scaleListWidth,
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: regularPadding,
                        ),
                        Expanded(
                          child: NewComScaleListWidget(
                            listWidth: scaleListWidth, // 列表宽度
                            selScaleId: selScaleId,
                            clickScale: (scale) {
                              setState(() {
                                changeScale(scale.scaleId);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: Theme.of(context).colorScheme.outlineVariant, //  分隔条颜色
                ),
                comScalesList.isEmpty
                    ? SizedBox()
                    : Expanded(
                        child: Container(
                        padding: const EdgeInsets.only(
                            top: smallPadding, bottom: largePadding),
                        child: Column(children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(0.0)), // 边框圆角
                              ),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.all(smallPadding), // 添加边距
                                itemCount: outputData.length,
                                itemBuilder: (context, index) {
                                  return Text(outputData[index],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                              color: colorScheme
                                                  .onSurfaceVariant));
                                },
                                controller: _scrollController,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              showTextButton(context, btnHeight,
                                  localizedStrings.gBtnClear, () {
                                setState(() {
                                  outputData.clear();
                                });
                              }, colorScheme.onPrimary, colorScheme.error,
                                  colorScheme.onPrimary),
                              showTextButton(context, btnHeight, 'HEX', () {
                                setState(() {
                                  _isHexDisplay = !_isHexDisplay;
                                });
                                PublicFunctions.changeScalePassth(
                                    _isHexDisplay, selScaleId);
                              },
                                  _isHexDisplay
                                      ? colorScheme.onPrimary
                                      : colorScheme.primary,
                                  _isHexDisplay
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                  colorScheme.onPrimary)
                            ],
                          )
                        ]),
                      )),
              ]),
            ),
          ],
        ));
  }

  Widget subTitleInfo(
      dynamic context, double maxWidth, String pageTitle, String helpInfo) {
    return SizedBox(
        height: pageTopTitleHeight,
        child: Column(children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                subNewTitle(context, maxWidth, pageTitle),
              ],
            ),
          ),
          Divider(
            color:
                Theme.of(context).colorScheme.surfaceContainerLow, // 设置分割线的颜色
            height: 1, // 设置分割线的高度
            thickness: 1, // 设置分割线的粗细
          ),
        ]));
  }

  Widget subNewTitle(
    dynamic context,
    double maxWidth,
    String pageTitle,
  ) {
    return Row(
      children: [
        SizedBox(
          width: largePadding,
        ),
        IconButton(
          iconSize: 22,
          onPressed: () {
            setState(() {
              serialPreview = false;
            });
            PublicFunctions.stopWeight(selScaleId);
          },
          icon: Icon(Icons.keyboard_double_arrow_left),
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(
          width: regularPadding,
        ),
        SizedBox(
          width: maxWidth,
          child: Text(
            pageTitle,
            style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

//标题栏组件
  Widget buildPageTitle() {
    return Container(
      height: topTitleHeight,
      padding: const EdgeInsets.all(regularPadding),
      child: Container(
        height: btnHeight,
        color: colorScheme.surfaceDim,
        child: Row(children: [
          columnItem(pageMap['Weight']!),
          columnItem(pageMap['OL']!),
          columnItem(pageMap['UL']!),
          columnItem(pageMap['Pcs']!),
          columnItem(pageMap['Price']!),
          columnItem(pageMap['Percent']!),
        ]),
      ),
    );
  }

  // 底部部分组件
  Widget buildBottomPart() {
    return Expanded(
        child: Container(
      color: colorScheme.surfaceContainerLow,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showBottomLeftPart(),
          showBottomMiddlePart(),
          showBottomRightPart(),
        ],
      ),
    ));
  }

  // 底部左侧部分组件
  Widget showBottomLeftPart() {
    return Container(
        color: colorScheme.surfaceContainerLow,
        width: leftBtnWidth,
        padding: const EdgeInsets.all(regularPadding),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _buttonLabels.length + 1, // +1是为了添加"Enter"按钮
                itemBuilder: (context, index) {
                  if (index == _buttonLabels.length) {
                    // 最后一个是"Enter"按钮
                    return buildEnterBtn();
                  }
                  final label = _buttonLabels[index];
                  return buildOtherTextBtn(label);
                },
              ),
            ),
          ],
        ));
  }

  // 构建其他文本按钮
  Widget buildOtherTextBtn(String label) {
    return Container(
        height: 44,
        padding: const EdgeInsets.only(bottom: smallPadding),
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
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
          child: Text(label,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: colorScheme.onSurface,
                  )),
        ));
  }

  //显示Enter按钮
  Widget buildEnterBtn() {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(bottom: smallPadding),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        onPressed: () {
          setState(() {
            _addEnter(_currentPageIndex);
          });
        },
        child: Text('Enter',
            style: Theme.of(context).textTheme.bodySmall!.apply(
                  color: colorScheme.onSurface,
                )),
      ),
    );
  }

  // 底部中间部分组件
  Widget showBottomMiddlePart() {
    return Expanded(
      child: Container(
          padding:
              const EdgeInsets.only(top: regularPadding, right: regularPadding),
          child: Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(regularPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            pageTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .apply(color: colorScheme.primary),
                          ),
                        ),
                      ),
                      _buildTexts(_currentPageIndex),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: secondPageBuild(_currentPageIndex),
                ),
                buildBtnRow(),
              ],
            ),
          )),
    );
  }

  // 底部右侧部分组件
  Widget showBottomRightPart() {
    return SizedBox(
        width: rightBtnWidth,
        child: Container(
            padding: const EdgeInsets.only(
              top: regularPadding,
            ),
            child: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.all(regularPadding),
                child: Column(
                  children: [!serialPreview ? attribute() : preview()],
                ))));
  }

  // 显示属性界面
  Widget attribute() {
    return Expanded(
      child: ListView(
        children: (getListName(_currentPageIndex).isNotEmpty &&
                mySerialProtocolText.type == 'Bool' &&
                mySerialProtocolText.tabOrder != 9999 &&
                (mySerialProtocolText.varName == 'isstable' ||
                    mySerialProtocolText.varName == 'istare'))
            ? _boolProperty()
            : (getListName(_currentPageIndex).isNotEmpty &&
                    mySerialProtocolText.type == 'TEXT' &&
                    mySerialProtocolText.tabOrder != 9999)
                ? _textProperty()
                : (getListName(_currentPageIndex).isNotEmpty &&
                        mySerialProtocolText.type == 'TEXT_HEX' &&
                        mySerialProtocolText.tabOrder != 9999)
                    ? _textHexProperty()
                    : (getListName(_currentPageIndex).isNotEmpty &&
                            mySerialProtocolText.type == 'String' &&
                            mySerialProtocolText.tabOrder != 9999)
                        ? _stringProperty()
                        : (getListName(_currentPageIndex).isNotEmpty &&
                                mySerialProtocolText.type == 'Enter')
                            ? _enterProperty()
                            : (getListName(_currentPageIndex).isNotEmpty &&
                                    mySerialProtocolText.type == 'Float' &&
                                    mySerialProtocolText.tabOrder != 9999)
                                ? _floatProperty()
                                : (getListName(_currentPageIndex).isNotEmpty &&
                                        mySerialProtocolText.type ==
                                            'Integer' &&
                                        mySerialProtocolText.tabOrder != 9999)
                                    ? _intProperty()
                                    : [],
      ),
    );
  }

  // 显示预览界面
  Widget preview() {
    return Expanded(
        child: Column(
      children: [
        Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                showTextButton(context, btnHeight, localizedStrings.gBtnClear,
                    () {
                  setState(() {
                    outputData.clear();
                  });
                }, colorScheme.onPrimary, colorScheme.error,
                    colorScheme.onPrimary),
                showTextButton(context, btnHeight, 'HEX', () {
                  setState(() {
                    _isHexDisplay = !_isHexDisplay;
                  });
                  PublicFunctions.changeScalePassth(_isHexDisplay, 1);
                },
                    _isHexDisplay ? colorScheme.onPrimary : colorScheme.primary,
                    _isHexDisplay
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    colorScheme.onPrimary)
              ],
            )),
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(smallPadding),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outlineVariant, // 边框颜色
                width: 1.0, // 边框宽度
              ),
              borderRadius:
                  const BorderRadius.all(Radius.circular(0.0)), // 边框圆角
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(smallPadding), // 添加边距
              itemCount: outputData.length,
              itemBuilder: (context, index) {
                return Text(outputData[index],
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .apply(color: colorScheme.onSurfaceVariant));
              },
              controller: _scrollController,
            ),
          ),
        ),
      ],
    ));
  }

  // 提取分隔线组件
  Widget verticalDivider() {
    return Container(
      height: btnHeight,
      width: 1,
      alignment: Alignment.center,
      child: Container(
        color: colorScheme.primary,
        height: 24,
      ),
    );
  }

  // 提取按钮组件
  Widget textButton(int pageId) {
    return SizedBox(
        height: btnHeight,
        child: TextButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
          onPressed: () {
            setState(() {
              _currentPageIndex = pageId;
            });
          },
          child: Text(
            getTitleName(pageId),
            style: Theme.of(context).textTheme.bodySmall!.apply(
                color: _currentPageIndex == pageId
                    ? colorScheme.primary
                    : colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        ));
  }

  // 提取每列组件
  Widget columnItem(int pageId) {
    return Expanded(
      child: Row(
        children: [
          Expanded(child: textButton(pageId)),
          verticalDivider(),
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
          backgroundColor: colorScheme.onTertiaryFixedVariant));
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
              backgroundColor: colorScheme.error));
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
          backgroundColor: colorScheme.onTertiaryFixedVariant));
    }
  }

  void handleButtonPress() async {
    setState(() {
      serialPreview = true;
      _isHexDisplay = false;
      outputData.clear();
    });
    if (selScaleId != -1) {
      PublicFunctions.getWeight(selScaleId);
    }
  }

  String getTitleName(int pageId) {
    String titleName = '';
    String key =
        pageMap.entries.firstWhere((entry) => entry.value == pageId).key;
    switch (key) {
      case "OL":
        titleName = localizedStrings.serial_page_ol;
        break;
      case "UL":
        titleName = localizedStrings.serial_page_ul;
        break;
      case "Weight":
        titleName = localizedStrings.serial_page_weight;
        break;
      case "Pcs":
        titleName = localizedStrings.serial_page_pcs;
        break;
      case "Price":
        titleName = localizedStrings.serial_page_price;
        break;
      case "Percent":
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

  Widget buildBtnRow() {
    return SizedBox(
        height: btnHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 200,
              child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.gBtnDownload,
                  (!serialPreview && isListEmpty())
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
                            // PublicFunctions.sendOutputFmtToScale(
                            //     jsonFilesList, myDefScaleInfo.defScaleId!);
                            useNetworkUpdate(jsonFilesList);
                          }
                        }
                      : null,
                  colorScheme.onPrimary,
                  colorScheme.primary,
                  colorScheme.onPrimary),
            ),
            SizedBox(
              width: 200,
              child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.cBtnOpenPreview,
                  handleButtonPress,
                  colorScheme.onPrimary,
                  colorScheme.onTertiaryFixedVariant,
                  colorScheme.onPrimary),
            )
          ],
        ));
  }

//comScaleSerialSend 串口的连续发送
  void useNetworkUpdate(List<String> jsonList) {
    String msg = '';
    showSelScaleDialog(comScaleSerialSend, msg, jsonList);
  }

  void showSelScaleDialog(int funcNo, String msg, List<String> jsonList) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return SelectScalesPageNew(
          funcNo: funcNo,
          sendMsgStr: msg,
          jsonList: jsonList,
        );
      },
    );
  }

  Container secondPageBuild(int pageId) {
    return Container(
      color: colorScheme.surfaceTint,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 30,
            color: colorScheme.surfaceContainerLow,
            child: Center(
              child: Text(
                localizedStrings.cBtnOpenPreview,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .apply(color: colorScheme.onSurface),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                  left: regularPadding,
                  right: regularPadding,
                  top: smallPadding),
              width: double.infinity,
              color: colorScheme.surfaceTint,
              child: SingleChildScrollView(
                child: Text(
                  _getOutputData(pageId),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .apply(color: colorScheme.onSurface),
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
            localizedStrings.gTipTextProperty,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      showTextTitleAttribute('Type:    ${mySerialProtocolText.type}'),
      Text(
        (mySerialProtocolText.varName == 'isstable')
            ? localizedStrings.gTipStableText
            : localizedStrings.gTipNetText,
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
            ? localizedStrings.gTipUnstableText
            : localizedStrings.gTipGrossText,
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
      deleteButton(),
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
            localizedStrings.gTipEnterProperty,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      showTextTitleAttribute('Type:    ${mySerialProtocolText.type}'),
      showTextTitleAttribute(localizedStrings.gTipContent + '    \\r\\n'),
      const SizedBox(
        height: 15,
      ),
      arrowWidget(),
      const SizedBox(
        height: 15,
      ),
      deleteButton()
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
            localizedStrings.gTipTextProperty,
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
      showTextTitleAttribute('Type:    ${mySerialProtocolText.type}'),
      showTextTitleAttribute(localizedStrings.gTipContent),
      TextField(
        controller: myContentCtl,
        onChanged: (value) {
          setState(() {
            _changedContent(value, _currentPageIndex);
          });
        },
        textAlignVertical: TextAlignVertical.top,
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
            localizedStrings.gTipTextHexProperty,
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
      Container(
        height: 80,
        color: colorScheme.surface,
        alignment: Alignment.centerLeft,
        child: Text(
          localizedStrings.gTipHexInput,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: colorScheme.onSurface,
              ),
        ),
      ),
      showTextTitleAttribute('Type:    ${mySerialProtocolText.type}'),
      showTextTitleAttribute('Hex'),
      TextField(
        controller: myContentCtl,
        onChanged: (value) {
          setState(() {
            _changedContent(value, _currentPageIndex);
          });
        },
        textAlignVertical: TextAlignVertical.top,
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
      showTextTitleAttribute('Type:    ${mySerialProtocolText.type}'),
      showTextTitleAttribute(localizedStrings.gTipAlignment),
      _alignmentDropdownButton(_currentPageIndex),
      showTextTitleAttribute(localizedStrings.gTipFilling),
      _fillingDropdownButton(_currentPageIndex),
      showTextTitleAttribute(localizedStrings.gTipMaxLength),
      maxLenWidget(),
      showTextTitleAttribute(localizedStrings.gTipDefaultValue),
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

  Widget _decimalDropdownButton(int pageId) {
    return showDropDownButtonValue(
        context,
        _selectedDecimal.toString(),
        decimals.map((int value) => (value.toString())).toList(),
        '', (String? newValue) {
      setState(() {
        _selectedDecimal = int.parse(newValue!);
        _changedDecimal(_selectedDecimal, pageId);
        myContentCtl.text = mySerialProtocolText.content;
      });
    });
  }

  Widget _fillingDropdownButton(int pageId) {
    return showDropDownButtonValue(context, _selectedFilling, fillings, '',
        (String? newValue) {
      setState(() {
        _selectedFilling = newValue!;
        _changedFilling(_selectedFilling, pageId);
        myContentCtl.text = mySerialProtocolText.content;
      });
    });
  }

  Widget _alignmentDropdownButton(int pageId) {
    return showDropDownButtonValue(context, _selectedAlignment, alignments, '',
        (String? newValue) {
      setState(() {
        _selectedAlignment = newValue!;
        _changedAlignment(_selectedAlignment, pageId);
        myContentCtl.text = mySerialProtocolText.content;
      });
    });
  }

  //float类型的属性编辑

  _floatProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.tertiaryContainer,
        child: Center(
          child: Text(
            localizedStrings.gTipFloatProperty,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      showTextTitleAttribute('Type:    ${mySerialProtocolText.type}'),
      showTextTitleAttribute(localizedStrings.gTipAlignment),
      _alignmentDropdownButton(_currentPageIndex),
      showTextTitleAttribute(localizedStrings.gTipFilling),
      _fillingDropdownButton(_currentPageIndex),
      showTextTitleAttribute(localizedStrings.gTipDecimal),
      _decimalDropdownButton(_currentPageIndex),
      showTextTitleAttribute(localizedStrings.gTipMaxLength),
      maxLenWidget(),
      showTextTitleAttribute(localizedStrings.gTipDefaultValue),
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

  Widget showTextTitleAttribute(String title) {
    return Container(
      height: 42,
      color: colorScheme.surface,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall!.apply(
              color: colorScheme.onSurface,
            ),
      ),
    );
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
      showTextTitleAttribute('Type:    ${mySerialProtocolText.type}'),
      showTextTitleAttribute(localizedStrings.gTipAlignment),
      _alignmentDropdownButton(_currentPageIndex),
      showTextTitleAttribute(localizedStrings.gTipFilling),
      _fillingDropdownButton(_currentPageIndex),
      showTextTitleAttribute(localizedStrings.gTipMaxLength),
      maxLenWidget(),
      showTextTitleAttribute(localizedStrings.gTipDefaultValue),
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
    return showTextButton(context, btnHeight, localizedStrings.gBtnDelete, () {
      setState(() {
        _deleteItem(_currentPageIndex);
      });
    }, colorScheme.onPrimary, colorScheme.error, colorScheme.onPrimary);
  }

  Widget arrowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
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
            height: 38.0,
            width: 38.0,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: !isArrowBackHovered
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.secondaryFixed,
            ),
            child: Icon(
              Icons.arrow_left,
              color: colorScheme.primary,
              size: 32.0,
            ),
          ),
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
            height: 38.0,
            width: 38.0,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: !isArrowForwardHovered
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.secondaryFixed,
            ),
            child: Icon(
              Icons.arrow_right,
              color: colorScheme.primary,
              size: 32.0,
            ),
          ),
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
        setState(() {
          if (list.isNotEmpty) {
            mySerialProtocolText = list[list.length - 1];
            _changeSelect(list.length - 1, list);
          } else {
            mySerialProtocolText.tabOrder = 9999;
          }
        });

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
      height: 40,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: colorScheme.surfaceContainerLow),
      ),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: (textData.isSelect)
              ? WidgetStateProperty.all(colorScheme.primary)
              : null,
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
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
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: (textData.isSelect)
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface),
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
            style: TextStyle(color: colorScheme.primary),
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
