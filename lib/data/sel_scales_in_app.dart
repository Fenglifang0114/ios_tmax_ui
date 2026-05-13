//记录选中的秤体在shared_preferences中的key

import 'package:shared_preferences/shared_preferences.dart';

// 应用名称常量
class AppNames {
  static const String weighing = "weighing";
  static const String weda = "weda";
  static const String chwe = "chwe";
  static const String insc = "insc";
  static const String taou = "taou";
}

class AppSelScalesManager {
  // 设置指定应用的整数列表数据
  static Future<void> setIntList(String appName, List<int> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(appName, data.map((e) => e.toString()).toList());
  }

  // 获取指定应用的整数列表数据
  static Future<List<int>> getIntList(String appName) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(appName);

    if (stringList == null) {
      return []; // 返回空列表作为默认值
    }

    // 将字符串列表转换为整数列表
    return stringList.map((e) => int.tryParse(e) ?? 0).toList();
  }
}
