import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final double btnWidth;
  final double btnHeight;
  final IconData icon;
  final String text;
  final void Function()? onPressed;

  const CustomElevatedButton(
      {super.key,
      required this.btnWidth,
      required this.btnHeight,
      required this.icon,
      required this.text,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary, // 设置按钮的背景色
        elevation: 5, // 设置按钮的阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: btnWidth,
            height: btnHeight,
            child: Center(
              child: Text(
                text,
                maxLines: 1,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final double btnWidth;
  final double btnHeight;
  final IconData icon;
  final String text;
  final void Function()? onPressed;

  const CustomOutlinedButton(
      {super.key,
      required this.btnWidth,
      required this.btnHeight,
      required this.icon,
      required this.text,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: btnWidth,
            height: btnHeight,
            child: Center(
              child: Text(
                text,
                maxLines: 1,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget getDialogTitle(
    BuildContext context, String title, IconData icon, double titleWidth) {
  return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(4.0), // 设置圆角半径
      ),
      height: 40,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
          SizedBox(
            width: titleWidth,
            child: Text(title,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          )
        ],
      ));
}
