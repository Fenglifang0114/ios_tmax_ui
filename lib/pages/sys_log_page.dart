// 系统日志页面

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/widget/log_cal_tab.dart';
import 'package:t_max/widget/log_sys_tab.dart';
import 'package:t_max/widget/log_wgt_tab.dart';

class SysLogPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const SysLogPage(
      {super.key, required this.onNavigate, required this.lastRouteName});

  @override
  State<SysLogPage> createState() => _SysLogPageState();
}

class _SysLogPageState extends State<SysLogPage>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  bool isExit = false;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _mainTabController.removeListener(() {});
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        body: Container(
            color: colorScheme.surfaceDim,
            child: Column(
              children: [
                thisPageHeadInfo(
                  context,
                  width - headWidthPadding,
                  localizedStrings.logManagement,
                ),
                if (!isExit)
                  Expanded(
                    child: TabBarView(
                      controller: _mainTabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        SysLogTabPage(contentType: ''),
                        ScaleCalLogTabPage(contentType: ''),
                        ScaleWgtLogTabPage(contentType: ''),
                      ],
                    ),
                  ),
              ],
            )));
  }

  Widget thisPageHeadInfo(
    dynamic context,
    double maxWidth,
    String pageTitle,
  ) {
    return Container(
        height: pageTopTitleHeight,
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                subTitle(context, maxWidth, pageTitle),
              ],
            ),
          ),
          Divider(
            color:
                Theme.of(context).colorScheme.surfaceContainerLow, // 设置分割线的颜色
            height: 1, // 设置分割线的高度
            thickness: 1, // 设置分割线的粗细
          ),
        ]));
  }

  Widget subTitle(
    dynamic context,
    double maxWidth,
    String pageTitle,
  ) {
    return Row(
      children: [
        SizedBox(
          width: largePadding,
        ),
        SizedBox(
          child: IconButton(
              onPressed: () {
                setState(() {
                  isExit = true;
                });
                Future.delayed(Duration.zero, () {
                  setState(() {
                    widget.onNavigate(widget.lastRouteName);
                  });
                });
              },
              icon: getSvgIcon(returnSvgIcon(), 28, 28,
                  Theme.of(context).colorScheme.primary)),
        ),
        SizedBox(
          width: regularPadding,
        ),
        SizedBox(
          width: maxWidth,
          child: TabBar(
            isScrollable: true, // 添加这行
            tabAlignment: TabAlignment.start,
            controller: _mainTabController,
            labelStyle: Theme.of(context).textTheme.bodySmall!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            unselectedLabelStyle: Theme.of(context).textTheme.bodySmall!.apply(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
            dividerHeight: 0,
            tabs: [
              Tab(
                text: localizedStrings.systemRecords,
              ),
              Tab(text: localizedStrings.calibrationRecords),
              Tab(text: localizedStrings.weighingRecords)
            ],
          ),
        ),
      ],
    );
  }
}
