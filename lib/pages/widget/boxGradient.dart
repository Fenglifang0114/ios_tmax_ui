import 'package:flutter/material.dart';

boxGradient() {
  return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color.fromARGB(255, 186, 225, 245),
        Color.fromARGB(255, 98, 161, 250),
        // Color.fromRGBO(63, 115, 192, 1),
        Color.fromARGB(255, 211, 237, 250)
      ]);
}
