import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_max/data/company_info.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/sys_user_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';

import 'package:t_max/dialog/exit_app_dialog.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/generated/l10n.dart';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with TrayListener, WindowListener {
  bool isResize = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String backImgPath = 'assets/images/background.png';
  bool _showPassword = false;
  bool firstTime = true; // 第一次点击登录

  Future<void> _submitLogin() async {
    firstTime = false;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      PublicFunctions.login(_usernameController.text, _passwordController.text);
    }
  }

  dynamic _eventbus1; // 监听事件
  dynamic _eventbus2; // 监听事件

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void onWindowResize() {
    isResize = true;
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // 允许点击空白处关闭对话框
          builder: (context) {
            return CustomAlertDialog(
              titleText: localizedStrings.gTipExitApp,
              onNoPressed: () {
                Navigator.of(context).pop();
              },
              onYesPressed: () async {
                Navigator.of(context).pop();
                dispose();
                await trayManager.destroy(); //退出系统托盘
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
  void onWindowMaximize() {
    isResize = true;
  }

  @override
  void onWindowUnmaximize() {
    isResize = true;
  }

  @override
  void onWindowMinimize() {
    isResize = true;
  }

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);

    windowManager.setMinimumSize(Size(1320, 720));
    super.initState();

    _eventbus1 = eventBus.on<EventRespLogin>().listen((event) {
      if (mounted) {
        setState(() {
          String dataString = event.obj;
          if (dataString.contains('ok')) {
            PublicFunctions.getUserInfo(_usernameController.text);
          } else {
            _isLoading = false;
            showTipInfo(localizedStrings.tipLoginError, context);
          }
        });
      }
    });

    _eventbus2 = eventBus.on<EventRespGetUserDetail>().listen((event) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          String dataString = event.obj;
          try {
            mySysUser = sysUserDetailFromDbFromJson(dataString);
            if (mySysUser.roleId == superAdminRoleId ||
                mySysUser.roleId == adminRoleId) {
              mySysUser.pageIdList = allPageIdList;
            }
          } catch (e) {
            showTipInfo(localizedStrings.tipLoginError, context);
          }
          if (mySysUser.initialPageId != null) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            showTipInfo(localizedStrings.tipLoginError, context);
          }
        });
      }
    });

    // 所有初始化完成后设置默认页面
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();

    trayManager.removeListener(this);
    windowManager.removeListener(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40), // 自定义高度
        child: DraggableTitleBar(title: ''),
      ),
      body: Stack(
        children: [
          // 背景图
          Positioned.fill(
            child: Image.asset(
              backImgPath,
              fit: BoxFit.cover, // 确保图片覆盖整个屏幕
            ),
          ),

          SizedBox(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/company.png',
                          width: 138,
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: _height - 130,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(60),
                          width: 420,
                          child: Form(
                            // 添加Form组件包裹输入框
                            key: _formKey, // 关联formKey
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction, // 用户交互时自动验证
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Text(
                                    myAppName.appName!,
                                    style: textTheme.titleLarge!.copyWith(
                                      color: colorScheme.surface,
                                      fontSize: 42,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 36),
                                SizedBox(
                                  height: 80,
                                  child: TextFormField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      prefixIcon: Icon(
                                        size: 18,
                                        Icons.person_outline,
                                        color: colorScheme.primary,
                                      ),
                                      fillColor: colorScheme.surface,
                                      filled: true,
                                      hintText: localizedStrings
                                          .tipLoginUsernameEmpty,
                                      hintStyle: textTheme.bodySmall!.apply(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                      ),
                                      counterText: "",
                                      // 验证错误时的边框样式
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.error,
                                            width: 1.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.error,
                                            width: 1.0),
                                      ),
                                    ),
                                    maxLength: 40,
                                    style: textTheme.bodySmall!.apply(
                                      color: colorScheme.onSurface,
                                    ),
                                    // 添加验证器
                                    validator: (value) {
                                      if (firstTime) return null;
                                      if (value == null || value.isEmpty) {
                                        return localizedStrings
                                            .tipLoginUsernameNotEmpty;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 80,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      prefixIcon: Icon(
                                          size: 18,
                                          Icons.lock_outline,
                                          color: colorScheme.primary),
                                      fillColor: colorScheme.surface,
                                      filled: true,
                                      hintText: localizedStrings
                                          .tipLoginPasswordEmpty,
                                      hintStyle: textTheme.bodySmall!.apply(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          size: 18,
                                          _showPassword
                                              ? Icons.remove_red_eye_outlined
                                              : Icons.visibility_off_outlined,
                                          color: colorScheme.onSurface,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showPassword = !_showPassword;
                                          });
                                        },
                                      ),
                                      counterText: "",
                                      // 验证错误时的边框样式
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.error,
                                            width: 1.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.error,
                                            width: 1.0),
                                      ),
                                    ),
                                    obscureText: !_showPassword,
                                    obscuringCharacter: '*',
                                    style: textTheme.bodySmall!.apply(
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLength: 15,
                                    // 添加验证器
                                    validator: (value) {
                                      if (firstTime) return null;

                                      if (value == null || value.isEmpty) {
                                        return localizedStrings
                                            .tipLoginPasswordNotEmpty;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 48,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : Text(
                                            localizedStrings.btnLogin,
                                            style: textTheme.bodySmall!.apply(
                                              color: colorScheme.surface,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> with WindowListener {
  final StreamController<bool> _maximizedStreamController =
      StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    // 注册监听器
    windowManager.addListener(this);
    _initMaximizedState();
  }

  Future<void> _initMaximizedState() async {
    _maximizedStreamController.add(await windowManager.isMaximized());
  }

  // 实现 WindowListener 接口的 onWindowMaximize 方法
  @override
  void onWindowMaximize() {
    _maximizedStreamController.add(true);
  }

  // 实现 WindowListener 接口的 onWindowUnmaximize 方法
  @override
  void onWindowUnmaximize() {
    _maximizedStreamController.add(false);
  }

  @override
  void dispose() {
    // 移除监听器
    windowManager.removeListener(this);
    _maximizedStreamController.close();
    super.dispose();
  }

  // 定义常量
  static const buttonSize = Size(45, 32);
  static const iconSize = 16.0;

  // 公共按钮样式
  ButtonStyle get baseButtonStyle => ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        minimumSize: WidgetStateProperty.all(buttonSize),
        maximumSize: WidgetStateProperty.all(buttonSize),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.black12;
          }
          if (states.contains(WidgetState.pressed)) {
            return Colors.black26;
          }
          return Colors.transparent;
        }),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        )),
      );

  // 创建最小化按钮
  Widget _buildMinimizeButton() {
    return IconButton(
      style: baseButtonStyle,
      icon: Icon(
        Icons.remove,
        size: iconSize,
        color: Colors.black,
      ),
      onPressed: () => windowManager.minimize(),
    );
  }

  // 创建最大化/还原按钮
  Widget _buildMaximizeButton() {
    return IconButton(
      style: baseButtonStyle,
      icon: StreamBuilder<bool>(
        stream: _maximizedStreamController.stream,
        initialData: false,
        builder: (context, snapshot) {
          final isMaximized = snapshot.data ?? false;
          return Icon(
            isMaximized ? Icons.fullscreen_exit_sharp : Icons.fullscreen_sharp,
            size: iconSize,
            color: Colors.black,
          );
        },
      ),
      onPressed: () async {
        if (await windowManager.isMaximized()) {
          windowManager.unmaximize();
        } else {
          windowManager.maximize();
        }
      },
    );
  }

  // 创建关闭按钮
  Widget _buildCloseButton() {
    return IconButton(
      style: baseButtonStyle.copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed)) {
            return Colors.red;
          }
          return Colors.black;
        }),
      ),
      icon: Icon(
        Icons.close_sharp,
        size: iconSize,
        color: Colors.black,
      ),
      onPressed: () async {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // 允许点击空白处关闭对话框
            builder: (context) {
              return CustomAlertDialog(
                titleText: localizedStrings.gTipExitApp,
                onNoPressed: () {
                  Navigator.of(context).pop();
                },
                onYesPressed: () async {
                  Navigator.of(context).pop();
                  dispose();
                  await trayManager.destroy(); //退出系统托盘
                  await windowManager.destroy();
                  exit(0);
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMinimizeButton(),
        _buildMaximizeButton(),
        _buildCloseButton(),
      ],
    );
  }
}

// 可拖拽的标题栏组件
class DraggableTitleBar extends StatelessWidget {
  final Widget? leading; // 左侧图标/内容
  final String title; // 标题文本
  final bool showButtons; // 是否显示窗口按钮

  const DraggableTitleBar({
    super.key,
    this.leading,
    required this.title,
    this.showButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 关键：添加拖拽事件处理
      onPanStart: (details) => windowManager.startDragging(),

      // 双击标题栏时切换窗口最大化/还原
      onDoubleTap: () async {
        if (await windowManager.isMaximized()) {
          windowManager.unmaximize();
        } else {
          windowManager.maximize();
        }
      },

      child: Container(
        height: 32, // 标题栏高度
        color: Color(0xFFF0F0F0), // 标题栏背景色
        child: Row(
          children: [
            if (leading != null) leading!,
            SizedBox(width: 8), // 左侧图标和标题之间的间距
            Image.asset(appIconPath, width: 20, height: 20), // 左侧图标

            // 标题文本
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // 窗口控制按钮
            if (showButtons) WindowButtons(),
          ],
        ),
      ),
    );
  }
}
