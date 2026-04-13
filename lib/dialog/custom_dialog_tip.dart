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
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          // 当对话框关闭时，清除当前对话框上下文
          if (didPop) {
            _currentDialogContext = null;
          }
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
    _timer = Timer(const Duration(seconds: 5), () {
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
        height: 120,
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Center(
              child: Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ))
          ],
        ),
      ),
    );
  }
}

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

// 定义验证原料的弹框
class ShowCheckCodeDialog extends StatefulWidget {
  const ShowCheckCodeDialog(
      {super.key,
      required this.title,
      required this.rawId,
      required this.rawName,
      required this.rawCode,
      required this.canSave});
  final String title;
  final String rawId;
  final String rawName;
  final String rawCode;
  final bool canSave;

  @override
  ShowCheckCodeDialogState createState() => ShowCheckCodeDialogState();
}

class ShowCheckCodeDialogState extends State<ShowCheckCodeDialog> {
  TextEditingController checkCodeCtl = TextEditingController();
  late FocusNode _checkCodeFocusNode;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    _checkCodeFocusNode = FocusNode();

    // 在下一帧请求焦点，确保组件已构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCodeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _checkCodeFocusNode.dispose();
    checkCodeCtl.dispose();
    super.dispose();
  }

  Widget showTextTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurface, // 设置文本颜色
          ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget showName(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.apply(
            color: Theme.of(context).colorScheme.primary, // 设置文本颜色
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 350,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...fmaDialogHeadStyle(
                context, widget.title, localizedStrings.gParameterSettingsTitle,
                () {
              Navigator.pop(context, "set");
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(regularPadding),
                child: Column(children: [
                  Expanded(
                    child: Row(children: [
                      Expanded(
                          child: Align(
                              alignment: Alignment.center,
                              child: showName(widget.rawName))),
                    ]),
                  ),
                  SizedBox(
                    height: 40,
                    child: Row(children: [
                      Expanded(
                          flex: 2,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: showTextTitle(
                                  localizedStrings.fMaterialIdCol + ":  "))),
                      Expanded(
                          flex: 3,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: showTextTitle(widget.rawId))),
                    ]),
                  ),
                  SizedBox(
                    height: 40,
                    child: Row(children: [
                      Expanded(
                          flex: 2,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: showTextTitle(
                                  localizedStrings.fMaterialCodeCol + ":  "))),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: checkCodeCtl,
                          focusNode: _checkCodeFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0.0))),
                            hintText: localizedStrings.fMaterialCodeCol,
                            hintStyle:
                                Theme.of(context).textTheme.bodySmall!.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest, // 设置提示文本颜色
                                    ),
                          ),
                          style: Theme.of(context).textTheme.bodySmall!.apply(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface, // 设置输入文本颜色
                              ),
                          onChanged: (value) {
                            setState(() {
                              errorText = '';
                            });

                            if (value.isNotEmpty && value == widget.rawCode) {
                              Navigator.pop(context, "ok");
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty && value == widget.rawCode) {
                              Navigator.pop(context, "ok");
                            } else {
                              setState(() {
                                errorText =
                                    localizedStrings.verificationCodeMismatch;
                                checkCodeCtl.text = "";
                                _checkCodeFocusNode.requestFocus();
                              });
                            }
                          },
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  SizedBox(
                    height: 40,
                    child: Text(
                      errorText,
                      style: Theme.of(context).textTheme.bodySmall!.apply(
                            color:
                                Theme.of(context).colorScheme.error, // 设置输入文本颜色
                          ),
                    ),
                  )
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 600,
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
                        Navigator.pop(context, "skip");
                      },
                      child: Text(
                        localizedStrings.skipThisIngredient,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
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
                        Navigator.pop(context, "abandon");
                      },
                      child: Text(
                        localizedStrings.fAbandonIngredientsBtn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
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
                      onPressed: widget.canSave
                          ? () {
                              Navigator.pop(context, "save");
                            }
                          : null,
                      child: Text(
                        localizedStrings.btnTemporarySave,
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
