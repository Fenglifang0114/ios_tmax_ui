import 'package:flutter/material.dart';
import 'package:t_max/widget/t_max_dialog.dart';

import 'package:t_max/widget/dialog_head_style.dart';
import '../data/language.dart';
import '../data/plu_field_status_data.dart';

class MultiSelectDialog extends StatefulWidget {
  final Map<String, FieldNameStatus> options;
  final List<String> selectedOptions;

  const MultiSelectDialog(
      {required this.options,
      required this.selectedOptions,
      super.key,
      required BuildContext context});

  @override
  MultiSelectDialogState createState() => MultiSelectDialogState();
}

class MultiSelectDialogState extends State<MultiSelectDialog> {
  List<String> _selectedOptions = [];

  bool closeButtonEnabled = true;
  bool isSelectAll = false;

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        if (option != 'plu' && option != 'productName') {
          _selectedOptions.remove(option);
        }
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // 在初始化时将options的所有键添加到_selectedOptions中

    _selectedOptions = widget.selectedOptions;
  }

  // 全选方法
  void selectAll(bool value) {
    setState(() {
      _selectedOptions.clear();
      if (!value) {
        _selectedOptions.add('plu');
        _selectedOptions.add('productName');
      }

      for (var entry in widget.options.entries) {
        if (value) {
          _selectedOptions.add(entry.key);
        }
      }
    });
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  TextStyle getTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodySmall!.apply(
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TMaxDialog(
      backgroundColor: Colors.transparent,
      child: Container(
          width: 630,
          height: 493,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            children: [
              // 头部
              ...dialogHeadStyle(context, (localizedStrings?.gPluField ?? "gPluField"), false),

              // 中部
              Expanded(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(children: [
                        CheckboxListTile(
                          title: Text(
                            (localizedStrings?.gSelectAll ?? "gSelectAll"),
                            style: TextStyle(overflow: TextOverflow.ellipsis),
                          ),
                          value: isSelectAll,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isSelectAll = newValue!;
                              selectAll(newValue);
                            });
                          },
                        ),
                        GridView.count(
                          shrinkWrap: true, // 使 GridView 适应内容高度
                          physics: const NeverScrollableScrollPhysics(), // 禁止滚动
                          crossAxisCount: 3, // 设置列数为 3
                          crossAxisSpacing: 8.0, // 水平间距
                          mainAxisSpacing: 0.0, // 适当减小垂直间距
                          childAspectRatio: 5, // 设置子组件宽高比，可按需调整
                          children: widget.options.entries.map((entry) {
                            return CheckboxListTile(
                              title: Text(
                                entry.value.field,
                                style: getTextStyle(),
                                overflow: TextOverflow.ellipsis,
                              ),
                              value: _selectedOptions.contains(entry.key),
                              onChanged: closeButtonEnabled
                                  ? (value) => _toggleOption(entry.key)
                                  : null,
                            );
                          }).toList(),
                        ),
                      ]))),

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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          fixedSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(_selectedOptions);
                        },
                        child: Text(
                          (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                          style: getTextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          fixedSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                          style: getTextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
