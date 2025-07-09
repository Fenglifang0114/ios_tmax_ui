import 'package:flutter/material.dart';

import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/dialog/language_setting.dart';
import '../data/comscaleinfo_data.dart';
import '../data/manager_scale_channel.dart';
import 'package:t_max/data/timer_manager.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import 'box_gradient.dart';
import 'custom_button.dart';
import 'custom_circle_icon.dart';
import 'page_info.dart';

Widget pageHead(dynamic context, String pageTitle, String serialPortStatus,
    List<int> scaleList) {
  return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Container(
        decoration: BoxDecoration(gradient: boxGradient(context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: SizedBox(
                  child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                      // width: _width,
                      height: 50,
                      alignment: Alignment.centerLeft, //设置控件内容的位置
                      child: Row(
                        children: [
                          SizedBox(
                              width: 50,
                              height: 50,
                              child: IconButton(
                                  onPressed: () {
                                    _showConfirmationDialog(context, scaleList);
                                  },
                                  icon: CustomCircleIcon(
                                    outerColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    innerColor:
                                        Theme.of(context).colorScheme.primary,
                                    icon: Icons.home,
                                    size: 30.0,
                                  ))),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            child: Text(
                              pageTitle,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )),
                ],
              )),
            ),
            SizedBox(
              width: 360,
              height: 50,
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Text(serialPortStatus,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  (myComScaleInfo.isOnline)
                      ? CustomCircleIcon(
                          outerColor: Theme.of(context).colorScheme.primary,
                          innerColor: Theme.of(context).colorScheme.onPrimary,
                          icon: Icons.check_circle,
                          size: 24.0,
                        )
                      : CustomCircleIcon(
                          outerColor: Theme.of(context).colorScheme.error,
                          innerColor: Theme.of(context).colorScheme.onPrimary,
                          icon: Icons.cancel,
                          size: 24.0,
                        ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ));
}

void _showConfirmationDialog(BuildContext context, List<int> scaleList) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(
          localizedStrings.gTitleConfirm,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(localizedStrings.go_home),
        actions: <Widget>[
          Row(
            children: [
              CustomElevatedButton(
                btnWidth: 100,
                btnHeight: 40,
                icon: Icons.check_circle,
                text: localizedStrings.gBtnConfirm,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              const SizedBox(width: 20),
              CustomOutlinedButton(
                btnWidth: 100,
                btnHeight: 40,
                icon: Icons.cancel,
                text: localizedStrings.gBtnCancel,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          )
        ],
      );
    },
  ).then((confirmed) {
    if (confirmed) {
      myScreenMgr.isMainScreen = true;
      cntScaleTimerMgr.stopCntScaleTimer();
      // PublicFunctions.closewifiPassth(1);
      if (scaleList.isNotEmpty) {
        for (int i = 0; i < scaleList.length; i++) {
          // PublicFunctions.stopWeight(scaleList[i]);
        }
      }
      // PublicFunctions.closeScalePassth(1); //关闭透传
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  });
}

Widget pageHeadDesign(
    dynamic context, String pageTitle, List<int> scaleList, String helpInfo) {
  return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Container(
        decoration: BoxDecoration(gradient: boxGradient(context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: SizedBox(
                  child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                      // width: _width,
                      height: 50,
                      alignment: Alignment.centerLeft, //设置控件内容的位置
                      child: Row(
                        children: [
                          SizedBox(
                              width: 50,
                              height: 50,
                              child: IconButton(
                                  onPressed: () {
                                    _showConfirmationDialog(context, scaleList);
                                  },
                                  icon: CustomCircleIcon(
                                    outerColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    innerColor:
                                        Theme.of(context).colorScheme.primary,
                                    icon: Icons.home,
                                    size: 30.0,
                                  ))),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            child: Text(
                              pageTitle,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )),
                ],
              )),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              PageInfoButton(helpInfo: helpInfo, onRefresh: () {}),
              const SizedBox(
                width: 50,
              ),
            ])
          ],
        ),
      ));
}

Widget pageHeadDefScale(dynamic context, String pageTitle, String helpInfo) {
  List<int> scaleList = [myDefScaleInfo.defScaleId!];
  return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Container(
        decoration: BoxDecoration(gradient: boxGradient(context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: SizedBox(
                  child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                      // width: _width,
                      height: 50,
                      alignment: Alignment.centerLeft, //设置控件内容的位置
                      child: Row(
                        children: [
                          SizedBox(
                              width: 50,
                              height: 50,
                              child: IconButton(
                                  onPressed: () {
                                    _showConfirmationDialog(context, scaleList);
                                  },
                                  icon: CustomCircleIcon(
                                    outerColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    innerColor:
                                        Theme.of(context).colorScheme.primary,
                                    icon: Icons.home,
                                    size: 30.0,
                                  ))),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            child: Text(
                              pageTitle,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )),
                ],
              )),
            ),
            SizedBox(
              width: 360,
              height: 50,
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Tooltip(
                        message: myDefScaleInfo.defScaleId == 1
                            ? '${myDefScaleInfo.defScaleModel!}\r\nSN:${myDefScaleInfo.defScaleSn!}\r\nSerial Port:${myDefScaleInfo.defScalePort!}\r\nBuadRate:${myDefScaleInfo.defScaleBaud!}'
                            : '${myDefScaleInfo.defScaleModel!}\r\nSN:${myDefScaleInfo.defScaleSn!}\r\nIP:${myDefScaleInfo.defScaleIp!}\r\nPort:${myDefScaleInfo.defScalePort!}',
                        child: Text(myDefScaleInfo.defScaleName!,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(context).colorScheme.onPrimary))),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  helpInfo != ''
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                              PageInfoButton(
                                  helpInfo: helpInfo, onRefresh: () {}),
                              const SizedBox(
                                width: 50,
                              ),
                            ])
                      : SizedBox()
                ],
              ),
            )
          ],
        ),
      ));
}

Widget pageHeadInfo(
    dynamic context, double maxWidth, String pageTitle, String helpInfo) {
  return Container(
      height: pageTopTitleHeight,
      color: Theme.of(context).colorScheme.surface,
      child: Column(children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              subTitle(context, maxWidth, pageTitle),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                PageInfoButton(helpInfo: helpInfo, onRefresh: () {}),
                const SizedBox(
                  width: largePadding,
                ),
              ])
            ],
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.surfaceContainerLow, // 设置分割线的颜色
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
              Navigator.pop(context);
            },
            icon: getSvgIcon(returnSvgIcon(), 28, 28,
                Theme.of(context).colorScheme.primary)),
      ),
      SizedBox(
        width: regularPadding,
      ),
      SizedBox(
        width: maxWidth,
        child: Text(
          pageTitle,
          style: Theme.of(context).textTheme.labelMedium!.apply(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class TopRightIcons extends StatefulWidget {
  final VoidCallback onRefresh; // 添加回调参数
  const TopRightIcons({super.key, required this.onRefresh});

  @override
  State<TopRightIcons> createState() => _TopRightIconsState();
}

class _TopRightIconsState extends State<TopRightIcons> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        PopupMenuButton<String>(
          tooltip: localizedStrings.menuApplications,
          // icon: TIcons.appsSvgIcon(
          //   width: topIconSize,
          //   height: topIconSize,
          //   color: colorScheme.primary,
          // ),
          offset: Offset(-15, 40),
          color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem(
              value: '1',
              child: Text(
                localizedStrings.menuConfiguration,
                style: textTheme.bodySmall!.apply(
                  // 根据选中状态改变颜色
                  color: colorScheme.surface,
                ),
              ),
              onTap: () {
                // if (currentPageId != PageId.config.index) {
                //   currentPageId = PageId.config.index;
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => const ConfigurationPage(),
                //     ),
                //   ).then((_) {
                //     setState(() {
                //       // 移除 print 语句，避免生产环境警告
                //     });
                //   });
                // }
              },
            ),
            PopupMenuDivider(height: 1.0),
            PopupMenuItem(
              value: '2',
              child: Text(
                localizedStrings.menuApplications,
                style: textTheme.bodySmall!.apply(
                  // 根据选中状态改变颜色
                  color: colorScheme.surface,
                ),
              ),
              onTap: () {
                // if (currentPageId != PageId.apps.index) {
                //   currentPageId = PageId.apps.index;
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => const AppsPage(),
                //     ),
                //   ).then((_) {
                //     setState(() {
                //       // 移除 print 语句，避免生产环境警告
                //     });
                //   });
                // }
              },
            ),
          ],
        ),
        SizedBox(
          width: regularPadding,
        ),
        PopupMenuButton<String>(
          tooltip: localizedStrings.menuLanguageSetting,
          // icon: TIcons.settingSvgIcon(
          //   width: topIconSize,
          //   height: topIconSize,
          //   color: colorScheme.primary,
          // ),
          offset: Offset(-15, 40),
          color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem(
              value: '1',
              child: Text(
                localizedStrings.menuLanguageSetting,
                style: textTheme.bodySmall!.apply(
                  // 根据选中状态改变颜色
                  color: colorScheme.surface,
                ),
              ),
              onTap: () {
                // 延迟执行，避免菜单关闭时 UI 闪烁
                if (mounted) {
                  _setLanguageDialog(context);
                }
              },
            ),
            PopupMenuDivider(height: 1.0),
          ],
        ),
        SizedBox(
          width: regularPadding,
        ),
        // Tooltip(
        //   message: localizedStrings.menuSystemInformation,
        //   child: IconButton(
        //     icon: Icons.abc,
        //     //  TIcons.infoSvgIcon(
        //     //   width: topIconSize,
        //     //   height: topIconSize,
        //     //   color: colorScheme.primary,
        //     // ),
        //     onPressed: () {
        //       // showLicenseDialog(context);
        //       showDialog(
        //         context: context,
        //         barrierDismissible: false, // 允许点击空白处关闭对话框
        //         builder: (context) {
        //           return const CompanyInfoDialog();
        //         },
        //       );
        //     },
        //   ),
        // ),
        SizedBox(
          width: regularPadding,
        )
      ],
    );
  }

  void _setLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LanguageSettingPage();
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          // 可以在这里添加刷新状态的逻辑
        });
        widget.onRefresh(); // 调用回调刷新页面
      }
    });
  }
}

//添加多台秤页面，增加串口，网络秤的标题显示

Widget subTitleInfo(
    dynamic context, double maxWidth, String pageTitle, String helpInfo) {
  return SizedBox(
      height: pageTopTitleHeight,
      child: Column(children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              subNewTitle(context, maxWidth, pageTitle),
              // Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              //   PageInfoButton(helpInfo: helpInfo, onRefresh: () {}),
              //   const SizedBox(
              //     width: largePadding,
              //   ),
              // ])
            ],
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.surfaceContainerLow, // 设置分割线的颜色
          height: 1, // 设置分割线的高度
          thickness: 1, // 设置分割线的粗细
        ),
      ]));
}

Widget subNewTitle(
  dynamic context,
  double maxWidth,
  String pageTitle,
) {
  return Row(
    children: [
      SizedBox(
        width: largePadding,
      ),
      Container(
        color: Theme.of(context).colorScheme.onSurface, // 设置分割线的颜色
        width: 3, // 设置分割线的宽度
        height: regularPadding, // 设置分割线的粗细
      ),
      SizedBox(
        width: regularPadding,
      ),
      SizedBox(
        width: maxWidth,
        child: Text(
          pageTitle,
          style: Theme.of(context).textTheme.labelMedium!.apply(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
