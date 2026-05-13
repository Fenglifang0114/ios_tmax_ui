//每个页面的关于按钮

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import '../dialog/page_help_dialog.dart';

class PageInfoButton extends StatefulWidget {
  final VoidCallback onRefresh;
  final String helpInfo;
  final Color? color;

  const PageInfoButton(
      {required this.helpInfo, required this.onRefresh, this.color, super.key});

  @override
  PageInfoButtonState createState() => PageInfoButtonState();
}

class PageInfoButtonState extends State<PageInfoButton> {
  bool isHovered = false;
  bool isPressed = false;

  Color getColor() {
    if (widget.color != null) {
      return widget.color!;
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          isPressed = !isPressed;
          showDialog(
            context: context,
            barrierDismissible: false, // 允许点击空白处关闭对话框
            builder: (context) {
              return PageHelpInfoDialog(
                helpInfo: widget.helpInfo,
              );
            },
          ).then((value) => setState(() {
                isPressed = !isPressed;
                widget.onRefresh();
              }));
        });
        // 处理按钮点击事件
      },
      icon: getSvgIcon(aboutSvgIcon(), topIconSize, topIconSize, getColor()),
    );
  }
}
