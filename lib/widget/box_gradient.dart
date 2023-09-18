import 'package:flutter/material.dart';

boxGradient() {
  return const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: <Color>[
        Color.fromARGB(255, 236, 234, 235),
        Color.fromARGB(255, 186, 225, 245),
        Color.fromARGB(255, 0, 74, 152),
      ]);
}
