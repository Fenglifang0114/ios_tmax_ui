import 'package:flutter/material.dart';

class TextUtils {
  static List<TextSpan> generateTextSpans(
      BuildContext context, String text, Color color) {
    List<TextSpan> spans = [];
    int startIndex = 0;
    const baseStyle = TextStyle(
      fontSize: 14,
      height: 1.5,
      color: Color(0xFF334155),
    );
    final highlightStyle = baseStyle.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );

    while (true) {
      int openBracketIndex = text.indexOf('【', startIndex);
      int openSquareBracketIndex = text.indexOf('[', startIndex);
      int actualOpenIndex;

      if (openBracketIndex == -1 && openSquareBracketIndex == -1) {
        spans.add(TextSpan(
          text: text.substring(startIndex),
          style: baseStyle,
        ));
        break;
      } else if (openBracketIndex == -1) {
        actualOpenIndex = openSquareBracketIndex;
      } else if (openSquareBracketIndex == -1) {
        actualOpenIndex = openBracketIndex;
      } else {
        actualOpenIndex = openBracketIndex < openSquareBracketIndex
            ? openBracketIndex
            : openSquareBracketIndex;
      }

      spans.add(TextSpan(
        text: text.substring(startIndex, actualOpenIndex),
        style: baseStyle,
      ));

      int closeBracketIndex = text.indexOf('】', actualOpenIndex);
      int closeSquareBracketIndex = text.indexOf(']', actualOpenIndex);
      int actualCloseIndex;

      if (closeBracketIndex == -1 && closeSquareBracketIndex == -1) {
        spans.add(TextSpan(
          text: text.substring(actualOpenIndex),
          style: baseStyle,
        ));
        break;
      } else if (closeBracketIndex == -1) {
        actualCloseIndex = closeSquareBracketIndex;
      } else if (closeSquareBracketIndex == -1) {
        actualCloseIndex = closeBracketIndex;
      } else {
        actualCloseIndex = closeBracketIndex < closeSquareBracketIndex
            ? closeBracketIndex
            : closeSquareBracketIndex;
      }

      spans.add(TextSpan(
        text: text.substring(actualOpenIndex, actualCloseIndex + 1),
        style: highlightStyle,
      ));
      startIndex = actualCloseIndex + 1;
    }
    return spans;
  }
}

