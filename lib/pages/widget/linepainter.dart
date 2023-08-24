import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final Paint linePaint;
  final Offset startPoint;
  late final Offset endPoint;
  final StrokeCap strokeType;
  final double lineWidth;

  LinePainter({
    required this.startPoint,
    required this.endPoint,
    Color lineColor = Colors.black,
    this.strokeType = StrokeCap.butt,
    this.lineWidth = 0.5,
  }) : linePaint = Paint()
          ..color = lineColor
          ..strokeCap = strokeType
          ..strokeWidth = lineWidth
          ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawLine(startPoint, endPoint, linePaint);

    // if (endPoint.dx == startPoint.dx || endPoint.dy == startPoint.dy) {
    //   linePaint.color = Colors.red;
    // } else {
    //   linePaint.color = Colors.black;
    // }
    canvas.drawLine(
      startPoint,
      endPoint,
      linePaint,
    );
    print('startPoint.dx  ' + startPoint.dx.toString());
    print('startPoint.dy  ' + startPoint.dy.toString());
    print('endPoint.dx  ' + endPoint.dx.toString());
    print('endPoint.dy  ' + endPoint.dy.toString());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
