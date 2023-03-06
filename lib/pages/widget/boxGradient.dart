import 'package:flutter/material.dart';

boxGradient() {
  return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Colors.blue.shade900,
        Color.fromARGB(255, 255, 255, 255),
        // Color.fromRGBO(63, 115, 192, 1),
        Colors.blue.shade900,
      ]);
}
