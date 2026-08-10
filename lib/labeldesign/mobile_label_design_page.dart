import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/data/barcoderowdata.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/labeldesign/label_element.dart';
import 'package:t_max/labeldesign/label_formatdata.dart';
import 'package:csv/csv.dart';
import 'package:t_max/data/encrypt_data.dart';
import 'package:t_max/labeldesign/mobile_tag_style_canvas_page.dart';
import 'package:t_max/labeldesign/mobile_barcode_manage_page.dart';
import 'package:t_max/labeldesign/widgets/mobile_canvas_element_widget.dart';

class MobileLabelDesignPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;

  const MobileLabelDesignPage({
    super.key,
    required this.onNavigate,
    required this.lastRouteName,
  });

  @override
  State<MobileLabelDesignPage> createState() => _MobileLabelDesignPageState();
}

class _MobileLabelDesignPageState extends State<MobileLabelDesignPage> {
  TextEditingController widthController = TextEditingController(text: "55.0");
  TextEditingController heightController = TextEditingController(text: "55.0");
  String selectedPrinter = "EPM205";
  String selectedDirection = "0";

  List<DraggableElement> elements = [];
  List<BarCodeRowDataInfo> barcodeList = [];
  List<BarCodeRowDataInfo> qrcodeList = [];

  final List<String> printerProtocols = ["EPM205", "TSPL", "ZPL", "CPCL"];
  final List<String> directionOptions = ["0", "90", "180", "270"];

  @override
  void initState() {
    super.initState();
    _loadDefaultElements();
  }

  @override
  void dispose() {
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void _loadDefaultElements() {
    // Start with a clean canvas or initial empty state (removed hardcoded Gross: 0.00kg)
    elements = [];
  }

  // --- Android Permission & Storage Helpers ---

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

  Future<void> _handleOpenJson() async {
    try {
      await _requestStoragePermission();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        String jsonStr = "";
        final pickedFile = result.files.single;

        if (pickedFile.path != null && pickedFile.path!.isNotEmpty) {
          final file = File(pickedFile.path!);
          jsonStr = await file.readAsString();
        } else if (pickedFile.bytes != null) {
          jsonStr = utf8.decode(pickedFile.bytes!);
        }

        if (jsonStr.isNotEmpty) {
          _importJsonContent(jsonStr);
          if (mounted) {
            showTipInfo("JSON Template imported successfully", context);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showTipInfo("Import failed: $e", context);
      }
    }
  }

  void _importJsonContent(String jsonStr) {
    try {
      final jsonData = jsonDecode(jsonStr);
      List rawList = [];

      if (jsonData is Map) {
        if (jsonData.containsKey('content')) {
          final FormatContent formatContent = FormatContent.fromJson(jsonData);
          if (formatContent.page.contains('*')) {
            final parts = formatContent.page.split('*');
            if (parts.length == 2) {
              widthController.text = parts[0];
              heightController.text = parts[1];
            }
          }
          if (formatContent.printer != null && formatContent.printer!.isNotEmpty) {
            selectedPrinter = formatContent.printer!;
          }
          if (formatContent.rotation.isNotEmpty) {
            selectedDirection = formatContent.rotation;
          }

          final contentDecoded = jsonDecode(formatContent.content);
          if (contentDecoded is List) {
            rawList = contentDecoded;
          }
        } else if (jsonData.containsKey('pWidth')) {
          final PageInfo pageInfo = PageInfo.fromJson(jsonData as Map<String, dynamic>);
          widthController.text = pageInfo.pWidth.toString();
          heightController.text = pageInfo.pHeight.toString();
          selectedDirection = pageInfo.rotation;
          rawList = pageInfo.content.map((x) => x.toJson()).toList();
        }
      } else if (jsonData is List) {
        rawList = jsonData;
      }

      if (rawList.isNotEmpty) {
        setState(() {
          elements.clear();
          for (var item in rawList) {
            if (item is Map) {
              final formData = FromateItemData.fromJson(item);
              elements.add(DraggableElement(
                type: _parseElementType(formData.type),
                position: Offset(formData.xPos.toDouble(), formData.yPos.toDouble()),
                size: Size(formData.width, formData.height),
                fontSize: formData.fontSize.toString(),
                varName: formData.varName,
                content: formData.content,
                maxLength: formData.maxLength,
                rotation: formData.rotation,
                fontBold: formData.fontBold,
                fontReverse: formData.fontReverse,
                alignment: formData.alignment == 1
                    ? 'Left'
                    : (formData.alignment == 2 ? 'Center' : 'Right'),
                hralignment: formData.hralignment,
                barcodeName: formData.barcodeName,
                barcodeType: formData.barcodeType,
                qrcodeName: formData.qrcodeName,
                qrcodeType: formData.qrcodeType,
                lineWidth: formData.lineWidth,
                qrWidth: formData.qrWidth,
                defaultValue: formData.defaultValue,
                varcontent: formData.varcontent,
                index: formData.tabOrder,
              ));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        showTipInfo("Parse error: $e", context);
      }
    }
  }

  ElementType _parseElementType(String? typeStr) {
    if (typeStr == 'data' || typeStr == 'DATA') {
      return ElementType.data;
    }
    if (typeStr == 'barcode' || typeStr == 'BarCode' || typeStr == 'B') {
      return ElementType.barcode;
    }
    if (typeStr == 'qrcode' || typeStr == 'QrCode' || typeStr == 'QR') {
      return ElementType.qrcode;
    }
    if (typeStr == 'line' || typeStr == 'L') {
      return ElementType.line;
    }
    return ElementType.text;
  }

  Future<void> _handleSaveFormat() async {
    try {
      bool hasPerm = await _requestStoragePermission();

      String saveDir;
      if (hasPerm && Platform.isAndroid) {
        Directory? extDir = await getExternalStorageDirectory();
        saveDir =
            extDir?.path ?? (await getApplicationDocumentsDirectory()).path;
      } else {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        saveDir = appDocDir.path;
      }

      final jsonPath = "$saveDir/format.json";
      final fmtPath = "$saveDir/format.fmt";

      List<FromateItemData> formatDataList = [];
      for (int i = 0; i < elements.length; i++) {
        final el = elements[i];
        formatDataList.add(FromateItemData(
          type: el.type.name,
          xPos: el.position.dx.toInt(),
          yPos: el.position.dy.toInt(),
          width: el.size.width,
          height: el.size.height,
          fontSize: int.tryParse(el.fontSize ?? "23") ?? 23,
          fontWidthRatio: el.fontWidthRatio ?? 1,
          fontHeightRatio: el.fontHeightRatio ?? 1,
          alignment: (el.alignment ?? 'Left') == 'Left'
              ? 1
              : ((el.alignment ?? 'Left') == 'Center' ? 2 : 3),
          maxLength: el.maxLength ?? 10,
          rotation: el.rotation ?? 0,
          style: el.style ?? 0,
          tabOrder: el.index ?? (i + 1),
          varName: el.varName ?? '',
          content: el.content ?? '',
          defaultValue: el.defaultValue ?? '',
          varcontent: el.varcontent ?? [],
          barcodeName: el.barcodeName ?? '',
          barcodeType: el.barcodeType ?? '',
          hralignment: el.hralignment ?? '',
          x2Pos: el.x2Pos ?? el.position.dx.toInt(),
          y2Pos: el.y2Pos ?? el.position.dy.toInt(),
          lineWidth: el.lineWidth ?? 1.0,
          qrWidth: el.qrWidth ?? '3',
          qrcodeName: el.qrcodeName ?? '',
          qrcodeType: el.qrcodeType ?? '',
          fontBold: el.fontBold ?? 'false',
          fontReverse: el.fontReverse ?? 'false',
        ));
      }

      FormatContent formatContent = FormatContent(
        page: "${widthController.text}*${heightController.text}",
        rotation: selectedDirection,
        content: jsonEncode(formatDataList),
        printer: selectedPrinter,
        prtType: "L",
      );

      final jsonFile = File(jsonPath);
      await jsonFile.writeAsString(jsonEncode(formatContent));

      final csvString = _exportCSV();
      final encryptedCsv = myFilePassword.encryptCsv(csvString);

      final fmtFile = File(fmtPath);
      await fmtFile.writeAsString(encryptedCsv);

      if (mounted) {
        showTipInfo("Format saved to:\n$saveDir", context);
      }
    } catch (e) {
      if (mounted) {
        showTipInfo("Save failed: $e", context);
      }
    }
  }

  String _exportCSV() {
    List<List<dynamic>> csvData = <List<dynamic>>[];

    if (selectedDirection == '180') {
      csvData.add(['ROTATE', '180']);
    } else {
      csvData.add(['ROTATE', '0']);
    }

    int width = ((double.tryParse(widthController.text) ?? 55.0) * 8).toInt();
    int height = ((double.tryParse(heightController.text) ?? 55.0) * 8).toInt();

    csvData.add(['P', width.toString(), height.toString()]);

    for (var i = 0; i < elements.length; i++) {
      final el = elements[i];
      if (el.type == ElementType.text) {
        int fontsize = int.tryParse(el.fontSize ?? '23') ?? 23;
        List fontlist = _getFontSize(fontsize);
        csvData.add([
          'TB',
          el.position.dx.toInt(),
          el.position.dy.toInt(),
          el.size.width.toInt(),
          el.size.height.toInt(),
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(el.fontBold ?? 'false', el.fontReverse ?? 'false'),
          _getRotation(el.rotation ?? 0),
          'TEXT',
          el.content ?? '',
          el.index ?? (i + 1),
        ]);
      } else if (el.type == ElementType.data) {
        int fontsize = int.tryParse(el.fontSize ?? '23') ?? 23;
        List fontlist = _getFontSize(fontsize);
        csvData.add([
          'TB',
          el.position.dx.toInt(),
          el.position.dy.toInt(),
          el.size.width.toInt(),
          el.size.height.toInt(),
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(el.fontBold ?? 'false', el.fontReverse ?? 'false'),
          _getRotation(el.rotation ?? 0),
          'DATA',
          el.varName ?? '',
          el.defaultValue ?? '',
          el.alignment ?? 'Left',
          el.maxLength ?? 10,
          el.index ?? (i + 1),
        ]);
      } else if (el.type == ElementType.barcode) {
        String tempContent = _barcodeContent(el.varcontent ?? []);
        String barcodeType = '1';
        if (el.barcodeType == 'Code39') barcodeType = 'CODE39';
        else if (el.barcodeType == 'EAN8') barcodeType = 'EAN8';
        else if (el.barcodeType == 'EAN13') barcodeType = 'EAN13';
        else if (el.barcodeType == 'UPC-A') barcodeType = 'UPCA';
        else if (el.barcodeType == 'UPC-E') barcodeType = 'UPCE';

        String hrAlignment = 'N';
        if (el.hralignment == 'Top') hrAlignment = 'TC';
        else if (el.hralignment == 'Bottom') hrAlignment = 'BC';

        csvData.add([
          'B',
          el.position.dx.toInt(),
          el.position.dy.toInt(),
          el.size.width.toInt(),
          el.size.height.toInt(),
          '2',
          barcodeType,
          _getRotation(el.rotation ?? 0),
          hrAlignment,
          tempContent,
          el.index ?? (i + 1),
        ]);
      } else if (el.type == ElementType.qrcode) {
        String tempContent = _barcodeContent(el.varcontent ?? []);
        csvData.add([
          'QR',
          el.position.dx.toInt(),
          el.position.dy.toInt(),
          '1',
          el.qrWidth ?? '3',
          '1',
          '',
          tempContent,
          el.index ?? (i + 1),
        ]);
      } else if (el.type == ElementType.line) {
        int lineWidth = el.size.width.toInt();
        int lineHeight = el.size.height.toInt();
        if (lineHeight <= lineWidth) {
          csvData.add([
            'L',
            el.position.dx.toInt(),
            el.position.dy.toInt(),
            (lineWidth + el.position.dx.toInt()),
            el.position.dy.toInt(),
            lineHeight,
            0,
            el.index ?? (i + 1),
          ]);
        } else {
          csvData.add([
            'L',
            el.position.dx.toInt(),
            el.position.dy.toInt(),
            el.position.dx.toInt(),
            (lineHeight + el.position.dy.toInt()),
            lineWidth,
            0,
            el.index ?? (i + 1),
          ]);
        }
      }
    }
    csvData.add(['F', selectedPrinter, 'L']);
    csvData.add(['']);

    return const ListToCsvConverter(textDelimiter: '').convert(csvData);
  }

  String _barcodeContent(List<dynamic> con) {
    final barcodedata = StringBuffer();
    if (con.isEmpty) return barcodedata.toString();
    for (final item in con) {
      if (barcodedata.isNotEmpty) barcodedata.write(',');
      if (item is Map) {
        if (item['type'] == 'TEXT') {
          barcodedata.write('TEXT,${item['content']}');
        } else {
          var varalignment = item['alignment'] == 'Center' ? 2 : (item['alignment'] == 'Right' ? 3 : 1);
          barcodedata.write('DATA,${item['type']},${item['defaultvalue']},$varalignment,${item['maxlength']}');
        }
      } else {
        if (item.type == 'TEXT') {
          barcodedata.write('TEXT,${item.content}');
        } else {
          var varalignment = item.alignment == 'Center' ? 2 : (item.alignment == 'Right' ? 3 : 1);
          barcodedata.write('DATA,${item.type},${item.defaultvalue},$varalignment,${item.maxlength}');
        }
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
    return [fontsize, width, height];
  }

  void _navigateToCanvasPage() {
    double widthMm = double.tryParse(widthController.text) ?? 55.0;
    double heightMm = double.tryParse(heightController.text) ?? 55.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MobileTagStyleCanvasPage(
          widthMm: widthMm,
          heightMm: heightMm,
          initialElements: elements,
          onConfirm: (updatedElements) {
            setState(() {
              elements = updatedElements;
            });
          },
        ),
      ),
    );
  }

  void _showAddFormatSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Add",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _loadDefaultElements();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005696),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text("New Format",
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showTipInfo("AI Design Service ready", context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F6F6),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                  ),
                  child: const Text("AI Design",
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showOptionPicker(
    String title,
    List<String> options,
    String currentValue,
    Function(String selected) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...options.map((opt) {
                final isSelected = opt == currentValue;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      onSelect(opt);
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
                    child: Text(opt, style: const TextStyle(fontSize: 16)),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double widthMm = double.tryParse(widthController.text) ?? 55.0;
    double heightMm = double.tryParse(heightController.text) ?? 55.0;

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
        title: Text(
          S.of(context).menuLabelDesign,
          style: const TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.black87, size: 26),
            onPressed: _showAddFormatSheet,
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
                  // Printer Protocol Tile
                  _buildPropertyTile(
                    label: "Printer Protocol",
                    value: selectedPrinter,
                    onTap: () => _showOptionPicker(
                      "Printer Protocol",
                      printerProtocols,
                      selectedPrinter,
                      (val) => setState(() => selectedPrinter = val),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // Direction Tile
                  _buildPropertyTile(
                    label: "Direction",
                    value: selectedDirection,
                    onTap: () => _showOptionPicker(
                      "Direction",
                      directionOptions,
                      selectedDirection,
                      (val) => setState(() => selectedDirection = val),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),

                  // Width and Height Fields
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Width(mm)",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                            TextField(
                              controller: widthController,
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() {}),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Height(mm)",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                            TextField(
                              controller: heightController,
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() {}),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tag Style Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tag Style",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      // Canvas Edit Icon
                      InkWell(
                        onTap: _navigateToCanvasPage,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFDDDDDD)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.edit_note,
                            color: Colors.black87,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Canvas Preview Box
                  GestureDetector(
                    onTap: _navigateToCanvasPage,
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: elements.isEmpty
                          ? const Center(
                              child: Text(
                                "Tap edit icon to design canvas",
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 14),
                              ),
                            )
                          : Stack(
                              children: elements.map((el) {
                                double scaleX = 300.0 / widthMm;
                                double scaleY = 260.0 / heightMm;
                                double previewScale =
                                    scaleX < scaleY ? scaleX : scaleY;

                                return Positioned(
                                  left: el.position.dx * previewScale,
                                  top: el.position.dy * previewScale,
                                  child: MobileCanvasElementWidget(
                                    element: el,
                                    scaleFactor: previewScale,
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Grid (2x2)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      // BarCode Edit
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => MobileBarcodeManagePage(
                                    isQrcode: false,
                                    barcodeList: barcodeList,
                                    onUpdateList: (newList) {
                                      setState(() => barcodeList = newList);
                                    },
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005696),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: const Text(
                              "BarCode Edit",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Qrcode Edit
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => MobileBarcodeManagePage(
                                    isQrcode: true,
                                    barcodeList: qrcodeList,
                                    onUpdateList: (newList) {
                                      setState(() => qrcodeList = newList);
                                    },
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005696),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: const Text(
                              "Qrcode Edit",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Open Json
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
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: const Text(
                              "Open Json",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Save Format
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
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: const Text(
                              "Save Format",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildPropertyTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            Row(
              children: [
                Text(value,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
