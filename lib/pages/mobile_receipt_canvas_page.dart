import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:t_max/data/receipt_item.dart';
import 'package:t_max/pages/mobile_receipt_element_edit_sheet.dart';
import 'package:t_max/pages/mobile_receipt_var_sheet.dart';

const double receiptLineHeightDots = 3.9 * 8; // 31.2 dots per row

class MobileReceiptCanvasPage extends StatefulWidget {
  final List<ReceiptItemData> initialItemList;
  final double receiptWidthMm;
  final double receiptHeightMm;

  const MobileReceiptCanvasPage({
    super.key,
    required this.initialItemList,
    this.receiptWidthMm = 55.0,
    this.receiptHeightMm = 55.0,
  });

  @override
  State<MobileReceiptCanvasPage> createState() => _MobileReceiptCanvasPageState();
}

class _MobileReceiptCanvasPageState extends State<MobileReceiptCanvasPage> {
  List<ReceiptItemData> receiptItemList = [];
  ReceiptItemData? selectedItem;
  int? _hoverRowIndex;
  int count = 0;

  @override
  void initState() {
    super.initState();
    // Copy initial item list
    receiptItemList = List<ReceiptItemData>.from(widget.initialItemList);
    count = receiptItemList.length;
  }

  void _addVariableItem(String category, String name) {
    setState(() {
      int nextRow = receiptItemList.length;
      int yPosDots = (nextRow * receiptLineHeightDots).toInt();

      final newItem = ReceiptItemData(
        category == 'Dividing Line' ? 'Line' : (category == 'Free Text' ? 'TEXT' : 'DATA'),
        10,
        yPosDots,
        120,
        30,
        24,
        1,
        1,
        1,
        20,
        0,
        0,
        ++count,
        category == 'Free Text' || category == 'Dividing Line' ? '' : name,
        name,
        name,
        [],
        '--',
        '',
        'Bottom',
        384,
        yPosDots,
        1.0,
        '3',
        '--',
        'Qrcode',
        'false',
        'false',
      );
      receiptItemList.add(newItem);
      selectedItem = newItem;
    });
  }

  void _deleteSelectedItem() {
    if (selectedItem != null) {
      setState(() {
        receiptItemList.remove(selectedItem);
        selectedItem = null;
      });
    } else if (receiptItemList.isNotEmpty) {
      setState(() {
        receiptItemList.clear();
      });
    }
  }

  void _openEditSelectedItem() {
    if (selectedItem != null) {
      MobileReceiptElementEditSheet.show(
        context,
        selectedItem!,
        () {
          setState(() {
            receiptItemList.remove(selectedItem);
            selectedItem = null;
          });
        },
        (updated) {
          setState(() {
            selectedItem = updated;
          });
        },
      );
    }
  }

  void _handleConfirm() {
    // Return confirmed item list back to MobileReceiptDesignPage
    Navigator.pop(context, receiptItemList);
  }

  @override
  Widget build(BuildContext context) {
    const double rulerThickness = 28.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
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
          "Receipt Style",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: selectedItem != null ? const Color(0xFF005696) : Colors.black87,
            ),
            onPressed: selectedItem == null ? null : _openEditSelectedItem,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _deleteSelectedItem,
          ),
        ],
      ),
      // Non-scrollable body layout to allow drag-and-drop without scrolling page
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 16, top: 12, bottom: 8),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  double maxCanvasW = constraints.maxWidth - rulerThickness;
                  double maxCanvasH = constraints.maxHeight - rulerThickness;

                  double canvasW = maxCanvasW;
                  double canvasH = maxCanvasW * (widget.receiptHeightMm / widget.receiptWidthMm);
                  if (canvasH > maxCanvasH) {
                    canvasH = maxCanvasH;
                    canvasW = canvasH * (widget.receiptWidthMm / widget.receiptHeightMm);
                  }

                  // Dots scale ratio
                  double scale = canvasW / (widget.receiptWidthMm * 8.0);
                  double rowHeightPx = receiptLineHeightDots * scale;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: canvasW + rulerThickness,
                      height: canvasH + rulerThickness,
                      child: Stack(
                        children: [
                          // 1. Top Ruler (Horizontal mm markings)
                          Positioned(
                            left: rulerThickness,
                            top: 0,
                            width: canvasW,
                            height: rulerThickness,
                            child: CustomPaint(
                              painter: _TopRulerPainter(widthMm: widget.receiptWidthMm),
                            ),
                          ),

                          // 2. Left Ruler (Vertical mm markings)
                          Positioned(
                            left: 0,
                            top: rulerThickness,
                            width: rulerThickness,
                            height: canvasH,
                            child: CustomPaint(
                              painter: _LeftRulerPainter(heightMm: widget.receiptHeightMm),
                            ),
                          ),

                          // 3. Main White Canvas Area with Proportional Guideline Rows
                          Positioned(
                            left: rulerThickness,
                            top: rulerThickness,
                            width: canvasW,
                            height: canvasH,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Proportional Guideline Row Painter
                                  CustomPaint(
                                    size: Size(canvasW, canvasH),
                                    painter: _ProportionalRowPainter(
                                      rowHeightPx: rowHeightPx,
                                    ),
                                  ),

                                  // Highlight current target row slot when dragging
                                  if (_hoverRowIndex != null)
                                    Positioned(
                                      left: 0,
                                      top: _hoverRowIndex! * rowHeightPx,
                                      width: canvasW,
                                      height: rowHeightPx,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1CB079).withOpacity(0.15),
                                          border: Border.all(
                                            color: const Color(0xFF1CB079),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Elements placed & snapped inside row slots (selected item rendered on top)
                                  ...() {
                                    List<ReceiptItemData> renderList = List.of(receiptItemList);
                                    if (selectedItem != null && renderList.contains(selectedItem)) {
                                      renderList.remove(selectedItem);
                                      renderList.add(selectedItem!);
                                    }
                                    return renderList.map((item) {
                                      final isSelected = item == selectedItem;

                                      double itemTopPx = (item.yPos / receiptLineHeightDots) * rowHeightPx;
                                      double itemLeftPx = item.xPos * scale;

                                      return Positioned(
                                        key: ValueKey(item),
                                        left: itemLeftPx,
                                        top: itemTopPx,
                                        child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            selectedItem = item;
                                          });
                                        },
                                        onPanStart: (details) {
                                          setState(() {
                                            selectedItem = item;
                                            _hoverRowIndex = (item.yPos / receiptLineHeightDots).round();
                                          });
                                        },
                                        onPanUpdate: (details) {
                                          setState(() {
                                            selectedItem = item;

                                            // 1. Horizontal move (continuous in dots)
                                            double curLeftPx = item.xPos * scale + details.delta.dx;
                                            curLeftPx = math.max(0, math.min(canvasW - 40, curLeftPx));
                                            item.xPos = (curLeftPx / scale).toInt();

                                            // 2. Vertical move (continuous dots, NO premature rounding during drag!)
                                            double curTopDots = item.yPos + (details.delta.dy / rowHeightPx) * receiptLineHeightDots;
                                            double maxDots = ((canvasH / rowHeightPx).floor() - 1) * receiptLineHeightDots;
                                            curTopDots = math.max(0, math.min(maxDots, curTopDots));
                                            item.yPos = curTopDots.toInt();

                                            // 3. Target hover row highlight
                                            int maxRows = (canvasH / rowHeightPx).floor() - 1;
                                            int hoverRow = (item.yPos / receiptLineHeightDots).round();
                                            _hoverRowIndex = math.max(0, math.min(maxRows, hoverRow));
                                          });
                                        },
                                        onPanEnd: (details) {
                                          setState(() {
                                            // Snap item.yPos cleanly to exact target row index on release
                                            int maxRows = (canvasH / rowHeightPx).floor() - 1;
                                            int finalRow = (item.yPos / receiptLineHeightDots).round();
                                            finalRow = math.max(0, math.min(maxRows, finalRow));
                                            item.yPos = (finalRow * receiptLineHeightDots).toInt();

                                            _hoverRowIndex = null;
                                          });
                                        },
                                        onPanCancel: () {
                                          setState(() {
                                            _hoverRowIndex = null;
                                          });
                                        },
                                        child: Container(
                                          height: rowHeightPx,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          alignment: Alignment.centerLeft,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF005696).withOpacity(0.12)
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF005696)
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: item.type == 'Line' || item.type == 'line'
                                              ? SizedBox(
                                                  width: canvasW - 20,
                                                  child: const Divider(
                                                    color: Colors.black87,
                                                    thickness: 1,
                                                  ),
                                                )
                                              : Text(
                                                  item.content.isNotEmpty
                                                      ? item.content
                                                      : item.varName,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isSelected
                                                        ? const Color(0xFF005696)
                                                        : Colors.black87,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                }(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom 2 Action Buttons (Confirm & Add)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1CB079), // Green Confirm button
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          MobileReceiptVarSheet.show(context, _addVariableItem);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005696), // Blue Add button
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          "Add",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

class _TopRulerPainter extends CustomPainter {
  final double widthMm;
  _TopRulerPainter({required this.widthMm});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1.0;

    double stepPx = size.width / (widthMm / 10.0);
    int stepCount = (widthMm / 10.0).floor();

    for (int i = 0; i <= stepCount; i++) {
      double x = i * stepPx;
      canvas.drawLine(Offset(x, size.height - 6), Offset(x, size.height), linePaint);

      if (i > 0) {
        TextPainter tp = TextPainter(
          text: TextSpan(
            text: "${i * 10}",
            style: const TextStyle(fontSize: 9, color: Colors.black54),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, size.height - 18));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LeftRulerPainter extends CustomPainter {
  final double heightMm;
  _LeftRulerPainter({required this.heightMm});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1.0;

    double stepPx = size.height / (heightMm / 10.0);
    int stepCount = (heightMm / 10.0).floor();

    for (int i = 0; i <= stepCount; i++) {
      double y = i * stepPx;
      canvas.drawLine(Offset(size.width - 6, y), Offset(size.width, y), linePaint);

      if (i > 0) {
        TextPainter tp = TextPainter(
          text: TextSpan(
            text: "${i * 10}",
            style: const TextStyle(fontSize: 9, color: Colors.black54),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(2, y - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ProportionalRowPainter extends CustomPainter {
  final double rowHeightPx;
  _ProportionalRowPainter({required this.rowHeightPx});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1.0;

    double y = rowHeightPx;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      y += rowHeightPx;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
