import 'package:flutter/material.dart';

//页面下方备注部分
class RawRemarkTextWidget extends StatelessWidget {
  const RawRemarkTextWidget({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(8.0),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: SelectableText(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

//页面下方配料部分的标题
class ShowRawTitleWidget extends StatelessWidget {
  const ShowRawTitleWidget({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
