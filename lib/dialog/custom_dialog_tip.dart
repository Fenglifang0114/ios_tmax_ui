import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';

// 用于存储当前显示的对话框的上下文
BuildContext? _currentDialogContext;

void showTipInfo(String message, BuildContext context) {
  // 如果有当前显示的对话框，先关闭它
  if (_currentDialogContext != null &&
      Navigator.canPop(_currentDialogContext!)) {
    Navigator.pop(_currentDialogContext!);
  }

  showDialog(
    context: context,
    barrierColor: Colors.transparent, // 设置透明底色
    builder: (BuildContext dialogContext) {
      // 记录当前对话框的上下文
      _currentDialogContext = dialogContext;
      return WillPopScope(
        onWillPop: () async {
          // 当对话框关闭时，清除当前对话框上下文
          _currentDialogContext = null;
          return true;
        },
        child: CustomDialogView(
          message: message,
          onClose: () {
            // 关闭对话框时，清除当前对话框上下文
            _currentDialogContext = null;
            if (Navigator.canPop(dialogContext)) {
              Navigator.pop(dialogContext);
            }
          },
        ),
      );
    },
  );
}

class CustomDialogView extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  const CustomDialogView(
      {super.key, required this.message, required this.onClose});

  @override
  State<CustomDialogView> createState() => _CustomDialogViewState();
}

class _CustomDialogViewState extends State<CustomDialogView> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      // 时间到后调用关闭回调
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 500,
        height: 80,
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Center(
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

// void showTipInfo(String message, BuildContext context) {
//   showDialog(
//     context: context,
//     barrierColor: Colors.transparent, //设置透明底色
//     builder: (BuildContext context) {
//       return CustomDialogView(
//         message: message,
//       );
//     },
//   );
// }

// class CustomDialogView extends StatefulWidget {
//   final String message;
//   const CustomDialogView({super.key, required this.message});

//   @override
//   State<CustomDialogView> createState() => _CustomDialogViewState();
// }

// class _CustomDialogViewState extends State<CustomDialogView> {
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _timer = Timer(const Duration(seconds: 3), () {
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         width: 500,
//         height: 80,
//         color: const Color.fromRGBO(0, 0, 0, 0.8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Expanded(
//                 child: Center(
//               child: Text(
//                 widget.message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.normal,
//                   decoration: TextDecoration.none,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ))
//           ],
//         ),
//       ),
//     );
//   }
// }

// 定义提示单位不对的弹框
class ShowNormalTipDialog extends StatefulWidget {
  const ShowNormalTipDialog(
      {super.key, required this.title, required this.msg});
  final String title;
  final String msg;
  @override
  ShowNormalTipDialogState createState() => ShowNormalTipDialogState();
}

class ShowNormalTipDialogState extends State<ShowNormalTipDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, widget.title, true),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 150,
                width: 380,
                child: Row(children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        localizedStrings.gBtnCancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 定义提示删除的弹框
class ShowDeleteTipDialog extends StatefulWidget {
  const ShowDeleteTipDialog(
      {super.key, required this.title, required this.msg});
  final String title;
  final String msg;
  @override
  ShowDeleteTipDialogState createState() => ShowDeleteTipDialogState();
}

class ShowDeleteTipDialogState extends State<ShowDeleteTipDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, widget.title, true, onClose: () {
              Navigator.pop(context, false);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 150,
                width: 380,
                child: Row(children: [
                  Icon(Icons.warning,
                      size: 48, color: Theme.of(context).colorScheme.error),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        localizedStrings.gBtnDelete,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        localizedStrings.gBtnCancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//正常提示的对话框
class ShowHignWgtTipDialog extends StatefulWidget {
  const ShowHignWgtTipDialog(
      {super.key, required this.title, required this.msg});
  final String title;
  final String msg;
  @override
  ShowHignWgtTipDialogState createState() => ShowHignWgtTipDialogState();
}

class ShowHignWgtTipDialogState extends State<ShowHignWgtTipDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, widget.title, true, onClose: () {
              Navigator.pop(context, 0);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 150,
                width: 380,
                child: Row(children: [
                  Icon(Icons.warning,
                      size: 48, color: Theme.of(context).colorScheme.error),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, 1);
                      },
                      child: Text(
                        localizedStrings.fAbandonBtn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, 2);
                      },
                      child: Text(
                        localizedStrings.fReviseBtn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//正常提示的对话框
class ShowLowWgtTipDialog extends StatefulWidget {
  const ShowLowWgtTipDialog(
      {super.key, required this.title, required this.msg});
  final String title;
  final String msg;
  @override
  ShowLowWgtTipDialogState createState() => ShowLowWgtTipDialogState();
}

class ShowLowWgtTipDialogState extends State<ShowLowWgtTipDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, widget.title, true, onClose: () {
              Navigator.pop(context, 0);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 150,
                width: 380,
                child: Row(children: [
                  Icon(Icons.warning,
                      size: 48, color: Theme.of(context).colorScheme.error),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: showTextButton(
                          context, btnHeight, localizedStrings.gBtnConfirm, () {
                    Navigator.pop(context, 1);
                  },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary)),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: showTextButton(
                          context, btnHeight, localizedStrings.gBtnCancel, () {
                    Navigator.pop(context, 0);
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

// 定义提示单位不对的弹框
class ShowUnitTipDialog extends StatefulWidget {
  const ShowUnitTipDialog({super.key, required this.title, required this.msg});
  final String title;
  final String msg;
  @override
  ShowUnitTipDialogState createState() => ShowUnitTipDialogState();
}

class ShowUnitTipDialogState extends State<ShowUnitTipDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              widget.title,
              true,
            ),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 150,
                width: 380,
                child: Row(children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

getCustomDialogTitle(
  BuildContext context,
  String title,
) {
  return [
    Container(
        height: dialogTitleheight,
        padding: const EdgeInsets.only(left: largePadding, right: largePadding),
        alignment: Alignment.centerLeft,
        child: Row(children: [
          Container(
            width: 3,
            height: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(
            width: regularPadding,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.cancel,
                size: 24,
                color: Theme.of(context).colorScheme.secondaryFixed,
              ),
              onPressed: () {
                Navigator.pop(context);
              })
        ])),
    // 分割线
    Divider(
      height: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
    )
  ];
}
