import 'package:flutter/material.dart';

class RectanglePainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;

  RectanglePainter({required this.startPoint, required this.endPoint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromPoints(startPoint, endPoint), paint);
  }

  @override
  bool shouldRepaint(RectanglePainter oldDelegate) => false;
}
