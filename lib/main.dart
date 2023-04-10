import 'package:window_size/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common/WebSocketChannel.dart';
import 'generated/l10n.dart';
import 'pages/trial_page.dart';
import 'pages/widget/themeColor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //   setWindowMinSize(const Size(1320, 720));
  // }
  setWindowMinSize(const Size(1366, 768));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static late WebSocketChannel webchannel;

  // 重写build 方法，build 方法返回值为Widget类型，返回内容为屏幕上显示内容。
  @override
  Widget build(BuildContext context) {
    webchannel = WebSocketChannel('ws://127.0.0.1:7878/tmax?scaleid=0');
    // webchannel = WebSocketChannel('ws://10.5.100.89:7878/tmax?scaleid=0');
    webchannel.connect();

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

        //去掉右上角debug图标
        debugShowCheckedModeBanner: false,
        home: const TrialPage());
  }
}

























//备份 20230116

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
//     setWindowMinSize(const Size(1320, 720));
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   // static late WebSockClnt sock;
//   // static WebSockClnt getSock() {
//   //   return sock;
//   // }
//   static late IOWebSocketChannel channel;

//   // 重写build 方法，build 方法返回值为Widget类型，返回内容为屏幕上显示内容。
//   @override
//   Widget build(BuildContext context) {
//     //sock = WebSockClnt('http://localhost:5000');
//     // sock = WebSockClnt('ws://10.5.52.61:9090/ws');
//     // sock.connect();

//     var channel = IOWebSocketChannel.connect("ws://10.5.52.61:9090/ws");
//     channel.sink.add("connected!");

//     channel.stream.listen((message) {
//       print('收到消息:' + message);
//     });

//     channel.sink.close();

//     return MaterialApp(
//         //自定义主题
//         theme: themeColor(),
//         // 国际化
//         localizationsDelegates: const [
//           // 本地化的代理类
//           GlobalMaterialLocalizations.delegate, //为使material组件支持多语言
//           GlobalCupertinoLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate, // 定义组件默认的文本方向，从左到右或从右到左
//           S.delegate,
//         ],
//         // 应用支持的语言列表
//         supportedLocales: S.delegate.supportedLocales,

//         //去掉右上角debug图标
//         debugShowCheckedModeBanner: false,
//         home: TrialPage());
//   }
// }
