import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/main.dart';
import '../data/custom_serial_protocol_text_dart.dart';
import '../data/download_prt_fmt.dart';
import '../data/downloadresponse.dart';
import '../data/scalecmd_data.dart';
import '../data/writelog.dart';
import '../eventbus/eventbus.dart';
import '../generated/l10n.dart';
import 'package:path/path.dart' as p;

class CustomSerialProtocol extends StatefulWidget {
  const CustomSerialProtocol({Key? key}) : super(key: key);

  @override
  State<CustomSerialProtocol> createState() => _CustomSerialProtocolState();
}

class _CustomSerialProtocolState extends State<CustomSerialProtocol> {
  final List<SerialProtocolText> _textListOl = [];
  final List<SerialProtocolText> _textListUl = [];
  final List<SerialProtocolText> _textListWeight = [];
  final List<SerialProtocolText> _textListPcs = [];
  final List<SerialProtocolText> _textListPrice = [];
  final List<SerialProtocolText> _textListPercent = [];
  final textController = TextEditingController();
  final RegExp englishRegExp = RegExp(r'^[\x00-\x7F]*$');

  List<String> outputData = [];

  String _selectedAlignment = 'left';
  String _selectedFilling = 'space';
  int _selectedDecimal = 3;
  List<String> alignments = ['left', 'right'];
  List<String> fillings = ['0', 'space'];
  List<int> decimals = [0, 1, 2, 3, 4];
  Map<String, int> pageMap = {
    "OL": 1,
    "UL": 2,
    "Weight": 3,
    "Pcs": 4,
    "Price": 5,
    "Percent": 6,
  };

  int count = 0;
  List<String> jsonFilesList = [];
  late int _currentPageIndex;
  String pageTitle = '';
  late ColorScheme colorScheme;
  bool isArrowBackHovered = false;
  bool isArrowForwardHovered = false;
  bool serialPreview = false;
  bool _isHexDisplay = false;

  TextEditingController myContentCtl =
      TextEditingController(text: mySerialProtocolText.content);
  TextEditingController myMaxLenCtl =
      TextEditingController(text: mySerialProtocolText.maxLength.toString());
  TextEditingController myBoolTypeTrueCtl =
      TextEditingController(text: mySerialProtocolText.isTrue);
  TextEditingController myBoolTypeFalseCtl =
      TextEditingController(text: mySerialProtocolText.isFalse);
  final List<String> _buttonLabels = [
    'Text',
    'Net',
    'Gross',
    'Tare',
    'WeightUnit',
    'isstable',
    'istare',
    'PCS',
  ];

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  final ScrollController _scrollController = ScrollController();

  bool isListEmpty() {
    if (_textListOl.isNotEmpty ||
        _textListPcs.isNotEmpty ||
        _textListPercent.isNotEmpty ||
        _textListPrice.isNotEmpty ||
        _textListUl.isNotEmpty ||
        _textListWeight.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    _currentPageIndex = 3;
    super.initState();
    // _serialOutputDataCtl.addListener(scrollToBottom); // 监听文本变化
    _eventbus1 = eventBus.on<EventSerialOutputResp>().listen((event) {
      if (mounted) {
        setState(() {
          mySetSerialOutputResp = event.obj;
          if (mySetSerialOutputResp.msgBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    (mySetSerialOutputResp.msgBody.contains('ok'))
                        ? 'Download successful!'
                        : mySetSerialOutputResp.msgBody,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal)), ////此处需要秤回复
                duration: const Duration(seconds: 3),
                backgroundColor: (mySetSerialOutputResp.msgBody.contains('ok'))
                    ? Colors.green.shade900
                    : Colors.red.shade900));
          }
        });
      }
    });
    _eventbus2 = eventBus.on<EventScalePassthData>().listen((event) {
      if (mounted) {
        if (serialPreview) {
          setState(() {
            myScalePassthData = event.obj;
            outputData.add(myScalePassthData.msgBody);
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
        myOpenScalePassthData = event.obj;
        setState(() {});
      }
    });

    _eventbus4 = eventBus.on<EventCloseScalePassthResp>().listen((event) {
      if (mounted) {
        myCloseScalePassthData = event.obj;
        if (myCloseScalePassthData.msgBody.contains('ok')) {
          PublicFunctions.stopWeight();
        }
      }
    });

    _eventbus5 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRegWeightResp = event.obj;

        PublicFunctions.openScalePassth();
      }
    });
  }

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    colorScheme = Theme.of(context).colorScheme;
    pageTitle = getTitleName(_currentPageIndex);

    // Color buttonColor =
    //     !serialPreview ? colorScheme.primary : colorScheme.secondaryContainer;
    // Color borderColor = colorScheme.primary;
    // ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    //   backgroundColor: buttonColor,
    //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(4),
    //     side: BorderSide(width: 1, color: borderColor),
    //   ),
    // );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          height: 50,
          width: screenSize.width - 10,
          color: colorScheme.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: 240,
                  child: Text(
                    localizedStrings.serial_output,
                    style:
                        TextStyle(fontSize: 20, color: colorScheme.onPrimary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      flex: 1, // 设置子部件占用空间的比例
                      child: Column(
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
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .onPrimary, // 设置按钮的背景色
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(4), // 设置按钮的圆角
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.home,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    Text(
                                      localizedStrings.button_home,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () {
                                PublicFunctions.closeScalePassth();
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      )),
                  Divider(
                    height: 2,
                    color: colorScheme.primary,
                  ),
                  Expanded(
                    flex: 6, // 设置子部件占用空间的比例
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
                ],
              )),
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                  color: colorScheme.onPrimary,
                  border: Border.all(width: 0.2, color: Colors.black)),
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
              flex: 5,
              child: Column(
                children: [
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  Expanded(
                    flex: 1, // 设置子部件占用空间的比例
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: (!serialPreview && isListEmpty())
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .background, // 设置按钮的背景色
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(4), // 设置按钮的圆角
                              ),
                            ),
                            child: Center(
                              child: Text(
                                localizedStrings.download,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            onPressed: (!serialPreview && isListEmpty())
                                ? () async {
                                    jsonFilesList.clear();
                                    for (var i = 1; i < 7; i++) {
                                      await generateJson(i);
                                    }
                                    await generateFileList();
                                    if (jsonFilesList.isNotEmpty) {
                                      PublicFunctions.sendOutoutFmtToScale(
                                          jsonFilesList);
                                    }
                                  }
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                width: 1,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: !serialPreview
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .background, // 设置按钮的背景色
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(4), // 设置按钮的圆角
                              ),
                            ),
                            child: Center(
                              child: Text(
                                localizedStrings.open_preview,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            onPressed:
                                !serialPreview ? handleButtonPress : null,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                width: 1,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary, // 设置按钮的背景色
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(4), // 设置按钮的圆角
                              ),
                            ),
                            child: Center(
                              child: Text(
                                localizedStrings.close_preview,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                serialPreview = false;
                                outputData.clear();
                              });
                              PublicFunctions.closeScalePassth();
                              // PublicFunctions.stopWeight();
                            },
                          ),
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
                            children:
                                (getListName(_currentPageIndex).isNotEmpty &&
                                        mySerialProtocolText.type == 'Bool' &&
                                        mySerialProtocolText.tabOrder != 9999 &&
                                        (mySerialProtocolText.varName ==
                                                'isstable' ||
                                            mySerialProtocolText.varName ==
                                                'istare'))
                                    ? _boolProperty()
                                    : (getListName(_currentPageIndex)
                                                .isNotEmpty &&
                                            mySerialProtocolText.type ==
                                                'TEXT' &&
                                            mySerialProtocolText.tabOrder !=
                                                9999)
                                        ? _textProperty()
                                        : (getListName(_currentPageIndex)
                                                    .isNotEmpty &&
                                                mySerialProtocolText.type ==
                                                    'String' &&
                                                mySerialProtocolText.tabOrder !=
                                                    9999)
                                            ? _stringProperty()
                                            : (getListName(_currentPageIndex)
                                                        .isNotEmpty &&
                                                    mySerialProtocolText
                                                            .type ==
                                                        'Enter')
                                                ? _enterProperty()
                                                : (getListName(_currentPageIndex)
                                                            .isNotEmpty &&
                                                        mySerialProtocolText
                                                                .type ==
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
                                                            mySerialProtocolText
                                                                    .tabOrder !=
                                                                9999)
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
                                            side: MaterialStateProperty
                                                .resolveWith<BorderSide>(
                                              (Set<MaterialState> states) {
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
                                            localizedStrings.clear_btn,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                      OutlinedButton(
                                          style: ButtonStyle(
                                            backgroundColor: _isHexDisplay
                                                ? MaterialStateProperty.all(
                                                    colorScheme.primary)
                                                : MaterialStateProperty.all(
                                                    colorScheme.onPrimary),
                                            side: MaterialStateProperty
                                                .resolveWith<BorderSide>(
                                              (Set<MaterialState> states) {
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
                                              _isHexDisplay = !_isHexDisplay;
                                            });
                                            PublicFunctions.changeScalePassth(
                                                _isHexDisplay);
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
                                      color: Colors.blue, // 边框颜色
                                      width: 2.0, // 边框宽度
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)), // 边框圆角
                                  ),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(10.0), // 添加边距
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
              ))
        ],
      ),
    );
  }

  void handleButtonPress() async {
    setState(() {
      serialPreview = true;
      _isHexDisplay = false;
      outputData.clear();
    });
    PublicFunctions.getWeight();
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
                side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
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

  SizedBox secondPageBuild(int pageId) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 30,
            child: Center(
              child: Text(
                localizedStrings.serial_port_output_preview,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            color: colorScheme.primary,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: colorScheme.tertiary,
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
      return _textListOl;
    } else if (pageId == pageMap["UL"]) {
      return _textListUl;
    } else if (pageId == pageMap["Weight"]) {
      return _textListWeight;
    } else if (pageId == pageMap["Pcs"]) {
      return _textListPcs;
    } else if (pageId == pageMap["Price"]) {
      return _textListPrice;
    } else if (pageId == pageMap["Percent"]) {
      return _textListPercent;
    }
    return _textListWeight;
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
        res = res + '\r\n';
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
        color: colorScheme.tertiary,
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
              borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
            ),
          ),
          child: const Text('Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
    for (var i = 0; i < _textListWeight.length; i++) {
      if (_textListWeight[i].tabOrder == index) {
        if (defaultIndex == 1) {
          _textListWeight[i].isTrue = data;
        } else {
          _textListWeight[i].isFalse = data;
        }

        break;
      }
    }
  }

  _enterProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.tertiary,
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
              borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
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
        color: colorScheme.tertiary,
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

//变量编辑属性
  _stringProperty() {
    return [
      Container(
        height: 40,
        color: colorScheme.tertiary,
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
      dropdownColor: colorScheme.background,
      style: TextStyle(
          color: colorScheme.onBackground,
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
      dropdownColor: colorScheme.background,
      style: TextStyle(
          color: colorScheme.onBackground,
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
      dropdownColor: colorScheme.background,
      style: TextStyle(
          color: colorScheme.onBackground,
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
        color: colorScheme.tertiary,
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
        color: colorScheme.tertiary,
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
            borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
          ),
        ),
        child: const Text('Delete',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
              color:
                  !isArrowBackHovered ? Colors.white : colorScheme.background,
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
                  ? Colors.white
                  : colorScheme.background,
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
    } else if (varname == 'Gross' || varname == 'Tare' || varname == 'Net') {
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
                ? MaterialStateProperty.all(colorScheme.primary)
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
              color: (textData.isSelect) ? Colors.white : colorScheme.primary),
        ),
      ),
    );
  }

  Future<bool> generateJson(int pageId) async {
    List<Map<String, dynamic>> functionList = [];
    List<Map<String, dynamic>> dataList = [];
    List<SerialProtocolText> list = getListName(pageId);
    if (list.isEmpty) {
      return false;
    }
    int functionId = 0;
    for (var i = 0; i < list.length; i++) {
      if (list[i].type == 'TEXT') {
        dataList.add({"isvar": false, "value": list[i].content});
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
        jsonFilesList.add('$i' + filePath);
      }
    }
  }
}
