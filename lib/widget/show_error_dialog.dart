import 'package:flutter/material.dart';
import 'package:t_max/widget/dialog_head_style.dart';

import '../data/language.dart';

void showErrorDialog(BuildContext context, String tipStr) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
            width: 480,
            height: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              children: [
                // 头部
                ...dialogHeadStyle(
                    context, localizedStrings.gTitleConfirm, false),

                // 中部
                Expanded(
                    child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text(tipStr,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(ctx).textTheme.bodySmall),
                )),

                // 底部
                Container(
                  height: 90,
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
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            fixedSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop(true); // 跳转
                          },
                          child: Text(
                            localizedStrings.gBtnConfirm,
                            style: Theme.of(ctx).textTheme.bodySmall!.apply(
                                  color: Theme.of(ctx).colorScheme.onPrimary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
              ],
            )),
      );
    },
  ).then((confirmed) {
    if (confirmed) {}
  });
}
