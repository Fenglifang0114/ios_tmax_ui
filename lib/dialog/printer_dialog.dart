// import 'package:flutter/material.dart';
// import 'package:t_max/data/printer.dart';
// import 'package:t_max/eventbus/eventbus.dart';
// import 'package:t_max/pages/pt566_page.dart';

// import '../pages/labeldesign_page.dart';

// final List<String> _printers = [
//   'EPM205',
//   'PT566',
// ];

// String _seletctPrinter = 'EPM205';

// printerDialog(BuildContext context) {
//   return showDialog(
//       barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: ((context, setState) {
//           return AlertDialog(
//             title: Container(
//                 color: Theme.of(context).colorScheme.primary,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.print,
//                       color: Theme.of(context).colorScheme.onPrimary,
//                     ),
//                     const SizedBox(width: 10),
//                     Text("Select the printer",
//                         style: TextStyle(
//                             color: Theme.of(context).colorScheme.onPrimary)),
//                   ],
//                 )),
//             content: Container(
//               height: 200,
//               decoration:
//                   BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 15),
//                   const Divider(),
//                   Center(
//                     child: DropdownButton<String>(
//                       value: _seletctPrinter,
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.onSurface,
//                         fontSize: 18,
//                         fontWeight: FontWeight.normal,
//                       ),
//                       hint: const Text(
//                         'Select Printer',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       items: _printers
//                           .map(
//                             (entry) => DropdownMenuItem<String>(
//                               value: entry.toString(),
//                               child: Text(entry.toString()),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             _seletctPrinter = newValue;
//                           }
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//             actions: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                       onPressed: () {
//                         myPrinter.printer = _seletctPrinter;
//                         eventBus.fire(EventPrinter(myPrinter));
//                         if (_seletctPrinter == 'EPM205') {
//                           Navigator.of(context).pop();
//                           Navigator.push(context,
//                               MaterialPageRoute(builder: (context) {
//                             return const LabelDesignPage(type: "");
//                           }));
//                         } else {
//                           Navigator.of(context).pop();
//                           Navigator.push(context,
//                               MaterialPageRoute(builder: (context) {
//                             return const PT566Page();
//                           }));
//                         }
//                       },
//                       child: const Text("Confirm")),
//                   const SizedBox(width: 20),
//                   OutlinedButton(
//                       child: const Text("Cancel"),
//                       onPressed: () {
//                         Navigator.of(context)
//                             .pop(); // to go back to screen after submitting
//                       })
//                 ],
//               )
//             ],
//           );
//         }));
//       });
// }
