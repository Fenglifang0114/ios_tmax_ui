import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gbk_codec/gbk_codec.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import '../data/manager_scale_channel.dart';
import '../data/barcoderowdata.dart';
import '../data/encrypt_data.dart';
import '../data/formatdata.dart';
import '../data/item_key_list.dart';
import '../data/language.dart';
import '../data/offset.dart';
import '../data/scalecmd_data.dart';
import '../data/selectedcontrol.dart';
import '../data/text.dart';
import '../data/writelog.dart';
import '../dialog/barcodeedit_dialog.dart';
import '../dialog/qrcodeedit_dialog.dart';
import '../eventbus/eventbus.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import '../widget/draggable_fliating.dart';
import '../widget/dropdown_copy.dart';
import '../widget/page_head.dart';
import '../widget/textlist_item.dart';

class LabelDesignPage extends StatefulWidget {
  final String type;
  const LabelDesignPage({super.key, required this.type});

  @override
  State<LabelDesignPage> createState() => _LabelDesignPageState();
}

const labelVarMap = {
  "Free Text": ["Text,TEXT"],
  "BarCode Variable": ["BarCode,BarCode"],
  "Qrcode Variable": ["Qrcode,Qrcode"],
  // "Shape": ["Line,Line"],
  // "Shape": ["Rectangle,Rectangle", "Circle,Circle", "Line,Line"],
  "Variable": [
    "NO.,DATA",
    "Gross,DATA",
    "Tare,DATA",
    "Net,DATA",
    "PCS,DATA",
    "WeightUnit,DATA",
    // "Date,DATA",
    // "Time,DATA",
    "DATE,DATA",
    "TIME,DATA",
    "U.WGT,DATA",
    "U.WU,DATA",
    "UnitWeight,DATA",
    "Percent,DATA",
    "TotalWeight,DATA",
    "TotalCount,DATA",
    "TotalPcs,DATA",
  ],
};

class _LabelDesignPageState extends State<LabelDesignPage> {
  List<TextItem> textItemList = [];
  List<DraggableFloatingActionButton> floatButtonList = [];
  GlobalKey _parentKey = GlobalKey();
  List<int> num = [0];
  dynamic name = "Text,TEXT";
  String text = "";
  String type = '';
  int xPos = 0;
  int yPos = 0;
  int width = 20;
  int height = 50;
  int fontSize = 23;
  int fontWidthRatio = 1;
  int fontHeightRatio = 1;
  int style = 0;
  int rotation = 0;
  String varName = '';
  String defaultValue = 'data';
  int alignment = 1;
  int maxLength = 10;
  int tabOrder = 0;
  String content = '';
  String barcodeName = '--';
  String barcodeType = '';
  String hralignment = 'Bottom';
  int x2Pos = 100;
  int y2Pos = 0;
  double lineWidth = 2;
  String qrWidth = '3';
  String qrcodename = '--';
  String qrcodeType = 'Qrcode';
  String fontBold = 'false';
  String fontReverse = 'false';
  List<dynamic> varcontent = [];
  // Offset _offset = const Offset(0, 0);
  // bool _isDragging = false;
  final double btnWidth = 150;
  final double textWidth = 120;
  final double topTitleHeight = 300;
  final double topBtnHeight = 120;
  final double leftBtnWidth = 280;
  final double rightBtnWidth = 288;

  TextEditingController textvariable = TextEditingController();
  TextEditingController fontsizevar = TextEditingController();
  TextEditingController xPosvar = TextEditingController();
  TextEditingController yPosvar = TextEditingController();
  TextEditingController x2Posvar = TextEditingController();
  TextEditingController y2Posvar = TextEditingController();
  TextEditingController maxLenthvar = TextEditingController();
  TextEditingController barcodeHeight = TextEditingController();
  TextEditingController lineWidthVar = TextEditingController();
  TextEditingController pageWidth = TextEditingController();
  TextEditingController pageHeight = TextEditingController();
  TextEditingController printerCtl = TextEditingController(text: 'EPM205');
  TextEditingController printDirectionCtl =
      TextEditingController(text: 'Forward');

  var count = 0;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;

  final FocusNode _focusNodeContent = FocusNode();
  final FocusNode _focusNodeFontSize = FocusNode();
  final FocusNode _focusNodexPos = FocusNode();
  final FocusNode _focusNodeyPos = FocusNode();
  final FocusNode _focusNodemaxLenth = FocusNode();
  final FocusNode _focusbarcodeHeght = FocusNode();
  final FocusNode _focusNodex2Pos = FocusNode();
  final FocusNode _focusNodey2Pos = FocusNode();
  final FocusNode _focusNodelineWidth = FocusNode();

  String _sltPrtName = 'EPM205';
  String _selectedAlignment = 'Left';
  String _selectedBarcode = '--';
  String _selectedQrcode = '--';
  String _selectedRotation = '0';
  late List<String> _savedBarCodeNames = ['--'];
  late List<String> _savedQrcodeNames = ['--'];
  String _selectedHRAlignment = 'Bottom';
  String _selectedQr = '3';
  String _selectedPrintDirection = 'Forward';
  String _selectFontBold = 'false';
  String _selectFontReverse = 'false';
  bool downloadStatus = true;
  String _selectFontsize = '23';
  double myPageWidth = 0;
  double myPageHeight = 0;
  // final _lineList = [];

  List<String> paths = [];
  List<DataRow> dataRows = [];

  final List<String> _printers = [
    'EPM205',
    'ZEBRA',
  ];
  final List<String> _printDirections = [
    'Forward',
    'Backward',
  ];
  final List<String> _fontBoldReverse = [
    'true',
    'false',
  ];
  final List<String> _rotations = [
    '0',
    '90',
    '180',
    '270',
  ];
  final List<String> _alignments = [
    'Left',
    'Center',
    'Right',
  ];
  final List<String> _hralignments = [
    'None',
    'Bottom',
    'Top',
  ];
  final List<String> _qrWidths = [
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];

  final List<String> _fontSizes = [
    // '20', //1 1 1   中文不支持
    '20',
    '21',
    '23', //4 1 1
    // '39', //1 2 2   中文不支持
    '46', //4 2 2
    '69', //4 3 3
    '95', //4 4 4
    '115', //4 5 5
    '137', //4 6 6
    '165', //4 7 7
    '170', //4 8 8
  ];
  Map<String, String> langVarMap = {};
  Map<String, String> langVarExplMap = {};

  String systemId = '';

  @override
  void initState() {
    addfloatbutton(name); //暂时屏蔽掉
    textItemList;
    textvariable.text = myTextData.content;
    xPosvar.text = myTextData.xPos.toString();
    yPosvar.text = myTextData.yPos.toString();
    x2Posvar.text = myTextData.x2Pos.toString();
    y2Posvar.text = myTextData.y2Pos.toString();
    pageWidth.text = '55';
    pageHeight.text = '50';
    myPageWidth = 440;
    myPageHeight = 400;
    barcodeDataReload();
    openTemplateJson();

    _eventbus1 = eventBus.on<EventText>().listen((event) {
      if (mounted) {
        setState(() {
          myTextData = event.obj;
          textvariable.text = myTextData.content;
          fontsizevar.text = myTextData.fontSize.toString();
          barcodeHeight.text = myTextData.height.toString();
          _selectedRotation = myTextData.rotation.toString();
          _selectedBarcode = myTextData.barcodeName;
          _selectedQrcode = myTextData.qrcodeName;
          _selectFontsize = myTextData.fontSize.toString();
          _selectedQr = int.parse(myTextData.qrWidth.toString()).toString();
          if (myTextData.alignment == 1) {
            _selectedAlignment = 'Left';
          } else if (myTextData.alignment == 2) {
            _selectedAlignment = 'Center';
          } else if (myTextData.alignment == 3) {
            _selectedAlignment = 'Right';
          }
          _selectFontBold = myTextData.fontBold;
          _selectFontReverse = myTextData.fontReverse;
          _selectedHRAlignment = myTextData.hralignment;
        });
      }
    });
    _eventbus2 = eventBus.on<EventOffset>().listen((event) {
      if (mounted) {
        setState(() {
          myOffsetData = event.obj;
          xPosvar.text = myOffsetData.x.toString();
          yPosvar.text = myOffsetData.y.toString();
          // _onSubmit(xPosvar.text.toString(), 2);
          // _onSubmit(yPosvar.text.toString(), 3);
          if (textItemList.isNotEmpty) {
            for (var i = 0; i < textItemList.length; i++) {
              if (textItemList[i].key == myOffsetData.key) {
                textItemList[i].xPos = myOffsetData.x.toInt();
                textItemList[i].yPos = myOffsetData.y.toInt();
                myTextData.tabOrder = textItemList[i].index;
                myTextData.type = textItemList[i].type;
                myTextData.xPos = textItemList[i].xPos;
                myTextData.yPos = textItemList[i].yPos;
                myTextData.height = textItemList[i].height;
                myTextData.width = textItemList[i].width;
                myTextData.style = textItemList[i].style;
                myTextData.fontWidthRatio = textItemList[i].fontWidthRatio;
                myTextData.fontHeightRatio = textItemList[i].fontHeightRatio;
                myTextData.fontSize = textItemList[i].fontSize;
                myTextData.maxLength = textItemList[i].maxLength;
                myTextData.alignment = textItemList[i].alignment;
                myTextData.content = textItemList[i].content;
                myTextData.varcontent = textItemList[i].varcontent;
                myTextData.defaultValue = textItemList[i].defaultValue;
                myTextData.rotation = textItemList[i].rotation;
                myTextData.varName = textItemList[i].varName;
                myTextData.hralignment = textItemList[i].hralignment;
                myTextData.x2Pos = textItemList[i].x2Pos;
                myTextData.y2Pos = textItemList[i].y2Pos;
                myTextData.lineWidth = textItemList[i].lineWidth;
                myTextData.qrWidth = textItemList[i].qrWidth;
                myTextData.barcodeName = textItemList[i].barcodeName;
                myTextData.barcodeType = textItemList[i].barcodeType;
                myTextData.qrcodeName = textItemList[i].qrcodeName;
                myTextData.qrcodeType = textItemList[i].qrcodeType;
                myTextData.fontBold = textItemList[i].fontBold;
                myTextData.fontReverse = textItemList[i].fontReverse;

                mySelectedControl.selectid = myTextData.tabOrder;
                mySelectedControl.isSelect = true;
                eventBus.fire(EventSelectedControl(mySelectedControl));
                eventBus.fire(EventText(myTextData));
                break;
              }
            }
          }
        });
      }
    });

    _eventbus3 = eventBus.on<EventSavedBarcodeName>().listen((event) {
      if (mounted) {
        setState(() {
          mySavedBarcodeName = event.obj;
          _savedBarCodeNames = mySavedBarcodeName.savedBarcodeName;
          if (_savedBarCodeNames.isNotEmpty) {
            _selectedBarcode =
                _savedBarCodeNames[_savedBarCodeNames.length - 1];
          } else {
            _savedBarCodeNames = ['--'];
            _selectedBarcode =
                _savedBarCodeNames[_savedBarCodeNames.length - 1];
          }
        });
      }
    });

    _eventbus4 = eventBus.on<EventCurrentBarCodeRowDataList>().listen((event) {
      if (mounted) {
        setState(() {
          myBarCodeRowDataList = event.obj;
        });
      }
    });

    _eventbus5 = eventBus.on<EventSavedQrcodeName>().listen((event) {
      if (mounted) {
        setState(() {
          mySavedQrcodeName = event.obj;
          _savedQrcodeNames = mySavedQrcodeName.savedQrcodeName;
          if (_savedQrcodeNames.isNotEmpty) {
            _selectedQrcode = _savedQrcodeNames[_savedQrcodeNames.length - 1];
          } else {
            _savedQrcodeNames = ['--'];
            _selectedQrcode = _savedQrcodeNames[_savedQrcodeNames.length - 1];
          }
        });
      }
    });

    _focusNodeContent.addListener(() {
      if (!_focusNodeContent.hasFocus) {
        _onSubmit(textvariable.text, 0);
      }
    });
    _focusNodeFontSize.addListener(() {
      if (!_focusNodeFontSize.hasFocus) {
        _onSubmit(fontsizevar.text, 1);
      }
    });
    _focusNodexPos.addListener(() {
      if (!_focusNodexPos.hasFocus) {
        _onSubmit(xPosvar.text, 2);
      }
    });
    _focusNodeyPos.addListener(() {
      if (!_focusNodeyPos.hasFocus) {
        _onSubmit(yPosvar.text, 3);
      }
    });
    _focusNodex2Pos.addListener(() {
      if (!_focusNodex2Pos.hasFocus) {
        _onSubmit(x2Posvar.text, 9);
      }
    });
    _focusNodey2Pos.addListener(() {
      if (!_focusNodey2Pos.hasFocus) {
        _onSubmit(y2Posvar.text, 10);
      }
    });
    _focusNodemaxLenth.addListener(() {
      if (!_focusNodemaxLenth.hasFocus) {
        _onSubmit(maxLenthvar.text, 4);
      }
    });

    _focusbarcodeHeght.addListener(() {
      if (!_focusbarcodeHeght.hasFocus) {
        _onSubmit(barcodeHeight.text, 7);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    ScrollController scrollController = ScrollController();
    ScrollController scrollController1 = ScrollController();
    return Scaffold(
        body: Container(
            width: width,
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.type == "app")
                  pageHeadInfo(
                      context,
                      width - headWidthPadding,
                      localizedStrings.menuLabelDesign,
                      localizedStrings.gTipLabelDesignPageHelp),
                Expanded(
                    child: SizedBox(
                  height: height - topTitleHeight,
                  child: Column(
                    children: [
                      showHeadWidget(width),
                      Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      SizedBox(
                        height: height - topTitleHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //左侧变量部分
                            SizedBox(
                              width: leftBtnWidth,
                              child: ListView(
                                children: _buildList(),
                              ),
                            ),
                            //中间画布部分
                            showMiddleLabel(
                                scrollController, scrollController1),
                            //右侧属性部分
                            Container(
                                width: rightBtnWidth,
                                alignment: Alignment.topLeft,
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: showAttributePart()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
              ],
            )));
  }

  Widget showHeadWidget(double width) {
    return Container(
      height: topBtnHeight,
      width: width - 10,
      color: Theme.of(context).colorScheme.onPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            child: Row(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(
                                localizedStrings.gPrinter,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 150, // 设置固定宽度
                              child: showDropDownButton(
                                  context, '', printerCtl, _printers,
                                  (String? newValue) {
                                setState(() {
                                  _sltPrtName = newValue!;
                                  printerCtl.text = newValue;
                                });
                              }),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(
                                localizedStrings.gPrintDirection,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 150, // 设置固定宽度
                              child: showDropDownButton(
                                  context,
                                  '',
                                  printDirectionCtl,
                                  _printDirections, (String? newValue) {
                                setState(() {
                                  _selectedPrintDirection = newValue!;
                                  printDirectionCtl.text = newValue;
                                });
                              }),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            buildBtnText(localizedStrings.gPageWidth + '(mm):'),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 80, // 设置固定宽度
                                height: 48,
                                child: showInputBox(context, pageWidth, '',
                                    (value) {
                                  setState(() {});
                                }, true))
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            buildBtnText(
                                localizedStrings.gPageHeight + '(mm):'),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 80, // 设置固定宽度
                                height: 48,
                                child: showInputBox(context, pageHeight, '',
                                    (value) {
                                  setState(() {});
                                }, true))
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: btnWidth,
                      height: 40,
                    ),
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gBtnNewFormat, () {
                          deleteAllItem();
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary)),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gBarcodeEdit,
                            () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const MyBarCodeDialog();
                            },
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                // rowDataList = value;
                              });
                            }
                          });
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary)),
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gOpenJson, () async {
                          String filePath = '';
                          try {
                            String executablePath = Platform.resolvedExecutable;
                            var directory = p.dirname(executablePath);

                            final formatfilePath =
                                Directory('$directory\\format');
                            if (!await formatfilePath.exists()) {
                              await formatfilePath.create(recursive: true);
                            }
                            directory = formatfilePath.path;
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              initialDirectory: directory,
                              type: FileType.custom,
                              allowedExtensions: ['json'],
                            );
                            if (result != null && result.files.isNotEmpty) {
                              filePath = result.files.single.path!;
                            }
                          } catch (e) {
                            setState(() {
                              showTipInfo('Open fail', context);
                            });
                          }
                          if (filePath != '') {
                            deleteAllItem();
                            _openJsonFile(filePath);
                          }
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary)),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gQrcodeEdit,
                            () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const MyQrcodeDialog();
                            },
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                // rowDataList = value;
                              });
                            }
                          });
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary)),
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gSaveFormat,
                            () async {
                          String executablePath = Platform.resolvedExecutable;
                          var directory = p.dirname(executablePath);
                          final formatfilePath =
                              Directory('$directory\\format');
                          if (!await formatfilePath.exists()) {
                            await formatfilePath.create(recursive: true);
                          }
                          directory = formatfilePath.path;

                          String? outputFile =
                              (await FilePicker.platform.saveFile(
                            initialDirectory: directory,
                            dialogTitle: 'Output file:',
                            type: FileType.custom,
                            allowedExtensions: ['fmt'],
                            fileName: 'format.fmt',
                          ));
                          if (outputFile != null) {
                            if (!outputFile.contains(".fmt")) {
                              outputFile = "$outputFile.fmt";
                            }
                            _exportCSV();
                            _saveFormatToCsv(csv, outputFile);

                            ///保存数据到csv
                            String jsonFilePath =
                                outputFile.replaceAll('.fmt', '.json');
                            _saveFormatToJson(jsonFilePath); //同时保存一份到json
                          }
                          ////添加实现
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context)
                                .colorScheme
                                .onTertiaryFixedVariant,
                            Theme.of(context).colorScheme.onPrimary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showMiddleLabel(
      ScrollController? scrollController, ScrollController? scrollController1) {
    return Expanded(
      child: Scrollbar(
        controller: scrollController,
        trackVisibility: true,
        child: ScrollConfiguration(
          // 为水平滚动添加自定义行为
          behavior: _ScrollbarOnlyScrollBehavior(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            child: Container(
              padding: const EdgeInsets.all(10),
              width: 1700,
              height: 1000,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                border: Border.all(
                  width: 0.2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              child: ScrollConfiguration(
                // 为垂直滚动添加自定义行为
                behavior: _ScrollbarOnlyScrollBehavior(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: scrollController1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: _getPageWidth(),
                        height: _getPageHeight(),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          border: Border.all(
                            width: 0.5,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          key: _parentKey,
                          children: [
                            ...floatButtonList,
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget showMiddleLabel(
  //     ScrollController? scrollController, ScrollController? scrollController1) {
  //   return Expanded(
  //     child: Scrollbar(
  //       controller: scrollController,
  //       trackVisibility: true,
  //       child: SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         controller: scrollController,
  //         child: Container(
  //           padding: const EdgeInsets.all(10),
  //           width: 1700,
  //           height: 1000,
  //           decoration: BoxDecoration(
  //               color: Theme.of(context).colorScheme.surfaceBright,
  //               border: Border.all(
  //                   width: 0.2,
  //                   color: Theme.of(context).colorScheme.onSurface)),
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.vertical, // 水平滚动
  //             controller: scrollController1,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               children: [
  //                 Container(
  //                   //60mmX60
  //                   width: _getPageWidth(),
  //                   height: _getPageHeight(),
  //                   decoration: BoxDecoration(
  //                       color: Theme.of(context).colorScheme.onPrimary,
  //                       border: Border.all(
  //                           width: 0.5,
  //                           color: Theme.of(context).colorScheme.onSurface)),
  //                   child: Stack(
  //                     clipBehavior: Clip.none,
  //                     key: _parentKey,
  //                     children: [
  //                       ...floatButtonList,
  //                       // _buildLines(),//屏蔽横线
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget showAttributePart() {
    return Container(
      width: 260,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ListView(
        children: (myTextData.tabOrder == 9999)
            ? _selectItem()
            : (myTextData.type == 'TEXT')
                ? _textproperties()
                : (myTextData.type == 'DATA')
                    ? _varproperties()
                    : (myTextData.type == 'BarCode')
                        ? _barCodeproperties()
                        : (myTextData.type == 'Line')
                            ? _lineproperties()
                            : (myTextData.type == 'Qrcode')
                                ? _qrcodeproperties()
                                : _textproperties(),
      ),
    );
  }

  Widget buildBtnText(String textStr) {
    return SizedBox(
      width: textWidth,
      child: Text(
        textStr,
        textAlign: TextAlign.right,
        style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  ButtonStyle buildBtnStyle() {
    return OutlinedButton.styleFrom(
      side: BorderSide(
        width: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
      foregroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.onPrimary, // 设置按钮的背景色
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
      ),
    );
  }

  void openTemplateJson() async {
    final ByteData bytes = await rootBundle.load('assets/template/label.json');
    // 将 ByteData 直接转换为 JSON 字符串
    final jsonString = bytes.buffer.asUint8List();
    final jsonData = utf8.decode(jsonString);

    deleteAllItem();
    readTextInfoListFromStr(jsonData);
  }

  Future pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
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
        for (var i = 0; i < paths.length; i++) {
          dataRows.add(
            DataRow(
              cells: [
                DataCell(
                  Text(
                    "File${i + 1}",
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
      });
    }
  }

  // Widget _buildLines() {
  //   return Stack(
  //     children: [
  //       for (var i = 0; i < _lineList.length; i++)
  //         _buildLine(i, _lineList[i].start, _lineList[i].end),
  //     ],
  //   );
  // }

  // void _updatePosition(PointerMoveEvent pointerMoveEvent) {
  //   double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
  //   double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

  //   setState(() {
  //     _offset = Offset(newOffsetX, newOffsetY);
  //   });
  // }

  // Widget _buildLine(int index, Offset start, Offset end) {
  //   _offset = start;

  //   return Stack(children: [
  //     Positioned(
  //       left: _offset.dy,
  //       top: _offset.dx, // start.dy, //math.min(start.dy, end.dy),
  //       //start.dx, //math.min(start.dx, end.dx),
  //       // right: end.dy,
  //       // bottom: end.dx,
  //       width: (start - end).distance,
  //       height: 50.0,
  //       child: Listener(
  //         onPointerMove: (PointerMoveEvent pointerMoveEvent) {
  //           _updatePosition(pointerMoveEvent);

  //           setState(() {
  //             _isDragging = true;
  //           });
  //         },
  //         onPointerUp: (PointerUpEvent pointerUpEvent) {
  //           var dx = (pointerUpEvent.delta.dx.toInt()).roundToDouble();
  //           var dy = ((pointerUpEvent.delta.dy).toInt()).roundToDouble();
  //           final line = _lineList[index];
  //           setState(() {
  //             _lineList[index] = Line(_offset, line.end + Offset(dx, dy));
  //           });

  //           if (_isDragging) {
  //             setState(() {
  //               _isDragging = false;
  //             });
  //           } else {}
  //         },
  //         child: CustomPaint(
  //           painter: LinePainter(
  //               startPoint: _lineList[index].start,
  //               endPoint: _lineList[index].end),
  //         ),
  //       ),
  //     ),

  //     // angle: 0, //math.atan2(end.dy - start.dy, end.dx - start.dx),
  //   ]);
  // }

  // void _onLineDragged(int index, DragUpdateDetails details) {
  //   setState(() {
  //     final line = _lineList[index];
  //     if ((_getPageWidth() < (line.start.dx + details.delta.dx)) ||
  //         _getPageHeight() - 10 < (line.end.dy + details.delta.dy) ||
  //         _getPageWidth() < (line.end.dx + details.delta.dx) ||
  //         _getPageHeight() - 10 < (line.start.dy + details.delta.dy) ||
  //         (0 > (line.start.dx + details.delta.dx)) ||
  //         0 > (line.end.dy + details.delta.dy) ||
  //         0 > (line.end.dx + details.delta.dx) ||
  //         0 > (line.start.dy + details.delta.dy)) {
  //       return;
  //     }
  //     var _tmpOffsetDx = ((details.delta.dx).toInt()).roundToDouble();
  //     var _tmpOffsetDy = ((details.delta.dy).toInt()).roundToDouble();
  //     Offset tmpOffset = Offset(_tmpOffsetDx, _tmpOffsetDy);
  //     _lineList[index] = Line(line.start + tmpOffset, line.end + tmpOffset);
  //   });
  // }

  // void _onCircleDragged(
  //     int index, Offset oldPosition, Offset newPosition, int circleIndex) {
  //   setState(() {
  //     final line = _lineList[index];
  //     if ((_getPageWidth() < (newPosition.dx)) ||
  //         _getPageHeight() - 10 < (newPosition.dy) ||
  //         (0 > (newPosition.dx)) ||
  //         0 > (newPosition.dy)) {
  //       return;
  //     }
  //     var _tmpOffsetDx = ((newPosition.dx).toInt()).roundToDouble();
  //     var _tmpOffsetDy = ((newPosition.dy).toInt()).roundToDouble();
  //     Offset tmpOffset = Offset(_tmpOffsetDx, _tmpOffsetDy);

  //     if (circleIndex == 1) {
  //       _lineList[index] = Line(line.start, tmpOffset);
  //     } else {
  //       _lineList[index] = Line(tmpOffset, line.end);
  //     }
  //   });
  // }

  String pad0(int num) {
    if (num < 10) {
      return '0${num.toString()}';
    }
    return num.toString();
  }

  String getDateTime() {
    // 1 yymmdd   2 ddmmyy 3 mmddyy
    var currTime = DateTime.now();
    String format = '';

    format =
        "${currTime.year}${pad0(currTime.month)}${pad0(currTime.day)}${pad0(currTime.hour)}${pad0(currTime.minute)}${pad0(currTime.second)}";

    return format;
  }

  double _getPageWidth() {
    if (pageWidth.text.isEmpty) {
      return 0;
    }

    if (_sltPrtName == "EPM205") {
      double? d = double.tryParse(pageWidth.text);
      if (d != null) {
        myPageWidth = d * 8;
        if (myPageWidth > 1600) {
          myPageWidth = 1600;
          pageWidth.text = '200';
        }
        x2Pos = myPageWidth.toInt();
        return myPageWidth;
      }
      return 0;
    } else if (_sltPrtName == "ZEBRA") {
      double? d = double.tryParse(pageWidth.text);
      if (d != null) {
        myPageWidth = d * 8;
        if (myPageWidth > 1600) {
          myPageWidth = 1600;
          pageWidth.text = '200';
        }
        x2Pos = myPageWidth.toInt();
        return myPageWidth;
      }
      return 0;
    } else {
      return 0;
    }
  }

  double _getPageHeight() {
    if (pageHeight.text.isEmpty) {
      return 0;
    }

    if (_sltPrtName == "EPM205") {
      double? d = double.tryParse(pageHeight.text);
      if (d != null) {
        myPageHeight = d * 8;
        if (myPageHeight > 1600) {
          myPageHeight = 1600;
          pageHeight.text = '200';
        }
        return myPageHeight;
      }
      return 0;
    } else if (_sltPrtName == "ZEBRA") {
      double? d = double.tryParse(pageHeight.text);
      if (d != null) {
        myPageHeight = d * 8;
        if (myPageHeight > 1600) {
          myPageHeight = 1600;
          pageHeight.text = '200';
        }
        return myPageHeight;
      }
      return 0;
    } else {
      return 0;
    }
  }

  void sendFormatToScale(String modifyString) async {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    myScaleCmd.cmdData = modifyString;
    PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  int _getRotation(int rotation) {
    if (rotation == 90) {
      return 1;
    } else if (rotation == 180) {
      return 2;
    } else if (rotation == 270) {
      return 3;
    } else {
      return 0;
    }
  }

  String _getstyle(String fontBold, String fontReverse) {
    if (fontBold == 'true' && fontReverse == 'false') {
      return '2';
    } else if (fontBold == 'true' && fontReverse == 'true') {
      return '3';
    } else if (fontBold == 'false' && fontReverse == 'true') {
      return '1';
    } else {
      return '0';
    }
  }

  List getFontSize(int sFont) {
    int fontsize = 4;
    int width = 1;
    int height = 1;
    if (sFont == 23) {
      fontsize = 4;
    } else if (sFont == 20) {
      fontsize = 1;
    } else if (sFont == 39) {
      fontsize = 1;
      width = 2;
      height = 2;
    } else if (sFont == 46) {
      fontsize = 4;
      width = 2;
      height = 2;
    } else if (sFont == 69) {
      fontsize = 4;
      width = 3;
      height = 3;
    } else if (sFont == 95) {
      width = 4;
      height = 4;
    } else if (sFont == 115) {
      fontsize = 4;
      width = 5;
      height = 5;
    } else if (sFont == 137) {
      width = 6;
      height = 6;
    } else if (sFont == 165) {
      width = 7;
      height = 7;
    } else if (sFont == 170) {
      width = 8;
      height = 8;
    }

    return [fontsize, width, height];
  }

  //  List vals = getFontSize(); print("${vals[0]} ${vals[1]} ${vals[2]}");
  String csv = "";
  void _exportCSV() async {
    // var path = 'C:\\Users\\Test-Team\\Desktop\\text1111';
    List<List<dynamic>> csvData = <List<dynamic>>[];
    // csvData.add(['Time', 'Name']);
    //打印正向或者反向
    if (_selectedPrintDirection == 'Forward') {
      csvData.add(['ROTATE', '0']);
    } else {
      csvData.add(['ROTATE', '2']);
    }
    //打印纸张大小
    csvData.add(['P', myPageWidth, myPageHeight]);
    // csvData.add(['R', '147', '124', '247', '184', '2', '0', '0']);
    // csvData.add(['L', '147', '124', '247', '184', '2', '0', '0']);

    for (var i = 0; i < textItemList.length; i++) {
      if (textItemList[i].type == 'TEXT') {
        List fontlist = getFontSize(textItemList[i].fontSize);
        csvData.add([
          'TB',
          textItemList[i].xPos,
          textItemList[i].yPos,
          textItemList[i].width,
          textItemList[i].height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(textItemList[i].fontBold, textItemList[i].fontReverse),
          _getRotation(textItemList[i].rotation),
          textItemList[i].type,
          textItemList[i].content,
          textItemList[i].index,
        ]);
      } else if (textItemList[i].type == 'DATA') {
        List fontlist = getFontSize(textItemList[i].fontSize);
        csvData.add([
          'TB',
          textItemList[i].xPos,
          textItemList[i].yPos,
          textItemList[i].width,
          textItemList[i].height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(textItemList[i].fontBold, textItemList[i].fontReverse),
          _getRotation(textItemList[i].rotation),
          textItemList[i].type,
          textItemList[i].varName,
          textItemList[i].defaultValue,
          textItemList[i].alignment,
          textItemList[i].maxLength,
          textItemList[i].index,
        ]);
      } else if (textItemList[i].type == 'BarCode') {
        String tempContent = '';
        if (textItemList[i].style == 0) {
          tempContent = _barcodeContent(textItemList[i].varcontent);
        } else {
          tempContent = _barcodeContent1(textItemList[i].varcontent);
        }
        String barcodeType = '';
        String hrAlignment;
        if (textItemList[i].barcodeType == 'Code128') {
          barcodeType = '1';
        } else if (textItemList[i].barcodeType == 'Code39') {
          barcodeType = 'CODE39';
        } else if (textItemList[i].barcodeType == 'EAN8') {
          barcodeType = 'EAN8';
        } else if (textItemList[i].barcodeType == 'EAN13') {
          barcodeType = 'EAN13';
        } else if (textItemList[i].barcodeType == 'UPC-A') {
          barcodeType = 'UPCA';
        } else if (textItemList[i].barcodeType == 'UPC-E') {
          barcodeType = 'UPCE';
        }
        if (textItemList[i].hralignment == 'Top') {
          hrAlignment = 'TC';
        } else if (textItemList[i].hralignment == 'Bottom') {
          hrAlignment = 'BC';
        } else {
          hrAlignment = 'N';
        }
        csvData.add([
          'B',
          textItemList[i].xPos,
          textItemList[i].yPos,
          textItemList[i].width,
          textItemList[i].height,
          '2',
          barcodeType,
          _getRotation(textItemList[i].rotation),
          hrAlignment,
          tempContent,
          textItemList[i].index,
        ]);
      } else if (textItemList[i].type == 'Qrcode') {
        String tempContent = '';
        if (textItemList[i].style == 0) {
          tempContent = _barcodeContent(textItemList[i].varcontent);
        } else {
          tempContent = _barcodeContent1(textItemList[i].varcontent);
        }

        String version = '1';
        String errorlevel = '1';

        csvData.add([
          'QR',
          textItemList[i].xPos,
          textItemList[i].yPos,
          version,
          textItemList[i].qrWidth.toString(),
          errorlevel,
          '',
          tempContent,
          textItemList[i].index,
        ]);
      } else if (textItemList[i].type == 'Line') {
        if (textItemList[i].lineWidth <= textItemList[i].x2Pos) {
          csvData.add([
            'L',
            textItemList[i].xPos,
            textItemList[i].yPos,
            (textItemList[i].x2Pos + textItemList[i].xPos).toInt(),
            textItemList[i].yPos,
            textItemList[i].lineWidth.toInt(),
            0, //线类型
            textItemList[i].index,
          ]);
        } else {
          csvData.add([
            'L',
            textItemList[i].xPos,
            textItemList[i].yPos,
            textItemList[i].xPos,
            (textItemList[i].lineWidth + textItemList[i].yPos).toInt(),
            textItemList[i].x2Pos.toInt(),
            0, //线类型
            textItemList[i].index,
          ]);
        }
      }
    }
    csvData.add(['F', _sltPrtName, 'L']);
    csvData.add(['']);
    csv = const ListToCsvConverter(
      textDelimiter: '',
    ).convert(csvData);
  }

  // Future<File> get _localFilepath async {
  //   final directory = p.dirname(Platform.script.toFilePath());
  //   return File(p.join(directory, 'fromatdata.json'));
  // }

  _saveFormatDataToJson(List list, String path) async {
    try {
      if (list.isNotEmpty) {
        String json = jsonEncode(list);
        // print(json);

        FormatContent myFormatContent = FormatContent(
            page: '${pageWidth.text}*${pageHeight.text}',
            rotation: _selectedPrintDirection,
            content: json,
            printer: _sltPrtName,
            prtType: 'L');

        String formatjson = jsonEncode(myFormatContent);

        // final file = await _localFilepath; ///////获取固定位置
        final file = File(p.join(path));
        // 将字符串写入文件中
        file.writeAsStringSync(formatjson);

        // await loadData();   此处已经写好了如何捞回来条码信息
      }
    } catch (e) {
      setState(() {
        showTipInfo('$e Save fail', context);
      });
    }
  }

  // 读取本地文件中的文本框信息
  Future readTextInfoListFromFile(String path) async {
    try {
      var file = File(p.join(path)); //await _localFilepath;
      String jsonString = await file.readAsString();
      readTextInfoListFromStr(jsonString);
    } catch (e) {
      if (mounted && context.mounted) {
        showTipInfo(e.toString(), context);
      }
    }
  }

  // 读取本地文件中的文本框信息
  Future readTextInfoListFromStr(String dataStr) async {
    List textInfoList = [];
    try {
      FormatContent fromatContent = FormatContent.fromJson(jsonDecode(dataStr));
      if (fromatContent.prtType != null && fromatContent.prtType == 'P') {
        showTipInfo(localizedStrings.l_open_fmt_err, context);

        return;
      }
      setState(() {
        List<String> sizes = fromatContent.page.split('*');

        if (sizes.length == 2) {
          String num1 = sizes[0];
          String num2 = sizes[1];
          pageWidth.text = num1;
          pageHeight.text = num2;
        }

        bool hasPrint =
            _printers.any((element) => element == fromatContent.printer);
        if (hasPrint) {
          _sltPrtName = fromatContent.printer.toString();
          printerCtl.text = _sltPrtName;
        }

        if (_printDirections.contains(fromatContent.rotation)) {
          _selectedPrintDirection = fromatContent.rotation;
          printDirectionCtl.text = _selectedPrintDirection;
        }
      });
      // String jsonItemString = jsonDecode(fromatContent.content);
      List jsonList = jsonDecode(fromatContent.content);
      for (var json in jsonList) {
        FromateItemData formData = FromateItemData.fromJson(json);
        textInfoList.add(formData);
      }
      if (textInfoList.isNotEmpty) {
        redrawInterface(textInfoList);
      }
    } catch (e) {
      showTipInfo(e.toString(), context);
    }
    return textInfoList;
  }

  void deleteAllItem() {
    setState(() {
      textItemList.clear();
      myItemKey.keyList.clear();
      num.clear();
      count = 0;
      floatButtonList.clear();
      _parentKey = GlobalKey();
    });
  }

  void redrawInterface(List list) {
    setState(() {
      for (var i = 0; i < list.length; i++) {
        // temptextItemList[i].index = i;
        FromateItemData formData = list[i];
        num.add(i);
        count = num.length;

        textItemList.add(TextItem(
          key: ObjectKey(i),
          index: (i),
          content: formData.content,
          type: formData.type,
          xPos: formData.xPos,
          yPos: formData.yPos,
          width: formData.width,
          height: formData.height,
          fontSize: formData.fontSize,
          fontWidthRatio: formData.fontWidthRatio,
          fontHeightRatio: formData.fontHeightRatio,
          style: 1,
          rotation: formData.rotation,
          defaultValue: formData.defaultValue,
          alignment: formData.alignment,
          maxLength: formData.maxLength,
          tabOrder: formData.tabOrder,
          varName: formData.varName,
          varcontent: formData.varcontent,
          barcodeName: '--',
          barcodeType: formData.barcodeType,
          hralignment: formData.hralignment,
          x2Pos: formData.x2Pos,
          y2Pos: formData.y2Pos,
          lineWidth: formData.lineWidth,
          qrWidth: formData.qrWidth,
          qrcodeName: '--',
          qrcodeType: formData.qrcodeType,
          fontBold: formData.fontBold,
          fontReverse: formData.fontReverse,
        ));
        //中间页面添加最新的可拖拽控件
        floatButtonList.add(DraggableFloatingActionButton(
            index: (textItemList[i].index),
            key: textItemList[i].key,
            initialOffset: Offset(textItemList[i].xPos.toDouble(),
                textItemList[i].yPos.toDouble()),
            parentKey: _parentKey,
            onPressed: () {},
            children: [textItemList[i]]));
      }
    });
    reconstructItem();
  }

  void _saveFormatToJson(String path) {
    List formatDataList = [];
    for (var i = 0; i < textItemList.length; i++) {
      FromateItemData formatdata = FromateItemData(
        type: textItemList[i].type,
        xPos: textItemList[i].xPos,
        yPos: textItemList[i].yPos,
        width: textItemList[i].width,
        height: textItemList[i].height,
        fontSize: textItemList[i].fontSize,
        fontWidthRatio: textItemList[i].fontWidthRatio,
        fontHeightRatio: textItemList[i].fontHeightRatio,
        alignment: textItemList[i].alignment,
        maxLength: textItemList[i].maxLength,
        rotation: textItemList[i].rotation,
        style: textItemList[i].style,
        tabOrder: textItemList[i].tabOrder,
        varName: textItemList[i].varName,
        content: textItemList[i].content,
        defaultValue: textItemList[i].defaultValue,
        varcontent: textItemList[i].varcontent,
        barcodeName: textItemList[i].barcodeName,
        barcodeType: textItemList[i].barcodeType,
        hralignment: textItemList[i].hralignment,
        x2Pos: textItemList[i].x2Pos,
        y2Pos: textItemList[i].y2Pos,
        lineWidth: textItemList[i].lineWidth,
        qrWidth: textItemList[i].qrWidth,
        qrcodeName: textItemList[i].qrcodeName,
        qrcodeType: textItemList[i].qrcodeType,
        fontBold: textItemList[i].fontBold,
        fontReverse: textItemList[i].fontReverse,
      );
      formatDataList.add(formatdata);
    }

    _saveFormatDataToJson(formatDataList, path);
  }

  void _saveFormatToCsv(String csv, String path) async {
    final file = File(path);
    csv = myFilePassword.encryptCsv(csv);
    await file.writeAsString(csv, mode: FileMode.write, encoding: utf8);
  }

  // void _saveFormatToCsv(String csv) async {
  //   final directory = Directory.current.path;
  //   final file = File('$directory\\data.csv');
  //   await file.writeAsString(csv);
  // }
//utf8字符串转GB2312编码
  List<int> stringToGb2312Bytes(String str) {
    var encoder = gbk.encode(str);
    return encoder.toList();
  }

  List<int> convertList(List<int> inputList) {
    var resultList = <int>[];
    for (var i = 0; i < inputList.length; i++) {
      var value = (inputList[i] >> 8) & 0xFF;
      if (value != 0) {
        resultList.add(value);
      }
      value = (inputList[i] & 0xFF);
      resultList.add(value);
    }
    return resultList;
  }

// 在GBK编码数据开头添加BOM标记
  List<int> addGbkBom(List<int> gbkData) {
    final bom = [0xEF, 0xBB, 0xBF];
    return bom + gbkData;
  }

  void _openJsonFile(String path) {
    readTextInfoListFromFile(path);
  }

  // Future<void> _loadCsvData() async {
  //   List<List<dynamic>> _data = [];
  //   final directory = Directory.current.path;
  //   final csvString = await rootBundle.loadString('$directory\\data.csv');
  //   setState(() {
  //     _data = const CsvToListConverter().convert(csvString);
  //   });
  // }

  // Future _loadCsvData() async {
  //   List<List<dynamic>> _data = [];
  //   String csvFilePath = "G:\\Labeldesign\\t_label\\data.csv";
  //   try {
  //     // 获取文件夹路径
  //     Directory appDocDir = await getApplicationDocumentsDirectory(); // 加载文件内容
  //     File csvFile = File(csvFilePath);
  //     String csvString = await csvFile.readAsString(); // 解析 CSV 文件内容并提取数据
  //     _data = const CsvToListConverter().convert(csvString);
  //   } catch (e) {}
  // }

  String _barcodeContent(List<dynamic> con) {
    var barcodedata = StringBuffer();
    if (con.isEmpty) {
      return barcodedata.toString();
    }
    var varalignment = 1;
    for (var i = 0; i < con.length; i++) {
      if (barcodedata.isNotEmpty) {
        barcodedata.write(',');
      }
      if (con[i].type == 'TEXT') {
        barcodedata.write('${con[i].type},${con[i].content}');
      } else {
        if (con[i].alignment == 'Center') {
          varalignment = 2;
        } else {
          varalignment = 3;
        }
        barcodedata.write(
            'DATA,${con[i].type},${con[i].defaultvalue},$varalignment,${con[i].maxlength}');
      }
    }
    return barcodedata.toString();
  }

//此处解析条码内容，本地不一定有此条码格式。都按没有此条码格式处理
  String _barcodeContent1(List<dynamic> con) {
    final barcodedata = StringBuffer(); // 使用 StringBuffer 来构建字符串
    if (con.isEmpty) {
      return barcodedata.toString();
    }
    for (final item in con) {
      if (barcodedata.isNotEmpty) {
        barcodedata.write(','); // 在前一个项目之后附加逗号分隔符
      }
      if (item['type'] == 'TEXT') {
        barcodedata.write('TEXT,${item['content']}');
      } else {
        var varalignment = 1;
        if (item['alignment'] == 'Center') {
          varalignment = 2;
        } else if (item['alignment'] == 'Right') {
          // 统一将未命中的情况视为 'Left'
          varalignment = 3;
        }
        barcodedata.write(
            'DATA,${item['type']},${item['defaultvalue']},$varalignment,${item['maxlength']}');
      }
    }
    return barcodedata.toString();
  }

  /// 创建列表 , 每个元素都是一个 ExpansionTile 组件
  List<Widget> _buildList() {
    getLanguageVarMap();
    List<Widget> widgets = [];
    for (var key in labelVarMap.keys) {
      String keyStr = langVarMap[key]!;
      widgets.add(_generateExpansionTileWidget(keyStr, labelVarMap[key]));
    }
    return widgets;
  }

  /// 生成 ExpansionTile 组件 , children 是 List<Widget> 组件
  Widget _generateExpansionTileWidget(tittle, List<String>? names) {
    return ExpansionTile(
      title: Text(tittle,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.primary,
              )),
      children: names!.map((name) => _generateWidget(name)).toList(),
    );
  }

  /// 生成 ExpansionTile 下的 ListView 的单个组件
  Widget _generateWidget(name) {
    text = name.split(",")[0];
    type = name.split(",")[1];
    String expStr = "";
    if (langVarExplMap[text] != "") {
      expStr = langVarExplMap[text]!;
    }
    if (langVarMap[text] != "") {
      text = langVarMap[text]!;
    }

    /// 使用该组件可以使宽度撑满
    return FractionallySizedBox(
        widthFactor: 1,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          height: 46,
          alignment: Alignment.center,
          child: Tooltip(
            message: expStr,
            preferBelow: false,
            verticalOffset: 10.0,
            waitDuration: const Duration(seconds: 1),
            child: TextButton(
                style: ButtonStyle(
                  side: WidgetStateProperty.all<BorderSide>(BorderSide(
                      width: 1,
                      color: Theme.of(context).colorScheme.outlineVariant)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
                onPressed: () {
                  count++;
                  num.add(count);
                  myTextData.tabOrder = count;
                  addfloatbutton(name);
                },
                child: Container(
                  width: 194, // 固定宽度
                  height: 36, // 固定高度

                  alignment: Alignment.center,
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                )),
          ),
        ));
  }

  void _onUpdate(int i) {
    textItemList.fillRange(
        i,
        i + 1,
        TextItem(
          key: textItemList[i].key,
          index: textItemList[i].index,
          xPos: textItemList[i].xPos,
          yPos: textItemList[i].yPos,
          width: textItemList[i].width,
          varName: textItemList[i].varName,
          tabOrder: textItemList[i].tabOrder,
          style: textItemList[i].style,
          rotation: textItemList[i].rotation,
          maxLength: textItemList[i].maxLength,
          height: textItemList[i].height,
          fontWidthRatio: textItemList[i].fontWidthRatio,
          fontSize: textItemList[i].fontSize,
          fontHeightRatio: textItemList[i].fontHeightRatio,
          defaultValue: textItemList[i].defaultValue,
          content: textItemList[i].content,
          alignment: textItemList[i].alignment,
          type: textItemList[i].type,
          varcontent: textItemList[i].varcontent,
          barcodeName: textItemList[i].barcodeName,
          barcodeType: textItemList[i].barcodeType,
          hralignment: textItemList[i].hralignment,
          x2Pos: textItemList[i].x2Pos,
          y2Pos: textItemList[i].y2Pos,
          lineWidth: textItemList[i].lineWidth,
          qrWidth: textItemList[i].qrWidth,
          qrcodeName: textItemList[i].qrcodeName,
          qrcodeType: textItemList[i].qrcodeType,
          fontBold: textItemList[i].fontBold,
          fontReverse: textItemList[i].fontReverse,
        ));

    floatButtonList.replaceRange(
      i,
      i + 1,
      [
        DraggableFloatingActionButton(
          key: textItemList[i].key,
          index: i,
          initialOffset: Offset(myOffsetData.x, myOffsetData.y),
          parentKey: _parentKey,
          onPressed: () {},
          children: [textItemList[i]],
        )
      ],
    );
    floatButtonList;
  }

  // 最后，在执行修改操作的方法中，需要将FocusNode设为失去焦点状态
  void _onSubmit(String s, int indexTemp) {
    // 执行修改操作
    if (indexTemp == 0) {
      //文本内容更新
      //文本框操作
      setState(() {
        myTextData.content = s.toString();
        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].content = myTextData.content;

            updateMytextData();
            //修改可拖拽控件的信息
            _onUpdate(i);
          }
        }
      });
      _focusNodeContent.unfocus();
    } else if (indexTemp == 1) {
      //字体大小
      RegExp regex =
          RegExp(r"^([1-9]|[1-9]\d|1\d{2}|2[0-4]\d|500)$"); //1-50限制大小
      if (regex.hasMatch(s)) {
        setState(() {
          myTextData.fontSize = int.tryParse(s.toString())!;
          for (var i = 0; i < textItemList.length; i++) {
            if (textItemList[i].index == myTextData.tabOrder) {
              textItemList[i].fontSize = myTextData.fontSize;
              updateMytextData();
              _onUpdate(i);
            }
          }
        });
      }
    } else if (indexTemp == 2) {
      //x坐标
      setState(() {
        var ss = double.parse(s.toString());
        myTextData.xPos = ss.toInt();

        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].xPos = myTextData.xPos;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 3) {
      //y坐标
      setState(() {
        var ss = double.parse(s.toString());
        myTextData.yPos = ss.toInt();

        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].yPos = myTextData.yPos;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 4) {
      //最大长度
      RegExp regex = RegExp(r"^(?:0|[1-9]\d?|100)$"); //1-50限制大小
      if (regex.hasMatch(s)) {
        setState(() {
          myTextData.maxLength = int.tryParse(s.toString())!;
          for (var i = 0; i < textItemList.length; i++) {
            if (textItemList[i].index == myTextData.tabOrder) {
              textItemList[i].maxLength = myTextData.maxLength;
              updateMytextData();
              _onUpdate(i);
            }
          }
        });
      }
      _focusNodemaxLenth.unfocus();
    } else if (indexTemp == 5) {
      //对齐方式
      setState(() {
        myTextData.alignment = int.tryParse(s.toString())!;
        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].alignment = myTextData.alignment;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 6) {
      //条码类型
      int objectIndex = _findIndex(myTextData.tabOrder);
      if (objectIndex == -1) {
        return;
      }
      var tempBacodeName = s;
      String totalcontent = '';
      List<dynamic> tempcontent = [];
      setState(() {
        if (s != '--') {
          int barcodeIndex = _findVarcontent(tempBacodeName, myTextData.type);
          if (barcodeIndex != -1) {
            // myTextData.varcontent.clear();
            myTextData.style = 0;
            myTextData.barcodeType =
                myBarCodeListList.barCodeListList[barcodeIndex].barCodeType;
            myTextData.barcodeName =
                myBarCodeListList.barCodeListList[barcodeIndex].barCodeName;
            for (var j = 0;
                j <
                    myBarCodeListList.barCodeListList[barcodeIndex]
                        .barCodeRowDataList.length;
                j++) {
              tempcontent.add(myBarCodeListList
                  .barCodeListList[barcodeIndex].barCodeRowDataList[j]);
              if (myBarCodeListList.barCodeListList[barcodeIndex]
                      .barCodeRowDataList[j].type ==
                  'TEXT') {
                totalcontent = totalcontent +
                    myBarCodeListList.barCodeListList[barcodeIndex]
                        .barCodeRowDataList[j].content
                        .toString();
              } else {
                totalcontent = totalcontent +
                    myBarCodeListList.barCodeListList[barcodeIndex]
                        .barCodeRowDataList[j].defaultvalue
                        .toString();
              }
            }
          }

          myTextData.varcontent = tempcontent;
          myTextData.content = totalcontent;
          textItemList[objectIndex].content = myTextData.content;
          textItemList[objectIndex].barcodeName = myTextData.barcodeName;
          textItemList[objectIndex].barcodeType = myTextData.barcodeType;
          textItemList[objectIndex].varcontent = myTextData.varcontent;
          textItemList[objectIndex].style = myTextData.style; //此处说明条码库中有此条码
          updateMytextData();
          _onUpdate(objectIndex);
        } else {
          if (textItemList[objectIndex].style == 0) {
            myTextData.varcontent.clear();
            textItemList[objectIndex].varcontent = myTextData.varcontent;
            updateMytextData();
          }
        }
      });
    } else if (indexTemp == 7) {
      //barcodeheight
      RegExp regex = RegExp(r"^(?:[1-9]|[1-9]\d|[1-4]\d\d|500)$"); //1-500限制大小
      if (regex.hasMatch(s)) {
        setState(() {
          myTextData.height = int.tryParse(s.toString())!;
          for (var i = 0; i < textItemList.length; i++) {
            if (textItemList[i].index == myTextData.tabOrder) {
              textItemList[i].height = myTextData.height;
              updateMytextData();
              _onUpdate(i);
            }
          }
        });
      }
      _focusbarcodeHeght.unfocus();
    } else if (indexTemp == 8) {
      //rotation
      setState(() {
        myTextData.rotation = int.tryParse(s.toString())!;
        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].rotation = myTextData.rotation;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 9) {
      //rotation
      setState(() {
        myTextData.hralignment = s;
        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].hralignment = myTextData.hralignment;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 10) {
      //x2坐标
      setState(() {
        var ss = double.parse(s.toString());
        myTextData.x2Pos = ss.toInt();

        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].x2Pos = myTextData.x2Pos;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 11) {
      //y2坐标
      setState(() {
        var ss = double.parse(s.toString());
        myTextData.y2Pos = ss.toInt();

        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].y2Pos = myTextData.y2Pos;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 12) {
      //条码类型   barcode
      List<dynamic> tempcontent = [];
      var tempQrcodeName = s;
      setState(() {
        if (s != '--') {
          int qrcodeIndex = _findVarcontent(tempQrcodeName, myTextData.type);
          if (qrcodeIndex != -1) {
            // myTextData.varcontent.clear();
            myTextData.style = 0;
            myTextData.qrcodeType =
                myBarCodeListList.barCodeListList[qrcodeIndex].barCodeType;
            myTextData.qrcodeName =
                myBarCodeListList.barCodeListList[qrcodeIndex].barCodeName;
            for (var j = 0;
                j <
                    myBarCodeListList
                        .barCodeListList[qrcodeIndex].barCodeRowDataList.length;
                j++) {
              tempcontent.add(myBarCodeListList
                  .barCodeListList[qrcodeIndex].barCodeRowDataList[j]);
            }
          }
          myTextData.varcontent = tempcontent;
          for (var i = 0; i < textItemList.length; i++) {
            if (textItemList[i].index == myTextData.tabOrder) {
              textItemList[i].qrcodeName = myTextData.qrcodeName;
              textItemList[i].qrcodeType = myTextData.qrcodeType;
              textItemList[i].varcontent = myTextData.varcontent;
              textItemList[i].style = myTextData.style;
              updateMytextData();
              _onUpdate(i);
            }
          }
        }
      });
    } else if (indexTemp == 13) {
      //qrcode width
      setState(() {
        myTextData.qrWidth = s;
        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].qrWidth = myTextData.qrWidth;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 14) {
      //Font bold
      setState(() {
        myTextData.fontBold = s;
        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].fontBold = myTextData.fontBold;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 15) {
      //Font reverse
      setState(() {
        myTextData.fontReverse = s;
        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].fontReverse = myTextData.fontReverse;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 16) {
      //Font reverse
      setState(() {
        myTextData.lineWidth = double.parse(s);
        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].lineWidth = myTextData.lineWidth;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 17) {
      //Font reverse
      setState(() {
        myTextData.x2Pos = int.parse(s);
        if (myTextData.x2Pos > (double.tryParse(pageWidth.text)!) * 8) {
          myTextData.x2Pos = (int.tryParse(pageWidth.text)!) * 8;
        }
        for (var i = 0; i < textItemList.length; i++) {
          if (textItemList[i].index == myTextData.tabOrder) {
            textItemList[i].x2Pos = myTextData.x2Pos;
            updateMytextData();
            _onUpdate(i);
          }
        }
      });
    }
  }

  void updateMytextData() {
    setState(() {
      xPosvar.text = myTextData.xPos.toString();
      yPosvar.text = myTextData.yPos.toString();
      textvariable.text = myTextData.content;
      fontsizevar.text = myTextData.fontSize.toString();
      barcodeHeight.text = myTextData.height.toString();
      _selectedRotation = myTextData.rotation.toString();
      _selectedBarcode = myTextData.barcodeName;
      _selectedQrcode = myTextData.qrcodeName;
      _selectFontsize = myTextData.fontSize.toString();
      _selectedQr = int.parse(myTextData.qrWidth.toString()).toString();
      if (myTextData.alignment == 1) {
        _selectedAlignment = 'Left';
      } else if (myTextData.alignment == 2) {
        _selectedAlignment = 'Center';
      } else if (myTextData.alignment == 3) {
        _selectedAlignment = 'Right';
      }
      _selectFontBold = myTextData.fontBold;
      _selectFontReverse = myTextData.fontReverse;
      _selectedHRAlignment = myTextData.hralignment;
      // yPosvar.text = myTextData.yPos.toString(); //20240503
    });
  }

  int _findIndex(int taborder) {
    int objectIndex = -1;

    for (var i = 0; i < textItemList.length; i++) {
      if (textItemList[i].index == taborder) {
        objectIndex = i;
        break;
      }
    }
    return objectIndex;
  }

  int _findVarcontent(String name, String type) {
    int findIndex = -1;
    for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
      if (myBarCodeListList.barCodeListList[i].barCodeName == name &&
          myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode' &&
          type == 'Qrcode') {
        findIndex = i;
        break;
      } else if (myBarCodeListList.barCodeListList[i].barCodeName == name &&
          myBarCodeListList.barCodeListList[i].barCodeType != 'Qrcode' &&
          type != 'Qrcode') {
        findIndex = i;
        break;
      }
    }

    return findIndex;
  }

  //左侧列表里按钮的点击事件
//在中间部分添加可拖拽控件，并添加到floatButtonList数组里，方便显示
  void addfloatbutton(name) {
    text = name.split(",")[0];
    type = name.split(",")[1];
    setState(() {
      myTextData.tabOrder = count;
      myTextData.content = text;
      myTextData.type = type;
      myTextData.xPos = xPos;

      if (text == "WeightUnit") {
        var contentStr = "Unit";
        textItemList.add(TextItem(
          key: ObjectKey(myTextData.tabOrder),
          index: count,
          content: contentStr,
          type: type,
          xPos: xPos,
          yPos: yPos,
          width: width,
          height: height,
          fontSize: fontSize,
          fontWidthRatio: fontWidthRatio,
          fontHeightRatio: fontHeightRatio,
          style: style,
          rotation: rotation,
          defaultValue: defaultValue,
          alignment: alignment,
          maxLength: maxLength,
          tabOrder: tabOrder,
          varName: text,
          varcontent: varcontent,
          barcodeName: barcodeName,
          barcodeType: barcodeType,
          hralignment: hralignment,
          x2Pos: x2Pos,
          y2Pos: y2Pos,
          lineWidth: lineWidth,
          qrWidth: qrWidth,
          qrcodeName: qrcodename,
          qrcodeType: qrcodeType,
          fontBold: fontBold,
          fontReverse: fontReverse,
        ));
      } else {
        textItemList.add(TextItem(
          key: ObjectKey(myTextData.tabOrder),
          index: count,
          content: text,
          type: type,
          xPos: xPos,
          yPos: yPos,
          width: width,
          height: height,
          fontSize: fontSize,
          fontWidthRatio: fontWidthRatio,
          fontHeightRatio: fontHeightRatio,
          style: style,
          rotation: rotation,
          defaultValue: defaultValue,
          alignment: alignment,
          maxLength: maxLength,
          tabOrder: tabOrder,
          varName: text,
          varcontent: varcontent,
          barcodeName: barcodeName,
          barcodeType: barcodeType,
          hralignment: hralignment,
          x2Pos: x2Pos,
          y2Pos: y2Pos,
          lineWidth: lineWidth,
          qrWidth: qrWidth,
          qrcodeName: qrcodename,
          qrcodeType: qrcodeType,
          fontBold: fontBold,
          fontReverse: fontReverse,
        ));
      }
      myItemKey.keyList.add(ObjectKey(myTextData.tabOrder));

      //中间页面添加最新的可拖拽控件
      floatButtonList.add(DraggableFloatingActionButton(
          index: (num.length - 1),
          key: ObjectKey(myTextData.tabOrder),
          initialOffset: const Offset(0, 0),
          parentKey: _parentKey,
          onPressed: () {},
          children: [textItemList[num.length - 1]]));
    });
  }

  //重新加载条码数据
  barcodeDataReload() {
    loadData();
  }

  Future<File> get _localFile async {
    final directory = p.dirname(Platform.script.toFilePath());
    return File(p.join(directory, 'barcodedata.json'));
  }

  Future<Map<String, dynamic>?> loadData() async {
    try {
      final file = await _localFile;
      // 从文件中读取字符串
      String contents = await file.readAsString();
      // 将字符串解码为JSON数据
      if (contents.isNotEmpty) {
        pasterBarcodeList(contents);
      }

      // Map<String, dynamic> data = jsonDecode(contents);
      // return data;
    } catch (e) {
      return null;
    }
    return null;
  }

  Future pasterBarcodeList(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    myBarCodeListList = BarCodeListList.fromJson(jsonResponse);
    _saveBarCodeNameToList();
    _saveQrcodeNameToList();
  }

  _saveBarCodeNameToList() {
    if (myBarCodeListList.barCodeListList.isNotEmpty) {
      mySavedBarcodeName.savedBarcodeName.clear();
      for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
        if (myBarCodeListList.barCodeListList[i].barCodeType != 'Qrcode') {
          mySavedBarcodeName.savedBarcodeName
              .add(myBarCodeListList.barCodeListList[i].barCodeName);
        }
      }
      mySavedBarcodeName.savedBarcodeName.add('--');
    } else {
      mySavedBarcodeName.savedBarcodeName.clear();
    }
    eventBus.fire(EventSavedBarcodeName(mySavedBarcodeName));
  }

  _saveQrcodeNameToList() {
    if (myBarCodeListList.barCodeListList.isNotEmpty) {
      mySavedQrcodeName.savedQrcodeName.clear();
      for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
        if (myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode') {
          mySavedQrcodeName.savedQrcodeName
              .add(myBarCodeListList.barCodeListList[i].barCodeName);
        }
      }
      mySavedQrcodeName.savedQrcodeName.add('--');
    } else {
      mySavedQrcodeName.savedQrcodeName.clear();
    }
    eventBus.fire(EventSavedQrcodeName(mySavedQrcodeName));
  }

  List<Widget> _selectItem() {
    return [
      const SizedBox(height: 100),
      Container(
        height: 50,
        color: Theme.of(context).colorScheme.surfaceBright,
        child: Text(
          localizedStrings.gMsgNoElement,
          style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.normal),
        ),
      ),
      Container(
        height: 50,
        color: Theme.of(context).colorScheme.surfaceBright,
        child: Text(
          localizedStrings.gOperationSteps,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        ),
      ),
      Container(
        height: 50,
        color: Theme.of(context).colorScheme.surfaceBright,
        child: Text(
          localizedStrings.gMsgStep1,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        ),
      ),
      Container(
        height: 80,
        color: Theme.of(context).colorScheme.surfaceBright,
        child: Text(
          localizedStrings.gMsgStep2,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        ),
      ),
    ];
  }

  TextField buildTextField(TextEditingController controller, String labelText,
      String hintText, int num) {
    controller.text = hintText;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        hintStyle: const TextStyle(fontSize: 14),
        labelText: labelText,
        hintText: hintText,
      ),
      onEditingComplete: () {
        _onSubmit(controller.text, num);
      },
      focusNode: (num == 0)
          ? _focusNodeContent
          : (num == 1)
              ? _focusNodeFontSize
              : (num == 2)
                  ? _focusNodexPos
                  : (num == 3)
                      ? _focusNodeyPos
                      : (num == 4)
                          ? _focusNodemaxLenth
                          : (num == 7)
                              ? _focusbarcodeHeght
                              : (num == 17)
                                  ? _focusNodex2Pos
                                  : (num == 10)
                                      ? _focusNodey2Pos
                                      : (num == 16)
                                          ? _focusNodelineWidth
                                          : _focusNodeContent,
    );
  }

//下拉旋转
  void _handleRotationSelected(String value) {
    setState(() {
      _selectedRotation = value;
      _onSubmit(_selectedRotation, 8);
    });
  }

//下拉对齐方式
  void _handleAlignmentSelected(String value) {
    setState(() {
      _selectedAlignment = value;
    });
    if (_selectedAlignment == 'Left') {
      _onSubmit('1', 5);
    } else if (_selectedAlignment == 'Center') {
      _onSubmit('2', 5);
    } else if (_selectedAlignment == 'Right') {
      _onSubmit('3', 5);
    }
  }

//下拉HR 位置
  void _handleHrAlignmentSelected(String value) {
    setState(() {
      _selectedHRAlignment = value;
      _onSubmit(_selectedHRAlignment, 9);
    });
  }

//下拉字体加粗
  void _handleFontBoldSelected(String value) {
    setState(() {
      _selectFontBold = value;
      _onSubmit(_selectFontBold, 14);
    });
  }

//下拉反白
  void _handleFontReverseSelected(String value) {
    setState(() {
      _selectFontReverse = value;
      _onSubmit(_selectFontReverse, 15);
    });
  }

//下拉qr宽度
  void _handleQrWidthSelected(String value) {
    setState(() {
      _selectedQr = value;
      _onSubmit(_selectedQr, 13);
    });
  }

//下拉qrcode
  void _handleQrcodeSelected(String value) {
    setState(() {
      _selectedQrcode = value;
      if (_selectedQrcode == '--') {
      } else {
        _onSubmit(_selectedQrcode, 12);
      }
    });
  }

//下拉Barcode
  void _handleBarcodeSelected(String value) {
    setState(() {
      _selectedBarcode = value;
      if (_selectedBarcode == '--') {
        // _onSubmit(_selectedBarcode, 6);
      } else {
        _onSubmit(_selectedBarcode, 6);
      }
    });
  }

  //下拉字体加粗
  void _handleFontSizeSelected(String value) {
    setState(() {
      _selectFontsize = value;
      _onSubmit(_selectFontsize, 1);
    });
  }

  List<Widget> buildXYPosition() {
    return [
      Row(
        children: [
          Container(
            height: 48,
            width: 50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: smallPadding),
            child: Text("X:",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                )),
          ),
          Expanded(
            child: TextField(
              enabled: false,
              controller: xPosvar,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              onEditingComplete: () {
                _onSubmit(xPosvar.text, 2);
              }, // 点击“完成”按钮后，调用失去焦点方法
              focusNode: _focusNodexPos, // 将FocusNode对象绑定到TextField
            ),
          ),
        ],
      ),
      SizedBox(
        height: smallPadding,
      ),
      Row(
        children: [
          Container(
            height: 48,
            width: 50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: smallPadding),
            child: Text("Y:",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                )),
          ),
          Expanded(
            child: TextField(
              enabled: false,
              controller: yPosvar,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              onEditingComplete: () {
                _onSubmit(yPosvar.text, 3);
              }, // 点击“完成”按钮后，调用失去焦点方法
              focusNode: _focusNodeyPos, // 将FocusNode对象绑定到TextField
            ),
          ),
        ],
      ),
    ];
  }

  Widget buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  List<Widget> buildRotation() {
    return [
      showRightItemTitleText(context, localizedStrings.gRotation),
      showDropDownButtonValue(
        context,
        _selectedRotation,
        _rotations,
        'Rotation',
        _handleRotationSelected,
      ),
    ];
  }

  List<Widget> fontInfoWidget() {
    return [
      showRightItemTitleText(context, localizedStrings.gFontSize),
      showDropDownButtonValue(
        context,
        _selectFontsize,
        _fontSizes,
        'FontSize',
        _handleFontSizeSelected,
      ),
      ...buildRotation(),
      showRightItemTitleText(context, localizedStrings.gFontBold),
      showDropDownButtonValue(
        context,
        _selectFontBold,
        _fontBoldReverse,
        localizedStrings.gFontBold,
        _handleFontBoldSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gFontReverse),
      showDropDownButtonValue(
        context,
        _selectFontReverse,
        _fontBoldReverse,
        localizedStrings.gFontReverse,
        _handleFontReverseSelected,
      ),
    ];
  }

  List<Widget> _textproperties() {
    return [
      buildAttitudeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTabOrder, myTextData.tabOrder.toString()),
      const SizedBox(height: smallPadding),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTipItemType, myTextData.type),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      showRightItemTitleText(context, localizedStrings.gTextContent),
      buildTextField(textvariable, "", myTextData.content.toString(), 0),
      ...fontInfoWidget(),
      const SizedBox(height: 20),
      deleteBtnBuild(),
    ];
  }

  _deleteTextItem(int deleteNum) {
    int indexToRemove = -1;
    for (var i = 0; i < textItemList.length; i++) {
      if (textItemList[i].index == deleteNum) {
        indexToRemove = i;
        break;
      }
    }
    if (indexToRemove >= 0) {
      textItemList.removeAt(indexToRemove);
      List<TextItem> temptextItemList = [];
      for (var i = 0; i < textItemList.length; i++) {
        temptextItemList.add(textItemList[i]);
      }

      textItemList.clear();
      myItemKey.keyList.clear();
      num.removeAt(indexToRemove);
      // count = 0;
      floatButtonList.clear();
      _parentKey = GlobalKey();

      for (var i = 0; i < temptextItemList.length; i++) {
        // temptextItemList[i].index = i;
        textItemList.add(temptextItemList[i]);
        myItemKey.keyList.add(ObjectKey(textItemList[i].index));

        floatButtonList.add(DraggableFloatingActionButton(
            index: (textItemList[i].index),
            key: ObjectKey(textItemList[i].index),
            initialOffset: Offset(textItemList[i].xPos.toDouble(),
                textItemList[i].yPos.toDouble()),
            parentKey: _parentKey,
            onPressed: () {},
            children: [textItemList[i]]));
      }
      myTextData.tabOrder = 9999;
    }
  }

  void reconstructItem() {
    List<TextItem> temptextItemList = [];
    for (var i = 0; i < textItemList.length; i++) {
      temptextItemList.add(textItemList[i]);
    }
    textItemList.clear();
    myItemKey.keyList.clear();
    floatButtonList.clear();
    _parentKey = GlobalKey();

    for (var i = 0; i < temptextItemList.length; i++) {
      // temptextItemList[i].index = i;
      textItemList.add(temptextItemList[i]);
      myItemKey.keyList.add(ObjectKey(textItemList[i].index));

      floatButtonList.add(DraggableFloatingActionButton(
          index: (textItemList[i].index),
          key: ObjectKey(textItemList[i].index),
          initialOffset: Offset(
              textItemList[i].xPos.toDouble(), textItemList[i].yPos.toDouble()),
          parentKey: _parentKey,
          onPressed: () {},
          children: [textItemList[i]]));
    }
    myTextData.tabOrder = 9999;
  }

  List<Widget> _varproperties() {
    return [
      buildAttitudeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTabOrder, myTextData.tabOrder.toString()),
      const SizedBox(height: smallPadding),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTipItemType, myTextData.type),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      showRightItemTitleText(context, localizedStrings.gMaxLength),
      buildTextField(maxLenthvar, "", myTextData.maxLength.toString(), 4),
      showRightItemTitleText(context, localizedStrings.gAlignment),
      showDropDownButtonValue(
        context,
        _selectedAlignment,
        _alignments,
        localizedStrings.gAlignment,
        _handleAlignmentSelected,
      ),
      ...fontInfoWidget(),
      const SizedBox(height: 20),
      deleteBtnBuild(),
    ];
  }

  Widget deleteBtnBuild() {
    return SizedBox(
        width: 200,
        child: showTextButton(context, btnHeight, localizedStrings.gBtnDelete,
            () {
          setState(() {
            _deleteTextItem(myTextData.tabOrder);
          });
        },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.error,
            Theme.of(context).colorScheme.onPrimary));
  }

  List<Widget> _lineproperties() {
    return [
      buildAttitudeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTabOrder, myTextData.tabOrder.toString()),
      const SizedBox(height: smallPadding),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTipItemType, myTextData.type),
      showRightItemTitleText(context, localizedStrings.gPosition),
      buildTextField(xPosvar, "X1", myTextData.xPos.toString(), 2),
      buildTextField(yPosvar, "Y1", myTextData.yPos.toString(), 3),
      buildTextField(x2Posvar, localizedStrings.l_line_lenth_txt,
          myTextData.x2Pos.toString(), 17),
      buildTextField(lineWidthVar, localizedStrings.l_line_width_txt,
          myTextData.lineWidth.toString(), 16),
      const SizedBox(height: 20),
      deleteBtnBuild(),
    ];
  }

  List<Widget> _barCodeproperties() {
    return [
      buildAttitudeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTabOrder, myTextData.tabOrder.toString()),
      const SizedBox(height: smallPadding),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTipItemType, myTextData.type),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      showRightItemTitleText(context, localizedStrings.gBarcode),
      showDropDownButtonValue(
        context,
        _selectedBarcode,
        _savedBarCodeNames,
        localizedStrings.gBarcode,
        _handleBarcodeSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gBarcodeHeight),
      buildTextField(barcodeHeight, "", myTextData.height.toString(), 7),
      showRightItemTitleText(context, localizedStrings.gHrAlignment),
      showDropDownButtonValue(
        context,
        _selectedHRAlignment,
        _hralignments,
        localizedStrings.gHrAlignment,
        _handleHrAlignmentSelected,
      ),
      ...buildRotation(),
      const SizedBox(height: 20),
      deleteBtnBuild(),
    ];
  }

  List<Widget> _qrcodeproperties() {
    return [
      buildAttitudeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTabOrder, myTextData.tabOrder.toString()),
      const SizedBox(height: smallPadding),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTipItemType, myTextData.type),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      showRightItemTitleText(context, localizedStrings.gQrcode),
      showDropDownButtonValue(
        context,
        _selectedQrcode,
        _savedQrcodeNames,
        localizedStrings.gQrcode,
        _handleQrcodeSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gQrcodeWidth),
      showDropDownButtonValue(
        context,
        _selectedQr,
        _qrWidths,
        localizedStrings.gQrcodeWidth,
        _handleQrWidthSelected,
      ),
      const SizedBox(height: 20),
      deleteBtnBuild(),
    ];
  }

  void getLanguageVarMap() {
    if (langVarMap.isNotEmpty) {
      return;
    }
    langVarMap = {
      "Variable": localizedStrings.l_var_title,
      "Free Text": localizedStrings.l_text_title,
      "BarCode Variable": localizedStrings.l_barcode_title,
      "Qrcode Variable": localizedStrings.l_qrcode_title,
      "Shape": localizedStrings.l_shape_title,
      "Line": localizedStrings.l_line_var,
      "Text": localizedStrings.l_text_var,
      "BarCode": localizedStrings.l_barcode_var,
      "Qrcode": localizedStrings.l_qrcode_var,
      "NO.": localizedStrings.l_no_var,
      "Gross": localizedStrings.l_gross_var,
      "Tare": localizedStrings.l_tare_var,
      "Net": localizedStrings.l_net_var,
      "PCS": localizedStrings.l_pcs_var,
      "WeightUnit": localizedStrings.l_wgt_unit_var,
      "DATE": localizedStrings.l_date_var,
      "TIME": localizedStrings.l_time_var,
      "U.WGT": localizedStrings.l_uwgt_var,
      "U.WU": localizedStrings.l_uwu_var,
      "UnitWeight": localizedStrings.l_unit_wgt_var,
      "Percent": localizedStrings.l_percent_var,
      "TotalWeight": localizedStrings.l_total_wgt_var,
      "TotalCount": localizedStrings.l_total_cnt_var,
      "TotalPcs": localizedStrings.l_total_pcs_var,
    };

    langVarExplMap = {
      "Line": localizedStrings.l_line_expl,
      "Text": localizedStrings.l_text_expl,
      "BarCode": localizedStrings.l_barcode_expl,
      "Qrcode": localizedStrings.l_qrcode_expl,
      "NO.": localizedStrings.l_no_expl,
      "Gross": localizedStrings.l_gross_expl,
      "Tare": localizedStrings.l_tare_expl,
      "Net": localizedStrings.l_net_expl,
      "PCS": localizedStrings.l_pcs_expl,
      "WeightUnit": localizedStrings.l_wgt_unit_expl,
      "DATE": localizedStrings.l_date_expl,
      "TIME": localizedStrings.l_time_expl,
      "U.WGT": localizedStrings.l_uwgt_expl,
      "U.WU": localizedStrings.l_uwu_expl,
      "UnitWeight": localizedStrings.l_unit_wgt_expl,
      "Percent": localizedStrings.l_percent_expl,
      "TotalWeight": localizedStrings.l_total_wgt_expl,
      "TotalCount": localizedStrings.l_total_cnt_expl,
      "TotalPcs": localizedStrings.l_total_pcs_expl,
    };
  }
}

class Circle extends StatelessWidget {
  final int index;
  final Offset position;
  final ValueChanged onPositionChanged;
  const Circle({
    super.key,
    required this.index,
    required this.position,
    required this.onPositionChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 5,
      top: position.dy - 5,
      child: GestureDetector(
        onPanUpdate: (details) => onPositionChanged(position + details.delta),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class Line {
  final Offset start;
  final Offset end;
  Line(this.start, this.end);
}

// 自定义滚动行为：只有滚动条本身可以触发滚动
class _ScrollbarOnlyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        // 空集合，禁用所有设备在内容区域的拖拽滚动
        // 这样只有滚动条本身的拖拽才会触发滚动
      };

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    // 使用 RawScrollbar 确保滚动条本身可以交互
    return RawScrollbar(
      controller: details.controller,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 12,
      radius: const Radius.circular(6),
      // 确保滚动条本身可以交互
      interactive: true,
      child: child,
    );
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    // 禁用过度滚动效果
    return child;
  }
}
