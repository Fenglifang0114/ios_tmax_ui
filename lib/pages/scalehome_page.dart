import 'package:flutter/material.dart';
import 'package:t_max/pages/addDevice_page.dart';

import 'widget/themeColor.dart';

class ScaleHomePage extends StatelessWidget {
  const ScaleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeColor(),
      home: const AddDevicePage(),
    );
  }
}
