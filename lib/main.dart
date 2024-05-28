import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common/web_socket_channel.dart';
import 'common/web_socket_scale_channel.dart';
import 'data/get_theme_color.dart';
import 'data/parse_log.dart';
import 'data/scalecmd_data.dart';
import 'generated/l10n.dart';
import 'pages/trial_page.dart';
import 'widget/theme_color.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
      // size: Size(800, 600),
      minimumSize: Size(1320, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false, //底部任务栏是否显示 true不显示
      titleBarStyle: TitleBarStyle.normal, //标题栏的图标是否显示
      windowButtonVisibility: false, //没有作用呢
      title: '');
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setMinimizable(true);
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String savedLanguage = prefs.getString('language') ?? 'en_US';

  String ipAddr = await readIpAddr();
  if (ipAddr.isEmpty) {
    ipAddr = '127.0.0.1';
  }
  colorTheme = await loadColorsFromJson();
  runApp(MyApp(savedLanguage, ipAddr));
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
  const MyApp(this.savedLanguage, this.ipAddr, {Key? key}) : super(key: key);
  final String savedLanguage;
  final String ipAddr;
  static late WebSocketChannel webchannel;
  static late WebSocketScaleChannel webchannel1;

  // 重写build 方法，build 方法返回值为Widget类型，返回内容为屏幕上显示内容。
  @override
  Widget build(BuildContext context) {
    webchannel1 = WebSocketScaleChannel('ws://$ipAddr:7878/tmax?scaleid=1');
    webchannel = WebSocketChannel('ws://$ipAddr:7878/tmax?scaleid=0');
    webchannel.connect();
    webchannel1.connect();
    getLicense();
    return MaterialApp(
        //自定义主题
        theme: themeColor(colorTheme),
        // 国际化
        localizationsDelegates: const [
          // 本地化的代理类
          GlobalMaterialLocalizations.delegate, //为使material组件支持多语言
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate, // 定义组件默认的文本方向，从左到右或从右到左
          S.delegate,
        ],
        // 应用支持的语言列表
        supportedLocales: S.delegate.supportedLocales,
        locale:
            Locale(savedLanguage.split('_')[0], savedLanguage.split('_')[1]),
        //去掉右上角debug图标
        debugShowCheckedModeBanner: false,
        home: const TrialPage()); //HomePage()); //
  }

  void getLicense() {
    myScaleCmd.cmdMode = "check_license";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }
}
