//每个页面的关于按钮

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import '../dialog/page_help_dialog.dart';

class PageInfoButton extends StatefulWidget {
  final VoidCallback onRefresh;
  final String helpInfo;
  const PageInfoButton(
      {required this.helpInfo, required this.onRefresh, super.key});

  @override
  PageInfoButtonState createState() => PageInfoButtonState();
}

class PageInfoButtonState extends State<PageInfoButton> {
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
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
      onHover: (value) {
        setState(() {
          isHovered = value;
        });
      },
      child: Container(
          child: getSvgIcon(
              infoSvgIcon(), iconMenuSize, iconMenuSize, Color(0xFFF4B837))),
    );
  }
}
