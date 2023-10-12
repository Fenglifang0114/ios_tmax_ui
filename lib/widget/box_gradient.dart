import 'package:flutter/material.dart';

boxGradient() {
  return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomLeft,
      colors: <Color>[
        Color.fromARGB(255, 26, 166, 254),
        Color.fromARGB(255, 17, 145, 255),
        Color.fromARGB(255, 10, 124, 255),
      ]);
}
