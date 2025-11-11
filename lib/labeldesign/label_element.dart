import 'package:flutter/material.dart';

enum ElementType {
  text,
  data,
  line,
  lineDiagonal,
  img,
  barcode,
  qrcode,
  rectangle,
}

class DraggableElement {
  Offset position;
  Size size;
  ElementType type;
  int? index;
  int? xPos;
  int? yPos;
  double? width;
  double? height;
  String? fontSize;
  int? fontWidthRatio;
  int? fontHeightRatio;
  int? style;
  int? rotation;
  String? varName;
  String? defaultValue;
  String? alignment;
  int? maxLength;
  int? tabOrder;
  String? content;
  List<dynamic>? varcontent;
  String? barcodeName;
  String? barcodeType;
  String? hralignment;
  int? x2Pos;
  int? y2Pos;
  double? lineWidth;
  String? qrWidth;
  String? qrcodeName;
  String? qrcodeType;
  String? fontBold;
  String? fontReverse;

  DraggableElement({
    required this.position,
    required this.size,
    required this.type,
    this.index,
    this.xPos,
    this.yPos,
    this.width,
    this.height,
    this.fontSize,
    this.fontWidthRatio,
    this.fontHeightRatio,
    this.alignment,
    this.maxLength,
    this.rotation,
    this.style,
    this.tabOrder,
    this.varName,
    this.content,
    this.defaultValue,
    this.varcontent,
    this.barcodeName,
    this.barcodeType,
    this.hralignment,
    this.x2Pos,
    this.y2Pos,
    this.lineWidth,
    this.qrWidth,
    this.qrcodeName,
    this.qrcodeType,
    this.fontBold,
    this.fontReverse,
  });
  DraggableElement copy() {
    return DraggableElement(
      position: position,
      size: size,
      type: type,
      index: index,
      xPos: xPos,
      yPos: yPos,
      width: width,
      height: height,
      fontSize: fontSize,
      fontWidthRatio: fontWidthRatio,
      fontHeightRatio: fontHeightRatio,
      alignment: alignment,
      maxLength: maxLength,
      rotation: rotation,
      style: style,
      tabOrder: tabOrder,
      varName: varName,
      content: content,
      defaultValue: defaultValue,
      varcontent: varcontent,
      barcodeName: barcodeName,
      barcodeType: barcodeType,
      hralignment: hralignment,
      x2Pos: x2Pos,
      y2Pos: y2Pos,
      lineWidth: lineWidth,
      qrWidth: qrWidth,
      qrcodeName: qrcodeName,
      qrcodeType: qrcodeType,
      fontBold: fontBold,
      fontReverse: fontReverse,
    );
  }
}

class DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class AlignmentLine {
  final Offset start;
  final Offset end;

  AlignmentLine({required this.start, required this.end});
}

class AlignmentLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  AlignmentLinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 0.5;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
