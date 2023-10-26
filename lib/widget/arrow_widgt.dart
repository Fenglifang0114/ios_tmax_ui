import 'package:flutter/material.dart';
import 'package:t_max/pages/system_setting_page.dart';

class ArrowButton extends StatefulWidget {
  const ArrowButton({super.key});

  @override
  _ArrowButtonState createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<ArrowButton> {
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isPressed = !isPressed;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SystemSettingPage()),
          ).then((value) => setState(() {
                isPressed = !isPressed;
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
                : Theme.of(context).colorScheme.background,
            width: 1.0,
          ),
          color: Colors.white,
        ),
        child: Icon(
          Icons.settings,
          color: isHovered || isPressed
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.background,
          size: 24.0,
        ),
      ),
    );
  }
}
