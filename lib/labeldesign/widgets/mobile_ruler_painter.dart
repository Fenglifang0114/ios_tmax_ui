import 'package:flutter/material.dart';

class TopRulerPainter extends CustomPainter {
  final double widthMm;
  final double scaleFactor;

  TopRulerPainter({
    required this.widthMm,
    required this.scaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw baseline
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );

    // Draw tick marks every 1mm, major tick & label every 10mm
    int totalMm = widthMm.ceil();
    for (int mm = 0; mm <= totalMm; mm++) {
      double x = mm * scaleFactor;
      if (x > size.width) break;

      if (mm % 10 == 0) {
        // Major tick
        canvas.drawLine(
          Offset(x, size.height - 10),
          Offset(x, size.height),
          paint,
        );

        if (mm > 0) {
          textPainter.text = TextSpan(
            text: "$mm",
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF666666),
            ),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(x - (textPainter.width / 2), size.height - 20),
          );
        }
      } else if (mm % 5 == 0) {
        // Medium tick
        canvas.drawLine(
          Offset(x, size.height - 6),
          Offset(x, size.height),
          paint,
        );
      } else {
        // Minor tick
        canvas.drawLine(
          Offset(x, size.height - 3),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TopRulerPainter oldDelegate) {
    return oldDelegate.widthMm != widthMm ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}

class LeftRulerPainter extends CustomPainter {
  final double heightMm;
  final double scaleFactor;

  LeftRulerPainter({
    required this.heightMm,
    required this.scaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw baseline
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      paint,
    );

    // Draw tick marks every 1mm, major tick & label every 10mm
    int totalMm = heightMm.ceil();
    for (int mm = 0; mm <= totalMm; mm++) {
      double y = mm * scaleFactor;
      if (y > size.height) break;

      if (mm % 10 == 0) {
        // Major tick
        canvas.drawLine(
          Offset(size.width - 10, y),
          Offset(size.width, y),
          paint,
        );

        if (mm > 0) {
          textPainter.text = TextSpan(
            text: "$mm",
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF666666),
            ),
          );
          textPainter.layout();
          canvas.save();
          canvas.translate(size.width - 14, y + (textPainter.width / 2));
          canvas.rotate(-1.5708); // Rotate text 90 degrees
          textPainter.paint(canvas, Offset.zero);
          canvas.restore();
        }
      } else if (mm % 5 == 0) {
        // Medium tick
        canvas.drawLine(
          Offset(size.width - 6, y),
          Offset(size.width, y),
          paint,
        );
      } else {
        // Minor tick
        canvas.drawLine(
          Offset(size.width - 3, y),
          Offset(size.width, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LeftRulerPainter oldDelegate) {
    return oldDelegate.heightMm != heightMm ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}
