import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import 'package:url_launcher/url_launcher.dart';

void showExportDialog(String filePath, BuildContext context) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  final TextTheme textTheme = Theme.of(context).textTheme;

  final BuildContext currentContext = context;
  if (currentContext.mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    context, (localizedStrings?.gTipExportSuccess ?? "gTipExportSuccess"), true),

                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: getSvgIcon(exportSuccessSvgIcon(), 178, 178,
                            colorScheme.onTertiaryFixedVariant),
                      ),
                    ),
                  ]),
                ),

                // 中部
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: SelectableText(
                            filePath,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

                // 底部
                Container(
                  height: 96,
                  width: 610,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      showTextButton(
                          context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"), () {
                        Navigator.pop(context);
                      }, colorScheme.onPrimary, colorScheme.error,
                          colorScheme.onPrimary),
                      SizedBox(
                        width: 20,
                      ),
                      showTextButton(context, btnHeight,
                          (localizedStrings?.gBtnOpenFileLocation ?? "gBtnOpenFileLocation"), () async {
                        // 打开文件所在文件夹或直接打开文件
                        if (Platform.isWindows) {
                          // Windows: 打开文件所在文件夹并选中文件
                          await Process.run(
                              'explorer.exe', ['/select,', filePath]);
                        } else if (Platform.isMacOS) {
                          // macOS: 在Finder中显示文件
                          await Process.run('open', ['-R', filePath]);
                        } else if (Platform.isLinux) {
                          // Linux: 打开文件所在目录
                          String directory = Directory(filePath).parent.path;
                          await Process.run('xdg-open', [directory]);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }, colorScheme.onPrimary, colorScheme.primary,
                          colorScheme.onPrimary),
                      SizedBox(
                        width: 20,
                      ),
                      showTextButton(
                          context, btnHeight, (localizedStrings?.gBtnOpenFile ?? "gBtnOpenFile"),
                          () async {
                        // 直接打开文件
                        final Uri fileUri = Uri.file(filePath);
                        if (await canLaunchUrl(fileUri)) {
                          await launchUrl(fileUri);
                        } else {
                          // 如果无法直接打开，则打开文件所在目录
                          String directory = Directory(filePath).parent.path;
                          final Uri dirUri = Uri.file(directory);
                          if (await canLaunchUrl(dirUri)) {
                            await launchUrl(dirUri);
                          }
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }, colorScheme.onPrimary, colorScheme.primary,
                          colorScheme.onPrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
