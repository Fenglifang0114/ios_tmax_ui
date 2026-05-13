// //主界面

// import 'package:flutter/material.dart';
// import 'package:t_max/data/company_info.dart';
// import 'package:t_max/data/home_page_common_data.dart';
// import 'package:t_max/data/language.dart';
// import 'package:t_max/data/routes_data.dart';
// import 'package:smart_tooltip/smart_tooltip.dart';

// class Backdrop extends StatefulWidget {
//   const Backdrop({super.key});
//   @override
//   State<Backdrop> createState() => _BackdropState();
// }

// class _BackdropState extends State<Backdrop> {
//   //左侧部分是否收起
//   bool isLeftBarCollapsed = false;
//   late ValueNotifier<bool> _isSidebarExpandedNotifier;
//   late AnimationController _sidebarController;
//   int? _selectedIndex; // 新增选中导航栏的索引
//   bool isExpanded = true; // 侧边栏是否展开

//   @override
//   void initState() {
//     super.initState();
//     _isSidebarExpandedNotifier = ValueNotifier(true);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   // 修改后的切换侧边栏状态方法
//   void toggleSidebar() {
//     final isExpanded = _isSidebarExpandedNotifier.value;
//     _isSidebarExpandedNotifier.value = !isExpanded;
//     if (isExpanded) {
//       _sidebarController.reverse();
//     } else {
//       _sidebarController.forward();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//     List<RouteData> allRoutes = freePagesRoutes(colorScheme.onPrimary);
//     Widget showNavigationBar(bool isExpanded, List<RouteData> demos) {
//       return ListView.builder(
//         primary: false,
//         itemBuilder: (context, index) => MenuItem(
//           demo: demos[index],
//           isExpanded: isExpanded,
//           isSelected: index == _selectedIndex,
//           onTap: () {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//         ),
//         itemCount: demos.length,
//       );
//     }

//     return Scaffold(
//       body: Row(
//         children: [
//           // 左侧部分，宽度 240
//           Container(
//             width: isExpanded ? leftBarWidth : leftBarLittleWidth,
//             color: Theme.of(context).colorScheme.primary, // 可替换为实际内容
//             child: Column(children: [
//               Container(
//                 height: leftBarIconHeight,
//                 width: isExpanded ? leftBarWidth : leftBarLittleWidth,
//                 child: Row(
//                   children: [
//                     IconButton(
//                       padding: EdgeInsets.only(left: largePadding),
//                       iconSize: iconAppSize,
//                       onPressed: () {
//                         setState(() {
//                           isExpanded = !isExpanded;
//                         });
//                       },
//                       icon: Image.asset(
//                         appIconPath,
//                         width: iconAppSize,
//                         height: iconAppSize,
//                       ),
//                     ),
//                     isExpanded
//                         ? Expanded(
//                             child: Container(
//                                 padding: EdgeInsets.only(left: regularPadding),
//                                 child: Text(
//                                   myAppName.appName!,
//                                   style: textTheme.headlineSmall!.apply(
//                                       // 根据选中状态改变颜色
//                                       color: colorScheme.onPrimary),
//                                 )))
//                         : SizedBox()
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: showNavigationBar(isExpanded, allRoutes),
//               ),
//             ]),
//           ),

//           // 右侧部分，占据剩余空间
//           Expanded(
//             child: Column(
//               children: [
//                 // 右上部分，高度 64
//                 Container(
//                   height: topBarHeight,
//                   color: Colors.green, // 可替换为实际内容
//                   child:
//                       Center(child: Text(localizedStrings?.menuLabelDesign ?? "menuLabelDesign")),
//                 ),
//                 SizedBox(
//                   height: regularPadding,
//                 ),
//                 // 右下部分，占据剩余空间

//                 Expanded(
//                   child: Row(
//                     children: [
//                       // 右下左侧部分，宽度 290
//                       SizedBox(
//                         width: regularPadding,
//                       ),
//                       Container(
//                         width: scaleListWidth,
//                         color: Colors.yellow, // 可替换为实际内容
//                         child: const Center(child: Text('右下左侧部分')),
//                       ),
//                       // 右下右侧部分，占据剩余空间
//                       Expanded(
//                           child: Container(
//                         color: colorScheme.surface,
//                         child: _selectedIndex != null
//                             ? allRoutes[_selectedIndex!].buildRoute!(context)
//                             : Container(
//                                 color: colorScheme.surface,
//                               ),
//                       )),
//                       SizedBox(
//                         width: regularPadding,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: regularPadding,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// typedef CategoryHeaderTapCallback = Function(bool shouldOpenList);
// const double barLeftWidth = 24;
// const double barBetweenHeight = 13;

// // 修改 MenuItem 以支持选中状态和点击回调
// class MenuItem extends StatelessWidget {
//   const MenuItem({
//     super.key,
//     required this.demo,
//     this.isExpanded = true,
//     required this.isSelected, // 新增选中状态
//     required this.onTap, // 新增点击回调
//   });

//   final RouteData demo;
//   final bool isExpanded;
//   final bool isSelected; // 新增选中状态
//   final VoidCallback onTap; // 新增点击回调

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final colorScheme = Theme.of(context).colorScheme;

//     Widget buildMenuInfo() {
//       return SizedBox(
//           height: 52, // 固定高度
//           child: Material(
//             color: isSelected
//                 ? Color(0xFF06406F)
//                 : Theme.of(context).colorScheme.primary,
//             child: MergeSemantics(
//               child: InkWell(
//                 onTap: onTap, // 绑定点击回调
//                 child: Padding(
//                     padding: EdgeInsetsDirectional.only(
//                       start: isExpanded ? 20 : barLeftWidth,
//                       end: 5,
//                     ),
//                     child: Container(
//                       alignment: Alignment.centerLeft,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             child: demo.icon,
//                           ),
//                           if (isExpanded) ...[
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Flexible(
//                               fit: FlexFit.loose,
//                               child: FittedBox(
//                                 fit: BoxFit.scaleDown, // 仅在需要时缩小内容
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   demo.title,
//                                   maxLines: 1,
//                                   style: isSelected
//                                       ? textTheme.labelSmall!.apply(
//                                           // 根据选中状态改变颜色
//                                           color: colorScheme.onPrimary)
//                                       : textTheme.bodySmall!.apply(
//                                           // 根据选中状态改变颜色
//                                           color: colorScheme.onPrimary),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     )),
//               ),
//             ),
//           ));
//     }

//     if (isExpanded) {
//       return buildMenuInfo();
//     }
//     return SmartTooltip(
//         borderColor: colorScheme.onInverseSurface,
//         message: isExpanded ? '' : demo.title,
//         backgroundColor: colorScheme.onInverseSurface.withOpacity(0.7),
//         textStyle: TextStyle(
//           color: colorScheme.onPrimary,
//         ),
//         position: TooltipPosition.right,
//         child: buildMenuInfo());
//   }
// }
