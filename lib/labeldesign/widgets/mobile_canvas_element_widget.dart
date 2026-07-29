import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:t_max/labeldesign/label_element.dart';

class MobileCanvasElementWidget extends StatelessWidget {
  final DraggableElement element;
  final double scaleFactor;

  const MobileCanvasElementWidget({
    super.key,
    required this.element,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final renderW = element.size.width * scaleFactor;
    final renderH = element.size.height * scaleFactor;

    // Convert fontSize code (e.g. 23 -> 2.3mm, 46 -> 4.6mm, 69 -> 6.9mm) to physical mm font height
    final fontVal = (double.tryParse(element.fontSize ?? "23") ?? 23.0);
    final fontHeightMm = (fontVal / 10.0).clamp(1.2, 25.0);
    final scaledFontSize = fontHeightMm * scaleFactor;
    final isBold = (element.fontBold == "true" || element.fontBold == "True");

    switch (element.type) {
      case ElementType.barcode:
        return SizedBox(
          width: renderW > 10 ? renderW : 100,
          height: renderH > 5 ? renderH : 40,
          child: BarcodeWidget(
            barcode: Barcode.code128(),
            data: element.content?.isNotEmpty == true
                ? element.content!
                : "12345678",
            drawText: true,
            style: TextStyle(
              fontSize: (scaledFontSize * 0.75).clamp(6.0, 16.0),
              height: 1.0,
            ),
          ),
        );

      case ElementType.qrcode:
        return SizedBox(
          width: renderW > 10 ? renderW : 45,
          height: renderH > 10 ? renderH : 45,
          child: BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: element.content?.isNotEmpty == true
                ? element.content!
                : "12345678",
            drawText: false,
          ),
        );

      case ElementType.line:
      case ElementType.lineDiagonal:
        return SizedBox(
          width: renderW > 5 ? renderW : 80,
          height: renderH > 0.5 ? renderH : 2,
          child: Container(
            color: Colors.black87,
          ),
        );

      case ElementType.data:
        // Variable element: Display ONLY variable name
        final displayName = element.varName?.isNotEmpty == true
            ? element.varName!
            : (element.content?.isNotEmpty == true ? element.content! : "Variable");

        return SizedBox(
          width: renderW > 0 ? renderW : null,
          height: renderH > 0 ? renderH : null,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: scaledFontSize,
                height: 1.0, // Strict height multiplier to prevent extra line padding
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF005696),
              ),
            ),
          ),
        );

      case ElementType.text:
      default:
        final textStr = element.content?.isNotEmpty == true
            ? element.content!
            : "Free Text";

        return SizedBox(
          width: renderW > 0 ? renderW : null,
          height: renderH > 0 ? renderH : null,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Text(
              textStr,
              style: TextStyle(
                fontSize: scaledFontSize,
                height: 1.0, // Strict height multiplier to prevent extra line padding
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        );
    }
  }
}
