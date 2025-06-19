// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:t_max/data/formula_common.dart';
// import 'package:t_max/data/formula_from_db_data.dart';

// import 'package:t_max/data/formula_scale_data.dart';
// import 'package:t_max/data/req_formula_data.dart';
// import 'package:t_max/dialog/custom_dialog_tip.dart';
// import 'package:t_max/eventbus/eventbus.dart';
// import 'package:t_max/functions/methods.dart';
// import '../data/language.dart';

// class AddFormulaPage extends StatefulWidget {
//   const AddFormulaPage({super.key});

//   @override
//   State<AddFormulaPage> createState() => AddFormulaPageState();
// }

// class AddFormulaPageState extends State<AddFormulaPage> {
//   TextEditingController formulaCodeCtl = TextEditingController();
//   TextEditingController formulaNameCtl = TextEditingController();
//   TextEditingController formulaModeCtl = TextEditingController(text: 'wgt');
//   TextEditingController formulaUnitCtl = TextEditingController(text: 'g');
//   TextEditingController formulaTypeCtl = TextEditingController();
//   TextEditingController rawMaterialCtl = TextEditingController();
//   TextEditingController wgtCtl = TextEditingController(); // 权重
//   TextEditingController errorCtl = TextEditingController(); // 误差
//   TextEditingController remarkCtl = TextEditingController(); // 备注

//   bool isEncrypted = false; // 保密初始值为 false
//   bool needContainer = false; // 保密初始值为 false
//   RawDataInfo? selectedRawDataInfo;
//   List<AddFormulaRawWgtInfo> addFormulaRawList = [];
//   double totalWgt = 0.0; // 总权重
//   // 创建一个映射表，将枚举值与翻译关联起来
//   Map<FormulaMode, String> formulaModeTranslation = {
//     FormulaMode.wgt: localizedStrings.fWeightMode,
//     FormulaMode.pct: localizedStrings.fPctMode,
//   };

//   int? selectedIndex;
//   dynamic _eventbus1;
//   dynamic _eventbus2;
//   dynamic _eventbus3;
//   dynamic _eventbus4;

//   @override
//   void initState() {
//     super.initState();

//     _eventbus1 = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
//       if (mounted) {
//         String dataStr = event.obj;
//         if (dataStr != '') {
//           setState(() {
//             formulaTypeList = categoryTypeListFromJson(dataStr);
//           });
//         } else {
//           setState(() {
//             formulaTypeList = [];
//           });
//         }
//       }
//     });

//     _eventbus2 = eventBus.on<EventRespAddFormulaType>().listen((event) {
//       if (mounted) {
//         PublicFunctions.getFormulaTypeList();
//         showTipInfo(localizedStrings.fAddSuccessMsg, context);
//       }
//     });
//     _eventbus3 = eventBus.on<EventRespAddFormula>().listen((event) {
//       if (mounted) {
//         PublicFunctions.getFormulaList();
//         showTipInfo(localizedStrings.fAddSuccessMsg, context);
//       }
//     });
//     _eventbus4 = eventBus.on<EventRespFormulaList>().listen((event) {
//       if (mounted) {
//         String dataStr = event.obj;
//         if (dataStr != '' && dataStr != 'null') {
//           setState(() {
//             formulaDataList = formulaInfoDbFromJson(dataStr);
//             // print(formulaDataList.length);
//           });
//         } else {
//           setState(() {
//             formulaDataList = [];
//           });
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _eventbus1.cancel();
//     _eventbus2.cancel();
//     _eventbus3.cancel();
//     _eventbus4.cancel();
//   }

// // 显示新增配方类型对话框
//   void showAddFormulaTypeDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // 点击对话框外部不关闭对话框
//       builder: (BuildContext context) {
//         return AddFormulaTypeDialog();
//       },
//     );
//   }

//   // 显示名称
//   showItemName(String itemName, bool showFlag) {
//     return Container(
//       height: 42,
//       alignment: Alignment.centerLeft,
//       child: RichText(
//         text: TextSpan(
//           children: [
//             !showFlag
//                 ? TextSpan(
//                     text: '*',
//                     style: Theme.of(context).textTheme.bodySmall!.apply(
//                           color: Theme.of(context).colorScheme.error,
//                         ),
//                   )
//                 : TextSpan(
//                     text: '',
//                   ),
//             TextSpan(
//                 text: ' $itemName',
//                 style: Theme.of(context).textTheme.bodySmall!.apply(
//                     color: Theme.of(context).colorScheme.onSurface,
//                     overflow: TextOverflow.ellipsis)),
//           ],
//         ),
//       ),
//     );
//   }

//   //下拉列表框
//   showModeDropDownButton(List<FormulaMode> items, String hintText,
//       TextEditingController valueCtl) {
//     return Container(
//         height: 48,
//         padding: const EdgeInsets.only(left: 16, right: 20),
//         decoration: BoxDecoration(
//           border: Border.all(
//               color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
//           borderRadius: BorderRadius.circular(0), // 设置圆角
//         ),
//         child: DropdownButton<FormulaMode>(
//             isExpanded: true,
//             value: items.firstWhere(
//                 (mode) => mode.toString().split('.').last == valueCtl.text,
//                 orElse: () => items[0]),
//             hint: Text(hintText), // 设置提示文本
//             underline: SizedBox.shrink(), // 移除下划线
//             items: items.map((FormulaMode item) {
//               // 设置下拉列表项
//               return DropdownMenuItem<FormulaMode>(
//                 value: item,
//                 child: Text(
//                   formulaModeTranslation[item]!,
//                   style: Theme.of(context).textTheme.bodySmall!.apply(
//                         color: Theme.of(context).colorScheme.onSurface,
//                       ),
//                 ),
//               );
//             }).toList(),
//             onChanged: (FormulaMode? newValue) {
//               // 处理下拉列表项选择事件
//               if (newValue != null) {
//                 // 在这里处理选择的值
//                 //这里要提示修改模式时，需要把原来的数据清空

//                 if (addFormulaRawList.isEmpty) {
//                   setState(() {
//                     valueCtl.text =
//                         newValue.toString().split('.').last; // 更新 valueCtl 的值
//                   });
//                 } else {
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false, // 点击对话框外部不关闭对话框
//                     builder: (BuildContext context) {
//                       return ShowNormalTipDialog(
//                         title: localizedStrings.fTipTitle,
//                         msg: localizedStrings.fSwitchModeClearMsg,
//                       );
//                     },
//                   ).then((value) {
//                     if (value) {
//                       // 保存
//                       setState(() {
//                         valueCtl.text = newValue
//                             .toString()
//                             .split('.')
//                             .last; // 更新 valueCtl 的值
//                         addFormulaRawList.clear();
//                       });
//                     } else {
//                       return;
//                     }
//                   });
//                 }
//               }
//             }));
//   }

//   //下拉列表框
//   showUnitDropDownButton(List<FormulaWgtUnit> items, String hintText,
//       TextEditingController valueCtl) {
//     return Container(
//         height: 48,
//         padding: const EdgeInsets.only(left: 16, right: 20),
//         decoration: BoxDecoration(
//           border: Border.all(
//               color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
//           borderRadius: BorderRadius.circular(0), // 设置圆角
//         ),
//         child: DropdownButton<FormulaWgtUnit>(
//             isExpanded: true,
//             value: items.firstWhere(
//                 (mode) => mode.toString().split('.').last == valueCtl.text,
//                 orElse: () => items[0]),
//             hint: Text(hintText), // 设置提示文本
//             underline: SizedBox.shrink(), // 移除下划线
//             items: items.map((FormulaWgtUnit item) {
//               // 设置下拉列表项
//               return DropdownMenuItem<FormulaWgtUnit>(
//                 value: item,
//                 child: Text(
//                   item.name,
//                   style: Theme.of(context).textTheme.bodySmall!.apply(
//                         color: Theme.of(context).colorScheme.onSurface,
//                       ),
//                 ),
//               );
//             }).toList(),
//             onChanged: (FormulaWgtUnit? newValue) {
//               // 处理下拉列表项选择事件
//               if (newValue != null) {
//                 // 在这里处理选择的值
//                 // print('Selected: ${newValue.toString().split('.').last}');
//                 setState(() {
//                   valueCtl.text = newValue.name; // 更新 valueCtl 的值
//                 });
//               }
//             }));
//   }

//   //选择类型下拉列表框
//   showTypeDropDownButton(String hintText, TextEditingController valueCtl) {
//     return Container(
//         height: 48,
//         padding: const EdgeInsets.only(left: 16, right: 20),
//         decoration: BoxDecoration(
//           border: Border.all(
//               color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
//           borderRadius: BorderRadius.circular(0), // 设置圆角
//         ),
//         child: DropdownButton(
//           underline: SizedBox(),
//           isExpanded: true,
//           value: formulaTypeCtl.text == "" ? null : formulaTypeCtl.text,
//           items: formulaTypeList.isEmpty
//               ? [
//                   DropdownMenuItem<String>(
//                     value: null,
//                     child: Text(localizedStrings.fPleaseSelectCategory),
//                   )
//                 ]
//               : [
//                   DropdownMenuItem<String>(
//                     value: null,
//                     child: Text(localizedStrings.fPleaseSelectCategory),
//                   ),
//                   ...formulaTypeList.map((CategoryTypeList item) {
//                     return DropdownMenuItem<String>(
//                       value: item.categoryName,
//                       child: Text(item.categoryName),
//                     );
//                   })
//                 ],
//           onChanged: (value) {
//             if (value == null) return;
//             setState(() {
//               formulaTypeCtl.text = value.toString();
//             });
//           },
//           style: Theme.of(context).textTheme.bodySmall!.apply(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//         ));
//   }

//   //选择原料下拉列表框
//   showRawDropDownBtn(String hintText) {
//     return Container(
//         height: 48,
//         padding: const EdgeInsets.only(left: 16, right: 20),
//         decoration: BoxDecoration(
//           border: Border.all(
//               color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
//           borderRadius: BorderRadius.circular(0), // 设置圆角
//         ),
//         child: DropdownButton(
//           underline: SizedBox(),
//           isExpanded: true,
//           // 更新判断值
//           value: rawMaterialCtl.text == "" ? null : rawMaterialCtl.text,
//           items: rawDataList.isEmpty
//               ? [
//                   DropdownMenuItem<String>(
//                     value: null,
//                     child: Text(localizedStrings.fSelectRawMaterialHint),
//                   )
//                 ]
//               : [
//                   DropdownMenuItem<String>(
//                     value: null,
//                     child: Text(localizedStrings.fSelectRawMaterialHint),
//                   ),
//                   ...rawDataList.map((RawDataInfo item) {
//                     // 拼接 materialId 和 materialName
//                     String displayText =
//                         '${item.rawMaterial.materialId} ${item.rawMaterial.materialName}';
//                     return DropdownMenuItem<String>(
//                       // 使用拼接后的文本作为 value
//                       value: displayText,
//                       child: Text(displayText),
//                     );
//                   })
//                 ],
//           onChanged: (value) {
//             if (value == null) return;
//             setState(() {
//               rawMaterialCtl.text = value.toString();
//               selectedRawDataInfo = rawDataList.firstWhere(
//                 (item) =>
//                     '${item.rawMaterial.materialId} ${item.rawMaterial.materialName}' ==
//                     value,
//                 orElse: () {
//                   return RawDataInfo(
//                     // 根据 RawDataInfo 类的构造函数传入必要的参数
//                     rawMaterial: RawMaterial(
//                       materialId: '',
//                       materialName: '',
//                       categoryId: 0,
//                       ingredient: '',
//                       createdBy: '',
//                       updatedBy: '',
//                       remark: '',
//                       recId: -1,
//                       createdAt: DateTime.now(),
//                       updatedAt: DateTime.now(),
//                       remark1: '',
//                       // 其他必要的参数
//                     ),
//                     rawCategoryName: '',
//                     // 其他必要的参数
//                   );
//                 },
//               );
//             });
//           },
//           style: Theme.of(context).textTheme.bodySmall!.apply(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//         ));
//   }

//   //输入框
//   showInputBox(TextEditingController controller, String hintText) {
//     return Container(
//       height: 48,
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(
//             color: Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
//           ),
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(0.0))),
//         ),
//         style: Theme.of(context).textTheme.bodySmall!.apply(
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//         onChanged: (value) {
//           setState(() {});
//         },
//       ),
//     );
//   }

// // 显示编号和模式
//   showCodeAndMode(double width) {
//     return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//       Row(children: [
//         SizedBox(
//           width: width,
//           height: 90,
//           child: Column(children: [
//             showItemName(localizedStrings.fFmaIdLabel + ' ', false),
//             showInputBox(formulaCodeCtl, localizedStrings.fInputFormulaIdHint),
//           ]),
//         ),
//       ]),
//       Row(children: [
//         SizedBox(
//           width: width,
//           height: 90,
//           child: Column(children: [
//             showItemName(localizedStrings.fFmaModeCol + " ", false),
//             showModeDropDownButton([FormulaMode.wgt, FormulaMode.pct],
//                 localizedStrings.fSelectFormulaModeHint, formulaModeCtl)
//           ]),
//         ),
//       ]),
//     ]);
//   }

// // 显示名称和单位
//   showNameAndUnit(double width) {
//     return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//       Row(children: [
//         SizedBox(
//           width: width,
//           height: 90,
//           child: Column(children: [
//             showItemName(localizedStrings.fFmaNameLabel + " ", false),
//             showInputBox(
//                 formulaNameCtl, localizedStrings.fInputFormulaNameHint),
//           ]),
//         ),
//       ]),
//       Row(children: [
//         SizedBox(
//           width: width,
//           height: 90,
//           child: Column(children: [
//             showItemName(localizedStrings.fWgtUnit, false),
//             formulaModeCtl.text == FormulaMode.wgt.name
//                 ? showUnitDropDownButton(
//                     [FormulaWgtUnit.g, FormulaWgtUnit.kg, FormulaWgtUnit.lb],
//                     localizedStrings.fSelectUnitHint,
//                     formulaUnitCtl)
//                 : Container(
//                     height: 48,
//                     padding: const EdgeInsets.only(left: 16, right: 20),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                           color: Theme.of(context)
//                               .colorScheme
//                               .outlineVariant), // 设置边框颜色
//                       borderRadius: BorderRadius.circular(0), // 设置圆角
//                     ),
//                     alignment: Alignment.centerLeft,
//                     child: Text("%", textAlign: TextAlign.left),
//                   )
//           ]),
//         ),
//       ]),
//     ]);
//   }

// // 显示类型和加密  容器
//   showTypeAndEncrypt(double width) {
//     return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//       Row(children: [
//         SizedBox(
//           width: width,
//           height: 90,
//           child: Column(children: [
//             showItemName(localizedStrings.fFmaCategoryCol, false),
//             Row(
//               children: [
//                 Expanded(
//                   child: showTypeDropDownButton(
//                       localizedStrings.fPleaseSelectCategory, formulaTypeCtl),
//                 ),
//                 Container(
//                   width: 10,
//                 ),
//                 Tooltip(
//                   message: localizedStrings.fAddTypeBtn, // 提示信息
//                   child: IconButton(
//                     iconSize: 24,
//                     color: Theme.of(context).colorScheme.onPrimary,
//                     style: IconButton.styleFrom(
//                       backgroundColor: Theme.of(context).colorScheme.surface,
//                       focusColor: Theme.of(context)
//                           .colorScheme
//                           .primary
//                           .withOpacity(0.1),
//                       shape: RoundedRectangleBorder(
//                           // 设置为矩形形状
//                           borderRadius: BorderRadius.zero, // 没有圆角，即正方形
//                           side: BorderSide(
//                             color:
//                                 Theme.of(context).colorScheme.outline, // 设置边框颜色
//                             width: 1, // 设置边框宽度
//                           )),
//                       fixedSize: const Size(48, 48), // 设置固定大小
//                     ),
//                     onPressed: () {
//                       showAddFormulaTypeDialog();
//                     },
//                     icon: Icon(
//                       Icons.add,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ]),
//         ),
//       ]),
//       Row(children: [
//         SizedBox(
//           width: width / 2,
//           height: 90,
//           child: Column(children: [
//             showItemName(localizedStrings.fConfidential, true),
//             Row(
//               children: [
//                 Checkbox(
//                   value: isEncrypted, // 假设这是一个状态变量，用于跟踪复选框的状态
//                   onChanged: (bool? newValue) {
//                     setState(() {
//                       isEncrypted = newValue!;
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: Text(
//                     localizedStrings.fConfidential,
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onSurface,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//                 // Tooltip(
//                 //   message: '自由配方模式', // 提示信息
//                 //   child: ElevatedButton(
//                 //     style: ElevatedButton.styleFrom(
//                 //       fixedSize: const Size(150, 48),
//                 //       backgroundColor: Theme.of(context).colorScheme.primary,
//                 //       foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                 //       shape: RoundedRectangleBorder(
//                 //         borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
//                 //       ),
//                 //     ),
//                 //     onPressed: null,
//                 //     child: Text(
//                 //       "自由配方模式",
//                 //       style: TextStyle(
//                 //         color: Theme.of(context)
//                 //             .colorScheme
//                 //             .onPrimary, // 可以根据需要调整文本颜色
//                 //         fontSize: 14, // 可以根据需要调整字体大小
//                 //         overflow: TextOverflow.ellipsis,
//                 //         fontWeight: FontWeight.normal,
//                 //       ),
//                 //     ),
//                 //   ),
//                 // )
//               ],
//             ),
//           ]),
//         ),
//         SizedBox(
//           width: width / 2,
//           height: 90,
//           child: Column(children: [
//             showItemName(localizedStrings.fNeedContainer, true),
//             Row(
//               children: [
//                 Checkbox(
//                   value: needContainer, // 假设这是一个状态变量，用于跟踪复选框的状态
//                   onChanged: (bool? newValue) {
//                     setState(() {
//                       needContainer = newValue!;
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: Text(
//                     localizedStrings.fNeedContainer,
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onSurface,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ]),
//         ),
//       ]),
//     ]);
//   }

//   // 向上移动元素
//   void moveUp(int index) {
//     if (index > 0) {
//       setState(() {
//         // 交换当前元素和上一个元素的位置
//         final temp = addFormulaRawList[index];
//         addFormulaRawList[index] = addFormulaRawList[index - 1];
//         addFormulaRawList[index - 1] = temp;
//         // 更新元素的顺序
//         addFormulaRawList[index].sequence = index + 1;
//         addFormulaRawList[index - 1].sequence = index;
//       });
//     }
//   }

//   // 向下移动元素
//   void moveDown(int index) {
//     if (index < addFormulaRawList.length - 1) {
//       setState(() {
//         // 交换当前元素和下一个元素的位置
//         final temp = addFormulaRawList[index];
//         addFormulaRawList[index] = addFormulaRawList[index + 1];
//         addFormulaRawList[index + 1] = temp;
//         // 更新元素的顺序
//         addFormulaRawList[index].sequence = index + 1;
//         addFormulaRawList[index + 1].sequence = index + 2;
//       });
//     }
//   }

//   void updateTotalWgt() {
//     totalWgt = 0.0;
//     if (addFormulaRawList.isEmpty) {
//       return;
//     }
//     for (var item in addFormulaRawList) {
//       totalWgt += item.wgt;
//     }
//     totalWgt = double.parse(totalWgt.toStringAsFixed(3));
//   }

//   showRawOrderRow(AddFormulaRawWgtInfo item, int index, bool isSelected) {
//     return Container(
//       height: 48,
//       margin: EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Container(
//             width: 22,
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? Theme.of(context).colorScheme.primary
//                   : Theme.of(context).colorScheme.surfaceContainerLow,
//               border: Border(
//                 right: BorderSide(
//                   color: Theme.of(context).colorScheme.outline,
//                   width: 1,
//                 ),
//               ),
//               shape: BoxShape.circle,
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               '${index + 1}',
//               style: TextStyle(
//                 color: isSelected
//                     ? Theme.of(context).colorScheme.onPrimary
//                     : Theme.of(context).colorScheme.onSurface,
//               ),
//             ),
//           ),
//           SizedBox(width: 10),
//           Expanded(
//               child: InkWell(
//             onTap: () {
//               setState(() {
//                 selectedIndex = index;
//               });
//             },
//             child: Container(
//               height: 48,
//               alignment: Alignment.centerLeft,
//               color: isSelected
//                   ? Theme.of(context).colorScheme.primary
//                   : Theme.of(context).colorScheme.surfaceContainerLow,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: RichText(
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: localizedStrings.fFmaNameLabel + ':  ',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: isSelected
//                                             ? Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface
//                                                 .withOpacity(0.5),
//                                       ),
//                                 ),
//                                 TextSpan(
//                                   text:
//                                       item.rawDataInfo.rawMaterial.materialName,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: isSelected
//                                             ? Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface,
//                                       ),
//                                 ),
//                                 TextSpan(text: '    '),
//                                 TextSpan(
//                                   text: formulaModeCtl.text ==
//                                           FormulaMode.wgt.name
//                                       ? localizedStrings.fWeightMode + ":"
//                                       : localizedStrings.fPctMode + ":",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: isSelected
//                                             ? Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface
//                                                 .withOpacity(0.5),
//                                       ),
//                                 ),
//                                 TextSpan(
//                                   text: item.wgt.toString(),
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: isSelected
//                                             ? Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface,
//                                       ),
//                                 ),
//                                 TextSpan(text: '    '),
//                                 TextSpan(
//                                   text: localizedStrings.fAllowableError + ':',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: isSelected
//                                             ? Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface
//                                                 .withOpacity(0.5),
//                                       ),
//                                 ),
//                                 TextSpan(
//                                   text: item.error.toString(),
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: isSelected
//                                             ? Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface,
//                                       ),
//                                 ),
//                                 TextSpan(text: '    '),
//                                 TextSpan(
//                                   text:
//                                       localizedStrings.fIngredientRemark + ": ",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: isSelected
//                                             ? Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface
//                                                 .withOpacity(0.5),
//                                       ),
//                                 ),
//                                 TextSpan(
//                                   text: item.rawDataInfo.rawMaterial.ingredient,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .apply(
//                                         color: isSelected
//                                             ? Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .onSurface,
//                                       ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Container(
//                         height: 48,
//                         alignment: Alignment.center,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 moveUp(index);
//                               },
//                               onHover: (bool hovering) {},
//                               child: Icon(
//                                 Icons.keyboard_arrow_up_sharp,
//                                 color: isSelected
//                                     ? Theme.of(context).colorScheme.onPrimary
//                                     : Theme.of(context).colorScheme.onSurface,
//                                 size: 16,
//                               ),
//                             ),
//                             InkWell(
//                               hoverColor: Theme.of(context)
//                                   .colorScheme
//                                   .primary
//                                   .withOpacity(0.1),
//                               onTap: () {
//                                 moveDown(index);
//                               },
//                               onHover: (bool hovering) {},
//                               child: Icon(
//                                 Icons.keyboard_arrow_down_sharp,
//                                 color: isSelected
//                                     ? Theme.of(context).colorScheme.onPrimary
//                                     : Theme.of(context).colorScheme.onSurface,
//                                 size: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       SizedBox(
//                         child: IconButton(
//                           iconSize: 24,
//                           onPressed: () {
//                             setState(() {
//                               addFormulaRawList.removeAt(index);
//                               updateTotalWgt();
//                             });
//                           },
//                           icon: Icon(
//                             Icons.delete_outline,
//                             color: isSelected
//                                 ? Theme.of(context).colorScheme.onPrimary
//                                 : Theme.of(context).colorScheme.onSurface,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           )),
//         ],
//       ),
//     );
//   }

//   showContainerOrder() {
//     return Container(
//       height: 48,
//       margin: EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Container(
//             width: 22,
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surfaceContainerLow,
//               border: Border(
//                 right: BorderSide(
//                   color: Theme.of(context).colorScheme.outline,
//                   width: 1,
//                 ),
//               ),
//               shape: BoxShape.circle,
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               '0',
//               style: Theme.of(context).textTheme.bodySmall!.apply(
//                     color: Theme.of(context).colorScheme.onSurface,
//                   ),
//             ),
//           ),
//           SizedBox(width: 10),
//           Expanded(
//             child: Container(
//               height: 48,
//               alignment: Alignment.centerLeft,
//               color: Theme.of(context).colorScheme.surfaceContainerLow,
//               child: Row(
//                 children: [
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: RichText(
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: localizedStrings.fFmaContainer,
//                             style: Theme.of(context).textTheme.bodySmall!.apply(
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .onSurface
//                                       .withOpacity(0.5),
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void newFma() {
//     setState(() {
//       formulaCodeCtl.text = '';
//       formulaNameCtl.text = '';
//       formulaTypeCtl.text = '';
//       formulaModeCtl.text = 'wgt';
//       formulaUnitCtl.text = 'g';
//       addFormulaRawList.clear();
//       totalWgt = 0;
//       remarkCtl.text = '';
//       isEncrypted = false;
//       needContainer = false;
//       selectedRawDataInfo = null;
//       selectedIndex = -1;
//       rawMaterialCtl.clear();
//       errorCtl.text = '';
//       wgtCtl.text = '';
//     });
//   }

//   // 显示添加部分的组件
//   Widget showAddWidget(BoxConstraints constraints) {
//     return Expanded(
//         flex: 11,
//         child: Container(
//             padding: const EdgeInsets.only(right: 20),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 54,
//                   child: Row(children: [
//                     Expanded(
//                         child: Container(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         localizedStrings.fSetRawMaterialBtn,
//                         style: Theme.of(context).textTheme.bodyMedium!.apply(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                       ),
//                     ))
//                   ]),
//                 ),
//                 SizedBox(
//                   height: constraints.maxHeight - 54,
//                   child: ListView(
//                     children: [
//                       SizedBox(
//                         height: 90,
//                         child: Row(children: [
//                           Expanded(
//                             flex: 1,
//                             child: Column(children: [
//                               SizedBox(
//                                 height: 42,
//                                 child: showItemName(
//                                     localizedStrings.fSelectRawMaterialHint,
//                                     false),
//                               ),
//                               showRawDropDownBtn(
//                                 localizedStrings.fSelectRawMaterialHint,
//                               )
//                             ]),
//                           ),
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Expanded(
//                               flex: 1,
//                               child: Column(children: [
//                                 SizedBox(
//                                   height: 42,
//                                   child: showItemName(
//                                       formulaModeCtl.text ==
//                                               FormulaMode.wgt.name
//                                           ? localizedStrings.fWeightMode + ':'
//                                           : localizedStrings.fPctMode + ':',
//                                       false),
//                                 ),
//                                 Container(
//                                     height: 48,
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: TextField(
//                                             controller: wgtCtl,
//                                             onChanged: (value) {
//                                               setState(() {});
//                                             },
//                                             inputFormatters: [
//                                               FilteringTextInputFormatter.allow(
//                                                   RegExp(
//                                                       r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
//                                               LengthLimitingTextInputFormatter(
//                                                   10),
//                                             ],
//                                             decoration: InputDecoration(
//                                               border: OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                           Radius.circular(
//                                                               0.0))),
//                                               hintText: formulaModeCtl.text ==
//                                                       FormulaMode.wgt.name
//                                                   ? localizedStrings
//                                                       .fInputWeightHint
//                                                   : localizedStrings
//                                                       .fInputPercentageHint,
//                                               hintStyle: Theme.of(context)
//                                                   .textTheme
//                                                   .bodySmall!
//                                                   .apply(
//                                                     color: Theme.of(context)
//                                                         .colorScheme
//                                                         .onSurfaceVariant,
//                                                   ),
//                                               suffixIcon: Container(
//                                                   width: 50,
//                                                   alignment: Alignment.center,
//                                                   child: Center(
//                                                     child: Text(
//                                                       formulaModeCtl.text ==
//                                                               FormulaMode
//                                                                   .wgt.name
//                                                           ? formulaUnitCtl.text
//                                                           : pctStrShow,
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .bodySmall!
//                                                           .apply(
//                                                             color: Theme.of(
//                                                                     context)
//                                                                 .colorScheme
//                                                                 .onSurfaceVariant,
//                                                           ),
//                                                     ),
//                                                   )),
//                                             ),
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodySmall!
//                                                 .apply(
//                                                   color: Theme.of(context)
//                                                       .colorScheme
//                                                       .onSurface,
//                                                 ),
//                                           ),
//                                         ),
//                                       ],
//                                     ))
//                               ]))
//                         ]),
//                       ),
//                       SizedBox(
//                         height: 90,
//                         child: Row(children: [
//                           Expanded(
//                             flex: 1,
//                             child: Column(children: [
//                               SizedBox(
//                                 height: 42,
//                                 child: showItemName(
//                                     localizedStrings.fAllowableError, false),
//                               ),
//                               Container(
//                                   height: 48,
//                                   child: Row(children: [
//                                     Expanded(
//                                       child: TextField(
//                                         onChanged: (value) {
//                                           setState(() {});
//                                         },
//                                         controller: errorCtl,
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.allow(
//                                               RegExp(
//                                                   r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
//                                           LengthLimitingTextInputFormatter(10),
//                                         ],
//                                         decoration: InputDecoration(
//                                           border: OutlineInputBorder(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(0.0))),
//                                           hintText:
//                                               localizedStrings.fInputErrorHint,
//                                           hintStyle: Theme.of(context)
//                                               .textTheme
//                                               .bodySmall!
//                                               .apply(
//                                                 color: Theme.of(context)
//                                                     .colorScheme
//                                                     .onSurfaceVariant,
//                                               ),
//                                           prefixIcon: Container(
//                                             width: 30,
//                                             alignment: Alignment.center,
//                                             child: Text(
//                                               showErrorStr,
//                                               style: Theme.of(context)
//                                                   .textTheme
//                                                   .bodySmall!
//                                                   .apply(
//                                                     color: Theme.of(context)
//                                                         .colorScheme
//                                                         .onSurfaceVariant,
//                                                   ),
//                                             ),
//                                           ),
//                                           suffixIcon: Container(
//                                               width: 50,
//                                               alignment: Alignment.center,
//                                               child: Center(
//                                                 child: Text(
//                                                   formulaModeCtl.text ==
//                                                           FormulaMode.wgt.name
//                                                       ? formulaUnitCtl.text
//                                                       : pctStrShow,
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .bodySmall!
//                                                       .apply(
//                                                         color: Theme.of(context)
//                                                             .colorScheme
//                                                             .onSurfaceVariant,
//                                                       ),
//                                                 ),
//                                               )),
//                                         ),
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodySmall!
//                                             .apply(
//                                               color: Theme.of(context)
//                                                   .colorScheme
//                                                   .onSurface,
//                                             ),
//                                       ),
//                                     ),
//                                   ]))
//                             ]),
//                           ),
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Expanded(
//                               flex: 1,
//                               child: Column(children: [
//                                 Container(
//                                   height: 42,
//                                 ),
//                                 Row(children: [
//                                   Expanded(
//                                     child: ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         foregroundColor: Theme.of(context)
//                                             .colorScheme
//                                             .onPrimary,
//                                         backgroundColor: Theme.of(context)
//                                             .colorScheme
//                                             .primary,
//                                         fixedSize:
//                                             const Size(double.infinity, 48),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.zero,
//                                         ),
//                                       ),
//                                       onPressed: (selectedRawDataInfo == null ||
//                                               wgtCtl.text == '' ||
//                                               errorCtl.text == '')
//                                           ? null
//                                           : () {
//                                               if (selectedRawDataInfo == null) {
//                                                 return;
//                                               }
//                                               double wgt = 0.0;
//                                               if (wgtCtl.text != '') {
//                                                 wgt = double.parse(wgtCtl.text);
//                                               }
//                                               double error = 0.0;
//                                               if (errorCtl.text != '') {
//                                                 error =
//                                                     double.parse(errorCtl.text);
//                                               }

//                                               int num =
//                                                   addFormulaRawList.length + 1;
//                                               AddFormulaRawWgtInfo tempInfo =
//                                                   AddFormulaRawWgtInfo(
//                                                       rawDataInfo:
//                                                           selectedRawDataInfo!,
//                                                       sequence: num,
//                                                       wgt: wgt,
//                                                       error: error);
//                                               setState(() {
//                                                 addFormulaRawList.add(tempInfo);
//                                                 updateTotalWgt();
//                                                 //清空输入框
//                                                 wgtCtl.text = '';
//                                                 errorCtl.text = '';
//                                                 rawMaterialCtl.clear();
//                                                 selectedRawDataInfo = null;
//                                               });
//                                             },
//                                       child: Text(
//                                         localizedStrings.gBtnAdd,
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.normal,
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .onPrimary,
//                                             overflow: TextOverflow.ellipsis),
//                                       ),
//                                     ),
//                                   )
//                                 ]),
//                               ]))
//                         ]),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Container(
//                                 height: constraints.maxHeight -
//                                             54 -
//                                             90 -
//                                             90 -
//                                             30 <
//                                         90
//                                     ? 90
//                                     : constraints.maxHeight - 54 - 90 - 90 - 30,
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .surfaceContainerLow,
//                                 alignment: Alignment.centerLeft,
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                         child: Container(
//                                             padding: const EdgeInsets.all(10),
//                                             alignment: Alignment.topLeft,
//                                             child: SelectableText(
//                                               selectedRawDataInfo == null
//                                                   ? ""
//                                                   : selectedRawDataInfo!
//                                                       .rawMaterial.ingredient,
//                                               style: TextStyle(
//                                                 color: Theme.of(context)
//                                                     .colorScheme
//                                                     .onSurface,
//                                               ),
//                                             )))
//                                   ],
//                                 )),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )

//                 // 其他组件
//               ],
//             )));
//   }

//   //保存功能
//   void saveFormula(int func) {
//     bool res = true;
//     if (formulaDataList.isNotEmpty) {
//       for (var item in formulaDataList) {
//         if (item.header!.formulaHeader!.formulaId == formulaCodeCtl.text) {
//           showTipInfo(localizedStrings.fFormulaIdDuplicate, context);
//           res = false;
//           return;
//         }
//         if (item.header!.formulaHeader!.formulaName == formulaNameCtl.text) {
//           showTipInfo(localizedStrings.fFormulaNameDuplicate, context);
//           res = false;
//           return;
//         }
//       }
//     }
//     if (!res) {
//       return;
//     }

//     //查找配方类别的ID
//     int categoryId = 0;
//     for (var item in formulaTypeList) {
//       if (item.categoryName == formulaTypeCtl.text) {
//         categoryId = item.categoryId;
//         break;
//       }
//     }
//     ReqFormulaHeader tempHeader = ReqFormulaHeader(
//       formulaId: formulaCodeCtl.text,
//       formulaName: formulaNameCtl.text,
//       categoryId: categoryId,
//       formulaMode: formulaModeCtl.text,
//       formulaUnit: formulaUnitCtl.text,
//       totalWeight: totalWgt,
//       materialCount: addFormulaRawList.length,
//       isEncrypted: isEncrypted,
//       needContainer: needContainer,
//       createdBy: 'admin',
//       updatedBy: 'admin',
//       remark: remarkCtl.text,
//     );
//     ReqFormulaAddInfo tempReqAddF = ReqFormulaAddInfo(
//       header: tempHeader,
//       detail: [],
//     );
//     int no = 1;
//     for (var item in addFormulaRawList) {
//       ReqFormulaDetail tempDetail = ReqFormulaDetail();
//       tempDetail.formulaId = formulaCodeCtl.text;
//       tempDetail.materialId = item.rawDataInfo.rawMaterial.materialId;
//       tempDetail.materialWeight = item.wgt;

//       tempDetail.materialPercentage = item.wgt;
//       tempDetail.sequence = no++;
//       tempDetail.allowableError = item.error;
//       tempDetail.remark = '';

//       tempReqAddF.detail!.add(tempDetail);
//     }

//     String jsonStr = formulaAddInfoToJson(tempReqAddF);
//     PublicFunctions.addFormulaData(jsonStr);

//     if (func == 1) {
//       newFma();
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   // 显示顺序和删除按钮
//   Widget showOrderWidget(BoxConstraints constraints) {
//     return Expanded(
//         flex: 13,
//         child: Container(
//             padding: const EdgeInsets.only(left: 10),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 54,
//                   child: Row(children: [
//                     Expanded(
//                         child: Container(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         localizedStrings.fIngredientOrder,
//                         style: Theme.of(context).textTheme.bodyMedium!.apply(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                       ),
//                     )),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Expanded(
//                         child: Container(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         formulaModeCtl.text == FormulaMode.wgt.name
//                             ? '${localizedStrings.fTotalWeightLabel} :  ${totalWgt.toString()} ${formulaUnitCtl.text}'
//                             : '${localizedStrings.fTotalWeightLabel} :  ${totalWgt.toString()} %',
//                         style: Theme.of(context).textTheme.bodyMedium!.apply(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     )),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     TextButton(
//                         style: TextButton.styleFrom(
//                           fixedSize: const Size(100, 40),
//                           backgroundColor:
//                               Theme.of(context).colorScheme.surface,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
//                             side: BorderSide(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .outline, // 设置边框颜色
//                               width: 1, // 设置边框宽度
//                             ),
//                           ),
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             addFormulaRawList.clear();
//                           });
//                         },
//                         child: Text(
//                           localizedStrings.fClearBtn,
//                           style: Theme.of(context).textTheme.bodySmall!.apply(
//                                 color: Theme.of(context).colorScheme.onSurface,
//                               ),
//                           overflow: TextOverflow.ellipsis,
//                         ))
//                   ]),
//                 ),
//                 if (needContainer) showContainerOrder(),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: addFormulaRawList.length,
//                     itemBuilder: (context, index) {
//                       final item = addFormulaRawList[index];
//                       final isSelected = index == selectedIndex;
//                       return showRawOrderRow(item, index, isSelected);
//                     },
//                   ),
//                 ),
//               ],
//             )));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final double widthFor3Item =
//         (width - 200) / 3 > 400 ? 400 : (width - 200) / 3;
//     return Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
//         body:
//             // Padding(
//             //   padding: const EdgeInsets.all(14.0),
//             //   child:
//             Container(
//           color: Theme.of(context).colorScheme.surface,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 54,
//                 child: Row(
//                   children: [
//                     SizedBox(width: 20),
//                     Container(
//                       width: 3,
//                       height: 14,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                     SizedBox(width: 12),
//                     SizedBox(
//                       child: Text(
//                         localizedStrings.fAddFmaBtn,
//                         style: Theme.of(context).textTheme.bodyMedium!.apply(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                       ),
//                     ),
//                     SizedBox(width: 20),
//                   ],
//                 ),
//               ),
//               Divider(
//                 height: 1,
//                 color: Theme.of(context).colorScheme.outline,
//               ),
//               Container(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   height: 202,
//                   child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         showCodeAndMode(widthFor3Item),
//                         showNameAndUnit(widthFor3Item),
//                         showTypeAndEncrypt(widthFor3Item),
//                       ])),
//               Divider(
//                 height: 1,
//                 color: Theme.of(context).colorScheme.outline,
//               ),
//               Expanded(
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     return Container(
//                       padding: const EdgeInsets.only(left: 20, right: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           showAddWidget(constraints),
//                           Container(
//                             padding: const EdgeInsets.only(top: 24),
//                             child: VerticalDivider(
//                               width: 1,
//                               color: Theme.of(context).colorScheme.outline,
//                             ),
//                           ),
//                           showOrderWidget(constraints),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Container(
//                   height: 114,
//                   alignment: Alignment.centerLeft,
//                   child: Column(children: [
//                     Container(
//                         height: 42,
//                         padding: const EdgeInsets.only(left: 20, right: 20),
//                         child: Row(children: [
//                           Expanded(
//                               child: Container(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               localizedStrings.fRemarkCol,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall!
//                                   .apply(
//                                     color:
//                                         Theme.of(context).colorScheme.onSurface,
//                                   ),
//                             ),
//                           )),
//                         ])),
//                     Container(
//                         height: 72,
//                         padding: const EdgeInsets.only(left: 20, right: 20),
//                         child: Row(children: [
//                           Expanded(
//                               child: Container(
//                             height: 72,
//                             child: TextField(
//                               controller: remarkCtl,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall!
//                                   .apply(
//                                     color:
//                                         Theme.of(context).colorScheme.onSurface,
//                                   ),
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(0.0))),
//                                 hintText: localizedStrings.fInputRemarkHint,
//                                 hintStyle: TextStyle(
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .onSurfaceVariant,
//                                 ),
//                               ),
//                               maxLines: 5,
//                             ),
//                           ))
//                         ]))
//                   ])),
//               SizedBox(
//                   height: 86,
//                   child: Center(
//                       child: SizedBox(
//                     width: 400,
//                     height: 48,
//                     child: Row(children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             foregroundColor:
//                                 Theme.of(context).colorScheme.onPrimary,
//                             backgroundColor:
//                                 Theme.of(context).colorScheme.primary,
//                             fixedSize: const Size(double.infinity, 48),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
//                             ),
//                           ),
//                           onPressed: formulaCodeCtl.text == '' ||
//                                   formulaNameCtl.text == '' ||
//                                   formulaTypeCtl.text == '' ||
//                                   formulaModeCtl.text == '' ||
//                                   formulaUnitCtl.text == '' ||
//                                   addFormulaRawList.isEmpty
//                               ? null
//                               : (formulaModeCtl.text == FormulaMode.pct.name &&
//                                       totalWgt != 100)
//                                   ? null
//                                   : () {
//                                       //先判断是否有重复的ID和名称
//                                       //先判断formulaDataList是否为空
//                                       saveFormula(1);
//                                       //清空所有的内容，做一个干净的配方
//                                     },
//                           child: Text(
//                             localizedStrings.gBtnSave,
//                             style: TextStyle(
//                               fontWeight: FontWeight.normal,
//                               color: Theme.of(context).colorScheme.onPrimary,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 20,
//                       ),
//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             foregroundColor:
//                                 Theme.of(context).colorScheme.onSurfaceVariant,
//                             backgroundColor:
//                                 Theme.of(context).colorScheme.outline,
//                             fixedSize: const Size(double.infinity, 48),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
//                             ),
//                           ),
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             localizedStrings.fBackBtn,
//                             style: Theme.of(context).textTheme.bodySmall!.apply(
//                                   color:
//                                       Theme.of(context).colorScheme.onSurface,
//                                 ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ),
//                     ]),
//                   ))),
//             ],
//           ),
//           // ),
//         ));
//   }
// }

// // 定义新增配方类型弹框组件
// class AddFormulaTypeDialog extends StatefulWidget {
//   const AddFormulaTypeDialog({super.key});
//   @override
//   AddFormulaTypeDialogState createState() => AddFormulaTypeDialogState();
// }

// class AddFormulaTypeDialogState extends State<AddFormulaTypeDialog> {
//   TextEditingController formulaTypeCtl = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         width: 610,
//         height: 376,
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface,
//           borderRadius: BorderRadius.circular(0),
//         ),
//         child: Column(
//           children: [
//             // 头部
//             Container(
//                 height: 54,
//                 padding: const EdgeInsets.only(left: 20, right: 20),
//                 alignment: Alignment.centerLeft,
//                 child: Row(children: [
//                   Container(
//                     width: 3,
//                     height: 14,
//                     color: Theme.of(context).colorScheme.onSurface,
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Expanded(
//                     child: Container(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         localizedStrings.fAddTypeBtn,
//                         style: Theme.of(context).textTheme.bodyMedium!.apply(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                       icon: Icon(
//                         Icons.cancel,
//                         size: 24,
//                         color: Theme.of(context).colorScheme.secondaryFixed,
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       })
//                 ])),
//             // 分割线
//             Divider(
//               height: 1,
//               color: Theme.of(context).colorScheme.outline,
//             ),
//             // 中部
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.all(26),
//                 height: 150,
//                 width: 500,
//                 child: Column(children: [
//                   SizedBox(
//                     height: 42,
//                     child: Row(children: [
//                       Expanded(
//                         child: Container(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             localizedStrings.fFmaCategoryCol,
//                             style: Theme.of(context).textTheme.bodySmall!.apply(
//                                   color:
//                                       Theme.of(context).colorScheme.onSurface,
//                                 ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ),
//                     ]),
//                   ),
//                   SizedBox(
//                     child: Row(children: [
//                       Expanded(
//                         child: Container(
//                             alignment: Alignment.centerLeft,
//                             child: TextField(
//                               onChanged: (value) {
//                                 setState(() {});
//                               },
//                               controller: formulaTypeCtl,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(0.0))),
//                                 hintText:
//                                     localizedStrings.fInputFormulaTypeHint,
//                                 suffixIconConstraints:
//                                     BoxConstraints.tight(Size(40, 40)),
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     Icons.close,
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .onSurfaceVariant,
//                                   ),
//                                   onPressed: () {
//                                     formulaTypeCtl.clear(); // 清空文本
//                                     setState(() {});
//                                   },
//                                 ),
//                               ),
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall!
//                                   .apply(
//                                     color:
//                                         Theme.of(context).colorScheme.onSurface,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                               maxLines: 5,
//                               minLines: 1,
//                             )),
//                       ),
//                     ]),
//                   ),
//                 ]),
//               ),
//             ),

//             // 底部
//             Container(
//               height: 96,
//               width: 400,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onPrimary,
//                         backgroundColor: Theme.of(context).colorScheme.primary,
//                         fixedSize: const Size(double.infinity, 48),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.zero,
//                         ),
//                       ),
//                       onPressed: formulaTypeCtl.text.isEmpty
//                           ? null
//                           : () {
//                               for (var item in formulaTypeList) {
//                                 if (item.categoryName == formulaTypeCtl.text) {
//                                   showTipInfo(
//                                       localizedStrings.fTypeExistsMsg, context);
//                                   return;
//                                 }
//                               }
//                               PublicFunctions.addFormulaType(
//                                   formulaTypeCtl.text);
//                               Navigator.pop(context);
//                             },
//                       child: Text(
//                         localizedStrings.gBtnConfirm,
//                         style: Theme.of(context).textTheme.bodyMedium!.apply(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onSurfaceVariant,
//                         backgroundColor: Theme.of(context)
//                             .colorScheme
//                             .surfaceContainerHighest,
//                         fixedSize: const Size(double.infinity, 48),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.zero,
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(
//                         localizedStrings.gBtnCancel,
//                         style: Theme.of(context).textTheme.bodyMedium!.apply(
//                               color: Theme.of(context).colorScheme.onPrimary,
//                             ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 新增配方时选择的临时原料列表
// class AddFormulaRawWgtInfo {
//   RawDataInfo rawDataInfo; // 原料信息
//   double wgt; // 权重
//   int sequence;
//   double error; //误差

//   bool isSelected;

//   AddFormulaRawWgtInfo(
//       {required this.rawDataInfo,
//       required this.sequence,
//       required this.wgt,
//       required this.error,
//       this.isSelected = false});
// }
