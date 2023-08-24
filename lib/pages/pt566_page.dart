import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/pages/widget/linepainter.dart';
import '../data/barcoderowdata.dart';
import '../data/formatdata.dart';
import '../data/offset.dart';
import '../data/pagesize.dart';
import '../data/scalecmd_data.dart';
import '../data/text.dart';
import '../eventbus/eventbus.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import 'dialog/barcodeedit_dialog.dart';
import 'dialog/qrcodeedit_dialog.dart';
import 'widget/draggablefliating.dart';
import 'widget/dropdown copy.dart';
import 'widget/textlistItem.dart';

class PT566Page extends StatefulWidget {
  const PT566Page({Key? key}) : super(key: key);

  @override
  State<PT566Page> createState() => _PT566PageState();
}

const citys = {
  "Free Text": ["Text,TEXT"],
  "BarCode": ["BarCode,BarCode"],
  "Qrcode": ["Qrcode,Qrcode"],
  // "Shape": ["Rectangle,Rectangle", "Circle,Circle", "Line,Line"],
  "Variable": [
    "NO.,DATA",
    "Gross,DATA",
    "Tare,DATA",
    "Net,DATA",
    "PCS,DATA",
    "WeightUnit,DATA",
    "Date,DATA",
    "Time,DATA",
    "UnitWeight,DATA",
    "Percent,DATA",
    "TotalWeight,DATA",
    "TotalCount,DATA",
  ],
};

class _PT566PageState extends State<PT566Page> {
  List<TextItem> textItemList = [];
  List<DraggableFloatingActionButton> floatButtonList = [];
  GlobalKey _parentKey = GlobalKey();
  List<int> num = [0];
  dynamic name = "Text,TEXT";
  String text = "";
  String type = '';
  int xPos = 0;
  int yPos = 0;
  int width = 0;
  int height = 50;
  int fontSize = 24;
  int fontWidthRatio = 1;
  int fontHeightRatio = 1;
  int style = 0;
  int rotation = 0;
  String varName = '';
  String defaultValue = 'data';
  int alignment = 0;
  int maxLength = 10;
  int tabOrder = 0;
  String content = '';
  String barcodeName = '--';
  String barcodeType = '';
  String hralignment = 'Bottom';
  int x2Pos = 100;
  int y2Pos = 0;
  double lineWidth = 10;
  String qrWidth = '3';
  String qrcodename = '--';
  String qrcodeType = 'Qrcode';
  String fontBold = 'false';
  String fontReverse = 'false';
  List<dynamic> varcontent = [];

  TextEditingController textvariable = TextEditingController();
  TextEditingController fontsizevar = TextEditingController();
  TextEditingController xPosvar = TextEditingController();
  TextEditingController yPosvar = TextEditingController();
  TextEditingController x2Posvar = TextEditingController();
  TextEditingController y2Posvar = TextEditingController();
  TextEditingController maxLenthvar = TextEditingController();
  TextEditingController barcodeHeight = TextEditingController();

  var count = 0;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  // dynamic _eventbus7;
  // dynamic _eventbus8;
  final FocusNode _focusNodeContent = FocusNode();
  final FocusNode _focusNodeFontSize = FocusNode();
  final FocusNode _focusNodexPos = FocusNode();
  final FocusNode _focusNodeyPos = FocusNode();
  final FocusNode _focusNodemaxLenth = FocusNode();
  final FocusNode _focusbarcodeHeght = FocusNode();
  final FocusNode _focusNodex2Pos = FocusNode();
  final FocusNode _focusNodey2Pos = FocusNode();

  String _selectedPrinterName = 'PT566';
  String _selectedPageSize = '58*75';
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
  String _selectFontsize = '24';
  final _lineList = [];

  final List<String> _printers = [
    'PT566',
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

  final List<String> _pageSizes = [
    '60*60',
    '50*60',
    '40*50',
    '30*50',
    '50*40',
    '55*50',
    '58*75',
  ];
  final List<String> _fontSizes = [
    // '18', //1号 字体 只支持英文字体
    // '19',
    // '20',
    // '21',
    // '22',
    // '23',
    // '25', //0号 字体
    '24',
    // '25',
    // '38', //01 1 1
    '49',
    // '50',
    // '51', //00 1 1
    // '56', //01 2 2
    '72',
    // '74', //01 3 3
    // '93', //01 4 4
    '97', //00 3 3
    // '111', //01 5 5
    // '128', //01 6 6、

    '123', //00 4 4

    '142',
    //00 5 5
    // '148', //01 7 7
    '169', //00 6 6

    '200', //00 7 7
  ];

  @override
  void initState() {
    addfloatbutton(name); //暂时屏蔽掉
    textItemList;
    textvariable.text = myTextData.content;
    xPosvar.text = myTextData.xPos.toString();
    if (myTextData.type == "TEXT") {
      yPosvar.text = (myTextData.yPos + 26).toString();
    } else if (myTextData.type == "BarCode") {
      yPosvar.text = (myTextData.yPos + 52).toString();
    } else if (myTextData.type == "Qrcode") {
      yPosvar.text = (myTextData.yPos + 65).toString();
    }
    x2Posvar.text = myTextData.x2Pos.toString();
    y2Posvar.text = myTextData.y2Pos.toString();
    barcodeDataReload();

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
          yPosvar.text = (myOffsetData.y + myOffsetData.height).toString();
          // _onSubmit(xPosvar.text.toString(), 2);
          // _onSubmit(yPosvar.text.toString(), 3);
          if (textItemList.isNotEmpty) {
            for (var i = 0; i < textItemList.length; i++) {
              if (textItemList[i].key == myOffsetData.key) {
                textItemList[i].xPos = myOffsetData.x.toInt();
                textItemList[i].yPos = myOffsetData.y.toInt();
                textItemList[i].height = myOffsetData.height.toInt();
                textItemList[i].width = myOffsetData.width.toInt();
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
    _eventbus6 = eventBus.on<EventDownloadResponse>().listen((event) {
      if (mounted) {
        setState(() {
          downloadStatus = true;
          myDownloadResponse = event.obj;
          if (myDownloadResponse.msgBody.isNotEmpty) {
            setState(() {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      (myDownloadResponse.msgBody.contains('ok'))
                          ? 'Download successful!'
                          : myDownloadResponse.msgBody,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold)), ////此处需要秤回复
                  duration: const Duration(seconds: 3),
                  backgroundColor: (myDownloadResponse.msgBody.contains('ok'))
                      ? Colors.green.shade900
                      : Colors.red.shade900));
            });
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
      if (!_focusNodexPos.hasFocus) {
        _onSubmit(x2Posvar.text, 9);
      }
    });
    _focusNodey2Pos.addListener(() {
      if (!_focusNodeyPos.hasFocus) {
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
    _eventbus6.cancel();
    // _eventbus7.cancel();
    // _eventbus8.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          height: 80,
          width: screenSize.width - 10,
          color: Colors.blue.shade900,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 设置按钮的背景色
                    elevation: 10, // 设置按钮的阴影
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.blue.shade900,
                        ),
                        Text(
                          'Home',
                          style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
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
                            const Text(
                              'Printer:',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            DropdownButton<String>(
                              dropdownColor: Colors.grey[400],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal),
                              hint: const Text(
                                'Printer',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              value: _selectedPrinterName,
                              items: _printers
                                  .map((String value) =>
                                      DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      ))
                                  .toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPrinterName = newValue!;
                                });
                              },
                            ),
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
                            const Text(
                              'Direction:',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            DropdownButton<String>(
                              dropdownColor: Colors.grey[400],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal),
                              hint: const Text(
                                'Direction',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              value: _selectedPrintDirection,
                              items: _printDirections
                                  .map((String value) =>
                                      DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      ))
                                  .toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPrintDirection = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        const Text(
                          'Page:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          dropdownColor: Colors.grey[400],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.normal),
                          // hint: const Text(
                          //   'Select Page Size',
                          //   style: TextStyle(
                          //       color: Color.fromARGB(255, 13, 71, 161),
                          //       fontSize: 20,
                          //       fontWeight: FontWeight.bold),
                          // ),
                          value: _selectedPageSize,
                          items: _pageSizes
                              .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal)),
                                  ))
                              .toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPageSize = newValue!;
                              myPageSize.size = _selectedPageSize;
                              eventBus.fire(EventPageSize(myPageSize));
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                              onPressed: () {
                                deleteAllItem();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.yellow.shade900, // 设置按钮的背景色
                                elevation: 10, // 设置按钮的阴影
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8), // 设置按钮的圆角
                                ),
                              ),
                              child: const Text('New Format',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ))),
                        ),
                      ],
                    ),
                  )
                ],
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                        onPressed: () async {
                          final directory = Directory.current.path;
                          String? outputFile =
                              (await FilePicker.platform.saveFile(
                            initialDirectory: directory,
                            dialogTitle: 'Output file:',
                            type: FileType.custom,
                            allowedExtensions: ['json'],
                            fileName: 'formatdata1.json',
                          ));
                          if (outputFile != null) {
                            _saveFormatToJson(outputFile);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade900, // 设置按钮的背景色
                          elevation: 10, // 设置按钮的阴影
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
                          ),
                        ),
                        child: const Text('Save File',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ))),
                  ),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                        onPressed: () async {
                          String filePath = '';
                          try {
                            final directory = Directory.current.path;
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Text('Open fail',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight:
                                                  FontWeight.bold)), ////此处需要秤回复
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: Colors.red.shade900));
                            });
                          }
                          if (filePath != '') {
                            deleteAllItem();
                            _openJsonFile(filePath);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade900, // 设置按钮的背景色
                          elevation: 10, // 设置按钮的阴影
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
                          ),
                        ),
                        child: const Text('Open File',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ))),
                  ),
                ],
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // 设置按钮的背景色
                        elevation: 10, // 设置按钮的阴影
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
                        ),
                      ),
                      child: Text(
                        'BarCode Edit',
                        style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
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
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // 设置按钮的背景色
                        elevation: 10, // 设置按钮的阴影
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
                        ),
                      ),
                      child: Text(
                        'Qrcode Edit',
                        style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
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
                    ),
                  ),
                ],
              ),

              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                    onPressed: downloadStatus
                        ? () async {
                            final directory = Directory.current.path;
                            String dataTime = getDateTime();
                            String outputFile;
                            final filePath = Directory('$directory\\download');
                            final file =
                                File('$directory\\download\\$dataTime.json');
                            outputFile = file.path;
                            if (!await filePath.exists()) {
                              await filePath.create(recursive: true);
                            }
                            _saveFormatToJson(outputFile);
                            _exportCSV();
                            setState(() {
                              downloadStatus = false;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: downloadStatus
                          ? Colors.green.shade900
                          : Colors.white, // 设置按钮的背景色
                      elevation: 10, // 设置按钮的阴影
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
                      ),
                    ),
                    child: Text('Download',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: downloadStatus ? Colors.white : Colors.black,
                        ))),
              ),

              //   ],
              // ),
            ],
          ),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              children: _buildList(),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              height: 1200,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 223, 223, 223),
                  border: Border.all(width: 0.2, color: Colors.black)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    //60mmX60
                    width: _getPageWidth(),
                    height: _getPageHeight(),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 0.5, color: Colors.black)),
                    child: Stack(
                      key: _parentKey,
                      children: [
                        ...floatButtonList,
                        _buildLines(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
              flex: 3,
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
              )),
          const SizedBox(width: 10)
        ],
      ),
    );
  }

  Widget _buildLines() {
    return Stack(
      children: [
        for (var i = 0; i < _lineList.length; i++)
          _buildLine(i, _lineList[i].start, _lineList[i].end),
      ],
    );
  }

  Widget _buildLine(int index, Offset start, Offset end) {
    return Stack(
      children: [
        Positioned(
          top: start.dy, //min(start.dy, end.dy),
          left: start.dx, // min(start.dx, end.dx),
          // right: end.dy,
          // bottom: end.dx,
          width: (start - end).distance,
          height: 50.0,
          child: Transform.rotate(
            // offset: start,
            angle: atan2(end.dy - start.dy, end.dx - start.dx) - atan2(0, 1),
            child: GestureDetector(
              onPanUpdate: (details) => _onLineDragged(index, details),
              child: CustomPaint(
                painter: LinePainter(startPoint: start, endPoint: end),
              ),
            ),
          ),
        ),
        Circle(
          index: index,
          position: start,
          onPositionChanged: (position) =>
              _onCircleDragged(index, start, position, 0),
        ),
        Circle(
          index: index,
          position: end,
          onPositionChanged: (position) =>
              _onCircleDragged(index, end, position, 1),
        ),
      ],
    );
  }

  void _onLineDragged(int index, DragUpdateDetails details) {
    setState(() {
      final line = _lineList[index];
      _lineList[index] =
          Line(line.start + details.delta, line.end + details.delta);
    });
  }

  void _onCircleDragged(
      int index, Offset oldPosition, Offset newPosition, int circleIndex) {
    setState(() {
      final line = _lineList[index];
      if (circleIndex == 1) {
        _lineList[index] = Line(line.start, newPosition);
      } else {
        _lineList[index] = Line(newPosition, line.end);
      }
    });
  }

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
    if (_selectedPageSize == _pageSizes[0]) {
      return 447;
    } else if (_selectedPageSize == _pageSizes[1]) {
      return 400;
    } else if (_selectedPageSize == _pageSizes[2]) {
      return 320;
    } else if (_selectedPageSize == _pageSizes[3]) {
      return 240;
    } else if (_selectedPageSize == _pageSizes[4]) {
      return 400;
    } else if (_selectedPageSize == _pageSizes[5]) {
      return 384;
    } else if (_selectedPageSize == _pageSizes[6]) {
      return 464;
    } else {
      return 300;
    }
  }

  double _getPageHeight() {
    if (_selectedPageSize == _pageSizes[0]) {
      return 470;
    } else if (_selectedPageSize == _pageSizes[1]) {
      return 480;
    } else if (_selectedPageSize == _pageSizes[2]) {
      return 400;
    } else if (_selectedPageSize == _pageSizes[3]) {
      return 400;
    } else if (_selectedPageSize == _pageSizes[4]) {
      return 320;
    } else if (_selectedPageSize == _pageSizes[5]) {
      return 400;
    } else if (_selectedPageSize == _pageSizes[6]) {
      return 600;
    } else {
      return 300;
    }
  }

  void sendFormatToScale(String modifyString) {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    myScaleCmd.cmdData = modifyString;
    MyApp.webchannel1.sendMessage(jsonEncode(myScaleCmd));
    // MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
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

/*
  // '18', //1号 字体 只支持英文字体   
    '23', //0号 字体
    // '38', //01 1 1
    '50', //00 1 1
    // '56', //01 2 2
    '72', //00 2 2
    // '74', //01 3 3
    // '93', //01 4 4
    '97', //00 3 3
    // '111', //01 5 5
    // '128', //01 6 6
    '140', //00 4 4
    '146', //00 5 5
    // '148', //01 7 7
    '169', //00 6 6
    '186', //00 7 7
*/
  List getFontSize(int sFont) {
    int fontsize = 0;
    int width = 0;
    int height = 0;
    if (sFont == 24 ||
        sFont == 23 ||
        sFont == 22 ||
        sFont == 21 ||
        sFont == 20 ||
        sFont == 19 ||
        sFont == 18) {
    } else if (sFont == 51 || sFont == 50 || sFont == 49) {
      width = 1;
      height = 1;
    } else if (sFont == 75 ||
        sFont == 76 ||
        sFont == 74 ||
        sFont == 73 ||
        sFont == 72 ||
        sFont == 71 ||
        sFont == 70) {
      width = 2;
      height = 2;
    } else if (sFont < 100 && sFont > 80) {
      width = 3;
      height = 3;
    } else if (sFont < 128 && sFont > 100) {
      width = 4;
      height = 4;
    } else if (sFont < 146) {
      width = 5;
      height = 5;
    } else if (sFont <= 180) {
      width = 6;
      height = 6;
    } else if (sFont <= 200) {
      width = 7;
      height = 7;
    }
    return [fontsize, width, height];
  }
  //  List vals = getFontSize(); print("${vals[0]} ${vals[1]} ${vals[2]}");

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
    if (_selectedPageSize == '50*60') {
      csvData.add(['P', 400, 480]);
    } else if (_selectedPageSize == '40*50') {
      csvData.add(['P', 320, 400]);
    } else if (_selectedPageSize == '60*60') {
      csvData.add(['P', 480, 480]);
    } else if (_selectedPageSize == '30*50') {
      csvData.add(['P', 240, 400]);
    } else if (_selectedPageSize == '50*40') {
      csvData.add(['P', 400, 320]);
    } else if (_selectedPageSize == '55*50') {
      csvData.add(['P', 384, 400]);
    } else if (_selectedPageSize == '58*75') {
      csvData.add(['P', 464, 600]);
    }
    // csvData.add(['R', '147', '124', '247', '184', '2', '0', '0']);
    // csvData.add(['L', '147', '124', '247', '184', '2', '0', '0']);
    var xpos = 0;
    var ypos = 0;

    for (var i = 0; i < textItemList.length; i++) {
      ypos = textItemList[i].yPos;
      xpos = textItemList[i].xPos;
      ypos = textItemList[i].yPos + textItemList[i].height;
      if (textItemList[i].type == 'TEXT') {
        List fontlist = getFontSize(textItemList[i].fontSize);

        csvData.add([
          'TB',
          xpos,
          ypos,
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
          xpos,
          ypos,
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
          xpos,
          ypos,
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
          xpos,
          ypos,
          version,
          textItemList[i].qrWidth.toString(),
          errorlevel,
          '',
          tempContent,
          textItemList[i].index,
        ]);
      } else if (textItemList[i].type == 'Line') {
        csvData.add([
          'L',
          xpos,
          ypos,
          textItemList[i].x2Pos,
          textItemList[i].y2Pos,
          textItemList[i].lineWidth,
          0, //线类型
          textItemList[i].index,
        ]);
      }
    }
    String csv = const ListToCsvConverter(
      textDelimiter: '',
    ).convert(csvData);
    // String csv = const ListToCsvConverter().convert(csvData);
    // final directory = await Directory.systemTemp.createTemp();
    // final file = File('${path}/data.csv');
    // await file.writeAsString(csv);
    sendFormatToScale(csv); //发送数据
    if (kDebugMode) {
      print(csv);
    }
  }

  _saveFormatDataToJson(List list, String path) async {
    try {
      if (list.isNotEmpty) {
        String json = jsonEncode(list);
        // print(json);

        FormatContent myFormatContent = FormatContent(
            page: _selectedPageSize,
            rotation: _selectedPrintDirection,
            content: json);

        String formatjson = jsonEncode(myFormatContent);

        // final file = await _localFilepath; ///////获取固定位置
        final file = File(p.join(path));
        // 将字符串写入文件中
        file.writeAsStringSync(formatjson);
        // await loadData();   此处已经写好了如何捞回来条码信息
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // 读取本地文件中的文本框信息
  Future readTextInfoListFromFile(String path) async {
    List textInfoList = [];
    try {
      var file = File(p.join(path)); //await _localFilepath;
      String jsonString = await file.readAsString();
      FormatContent fromatContent =
          FormatContent.fromJson(jsonDecode(jsonString));
      setState(() {
        if (_pageSizes.contains(fromatContent.page)) {
          _selectedPageSize = fromatContent.page;
        }
        if (_printDirections.contains(fromatContent.rotation)) {
          _selectedPrintDirection = fromatContent.rotation;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)), ////此处需要秤回复
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red.shade900));
    }
    return textInfoList;
  }

  void deleteAllItem() {
    setState(() {
      textItemList.clear();
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

  // void _saveFormatToCsv(String csv) async {
  //   final directory = Directory.current.path;
  //   final file = File('$directory\\data.csv');
  //   await file.writeAsString(csv);
  // }

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
    List<Widget> widgets = [];
    for (var key in citys.keys) {
      widgets.add(_generateExpansionTileWidget(key, citys[key]));
    }
    return widgets;
  }

  /// 生成 ExpansionTile 组件 , children 是 List<Widget> 组件
  Widget _generateExpansionTileWidget(tittle, List<String>? names) {
    return ExpansionTile(
      title: Text(tittle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      children: names!.map((name) => _generateWidget(name)).toList(),
    );
  }

  /// 生成 ExpansionTile 下的 ListView 的单个组件
  Widget _generateWidget(name) {
    text = name.split(",")[0];
    type = name.split(",")[1];

    /// 使用该组件可以使宽度撑满
    return FractionallySizedBox(
      widthFactor: 1,
      child: Container(
          height: 30,
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 0.2, color: Colors.grey))),
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              if (name != 'Line,Line') {
                count++;
                num.add(count);
                myTextData.tabOrder = count;
                addfloatbutton(name);
              } else {
                _createLine();
              }
            },
            child: Text(
              //左侧按钮文本的颜色
              text,
              style: const TextStyle(
                  color: Color.fromARGB(255, 15, 71, 161),
                  fontWeight: FontWeight.bold),
            ),
          )),
    );
  }

  void _createLine() {
    const start = Offset(0, 0);
    const end = Offset(100, 0);
    setState(() {
      _lineList.add(Line(start, end));
    });
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

            eventBus.fire(EventText(myTextData));
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
              eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
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
              eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
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
          eventBus.fire(EventText(myTextData));
          _onUpdate(objectIndex);
        } else {
          if (textItemList[objectIndex].style == 0) {
            myTextData.varcontent.clear();
            textItemList[objectIndex].varcontent = myTextData.varcontent;
            eventBus.fire(EventText(myTextData));
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
              eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
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
              eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
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
            eventBus.fire(EventText(myTextData));
            _onUpdate(i);
          }
        }
      });
    }
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

      //添加可拖拽控件的信息

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

  _selectItem() {
    return [
      const SizedBox(height: 100),
      Container(
        height: 50,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text(
          "You haven't selected any element.",
          style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 245, 127, 23),
              fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        height: 50,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text(
          "Operation Steps:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        height: 50,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text(
          "1. Please click on one or more elements on the left side; ",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        height: 80,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text(
          "2. The selected elements will be displayed in the center of the page, and you can edit their attributes here. ",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  TextField buildTextField(TextEditingController controller, String labelText,
      String hintText, int num) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        hintStyle: const TextStyle(fontSize: 20),
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
                              : (num == 9)
                                  ? _focusNodex2Pos
                                  : (num == 10)
                                      ? _focusNodey2Pos
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

  _textproperties() {
    return [
      const SizedBox(height: 20),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text(
          "------------------Attribute------------------",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Tab order:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            myTextData.tabOrder.toString(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        ],
      ),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Type:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(myTextData.type,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
        ],
      ),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text("----------Position--------------",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      TextField(
        enabled: false,
        controller: xPosvar,
        decoration: InputDecoration(
            labelText: "x:", hintText: myTextData.content.toString()),
        onEditingComplete: () {
          _onSubmit(xPosvar.text, 2);
        }, // 点击“完成”按钮后，调用失去焦点方法
        focusNode: _focusNodexPos, // 将FocusNode对象绑定到TextField
      ),
      TextField(
        enabled: false,
        controller: yPosvar,
        decoration: InputDecoration(
            labelStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold), // 设置label字体大小为20
            hintStyle: const TextStyle(fontSize: 20),
            labelText: "y:",
            hintText: (myTextData.yPos + myTextData.height).toString()),
        onEditingComplete: () {
          _onSubmit(yPosvar.text, 3);
        }, // 点击“完成”按钮后，调用失去焦点方法
        focusNode: _focusNodeyPos, // 将FocusNode对象绑定到TextField
      ),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text("----------Editor-----------------",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      buildTextField(
          textvariable, "Text Content", myTextData.content.toString(), 0),
      const Text(
        'Select FontSize:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectFontsize,
        items: _fontSizes,
        hintText: 'FontSize',
        onSelect: _handleFontSizeSelected,
      ),
      const Text(
        'Select Rotation:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectedRotation,
        items: _rotations,
        hintText: 'Rotation',
        onSelect: _handleRotationSelected,
      ),
      // buildTextField(
      //     fontsizevar, "Font Size", myTextData.fontSize.toString(), 1),
      const Text(
        'Font Bold:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectFontBold,
        items: _fontBoldReverse,
        hintText: 'Font bold',
        onSelect: _handleFontBoldSelected,
      ),
      const Text(
        'Font Reverse:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectFontReverse,
        items: _fontBoldReverse,
        hintText: 'Font Reverse',
        onSelect: _handleFontReverseSelected,
      ),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteTextItem(myTextData.tabOrder);
            });
          },
          child: const Text("Delete",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
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
      num.removeAt(indexToRemove);
      // count = 0;
      floatButtonList.clear();
      _parentKey = GlobalKey();

      for (var i = 0; i < temptextItemList.length; i++) {
        // temptextItemList[i].index = i;
        textItemList.add(temptextItemList[i]);

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

  _varproperties() {
    return [
      const SizedBox(height: 20),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text(
          "------------------Attribute------------------",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Tab order:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            myTextData.tabOrder.toString(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Type:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(myTextData.type,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
        ],
      ),
      const SizedBox(height: 20),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text("----------Position--------------",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      TextField(
        enabled: false,
        controller: xPosvar,
        decoration: InputDecoration(
            labelText: "x:", hintText: myTextData.content.toString()),
        onEditingComplete: () {
          _onSubmit(xPosvar.text, 2);
        }, // 点击“完成”按钮后，调用失去焦点方法
        focusNode: _focusNodexPos, // 将FocusNode对象绑定到TextField
      ),
      TextField(
        enabled: false,
        controller: yPosvar,
        decoration: InputDecoration(
            labelStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold), // 设置label字体大小为20
            hintStyle: const TextStyle(fontSize: 20),
            labelText: "y:",
            hintText: myTextData.content.toString()),
        onEditingComplete: () {
          _onSubmit(yPosvar.text, 3);
        }, // 点击“完成”按钮后，调用失去焦点方法
        focusNode: _focusNodeyPos, // 将FocusNode对象绑定到TextField
      ),
      const SizedBox(height: 20),
      buildTextField(
          maxLenthvar, "Max Length", myTextData.maxLength.toString(), 4),
      const SizedBox(width: 10),
      const Text(
        'Alignment:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectedAlignment,
        items: _alignments,
        hintText: 'Alignment',
        onSelect: _handleAlignmentSelected,
      ),
      const SizedBox(height: 20),
      const Text(
        'Select Rotation:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectedRotation,
        items: _rotations,
        hintText: 'Rotation',
        onSelect: _handleRotationSelected,
      ),
      const Text(
        'Select FontSize:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectFontsize,
        items: _fontSizes,
        hintText: 'FontSize',
        onSelect: _handleFontSizeSelected,
      ),
      // buildTextField(
      //     fontsizevar, "Font Size", myTextData.fontSize.toString(), 1),
      const Text(
        'Font Bold:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectFontBold,
        items: _fontBoldReverse,
        hintText: 'Font bold',
        onSelect: _handleFontBoldSelected,
      ),
      const Text(
        'Font Reverse: ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectFontReverse,
        items: _fontBoldReverse,
        hintText: 'Font Reverse',
        onSelect: _handleFontReverseSelected,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteTextItem(myTextData.tabOrder);
            });
          },
          child: const Text("Delete",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
    ];
  }

  _lineproperties() {
    return [
      const SizedBox(height: 20),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text(
          "------------------Attribute------------------",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Tab order:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            myTextData.tabOrder.toString(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Type:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(myTextData.type,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
        ],
      ),
      const SizedBox(height: 20),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text("----------Position--------------",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      buildTextField(xPosvar, "X1", myTextData.xPos.toString(), 2),
      buildTextField(yPosvar, "Y1", myTextData.yPos.toString(), 3),
      buildTextField(x2Posvar, "X2", myTextData.x2Pos.toString(), 9),
      buildTextField(y2Posvar, "Y2", myTextData.y2Pos.toString(), 10),
      const SizedBox(height: 20),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteTextItem(myTextData.tabOrder);
            });
          },
          child: const Text("Delete",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
    ];
  }

  _barCodeproperties() {
    return [
      const SizedBox(height: 20),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text(
          "------------------Attribute------------------",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Tab order:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            myTextData.tabOrder.toString(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Type:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(myTextData.type,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
        ],
      ),
      const SizedBox(height: 20),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text("----------Position--------------",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      TextField(
        enabled: false,
        controller: xPosvar,
        decoration: InputDecoration(
            labelText: "x:", hintText: myTextData.content.toString()),
        onEditingComplete: () {
          _onSubmit(xPosvar.text, 2);
        }, // 点击“完成”按钮后，调用失去焦点方法
        focusNode: _focusNodexPos, // 将FocusNode对象绑定到TextField
      ),
      TextField(
        enabled: false,
        controller: yPosvar,
        decoration: InputDecoration(
            labelStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold), // 设置label字体大小为20
            hintStyle: const TextStyle(fontSize: 20),
            labelText: "y:",
            hintText: myTextData.content.toString()),
        onEditingComplete: () {
          _onSubmit(yPosvar.text, 3);
        }, // 点击“完成”按钮后，调用失去焦点方法
        focusNode: _focusNodeyPos, // 将FocusNode对象绑定到TextField
      ),
      const SizedBox(height: 20),
      const Text(
        'Select barcode:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectedBarcode,
        items: _savedBarCodeNames,
        hintText: 'Barcode',
        onSelect: _handleBarcodeSelected,
      ),
      buildTextField(
          barcodeHeight, "BarCode Height", myTextData.height.toString(), 7),
      const SizedBox(height: 20),
      const Text(
        'Select HR Alignment:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectedHRAlignment,
        items: _hralignments,
        hintText: 'HR Alignment',
        onSelect: _handleHrAlignmentSelected,
      ),
      const Text(
        'Select Rotation:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectedRotation,
        items: _rotations,
        hintText: 'Rotation',
        onSelect: _handleRotationSelected,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteTextItem(myTextData.tabOrder);
            });
          },
          child: const Text("Delete",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
    ];
  }

  _qrcodeproperties() {
    return [
      const SizedBox(height: 20),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text(
          "------------------Attribute------------------",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Tab order:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            myTextData.tabOrder.toString(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          const SizedBox(width: 10),
          const Text("Type:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(myTextData.type,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
        ],
      ),
      const SizedBox(height: 20),
      Container(
        height: 30,
        color: const Color.fromARGB(255, 240, 247, 252),
        child: const Text("----------Position--------------",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      TextField(
        enabled: false,
        controller: xPosvar,
        decoration: InputDecoration(
            labelText: "x:", hintText: myTextData.content.toString()),
        onEditingComplete: () {
          _onSubmit(xPosvar.text, 2);
        }, // 点击“完成”按钮后，调用失去焦点方法
        focusNode: _focusNodexPos, // 将FocusNode对象绑定到TextField
      ),
      TextField(
        enabled: false,
        controller: yPosvar,
        decoration: InputDecoration(
            labelStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold), // 设置label字体大小为20
            hintStyle: const TextStyle(fontSize: 20),
            labelText: "y:",
            hintText: myTextData.content.toString()),
        onEditingComplete: () {
          _onSubmit(yPosvar.text, 3);
        }, // 点击“完成”按钮后，调用失去焦点方法
        focusNode: _focusNodeyPos, // 将FocusNode对象绑定到TextField
      ),
      const SizedBox(height: 20),
      const Text(
        'Select QRcode:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectedQrcode,
        items: _savedQrcodeNames,
        hintText: 'Qrcode',
        onSelect: _handleQrcodeSelected,
      ),
      const SizedBox(height: 20),
      const Text(
        'Select Qrcode Width:      ',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buildDropdownButton(
        value: _selectedQr,
        items: _qrWidths,
        hintText: 'Qrcode Width',
        onSelect: _handleQrWidthSelected,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteTextItem(myTextData.tabOrder);
            });
          },
          child: const Text("Delete",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
    ];
  }
}

// showAddComPortDialog(context).then((onValue) {
//   if (kDebugMode) {
//     print(onValue);
//   }
//   setState(() {
//     // items.add(onValue.toString());
//   });
// });

// final result = await Navigator.push(
//   context,
//   MaterialPageRoute(
//       builder: (context) => BarCodeEditPage(value: 'nihao')),
// );
// setState(() {
//   // value = result;
// });

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
      left: position.dx - 3,
      top: position.dy - 3,
      child: GestureDetector(
        onPanUpdate: (details) => onPositionChanged(position + details.delta),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
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
