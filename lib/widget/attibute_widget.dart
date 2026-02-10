//属性列表

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';

Widget buildAttributeText(BuildContext context, String text) {
  return Container(
      height: 54,
      padding: const EdgeInsets.only(right: largePadding),
      alignment: Alignment.centerLeft,
      child: Row(children: [
        Container(
          width: 3,
          height: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ]));
}

Widget buildTabOrderAndTyptTextNew(
    BuildContext context, String title, String value) {
  return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          SizedBox(
            width: smallPadding,
          ),
          Expanded(
              child: Container(
                  height: 36,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary),
                  )))
        ],
      ));
}

Widget showRightItemTitleText(BuildContext context, String title) {
  return Container(
    height: 42,
    alignment: Alignment.centerLeft,
    child: Text(title,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodySmall!.apply(
              color: Theme.of(context).colorScheme.onSurface,
            )),
  );
}
