// 弹框的头部样式

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';

List<Widget> dialogHeadStyle(
    BuildContext context, String title, bool isShowCloseButton,
    {Function()? onClose}) {
  onClose ??= () {
    Navigator.pop(context);
  };
  return [
    Container(
        height: dialogHeadHeight,
        padding: const EdgeInsets.only(left: largePadding, right: largePadding),
        alignment: Alignment.centerLeft,
        child: Row(children: [
          Container(
            width: 3,
            height: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(
            width: smallPadding,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelMedium!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (isShowCloseButton)
            IconButton(
                icon: Icon(
                  Icons.cancel,
                  size: 24,
                  color: Theme.of(context).colorScheme.secondaryFixed,
                ),
                onPressed: onClose)
        ])),
    // 分割线
    Divider(
      height: 1,
      color: Theme.of(context).colorScheme.surfaceDim,
    ),
  ];
}
