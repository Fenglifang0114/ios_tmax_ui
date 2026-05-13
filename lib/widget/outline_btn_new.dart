import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';

// 自定义通用按钮组件
class CustomGeneralButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double maxWidth;

  const CustomGeneralButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.maxWidth, // 默认最大宽度为 150
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth, // 最大宽度限制为 240
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: regularPadding),
          backgroundColor: Theme.of(context).colorScheme.onPrimary, // 背景色为白色
          foregroundColor: Theme.of(context).colorScheme.primary, // 文字颜色为蓝色
          side: BorderSide(
              color: Theme.of(context).colorScheme.primary), // 边框颜色为蓝色
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // 无圆角
          ),
          fixedSize: const Size.fromHeight(40), // 高度固定为 48
        ),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .apply(color: Theme.of(context).colorScheme.primary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
