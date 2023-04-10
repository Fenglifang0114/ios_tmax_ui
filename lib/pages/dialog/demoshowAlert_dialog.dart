// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// _showAlertDialog(BuildContext context) {
//   showDialog(
//       // 设置点击 dialog 外部不取消 dialog，默认能够取消
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => AlertDialog(
//             title: Text('我是个标题...嗯，标题..'),
//             titleTextStyle: TextStyle(color: Colors.purple), // 标题文字样式
//             content: Text(r'我是内容\(^o^)/~, 我是内容\(^o^)/~, 我是内容\(^o^)/~'),
//             contentTextStyle: TextStyle(color: Colors.green), // 内容文字样式
//             backgroundColor: CupertinoColors.white,
//             elevation: 8.0, // 投影的阴影高度
//             semanticLabel: 'Label', // 这个用于无障碍下弹出 dialog 的提示
//             shape: Border.all(),
//             // dialog 的操作按钮，actions 的个数尽量控制不要过多，否则会溢出 `Overflow`
//             actions: <Widget>[
//               // 点击增加显示的值
//               ElevatedButton(onPressed: () {}, child: const Text('点我增加')),
//               // 点击减少显示的值
//               ElevatedButton(onPressed: () {}, child: Text('点我减少')),
//               // 点击关闭 dialog，需要通过 Navigator 进行操作
//               ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('你点我试试.')),
//             ],
//           ));
// }
