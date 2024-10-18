import 'package:flutter/material.dart';
import '../dialog/company_info_dialog.dart';

class AppInfoButton extends StatefulWidget {
  final VoidCallback onRefresh;
  const AppInfoButton({required this.onRefresh, super.key});

  @override
  AppInfoButtonState createState() => AppInfoButtonState();
}

class AppInfoButtonState extends State<AppInfoButton> {
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
              return const CompanyInfoDialog();
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
        height: 30.0,
        width: 30.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isPressed
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondaryFixed,
            width: 1.0,
          ),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        child: Icon(
          Icons.info_outline,
          color: isHovered || isPressed
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondaryFixed,
          size: 24.0,
        ),
      ),
    );
  }
}
