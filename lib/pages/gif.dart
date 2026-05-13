import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

Widget showGif() {
  return Gif(
    image: AssetImage('assets/images/searching.gif'),
    width: 600,
    height: 100,
    fit: BoxFit.scaleDown,
    autostart: Autostart.loop,
    fps: 8, // 这里控制速度！数值越小越慢，正常GIF是24fps
    placeholder: (context) => Container(
      width: 600,
      height: 100,
      color: Colors.grey[200],
    ),
  );
}
