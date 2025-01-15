import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:path/path.dart' as p;
import 'package:t_max/data/language.dart';

import '../../data/barcoderowdata.dart';
import '../../eventbus/eventbus.dart';
import '../widget/custom_button.dart';
import '../widget/rowdatawidget.dart';

class MyQrcodeDialog extends StatefulWidget {
  const MyQrcodeDialog({super.key});
  @override
  MyQrcodeDialogState createState() => MyQrcodeDialogState();
}

class MyQrcodeDialogState extends State<MyQrcodeDialog> {
  dynamic _eventbus1;
  late TextEditingController _errorController;
  late TextEditingController _qrCodeNameController;
  String _selectedQrcodeName = '--';
  @override
  void initState() {
    _errorController = TextEditingController(text: '');
    _qrCodeNameController = TextEditingController(text: '');

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
              Text("Qrcode Edit",
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: 800,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 300,
                        child: Text(
                          'Qrcode Name:',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 400,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          child: TypeAheadField<String>(
                            controller: _qrCodeNameController,
                            builder: (context, controller, focusNode) =>
                                TextField(
                              controller: _qrCodeNameController,
                              focusNode: focusNode,
                              autofocus: true,
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(fontStyle: FontStyle.italic),
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: 'Enter name to create/select.',
                              ),
                            ),
                            itemBuilder: (context, name) => ListTile(
                              title: Text(name),
                            ),
                            onSelected: _onSuggestionSelected,
                            suggestionsCallback: suggestionsCallback,
                          ),
                        ),
                      )
                    ],
                  ),
                )),
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
                      text: 'Delete All',
                      onPressed: _deleteRowData),
                ],
              ),
            ),
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DATA TYPE",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Content",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Default Value",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                  Text("Alignment",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Max Length",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text("Delete",
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
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : Theme.of(context).colorScheme.error,
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

  void _onSuggestionSelected(String suggestion) {
    setState(() {
      _errorController.text = '';
      _selectedQrcodeName = suggestion;
      _qrCodeNameController.text = suggestion;
      if (suggestion != '--') {
        for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
          if (myBarCodeListList.barCodeListList[i].barCodeName ==
                  _selectedQrcodeName &&
              myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode') {
            _saveDataList(i);
            eventBus.fire(EventCurrentBarCodeRowDataList(myBarCodeRowDataList));
            break;
          }
        }
      } else {
        myBarCodeRowDataList.barCodeRowDataList.clear();
        myBarCodeListList;
      }
    });
  }

  //获取建议列表
  Future<List<String>> suggestionsCallback(String pattern) async =>
      Future<List<String>>.delayed(
        Duration(milliseconds: 0),
        () => mySavedQrcodeName.savedQrcodeName.where((option) {
          final optionLower = option.toLowerCase();
          final patternLower = pattern.toLowerCase();
          return optionLower.contains(patternLower);
          // &&              _getTempQrcodeName().contains(option);
        }).toList(),
      );

  Future<File> get _localFile async {
    final directory = p.dirname(Platform.script.toFilePath());
    return File(p.join(directory, 'barcodedata.json'));
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
    if (_qrCodeNameController.text != '--') {
      setState(() {
        myBarCodeRowDataList.barCodeRowDataList
            .add(BarCodeRowData('TEXT', '', '', 'Left', 7));
      });
    } else {
      _errorController.text =
          'The Qrcode name is invalid. Please enter a valid name.';
    }
  }

  bool _judgeData() {
    bool res = true;
    if (_qrCodeNameController.text.isNotEmpty &&
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
          'Qrcode name not entered or content is empty, please check!';
      res = false;
    }
    return res;
  }

  void _saveRowData() {
    setState(() {
      if (!_judgeData()) {
        return;
      }
      bool result = true;
      myBarCodeRowDataList.barCodeName = _qrCodeNameController.text;
      myBarCodeRowDataList.barCodeType = 'Qrcode';
      String tempName = _qrCodeNameController.text;

      if (myBarCodeListList.barCodeListList.isNotEmpty) {
        for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
          if (myBarCodeListList.barCodeListList[i].barCodeName ==
                  myBarCodeRowDataList.barCodeName &&
              myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode') {
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
    myBarCodeListList.barCodeListList.add(BarCodeRowDataList(
      tempRowDataList,
      _qrCodeNameController.text,
      'Qrcode',
    ));
    _errorController.text = 'Qrcode  ($tempName) saved successfully!';
    _saveQrcodeNameToList();
    _saveDataToJson();
  }

  // void _savingData(String tempName) {
  //   myBarCodeListList.barCodeListList.add(BarCodeRowDataList(
  //       myBarCodeRowDataList.barCodeRowDataList,
  //       myBarCodeRowDataList.barCodeName,
  //       myBarCodeRowDataList.barCodeType));
  //   _errorController.text = 'Qrcode  ($tempName) saved successfully!';
  //   _saveQrcodeNameToList();
  //   _saveDataToJson();
  // }

  void _deleteRowData() {
    setState(() {
      if (_qrCodeNameController.text.isNotEmpty) {
        for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
          if (myBarCodeListList.barCodeListList[i].barCodeName ==
                  _qrCodeNameController.text &&
              myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode') {
            myBarCodeListList.barCodeListList.removeAt(i);
          }
        }
      }
      _saveQrcodeNameToList();
      myBarCodeRowDataList.barCodeRowDataList.clear();
      // myBarCodeRowDataList.barCodeRowDataList
      //     .removeWhere((rowData) => rowData.canDelete);
    });
  }
}
