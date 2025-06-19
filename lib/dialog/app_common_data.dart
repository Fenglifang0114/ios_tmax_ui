// app 设置中共用的函数

import 'package:flutter/material.dart';

Widget textBtn(
  BuildContext context,
  ColorScheme colorScheme,
  TextTheme textTheme,
  VoidCallback? func,
  String name,
  double height,
) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        fixedSize: Size(double.infinity, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      onPressed: func,
      child: Text(
        name,
        style: Theme.of(context).textTheme.bodySmall!.apply(
            color: func == null
                ? colorScheme.surfaceContainerHighest
                : colorScheme.onPrimary),
        overflow: TextOverflow.ellipsis,
      ));
}

Widget textColorBtn(
  BuildContext context,
  ColorScheme colorScheme,
  TextTheme textTheme,
  VoidCallback? func,
  String name,
  double height,
  Color backColor,
  Color fontColor,
) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: backColor,
        fixedSize: Size(double.infinity, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      onPressed: func,
      child: Text(
        name,
        style: Theme.of(context).textTheme.bodySmall!.apply(
            color:
                func == null ? colorScheme.surfaceContainerHighest : fontColor),
        overflow: TextOverflow.ellipsis,
      ));
}
