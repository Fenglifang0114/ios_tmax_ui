// import 'package:flutter/material.dart';

// // 引入Socket.io
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class SocketPage extends StatefulWidget {
//   const SocketPage({required Key key}) : super(key: key);
//   @override
//   _SocketPageState createState() => _SocketPageState();
// }

// class _SocketPageState extends State<SocketPage> {
//   ScrollController _scrollController = new ScrollController();
//   late IO.Socket socket;
//   List messageList = [];

//   @override
//   void initState() {
//     super.initState();
//     // 和服务器端建立连接
//     this.socket = IO.io('http://192.168.0.11:8000', <String, dynamic>{
//       'transports': ['websocket'],
//     });
//     // 连接事件
//     this.socket.on('connect', (_) {
//       print('connect..');
//     });
//     // 接受来自服务端的数据
//     this.socket.on('toClient', (data) {
//       setState(() {
//         this.messageList.add(data);
//       });
//       // 改变滚动条的位置
//       this
//           ._scrollController
//           .jumpTo(_scrollController.position.maxScrollExtent + 80);
//     });
//     // 断开连接
//     this.socket.on('disconnect', (_) {
//       print('disconnect');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Socket.io演示"),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//           // 发送数据到服务端
//           this.socket.emit('toServer', {"username": 'aiguangyuan', "age": 18});
//         },
//       ),
//       body: ListView.builder(
//         // 滚动控制器
//         controller: this._scrollController,
//         itemCount: this.messageList.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text("${this.messageList[index]}"),
//           );
//         },
//       ),
//     );
//   }
// }
