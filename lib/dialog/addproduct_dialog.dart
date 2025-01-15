// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:t_max/data/productrec.dart';
// import 'package:t_max/eventbus/eventbus.dart';
// import '../../data/productlist_data.dart';
// import '../../data/scalecmd_data.dart';
// import '../data/language.dart';
// import '../functions/methods.dart';
// import '../widget/custom_button.dart';

// TextEditingController productName = TextEditingController(
//     text: ((myProductRecInfo.product == null) ? "" : myProductRecInfo.product));
// TextEditingController productID = TextEditingController(
//     text: ((myProductRecInfo.id == null) ? "" : myProductRecInfo.id));
// TextEditingController model = TextEditingController();
// TextEditingController description = TextEditingController();
// TextEditingController preTare = TextEditingController(
//     text: ((myProductRecInfo.pretare == null) ? "" : myProductRecInfo.pretare));
// TextEditingController productRemark = TextEditingController(
//     text: ((myProductRecInfo.remarks == null) ? "" : myProductRecInfo.remarks));
// TextEditingController errorText = TextEditingController();

// bool? isPresetTare = ((myProductRecInfo.withPretare == null) ? false : true);

// addProductDialog(BuildContext context) {
//   productName.text =
//       ((myProductRecInfo.product == null) ? "" : myProductRecInfo.product)!;
//   productID.text = ((myProductRecInfo.id == null) ? "" : myProductRecInfo.id)!;
//   preTare.text =
//       ((myProductRecInfo.pretare == null) ? "" : myProductRecInfo.pretare)!;
//   productRemark.text =
//       ((myProductRecInfo.remarks == null) ? "" : myProductRecInfo.remarks)!;
//   isPresetTare = (myProductRecInfo.withPretare == null)
//       ? false
//       : myProductRecInfo.withPretare;
//   errorText.text = '';

//   return showDialog(
//       barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: ((context, setState) {
//           return AlertDialog(
//             title: getDialogTitle(context, localizedStrings.product_information,
//                 Icons.edit_note_outlined, 400),
//             content: Container(
//               height: 430,
//               decoration:
//                   BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 2),
//                     Container(
//                       decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.onPrimary),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text("PLU NO.:"),
//                                   SizedBox(
//                                     width: 200,
//                                     height: 30,
//                                     child: TextField(
//                                       controller: productID,
//                                       maxLength: 20,
//                                       maxLengthEnforcement:
//                                           MaxLengthEnforcement.enforced,
//                                       maxLines: 1,
//                                       textAlignVertical: TextAlignVertical.top,
//                                       decoration: const InputDecoration(
//                                         counterText: "",
//                                         // hintText: "请输入机种类型，如：ztp",
//                                         // border: OutlineInputBorder(),
//                                       ),
//                                       onChanged: (value) {
//                                         errorText.text = '';
//                                       },
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(localizedStrings.gPluName),
//                                   SizedBox(
//                                     width: 400,
//                                     height: 30,
//                                     child: TextField(
//                                       controller: productName,
//                                       maxLength: 100,
//                                       maxLengthEnforcement:
//                                           MaxLengthEnforcement.enforced,
//                                       maxLines: 1,
//                                       textAlignVertical: TextAlignVertical.top,
//                                       decoration: const InputDecoration(
//                                         counterText: "",
//                                         // hintText: "请输入机种类型，如：ztp",
//                                         // border: OutlineInputBorder(),
//                                       ),
//                                       onChanged: (value) {
//                                         errorText.text = '';
//                                       },
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Row(
//                                     children: [
//                                       Checkbox(
//                                           checkColor: Theme.of(context)
//                                               .colorScheme
//                                               .onPrimary,
//                                           activeColor: Theme.of(context)
//                                               .colorScheme
//                                               .primary,
//                                           value: isPresetTare,
//                                           onChanged: (value) {
//                                             setState(() {
//                                               errorText.text = '';
//                                               isPresetTare = value!;
//                                               if (!isPresetTare!) {
//                                                 preTare.text = "";
//                                               }
//                                             });
//                                           }),
//                                       Text(localizedStrings.pretare),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     width: 400,
//                                     height: 30,
//                                     child: TextField(
//                                       enabled: (isPresetTare == false)
//                                           ? false
//                                           : true,
//                                       controller: preTare,
//                                       maxLength: 20,
//                                       maxLengthEnforcement:
//                                           MaxLengthEnforcement.enforced,
//                                       maxLines: 1,
//                                       inputFormatters: [
//                                         FilteringTextInputFormatter.allow(
//                                             RegExp("[0-9.]"))
//                                       ], //数字包括小数,
//                                       textAlignVertical:
//                                           TextAlignVertical.bottom,
//                                       decoration: const InputDecoration(
//                                         counterText: "",
//                                         // hintText: "请输入机种类型，如：ztp",
//                                         // border: OutlineInputBorder(),
//                                       ),
//                                       onChanged: (value) {
//                                         if (kDebugMode) {
//                                           print(value);
//                                         }
//                                       },
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(localizedStrings.plu_remarks),
//                                   SizedBox(
//                                     width: 400,
//                                     height: 80,
//                                     child: TextField(
//                                       controller: productRemark,
//                                       maxLength: 300,
//                                       maxLengthEnforcement:
//                                           MaxLengthEnforcement.enforced,
//                                       maxLines: 10,
//                                       textAlignVertical: TextAlignVertical.top,
//                                       decoration: const InputDecoration(
//                                         counterText: "",
//                                         // hintText: "请输入机种类型，如：ztp",
//                                         border: OutlineInputBorder(),
//                                       ),
//                                       onChanged: (value) {
//                                         errorText.text = '';
//                                       },
//                                     ),
//                                   ),
//                                   const SizedBox(height: 20),
//                                   SizedBox(
//                                     width: 400,
//                                     height: 30,
//                                     child: TextField(
//                                       enabled: false,
//                                       controller: errorText,
//                                       maxLength: 100,
//                                       style: TextStyle(
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .error),
//                                       maxLengthEnforcement:
//                                           MaxLengthEnforcement.enforced,
//                                       maxLines: 1,
//                                       textAlignVertical:
//                                           TextAlignVertical.bottom,
//                                       decoration: InputDecoration(
//                                         border: const OutlineInputBorder(
//                                             borderSide: BorderSide.none),
//                                         counterText: "",
//                                         focusColor: Theme.of(context)
//                                             .colorScheme
//                                             .error, // hintText: "请输入机种类型，如：ztp",
//                                         // border: OutlineInputBorder(),
//                                       ),
//                                       onChanged: (value) {
//                                         errorText.text = '';
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         CustomOutlinedButton(
//                           btnWidth: 130,
//                           btnHeight: 40,
//                           icon: Icons.add,
//                           text: localizedStrings.gBtnAdd,
//                           onPressed: () {
//                             errorText.text = '';
//                             addProductRec();
//                           },
//                         ),
//                         const SizedBox(width: 20),
//                         CustomOutlinedButton(
//                           btnWidth: 130,
//                           btnHeight: 40,
//                           icon: Icons.edit_outlined,
//                           text: localizedStrings.button_edit,
//                           onPressed: () {
//                             errorText.text = '';
//                             editProductRec();
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 5),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         CustomOutlinedButton(
//                           btnWidth: 130,
//                           btnHeight: 40,
//                           icon: Icons.delete,
//                           text: localizedStrings.gBtnDelete,
//                           onPressed: () {
//                             if (productID.text.isNotEmpty ||
//                                 productName.text.isNotEmpty) {
//                               errorText.text = '';

//                               delProductRec();
//                             } else {
//                               errorText.text =
//                                   localizedStrings.plu_error_message;
//                             }
//                           },
//                         ),
//                         const SizedBox(width: 20),
//                         CustomOutlinedButton(
//                           btnWidth: 130,
//                           btnHeight: 40,
//                           icon: Icons.exit_to_app,
//                           text: localizedStrings.gBtnExit,
//                           onPressed: () {
//                             PublicFunctions.getProductList();
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }));
//       });
// }

// void addProductRec() {
//   PublicFunctions.getProductList();
//   bool result = true;
//   if (productID.text.isEmpty || productName.text.isEmpty) {
//     errorText.text = localizedStrings.plu_error_message1;
//     return;
//   }
//   if (isPresetTare!) {
//     if (preTare.text.isEmpty) {
//       errorText.text = localizedStrings.plu_error_message;
//       return;
//     }
//   }
//   if (myProductRecList.productRecInfo!.isNotEmpty) {
//     String? name;
//     String? id;
//     for (var i = 0; i < myProductRecList.productRecInfo!.length; i++) {
//       name = myProductRecList.productRecInfo![i].product;
//       id = myProductRecList.productRecInfo![i].id;
//       name ??= "";
//       id ??= "";
//       if (name == productName.text || id == productID.text) {
//         errorText.text = localizedStrings.plu_error_message2;
//         return;
//       }
//     }
//   }
//   if (result) {
//     myProductRec.id = productID.text;
//     myProductRec.product = productName.text;
//     myProductRec.withPretare = isPresetTare!;
//     myProductRec.remarks = productRemark.text;
//     myProductRec.pretare = preTare.text;
//     PublicFunctions.addProduct(jsonEncode(myProductRec));
//     errorText.text = "Success!";
//     productID.text = '';
//     productName.text = '';
//     productRemark.text = '';
//     preTare.text = '';
//   }
// }

// void editProductRec() {
//   if (productID.text.isEmpty || productName.text.isEmpty) {
//     errorText.text = localizedStrings.plu_error_message1;
//     return;
//   }
//   if (isPresetTare!) {
//     if (preTare.text.isEmpty) {
//       errorText.text = localizedStrings.plu_error_message1;
//       return;
//     }
//   }
//   if (myProductRecList.productRecInfo!.isNotEmpty) {
//     String? name;
//     String? id;
//     int recid = 0;
//     bool isFind = false;
//     for (var i = 0; i < myProductRecList.productRecInfo!.length; i++) {
//       name = myProductRecList.productRecInfo![i].product;
//       id = myProductRecList.productRecInfo![i].id;
//       name ??= "";
//       id ??= "";
//       if (name == productName.text || id == productID.text) {
//         recid = myProductRecList.productRecInfo![i].recId!;
//         isFind = true;
//         break;
//       }
//     }
//     if (isFind && recid != 0) {
//       myProductRecEdit.recId = recid;
//       myProductRecEdit.id = productID.text;
//       myProductRecEdit.product = productName.text;
//       myProductRecEdit.withPretare = isPresetTare!;
//       myProductRecEdit.remarks = productRemark.text;
//       myProductRecEdit.pretare = preTare.text;
//       PublicFunctions.modifyProduct(jsonEncode(myProductRecEdit));

//       if (kDebugMode) {
//         print(jsonEncode(myScaleCmd));
//       }
//       errorText.text = "Success!";
//     } else {
//       errorText.text = "Record was not found";
//     }
//   }
// }

// void delProductRec() {
//   if (productID.text.isEmpty || productName.text.isEmpty) {
//     errorText.text = localizedStrings.plu_error_message1;
//     return;
//   }
//   if (myProductRecList.productRecInfo!.isNotEmpty) {
//     String? name;
//     String? id;
//     int recid = 0;
//     bool isFind = false;
//     for (var i = 0; i < myProductRecList.productRecInfo!.length; i++) {
//       name = myProductRecList.productRecInfo![i].product;
//       id = myProductRecList.productRecInfo![i].id;
//       name ??= "";
//       id ??= "";
//       if (name == productName.text || id == productID.text) {
//         recid = myProductRecList.productRecInfo![i].recId!;
//         isFind = true;
//         break;
//       }
//     }
//     if (isFind && recid != 0) {
//       myProductRecDel.recId = recid;

//       PublicFunctions.delProduct(jsonEncode(myProductRecDel));
//       if (kDebugMode) {
//         print(jsonEncode(myScaleCmd));
//       }
//       if (recid == myProductRecInfo.recId) {
//         myProductRecInfo.id = "";
//         myProductRecInfo.product = "";
//         myProductRecInfo.pretare = "";
//         myProductRecInfo.remarks = "";
//         eventBus.fire(EventProductRecInfo(myProductRecInfo));
//       }
//       errorText.text = "Success!";
//       productID.text = "";
//       productName.text = "";
//       productName.text = "";
//       isPresetTare = false;
//       preTare.text = '';
//       productRemark.text = '';
//     } else {
//       errorText.text = "Record was not found";
//     }
//   }
// }
