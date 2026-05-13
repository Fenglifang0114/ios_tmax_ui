import 'package:flutter/material.dart';

class ReceiptLinePainter extends CustomPainter {
  final Paint linePaint;
  final Offset startPoint;
  late final Offset endPoint;
  final StrokeCap strokeType;
  final double lineWidth;

  ReceiptLinePainter({
    required this.startPoint,
    required this.endPoint,
    Color lineColor = Colors.black,
    this.strokeType = StrokeCap.butt,
    this.lineWidth = 0.2,
  }) : linePaint = Paint()
          ..color = lineColor
          ..strokeCap = strokeType
          ..strokeWidth = lineWidth
          ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      startPoint,
      endPoint,
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
