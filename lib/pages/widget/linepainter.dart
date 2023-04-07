import 'package:flutter/material.dart';

// class LinePainter extends CustomPainter {
//   final Paint linePaint;
//   final Offset startPoint;
//   final Offset endPoint;

//   LinePainter({
//     required this.startPoint,
//     required this.endPoint,
//     Color lineColor = Colors.black,
//     double lineWidth = 2,
//   }) : linePaint = Paint()
//           ..color = lineColor
//           ..strokeWidth = lineWidth;

//   @override
//   void paint(Canvas canvas, Size size) {
//     canvas.drawLine(startPoint, endPoint, linePaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
class LinePainter extends CustomPainter {
  final Paint linePaint;
  final Offset startPoint;
  final Offset endPoint;
  final StrokeCap strokeType;
  final double lineWidth;

  LinePainter({
    required this.startPoint,
    required this.endPoint,
    Color lineColor = Colors.black,
    this.strokeType = StrokeCap.butt,
    this.lineWidth = 2,
  }) : linePaint = Paint()
          ..color = lineColor
          ..strokeCap = strokeType
          ..strokeWidth = lineWidth
          ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(startPoint, endPoint, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
