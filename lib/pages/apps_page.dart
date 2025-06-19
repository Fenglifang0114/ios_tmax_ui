//应用的界面

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/parse_log.dart';
import 'package:t_max/data/routes_data.dart';
import 'package:t_max/dialog/app_common_data.dart';
import 'package:t_max/dialog/license_info.dart';

import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/formula_scale_page.dart';
import 'package:t_max/pages/labeldesign_page.dart';
import 'package:t_max/pages/receipt_design_page.dart';
import 'package:t_max/pages/weighing.dart';
import 'package:t_max/pages/weight_collection_page.dart';
import 'package:t_max/widget/show_license_res.dart';

class AppsPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;

  const AppsPage(
      {super.key, required this.onNavigate, required this.lastRouteName});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  // 模拟第二部分列表数据

  TextEditingController activationFileCtl = TextEditingController();
  List<String> licList = [];

  final TextEditingController pidCtl = TextEditingController();
  TextEditingController licCtl = TextEditingController();

  String pId = '';
  String dueDate = '';
  bool isPass = false;
  bool licenseKey = false;
  String moduleName = '';
  LicenseInfo newLicInfo = LicenseInfo(false, '', '', '');

  late List<bool> _isHoveredList;

  //做一个map 存放功能和激活的日期，描述

  ValueNotifier<Map<String, ShowAppActiveInfo>> mapActiveMenusRes =
      ValueNotifier({});

  @override
  void didChangeDependencies() {
    _isHoveredList = List.filled(getCurrentAppsMenus().length, false);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    activationFileCtl.dispose();
    pidCtl.dispose();
    licCtl.dispose();

    super.dispose();
  }

  void updateResCtl() {
    nextLicCheck();
  }

  void nextLicCheck() {
    if (licList.length >= 2) {
      licList.removeAt(0);
      PublicFunctions.checkLicenseKey(licList[0]);
    } else {
      licList.clear();
    }
  }

  //验证新日期是否可用，true 可用，直接更新，false 询问是否更新
  bool isLongerValidityPeriod(String oldLicenseDate, String newLicenseDate) {
    bool res = false;
    DateTime dateTimeOld = DateTime.parse(oldLicenseDate);
    DateTime dateTimeNew = DateTime.parse(newLicenseDate);

    if (dateTimeOld.isBefore(dateTimeNew)) {
      res = true;
    }
    return res;
  }

  void updateLicenseInfo() {
    PublicFunctions.updateLicense(licList[0]);
  }

  Widget buildAppInfo(BuildContext context, int index, int type) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    List<RouteData> list = getCurrentAppsMenus();
    if (list.isEmpty) return SizedBox();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        setState(() {
          _isHoveredList[index] = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHoveredList[index] = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          // 点击卡片跳转页面
          if (list[index].id == MenuId.formulationScalePage.index) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const FormulationScalePage()),
            );
          } else if (list[index].id == MenuId.weightModePage.index) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WeightModePage()),
            );
          } else if (list[index].id == MenuId.labelDesignPage.index) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LabelDesignPage(type: "app")),
            );
          } else if (list[index].id == MenuId.receiptDesignPage.index) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ReceiptDesignPage(type: "app")),
            );
          } else if (list[index].id == MenuId.weightDataCollectionPage.index) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WeightDataCollectionPage()),
            );
          } else {
            widget.onNavigate(list[index].routeName!);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHoveredList[index]
                ? colorScheme.primary
                : colorScheme.surface,
            border:
                Border.all(width: 1, color: colorScheme.surfaceContainerLow),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 98,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 使用 AnimatedColorFilter 来改变图标颜色
                        AnimatedColorFilter(
                          color: _isHoveredList[index]
                              ? Colors.white
                              : colorScheme.primary,
                          duration: const Duration(milliseconds: 200),
                          child: getSvgIcon(list[index].iconPath, 58, 58,
                              colorScheme.primary),
                        ),
                        SizedBox(
                          width: smallPadding,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: smallPadding,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: textTheme.bodySmall!.apply(
                          color: _isHoveredList[index]
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                        ),
                        child: SelectableText(
                          list[index].subtitle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: smallPadding,
                  ),
                ],
              ),
              // 右上角移除图标
              if (!isFreeApp(list[index].id))
                Positioned(
                  top: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHoveredList[index] ? 1.0 : 0.0,
                    child: IconButton(
                      icon: Icon(Icons.remove_circle,
                          color: Theme.of(context).colorScheme.error),
                      iconSize: 24,
                      onPressed: () {
                        // 处理移除逻辑
                        setState(() {
                          selectedAppsPaidMenuIds.remove(list[index].id);
                        });
                        writePageIdsToJson(selectedConfigPaidMenuIds,
                            selectedAppsPaidMenuIds, widget.lastRouteName);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(children: [
        // 第一部分，固定高度 64

        // 第二部分和第三部分按 13:10 比例分配剩余空间
        Expanded(
          child: Container(
              color: colorScheme.surface,
              child: Row(children: [
                Expanded(
                    child: Container(
                  padding: EdgeInsets.only(
                      left: regularPadding,
                      right: regularPadding,
                      bottom: regularPadding),
                  child: Column(children: [
                    Expanded(
                        child: Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.only(
                          left: regularPadding,
                          right: regularPadding,
                          bottom: regularPadding,
                          top: 40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // 计算每个元素的宽度，减去元素间的间距后平分
                          double itemWidth = 200; // 每个元素的宽度;
                          return SingleChildScrollView(
                            child: Wrap(
                              spacing: 50, // 元素间的水平间距
                              runSpacing: 40, // 元素间的垂直间距
                              children: List.generate(
                                getCurrentAppsMenus().length,
                                (index) {
                                  return SizedBox(
                                    width: itemWidth,
                                    height: 190, // 固定元素高度
                                    child: buildAppInfo(context, index, 1),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    )),
                  ]),
                )),
              ])),
        ),
        Container(
            height: 64,
            color: colorScheme.surface,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              textBtn(
                context,
                colorScheme,
                textTheme,
                () {
                  widget.onNavigate('/settingsAppsSetting');
                },
                localizedStrings.gTitleAppConfig,
                36,
              ),
              SizedBox(
                width: regularPadding,
              ),
              textColorBtn(
                context,
                colorScheme,
                textTheme,
                () {
                  widget.onNavigate(widget.lastRouteName);
                },
                localizedStrings.gBtnBackToPrevious,
                36,
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.onPrimary,
              )
            ])),
        Container(
          height: regularPadding,
          color: colorScheme.surfaceDim,
        ),
      ]),
    );
  }

  Widget buildActivatePart(ColorScheme colorScheme, TextTheme textTheme,
      VoidCallback? func, String name) {
    return Container(
      alignment: Alignment.center,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 400,
          child: showInputBox(
              activationFileCtl, localizedStrings.gTipSelectActivationFile),
        ),
        SizedBox(
          width: regularPadding,
        ),
        textBtn(context, colorScheme, textTheme, func, name, inputHeight)
      ]),
    );
  }

  showInputBox(TextEditingController controller, String hintText) {
    return Container(
      height: inputHeight,
      padding: const EdgeInsets.only(left: regularPadding, right: largePadding),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerLow), // 设置边框颜色
        borderRadius: BorderRadius.circular(0), // 设置圆角
      ),
      child: TextField(
        enabled: false,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest, // 设置提示文本颜色
          ),
          border: InputBorder.none, // 移除默认边框
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface, // 设置输入文本颜色
          fontSize: 14,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget buildBottomTitle(ColorScheme colorScheme, TextTheme textTheme,
      String title, String subtitle) {
    return Container(
        height: leftBarIconHeight,
        color: colorScheme.surface,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          title,
                          style: textTheme.bodyLarge!
                              .apply(color: colorScheme.onSurface),
                        ),
                      ),
                    ]),
              ),
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 使用 SingleChildScrollView 实现滚动功能
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical, // 垂直滚动
                          child: Text(
                            subtitle,
                            style: textTheme.bodySmall!.apply(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ]),
              )
            ]));
  }

  void showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LicenseInfoDialog();
      },
    ).then((value) => setState(() {}));
  }

  Future validLicense() async {
    String dataStr = activationFileCtl.text;
    if (dataStr.isNotEmpty) {
      try {
        File file = File(dataStr);
        String content = await file.readAsString();
        licList = content.split('\r\n');
        List<String> tmpList = [];
        for (var i = 0; i < licList.length; i++) {
          if (licList[i].length == 74 || licList[i].length == 78) {
            tmpList.add(licList[i]);
          }
        }
        licList = tmpList;
      } catch (e) {
        // print('读取文件时出错: $e');
        return;
      }
    }
  }

  Widget textAddAppBtn(ColorScheme colorScheme, TextTheme textTheme,
      VoidCallback? func, String name, int type) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: type == 2 ? Color(0xFFFFF3F3) : colorScheme.scrim,
          fixedSize: const Size(double.infinity, 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        onPressed: func,
        child: Text(
          name,
          style: Theme.of(context).textTheme.bodySmall!.apply(
              color: func == null
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : type == 2
                      ? colorScheme.error
                      : colorScheme.primary),
          overflow: TextOverflow.ellipsis,
        ));
  }
}

class AnimatedColorFilter extends ImplicitlyAnimatedWidget {
  final Widget child;
  final Color color;

  const AnimatedColorFilter({
    Key? key,
    required this.child,
    required this.color,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
  }) : super(key: key, duration: duration, curve: curve);

  @override
  AnimatedWidgetBaseState<AnimatedColorFilter> createState() =>
      _AnimatedColorFilterState();
}

class _AnimatedColorFilterState
    extends AnimatedWidgetBaseState<AnimatedColorFilter> {
  ColorTween? _color;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _color = visitor(
      _color,
      widget.color,
      (dynamic value) => ColorTween(begin: value as Color),
    ) as ColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter:
          ColorFilter.mode(_color!.evaluate(animation)!, BlendMode.srcIn),
      child: widget.child,
    );
  }
}
