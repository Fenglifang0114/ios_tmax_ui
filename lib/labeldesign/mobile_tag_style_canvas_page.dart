import 'package:flutter/material.dart';
import 'package:t_max/labeldesign/label_element.dart';
import 'package:t_max/labeldesign/mobile_label_element_edit_page.dart';
import 'package:t_max/labeldesign/widgets/mobile_ruler_painter.dart';
import 'package:t_max/labeldesign/widgets/mobile_style_picker_sheet.dart';
import 'package:t_max/labeldesign/widgets/mobile_canvas_element_widget.dart';

class MobileTagStyleCanvasPage extends StatefulWidget {
  final double widthMm;
  final double heightMm;
  final List<DraggableElement> initialElements;
  final Function(List<DraggableElement> updatedElements) onConfirm;

  const MobileTagStyleCanvasPage({
    super.key,
    required this.widthMm,
    required this.heightMm,
    required this.initialElements,
    required this.onConfirm,
  });

  @override
  State<MobileTagStyleCanvasPage> createState() =>
      _MobileTagStyleCanvasPageState();
}

class _MobileTagStyleCanvasPageState extends State<MobileTagStyleCanvasPage> {
  late List<DraggableElement> elements;
  DraggableElement? selectedElement;

  // Red alignment guide lines (stored in physical mm)
  List<double> redVerticalLinesMm = [];
  List<double> redHorizontalLinesMm = [];

  @override
  void initState() {
    super.initState();
    elements = widget.initialElements.map((e) => e.copy()).toList();
    if (elements.isNotEmpty) {
      selectedElement = elements.first;
    }
  }

  void _handleAddElement(String category, String elementName) {
    setState(() {
      ElementType type = ElementType.text;
      String content = elementName;
      String varName = "";

      if (category == "Free Text") {
        type = ElementType.text;
        content = "Free Text";
      } else if (category == "BarCode Variable") {
        type = ElementType.barcode;
        content = "12345678";
        varName = elementName;
      } else if (category == "Qrcode Variable") {
        type = ElementType.qrcode;
        content = "12345678";
        varName = elementName;
      } else if (category == "Shape") {
        type = ElementType.line;
        content = "------";
      } else if (category == "Variable") {
        type = ElementType.data;
        varName = elementName;
        content = elementName;
      }

      final newEl = DraggableElement(
        type: type,
        position: const Offset(5.0, 5.0),
        size: Size(
          type == ElementType.barcode
              ? 35.0
              : (type == ElementType.qrcode
                  ? 20.0
                  : (type == ElementType.line ? 30.0 : 25.0)),
          type == ElementType.barcode
              ? 12.0
              : (type == ElementType.qrcode
                  ? 20.0
                  : (type == ElementType.line ? 1.0 : 4.0)),
        ),
        varName: varName,
        content: content,
        fontSize: "23",
        fontBold: "false",
        fontReverse: "false",
        maxLength: 10,
        alignment: "Left",
        hralignment: "Bottom",
        rotation: 0,
        index: elements.length + 1,
        defaultValue: "",
        varcontent: [],
        barcodeName: "",
        barcodeType: "",
        qrcodeName: "",
        qrcodeType: "",
        lineWidth: 1.0,
        qrWidth: "3",
      );

      elements.add(newEl);
      selectedElement = newEl;
    });
  }

  void _updatePanWithAlignment(
      DraggableElement el, DragUpdateDetails details, double scaleFactor) {
    final deltaMmX = details.delta.dx / scaleFactor;
    final deltaMmY = details.delta.dy / scaleFactor;

    double newX = (el.position.dx + deltaMmX)
        .clamp(0.0, widget.widthMm - el.size.width);
    double newY = (el.position.dy + deltaMmY)
        .clamp(0.0, widget.heightMm - el.size.height);

    final snapThresholdMm = 1.2;
    final newVerts = <double>{};
    final newHorizs = <double>{};

    for (var other in elements) {
      if (other == el) continue;

      final w = el.size.width;
      final h = el.size.height;
      final otherW = other.size.width;
      final otherH = other.size.height;

      // --- Left Alignment ---
      if ((newX - other.position.dx).abs() < snapThresholdMm) {
        newX = other.position.dx;
        newVerts.add(other.position.dx);
      }
      // --- Right Alignment ---
      else if (((newX + w) - (other.position.dx + otherW)).abs() <
          snapThresholdMm) {
        newX = other.position.dx + otherW - w;
        newVerts.add(other.position.dx + otherW);
      }
      // --- Right to Left Alignment ---
      else if (((newX + w) - other.position.dx).abs() < snapThresholdMm) {
        newX = other.position.dx - w;
        newVerts.add(other.position.dx);
      }
      // --- Left to Right Alignment ---
      else if ((newX - (other.position.dx + otherW)).abs() < snapThresholdMm) {
        newX = other.position.dx + otherW;
        newVerts.add(other.position.dx + otherW);
      }

      // --- Top Alignment ---
      if ((newY - other.position.dy).abs() < snapThresholdMm) {
        newY = other.position.dy;
        newHorizs.add(other.position.dy);
      }
      // --- Bottom Alignment ---
      else if (((newY + h) - (other.position.dy + otherH)).abs() <
          snapThresholdMm) {
        newY = other.position.dy + otherH - h;
        newHorizs.add(other.position.dy + otherH);
      }
      // --- Top to Bottom Alignment ---
      else if ((newY - (other.position.dy + otherH)).abs() < snapThresholdMm) {
        newY = other.position.dy + otherH;
        newHorizs.add(other.position.dy + otherH);
      }
      // --- Bottom to Top Alignment ---
      else if (((newY + h) - other.position.dy).abs() < snapThresholdMm) {
        newY = other.position.dy - h;
        newHorizs.add(other.position.dy);
      }
    }

    setState(() {
      el.position = Offset(newX, newY);
      redVerticalLinesMm = newVerts.toList();
      redHorizontalLinesMm = newHorizs.toList();
    });
  }

  void _clearAlignmentLines() {
    if (redVerticalLinesMm.isNotEmpty || redHorizontalLinesMm.isNotEmpty) {
      setState(() {
        redVerticalLinesMm.clear();
        redHorizontalLinesMm.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final rulerThickness = 24.0;

    final maxAvailableW = screenSize.width - rulerThickness - 32.0;
    final maxAvailableH = screenSize.height - 200.0;

    final scaleX = maxAvailableW / widget.widthMm;
    final scaleY = maxAvailableH / widget.heightMm;

    final scaleFactor = (scaleX < scaleY ? scaleX : scaleY).clamp(1.5, 12.0);

    final canvasPxWidth = widget.widthMm * scaleFactor;
    final canvasPxHeight = widget.heightMm * scaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
          "Tag Style",
          style: TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: selectedElement != null
                  ? const Color(0xFF005696)
                  : Colors.grey[400],
              size: 22,
            ),
            onPressed: selectedElement == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => MobileLabelElementEditPage(
                          element: selectedElement!,
                          onDelete: () {
                            setState(() {
                              elements.remove(selectedElement);
                              selectedElement = null;
                            });
                          },
                          onConfirm: (updatedEl) {
                            setState(() {
                              selectedElement = updatedEl;
                            });
                          },
                        ),
                      ),
                    );
                  },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: selectedElement != null
                  ? Colors.redAccent
                  : Colors.grey[400],
              size: 22,
            ),
            onPressed: selectedElement == null
                ? null
                : () {
                    setState(() {
                      elements.remove(selectedElement);
                      selectedElement = null;
                    });
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: rulerThickness, height: rulerThickness),
                        CustomPaint(
                          size: Size(canvasPxWidth, rulerThickness),
                          painter: TopRulerPainter(
                            widthMm: widget.widthMm,
                            scaleFactor: scaleFactor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: Size(rulerThickness, canvasPxHeight),
                          painter: LeftRulerPainter(
                            heightMm: widget.heightMm,
                            scaleFactor: scaleFactor,
                          ),
                        ),
                        Container(
                          width: canvasPxWidth,
                          height: canvasPxHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // 1. Elements
                              ...elements.map((el) {
                                final isSelected = el == selectedElement;

                                final renderX = el.position.dx * scaleFactor;
                                final renderY = el.position.dy * scaleFactor;

                                return Positioned(
                                  left: renderX,
                                  top: renderY,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedElement = el;
                                      });
                                    },
                                    onPanUpdate: (details) {
                                      _updatePanWithAlignment(
                                          el, details, scaleFactor);
                                    },
                                    onPanEnd: (_) => _clearAlignmentLines(),
                                    onPanCancel: () => _clearAlignmentLines(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0x22005696)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF005696)
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: MobileCanvasElementWidget(
                                        element: el,
                                        scaleFactor: scaleFactor,
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // 2. Red Vertical Alignment Guide Lines
                              ...redVerticalLinesMm.map((xMm) {
                                return Positioned(
                                  left: xMm * scaleFactor,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 1.0,
                                    color: Colors.redAccent,
                                  ),
                                );
                              }),

                              // 3. Red Horizontal Alignment Guide Lines
                              ...redHorizontalLinesMm.map((yMm) {
                                return Positioned(
                                  top: yMm * scaleFactor,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 1.0,
                                    color: Colors.redAccent,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onConfirm(elements);
                          Navigator.pop(context);
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
                          "Confirm",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => MobileStylePickerSheet(
                              onSelectElement: _handleAddElement,
                            ),
                          );
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
                          "Add",
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
