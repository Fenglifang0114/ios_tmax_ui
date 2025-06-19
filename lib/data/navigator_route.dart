//自定义跳转路由

// 自定义导航服务
import 'package:flutter/material.dart';

class NavigationService {
  // 向前导航（避免重复跳转）
  static void navigateTo(BuildContext context, String routeName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != routeName) {
      Navigator.pushNamed(context, routeName);
    }
  }

  // 返回上一页
  static void navigateBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // 如果无法返回（例如在根页面），可以选择跳转到首页或其他操作
      navigateTo(context, '/');
    }
  }
}
