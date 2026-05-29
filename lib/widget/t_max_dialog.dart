import 'package:flutter/material.dart';

class TMaxDialog extends StatelessWidget {
  final Widget? child;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsets? insetPadding;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;

  const TMaxDialog({
    super.key,
    this.child,
    this.backgroundColor,
    this.elevation,
    this.insetPadding,
    this.shape,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {}, // 阻止点击弹框内部关闭
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
