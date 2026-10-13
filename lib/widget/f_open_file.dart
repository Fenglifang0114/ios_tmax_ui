import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/generated/l10n.dart';
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
        final s = S.of(context);
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = Platform.isIOS || Platform.isAndroid || screenWidth < 650;
        final dialogWidth = isMobile ? (screenWidth * 0.9).clamp(300.0, 500.0) : 610.0;

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
                  ...dialogHeadStyle(context, s.gTipExportSuccess, true),

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
                          Platform.isIOS ? p.basename(filePath) : filePath,
                          textAlign: TextAlign.center,
                          style: Platform.isIOS
                              ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
                              : textTheme.bodyMedium,
                        ),
                        if (Platform.isIOS) ...[
                          const SizedBox(height: 12),
                          Text(
                            s.gTipExportIosSavedNotice,
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
                    child: isMobile
                        ? Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 42,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      side: BorderSide(
                                          color: colorScheme.outline.withOpacity(0.3)),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      s.gBtnCancel,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 42,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    icon: const Icon(Icons.share,
                                        size: 18, color: Colors.white),
                                    label: Text(
                                      s.gBtnShareOrSave,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final box =
                                          context.findRenderObject() as RenderBox?;
                                      final bounds = box != null && box.hasSize
                                          ? box.localToGlobal(Offset.zero) &
                                              box.size
                                          : Rect.fromLTWH(
                                              0, 0, screenWidth, 100);
                                      try {
                                        final file = File(filePath);
                                        if (await file.exists()) {
                                          final bytes = await file.readAsBytes();
                                          await Printing.sharePdf(
                                            bytes: bytes,
                                            filename: p.basename(filePath),
                                            bounds: bounds,
                                          );
                                        } else {
                                          debugPrint(
                                              "Export file does not exist: $filePath");
                                        }
                                      } catch (e) {
                                        debugPrint("Share file error: $e");
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 38,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.error,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    s.gBtnCancel,
                                    style: TextStyle(color: colorScheme.onPrimary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 140,
                                height: 38,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (Platform.isWindows) {
                                      await Process.run(
                                          'explorer.exe', ['/select,', filePath]);
                                    } else if (Platform.isMacOS) {
                                      await Process.run('open', ['-R', filePath]);
                                    } else if (Platform.isLinux) {
                                      String directory =
                                          Directory(filePath).parent.path;
                                      await Process.run('xdg-open', [directory]);
                                    }
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    s.gBtnOpenFileLocation,
                                    style: TextStyle(color: colorScheme.onPrimary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 120,
                                height: 38,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final Uri fileUri = Uri.file(filePath);
                                    if (await canLaunchUrl(fileUri)) {
                                      await launchUrl(fileUri);
                                    } else {
                                      String directory =
                                          Directory(filePath).parent.path;
                                      final Uri dirUri = Uri.file(directory);
                                      if (await canLaunchUrl(dirUri)) {
                                        await launchUrl(dirUri);
                                      }
                                    }
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    s.gBtnOpenFile,
                                    style: TextStyle(color: colorScheme.onPrimary),
                                  ),
                                ),
                              ),
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
