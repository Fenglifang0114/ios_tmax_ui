import 'package:flutter/material.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/labeldesign/ai_service.dart';
import 'package:t_max/labeldesign/label_element.dart';
import 'package:t_max/labeldesign/label_formatdata.dart';

class AIDesignDialog extends StatefulWidget {
  final String apiKey;
  final Function(List<DraggableElement> elements, double width, double height,
      String printer, String direction) onApply;

  const AIDesignDialog(
      {super.key, required this.apiKey, required this.onApply});

  @override
  State<AIDesignDialog> createState() => _AIDesignDialogState();
}

class _AIDesignDialogState extends State<AIDesignDialog> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  List<FromateItemData> _generatedData = [];
  double _labelWidth = 55;
  double _labelHeight = 50;
  String _printer = 'EPM205';
  String _direction = '0';
  late DeepSeekService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = DeepSeekService(apiKey: widget.apiKey);
  }

  Future<void> _generate() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await _aiService.generateLabelFormat(_promptController.text);
      setState(() {
        _generatedData = result.elements;
        _labelWidth = result.labelWidth;
        _labelHeight = result.labelHeight;
        _printer = result.printer;
        _direction = result.direction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      String errorMsg = e.toString();
      if (errorMsg.contains("402")) {
        errorMsg = "DeepSeek 账户余额不足，请登录平台充值或检查免费额度。";
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: $errorMsg"), backgroundColor: Colors.red),
      );
    }
  }

  void _apply() {
    List<DraggableElement> elements = [];
    for (var item in _generatedData) {
      DraggableElement element = DraggableElement(
        position: Offset(item.xPos.toDouble(), item.yPos.toDouble()),
        size: Size(item.width, item.height),
        type: _getType(item.type),
        index: item.tabOrder,
        xPos: item.xPos,
        yPos: item.yPos,
        width: item.width,
        height: item.height,
        fontSize: item.fontSize.toString(),
        fontWidthRatio: item.fontWidthRatio,
        fontHeightRatio: item.fontHeightRatio,
        alignment: item.alignment == 1
            ? "Left"
            : (item.alignment == 2 ? "Center" : "Right"),
        maxLength: item.maxLength,
        rotation: item.rotation,
        style: item.style,
        tabOrder: item.tabOrder,
        varName: item.varName,
        content: item.content,
        defaultValue: item.defaultValue,
        varcontent: item.varcontent,
        barcodeName: item.barcodeName,
        barcodeType: item.barcodeType,
        hralignment: item.hralignment,
        x2Pos: item.x2Pos,
        y2Pos: item.y2Pos,
        lineWidth: item.lineWidth,
        qrWidth: item.qrWidth,
        qrcodeName: item.qrcodeName,
        qrcodeType: item.qrcodeType,
        fontBold: item.fontBold,
        fontReverse: item.fontReverse,
      );
      elements.add(element);
    }
    widget.onApply(elements, _labelWidth, _labelHeight, _printer, _direction);
    Navigator.of(context).pop();
  }

  ElementType _getType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return ElementType.text;
      case 'data':
        return ElementType.data;
      case 'barcode':
        return ElementType.barcode;
      case 'qrcode':
        return ElementType.qrcode;
      case 'line':
        return ElementType.line;
      case 'img':
        return ElementType.img;
      default:
        return ElementType.text;
    }
  }

  // Tools removed

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "AI Label Designer",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                  "Requirements (Size: ${_labelWidth.toInt()}x${_labelHeight.toInt()}mm, Printer: $_printer, Dir: $_direction):"),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: localizedStrings.aiDesignHintText,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _generate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        "Generate Design",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ),
              if (_generatedData.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                    "Visual Preview (${_labelWidth.toInt()}x${_labelHeight.toInt()}mm):",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _labelWidth / _labelHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Stack(
                          children: _generatedData.map((item) {
                            double scale = 200 / (_labelHeight * 8);
                            if (item.type == 'line') {
                              return Positioned(
                                left: item.xPos.toDouble() * scale,
                                top: item.yPos.toDouble() * scale,
                                child: Container(
                                  width: item.width * scale,
                                  height: item.height * scale,
                                  color: Colors.black,
                                ),
                              );
                            }
                            return Positioned(
                              left: item.xPos.toDouble() * scale,
                              top: item.yPos.toDouble() * scale,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Colors.blue.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  item.type == 'barcode'
                                      ? "||| BARCODE"
                                      : (item.type == 'qrcode'
                                          ? "[QR]"
                                          : item.content),
                                  style: const TextStyle(fontSize: 8),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                      ),
                      child: Text("Show In APP"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
