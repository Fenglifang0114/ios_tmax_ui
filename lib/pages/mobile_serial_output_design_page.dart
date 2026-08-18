import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:t_max/data/custom_serial_protocol_text_dart.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/pages/mobile_sel_scales_page.dart';
import 'package:t_max/pages/mobile_serial_property_edit_page.dart';
import 'package:t_max/pages/mobile_serial_preview_page.dart';
import 'package:t_max/pages/update_firmware_page.dart';
import 'package:t_max/dialog/mobile_page_help_dialog.dart';

class MobileSerialOutputDesignPage extends StatefulWidget {
  const MobileSerialOutputDesignPage({super.key});

  @override
  State<MobileSerialOutputDesignPage> createState() =>
      _MobileSerialOutputDesignPageState();
}

class _MobileSerialOutputDesignPageState
    extends State<MobileSerialOutputDesignPage> {
  // Lists for 6 modes
  List<SerialProtocolText> textListOl = [];
  List<SerialProtocolText> textListUl = [];
  List<SerialProtocolText> textListWgt = [];
  List<SerialProtocolText> textListPcs = [];
  List<SerialProtocolText> textListPrice = [];
  List<SerialProtocolText> textListPct = [];
  List<String> jsonFilesList = [];

  int currentModeId = 3; // Default Weight mode (3)
  SerialProtocolText? selectedItem;
  int count = 0;
  int currentPageOffset = 0;
  final int itemsPerPage = 16; // 4 columns x 4 rows

  final Map<String, int> modeMap = {
    "Weight mode": 3,
    "OLmode": 1,
    "UL mode": 2,
    "Counting mode": 4,
    "Price Computing mode": 5,
    "Percent mode": 6,
  };

  final List<String> insertableLabels = [
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
    'Enter',
  ];

  @override
  void initState() {
    super.initState();
    initOutputList();
  }

  Future<Directory> getJsonFileDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory(p.join(dir.path, 'output'));
  }

  void initOutputList() async {
    try {
      final formatfilePath = await getJsonFileDir();
      if (!await formatfilePath.exists()) {
        return;
      } else {
        var directory = formatfilePath.path;

        var filePath1 = p.join(directory, 'Weight.json');
        textListWgt = await loadJsonData(filePath1);
        var filePath2 = p.join(directory, 'UL.json');
        textListUl = await loadJsonData(filePath2);
        var filePath3 = p.join(directory, 'OL.json');
        textListOl = await loadJsonData(filePath3);
        var filePath4 = p.join(directory, 'Pcs.json');
        textListPcs = await loadJsonData(filePath4);
        var filePath5 = p.join(directory, 'Price.json');
        textListPrice = await loadJsonData(filePath5);
        var filePath6 = p.join(directory, 'Percent.json');
        textListPct = await loadJsonData(filePath6);
      }
      setState(() {});
    } catch (e) {
      if (kDebugMode) print(e);
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
        return false;
      }
    } else {
      return false;
    }
  }

  Future<List<SerialProtocolText>> loadJsonData(String filePath) async {
    List<SerialProtocolText> textList = [];
    if (File(filePath).existsSync()) {
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
              orElse: () => FunctionData(id: -1, type: '', description: ''));
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
                funcData.alignment ?? 'left',
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
          } else if (item.varname == 'isstable' || item.varname == 'istare') {
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
                funcData.istrue ?? '1',
                funcData.isfalse ?? '0',
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
                funcData.alignment ?? 'left',
                item.length!,
                ++count,
                '',
                '',
                filling,
                funcData.decimal ?? 3,
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
                funcData.alignment ?? 'left',
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
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return tempList;
  }

  List<SerialProtocolText> _getCurrentList() {
    if (currentModeId == 1) return textListOl;
    if (currentModeId == 2) return textListUl;
    if (currentModeId == 3) return textListWgt;
    if (currentModeId == 4) return textListPcs;
    if (currentModeId == 5) return textListPrice;
    if (currentModeId == 6) return textListPct;
    return textListWgt;
  }

  String _getCurrentModeName() {
    return modeMap.entries
        .firstWhere((e) => e.value == currentModeId,
            orElse: () => const MapEntry("Weight mode", 3))
        .key;
  }

  void _showChoiceModeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Choice mode",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...modeMap.keys.map((modeName) {
                    final isSelected = modeMap[modeName] == currentModeId;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentModeId = modeMap[modeName]!;
                            selectedItem = null;
                            currentPageOffset = 0;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? const Color(0xFF005696)
                              : const Color(0xFFF6F6F6),
                          foregroundColor:
                              isSelected ? Colors.white : Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(modeName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal)),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleInsertLabel(String label) {
    List<SerialProtocolText> list = _getCurrentList();
    setState(() {
      if (label == 'Text') {
        _addTextData(currentModeId);
      } else if (label == 'Text_Hex') {
        _addTextHexData(currentModeId);
      } else if (label == 'Enter') {
        _addEnter(currentModeId);
      } else {
        _addVarData(label, currentModeId);
      }
      if (list.isNotEmpty) {
        selectedItem = list.last;
      }
    });
  }

  void _addEnter(int modeId) {
    List<SerialProtocolText> list = _getCurrentList();
    final item = SerialProtocolText('Enter', '\\r\\n', '', 'left', 0,
        ++count, '', '', '', 0, '', false);
    list.add(item);
    mySerialProtocolText = item;
  }

  void _addTextData(int modeId) {
    List<SerialProtocolText> list = _getCurrentList();
    final item = SerialProtocolText(
        'TEXT', 'Test', '', 'left', 7, ++count, '', '', '', 0, '', false);
    list.add(item);
    mySerialProtocolText = item;
  }

  void _addTextHexData(int modeId) {
    List<SerialProtocolText> list = _getCurrentList();
    final item = SerialProtocolText('TEXT_HEX', '54 65 73 74', '', 'left',
        7, ++count, '', '', '', 0, '', false);
    list.add(item);
    mySerialProtocolText = item;
  }

  void _addVarData(String varName, int modeId) {
    List<SerialProtocolText> list = _getCurrentList();
    String type = 'String';
    if (varName == 'Net' ||
        varName == 'Gross' ||
        varName == 'Tare' ||
        varName == 'PCS' ||
        varName == 'Percent') {
      type = 'Float';
    } else if (varName == 'isstable' || varName == 'istare') {
      type = 'Bool';
    }

    final item = SerialProtocolText(type, varName, varName, 'left', 7,
        ++count, '1', '0', 'space', 3, 'kg', false);
    list.add(item);
    mySerialProtocolText = item;
  }

  void _openEditProperty(SerialProtocolText item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MobileSerialPropertyEditPage(
          item: item,
          onDelete: () {
            setState(() {
              _getCurrentList().remove(item);
              selectedItem = null;
            });
          },
          onConfirm: (updated) {
            setState(() {
              selectedItem = updated;
            });
          },
        ),
      ),
    );
  }

  bool _canMoveLeft() {
    final list = _getCurrentList();
    if (selectedItem != null) {
      return list.indexOf(selectedItem!) > 0;
    }
    return currentPageOffset > 0;
  }

  bool _canMoveRight() {
    final list = _getCurrentList();
    if (selectedItem != null) {
      int idx = list.indexOf(selectedItem!);
      return idx >= 0 && idx < list.length - 1;
    }
    return (currentPageOffset + 1) * itemsPerPage < list.length;
  }

  void _moveSelectedItemLeft() {
    final list = _getCurrentList();
    if (selectedItem != null) {
      int idx = list.indexOf(selectedItem!);
      if (idx > 0) {
        setState(() {
          final temp = list[idx];
          list[idx] = list[idx - 1];
          list[idx - 1] = temp;

          if (idx - 1 < currentPageOffset * itemsPerPage) {
            currentPageOffset = (idx - 1) ~/ itemsPerPage;
          }
        });
      }
    } else if (currentPageOffset > 0) {
      setState(() {
        currentPageOffset--;
      });
    }
  }

  void _moveSelectedItemRight() {
    final list = _getCurrentList();
    if (selectedItem != null) {
      int idx = list.indexOf(selectedItem!);
      if (idx >= 0 && idx < list.length - 1) {
        setState(() {
          final temp = list[idx];
          list[idx] = list[idx + 1];
          list[idx + 1] = temp;

          if (idx + 1 >= (currentPageOffset + 1) * itemsPerPage) {
            currentPageOffset = (idx + 1) ~/ itemsPerPage;
          }
        });
      }
    } else if ((currentPageOffset + 1) * itemsPerPage < list.length) {
      setState(() {
        currentPageOffset++;
      });
    }
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

  String _getPreviewString() {
    List<SerialProtocolText> list = _getCurrentList();
    return outPutData(list);
  }

  bool validateHexStringWithSpaces(String text) {
    text = text.replaceAll(' ', '');
    final RegExp hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegExp.hasMatch(text) && text.length % 2 == 0;
  }

  Future<bool> generateJson(int pageId) async {
    List<Map<String, dynamic>> functionList = [];
    List<Map<String, dynamic>> dataList = [];
    List<SerialProtocolText> list = _getListNameById(pageId);
    if (list.isEmpty) {
      return true;
    }
    int functionId = 0;
    for (var i = 0; i < list.length; i++) {
      if (list[i].type == 'TEXT') {
        dataList
            .add({"isvar": false, 'ishex': false, "value": list[i].content});
      } else if (list[i].type == 'TEXT_HEX') {
        if (validateHexStringWithSpaces(list[i].content)) {
          dataList
              .add({"isvar": false, 'ishex': true, "value": list[i].content});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The hexadecimal input is not valid')),
          );
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

  List<SerialProtocolText> _getListNameById(int pageId) {
    if (pageId == 1) return textListOl;
    if (pageId == 2) return textListUl;
    if (pageId == 3) return textListWgt;
    if (pageId == 4) return textListPcs;
    if (pageId == 5) return textListPrice;
    if (pageId == 6) return textListPct;
    return textListWgt;
  }

  Future<void> writeJsonToFile(String jsonString, int pageId) async {
    final formatfilePath = await getJsonFileDir();
    if (!await formatfilePath.exists()) {
      await formatfilePath.create(recursive: true);
    }
    var directory = formatfilePath.path;
    String fileName = 'Weight.json';
    if (pageId == 1) fileName = 'OL.json';
    if (pageId == 2) fileName = 'UL.json';
    if (pageId == 3) fileName = 'Weight.json';
    if (pageId == 4) fileName = 'Pcs.json';
    if (pageId == 5) fileName = 'Price.json';
    if (pageId == 6) fileName = 'Percent.json';

    File file = File(p.join(directory, fileName));
    await file.writeAsString(jsonString);
  }

  Future<void> generateFileList() async {
    jsonFilesList.clear();
    final formatfilePath = await getJsonFileDir();
    var directory = formatfilePath.path;
    List<String> filePaths = [
      p.join(directory, 'OL.json'),
      p.join(directory, 'UL.json'),
      p.join(directory, 'Weight.json'),
      p.join(directory, 'Pcs.json'),
      p.join(directory, 'Price.json'),
      p.join(directory, 'Percent.json'),
    ];
    for (int i = 1; i <= 6; i++) {
      String filePath = filePaths[i - 1];
      File file = File(filePath);
      if (await file.exists()) {
        jsonFilesList.add('$i$filePath');
      }
    }
  }

  void _handleDownload() async {
    jsonFilesList.clear();
    for (var i = 1; i < 7; i++) {
      bool res = await generateJson(i);
      if (!res) return;
    }
    await generateFileList();
    if (jsonFilesList.isNotEmpty && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileSelectScalesPage(
            funcNo: comScaleSerialSend,
            sendMsgStr: '',
            jsonList: jsonFilesList,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _getCurrentList();
    final totalItems = list.length;
    final startIndex = currentPageOffset * itemsPerPage;
    final pageList = list.skip(startIndex).take(itemsPerPage).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Serial Output Design",
          style: TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              showMobilePageHelpDialog(
                context,
                localizedStrings?.menuSerialOutputDesign ?? "Serial Output Design",
                localizedStrings?.gTipSerialDesignPageHelp ?? "Configure custom serial output format for scale.",
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Mode Dropdown Box
                  GestureDetector(
                    onTap: _showChoiceModeSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getCurrentModeName(),
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.black54),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Insertable Field Buttons (4 columns Grid)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: insertableLabels.length,
                    itemBuilder: (ctx, index) {
                      final label = insertableLabels[index];
                      return ElevatedButton(
                        onPressed: () => _handleInsertLabel(label),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6F6F6),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.normal),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // 3. Current Mode Grid Title & Edit Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCurrentModeName(),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: selectedItem != null
                              ? const Color(0xFF005696)
                              : Colors.grey[400],
                        ),
                        onPressed: selectedItem == null
                            ? null
                            : () => _openEditProperty(selectedItem!),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 4. Added Tokens Table Grid (4 columns x 4 rows)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                            childAspectRatio: 2.0,
                          ),
                          itemCount: itemsPerPage,
                          itemBuilder: (ctx, idx) {
                            if (idx < pageList.length) {
                              final item = pageList[idx];
                              final isSelected = item == selectedItem;
                              final displayText =
                                  item.varName.isNotEmpty ? item.varName : item.content;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (selectedItem == item) {
                                      _openEditProperty(item);
                                    } else {
                                      selectedItem = item;
                                    }
                                  });
                                },
                                child: Container(
                                  color: isSelected
                                      ? const Color(0xFF005696)
                                      : const Color(0xFFFAFAFA),
                                  alignment: Alignment.center,
                                  child: Text(
                                    displayText,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }
                            // Empty grid slot placeholder
                            return Container(
                              color: Colors.white,
                              alignment: Alignment.center,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Left/Right Shift Controls for Selected Element (solid filled blue triangles in light gray box)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _canMoveLeft() ? _moveSelectedItemLeft : null,
                              child: Container(
                                width: 44,
                                height: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.arrow_left,
                                  color: _canMoveLeft()
                                      ? const Color(0xFF005696)
                                      : Colors.grey[400],
                                  size: 28,
                                ),
                              ),
                            ),
                            Container(
                                width: 1, height: 24, color: Colors.grey[300]),
                            InkWell(
                              onTap: _canMoveRight() ? _moveSelectedItemRight : null,
                              child: Container(
                                width: 44,
                                height: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.arrow_right,
                                  color: _canMoveRight()
                                      ? const Color(0xFF005696)
                                      : Colors.grey[400],
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 5. Open Preview Output String
                  const Text(
                    "Open preview",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Text(
                      _getPreviewString(),
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons (Download & Open preview)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005696),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          "Download",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const MobileSerialPreviewPage(
                                selScaleId: -1,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1CB079),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          "Open preview",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
