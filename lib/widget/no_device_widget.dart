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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/noDevices.png',
              fit: BoxFit.scaleDown,
              width: 150,
              color: Colors.grey.withOpacity(0.5), // Apply a tint if it's a solid icon to match the light grey design
              colorBlendMode: BlendMode.srcATop,
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              "No devices found yet\nPlease add your device",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
