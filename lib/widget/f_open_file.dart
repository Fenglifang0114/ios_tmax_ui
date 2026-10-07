import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
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
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = Platform.isIOS || Platform.isAndroid || screenWidth < 650;
        final dialogWidth = isMobile ? (screenWidth * 0.9).clamp(300.0, 500.0) : 610.0;
        final isZh = Localizations.localeOf(context).languageCode == 'zh';

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 0),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头部
                  ...dialogHeadStyle(
                      context, (localizedStrings?.gTipExportSuccess ?? "Export Successful"), true),

                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: getSvgIcon(exportSuccessSvgIcon(), isMobile ? 120 : 178, isMobile ? 120 : 178,
                              colorScheme.onTertiaryFixedVariant),
                        ),
                      ),
                    ]),
                  ),

                  // 中部
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SelectableText(
                          filePath,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                        if (Platform.isIOS) ...[
                          const SizedBox(height: 12),
                          Text(
                            isZh
                                ? "提示：文件已保存至系统【文件】->【我的 iPhone】->【T Max】目录下"
                                : "Tip: Saved to iOS [Files] -> [On My iPhone] -> [T Max]",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 底部
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        showTextButton(
                            context, btnHeight, (localizedStrings?.gBtnCancel ?? "Cancel"), () {
                          Navigator.pop(context);
                        }, colorScheme.onPrimary, colorScheme.error,
                            colorScheme.onPrimary),

                        // 移动端（iOS / Android）：支持通过系统分享面板另存为或分享
                        if (Platform.isIOS || Platform.isAndroid)
                          showTextButton(
                            context,
                            btnHeight,
                            isZh ? "分享 / 另存为" : "Share / Export",
                            () async {
                              try {
                                final file = File(filePath);
                                if (await file.exists()) {
                                  final bytes = await file.readAsBytes();
                                  await Printing.sharePdf(
                                    bytes: bytes,
                                    filename: p.basename(filePath),
                                  );
                                }
                              } catch (e) {
                                debugPrint("Share file error: $e");
                              }
                            },
                            colorScheme.onPrimary,
                            colorScheme.primary,
                            colorScheme.onPrimary,
                          ),

                        // 桌面端专属：打开文件所在文件夹
                        if (!Platform.isAndroid && !Platform.isIOS)
                          showTextButton(context, btnHeight,
                              (localizedStrings?.gBtnOpenFileLocation ?? "Open Location"), () async {
                            if (Platform.isWindows) {
                              await Process.run('explorer.exe', ['/select,', filePath]);
                            } else if (Platform.isMacOS) {
                              await Process.run('open', ['-R', filePath]);
                            } else if (Platform.isLinux) {
                              String directory = Directory(filePath).parent.path;
                              await Process.run('xdg-open', [directory]);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }, colorScheme.onPrimary, colorScheme.primary,
                              colorScheme.onPrimary),

                        // 桌面端专属：直接打开文件
                        if (!Platform.isAndroid && !Platform.isIOS)
                          showTextButton(
                              context, btnHeight, (localizedStrings?.gBtnOpenFile ?? "Open File"),
                              () async {
                            final Uri fileUri = Uri.file(filePath);
                            if (await canLaunchUrl(fileUri)) {
                              await launchUrl(fileUri);
                            } else {
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
          ),
        );
      },
    );
  }
}
