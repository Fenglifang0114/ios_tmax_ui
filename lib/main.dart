import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:t_max/functions/methods.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';
import 'common/web_socket_channel.dart';
import 'data/get_theme_color.dart';
import 'data/manager_scale_channel.dart';
import 'data/parse_log.dart';
import 'data/setting_version_info.dart';
import 'generated/l10n.dart';
import 'widget/theme_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await setWindowOptions();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String savedLanguage = prefs.getString('language') ?? 'en_US';
  ipAddress = await readIpAddr();
  if (ipAddress.isEmpty) {
    ipAddress = '127.0.0.1';
  }
  await ensureInitialized();

  runApp(MyApp(savedLanguage, ipAddress));
}

//初始化
Future<void> ensureInitialized() async {
  colorTheme = await loadColorsFromJson();
  await mySystemVersionInfo.getTitle();
}

// 设置窗口选项
Future<void> setWindowOptions() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1320, 720));
  }

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1320, 720),
    minimumSize: Size(1320, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false, // 底部任务栏是否显示 true 不显示
    titleBarStyle: TitleBarStyle.normal, // 标题栏的图标是否显示
    windowButtonVisibility: false, // 没有作用呢
    title: '',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    windowManager.setMinimizable(true);
    windowManager.setResizable(true);
  });
}

Future<String> readIpAddr() async {
  String contentStr = '';
  String logFilePath = await getAppFilePath(myIpConfig);
  // 检查文件是否存在
  bool fileExists = await File(logFilePath).exists();
  if (!fileExists) {
    return contentStr;
  }
  // 追加写入日志
  String fileContent = await File(logFilePath).readAsString();
  return fileContent;
}

class MyApp extends StatelessWidget {
  const MyApp(this.savedLanguage, this.ipAddr, {super.key});
  final String savedLanguage;
  final String ipAddr;

  // 重写build 方法，build 方法返回值为Widget类型，返回内容为屏幕上显示内容。
  @override
  Widget build(BuildContext context) {
    webchannel = WebSocketChannel('ws://$ipAddr:7878/tmax?scaleid=0');
    webchannel.connect();
    PublicFunctions.getLicense();
    return MaterialApp(
        //自定义主题
        theme: themeColor(colorTheme),
        // 国际化
        localizationsDelegates: const [
          // 本地化的代理类
          S.delegate,
          GlobalMaterialLocalizations.delegate, //为使material组件支持多语言
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate, // 定义组件默认的文本方向，从左到右或从右到左
        ],
        // 应用支持的语言列表
        supportedLocales: S.delegate.supportedLocales,
        locale:
            Locale(savedLanguage.split('_')[0], savedLanguage.split('_')[1]),
        //去掉右上角debug图标
        debugShowCheckedModeBanner: false,
        home: mySystemVersionInfo.getHomePage()); //const TrialPage());
  }
}
