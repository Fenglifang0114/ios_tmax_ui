// 显示没有设备的提示

import 'package:flutter/material.dart';

import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';

Widget showNoDeviceWidget(BuildContext context) {
  return Expanded(
      child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Container(
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            'assets/images/noDevices.png',
            fit: BoxFit.scaleDown,
          ),
          SizedBox(
            height: regularPadding,
          ),
          Container(
            padding: EdgeInsets.all(largePadding),
            child: Text(
              (localizedStrings?.gTipNoDevice ?? "gTipNoDevice"),
              style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest),
            ),
          )
        ])),
  ));
}
