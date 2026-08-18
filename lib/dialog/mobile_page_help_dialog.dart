import 'package:flutter/material.dart';
import 'package:t_max/data/help_data.dart';
import 'package:t_max/data/language.dart';

class MobilePageHelpDialog extends StatelessWidget {
  final String title;
  final String helpInfo;

  const MobilePageHelpDialog({
    super.key,
    required this.title,
    required this.helpInfo,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.trim().isNotEmpty
        ? title
        : (localizedStrings?.gTipHelp ?? "Help");
    final displayContent = helpInfo.trim().isNotEmpty
        ? helpInfo
        : (localizedStrings?.gTipHelp ?? "Help instructions for this feature.");

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & Cancel Icon (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Color(0xFF94A3B8), size: 24),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Help Content Text (RichText supporting [Bracket] highlights)
            Flexible(
              child: SingleChildScrollView(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF334155),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF334155),
                      ),
                      children: TextUtils.generateTextSpans(
                        context,
                        displayContent,
                        const Color(0xFF0284C7), // Blue highlight color for bracketed items
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bottom Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Solid Emerald Green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  localizedStrings?.gBtnConfirm ?? "Confirm",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 全局显示手机端帮助弹框函数
void showMobilePageHelpDialog(BuildContext context, String? title, String? helpInfo) {
  final safeTitle = (title != null && title.trim().isNotEmpty) ? title : "Help";
  final safeInfo = (helpInfo != null && helpInfo.trim().isNotEmpty)
      ? helpInfo
      : "Help instructions for this feature.";

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => MobilePageHelpDialog(
      title: safeTitle,
      helpInfo: safeInfo,
    ),
  );
}


