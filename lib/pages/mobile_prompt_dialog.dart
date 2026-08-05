import 'package:flutter/material.dart';
import 'package:t_max/data/language.dart';

class MobilePromptDialog extends StatelessWidget {
  final String? title;
  final String msg;
  final String? confirmText;
  final Color confirmColor;

  const MobilePromptDialog({
    super.key,
    this.title,
    required this.msg,
    this.confirmText,
    this.confirmColor = const Color(0xFFFF4D4F),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Row: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title?.isNotEmpty == true
                      ? title!
                      : (localizedStrings?.fTipTitle ?? 'Prompt'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context, false),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Broom / Clean Graphic Illustration
            const _BroomIllustration(),
            const SizedBox(height: 20),

            // Message Content Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                msg.isNotEmpty
                    ? msg
                    : (localizedStrings?.fClearWeighingDataMsg ??
                        'Current weighing data will be cleared.\nConfirm Continue?'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  confirmText?.isNotEmpty == true
                      ? confirmText!
                      : (localizedStrings?.gBtnConfirm ?? 'Confirm'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

/// Custom illustration matching the broom/clean icon with sparkles
class _BroomIllustration extends StatelessWidget {
  const _BroomIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 110,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft pink oval shadow
          Positioned(
            bottom: 0,
            child: Container(
              width: 90,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEF),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Broom & sparkles icon
          const Icon(
            Icons.cleaning_services,
            size: 64,
            color: Color(0xFFFF4D4F),
          ),
          // Sparkle 1 (Top Right)
          const Positioned(
            top: 10,
            right: 15,
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: Color(0xFFFF859B),
            ),
          ),
          // Sparkle 2 (Top Left paper airplane / star)
          const Positioned(
            top: 14,
            left: 15,
            child: Icon(
              Icons.send_rounded,
              size: 16,
              color: Color(0xFFFFB3C1),
            ),
          ),
        ],
      ),
    );
  }
}
