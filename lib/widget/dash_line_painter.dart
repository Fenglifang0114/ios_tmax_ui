import 'package:flutter/material.dart';

class SolidLinePainter extends CustomPainter {
  final Color color;
  final Offset p1;
  final Offset p2;

  SolidLinePainter({required this.color, required this.p1, required this.p2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SolidLinePainter oldDelegate) => false;
}

// class DashedLinePainter extends CustomPainter {
//   final Color color;
//   final Offset p1;
//   final Offset p2;

//   DashedLinePainter({required this.color, required this.p1, required this.p2});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = 2.0
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.butt;

//     const double dashWidth = 5;
//     const double dashSpace = 5;

//     final path = Path()
//       ..moveTo(p1.dx, p1.dy)
//       ..lineTo(p2.dx, p2.dy);

//     final pathMetrics = path.computeMetrics();
//     if (pathMetrics.isEmpty) {
//       return;
//     }
//     final pathMetric = pathMetrics.first;
//     double distance = 0;
//     bool draw = true;

//     while (distance < pathMetric.length) {
//       final length = draw ? dashWidth : dashSpace;
//       final currentDistance = distance + length;
//       if (currentDistance > pathMetric.length) {
//         final remainingDistance = pathMetric.length - distance;
//         if (draw) {
//           final startOffset = distance / pathMetric.length;
//           final endOffset = (distance + remainingDistance) / pathMetric.length;
//           final subPath = pathMetric.extractPath(startOffset, endOffset);
//           canvas.drawPath(subPath, paint);
//         }
//         distance = pathMetric.length;
//       } else {
//         final subPath = pathMetric.extractPath(
//           distance / pathMetric.length,
//           (distance + dashWidth) / pathMetric.length,
//         );
//         canvas.drawPath(subPath, paint);
//         distance += dashWidth + dashSpace;
//         draw = !draw;
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(DashedLinePainter oldDelegate) => false;
// }
