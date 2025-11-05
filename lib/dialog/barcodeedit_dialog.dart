import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:path/path.dart' as p;
import 'package:t_max/data/barcodetype.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/widget/custom_button.dart';
import '../../data/barcoderowdata.dart';
import '../../eventbus/eventbus.dart';
import '../widget/rowdatawidget.dart';

class MyBarCodeDialog extends StatefulWidget {
  const MyBarCodeDialog({
    super.key,
  });
  @override
  MyBarCodeDialogState createState() => MyBarCodeDialogState();
}

class MyBarCodeDialogState extends State<MyBarCodeDialog> {
  dynamic _eventbus1;
  late TextEditingController _errorController;
  late TextEditingController _barCodeNameController;
  late String _selectBarcode;
  String _selectedBarcodeName = '--';

  final List<String> _barCodeTypes = [
    'Code128',
    'Code39',
    'EAN13',
    'EAN8',
    'UPC-A',
    'UPC-E',
    // 'TTF',
  ];
  @override
  void initState() {
    _errorController = TextEditingController(text: '');
    _barCodeNameController = TextEditingController(text: '');
    _selectBarcode = 'Code128';
    _eventbus1 = eventBus.on<EventCurrentBarCodeRowDataList>().listen((event) {
      if (mounted) {
        setState(() {
          myBarCodeRowDataList = event.obj;
          _errorController.text = '';
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            children: [
              Icon(Icons.qr_code,
                  color: Theme.of(context).colorScheme.onPrimary),
              Text(localizedStrings.gBarcodeEdit,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary))
            ],
          )),
      content: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        localizedStrings.gBarcodeType,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      DropdownButton<String>(
                        value: _selectBarcode,
                        underline: Container(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectBarcode = newValue!;
                            myBarcodetypedata.barcodetype = _selectBarcode;
                            _onSuggestionSelected("--");
                            _barCodeNameController.clear();
                            eventBus
                                .fire(EventBarcodetypedata(myBarcodetypedata));
                          });
                        },
                        items: _barCodeTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 300,
                    child: Text(
                      localizedStrings.gBarcodeName,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  Container(
                    //屏蔽20241008
                    width: 300,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: TypeAheadField<String>(
                      controller: _barCodeNameController,
                      builder: (context, controller, focusNode) => TextField(
                        controller: _barCodeNameController,
                        focusNode: focusNode,
                        autofocus: true,
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontStyle: FontStyle.italic),
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: localizedStrings.gBarcodeSelect,
                        ),
                      ),
                      itemBuilder: (context, name) => ListTile(
                        title: Text(name),
                      ),
                      onSelected: _onSuggestionSelected,
                      suggestionsCallback: suggestionsCallback,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  CustomOutlinedButton(
                      btnWidth: 150,
                      btnHeight: 40,
                      icon: Icons.add,
                      text: localizedStrings.gBtnAdd,
                      onPressed: _addRowData),
                  const SizedBox(
                    width: 10,
                  ),
                  CustomElevatedButton(
                      btnWidth: 150,
                      btnHeight: 40,
                      icon: Icons.save,
                      text: localizedStrings.gBtnSave,
                      onPressed: _saveRowData),
                  const SizedBox(
                    width: 10,
                  ),
                  CustomOutlinedButton(
                      btnWidth: 150,
                      btnHeight: 40,
                      icon: Icons.delete,
                      text: localizedStrings.gBtnDelete,
                      onPressed: _deleteRowData),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(localizedStrings.gBarCodeDataType,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(localizedStrings.gBarCodeContent,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(localizedStrings.gBarCodeDefValue,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(localizedStrings.gBarCodeAlignment,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(localizedStrings.gBarCodeMaxLength,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(localizedStrings.gBarCodeDelete,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ]),
            Expanded(
              child: ListView.builder(
                itemCount: myBarCodeRowDataList.barCodeRowDataList.length,
                itemBuilder: (context, index) {
                  return RowDataWidget(
                    rowData: myBarCodeRowDataList.barCodeRowDataList[index],
                    rowDataList: myBarCodeRowDataList.barCodeRowDataList,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: 600,
          child: TextField(
            controller: _errorController,
            style: TextStyle(
                color: (_errorController.text.contains("successfully"))
                    ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                    : Theme.of(context).colorScheme.error,
                fontSize: 14,
                fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
                border: OutlineInputBorder(
              borderSide: BorderSide.none,
            )),
            textAlign: TextAlign.start,
            onChanged: (value) {
              // widget.rowData.content = value;
            },
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomOutlinedButton(
              btnWidth: 150,
              btnHeight: 40,
              icon: Icons.exit_to_app,
              text: localizedStrings.gBtnExit,
              onPressed: () {
                myBarCodeRowDataList.barCodeRowDataList.clear();

                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

  List<String> _getTempBarcodeName() {
    List<String> tempList = [];
    tempList.add('--');
    for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
      if (myBarCodeListList.barCodeListList[i].barCodeType == _selectBarcode) {
        tempList.add(myBarCodeListList.barCodeListList[i].barCodeName);
      }
    }
    return tempList;
  }

  //获取建议列表
  Future<List<String>> suggestionsCallback(String pattern) async =>
      Future<List<String>>.delayed(
        Duration(milliseconds: 0),
        () => mySavedBarcodeName.savedBarcodeName.where((option) {
          final optionLower = option.toLowerCase();
          final patternLower = pattern.toLowerCase();
          return optionLower.contains(patternLower) &&
              _getTempBarcodeName().contains(option);
        }).toList(),
      );

// 选择建议项时的处理
  void _onSuggestionSelected(String suggestion) {
    setState(() {
      _errorController.text = '';
      _selectedBarcodeName = suggestion;
      _barCodeNameController.text = suggestion;

      if (suggestion != '--') {
        for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
          var barcode = myBarCodeListList.barCodeListList[i];

          if (barcode.barCodeName == _selectedBarcodeName &&
              barcode.barCodeType != 'Qrcode' &&
              barcode.barCodeType == _selectBarcode) {
            _saveDataList(i);
            eventBus.fire(EventCurrentBarCodeRowDataList(myBarCodeRowDataList));
            break;
          }
        }
      } else {
        myBarCodeRowDataList.barCodeRowDataList.clear();
      }
    });
  }

  Future<File> get _localFile async {
    final directory = p.dirname(Platform.script.toFilePath());
    return File(p.join(directory, 'barcodedata.json'));
  }

  _saveDataList(int i) {
    String type = '';
    String content = '';
    String defaultvalue = '';
    String alignment = '';
    int maxlength = 0;
    List<BarCodeRowData> tempRowDataList = [];
    for (var j = 0;
        j < myBarCodeListList.barCodeListList[i].barCodeRowDataList.length;
        j++) {
      alignment =
          myBarCodeListList.barCodeListList[i].barCodeRowDataList[j].alignment;
      content =
          myBarCodeListList.barCodeListList[i].barCodeRowDataList[j].content;
      defaultvalue = myBarCodeListList
          .barCodeListList[i].barCodeRowDataList[j].defaultvalue;
      maxlength =
          myBarCodeListList.barCodeListList[i].barCodeRowDataList[j].maxlength;
      type = myBarCodeListList.barCodeListList[i].barCodeRowDataList[j].type;

      tempRowDataList.add(
          BarCodeRowData(type, content, defaultvalue, alignment, maxlength));
    }
    myBarCodeRowDataList.barCodeRowDataList = tempRowDataList;
  }

  _saveDataToJson() async {
    if (myBarCodeListList.barCodeListList.isNotEmpty) {
      String json = jsonEncode(myBarCodeListList.barCodeListList);
      if (kDebugMode) {
        print(json);
      }
      final file = await _localFile;
      // 将字符串写入文件中
      file.writeAsStringSync(json);

      // await loadData();   此处已经写好了如何捞回来条码信息
    }
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

  Future<Map<String, dynamic>?> loadData() async {
    try {
      final file = await _localFile;
      // 从文件中读取字符串
      String contents = await file.readAsString();
      // 将字符串解码为JSON数据
      pasterBarcodeList(contents);
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
  }

  void _addRowData() {
    if (_barCodeNameController.text != '--') {
      setState(() {
        myBarCodeRowDataList.barCodeRowDataList
            .add(BarCodeRowData('TEXT', '', '', 'Left', 7));
      });
    } else {
      _errorController.text =
          'The barcode name is invalid. Please enter a valid name.';
    }
  }

  bool _judgeData() {
    bool res = true;

    if (_barCodeNameController.text.isNotEmpty &&
        myBarCodeRowDataList.barCodeRowDataList.isNotEmpty) {
      for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
        if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
          if (myBarCodeRowDataList.barCodeRowDataList[i].content.isEmpty) {
            _errorController.text = 'Content missing.';
            res = false;
          }
        } else {
          if (myBarCodeRowDataList.barCodeRowDataList[i].alignment == '--' ||
              myBarCodeRowDataList.barCodeRowDataList[i].maxlength == 0) {
            _errorController.text =
                'Variable alignment cannot be empty or have a length of 0. Please check';
            res = false;
          }
        }
      }
    } else {
      _errorController.text =
          'Barcode name not entered or content is empty, please check!';
      res = false;
    }
    return res;
  }

// 'Code128',
  // 'Code39',
  // 'EAN13',
  // 'EAN8',
  // 'UPC-A',
  // 'UPC-E',
  // 'TTF',
  bool _barcodeTypeVerification() {
    bool res = false;

    switch (_selectBarcode) {
      case 'Code128':
        res = _code128Verification();
        break;
      case 'Code39':
        res = _code139Verification();
        break;
      case 'EAN13':
        res = _ean13Verification();
        break;
      case 'EAN8':
        res = _ean8Verification();
        break;
      case 'UPC-A':
        res = _upcaVerification();
        break;
      case 'UPC-E':
        res = _upceVerification();
        break;
      case 'TTF':
        break;
      default:
    }
    return res;
  }

  bool _code128Verification() {
    bool res = true;
    int count = 0;
    bool isLegal = false;
    RegExp regex = RegExp(r'^[\x00-\x7F\xC8-\xDD]+$');

    for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
      if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
        count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
        isLegal =
            regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
        if (!isLegal) {
          _errorController.text =
              'The content does not meet barcode requirements!';
          res = false;
          break;
        }
      } else {
        count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
        if (myBarCodeRowDataList
            .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
          isLegal = regex.hasMatch(
              myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
          if (!isLegal) {
            _errorController.text =
                'The default value does not meet barcode requirements!';
            res = false;
            break;
          }
        } else {
          for (var j = 0;
              j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
              j++) {
            myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
                myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
                    j.toString();
          }
        }
      }
    }
    if (count > 128) {
      res = false;
      _errorController.text = 'The barcode lenth max lenth!';
    }

    return res;
  }

  bool _code139Verification() {
    bool res = true;
    int count = 0;
    bool isLegal = false;
    RegExp regex = RegExp(r'^[\x00-\x7F\xC8-\xDD]+$');

    for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
      if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
        count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
        isLegal =
            regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
        if (!isLegal) {
          _errorController.text =
              'The content does not meet barcode requirements!';
          res = false;
          break;
        }
      } else {
        count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
        if (myBarCodeRowDataList
            .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
          isLegal = regex.hasMatch(
              myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
          if (!isLegal) {
            _errorController.text =
                'The default value does not meet barcode requirements!';
            res = false;
            break;
          }
        } else {
          for (var j = 0;
              j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
              j++) {
            myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
                myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
                    j.toString();
          }
        }
      }
    }
    if (count > 39) {
      res = false;
      _errorController.text = 'The barcode lenth max lenth!';
    }

    return res;
  }

  bool _ean13Verification() {
    bool res = true;
    int count = 0;
    bool isLegal = false;
    RegExp regex = RegExp(r'\d{0,12}');

    for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
      if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
        count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
        isLegal =
            regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
        if (!isLegal) {
          _errorController.text =
              'The content does not meet barcode requirements!';
          res = false;
          break;
        }
      } else {
        count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
        if (myBarCodeRowDataList
            .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
          isLegal = regex.hasMatch(
              myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
          if (!isLegal) {
            _errorController.text =
                'The default value does not meet barcode requirements!';
            res = false;
            break;
          }
        } else {
          for (var j = 0;
              j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
              j++) {
            myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
                myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
                    j.toString();
          }
        }
      }
    }
    if (count != 12) {
      res = false;
      _errorController.text = 'The length of the barcode should be 12.!';
    }

    return res;
  }

  bool _ean8Verification() {
    bool res = true;
    int count = 0;
    bool isLegal = false;
    RegExp regex = RegExp(r'\d{0,7}');

    for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
      if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
        count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
        isLegal =
            regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
        if (!isLegal) {
          _errorController.text =
              'The content does not meet barcode requirements!';
          res = false;
          break;
        }
      } else {
        count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
        if (myBarCodeRowDataList
            .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
          isLegal = regex.hasMatch(
              myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
          if (!isLegal) {
            _errorController.text =
                'The default value does not meet barcode requirements!';
            res = false;
            break;
          }
        } else {
          for (var j = 0;
              j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
              j++) {
            myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
                myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
                    j.toString();
          }
        }
      }
    }
    if (count != 7) {
      res = false;
      _errorController.text = 'The length of the barcode should be 7!';
    }

    return res;
  }

  bool _upceVerification() {
    bool res = true;
    int count = 0;
    bool isLegal = false;
    RegExp regex = RegExp(r'\d{0,6}');

    for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
      if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
        count = myBarCodeRowDataList.barCodeRowDataList[i].content.length;
        isLegal =
            regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
        if (!isLegal) {
          _errorController.text =
              'The content does not meet barcode requirements!';
          res = false;
          break;
        }
      } else {
        count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
        if (myBarCodeRowDataList
            .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
          isLegal = regex.hasMatch(
              myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
          if (!isLegal) {
            _errorController.text =
                'The default value does not meet barcode requirements!';
            res = false;
            break;
          }
        } else {
          for (var j = 0;
              j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
              j++) {
            myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
                myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
                    j.toString();
          }
        }
      }
    }
    if (count != 6) {
      res = false;
      _errorController.text = 'The length of the barcode should be 6!';
    }

    return res;
  }

  bool _upcaVerification() {
    bool res = true;
    int count = 0;
    bool isLegal = false;
    RegExp regex = RegExp(r'\d{0,11}');

    for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
      if (myBarCodeRowDataList.barCodeRowDataList[i].type == 'TEXT') {
        count += myBarCodeRowDataList.barCodeRowDataList[i].content.length;
        isLegal =
            regex.hasMatch(myBarCodeRowDataList.barCodeRowDataList[i].content);
        if (!isLegal) {
          _errorController.text =
              'The content does not meet barcode requirements!';
          res = false;
          break;
        }
      } else {
        count += myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
        if (myBarCodeRowDataList
            .barCodeRowDataList[i].defaultvalue.isNotEmpty) {
          isLegal = regex.hasMatch(
              myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue);
          if (!isLegal) {
            _errorController.text =
                'The default value does not meet barcode requirements!';
            res = false;
            break;
          }
        } else {
          for (var j = 0;
              j < myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
              j++) {
            myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue =
                myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue +
                    j.toString();
          }
        }
      }
    }
    if (count != 11) {
      res = false;
      _errorController.text = 'The length of the barcode should be 6!';
    }

    return res;
  }

  void _saveRowData() {
    setState(() {
      if (!_judgeData()) {
        return;
      }
      if (!_barcodeTypeVerification()) {
        return;
      }

      bool result = true;
      myBarCodeRowDataList.barCodeName = _barCodeNameController.text;
      myBarCodeRowDataList.barCodeType = _selectBarcode;
      String tempName = _barCodeNameController.text;

      if (myBarCodeListList.barCodeListList.isNotEmpty) {
        for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
          if (myBarCodeListList.barCodeListList[i].barCodeName ==
              myBarCodeRowDataList.barCodeName) {
            myBarCodeListList.barCodeListList.removeAt(i);
            _savingData(tempName);
            result = false;
          }
        }
        if (result) {
          _savingData(tempName);
        }
      } else {
        _savingData(tempName);
      }
    });
  }

  void _savingData(String tempName) {
    String type = '';
    String content = '';
    String defaultvalue = '';
    String alignment = '';
    int maxlength = 0;
    List<BarCodeRowData> tempRowDataList = [];
    for (var i = 0; i < myBarCodeRowDataList.barCodeRowDataList.length; i++) {
      alignment = myBarCodeRowDataList.barCodeRowDataList[i].alignment;
      content = myBarCodeRowDataList.barCodeRowDataList[i].content;
      defaultvalue = myBarCodeRowDataList.barCodeRowDataList[i].defaultvalue;
      maxlength = myBarCodeRowDataList.barCodeRowDataList[i].maxlength;
      type = myBarCodeRowDataList.barCodeRowDataList[i].type;

      tempRowDataList.add(
          BarCodeRowData(type, content, defaultvalue, alignment, maxlength));
    }
    myBarCodeListList.barCodeListList.add(BarCodeRowDataInfo(
      tempRowDataList,
      _barCodeNameController.text,
      _selectBarcode,
    ));
    _errorController.text = 'Barcode  ($tempName) saved successfully!';
    _saveBarCodeNameToList();
    _saveDataToJson();
  }

  void _deleteRowData() {
    setState(() {
      if (_barCodeNameController.text.isNotEmpty) {
        for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
          if (myBarCodeListList.barCodeListList[i].barCodeName ==
                  _barCodeNameController.text &&
              myBarCodeListList.barCodeListList[i].barCodeType != 'Qrcode') {
            myBarCodeListList.barCodeListList.removeAt(i);
          }
        }
      }
      _saveBarCodeNameToList();
      myBarCodeRowDataList.barCodeRowDataList.clear();
      // myBarCodeRowDataList.barCodeRowDataList
      //     .removeWhere((rowData) => rowData.canDelete);
    });
  }
}
