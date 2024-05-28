import 'package:flutter/material.dart';

boxGradient(BuildContext context) {
  return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomLeft,
      colors: <Color>[
        // Color.fromARGB(255, 26, 166, 254),
        // Color.fromARGB(255, 17, 145, 255),
        // Color.fromARGB(255, 10, 124, 255),

        Theme.of(context).colorScheme.tertiary,
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.secondary,
      ]);
}
