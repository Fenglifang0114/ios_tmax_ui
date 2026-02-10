// // 软件锁

// import 'dart:convert';
// import 'dart:typed_data' as typed_data;

// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:pointycastle/api.dart' as pc_api;
// import 'package:pointycastle/block/aes.dart';

// import 'package:pointycastle/stream/ctr.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'AES固定长度加密',
//       theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
//       home: const FixedLengthAESEncryption(),
//     );
//   }
// }

// class FixedLengthAESEncryption extends StatefulWidget {
//   const FixedLengthAESEncryption({super.key});

//   @override
//   State<FixedLengthAESEncryption> createState() =>
//       _FixedLengthAESEncryptionState();
// }

// class _FixedLengthAESEncryptionState extends State<FixedLengthAESEncryption> {
//   final TextEditingController _originalTextController = TextEditingController();
//   final TextEditingController _cipherTextController = TextEditingController();

//   String _encryptedText = '';
//   bool _isProcessing = false;
//   String _outputLength = '16'; // 默认16位
//   bool _useFixedIV = true; // 使用固定IV，确保相同输入产生相同输出

//   // AES-256密钥（32字节）
//   static const String _aesKey = 'Lp8ZxTqY3W9RvA2cF7sDmJ4nBvG1hN5=';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('AES固定长度加密'), centerTitle: true),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // 原文输入区域
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '原文输入 (10位以内):',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: _originalTextController,
//                         decoration: const InputDecoration(
//                           hintText: '请输入要加密的原文',
//                           border: OutlineInputBorder(),
//                         ),
//                         maxLength: 10,
//                       ),
//                       Text(
//                         '长度: ${_originalTextController.text.length}/10',
//                         style: TextStyle(
//                           color: _originalTextController.text.length > 10
//                               ? Colors.red
//                               : Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // 配置区域
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '加密配置:',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // 加密按钮和结果
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'AES加密结果:',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       ElevatedButton(
//                         onPressed: _isProcessing ? null : _encryptText,
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: const Size(double.infinity, 50),
//                           backgroundColor: Colors.green,
//                         ),
//                         child: const Text(
//                           'AES加密',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // 加密结果
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.green[50],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               '固定长度密文:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             SelectableText(
//                               _encryptedText.isEmpty
//                                   ? '等待加密...'
//                                   : _encryptedText,
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontFamily: 'Monospace',
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green[800],
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               '长度: ${_encryptedText.length} 位',
//                               style: TextStyle(
//                                 color: _encryptedText.length.toString() ==
//                                         _outputLength
//                                     ? Colors.green
//                                     : Colors.orange,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       // 复制按钮
//                       if (_encryptedText.isNotEmpty)
//                         ElevatedButton(
//                           onPressed: () {
//                             _copyToClipboard(_encryptedText);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[50],
//                             foregroundColor: Colors.blue,
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.copy, size: 18),
//                               SizedBox(width: 8),
//                               Text('复制密文'),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // 密文验证区域
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '密文验证:',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),

//                       // 密文输入
//                       TextField(
//                         controller: _cipherTextController,
//                         decoration: InputDecoration(
//                           hintText: '输入密文进行验证',
//                           border: const OutlineInputBorder(),
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.paste),
//                             onPressed: () {
//                               _pasteFromClipboard();
//                             },
//                           ),
//                         ),
//                         maxLength: int.parse(_outputLength),
//                       ),

//                       const SizedBox(height: 12),

//                       // 验证按钮
//                       ElevatedButton(
//                         onPressed: _isProcessing ? null : _verifyCipherText,
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: const Size(double.infinity, 50),
//                           backgroundColor: Colors.blue,
//                         ),
//                         child: const Text(
//                           '验证密文',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       // 验证结果
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '验证说明:',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               '比较两个密文是否相同。注意：只有相同配置（相同密钥、相同IV、相同输出长度）下，相同原文才会产生相同密文。',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // 技术说明
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '技术实现:',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       _buildTechItem('算法', 'AES-256-CTR (Counter模式)'),
//                       _buildTechItem('密钥长度', '32字节 (256位)'),
//                       _buildTechItem('输出控制', '通过截取密文流实现固定长度'),
//                       _buildTechItem(
//                         'IV处理',
//                         _useFixedIV ? '固定IV（确定性输出）' : '随机IV（每次不同）',
//                       ),
//                       _buildTechItem('安全特性', '语义安全，即使相同原文也产生不同密文（随机IV时）'),
//                     ],
//                   ),
//                 ),
//               ),

//               // 测试用例
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '测试用例:',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: [
//                           _buildTestButton('10005250'),
//                           _buildTestButton('hello123'),
//                           _buildTestButton('测试'),
//                           _buildTestButton('a'),
//                           _buildTestButton('1234567890'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTechItem(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 80,
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTestButton(String text) {
//     return ElevatedButton(
//       onPressed: () {
//         _originalTextController.text = text;
//         _encryptText();
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.blue[50],
//         foregroundColor: Colors.blue[800],
//       ),
//       child: Text('"$text"'),
//     );
//   }

//   /// 加密文本
//   void _encryptText() {
//     final input = _originalTextController.text.trim();

//     if (input.isEmpty) {
//       _showMessage('请输入要加密的文本');
//       return;
//     }

//     if (input.length > 10) {
//       _showMessage('输入长度不能超过10位');
//       return;
//     }

//     setState(() {
//       _isProcessing = true;
//       _encryptedText = '';
//     });

//     try {
//       // 生成固定长度的AES密文
//       final ciphertext = _generateFixedLengthAESCipher(
//         input,
//         int.parse(_outputLength),
//       );

//       setState(() {
//         _encryptedText = ciphertext;
//         _cipherTextController.text = ciphertext;
//       });

//       _showMessage('✅ 加密成功！生成了${_outputLength}位密文');
//     } catch (e) {
//       _showMessage('加密失败: $e');
//     } finally {
//       setState(() {
//         _isProcessing = false;
//       });
//     }
//   }

//   /// 验证密文
//   void _verifyCipherText() {
//     final ciphertext = _cipherTextController.text.trim();
//     final originalInput = _originalTextController.text.trim();

//     if (ciphertext.isEmpty) {
//       _showMessage('请输入要验证的密文');
//       return;
//     }

//     if (originalInput.isEmpty) {
//       _showMessage('请先输入原文并加密');
//       return;
//     }

//     try {
//       // 重新生成密文进行比较
//       final expectedCipher = _generateFixedLengthAESCipher(
//         originalInput,
//         int.parse(_outputLength),
//       );

//       if (ciphertext == expectedCipher) {
//         _showMessage('✅ 密文验证通过！');
//       } else {
//         _showMessage('❌ 密文不匹配！请检查配置是否一致');
//       }
//     } catch (e) {
//       _showMessage('验证失败: $e');
//     }
//   }

//   /// 生成固定长度的AES密文
//   String _generateFixedLengthAESCipher(String plaintext, int outputLength) {
//     // 1. 准备AES密钥
//     final keyBytes = utf8.encode(_aesKey);
//     if (keyBytes.length != 32) {
//       throw Exception('AES密钥必须是32字节');
//     }

//     // 2. 生成IV（根据配置使用固定或随机IV）
//     typed_data.Uint8List? iv;
//     if (_useFixedIV) {
//       // 固定IV：使用基于原文的哈希值生成
//       final ivHash = sha256.convert(utf8.encode('TS*#@2026_$plaintext'));
//       iv = ivHash.bytes.sublist(0, 16) as typed_data.Uint8List?; // 取前16字节作为IV
//     }

//     // 3. 创建AES-CTR加密器
//     final ctr = CTRStreamCipher(AESEngine())
//       ..init(true, pc_api.ParametersWithIV(pc_api.KeyParameter(keyBytes), iv!));

//     // 4. 将原文转换为字节
//     final plainBytes = utf8.encode(plaintext);

//     // 5. 生成足够长的密钥流（至少需要outputLength/2字节，因为十六进制表示会翻倍）
//     final keyStreamNeeded = (outputLength / 2).ceil() + 16; // 额外生成一些保证足够
//     final dummyInput = typed_data.Uint8List(keyStreamNeeded); // 全零输入

//     // 6. 加密（实际上生成密钥流）
//     final keyStream = ctr.process(dummyInput);

//     // 7. 用密钥流加密原文（XOR）
//     final cipherBytes = typed_data.Uint8List(plainBytes.length);
//     for (int i = 0; i < plainBytes.length; i++) {
//       cipherBytes[i] = plainBytes[i] ^ keyStream[i];
//     }

//     // 8. 结合IV和密文，生成最终输出
//     final combined = typed_data.Uint8List(16 + cipherBytes.length)
//       ..setAll(0, iv)
//       ..setAll(16, cipherBytes);

//     // 9. 转换为十六进制
//     String hexResult = _bytesToHex(combined);

//     // 10. 截取到指定长度
//     if (hexResult.length > outputLength) {
//       return hexResult.substring(0, outputLength);
//     } else {
//       // 如果不够长，用哈希扩展
//       return hexResult.padRight(outputLength, '0');
//     }
//   }

//   /// 字节数组转十六进制字符串
//   String _bytesToHex(typed_data.Uint8List bytes) {
//     return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
//   }

//   // /// 十六进制字符串转字节数组
//   // typed_data.Uint8List _hexToBytes(String hex) {
//   //   final result = typed_data.Uint8List(hex.length ~/ 2);
//   //   for (int i = 0; i < result.length; i++) {
//   //     final byteStr = hex.substring(i * 2, i * 2 + 2);
//   //     result[i] = int.parse(byteStr, radix: 16);
//   //   }
//   //   return result;
//   // }

//   /// 复制到剪贴板
//   void _copyToClipboard(String text) {
//     // 在实际应用中，需要使用剪贴板插件
//     // 这里简化为显示消息
//     _showMessage('已复制到剪贴板: ${text.substring(0, 8)}...');
//   }

//   /// 从剪贴板粘贴
//   void _pasteFromClipboard() {
//     // 在实际应用中，需要使用剪贴板插件
//     // 这里简化为显示消息
//     _showMessage('请手动粘贴密文');
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
//     );
//   }

//   @override
//   void dispose() {
//     _originalTextController.dispose();
//     _cipherTextController.dispose();
//     super.dispose();
//   }
// }

// /// 自定义选择芯片组件
// class ChoiceChips extends StatelessWidget {
//   final List<String> options;
//   final String selected;
//   final ValueChanged<String> onSelected;

//   const ChoiceChips({
//     super.key,
//     required this.options,
//     required this.selected,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 8,
//       children: options.map((option) {
//         final isSelected = option == selected;
//         return ChoiceChip(
//           label: Text(option),
//           selected: isSelected,
//           onSelected: (selected) {
//             if (selected) {
//               onSelected(option);
//             }
//           },
//           selectedColor: Colors.blue[100],
//           labelStyle: TextStyle(
//             color: isSelected ? Colors.blue[800] : Colors.grey[700],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
