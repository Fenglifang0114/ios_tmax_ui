import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:t_max/dialog/exit_app_dialog.dart';
import 'package:t_max/data/language.dart';

/// 窗口生命周期管理的公用 Mixin
mixin WindowLifecycleMixin<T extends StatefulWidget> on State<T>
    implements WindowListener, TrayListener {
  /// 标记窗口是否被调整大小，用于 UI 适配
  bool isResize = false;

  /// 初始化窗口监听和设置
  void initWindowLifecycle() {
    if (Platform.isAndroid) return;
    trayManager.addListener(this);
    windowManager.addListener(this);

    // 设置全局统一的最小尺寸
    windowManager.setMinimumSize(const Size(1320, 720));
  }

  /// 销毁窗口监听
  void disposeWindowLifecycle() {
    if (Platform.isAndroid) return;
    trayManager.removeListener(this);
    windowManager.removeListener(this);
  }

  @override
  void onWindowResized() {
    if (mounted) {
      setState(() {
        isResize = true;
      });
    }
  }

  @override
  void onWindowMove() {}

  @override
  void onWindowFocus() {}

  @override
  void onWindowBlur() {}

  @override
  void onWindowMaximize() {}

  @override
  void onWindowUnmaximize() {}

  @override
  void onWindowMinimize() {}

  @override
  void onWindowRestore() {}

  @override
  void onWindowResize() {
    if (mounted) {
      setState(() {
        isResize = true;
      });
    }
  }

  @override
  void onWindowEnterFullScreen() {}

  @override
  void onWindowLeaveFullScreen() {}

  @override
  void onWindowClose() async {
    if (Platform.isAndroid) return;
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return CustomAlertDialog(
              titleText: (localizedStrings?.gTipExitApp ?? "gTipExitApp"),
              onNoPressed: () {
                Navigator.of(context).pop();
              },
              onYesPressed: () async {
                Navigator.of(context).pop();
                await trayManager.destroy();
                await windowManager.destroy();
                exit(0);
              },
            );
          },
        );
      }
    }
  }

  @override
  void onWindowEvent(String name) {}

  @override
  void onWindowDocked() {}

  @override
  void onWindowUndocked() {}

  @override
  void onWindowMoved() {}

  // TrayListener 的默认实现
  @override
  void onTrayIconMouseDown() {}

  @override
  void onTrayIconMouseUp() {}

  @override
  void onTrayIconRightMouseDown() {}

  @override
  void onTrayIconRightMouseUp() {}

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {}
}
