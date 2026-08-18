import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t_max/data/encrypt_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/labeldesign/label_formatdata.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/receipt_item.dart';
import 'package:t_max/pages/mobile_receipt_canvas_page.dart';
import 'package:t_max/pages/mobile_receipt_variable_setting_page.dart';
import 'package:t_max/pages/mobile_sel_scales_page.dart';
import 'package:t_max/pages/update_firmware_page.dart';
import 'package:t_max/dialog/mobile_page_help_dialog.dart';

class MobileReceiptDesignPage extends StatefulWidget {
  const MobileReceiptDesignPage({super.key});

  @override
  State<MobileReceiptDesignPage> createState() => _MobileReceiptDesignPageState();
}

class _MobileReceiptDesignPageState extends State<MobileReceiptDesignPage> {
  List<ReceiptItemData> receiptItemList = [];
  String selectedProtocol = 'EPM205';
  String selectedDirection = 'Forward';
  TextEditingController widthCtl = TextEditingController(text: '55.0');
  TextEditingController heightCtl = TextEditingController(text: '55.0');

  final List<String> protocols = ['ESC/POS', 'EPM205', 'LP50', 'ZEBRA'];
  final List<String> directions = ['Forward', 'Backward'];

  @override
  void initState() {
    super.initState();
    _loadDefaultTemplate();
  }

  void _loadDefaultTemplate() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/template/receipt.json');
      final jsonString = utf8.decode(bytes.buffer.asUint8List());
      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is Map<String, dynamic> && decoded.containsKey('content')) {
        FormatContent formatContent = FormatContent.fromJson(decoded);
        setState(() {
          if (formatContent.page.contains('*')) {
            final parts = formatContent.page.split('*');
            if (parts.length == 2) {
              widthCtl.text = parts[0];
              heightCtl.text = parts[1];
            }
          }
          if (formatContent.printer != null && formatContent.printer!.isNotEmpty) {
            selectedProtocol = formatContent.printer!;
          }
          if (formatContent.rotation.isNotEmpty) {
            selectedDirection = formatContent.rotation;
          }
          final itemsJson = jsonDecode(formatContent.content);
          if (itemsJson is List) {
            receiptItemList =
                itemsJson.map((e) => ReceiptItemData.fromJson(e)).toList();
          }
        });
      } else if (decoded is List) {
        setState(() {
          receiptItemList =
              decoded.map((e) => ReceiptItemData.fromJson(e)).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void _showAddFormatSheet() {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined,
                          color: Colors.black54, size: 24),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleNewFormat();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005696),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      "New Format",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChoiceProtocolSheet() {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Printer Protocol",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...protocols.map((protocol) {
                  final isSelected = protocol == selectedProtocol;

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedProtocol = protocol;
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
                      child: Text(
                        protocol,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChoiceDirectionSheet() {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Direction",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...directions.map((dir) {
                  final isSelected = dir == selectedDirection;

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedDirection = dir;
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
                      child: Text(
                        dir,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCanvasEditor() async {
    final updatedList = await Navigator.push<List<ReceiptItemData>>(
      context,
      MaterialPageRoute(
        builder: (ctx) => MobileReceiptCanvasPage(
          initialItemList: receiptItemList,
          receiptWidthMm: double.tryParse(widthCtl.text) ?? 55.0,
          receiptHeightMm: double.tryParse(heightCtl.text) ?? 55.0,
        ),
      ),
    );

    if (updatedList != null) {
      setState(() {
        receiptItemList = updatedList;
      });
    }
  }

  void _openVariableSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const MobileReceiptVariableSettingPage(),
      ),
    );
  }

  void _handleOpenJson() async {
    try {
      await _requestStoragePermission();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result != null && result.files.isNotEmpty) {
        String filePath = result.files.single.path!;
        File file = File(filePath);
        String contents = await file.readAsString();
        final dynamic decoded = jsonDecode(contents);

        if (decoded is Map<String, dynamic> && decoded.containsKey('content')) {
          FormatContent formatContent = FormatContent.fromJson(decoded);
          setState(() {
            if (formatContent.page.contains('*')) {
              final parts = formatContent.page.split('*');
              if (parts.length == 2) {
                widthCtl.text = parts[0];
                heightCtl.text = parts[1];
              }
            }
            if (formatContent.printer != null && formatContent.printer!.isNotEmpty) {
              selectedProtocol = formatContent.printer!;
            }
            if (formatContent.rotation.isNotEmpty) {
              selectedDirection = formatContent.rotation;
            }
            final itemsJson = jsonDecode(formatContent.content);
            if (itemsJson is List) {
              receiptItemList =
                  itemsJson.map((e) => ReceiptItemData.fromJson(e)).toList();
            }
          });
        } else if (decoded is List) {
          setState(() {
            receiptItemList =
                decoded.map((e) => ReceiptItemData.fromJson(e)).toList();
          });
        }

        if (mounted) {
          showTipInfo(
            localizedStrings?.gTipOperationSuccess ?? "Format JSON loaded successfully!",
            context,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showTipInfo("Open fail: $e", context);
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.storage.isGranted ||
        await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    var status = await Permission.storage.request();
    if (status.isGranted) return true;
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }
    return false;
  }

  void _handleSaveFormat() async {
    try {
      await _requestStoragePermission();

      String? selectedDir;
      if (Platform.isAndroid || Platform.isIOS) {
        selectedDir = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select Output Folder:',
        );
      }

      if (selectedDir == null || selectedDir.isEmpty) {
        Directory? extDir = await getExternalStorageDirectory();
        selectedDir = extDir?.path ?? (await getApplicationDocumentsDirectory()).path;
      }

      final jsonPath = p.join(selectedDir, "format.json");
      final fmtPath = p.join(selectedDir, "format.fmt");

      FormatContent formatContent = FormatContent(
        page: "${widthCtl.text}*${heightCtl.text}",
        rotation: selectedDirection,
        content: jsonEncode(receiptItemList.map((e) => e.toJson()).toList()),
        printer: selectedProtocol,
        prtType: "R",
      );

      final jsonFile = File(jsonPath);
      await jsonFile.writeAsString(jsonEncode(formatContent));

      final csvString = _exportCSV();
      final encryptedCsv = myFilePassword.encryptCsv(csvString);

      final fmtFile = File(fmtPath);
      await fmtFile.writeAsString(encryptedCsv);

      if (mounted) {
        showTipInfo(
          "${localizedStrings?.gTipOperationSuccess ?? 'Files saved to folder:'}\n$selectedDir",
          context,
        );
      }
    } catch (e) {
      if (mounted) {
        showTipInfo("Save failed: $e", context);
      }
    }
  }

  String _exportCSV() {
    List<List<dynamic>> csvData = <List<dynamic>>[];

    if (selectedDirection == 'Backward' || selectedDirection == '180') {
      csvData.add(['ROTATE', '2']);
    } else {
      csvData.add(['ROTATE', '0']);
    }

    int width = ((double.tryParse(widthCtl.text) ?? 55.0) * 8).toInt();
    int height = ((double.tryParse(heightCtl.text) ?? 55.0) * 8).toInt();

    csvData.add(['P', width.toString(), height.toString()]);

    List<ReceiptItemData> tempList = List.of(receiptItemList);

    tempList.sort((a, b) {
      if (a.yPos == b.yPos) {
        if (a.type == 'Line' && b.type != 'Line') {
          return -1;
        } else if (a.type != 'Line' && b.type == 'Line') {
          return 1;
        } else {
          return a.xPos.compareTo(b.xPos);
        }
      } else {
        return a.yPos.compareTo(b.yPos);
      }
    });

    for (var i = 0; i < tempList.length; i++) {
      final item = tempList[i];
      if (item.type == 'TEXT') {
        List fontlist = _getFontSize(item.fontSize);
        csvData.add([
          'TB',
          item.xPos,
          item.yPos,
          item.width,
          item.height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(item.fontBold, item.fontReverse),
          _getRotation(item.rotation),
          item.type,
          item.content,
          item.tabOrder > 0 ? item.tabOrder : (i + 1),
        ]);
      } else if (item.type == 'DATA') {
        List fontlist = _getFontSize(item.fontSize);
        csvData.add([
          'TB',
          item.xPos,
          item.yPos,
          item.width,
          item.height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(item.fontBold, item.fontReverse),
          _getRotation(item.rotation),
          item.type,
          item.varName,
          item.defaultValue,
          item.alignment,
          item.maxLength,
          item.tabOrder > 0 ? item.tabOrder : (i + 1),
        ]);
      } else if (item.type == 'BarCode' || item.type == 'barcode') {
        String tempContent = _barcodeContent(item.varcontent);
        String barcodeType = '1';
        if (item.barcodeType == 'Code39') barcodeType = 'CODE39';
        else if (item.barcodeType == 'EAN8') barcodeType = 'EAN8';
        else if (item.barcodeType == 'EAN13') barcodeType = 'EAN13';
        else if (item.barcodeType == 'UPC-A') barcodeType = 'UPCA';
        else if (item.barcodeType == 'UPC-E') barcodeType = 'UPCE';

        String hrAlignment = item.hralignment == 'Top' ? 'TC' : (item.hralignment == 'Bottom' ? 'BC' : 'N');
        csvData.add([
          'B',
          item.xPos,
          item.yPos,
          item.width,
          item.height,
          '2',
          barcodeType,
          _getRotation(item.rotation),
          hrAlignment,
          tempContent,
          item.tabOrder > 0 ? item.tabOrder : (i + 1),
        ]);
      } else if (item.type == 'Qrcode' || item.type == 'qrcode') {
        String tempContent = _barcodeContent(item.varcontent);
        csvData.add([
          'QR',
          item.xPos,
          item.yPos,
          '1',
          item.qrWidth.isNotEmpty ? item.qrWidth : '3',
          '1',
          '',
          tempContent,
          item.tabOrder > 0 ? item.tabOrder : (i + 1),
        ]);
      } else if (item.type == 'Line' || item.type == 'line') {
        csvData.add([
          'TB',
          item.xPos,
          item.yPos,
          item.width,
          item.height,
          '4',
          '1',
          '1',
          '0',
          '0',
          'DATA',
          'StartLoop',
          '',
          '1',
          '0',
          item.tabOrder > 0 ? item.tabOrder : (i + 1),
        ]);
      }
    }
    csvData.add(['F', selectedProtocol, 'R']);
    csvData.add(['']);

    return const ListToCsvConverter(textDelimiter: '').convert(csvData);
  }

  String _barcodeContent(List<dynamic> con) {
    var barcodedata = StringBuffer();
    if (con.isEmpty) return barcodedata.toString();
    for (var i = 0; i < con.length; i++) {
      if (barcodedata.isNotEmpty) barcodedata.write(',');
      var type = con[i] is Map ? con[i]['type'] : con[i].type;
      var content = con[i] is Map ? con[i]['content'] : con[i].content;
      var alignment = con[i] is Map ? con[i]['alignment'] : con[i].alignment;
      var defaultvalue = con[i] is Map ? con[i]['defaultvalue'] : con[i].defaultvalue;
      var maxlength = con[i] is Map ? con[i]['maxlength'] : con[i].maxlength;

      if (type == 'TEXT') {
        barcodedata.write('$type,$content');
      } else {
        var varalignment = alignment == 'Center' ? 2 : (alignment == 'Right' ? 3 : 1);
        barcodedata.write('DATA,$type,$defaultvalue,$varalignment,$maxlength');
      }
    }
    return barcodedata.toString();
  }

  int _getRotation(int rotation) {
    if (rotation == 90) return 1;
    if (rotation == 180) return 2;
    if (rotation == 270) return 3;
    return 0;
  }

  String _getstyle(String fontBold, String fontReverse) {
    if (fontBold == 'true' && fontReverse == 'false') return '2';
    if (fontBold == 'true' && fontReverse == 'true') return '3';
    if (fontBold == 'false' && fontReverse == 'true') return '1';
    return '0';
  }

  List _getFontSize(int sFont) {
    int fontsize = 4;
    int width = 1;
    int height = 1;
    if (sFont == 23) fontsize = 4;
    else if (sFont == 20) fontsize = 1;
    else if (sFont == 39) { fontsize = 1; width = 2; height = 2; }
    else if (sFont == 46) { fontsize = 4; width = 2; height = 2; }
    else if (sFont == 69) { fontsize = 4; width = 3; height = 3; }
    else if (sFont == 95) { width = 4; height = 4; }
    else if (sFont == 115) { fontsize = 4; width = 5; height = 5; }
    else if (sFont == 137) { width = 6; height = 6; }
    else if (sFont == 165) { width = 7; height = 7; }
    else if (sFont == 170) { width = 8; height = 8; }
    return [fontsize, width, height];
  }

  void _handleNewFormat() {
    setState(() {
      receiptItemList.clear();
    });
    showTipInfo(
      localizedStrings?.gTipOperationSuccess ?? "Canvas cleared for new format!",
      context,
    );
  }

  Widget _buildRealPreview(double canvasWidth, double canvasHeight) {
    if (receiptItemList.isEmpty) {
      return Container(
        width: canvasWidth,
        height: canvasHeight,
        alignment: Alignment.center,
        color: Colors.white,
        child: const Text(
          "Empty Canvas",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    double maxMm = double.tryParse(widthCtl.text) ?? 55.0;
    double scale = canvasWidth / (maxMm * 8.0 > 0 ? maxMm * 8.0 : 440.0);

    return Container(
      width: canvasWidth,
      height: canvasHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: receiptItemList.map((item) {
          final double leftPos = (item.xPos ?? 0) * scale;
          final double topPos = (item.yPos ?? 0) * scale;
          final String itemContent = item.content ?? '';
          final String itemVarName = item.varName ?? '';
          final String textDisplay = itemContent.isNotEmpty ? itemContent : itemVarName;
          final double itemFontSize = ((item.fontSize ?? 14) > 0 ? item.fontSize! : 14).toDouble();

          return Positioned(
            left: leftPos,
            top: topPos,
            child: item.type == 'Line'
                ? SizedBox(
                    width: canvasWidth > 16 ? canvasWidth - 16 : canvasWidth,
                    child: Divider(
                      color: Colors.black87,
                      thickness: item.lineWidth ?? 1.0,
                    ),
                  )
                : Text(
                    textDisplay,
                    style: TextStyle(
                      fontSize: itemFontSize * 0.4,
                      color: Colors.black87,
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          "Receipt Design",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              showMobilePageHelpDialog(
                context,
                localizedStrings?.menuReceiptDesign ?? "Receipt Design",
                localizedStrings?.gTipReceiptDesignPageHelp ?? "Configure custom receipt formats and printer protocols for scale.",
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
            onPressed: _showAddFormatSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Printer Protocol Selector
                  GestureDetector(
                    onTap: _showChoiceProtocolSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Printer Protocol",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                selectedProtocol,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: Colors.black45, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Direction Selector
                  GestureDetector(
                    onTap: _showChoiceDirectionSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Direction",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                selectedDirection,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: Colors.black45, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Width(mm) and Height(mm) Inputs
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Width(mm)",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: widthCtl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Height(mm)",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: heightCtl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. Receipt Sample Header & Real Preview Box
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Receipt Sample",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.black87,
                        ),
                        onPressed: _openCanvasEditor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Real Format Preview Container (Green Border Box matching design mockup)
                  GestureDetector(
                    onTap: _openCanvasEditor,
                    child: Container(
                      width: double.infinity,
                      height: 320,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1CB079), // Green border matching mockup
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: LayoutBuilder(
                        builder: (ctx, constraints) {
                          return _buildRealPreview(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 5. Bottom 3 Action Buttons (Variable Value Setting, Open Json, Save Format)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Full-width "Variable Value Setting" button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _openVariableSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005696),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        (localizedStrings?.menuVariableValueSetting ?? "Variable Value Setting"),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Row with "Open Json" and "Save Format"
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _handleOpenJson,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005696),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Text(
                              (localizedStrings?.gOpenJson ?? "Open Json"),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _handleSaveFormat,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1CB079),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Text(
                              (localizedStrings?.gSaveFormat ?? "Save Format"),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
