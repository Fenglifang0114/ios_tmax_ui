import 'package:flutter/material.dart';

class TextUtils {
  // 新增 color 参数，默认值为 Colors.blue
  static List<TextSpan> generateTextSpans(
      BuildContext context, String text, Color color) {
    List<TextSpan> spans = [];
    int startIndex = 0;
    while (true) {
      int openBracketIndex = text.indexOf('【', startIndex);
      int openSquareBracketIndex = text.indexOf('[', startIndex);
      int actualOpenIndex;

      if (openBracketIndex == -1 && openSquareBracketIndex == -1) {
        spans.add(TextSpan(
          text: text.substring(startIndex),
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .apply(color: Theme.of(context).colorScheme.onSurface),
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
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .apply(color: Theme.of(context).colorScheme.onSurface),
      ));

      int closeBracketIndex = text.indexOf('】', actualOpenIndex);
      int closeSquareBracketIndex = text.indexOf(']', actualOpenIndex);
      int actualCloseIndex;

      if (closeBracketIndex == -1 && closeSquareBracketIndex == -1) {
        spans.add(TextSpan(
          text: text.substring(actualOpenIndex),
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .apply(color: Theme.of(context).colorScheme.onSurface),
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
        style: Theme.of(context).textTheme.bodySmall!.apply(color: color),
      ));
      startIndex = actualCloseIndex + 1;
    }
    return spans;
  }
}
