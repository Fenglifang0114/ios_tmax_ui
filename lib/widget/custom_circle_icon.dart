import 'package:flutter/material.dart';

class CustomCircleIcon extends StatelessWidget {
  final Color outerColor; // 外圈颜色
  final Color innerColor; // 对号颜色
  final double size; // 图标大小
  final IconData icon;

  const CustomCircleIcon({
    super.key,
    required this.outerColor,
    required this.innerColor,
    this.size = 20.0,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: outerColor,
          ),
        ),
        Positioned.fill(
          child: Icon(
            icon,
            color: innerColor,
            size: 24,
          ),
        ),
      ],
    );
  }
}
