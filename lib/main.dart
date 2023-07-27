import 'dart:convert';
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common/WebSocketChannel.dart';
import 'common/WebSocketScaleChannel.dart';
import 'data/scalecmd_data.dart';
import 'generated/l10n.dart';
import 'pages/trial_page.dart';
import 'pages/widget/theme_color.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1320, 720));
  }
  // setWindowMinSize(const Size(1366, 900));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static late WebSocketChannel webchannel;
  static late WebSocketScaleChannel webchannel1;

  // 重写build 方法，build 方法返回值为Widget类型，返回内容为屏幕上显示内容。
  @override
  Widget build(BuildContext context) {
    // webchannel = WebSocketChannel('ws://127.0.0.1:56566/tmax?scaleid=0');
    webchannel1 = WebSocketScaleChannel('ws://127.0.0.1:7878/tmax?scaleid=1');
    webchannel = WebSocketChannel('ws://127.0.0.1:7878/tmax?scaleid=0');

    // webchannel = WebSocketChannel('ws://10.5.52.65:7878/tmax?scaleid=0');
    webchannel1.connect();
    webchannel.connect();

    getLicense();

    return MaterialApp(
        //自定义主题
        theme: themeColor(),
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
        locale: const Locale('zh', "CN"),

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
