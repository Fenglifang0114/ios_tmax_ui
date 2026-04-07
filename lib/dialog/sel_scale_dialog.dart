import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';

////选择秤

class SelScaleDialog extends StatefulWidget {
  const SelScaleDialog({super.key});
  @override
  SelScaleDialogState createState() => SelScaleDialogState();
}

class SelScaleDialogState extends State<SelScaleDialog> {
  TextEditingController rawCodeCtl = TextEditingController();
  TextEditingController rawNameCtl = TextEditingController();
  TextEditingController rawRemarkCtl = TextEditingController();
  TextEditingController rawTypeCtl = TextEditingController();
  dynamic _eventbus1;
  int selScaleId = -1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (myAllScalesList.isNotEmpty) {
      selScaleId = myAllScalesList[0].scaleId;
    }
    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            rawTypeList = [];
          });
        }
      }
    });
    super.initState();
  }

//

  @override
  void dispose() {
    _eventbus1.cancel();
    rawCodeCtl.dispose();
    rawNameCtl.dispose();
    rawRemarkCtl.dispose();
    rawTypeCtl.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  Widget showScaleInfo(Scale scale, bool isSelect) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
              setState(() {
                selScaleId = scale.scaleId;
              });
            },
            child: Container(
              height: scaleItemHeight,
              color: !isSelect
                  ? Theme.of(context).colorScheme.surfaceContainerLow
                  : scale.isOnline
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
              child: Row(
                children: [
                  Container(
                      width: scaleItemHeight,
                      height: scaleItemHeight,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: !isSelect
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest
                              : Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.1),
                        ),
                        width: scaleInnerItemHeight,
                        height: scaleInnerItemHeight,
                        child: scale.tMedia == 0
                            ? Container(
                                alignment: Alignment.center,
                                width: iconMenuSize,
                                height: iconMenuSize,
                                child: getSvgIcon(
                                    serialPortSvgIcon(),
                                    iconMenuSize,
                                    iconMenuSize,
                                    (!isSelect)
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary))
                            : scale.tMedia == 1
                                ? Container(
                                    alignment: Alignment.center,
                                    width: iconMenuSize,
                                    height: iconMenuSize,
                                    child: getSvgIcon(
                                        networkSvgIcon(),
                                        iconMenuSize,
                                        iconMenuSize,
                                        (!isSelect)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimary))
                                : Container(
                                    alignment: Alignment.center,
                                    width: iconMenuSize,
                                    height: iconMenuSize,
                                    child: getSvgIcon(
                                        btSvgIcon(),
                                        iconMenuSize,
                                        iconMenuSize,
                                        (!isSelect)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimary)),
                      )),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          scale.scaleName,
                          style: getTextStyle(
                            color: !isSelect
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                            scale.isOnline
                                ? localizedStrings.gTipOnline
                                : localizedStrings.gTipOffline,
                            style: getTextStyle(
                              color: isSelect
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : scale.isOnline
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onTertiaryFixedVariant
                                      : Theme.of(context).colorScheme.error,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 493,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
                context, localizedStrings.gTitleDeviceList, false),

            // 中部
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: regularPadding, vertical: regularPadding),
                // 使用 ScrollConfiguration 自定义滚动行为
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: true, // 显示滚动条
                    physics: const AlwaysScrollableScrollPhysics(), // 始终允许滚动
                  ),
                  child: Scrollbar(
                    // 始终显示滚动条
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: GridView.builder(
                      // 计算交叉轴数量为 2，表示每行两列
                      controller: _scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 每行两列
                        crossAxisSpacing: 20, // 列间距为 20
                        mainAxisSpacing: 14, // 行间距为 14
                        mainAxisExtent: scaleItemHeight,
                      ),
                      itemCount: myAllScalesList.length,
                      itemBuilder: (context, index) {
                        final scale = myAllScalesList[index];
                        bool isSelect = (selScaleId == scale.scaleId);
                        return showScaleInfo(scale, isSelect);
                      },
                    ),
                  ),
                ),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: largePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: showTextButton(
                          context,
                          btnHeight,
                          localizedStrings.gBtnConfirm,
                          (selScaleId == -1)
                              ? null
                              : () {
                                  Navigator.pop(context, selScaleId);
                                },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary)),
                  SizedBox(width: largePadding),
                  Expanded(
                      child: showTextButton(
                          context, btnHeight, localizedStrings.gBtnCancel, () {
                    Navigator.pop(context, selScaleId);
                  },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                          Theme.of(context).colorScheme.onPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
